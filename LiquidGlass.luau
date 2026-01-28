--[[
	LiquidGlass - A Roblox Luau UI Library
	
	Replicates the "Liquid Glass" effect from React with:
	- Frosted glass appearance with semi-transparent blur simulation
	- Rounded corners with configurable radius
	- Reflective borders that respond to mouse position
	- Elastic/liquid feel - element subtly moves toward cursor
	- Hover effects with radial highlights
	- Click/press scale animations
	- Multiple visual layers for depth
	- Configurable drop shadows
	
	Usage:
		local LiquidGlass = require(path.to.LiquidGlass)
		
		local glass = LiquidGlass.new({
			Size = UDim2.new(0, 200, 0, 60),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Parent = screenGui,
			CornerRadius = UDim.new(0, 20),
			OnClick = function() print("Clicked!") end,
		})
		
		glass:SetContent(textLabel)
		glass:Destroy()
	
	@author LiquidGlass Luau Port
	@version 1.0.0
]]

--// Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

--// Types
export type LiquidGlassOptions = {
	-- Core settings
	Size: UDim2?,
	Position: UDim2?,
	AnchorPoint: Vector2?,
	Parent: GuiObject?,
	ZIndex: number?,
	
	-- Glass effect settings
	CornerRadius: UDim?,
	BackgroundColor: Color3?,
	BackgroundTransparency: number?,
	BlurTint: Color3?,
	
	-- Border settings
	BorderColor: Color3?,
	BorderTransparency: number?,
	BorderThickness: number?,
	
	-- Shadow settings
	ShadowColor: Color3?,
	ShadowTransparency: number?,
	ShadowOffset: Vector2?,
	ShadowSize: number?,
	
	-- Interaction settings
	Elasticity: number?,
	HoverHighlight: boolean?,
	ClickScale: number?,
	
	-- Events
	OnClick: (() -> ())?,
	OnHover: ((hovering: boolean) -> ())?,
}

export type LiquidGlass = {
	SetContent: (self: LiquidGlass, content: GuiObject) -> (),
	Destroy: (self: LiquidGlass) -> (),
	SetProperty: (self: LiquidGlass, key: string, value: any) -> (),
	GetFrame: (self: LiquidGlass) -> Frame,
}

--// Constants
local DEFAULT_OPTIONS: LiquidGlassOptions = {
	Size = UDim2.new(0, 200, 0, 60),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Parent = nil,
	ZIndex = 1,
	
	CornerRadius = UDim.new(0, 20),
	BackgroundColor = Color3.fromRGB(255, 255, 255),
	BackgroundTransparency = 0.85,
	BlurTint = Color3.fromRGB(200, 200, 220),
	
	BorderColor = Color3.fromRGB(255, 255, 255),
	BorderTransparency = 0.5,
	BorderThickness = 1.5,
	
	ShadowColor = Color3.fromRGB(0, 0, 0),
	ShadowTransparency = 0.7,
	ShadowOffset = Vector2.new(0, 8),
	ShadowSize = 20,
	
	Elasticity = 0.15,
	HoverHighlight = true,
	ClickScale = 0.96,
	
	OnClick = nil,
	OnHover = nil,
}

-- Tween configurations
local TWEEN_INFO_FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_INFO_SMOOTH = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_INFO_ELASTIC = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

--// Helper Functions

--- Merges default options with provided options
local function mergeOptions(provided: LiquidGlassOptions?): LiquidGlassOptions
	local result = {}
	for key, defaultValue in pairs(DEFAULT_OPTIONS) do
		if provided and provided[key] ~= nil then
			result[key] = provided[key]
		else
			result[key] = defaultValue
		end
	end
	return result
end

--- Clamps a number between min and max
local function clamp(value: number, min: number, max: number): number
	return math.max(min, math.min(max, value))
end

