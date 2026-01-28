--[[
    LiquidGlass Pro - Example Script
    
    This example demonstrates the full capabilities of the LiquidGlass Pro library
    including chromatic aberration, edge refraction, and elastic animations.
    
    Usage: Execute this script in a Roblox executor
]]

-- Load the LiquidGlass Pro module
local LiquidGlass = loadstring(game:HttpGet("https://raw.githubusercontent.com/alexkkork/liquid-glass-luau/main/LiquidGlassPro.luau"))()

--// Create ScreenGui
local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LiquidGlassProDemo"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

--// Background with gradient (to show off the glass effect)
local background = Instance.new("Frame")
background.Name = "Background"
background.Size = UDim2.new(1, 0, 1, 0)
background.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
background.BorderSizePixel = 0
background.Parent = screenGui

local bgGradient = Instance.new("UIGradient")
bgGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(74, 20, 140)),
    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(30, 60, 114)),
    ColorSequenceKeypoint.new(0.66, Color3.fromRGB(20, 100, 100)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 30, 90)),
})
bgGradient.Rotation = 45
bgGradient.Parent = background

-- Animated background gradient rotation
task.spawn(function()
    local rotation = 45
    while background.Parent do
        rotation = rotation + 0.1
        bgGradient.Rotation = rotation
        task.wait(0.016)
    end
end)

--// ============================================
--// Example 1: Glass Button with Full Effects
--// ============================================
print("[LiquidGlass Pro] Creating glass button...")

