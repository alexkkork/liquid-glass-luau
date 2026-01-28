# Liquid Glass Luau

A comprehensive frosted glass UI library for Roblox Luau. Inspired by Apple's Liquid Glass design.

![Liquid Glass Demo](https://raw.githubusercontent.com/rdev/liquid-glass-react/master/assets/project-liquid.gif)

## Two Versions Available

### LiquidGlass (Basic) - 925 lines
Simple and lightweight version with essential glass effects.

### LiquidGlass Pro - 6,193 lines
Full-featured version with all visual effects:
- **Chromatic Aberration** - RGB edge separation like real glass
- **Edge Refraction** - Light bending at edges
- **Dynamic Borders** - Gradient that follows mouse cursor
- **Spring Physics** - Smooth elastic animations
- **Frost Simulation** - Multi-layer glass depth
- **And much more...**

## Features

- **Frosted Glass Effect** - Semi-transparent blur simulation
- **Chromatic Aberration** - RGB channel separation at edges (Pro)
- **Edge Refraction** - Light bending simulation (Pro)
- **Reflective Borders** - Dynamic gradient that follows mouse position
- **Elastic Animations** - Spring physics for liquid feel
- **Hover Effects** - Radial highlights on hover
- **Click Animations** - Scale-down effect on press
- **Multiple Layers** - Shadow, glass, glow, borders for depth
- **Full Type Support** - Luau type annotations included

## Installation

### For Roblox Executors

**Basic Version:**
```lua
local LiquidGlass = loadstring(game:HttpGet("https://raw.githubusercontent.com/alexkkork/liquid-glass-luau/main/LiquidGlass.luau"))()
```

**Pro Version (Full Effects):**
```lua
local LiquidGlass = loadstring(game:HttpGet("https://raw.githubusercontent.com/alexkkork/liquid-glass-luau/main/LiquidGlassPro.luau"))()
```

### Manual Installation

Copy `LiquidGlass.luau` to your project and require it:

```lua
local LiquidGlass = require(path.to.LiquidGlass)
```

## Quick Start

```lua
local LiquidGlass = loadstring(game:HttpGet("https://raw.githubusercontent.com/alexkkork/liquid-glass-luau/main/LiquidGlass.luau"))()

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Create a glass button
local glass = LiquidGlass.new({
    Size = UDim2.new(0, 200, 0, 50),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Parent = screenGui,
    
    CornerRadius = UDim.new(0, 25),
    BackgroundTransparency = 0.8,
    Elasticity = 0.2,
    
    OnClick = function()
        print("Clicked!")
    end,
})

-- Add content
local label = Instance.new("TextLabel")
label.Text = "Click Me"
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.new(1, 1, 1)
label.Font = Enum.Font.GothamBold
label.TextSize = 18
glass:SetContent(label)
```

## API Reference

### `LiquidGlass.new(options)`

Creates a new glass element.

#### Options

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `Size` | `UDim2` | `UDim2.new(0, 200, 0, 60)` | Element size |
| `Position` | `UDim2` | `UDim2.new(0.5, 0, 0.5, 0)` | Element position |
| `AnchorPoint` | `Vector2` | `Vector2.new(0.5, 0.5)` | Anchor point |
| `Parent` | `GuiObject?` | `nil` | Parent GUI |
| `ZIndex` | `number` | `1` | Z-index layer |
| `CornerRadius` | `UDim` | `UDim.new(0, 20)` | Corner radius (use 999 for pill) |
| `BackgroundColor` | `Color3` | `Color3.fromRGB(255, 255, 255)` | Glass color |
| `BackgroundTransparency` | `number` | `0.85` | Glass transparency (0-1) |
| `BlurTint` | `Color3` | `Color3.fromRGB(200, 200, 220)` | Blur tint color |
| `BorderColor` | `Color3` | `Color3.fromRGB(255, 255, 255)` | Border color |
| `BorderTransparency` | `number` | `0.5` | Border transparency |
| `BorderThickness` | `number` | `1.5` | Border thickness |
| `ShadowColor` | `Color3` | `Color3.fromRGB(0, 0, 0)` | Shadow color |
| `ShadowTransparency` | `number` | `0.7` | Shadow transparency |
| `ShadowOffset` | `Vector2` | `Vector2.new(0, 8)` | Shadow offset |
| `ShadowSize` | `number` | `20` | Shadow spread |
| `Elasticity` | `number` | `0.15` | Mouse-follow intensity (0 = none) |
| `HoverHighlight` | `boolean` | `true` | Show hover effect |
| `ClickScale` | `number` | `0.96` | Scale on click |
| `OnClick` | `() -> ()` | `nil` | Click callback |
| `OnHover` | `(boolean) -> ()` | `nil` | Hover callback |

### Methods

| Method | Description |
|--------|-------------|
| `glass:SetContent(guiObject)` | Add a child element |
| `glass:SetProperty(key, value)` | Update a property |
| `glass:GetFrame()` | Get the main Frame |
| `glass:GetContentFrame()` | Get the content container |
| `glass:IsHovered()` | Check if hovered |
| `glass:IsPressed()` | Check if pressed |
| `glass:Destroy()` | Clean up and destroy |

## Examples

### Glass Card

```lua
local card = LiquidGlass.new({
    Size = UDim2.new(0, 300, 0, 180),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Parent = screenGui,
    
    CornerRadius = UDim.new(0, 20),
    BackgroundTransparency = 0.75,
    ShadowSize = 25,
    Elasticity = 0.1,
})
```

### Pill Button

```lua
local pill = LiquidGlass.new({
    Size = UDim2.new(0, 150, 0, 40),
    Parent = screenGui,
    
    CornerRadius = UDim.new(0, 999), -- Pill shape
    BackgroundTransparency = 0.85,
    Elasticity = 0.25,
    ClickScale = 0.94,
    
    OnClick = function()
        print("Pill clicked!")
    end,
})
```

### Status Indicator

```lua
local status = LiquidGlass.new({
    Size = UDim2.new(0, 120, 0, 36),
    Parent = screenGui,
    
    CornerRadius = UDim.new(0, 10),
    BackgroundTransparency = 0.7,
    BlurTint = Color3.fromRGB(100, 255, 150),
    Elasticity = 0.05,
    HoverHighlight = false,
})
```

## Pro Version Examples

### Full Effects Button
```lua
local LiquidGlass = loadstring(game:HttpGet("https://raw.githubusercontent.com/alexkkork/liquid-glass-luau/main/LiquidGlassPro.luau"))()

local glass = LiquidGlass.new({
    Size = UDim2.new(0, 220, 0, 56),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Parent = screenGui,
    CornerRadius = 28,
    
    Chromatic = {
        Enabled = true,
        Intensity = 0.8,
    },
    
    Refraction = {
        Enabled = true,
        EdgeWidth = 8,
    },
    
    Border = {
        GradientEnabled = true,
        MouseResponsive = true,
    },
    
    Interaction = {
        Elasticity = 0.25,
    },
    
    onClick = function() print("Clicked!") end,
})
```

### Factory Methods (Pro)
```lua
-- Quick button creation
local button = LiquidGlass.CreateButton("Submit", function() end)

-- Card preset
local card = LiquidGlass.CreateCard({ Size = UDim2.fromOffset(300, 200) })

-- Pill badge
local pill = LiquidGlass.CreatePill("Premium")

-- Status indicator
local badge = LiquidGlass.CreateStatusBadge("Online", Color3.fromRGB(100, 255, 150))
```

## Run Examples

```lua
-- Basic Example
loadstring(game:HttpGet("https://raw.githubusercontent.com/alexkkork/liquid-glass-luau/main/LiquidGlassExample.luau"))()

-- Pro Example (Full Effects)
loadstring(game:HttpGet("https://raw.githubusercontent.com/alexkkork/liquid-glass-luau/main/LiquidGlassProExample.luau"))()
```

## Credits

Inspired by [liquid-glass-react](https://github.com/rdev/liquid-glass-react) by rdev.

## License

MIT License