--- Calculates the mouse offset relative to the element center (-1 to 1 range)
local function calculateMouseOffset(mousePos: Vector2, framePos: Vector2, frameSize: Vector2): Vector2
	local centerX = framePos.X + frameSize.X / 2
	local centerY = framePos.Y + frameSize.Y / 2
	
	local offsetX = (mousePos.X - centerX) / (frameSize.X / 2)
	local offsetY = (mousePos.Y - centerY) / (frameSize.Y / 2)
	
	return Vector2.new(
		clamp(offsetX, -1, 1),
		clamp(offsetY, -1, 1)
	)
end

--- Creates a radial gradient color sequence for hover effects
local function createRadialGradientSequence(centerColor: Color3, edgeColor: Color3): ColorSequence
	return ColorSequence.new({
		ColorSequenceKeypoint.new(0, centerColor),
		ColorSequenceKeypoint.new(0.5, Color3.new(
			centerColor.R * 0.7 + edgeColor.R * 0.3,
			centerColor.G * 0.7 + edgeColor.G * 0.3,
			centerColor.B * 0.7 + edgeColor.B * 0.3
		)),
		ColorSequenceKeypoint.new(1, edgeColor),
	})
end

--- Creates a transparency gradient for radial effect simulation
local function createRadialTransparencySequence(centerTransparency: number, edgeTransparency: number): NumberSequence
	return NumberSequence.new({
		NumberSequenceKeypoint.new(0, centerTransparency),
		NumberSequenceKeypoint.new(0.4, centerTransparency + (edgeTransparency - centerTransparency) * 0.3),
		NumberSequenceKeypoint.new(1, edgeTransparency),
	})
end

--- Calculates gradient rotation based on mouse offset (for reflective border effect)
local function calculateGradientRotation(mouseOffset: Vector2): number
	-- Base rotation + offset influence (similar to React's 135 + mouseOffset.x * 1.2 degrees)
	return 135 + mouseOffset.X * 45
end

--- Creates the inner glow gradient (white at top, transparent at bottom)
local function createInnerGlowGradient(): ColorSequence
	return ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.3, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
	})
end

local function createInnerGlowTransparency(): NumberSequence
	return NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.7),
		NumberSequenceKeypoint.new(0.3, 0.85),
		NumberSequenceKeypoint.new(1, 1),
	})
end

--// LiquidGlass Module
local LiquidGlass = {}
LiquidGlass.__index = LiquidGlass

--[[
	Creates a new LiquidGlass element
	
	@param options LiquidGlassOptions - Configuration options
	@return LiquidGlass - The glass element instance
]]
function LiquidGlass.new(options: LiquidGlassOptions?): LiquidGlass
	local self = setmetatable({}, LiquidGlass)
	
	-- Merge with defaults
	self._options = mergeOptions(options)
	self._connections = {} :: {RBXScriptConnection}
	self._tweens = {} :: {Tween}
	self._isHovered = false
	self._isPressed = false
	self._mouseOffset = Vector2.new(0, 0)
	self._destroyed = false
	self._content = nil :: GuiObject?
	
	-- Create the UI hierarchy
	self:_createUI()
	
	-- Setup interactions
	self:_setupInteractions()
	
	return self
end