local glassButton = LiquidGlass.new({
    Size = UDim2.new(0, 220, 0, 56),
    Position = UDim2.new(0.5, 0, 0.25, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Parent = screenGui,
    
    -- Corner radius (use 999 for full pill shape)
    CornerRadius = 28,
    
    -- Glass appearance
    Frost = {
        Enabled = true,
        BaseColor = Color3.fromRGB(255, 255, 255),
        BaseTransparency = 0.85,
        TintColor = Color3.fromRGB(200, 210, 255),
        NoiseEnabled = true,
        NoiseIntensity = 0.03,
    },
    
    -- Chromatic aberration (RGB edge separation)
    Chromatic = {
        Enabled = true,
        Intensity = 0.8,
        EdgeOnly = true,
        RedOffset = Vector2.new(-2, -1),
        BlueOffset = Vector2.new(2, 1),
    },
    
    -- Edge refraction simulation
    Refraction = {
        Enabled = true,
        EdgeWidth = 8,
        Intensity = 0.6,
    },
    
    -- Dynamic border that follows mouse
    Border = {
        Enabled = true,
        Thickness = 1.5,
        BaseColor = Color3.fromRGB(255, 255, 255),
        GradientEnabled = true,
        MouseResponsive = true,
    },
    
    -- Depth effects
    Depth = {
        TopGlow = true,
        BottomShadow = true,
        InnerGlowColor = Color3.fromRGB(255, 255, 255),
    },
    
    -- Shadow
    Shadow = {
        Enabled = true,
        Color = Color3.fromRGB(0, 0, 0),
        Transparency = 0.6,
        Offset = Vector2.new(0, 12),
        Size = 20,
    },
    
    -- Interaction
    Interaction = {
        Elasticity = 0.25,
        ClickScale = 0.95,
        HoverGlow = true,
    },
    
    onClick = function()
        print("Glass Button Clicked!")
    end,
})

-- Add button content
local buttonContent = Instance.new("Frame")
buttonContent.Size = UDim2.new(1, 0, 1, 0)
buttonContent.BackgroundTransparency = 1

local buttonText = Instance.new("TextLabel")
buttonText.Size = UDim2.new(1, 0, 1, 0)
buttonText.BackgroundTransparency = 1
buttonText.Text = "Click Me"
buttonText.TextColor3 = Color3.fromRGB(255, 255, 255)
buttonText.TextSize = 20
buttonText.Font = Enum.Font.GothamBold
buttonText.Parent = buttonContent

glassButton:SetContent(buttonContent)

--// ============================================
--// Example 2: Glass Card with Strong Effects
--// ============================================
print("[LiquidGlass Pro] Creating glass card...")

local glassCard = LiquidGlass.new({
    Size = UDim2.new(0, 320, 0, 200),
    Position = UDim2.new(0.5, 0, 0.58, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Parent = screenGui,
    
    CornerRadius = 24,
    
    Frost = {
        Enabled = true,
        BaseColor = Color3.fromRGB(255, 255, 255),
        BaseTransparency = 0.8,
        TintColor = Color3.fromRGB(220, 230, 255),
        NoiseEnabled = true,
        NoiseIntensity = 0.02,
    },
    
    Chromatic = {
        Enabled = true,
        Intensity = 1.0,
        EdgeOnly = true,
        RedOffset = Vector2.new(-3, -1.5),
        BlueOffset = Vector2.new(3, 1.5),
    },
    
    Refraction = {
        Enabled = true,
        EdgeWidth = 12,
        Intensity = 0.7,
    },
    
    Border = {
        Enabled = true,
        Thickness = 2,
        BaseColor = Color3.fromRGB(255, 255, 255),
        GradientEnabled = true,
        MouseResponsive = true,
    },
    
    Depth = {
        TopGlow = true,
        BottomShadow = true,
    },
    
    Shadow = {
        Enabled = true,
        Transparency = 0.5,
        Offset = Vector2.new(0, 16),
        Size = 30,
    },
    
    Interaction = {
        Elasticity = 0.15,
        ClickScale = 0.98,
        HoverGlow = true,
    },
    
    onClick = function()
        print("Glass Card Clicked!")
    end,
})

-- Add card content
local cardContent = Instance.new("Frame")
cardContent.Size = UDim2.new(1, -40, 1, -40)
cardContent.Position = UDim2.new(0.5, 0, 0.5, 0)
cardContent.AnchorPoint = Vector2.new(0.5, 0.5)
cardContent.BackgroundTransparency = 1

local cardTitle = Instance.new("TextLabel")
cardTitle.Name = "Title"
cardTitle.Size = UDim2.new(1, 0, 0, 32)
cardTitle.BackgroundTransparency = 1
cardTitle.Text = "Liquid Glass Pro"
cardTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
cardTitle.TextSize = 26
cardTitle.Font = Enum.Font.GothamBold
cardTitle.TextXAlignment = Enum.TextXAlignment.Left
cardTitle.Parent = cardContent

local cardSubtitle = Instance.new("TextLabel")
cardSubtitle.Name = "Subtitle"
cardSubtitle.Size = UDim2.new(1, 0, 0, 20)
cardSubtitle.Position = UDim2.new(0, 0, 0, 36)
cardSubtitle.BackgroundTransparency = 1
cardSubtitle.Text = "Advanced UI Effects for Roblox"
cardSubtitle.TextColor3 = Color3.fromRGB(200, 210, 255)
cardSubtitle.TextSize = 14
cardSubtitle.Font = Enum.Font.Gotham
cardSubtitle.TextXAlignment = Enum.TextXAlignment.Left
cardSubtitle.Parent = cardContent

local cardDesc = Instance.new("TextLabel")
cardDesc.Name = "Description"
cardDesc.Size = UDim2.new(1, 0, 0, 50)
cardDesc.Position = UDim2.new(0, 0, 0, 70)
cardDesc.BackgroundTransparency = 1
cardDesc.Text = "Features chromatic aberration, edge refraction, elastic animations, and dynamic borders."
cardDesc.TextColor3 = Color3.fromRGB(220, 220, 240)
cardDesc.TextSize = 13
cardDesc.Font = Enum.Font.Gotham
cardDesc.TextXAlignment = Enum.TextXAlignment.Left
cardDesc.TextYAlignment = Enum.TextYAlignment.Top
cardDesc.TextWrapped = true
cardDesc.Parent = cardContent

glassCard:SetContent(cardContent)

--// ============================================
--// Example 3: Pill Badge using Factory Method
--// ============================================
print("[LiquidGlass Pro] Creating pill badge...")

local pillBadge = LiquidGlass.CreatePill("Premium", {
    Position = UDim2.new(0.5, 0, 0.1, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Parent = screenGui,
    
    Frost = {
        TintColor = Color3.fromRGB(255, 200, 100),
    },
    
    Interaction = {
        Elasticity = 0.3,
    },
})

--// ============================================
--// Example 4: Status Badge using Factory Method
--// ============================================
print("[LiquidGlass Pro] Creating status badge...")

local statusBadge = LiquidGlass.CreateStatusBadge("Online", Color3.fromRGB(100, 255, 150), {
    Position = UDim2.new(0, 20, 0, 20),
    AnchorPoint = Vector2.new(0, 0),
    Parent = screenGui,
})

--// ============================================
--// Example 5: Minimal Glass (less effects)
--// ============================================
print("[LiquidGlass Pro] Creating minimal glass...")

local minimalGlass = LiquidGlass.new({
    Size = UDim2.new(0, 150, 0, 44),
    Position = UDim2.new(1, -20, 0, 20),
    AnchorPoint = Vector2.new(1, 0),
    Parent = screenGui,
    
    CornerRadius = 12,
    
    -- Disable heavy effects for performance
    Frost = {
        Enabled = true,
        BaseTransparency = 0.7,
        NoiseEnabled = false,
    },
    
    Chromatic = {
        Enabled = false, -- Disabled
    },
    
    Refraction = {
        Enabled = false, -- Disabled
    },
    
    Border = {
        Enabled = true,
        Thickness = 1,
        GradientEnabled = true,
        MouseResponsive = false, -- Static border
    },
    
    Shadow = {
        Enabled = true,
        Size = 10,
        Transparency = 0.7,
    },
    
    Interaction = {
        Elasticity = 0,
        HoverGlow = false,
    },
})

local minimalContent = Instance.new("TextLabel")
minimalContent.Size = UDim2.new(1, 0, 1, 0)
minimalContent.BackgroundTransparency = 1
minimalContent.Text = "Settings"
minimalContent.TextColor3 = Color3.fromRGB(255, 255, 255)
minimalContent.TextSize = 15
minimalContent.Font = Enum.Font.GothamMedium
minimalGlass:SetContent(minimalContent)

--// ============================================
--// Cleanup Function
--// ============================================
local function cleanup()
    glassButton:Destroy()
    glassCard:Destroy()
    pillBadge:Destroy()
    statusBadge:Destroy()
    minimalGlass:Destroy()
    screenGui:Destroy()
    print("[LiquidGlass Pro] Demo cleaned up!")
end

-- Uncomment to enable cleanup keybind
--[[
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Delete then
        cleanup()
    end
end)
]]

print("[LiquidGlass Pro] Demo loaded!")
print("  - Move your mouse over elements to see effects")
print("  - Watch the chromatic aberration at edges")
print("  - Notice the dynamic border gradient following cursor")
print("  - Try clicking the button!")
