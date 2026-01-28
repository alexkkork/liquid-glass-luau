--[[
    LiquidGlass Example Script
    
    This example demonstrates how to use the LiquidGlass UI library
    to create beautiful frosted glass UI elements in Roblox.
    
    Usage: Execute this script in a Roblox executor
]]

-- Load the LiquidGlass module
local LiquidGlass = loadstring(game:HttpGet("https://raw.githubusercontent.com/alexkkork/liquid-glass-luau/main/LiquidGlass.luau"))()

--// Create ScreenGui
local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LiquidGlassDemo"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

--// Background for demo (colorful gradient to show glass effect)
local background = Instance.new("Frame")
background.Name = "Background"
background.Size = UDim2.new(1, 0, 1, 0)
background.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
background.BorderSizePixel = 0
background.Parent = screenGui

local bgGradient = Instance.new("UIGradient")
bgGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(74, 20, 140)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 60, 114)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 100, 100)),
})
bgGradient.Rotation = 45
bgGradient.Parent = background

--// ============================================
--// Example 1: Glass Button
--// ============================================
local glassButton = LiquidGlass.new({
    Size = UDim2.new(0, 200, 0, 50),
    Position = UDim2.new(0.5, 0, 0.3, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Parent = screenGui,
    
    CornerRadius = UDim.new(0, 25),
    BackgroundTransparency = 0.8,
    BlurTint = Color3.fromRGB(180, 180, 220),
    
    BorderTransparency = 0.4,
    BorderThickness = 1.5,
    
    ShadowTransparency = 0.6,
    ShadowOffset = Vector2.new(0, 10),
    ShadowSize = 15,
    
    Elasticity = 0.2,
    HoverHighlight = true,
    ClickScale = 0.95,
    
    OnClick = function()
        print("Glass Button Clicked!")
    end,
})

-- Add button text
local buttonLabel = Instance.new("TextLabel")
buttonLabel.Name = "ButtonText"
buttonLabel.Size = UDim2.new(1, 0, 1, 0)
buttonLabel.BackgroundTransparency = 1
buttonLabel.Text = "Click Me"
buttonLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
buttonLabel.TextSize = 18
buttonLabel.Font = Enum.Font.GothamBold
buttonLabel.TextXAlignment = Enum.TextXAlignment.Center
buttonLabel.TextYAlignment = Enum.TextYAlignment.Center
glassButton:SetContent(buttonLabel)

--// ============================================
--// Example 2: Glass Card
--// ============================================
local glassCard = LiquidGlass.new({
    Size = UDim2.new(0, 300, 0, 180),
    Position = UDim2.new(0.5, 0, 0.6, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Parent = screenGui,
    
    CornerRadius = UDim.new(0, 20),
    BackgroundTransparency = 0.75,
    BlurTint = Color3.fromRGB(200, 200, 240),
    
    BorderTransparency = 0.5,
    BorderThickness = 2,
    
    ShadowTransparency = 0.5,
    ShadowOffset = Vector2.new(0, 15),
    ShadowSize = 25,
    
    Elasticity = 0.1,
    HoverHighlight = true,
    ClickScale = 0.98,
    
    OnClick = function()
        print("Glass Card Clicked!")
    end,
})

-- Add card content
local cardContent = Instance.new("Frame")
cardContent.Name = "CardContent"
cardContent.Size = UDim2.new(1, -30, 1, -30)
cardContent.Position = UDim2.new(0.5, 0, 0.5, 0)
cardContent.AnchorPoint = Vector2.new(0.5, 0.5)
cardContent.BackgroundTransparency = 1

local cardTitle = Instance.new("TextLabel")
cardTitle.Name = "Title"
cardTitle.Size = UDim2.new(1, 0, 0, 30)
cardTitle.Position = UDim2.new(0, 0, 0, 0)
cardTitle.BackgroundTransparency = 1
cardTitle.Text = "Liquid Glass"
cardTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
cardTitle.TextSize = 24
cardTitle.Font = Enum.Font.GothamBold
cardTitle.TextXAlignment = Enum.TextXAlignment.Left
cardTitle.Parent = cardContent

local cardDescription = Instance.new("TextLabel")
cardDescription.Name = "Description"
cardDescription.Size = UDim2.new(1, 0, 0, 60)
cardDescription.Position = UDim2.new(0, 0, 0, 40)
cardDescription.BackgroundTransparency = 1
cardDescription.Text = "A beautiful frosted glass UI library for Roblox. Features elastic animations, reflective borders, and hover effects."
cardDescription.TextColor3 = Color3.fromRGB(220, 220, 240)
cardDescription.TextSize = 14
cardDescription.Font = Enum.Font.Gotham
cardDescription.TextXAlignment = Enum.TextXAlignment.Left
cardDescription.TextYAlignment = Enum.TextYAlignment.Top
cardDescription.TextWrapped = true
cardDescription.Parent = cardContent

local cardButton = Instance.new("TextButton")
cardButton.Name = "LearnMore"
cardButton.Size = UDim2.new(0, 100, 0, 32)
cardButton.Position = UDim2.new(0, 0, 1, -32)
cardButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
cardButton.BackgroundTransparency = 0.8
cardButton.Text = "Learn More"
cardButton.TextColor3 = Color3.fromRGB(255, 255, 255)
cardButton.TextSize = 13
cardButton.Font = Enum.Font.GothamMedium
cardButton.AutoButtonColor = false
cardButton.Parent = cardContent

local cardButtonCorner = Instance.new("UICorner")
cardButtonCorner.CornerRadius = UDim.new(0, 8)
cardButtonCorner.Parent = cardButton

cardButton.MouseButton1Click:Connect(function()
    print("Learn More clicked!")
end)

glassCard:SetContent(cardContent)

--// ============================================
--// Example 3: Pill-shaped Glass Element
--// ============================================
local glassPill = LiquidGlass.new({
    Size = UDim2.new(0, 150, 0, 40),
    Position = UDim2.new(0.5, 0, 0.15, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Parent = screenGui,
    
    CornerRadius = UDim.new(0, 999), -- Pill shape
    BackgroundTransparency = 0.85,
    BlurTint = Color3.fromRGB(255, 200, 200),
    
    BorderTransparency = 0.6,
    BorderThickness = 1,
    
    ShadowTransparency = 0.7,
    ShadowOffset = Vector2.new(0, 6),
    ShadowSize = 10,
    
    Elasticity = 0.25,
    HoverHighlight = true,
    ClickScale = 0.94,
    
    OnClick = function()
        print("Pill Button Clicked!")
    end,
})

-- Add pill content
local pillLabel = Instance.new("TextLabel")
pillLabel.Name = "PillText"
pillLabel.Size = UDim2.new(1, 0, 1, 0)
pillLabel.BackgroundTransparency = 1
pillLabel.Text = "✨ New Feature"
pillLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
pillLabel.TextSize = 14
pillLabel.Font = Enum.Font.GothamMedium
glassPill:SetContent(pillLabel)

--// ============================================
--// Example 4: Glass Status Indicator
--// ============================================
local glassStatus = LiquidGlass.new({
    Size = UDim2.new(0, 120, 0, 36),
    Position = UDim2.new(0, 20, 0, 20),
    AnchorPoint = Vector2.new(0, 0),
    Parent = screenGui,
    
    CornerRadius = UDim.new(0, 10),
    BackgroundTransparency = 0.7,
    BlurTint = Color3.fromRGB(100, 255, 150),
    
    BorderTransparency = 0.6,
    BorderThickness = 1,
    
    ShadowTransparency = 0.8,
    ShadowOffset = Vector2.new(0, 4),
    ShadowSize = 8,
    
    Elasticity = 0.05,
    HoverHighlight = false,
})

-- Add status content
local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(1, -20, 1, 0)
statusFrame.Position = UDim2.new(0, 10, 0, 0)
statusFrame.BackgroundTransparency = 1

local statusDot = Instance.new("Frame")
statusDot.Name = "StatusDot"
statusDot.Size = UDim2.new(0, 10, 0, 10)
statusDot.Position = UDim2.new(0, 0, 0.5, 0)
statusDot.AnchorPoint = Vector2.new(0, 0.5)
statusDot.BackgroundColor3 = Color3.fromRGB(80, 255, 120)
statusDot.Parent = statusFrame

local statusDotCorner = Instance.new("UICorner")
statusDotCorner.CornerRadius = UDim.new(1, 0)
statusDotCorner.Parent = statusDot

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusText"
statusLabel.Size = UDim2.new(1, -20, 1, 0)
statusLabel.Position = UDim2.new(0, 18, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Online"
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = statusFrame

glassStatus:SetContent(statusFrame)

--// ============================================
--// Cleanup on script end
--// ============================================
local function cleanup()
    glassButton:Destroy()
    glassCard:Destroy()
    glassPill:Destroy()
    glassStatus:Destroy()
    screenGui:Destroy()
    print("LiquidGlass Demo cleaned up!")
end

-- Uncomment to add cleanup keybind (press Delete key)
--[[
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Delete then
        cleanup()
    end
end)
]]

print("LiquidGlass Demo loaded! Move your mouse over the glass elements.")