--[[
	Creates the complete UI hierarchy for the glass effect
	Layers (back to front):
	1. Shadow Frame
	2. Glass Base Frame (with blur tint)
	3. Inner Glow Frame (top gradient)
	4. Border Frame (with UIStroke + UIGradient)
	5. Hover Highlight Frame
	6. Content Frame
]]
function LiquidGlass:_createUI()
	local opts = self._options
	
	-- Container Frame (holds everything, handles transforms)
	local container = Instance.new("Frame")
	container.Name = "LiquidGlassContainer"
	container.Size = opts.Size
	container.Position = opts.Position
	container.AnchorPoint = opts.AnchorPoint
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.ZIndex = opts.ZIndex
	container.ClipsDescendants = false
	self._container = container
	
	-- Store original position for elastic movement
	self._originalPosition = opts.Position
	
	-- 1. Shadow Frame (behind everything)
	local shadowFrame = Instance.new("Frame")
	shadowFrame.Name = "Shadow"
	shadowFrame.Size = UDim2.new(1, opts.ShadowSize * 2, 1, opts.ShadowSize * 2)
	shadowFrame.Position = UDim2.new(0.5, opts.ShadowOffset.X, 0.5, opts.ShadowOffset.Y)
	shadowFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	shadowFrame.BackgroundColor3 = opts.ShadowColor
	shadowFrame.BackgroundTransparency = opts.ShadowTransparency
	shadowFrame.BorderSizePixel = 0
	shadowFrame.ZIndex = opts.ZIndex
	shadowFrame.Parent = container
	
	local shadowCorner = Instance.new("UICorner")
	shadowCorner.CornerRadius = UDim.new(
		opts.CornerRadius.Scale,
		opts.CornerRadius.Offset + opts.ShadowSize
	)
	shadowCorner.Parent = shadowFrame
	
	-- Shadow blur simulation (gradient from center outward)
	local shadowGradient = Instance.new("UIGradient")
	shadowGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, opts.ShadowTransparency),
		NumberSequenceKeypoint.new(0.7, opts.ShadowTransparency + 0.1),
		NumberSequenceKeypoint.new(1, 1),
	})
	shadowGradient.Parent = shadowFrame
	self._shadowFrame = shadowFrame
	self._shadowGradient = shadowGradient
	
	-- 2. Glass Base Frame (main frosted glass appearance)
	local glassBase = Instance.new("Frame")
	glassBase.Name = "GlassBase"
	glassBase.Size = UDim2.new(1, 0, 1, 0)
	glassBase.Position = UDim2.new(0.5, 0, 0.5, 0)
	glassBase.AnchorPoint = Vector2.new(0.5, 0.5)
	glassBase.BackgroundColor3 = opts.BackgroundColor
	glassBase.BackgroundTransparency = opts.BackgroundTransparency
	glassBase.BorderSizePixel = 0
	glassBase.ZIndex = opts.ZIndex + 1
	glassBase.Parent = container
	
	local glassCorner = Instance.new("UICorner")
	glassCorner.CornerRadius = opts.CornerRadius
	glassCorner.Parent = glassBase
	self._glassBase = glassBase
	
	-- Blur tint overlay (simulates frosted glass tint)
	local blurTint = Instance.new("Frame")
	blurTint.Name = "BlurTint"
	blurTint.Size = UDim2.new(1, 0, 1, 0)
	blurTint.Position = UDim2.new(0, 0, 0, 0)
	blurTint.BackgroundColor3 = opts.BlurTint
	blurTint.BackgroundTransparency = 0.9
	blurTint.BorderSizePixel = 0
	blurTint.ZIndex = opts.ZIndex + 2
	blurTint.Parent = glassBase
	
	local blurTintCorner = Instance.new("UICorner")
	blurTintCorner.CornerRadius = opts.CornerRadius
	blurTintCorner.Parent = blurTint
	self._blurTint = blurTint
	
	-- 3. Inner Glow Frame (subtle white gradient at top for depth)
	local innerGlow = Instance.new("Frame")
	innerGlow.Name = "InnerGlow"
	innerGlow.Size = UDim2.new(1, -4, 0.5, 0)
	innerGlow.Position = UDim2.new(0.5, 0, 0, 2)
	innerGlow.AnchorPoint = Vector2.new(0.5, 0)
	innerGlow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	innerGlow.BackgroundTransparency = 0.7
	innerGlow.BorderSizePixel = 0
	innerGlow.ZIndex = opts.ZIndex + 3
	innerGlow.Parent = container
	
	local innerGlowCorner = Instance.new("UICorner")
	innerGlowCorner.CornerRadius = UDim.new(
		opts.CornerRadius.Scale,
		math.max(0, opts.CornerRadius.Offset - 2)
	)
	innerGlowCorner.Parent = innerGlow
	
	local innerGlowGradient = Instance.new("UIGradient")
	innerGlowGradient.Color = createInnerGlowGradient()
	innerGlowGradient.Transparency = createInnerGlowTransparency()
	innerGlowGradient.Rotation = 90 -- Top to bottom
	innerGlowGradient.Parent = innerGlow
	self._innerGlow = innerGlow
	self._innerGlowGradient = innerGlowGradient
	
	-- 4. Border Frame (with UIStroke + UIGradient for reflective effect)
	local borderFrame = Instance.new("Frame")
	borderFrame.Name = "Border"
	borderFrame.Size = UDim2.new(1, 0, 1, 0)
	borderFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	borderFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	borderFrame.BackgroundTransparency = 1
	borderFrame.BorderSizePixel = 0
	borderFrame.ZIndex = opts.ZIndex + 4
	borderFrame.Parent = container
	
	local borderCorner = Instance.new("UICorner")
	borderCorner.CornerRadius = opts.CornerRadius
	borderCorner.Parent = borderFrame
	
	local borderStroke = Instance.new("UIStroke")
	borderStroke.Color = opts.BorderColor
	borderStroke.Thickness = opts.BorderThickness
	borderStroke.Transparency = opts.BorderTransparency
	borderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	borderStroke.Parent = borderFrame
	
	-- Reflective gradient on border (rotates based on mouse position)
	local borderGradient = Instance.new("UIGradient")
	borderGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.3, Color3.fromRGB(200, 200, 220)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.7, Color3.fromRGB(200, 200, 220)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
	})
	borderGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.8),
		NumberSequenceKeypoint.new(0.33, 0.4),
		NumberSequenceKeypoint.new(0.66, 0.6),
		NumberSequenceKeypoint.new(1, 0.8),
	})
	borderGradient.Rotation = 135
	borderGradient.Parent = borderStroke
	self._borderFrame = borderFrame
	self._borderStroke = borderStroke
	self._borderGradient = borderGradient
	
	-- Second border layer for extra depth (screen blend simulation)
	local borderFrame2 = Instance.new("Frame")
	borderFrame2.Name = "Border2"
	borderFrame2.Size = UDim2.new(1, 0, 1, 0)
	borderFrame2.Position = UDim2.new(0.5, 0, 0.5, 0)
	borderFrame2.AnchorPoint = Vector2.new(0.5, 0.5)
	borderFrame2.BackgroundTransparency = 1
	borderFrame2.BorderSizePixel = 0
	borderFrame2.ZIndex = opts.ZIndex + 5
	borderFrame2.Parent = container
	
	local borderCorner2 = Instance.new("UICorner")
	borderCorner2.CornerRadius = opts.CornerRadius
	borderCorner2.Parent = borderFrame2
	
	local borderStroke2 = Instance.new("UIStroke")
	borderStroke2.Color = Color3.fromRGB(255, 255, 255)
	borderStroke2.Thickness = opts.BorderThickness * 0.5
	borderStroke2.Transparency = 0.7
	borderStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	borderStroke2.Parent = borderFrame2
	
	local borderGradient2 = Instance.new("UIGradient")
	borderGradient2.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 220, 240)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
	})
	borderGradient2.Rotation = 135
	borderGradient2.Parent = borderStroke2
	self._borderFrame2 = borderFrame2
	self._borderStroke2 = borderStroke2
	self._borderGradient2 = borderGradient2
	
	-- 5. Hover Highlight Frame (radial gradient on hover)
	local hoverHighlight = Instance.new("Frame")
	hoverHighlight.Name = "HoverHighlight"
	hoverHighlight.Size = UDim2.new(1, 0, 1, 0)
	hoverHighlight.Position = UDim2.new(0.5, 0, 0.5, 0)
	hoverHighlight.AnchorPoint = Vector2.new(0.5, 0.5)
	hoverHighlight.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	hoverHighlight.BackgroundTransparency = 1 -- Hidden by default
	hoverHighlight.BorderSizePixel = 0
	hoverHighlight.ZIndex = opts.ZIndex + 6
	hoverHighlight.Parent = container
	
	local hoverCorner = Instance.new("UICorner")
	hoverCorner.CornerRadius = opts.CornerRadius
	hoverCorner.Parent = hoverHighlight
	
	-- Radial-like gradient for hover (centered highlight)
	local hoverGradient = Instance.new("UIGradient")
	hoverGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
	})
	hoverGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.85),
		NumberSequenceKeypoint.new(0.5, 0.92),
		NumberSequenceKeypoint.new(1, 1),
	})
	hoverGradient.Offset = Vector2.new(0, 0)
	hoverGradient.Parent = hoverHighlight
	self._hoverHighlight = hoverHighlight
	self._hoverGradient = hoverGradient
	
	-- 6. Content Frame (where user content goes)
	local contentFrame = Instance.new("Frame")
	contentFrame.Name = "Content"
	contentFrame.Size = UDim2.new(1, 0, 1, 0)
	contentFrame.Position = UDim2.new(0, 0, 0, 0)
	contentFrame.BackgroundTransparency = 1
	contentFrame.BorderSizePixel = 0
	contentFrame.ZIndex = opts.ZIndex + 7
	contentFrame.ClipsDescendants = true
	contentFrame.Parent = container
	
	local contentCorner = Instance.new("UICorner")
	contentCorner.CornerRadius = opts.CornerRadius
	contentCorner.Parent = contentFrame
	self._contentFrame = contentFrame
	
	-- Input capture frame (for mouse events)
	local inputFrame = Instance.new("TextButton")
	inputFrame.Name = "InputCapture"
	inputFrame.Size = UDim2.new(1, 0, 1, 0)
	inputFrame.Position = UDim2.new(0, 0, 0, 0)
	inputFrame.BackgroundTransparency = 1
	inputFrame.BorderSizePixel = 0
	inputFrame.ZIndex = opts.ZIndex + 8
	inputFrame.Text = ""
	inputFrame.AutoButtonColor = false
	inputFrame.Parent = container
	
	local inputCorner = Instance.new("UICorner")
	inputCorner.CornerRadius = opts.CornerRadius
	inputCorner.Parent = inputFrame
	self._inputFrame = inputFrame
	
	-- Parent the container
	if opts.Parent then
		container.Parent = opts.Parent
	end
end

--[[
	Sets up all mouse/touch interactions
]]
function LiquidGlass:_setupInteractions()
	local opts = self._options
	local inputFrame = self._inputFrame
	
	-- Mouse Enter
	local mouseEnterConn = inputFrame.MouseEnter:Connect(function()
		if self._destroyed then return end
		self._isHovered = true
		self:_onHoverChanged(true)
		
		if opts.OnHover then
			opts.OnHover(true)
		end
	end)
	table.insert(self._connections, mouseEnterConn)
	
	-- Mouse Leave
	local mouseLeaveConn = inputFrame.MouseLeave:Connect(function()
		if self._destroyed then return end
		self._isHovered = false
		self._isPressed = false
		self._mouseOffset = Vector2.new(0, 0)
		self:_onHoverChanged(false)
		self:_resetElasticPosition()
		self:_updateBorderGradient(Vector2.new(0, 0))
		
		if opts.OnHover then
			opts.OnHover(false)
		end
	end)
	table.insert(self._connections, mouseLeaveConn)
	
	-- Mouse Button Down
	local mouseDownConn = inputFrame.MouseButton1Down:Connect(function()
		if self._destroyed then return end
		self._isPressed = true
		self:_onPressChanged(true)
	end)
	table.insert(self._connections, mouseDownConn)
	
	-- Mouse Button Up
	local mouseUpConn = inputFrame.MouseButton1Up:Connect(function()
		if self._destroyed then return end
		local wasPressed = self._isPressed
		self._isPressed = false
		self:_onPressChanged(false)
		
		-- Trigger click callback
		if wasPressed and self._isHovered and opts.OnClick then
			opts.OnClick()
		end
	end)
	table.insert(self._connections, mouseUpConn)
	
	-- Mouse Movement (for elastic effect and border gradient)
	local mouseMoveConn = inputFrame.InputChanged:Connect(function(input)
		if self._destroyed then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			self:_onMouseMove(input.Position)
		end
	end)
	table.insert(self._connections, mouseMoveConn)
	
	-- Global mouse tracking for better elastic feel
	local globalMouseConn = UserInputService.InputChanged:Connect(function(input)
		if self._destroyed then return end
		if not self._isHovered then return end
		
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			self:_onMouseMove(input.Position)
		end
	end)
	table.insert(self._connections, globalMouseConn)
end

--[[
	Handles mouse movement - updates elastic position and border gradient
]]
function LiquidGlass:_onMouseMove(mousePosition: Vector3)
	local container = self._container
	local absolutePos = container.AbsolutePosition
	local absoluteSize = container.AbsoluteSize
	
	local mousePos2D = Vector2.new(mousePosition.X, mousePosition.Y)
	local offset = calculateMouseOffset(mousePos2D, absolutePos, absoluteSize)
	self._mouseOffset = offset
	
	-- Update border gradient rotation
	self:_updateBorderGradient(offset)
	
	-- Update hover highlight position
	self:_updateHoverHighlight(offset)
	
	-- Apply elastic movement if enabled
	if self._options.Elasticity > 0 then
		self:_applyElasticMovement(offset)
	end
end

--[[
	Updates the border gradient rotation based on mouse offset
]]
function LiquidGlass:_updateBorderGradient(offset: Vector2)
	local rotation = calculateGradientRotation(offset)
	
	-- Smooth tween the gradient rotation
	local tween1 = TweenService:Create(self._borderGradient, TWEEN_INFO_SMOOTH, {
		Rotation = rotation
	})
	local tween2 = TweenService:Create(self._borderGradient2, TWEEN_INFO_SMOOTH, {
		Rotation = rotation + 45
	})
	
	self:_cancelTweens()
	tween1:Play()
	tween2:Play()
	table.insert(self._tweens, tween1)
	table.insert(self._tweens, tween2)
	
	-- Update border transparency based on mouse position intensity
	local intensity = math.sqrt(offset.X * offset.X + offset.Y * offset.Y)
	local newTransparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.8 - intensity * 0.1),
		NumberSequenceKeypoint.new(0.33, 0.4 - intensity * 0.15),
		NumberSequenceKeypoint.new(0.66, 0.6 - intensity * 0.1),
		NumberSequenceKeypoint.new(1, 0.8 - intensity * 0.1),
	})
	self._borderGradient.Transparency = newTransparency
end

--[[
	Updates the hover highlight position (simulates radial gradient following mouse)
]]
function LiquidGlass:_updateHoverHighlight(offset: Vector2)
	if not self._options.HoverHighlight then return end
	if not self._isHovered then return end
	
	-- Offset the gradient center toward mouse position
	local gradientOffset = Vector2.new(
		offset.X * 0.3,
		offset.Y * 0.3
	)
	
	self._hoverGradient.Offset = gradientOffset
end

--[[
	Applies elastic movement to the container
]]
function LiquidGlass:_applyElasticMovement(offset: Vector2)
	local opts = self._options
	local elasticity = opts.Elasticity
	
	-- Calculate elastic translation (similar to React's calculateElasticTranslation)
	local maxTranslation = 10 -- max pixels of movement
	local translateX = offset.X * elasticity * maxTranslation
	local translateY = offset.Y * elasticity * maxTranslation
	
	-- Calculate scale based on direction (subtle scale toward mouse)
	local scaleModifier = 1 + math.abs(offset.X) * elasticity * 0.02 + math.abs(offset.Y) * elasticity * 0.02
	
	-- Apply position offset from original
	local originalPos = self._originalPosition
	local newPos = UDim2.new(
		originalPos.X.Scale,
		originalPos.X.Offset + translateX,
		originalPos.Y.Scale,
		originalPos.Y.Offset + translateY
	)
	
	local tween = TweenService:Create(self._container, TWEEN_INFO_SMOOTH, {
		Position = newPos,
		Size = UDim2.new(
			opts.Size.X.Scale * scaleModifier,
			opts.Size.X.Offset * scaleModifier,
			opts.Size.Y.Scale * scaleModifier,
			opts.Size.Y.Offset * scaleModifier
		)
	})
	tween:Play()
	table.insert(self._tweens, tween)
end

--[[
	Resets the elastic position to original
]]
function LiquidGlass:_resetElasticPosition()
	local opts = self._options
	
	local tween = TweenService:Create(self._container, TWEEN_INFO_ELASTIC, {
		Position = self._originalPosition,
		Size = opts.Size
	})
	tween:Play()
	table.insert(self._tweens, tween)
end

--[[
	Handles hover state changes
]]
function LiquidGlass:_onHoverChanged(isHovered: boolean)
	if not self._options.HoverHighlight then return end
	
	local targetTransparency = isHovered and 0.9 or 1
	
	local tween = TweenService:Create(self._hoverHighlight, TWEEN_INFO_FAST, {
		BackgroundTransparency = targetTransparency
	})
	tween:Play()
	table.insert(self._tweens, tween)
	
	-- Brighten border on hover
	local borderTargetTransparency = isHovered and (self._options.BorderTransparency - 0.1) or self._options.BorderTransparency
	local borderTween = TweenService:Create(self._borderStroke, TWEEN_INFO_FAST, {
		Transparency = borderTargetTransparency
	})
	borderTween:Play()
	table.insert(self._tweens, borderTween)
end

--[[
	Handles press state changes
]]
function LiquidGlass:_onPressChanged(isPressed: boolean)
	local opts = self._options
	
	if opts.OnClick == nil then return end -- Only animate if clickable
	
	local scale = isPressed and opts.ClickScale or 1
	local targetSize = UDim2.new(
		opts.Size.X.Scale * scale,
		opts.Size.X.Offset * scale,
		opts.Size.Y.Scale * scale,
		opts.Size.Y.Offset * scale
	)
	
	local tweenInfo = isPressed and TWEEN_INFO_FAST or TWEEN_INFO_ELASTIC
	local tween = TweenService:Create(self._container, tweenInfo, {
		Size = targetSize
	})
	tween:Play()
	table.insert(self._tweens, tween)
	
	-- Darken on press
	local glassTransparency = isPressed and (opts.BackgroundTransparency - 0.05) or opts.BackgroundTransparency
	local glassTween = TweenService:Create(self._glassBase, TWEEN_INFO_FAST, {
		BackgroundTransparency = glassTransparency
	})
	glassTween:Play()
	table.insert(self._tweens, glassTween)
end

--[[
	Cancels all active tweens
]]
function LiquidGlass:_cancelTweens()
	for _, tween in ipairs(self._tweens) do
		if tween.PlaybackState == Enum.PlaybackState.Playing then
			tween:Cancel()
		end
	end
	self._tweens = {}
end

--// Public Methods

--[[
	Sets the content of the glass element
	
	@param content GuiObject - The UI element to display inside the glass
]]
function LiquidGlass:SetContent(content: GuiObject)
	if self._destroyed then
		warn("LiquidGlass:SetContent called on destroyed instance")
		return
	end
	
	-- Remove existing content
	if self._content then
		self._content.Parent = nil
	end
	
	-- Add new content
	if content then
		content.Parent = self._contentFrame
		self._content = content
	end
end

--[[
	Destroys the glass element and cleans up all connections
]]
function LiquidGlass:Destroy()
	if self._destroyed then return end
	self._destroyed = true
	
	-- Cancel all tweens
	self:_cancelTweens()
	
	-- Disconnect all connections
	for _, connection in ipairs(self._connections) do
		connection:Disconnect()
	end
	self._connections = {}
	
	-- Destroy UI
	if self._container then
		self._container:Destroy()
	end
	
	-- Clear references
	self._container = nil
	self._glassBase = nil
	self._blurTint = nil
	self._shadowFrame = nil
	self._innerGlow = nil
	self._borderFrame = nil
	self._borderStroke = nil
	self._borderGradient = nil
	self._borderFrame2 = nil
	self._borderStroke2 = nil
	self._borderGradient2 = nil
	self._hoverHighlight = nil
	self._hoverGradient = nil
	self._contentFrame = nil
	self._inputFrame = nil
	self._content = nil
end

--[[
	Sets a property on the glass element
	
	@param key string - The property name
	@param value any - The new value
]]
function LiquidGlass:SetProperty(key: string, value: any)
	if self._destroyed then
		warn("LiquidGlass:SetProperty called on destroyed instance")
		return
	end
	
	-- Update internal options
	self._options[key] = value
	
	-- Apply property changes
	if key == "Size" then
		self._container.Size = value
	elseif key == "Position" then
		self._container.Position = value
		self._originalPosition = value
	elseif key == "AnchorPoint" then
		self._container.AnchorPoint = value
	elseif key == "Parent" then
		self._container.Parent = value
	elseif key == "CornerRadius" then
		-- Update all corner instances
		for _, child in ipairs(self._container:GetDescendants()) do
			if child:IsA("UICorner") then
				child.CornerRadius = value
			end
		end
	elseif key == "BackgroundColor" then
		self._glassBase.BackgroundColor3 = value
	elseif key == "BackgroundTransparency" then
		self._glassBase.BackgroundTransparency = value
	elseif key == "BlurTint" then
		self._blurTint.BackgroundColor3 = value
	elseif key == "BorderColor" then
		self._borderStroke.Color = value
	elseif key == "BorderTransparency" then
		self._borderStroke.Transparency = value
	elseif key == "BorderThickness" then
		self._borderStroke.Thickness = value
		self._borderStroke2.Thickness = value * 0.5
	elseif key == "ShadowColor" then
		self._shadowFrame.BackgroundColor3 = value
	elseif key == "ShadowTransparency" then
		self._shadowFrame.BackgroundTransparency = value
	elseif key == "ShadowOffset" then
		self._shadowFrame.Position = UDim2.new(0.5, value.X, 0.5, value.Y)
	elseif key == "ShadowSize" then
		local opts = self._options
		self._shadowFrame.Size = UDim2.new(1, value * 2, 1, value * 2)
	elseif key == "Elasticity" or key == "HoverHighlight" or key == "ClickScale" then
		-- These are behavior settings, no UI update needed
	elseif key == "OnClick" or key == "OnHover" then
		-- Event callbacks, no UI update needed
	else
		warn("LiquidGlass:SetProperty - Unknown property: " .. tostring(key))
	end
end

--[[
	Returns the main container Frame
	
	@return Frame - The main container frame
]]
function LiquidGlass:GetFrame(): Frame
	return self._container
end

--[[
	Returns the content Frame where child elements are placed
	
	@return Frame - The content frame
]]
function LiquidGlass:GetContentFrame(): Frame
	return self._contentFrame
end

--[[
	Returns whether the glass is currently hovered
	
	@return boolean
]]
function LiquidGlass:IsHovered(): boolean
	return self._isHovered
end

--[[
	Returns whether the glass is currently pressed
	
	@return boolean
]]
function LiquidGlass:IsPressed(): boolean
	return self._isPressed
end

return LiquidGlass
