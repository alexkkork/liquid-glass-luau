--[[
    ╔═══════════════════════════════════════════════════════════════════════════════╗
    ║                                                                               ║
    ║   ██╗     ██╗ ██████╗ ██╗   ██╗██╗██████╗      ██████╗ ██╗      █████╗ ███████╗║
    ║   ██║     ██║██╔═══██╗██║   ██║██║██╔══██╗    ██╔════╝ ██║     ██╔══██╗██╔════╝║
    ║   ██║     ██║██║   ██║██║   ██║██║██║  ██║    ██║  ███╗██║     ███████║███████╗║
    ║   ██║     ██║██║▄▄ ██║██║   ██║██║██║  ██║    ██║   ██║██║     ██╔══██║╚════██║║
    ║   ███████╗██║╚██████╔╝╚██████╔╝██║██████╔╝    ╚██████╔╝███████╗██║  ██║███████║║
    ║   ╚══════╝╚═╝ ╚══▀▀═╝  ╚═════╝ ╚═╝╚═════╝      ╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════║
    ║                                                                               ║
    ║   LiquidGlass Pro - Advanced Liquid Glass UI for Roblox                       ║
    ║   Version 2.0.0                                                               ║
    ║                                                                               ║
    ║   A comprehensive implementation of Apple's Liquid Glass design language.     ║
    ║   This library recreates the sophisticated visual effects seen in modern      ║
    ║   glass UI components including:                                              ║
    ║                                                                               ║
    ║   ┌─────────────────────────────────────────────────────────────────────────┐ ║
    ║   │ VISUAL EFFECTS IMPLEMENTED:                                             │ ║
    ║   │                                                                         │ ║
    ║   │ 1. EDGE REFRACTION SIMULATION                                           │ ║
    ║   │    • Multiple overlapping frames at edges with offset positions         │ ║
    ║   │    • Creates the appearance of light bending through thick glass        │ ║
    ║   │    • Simulates SVG feDisplacementMap effect without shaders             │ ║
    ║   │                                                                         │ ║
    ║   │ 2. CHROMATIC ABERRATION (RGB Edge Separation)                           │ ║
    ║   │    • Three overlapping edge frames tinted Red, Green, Blue              │ ║
    ║   │    • Each channel slightly offset to create rainbow edge effect         │ ║
    ║   │    • More pronounced at edges, invisible in center                      │ ║
    ║   │                                                                         │ ║
    ║   │ 3. FROSTED GLASS BLUR SIMULATION                                        │ ║
    ║   │    • Multiple stacked semi-transparent layers                           │ ║
    ║   │    • Noise texture overlay for grain effect                             │ ║
    ║   │    • Gradient overlays for depth perception                             │ ║
    ║   │                                                                         │ ║
    ║   │ 4. DYNAMIC REFLECTIVE BORDER                                            │ ║
    ║   │    • UIGradient rotation follows mouse position                         │ ║
    ║   │    • Simulates light reflection moving across glass surface             │ ║
    ║   │    • Rotation: 135 + mouseOffset.x * 1.2 degrees                        │ ║
    ║   │                                                                         │ ║
    ║   │ 5. INNER GLOW & DEPTH                                                   │ ║
    ║   │    • Top edge brighter (light from above)                               │ ║
    ║   │    • Bottom edge subtle shadow                                          │ ║
    ║   │    • Creates convincing 3D glass depth                                  │ ║
    ║   │                                                                         │ ║
    ║   │ 6. ELASTIC SPRING ANIMATIONS                                            │ ║
    ║   │    • Physics-based spring simulation for mouse following                │ ║
    ║   │    • Smooth easing with configurable tension/friction                   │ ║
    ║   │    • Natural, organic motion feel                                       │ ║
    ║   └─────────────────────────────────────────────────────────────────────────┘ ║
    ║                                                                               ║
    ║   ARCHITECTURE:                                                               ║
    ║   • Chunk 1 (Lines 1-1000): Core utilities, types, constants, math           ║
    ║   • Chunk 2 (Lines 1001-2000): Layer builders, effect generators             ║
    ║   • Chunk 3 (Lines 2001-3000): Component classes, interaction handlers       ║
    ║   • Chunk 4 (Lines 3001-4000+): Public API, presets, documentation           ║
    ║                                                                               ║
    ╚═══════════════════════════════════════════════════════════════════════════════╝
]]

--// ═══════════════════════════════════════════════════════════════════════════════
--// SECTION 1: SERVICES
--// ═══════════════════════════════════════════════════════════════════════════════

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Safe service acquisition for executor environments
local function getService(serviceName: string): any
	local success, service = pcall(function()
		return game:GetService(serviceName)
	end)
	return success and service or nil
end

local CoreGui = getService("CoreGui")
local LocalPlayer = Players.LocalPlayer

--// ═══════════════════════════════════════════════════════════════════════════════
--// SECTION 2: TYPE DEFINITIONS
--// ═══════════════════════════════════════════════════════════════════════════════

--[[
    Comprehensive type definitions for all configuration options.
    These types ensure type safety and provide excellent autocomplete support.
]]

-- Basic vector type for 2D operations
export type Vector2Like = {
	X: number,
	Y: number,
}

-- Color representation options
export type ColorInput = Color3 | string | { R: number, G: number, B: number }

-- Gradient color stop definition
export type GradientStop = {
	Position: number, -- 0 to 1
	Color: Color3,
	Transparency: number?, -- Optional, defaults to 0
}

-- Spring physics configuration
export type SpringConfig = {
	Tension: number, -- Spring stiffness (default: 170)
	Friction: number, -- Damping factor (default: 26)
	Mass: number?, -- Optional mass (default: 1)
	Precision: number?, -- Threshold for settling (default: 0.01)
	Velocity: number?, -- Initial velocity (default: 0)
	Clamp: boolean?, -- Whether to clamp overshoot (default: false)
}

-- Animation easing configuration
export type EasingConfig = {
	Style: Enum.EasingStyle?,
	Direction: Enum.EasingDirection?,
	Duration: number?,
}

-- Tween configuration shorthand
export type TweenConfig = {
	Duration: number,
	Style: Enum.EasingStyle?,
	Direction: Enum.EasingDirection?,
	RepeatCount: number?,
	Reverses: boolean?,
	DelayTime: number?,
}

-- Chromatic aberration configuration
export type ChromaticConfig = {
	Enabled: boolean, -- Whether chromatic aberration is active
	Intensity: number, -- How separated the RGB channels are (0-10)
	EdgeOnly: boolean, -- Only show at edges or across entire surface
	RedOffset: Vector2, -- Offset for red channel
	GreenOffset: Vector2, -- Offset for green channel (usually 0,0)
	BlueOffset: Vector2, -- Offset for blue channel
	Opacity: number, -- Overall opacity of the effect (0-1)
}

-- Refraction/distortion configuration
export type RefractionConfig = {
	Enabled: boolean, -- Whether edge refraction is active
	Intensity: number, -- How much distortion at edges (0-20)
	EdgeWidth: number, -- Width of the refraction zone in pixels
	Layers: number, -- Number of overlapping refraction layers (2-8)
	FalloffExponent: number, -- How quickly refraction fades from edge (1-4)
}

-- Frosted glass blur simulation configuration
export type FrostConfig = {
	Enabled: boolean, -- Whether frosted effect is active
	Intensity: number, -- How "frosted" the glass appears (0-1)
	NoiseScale: number, -- Scale of noise texture (0.1-10)
	NoiseOpacity: number, -- Visibility of noise grain (0-0.5)
	Layers: number, -- Number of blur simulation layers (2-6)
	Tint: Color3, -- Color tint for frosted layer
	TintOpacity: number, -- How visible the tint is (0-1)
}

-- Dynamic border gradient configuration
export type BorderGradientConfig = {
	Enabled: boolean, -- Whether dynamic border is active
	BaseRotation: number, -- Starting rotation in degrees (default: 135)
	MouseInfluence: number, -- How much mouse affects rotation (default: 1.2)
	Colors: { GradientStop }, -- Gradient color stops
	Thickness: number, -- Border thickness in pixels
	AnimationSpeed: number, -- How fast gradient responds (0.1-2)
}

-- Inner glow and depth configuration
export type DepthConfig = {
	Enabled: boolean, -- Whether depth effects are active
	TopGlowColor: Color3, -- Color of top edge glow
	TopGlowOpacity: number, -- Visibility of top glow (0-0.5)
	TopGlowSize: number, -- Height of top glow zone in pixels
	BottomShadowColor: Color3, -- Color of bottom shadow
	BottomShadowOpacity: number, -- Visibility of bottom shadow (0-0.3)
	BottomShadowSize: number, -- Height of bottom shadow zone
	InnerGlowColor: Color3, -- Overall inner glow color
	InnerGlowOpacity: number, -- Inner glow visibility
	InnerGlowSize: number, -- Inner glow spread
}

-- Mouse interaction configuration
export type InteractionConfig = {
	Enabled: boolean, -- Whether mouse interactions are active
	HoverScale: number, -- Scale multiplier on hover (default: 1.02)
	PressScale: number, -- Scale multiplier on press (default: 0.98)
	ElasticFollow: boolean, -- Whether content follows mouse with spring physics
	FollowIntensity: number, -- How much content moves with mouse (0-20)
	FollowSpring: SpringConfig?, -- Spring config for elastic follow
	GlowOnHover: boolean, -- Whether to intensify glow on hover
	HoverGlowIntensity: number, -- How much brighter glow gets (1-2)
}

-- Background layer configuration
export type BackgroundConfig = {
	Color: Color3, -- Primary background color
	Transparency: number, -- Background transparency (0-1)
	GradientEnabled: boolean, -- Whether to use gradient background
	GradientColors: { GradientStop }?, -- Gradient stops if enabled
	GradientRotation: number?, -- Gradient rotation in degrees
}

-- Shadow configuration for outer shadow
export type ShadowConfig = {
	Enabled: boolean, -- Whether outer shadow is active
	Color: Color3, -- Shadow color
	Transparency: number, -- Shadow transparency (0-1)
	Offset: Vector2, -- Shadow offset from element
	Spread: number, -- How much shadow spreads
	Blur: number, -- Shadow blur amount (simulated)
}

-- Complete liquid glass component configuration
export type LiquidGlassConfig = {
	-- Sizing and positioning
	Size: UDim2,
	Position: UDim2?,
	AnchorPoint: Vector2?,
	CornerRadius: UDim?,
	ZIndex: number?,
	
	-- Core visual settings
	Background: BackgroundConfig?,
	Shadow: ShadowConfig?,
	
	-- Liquid glass effects
	Chromatic: ChromaticConfig?,
	Refraction: RefractionConfig?,
	Frost: FrostConfig?,
	BorderGradient: BorderGradientConfig?,
	Depth: DepthConfig?,
	
	-- Interaction settings
	Interaction: InteractionConfig?,
	
	-- Animation settings
	DefaultSpring: SpringConfig?,
	DefaultTween: TweenConfig?,
	
	-- Content
	Content: { Instance }?, -- Child elements to add
	
	-- Callbacks
	OnHoverStart: (() -> ())?,
	OnHoverEnd: (() -> ())?,
	OnPress: (() -> ())?,
	OnRelease: (() -> ())?,
	OnMouseMove: ((position: Vector2) -> ())?,
}

-- Internal state tracking type
export type ComponentState = {
	IsHovered: boolean,
	IsPressed: boolean,
	MousePosition: Vector2,
	MouseOffset: Vector2, -- Normalized offset from center (-1 to 1)
	SpringState: {
		Position: Vector2,
		Velocity: Vector2,
	},
	GradientRotation: number,
	Connections: { RBXScriptConnection },
	TweensActive: { Tween },
}

-- Layer reference type for internal tracking
export type LayerRefs = {
	Root: Frame,
	Background: Frame?,
	FrostLayers: { Frame }?,
	RefractionLayers: { Frame }?,
	ChromaticLayers: {
		Red: Frame?,
		Green: Frame?,
		Blue: Frame?,
	}?,
	BorderFrame: Frame?,
	BorderGradient: UIGradient?,
	BorderStroke: UIStroke?,
	DepthTop: Frame?,
	DepthBottom: Frame?,
	InnerGlow: Frame?,
	ContentContainer: Frame?,
	Shadow: ImageLabel?,
}

--// ═══════════════════════════════════════════════════════════════════════════════
--// SECTION 3: CONSTANTS & DEFAULT CONFIGURATIONS
--// ═══════════════════════════════════════════════════════════════════════════════

--[[
    All default values, color palettes, and configuration templates.
    These provide sensible defaults while allowing full customization.
]]

local Constants = {}

-- Version information
Constants.VERSION = "2.0.0"
Constants.BUILD_DATE = "2025-01-28"

-- Mathematical constants
Constants.Math = {
	PI = math.pi,
	TAU = math.pi * 2,
	HALF_PI = math.pi / 2,
	DEG_TO_RAD = math.pi / 180,
	RAD_TO_DEG = 180 / math.pi,
	EPSILON = 1e-6,
	GOLDEN_RATIO = 1.618033988749895,
}

-- Timing constants (in seconds)
Constants.Timing = {
	FRAME_TIME = 1 / 60, -- Target frame time
	SPRING_STEP = 1 / 120, -- Physics substep time
	DEBOUNCE_DEFAULT = 0.1,
	ANIMATION_FAST = 0.15,
	ANIMATION_NORMAL = 0.25,
	ANIMATION_SLOW = 0.4,
	ANIMATION_VERY_SLOW = 0.6,
}

-- Default spring configurations
Constants.Springs = {
	-- Snappy, responsive spring (for UI feedback)
	Snappy = {
		Tension = 300,
		Friction = 30,
		Mass = 1,
		Precision = 0.01,
	} :: SpringConfig,
	
	-- Default spring (balanced)
	Default = {
		Tension = 170,
		Friction = 26,
		Mass = 1,
		Precision = 0.01,
	} :: SpringConfig,
	
	-- Smooth, gentle spring (for following animations)
	Smooth = {
		Tension = 120,
		Friction = 20,
		Mass = 1,
		Precision = 0.01,
	} :: SpringConfig,
	
	-- Bouncy spring (for playful effects)
	Bouncy = {
		Tension = 200,
		Friction = 12,
		Mass = 1,
		Precision = 0.01,
	} :: SpringConfig,
	
	-- Stiff spring (for precise control)
	Stiff = {
		Tension = 400,
		Friction = 40,
		Mass = 1,
		Precision = 0.01,
	} :: SpringConfig,
	
	-- Elastic spring (for mouse following)
	Elastic = {
		Tension = 150,
		Friction = 18,
		Mass = 1,
		Precision = 0.005,
	} :: SpringConfig,
}

-- Default tween configurations
Constants.Tweens = {
	Fast = {
		Duration = 0.15,
		Style = Enum.EasingStyle.Quart,
		Direction = Enum.EasingDirection.Out,
	} :: TweenConfig,
	
	Normal = {
		Duration = 0.25,
		Style = Enum.EasingStyle.Quart,
		Direction = Enum.EasingDirection.Out,
	} :: TweenConfig,
	
	Slow = {
		Duration = 0.4,
		Style = Enum.EasingStyle.Quart,
		Direction = Enum.EasingDirection.Out,
	} :: TweenConfig,
	
	Bounce = {
		Duration = 0.5,
		Style = Enum.EasingStyle.Bounce,
		Direction = Enum.EasingDirection.Out,
	} :: TweenConfig,
	
	Elastic = {
		Duration = 0.6,
		Style = Enum.EasingStyle.Elastic,
		Direction = Enum.EasingDirection.Out,
	} :: TweenConfig,
	
	Linear = {
		Duration = 0.3,
		Style = Enum.EasingStyle.Linear,
		Direction = Enum.EasingDirection.InOut,
	} :: TweenConfig,
}

-- Color palette for liquid glass effects
Constants.Colors = {
	-- Base glass colors
	Glass = {
		Clear = Color3.fromRGB(255, 255, 255),
		Frosted = Color3.fromRGB(240, 244, 248),
		Tinted = Color3.fromRGB(200, 220, 255),
		Dark = Color3.fromRGB(30, 30, 40),
	},
	
	-- Chromatic aberration colors (pure RGB channels)
	Chromatic = {
		Red = Color3.fromRGB(255, 0, 0),
		Green = Color3.fromRGB(0, 255, 0),
		Blue = Color3.fromRGB(0, 0, 255),
		-- Adjusted versions for better visual effect
		RedAdjusted = Color3.fromRGB(255, 100, 100),
		GreenAdjusted = Color3.fromRGB(100, 255, 100),
		BlueAdjusted = Color3.fromRGB(100, 100, 255),
	},
	
	-- Glow and highlight colors
	Glow = {
		White = Color3.fromRGB(255, 255, 255),
		Warm = Color3.fromRGB(255, 248, 240),
		Cool = Color3.fromRGB(240, 248, 255),
		Accent = Color3.fromRGB(100, 200, 255),
	},
	
	-- Shadow colors
	Shadow = {
		Soft = Color3.fromRGB(0, 0, 0),
		Blue = Color3.fromRGB(20, 40, 80),
		Purple = Color3.fromRGB(40, 20, 80),
	},
	
	-- Border gradient colors
	Border = {
		Transparent = Color3.fromRGB(255, 255, 255), -- With high transparency
		Highlight = Color3.fromRGB(255, 255, 255), -- Main highlight
		Bright = Color3.fromRGB(255, 255, 255), -- Brightest point
	},
}

-- Default effect configurations
Constants.Defaults = {
	-- Chromatic aberration defaults
	Chromatic = {
		Enabled = true,
		Intensity = 3,
		EdgeOnly = true,
		RedOffset = Vector2.new(-2, 0),
		GreenOffset = Vector2.new(0, 0),
		BlueOffset = Vector2.new(2, 0),
		Opacity = 0.15,
	} :: ChromaticConfig,
	
	-- Refraction defaults
	Refraction = {
		Enabled = true,
		Intensity = 8,
		EdgeWidth = 20,
		Layers = 4,
		FalloffExponent = 2,
	} :: RefractionConfig,
	
	-- Frost defaults
	Frost = {
		Enabled = true,
		Intensity = 0.6,
		NoiseScale = 2,
		NoiseOpacity = 0.08,
		Layers = 3,
		Tint = Color3.fromRGB(255, 255, 255),
		TintOpacity = 0.1,
	} :: FrostConfig,
	
	-- Border gradient defaults
	BorderGradient = {
		Enabled = true,
		BaseRotation = 135,
		MouseInfluence = 1.2,
		Colors = {
			{ Position = 0, Color = Color3.fromRGB(255, 255, 255), Transparency = 0.95 },
			{ Position = 0.3, Color = Color3.fromRGB(255, 255, 255), Transparency = 0.7 },
			{ Position = 0.5, Color = Color3.fromRGB(255, 255, 255), Transparency = 0.4 },
			{ Position = 0.7, Color = Color3.fromRGB(255, 255, 255), Transparency = 0.7 },
			{ Position = 1, Color = Color3.fromRGB(255, 255, 255), Transparency = 0.95 },
		},
		Thickness = 1.5,
		AnimationSpeed = 1,
	} :: BorderGradientConfig,
	
	-- Depth defaults
	Depth = {
		Enabled = true,
		TopGlowColor = Color3.fromRGB(255, 255, 255),
		TopGlowOpacity = 0.2,
		TopGlowSize = 30,
		BottomShadowColor = Color3.fromRGB(0, 0, 0),
		BottomShadowOpacity = 0.1,
		BottomShadowSize = 20,
		InnerGlowColor = Color3.fromRGB(255, 255, 255),
		InnerGlowOpacity = 0.05,
		InnerGlowSize = 10,
	} :: DepthConfig,
	
	-- Interaction defaults
	Interaction = {
		Enabled = true,
		HoverScale = 1.02,
		PressScale = 0.98,
		ElasticFollow = true,
		FollowIntensity = 8,
		FollowSpring = Constants.Springs.Elastic,
		GlowOnHover = true,
		HoverGlowIntensity = 1.3,
	} :: InteractionConfig,
	
	-- Background defaults
	Background = {
		Color = Color3.fromRGB(255, 255, 255),
		Transparency = 0.85,
		GradientEnabled = true,
		GradientColors = {
			{ Position = 0, Color = Color3.fromRGB(255, 255, 255), Transparency = 0.82 },
			{ Position = 1, Color = Color3.fromRGB(240, 245, 250), Transparency = 0.88 },
		},
		GradientRotation = 180,
	} :: BackgroundConfig,
	
	-- Shadow defaults
	Shadow = {
		Enabled = true,
		Color = Color3.fromRGB(0, 0, 30),
		Transparency = 0.7,
		Offset = Vector2.new(0, 8),
		Spread = 20,
		Blur = 30,
	} :: ShadowConfig,
}

-- Layer z-index ordering (from back to front)
Constants.ZOrder = {
	Shadow = 0,
	Background = 10,
	FrostBase = 20,
	FrostLayers = 25, -- +1 per layer
	RefractionBase = 30,
	RefractionLayers = 35, -- +1 per layer
	ChromaticRed = 40,
	ChromaticGreen = 41,
	ChromaticBlue = 42,
	DepthBottom = 50,
	DepthTop = 51,
	InnerGlow = 55,
	Border = 60,
	ContentContainer = 100,
}

-- Noise texture configuration for frost effect
Constants.NoiseTexture = {
	-- Using a simple procedural approach since Roblox doesn't have noise textures
	-- We'll generate patterns using overlapping gradients
	Seed = 12345,
	Octaves = 3,
	Persistence = 0.5,
	Scale = 1,
}

--// ═══════════════════════════════════════════════════════════════════════════════
--// SECTION 4: MATH UTILITIES
--// ═══════════════════════════════════════════════════════════════════════════════

--[[
    Mathematical utility functions for liquid glass calculations.
    Includes interpolation, easing, SDF functions, and vector math.
]]

local MathUtils = {}

--[=[
    Clamps a value between min and max bounds.
    
    @param value number -- The value to clamp
    @param min number -- Minimum allowed value
    @param max number -- Maximum allowed value
    @return number -- Clamped value
]=]
function MathUtils.Clamp(value: number, min: number, max: number): number
	return math.max(min, math.min(max, value))
end

--[=[
    Linear interpolation between two values.
    
    @param a number -- Start value
    @param b number -- End value
    @param t number -- Interpolation factor (0-1)
    @return number -- Interpolated value
]=]
function MathUtils.Lerp(a: number, b: number, t: number): number
	return a + (b - a) * t
end

--[=[
    Inverse linear interpolation - finds where value falls between a and b.
    
    @param a number -- Start value
    @param b number -- End value
    @param value number -- The value to find position of
    @return number -- Position (0-1) of value between a and b
]=]
function MathUtils.InverseLerp(a: number, b: number, value: number): number
	if math.abs(b - a) < Constants.Math.EPSILON then
		return 0
	end
	return (value - a) / (b - a)
end

--[=[
    Remaps a value from one range to another.
    
    @param value number -- Input value
    @param inMin number -- Input range minimum
    @param inMax number -- Input range maximum
    @param outMin number -- Output range minimum
    @param outMax number -- Output range maximum
    @return number -- Remapped value
]=]
function MathUtils.Remap(value: number, inMin: number, inMax: number, outMin: number, outMax: number): number
	local t = MathUtils.InverseLerp(inMin, inMax, value)
	return MathUtils.Lerp(outMin, outMax, t)
end

--[=[
    Smoothstep interpolation - smooth Hermite interpolation.
    Creates smooth S-curve transition, essential for glass effects.
    
    @param edge0 number -- Lower edge
    @param edge1 number -- Upper edge
    @param x number -- Input value
    @return number -- Smoothed value (0-1)
]=]
function MathUtils.Smoothstep(edge0: number, edge1: number, x: number): number
	local t = MathUtils.Clamp((x - edge0) / (edge1 - edge0), 0, 1)
	return t * t * (3 - 2 * t)
end

--[=[
    Smootherstep - Ken Perlin's improved smoothstep with zero second derivatives.
    Even smoother transitions, great for glass refraction falloff.
    
    @param edge0 number -- Lower edge
    @param edge1 number -- Upper edge
    @param x number -- Input value
    @return number -- Smoothed value (0-1)
]=]
function MathUtils.Smootherstep(edge0: number, edge1: number, x: number): number
	local t = MathUtils.Clamp((x - edge0) / (edge1 - edge0), 0, 1)
	return t * t * t * (t * (t * 6 - 15) + 10)
end

--[=[
    Vector2 linear interpolation.
    
    @param a Vector2 -- Start vector
    @param b Vector2 -- End vector
    @param t number -- Interpolation factor
    @return Vector2 -- Interpolated vector
]=]
function MathUtils.LerpVector2(a: Vector2, b: Vector2, t: number): Vector2
	return Vector2.new(
		MathUtils.Lerp(a.X, b.X, t),
		MathUtils.Lerp(a.Y, b.Y, t)
	)
end

--[=[
    Color3 linear interpolation.
    
    @param a Color3 -- Start color
    @param b Color3 -- End color
    @param t number -- Interpolation factor
    @return Color3 -- Interpolated color
]=]
function MathUtils.LerpColor3(a: Color3, b: Color3, t: number): Color3
	return Color3.new(
		MathUtils.Lerp(a.R, b.R, t),
		MathUtils.Lerp(a.G, b.G, t),
		MathUtils.Lerp(a.B, b.B, t)
	)
end

--[=[
    Exponential decay interpolation - useful for smooth following.
    
    @param current number -- Current value
    @param target number -- Target value
    @param decay number -- Decay rate (higher = faster)
    @param dt number -- Delta time
    @return number -- New value
]=]
function MathUtils.ExpDecay(current: number, target: number, decay: number, dt: number): number
	return target + (current - target) * math.exp(-decay * dt)
end

--[=[
    2D exponential decay for Vector2.
    
    @param current Vector2 -- Current position
    @param target Vector2 -- Target position
    @param decay number -- Decay rate
    @param dt number -- Delta time
    @return Vector2 -- New position
]=]
function MathUtils.ExpDecayVector2(current: Vector2, target: Vector2, decay: number, dt: number): Vector2
	return Vector2.new(
		MathUtils.ExpDecay(current.X, target.X, decay, dt),
		MathUtils.ExpDecay(current.Y, target.Y, decay, dt)
	)
end

--[=[
    Signed distance function for a rounded rectangle.
    Used for calculating edge distances for glass effects.
    
    @param point Vector2 -- Point to test
    @param size Vector2 -- Rectangle half-size
    @param radius number -- Corner radius
    @return number -- Signed distance (negative inside, positive outside)
]=]
function MathUtils.SDFRoundedRect(point: Vector2, size: Vector2, radius: number): number
	local q = Vector2.new(
		math.abs(point.X) - size.X + radius,
		math.abs(point.Y) - size.Y + radius
	)
	local outsideDist = Vector2.new(math.max(q.X, 0), math.max(q.Y, 0)).Magnitude
	local insideDist = math.min(math.max(q.X, q.Y), 0)
	return outsideDist + insideDist - radius
end

--[=[
    Calculate distance from point to nearest edge of rectangle.
    Essential for edge-based effects like chromatic aberration.
    
    @param point Vector2 -- Point position (relative to center)
    @param size Vector2 -- Rectangle half-size
    @return number -- Distance to nearest edge
]=]
function MathUtils.DistanceToEdge(point: Vector2, size: Vector2): number
	local distX = size.X - math.abs(point.X)
	local distY = size.Y - math.abs(point.Y)
	return math.min(distX, distY)
end

--[=[
    Calculate edge factor - 1 at edges, 0 at center.
    Used for edge-only effects.
    
    @param point Vector2 -- Point position (relative to center)
    @param size Vector2 -- Rectangle half-size
    @param edgeWidth number -- Width of edge zone
    @return number -- Edge factor (0-1)
]=]
function MathUtils.EdgeFactor(point: Vector2, size: Vector2, edgeWidth: number): number
	local dist = MathUtils.DistanceToEdge(point, size)
	return 1 - MathUtils.Smoothstep(0, edgeWidth, dist)
end

--[=[
    Normalize a value from screen space to -1 to 1 range.
    
    @param value number -- Input value
    @param size number -- Total size
    @return number -- Normalized value (-1 to 1)
]=]
function MathUtils.NormalizeToCenter(value: number, size: number): number
	return (value / size) * 2 - 1
end

--[=[
    Convert position within element to normalized offset from center.
    
    @param localPos Vector2 -- Position within element
    @param elementSize Vector2 -- Element size
    @return Vector2 -- Normalized offset (-1 to 1 on each axis)
]=]
function MathUtils.GetNormalizedOffset(localPos: Vector2, elementSize: Vector2): Vector2
	return Vector2.new(
		MathUtils.NormalizeToCenter(localPos.X, elementSize.X),
		MathUtils.NormalizeToCenter(localPos.Y, elementSize.Y)
	)
end

--[=[
    Calculate angle in degrees from center to point.
    Used for gradient rotation based on mouse position.
    
    @param offset Vector2 -- Offset from center
    @return number -- Angle in degrees
]=]
function MathUtils.GetAngleFromOffset(offset: Vector2): number
	return math.atan2(offset.Y, offset.X) * Constants.Math.RAD_TO_DEG
end

--[=[
    Rotate a 2D point around origin.
    
    @param point Vector2 -- Point to rotate
    @param angleDeg number -- Rotation angle in degrees
    @return Vector2 -- Rotated point
]=]
function MathUtils.RotatePoint(point: Vector2, angleDeg: number): Vector2
	local angleRad = angleDeg * Constants.Math.DEG_TO_RAD
	local cos = math.cos(angleRad)
	local sin = math.sin(angleRad)
	return Vector2.new(
		point.X * cos - point.Y * sin,
		point.X * sin + point.Y * cos
	)
end

--[=[
    Generate pseudo-random number based on seed.
    Used for procedural noise generation.
    
    @param seed number -- Input seed
    @return number -- Pseudo-random number (0-1)
]=]
function MathUtils.SeededRandom(seed: number): number
	local x = math.sin(seed * 12.9898) * 43758.5453
	return x - math.floor(x)
end

--[=[
    2D hash function for noise generation.
    
    @param x number -- X coordinate
    @param y number -- Y coordinate
    @return number -- Hash value (0-1)
]=]
function MathUtils.Hash2D(x: number, y: number): number
	local seed = x * 374761393 + y * 668265263
	return MathUtils.SeededRandom(seed)
end

--[=[
    Simple 2D value noise.
    Used for frost texture simulation.
    
    @param x number -- X coordinate
    @param y number -- Y coordinate
    @return number -- Noise value (0-1)
]=]
function MathUtils.ValueNoise2D(x: number, y: number): number
	local xi = math.floor(x)
	local yi = math.floor(y)
	local xf = x - xi
	local yf = y - yi
	
	-- Four corners
	local c00 = MathUtils.Hash2D(xi, yi)
	local c10 = MathUtils.Hash2D(xi + 1, yi)
	local c01 = MathUtils.Hash2D(xi, yi + 1)
	local c11 = MathUtils.Hash2D(xi + 1, yi + 1)
	
	-- Smooth interpolation
	local sx = MathUtils.Smoothstep(0, 1, xf)
	local sy = MathUtils.Smoothstep(0, 1, yf)
	
	local nx0 = MathUtils.Lerp(c00, c10, sx)
	local nx1 = MathUtils.Lerp(c01, c11, sx)
	
	return MathUtils.Lerp(nx0, nx1, sy)
end

--[=[
    Fractal Brownian Motion noise.
    Creates more natural-looking noise for frost effect.
    
    @param x number -- X coordinate
    @param y number -- Y coordinate
    @param octaves number -- Number of noise layers
    @param persistence number -- How much each octave contributes
    @return number -- FBM noise value (0-1)
]=]
function MathUtils.FBM(x: number, y: number, octaves: number, persistence: number): number
	local total = 0
	local frequency = 1
	local amplitude = 1
	local maxValue = 0
	
	for _ = 1, octaves do
		total = total + MathUtils.ValueNoise2D(x * frequency, y * frequency) * amplitude
		maxValue = maxValue + amplitude
		amplitude = amplitude * persistence
		frequency = frequency * 2
	end
	
	return total / maxValue
end

--[=[
    Power curve - raises value to power while preserving sign.
    Useful for intensity curves.
    
    @param value number -- Input value
    @param power number -- Power exponent
    @return number -- Result
]=]
function MathUtils.PowerCurve(value: number, power: number): number
	return math.sign(value) * math.abs(value) ^ power
end

--[=[
    Sine wave oscillation.
    Used for subtle animated effects.
    
    @param time number -- Time value
    @param frequency number -- Oscillation frequency
    @param amplitude number -- Wave amplitude
    @param phase number -- Phase offset
    @return number -- Oscillation value
]=]
function MathUtils.SineWave(time: number, frequency: number, amplitude: number, phase: number?): number
	phase = phase or 0
	return math.sin(time * frequency * Constants.Math.TAU + phase) * amplitude
end

--[=[
    Calculate the magnitude of a Vector2.
    
    @param v Vector2 -- Input vector
    @return number -- Magnitude
]=]
function MathUtils.Magnitude(v: Vector2): number
	return math.sqrt(v.X * v.X + v.Y * v.Y)
end

--[=[
    Normalize a Vector2 to unit length.
    
    @param v Vector2 -- Input vector
    @return Vector2 -- Normalized vector
]=]
function MathUtils.Normalize(v: Vector2): Vector2
	local mag = MathUtils.Magnitude(v)
	if mag < Constants.Math.EPSILON then
		return Vector2.new(0, 0)
	end
	return Vector2.new(v.X / mag, v.Y / mag)
end

--[=[
    Dot product of two Vector2s.
    
    @param a Vector2 -- First vector
    @param b Vector2 -- Second vector
    @return number -- Dot product
]=]
function MathUtils.Dot(a: Vector2, b: Vector2): number
	return a.X * b.X + a.Y * b.Y
end

--[=[
    Reflect a vector off a surface with given normal.
    
    @param incident Vector2 -- Incident vector
    @param normal Vector2 -- Surface normal
    @return Vector2 -- Reflected vector
]=]
function MathUtils.Reflect(incident: Vector2, normal: Vector2): Vector2
	local d = MathUtils.Dot(incident, normal)
	return Vector2.new(
		incident.X - 2 * d * normal.X,
		incident.Y - 2 * d * normal.Y
	)
end

--// ═══════════════════════════════════════════════════════════════════════════════
--// SECTION 5: COLOR UTILITIES
--// ═══════════════════════════════════════════════════════════════════════════════

--[[
    Color manipulation utilities for liquid glass effects.
    Includes color space conversions, blending, and chromatic functions.
]]

local ColorUtils = {}

--[=[
    Convert HSV to RGB Color3.
    
    @param h number -- Hue (0-360)
    @param s number -- Saturation (0-1)
    @param v number -- Value (0-1)
    @return Color3 -- RGB color
]=]
function ColorUtils.HSVToRGB(h: number, s: number, v: number): Color3
	h = h % 360
	local c = v * s
	local x = c * (1 - math.abs((h / 60) % 2 - 1))
	local m = v - c
	
	local r, g, b
	if h < 60 then
		r, g, b = c, x, 0
	elseif h < 120 then
		r, g, b = x, c, 0
	elseif h < 180 then
		r, g, b = 0, c, x
	elseif h < 240 then
		r, g, b = 0, x, c
	elseif h < 300 then
		r, g, b = x, 0, c
	else
		r, g, b = c, 0, x
	end
	
	return Color3.new(r + m, g + m, b + m)
end

--[=[
    Convert RGB Color3 to HSV.
    
    @param color Color3 -- RGB color
    @return number, number, number -- H (0-360), S (0-1), V (0-1)
]=]
function ColorUtils.RGBToHSV(color: Color3): (number, number, number)
	local r, g, b = color.R, color.G, color.B
	local max = math.max(r, g, b)
	local min = math.min(r, g, b)
	local delta = max - min
	
	local h, s, v
	v = max
	
	if max == 0 then
		s = 0
	else
		s = delta / max
	end
	
	if delta == 0 then
		h = 0
	elseif max == r then
		h = 60 * (((g - b) / delta) % 6)
	elseif max == g then
		h = 60 * (((b - r) / delta) + 2)
	else
		h = 60 * (((r - g) / delta) + 4)
	end
	
	if h < 0 then
		h = h + 360
	end
	
	return h, s, v
end

--[=[
    Adjust color brightness.
    
    @param color Color3 -- Input color
    @param factor number -- Brightness multiplier (1 = no change)
    @return Color3 -- Adjusted color
]=]
function ColorUtils.AdjustBrightness(color: Color3, factor: number): Color3
	return Color3.new(
		MathUtils.Clamp(color.R * factor, 0, 1),
		MathUtils.Clamp(color.G * factor, 0, 1),
		MathUtils.Clamp(color.B * factor, 0, 1)
	)
end

--[=[
    Adjust color saturation.
    
    @param color Color3 -- Input color
    @param factor number -- Saturation multiplier (1 = no change, 0 = grayscale)
    @return Color3 -- Adjusted color
]=]
function ColorUtils.AdjustSaturation(color: Color3, factor: number): Color3
	local h, s, v = ColorUtils.RGBToHSV(color)
	s = MathUtils.Clamp(s * factor, 0, 1)
	return ColorUtils.HSVToRGB(h, s, v)
end

--[=[
    Shift hue of a color.
    
    @param color Color3 -- Input color
    @param degrees number -- Hue shift in degrees
    @return Color3 -- Shifted color
]=]
function ColorUtils.ShiftHue(color: Color3, degrees: number): Color3
	local h, s, v = ColorUtils.RGBToHSV(color)
	h = (h + degrees) % 360
	return ColorUtils.HSVToRGB(h, s, v)
end

--[=[
    Blend two colors using various blend modes.
    
    @param base Color3 -- Base color
    @param blend Color3 -- Blend color
    @param mode string -- Blend mode: "normal", "screen", "overlay", "multiply", "add"
    @param opacity number -- Blend opacity (0-1)
    @return Color3 -- Blended color
]=]
function ColorUtils.Blend(base: Color3, blend: Color3, mode: string, opacity: number): Color3
	local result: Color3
	
	if mode == "normal" then
		result = blend
		
	elseif mode == "screen" then
		-- Screen blend: 1 - (1 - base) * (1 - blend)
		-- Creates lighter result, used for light effects
		result = Color3.new(
			1 - (1 - base.R) * (1 - blend.R),
			1 - (1 - base.G) * (1 - blend.G),
			1 - (1 - base.B) * (1 - blend.B)
		)
		
	elseif mode == "overlay" then
		-- Overlay: combines multiply and screen
		local function overlayChannel(b: number, l: number): number
			if b < 0.5 then
				return 2 * b * l
			else
				return 1 - 2 * (1 - b) * (1 - l)
			end
		end
		result = Color3.new(
			overlayChannel(base.R, blend.R),
			overlayChannel(base.G, blend.G),
			overlayChannel(base.B, blend.B)
		)
		
	elseif mode == "multiply" then
		result = Color3.new(
			base.R * blend.R,
			base.G * blend.G,
			base.B * blend.B
		)
		
	elseif mode == "add" then
		result = Color3.new(
			MathUtils.Clamp(base.R + blend.R, 0, 1),
			MathUtils.Clamp(base.G + blend.G, 0, 1),
			MathUtils.Clamp(base.B + blend.B, 0, 1)
		)
		
	else
		result = blend
	end
	
	-- Apply opacity
	return MathUtils.LerpColor3(base, result, opacity)
end

--[=[
    Extract single color channel for chromatic aberration.
    
    @param color Color3 -- Input color
    @param channel string -- "r", "g", or "b"
    @return Color3 -- Color with only specified channel
]=]
function ColorUtils.ExtractChannel(color: Color3, channel: string): Color3
	if channel == "r" then
		return Color3.new(color.R, 0, 0)
	elseif channel == "g" then
		return Color3.new(0, color.G, 0)
	elseif channel == "b" then
		return Color3.new(0, 0, color.B)
	else
		return color
	end
end

--[=[
    Create chromatic aberration color set.
    Returns three colors for RGB channel separation.
    
    @param baseColor Color3 -- Base color to split
    @param intensity number -- Separation intensity
    @return Color3, Color3, Color3 -- Red, Green, Blue tinted colors
]=]
function ColorUtils.CreateChromaticSet(baseColor: Color3, intensity: number): (Color3, Color3, Color3)
	local h, s, v = ColorUtils.RGBToHSV(baseColor)
	
	-- Slight hue shifts for each channel
	local redHue = (h + 10 * intensity) % 360
	local greenHue = h
	local blueHue = (h - 10 * intensity + 360) % 360
	
	local red = ColorUtils.HSVToRGB(redHue, s, v)
	local green = ColorUtils.HSVToRGB(greenHue, s, v)
	local blue = ColorUtils.HSVToRGB(blueHue, s, v)
	
	-- Tint towards pure RGB
	red = MathUtils.LerpColor3(red, Color3.new(1, 0.2, 0.2), 0.3 * intensity)
	blue = MathUtils.LerpColor3(blue, Color3.new(0.2, 0.2, 1), 0.3 * intensity)
	
	return red, green, blue
end

--[=[
    Create gradient color sequence for liquid glass border.
    
    @param highlightColor Color3 -- Main highlight color
    @param intensity number -- Highlight intensity
    @return ColorSequence -- Gradient for UIGradient
]=]
function ColorUtils.CreateBorderGradientSequence(highlightColor: Color3, intensity: number): ColorSequence
	local adjusted = ColorUtils.AdjustBrightness(highlightColor, intensity)
	
	return ColorSequence.new({
		ColorSequenceKeypoint.new(0, highlightColor),
		ColorSequenceKeypoint.new(0.3, adjusted),
		ColorSequenceKeypoint.new(0.5, ColorUtils.AdjustBrightness(adjusted, 1.2)),
		ColorSequenceKeypoint.new(0.7, adjusted),
		ColorSequenceKeypoint.new(1, highlightColor),
	})
end

--[=[
    Create transparency sequence for liquid glass border.
    Creates the characteristic transparent-opaque-transparent pattern.
    
    @param baseTransparency number -- Base transparency level
    @param peakOpacity number -- Opacity at brightest point
    @return NumberSequence -- Transparency gradient
]=]
function ColorUtils.CreateBorderTransparencySequence(baseTransparency: number, peakOpacity: number): NumberSequence
	local peak = 1 - peakOpacity
	
	return NumberSequence.new({
		NumberSequenceKeypoint.new(0, baseTransparency),
		NumberSequenceKeypoint.new(0.3, MathUtils.Lerp(baseTransparency, peak, 0.5)),
		NumberSequenceKeypoint.new(0.5, peak),
		NumberSequenceKeypoint.new(0.7, MathUtils.Lerp(baseTransparency, peak, 0.5)),
		NumberSequenceKeypoint.new(1, baseTransparency),
	})
end

--[=[
    Convert hex string to Color3.
    
    @param hex string -- Hex color string (with or without #)
    @return Color3 -- Converted color
]=]
function ColorUtils.HexToColor3(hex: string): Color3
	hex = hex:gsub("#", "")
	
	local r = tonumber(hex:sub(1, 2), 16) or 255
	local g = tonumber(hex:sub(3, 4), 16) or 255
	local b = tonumber(hex:sub(5, 6), 16) or 255
	
	return Color3.fromRGB(r, g, b)
end

--[=[
    Convert Color3 to hex string.
    
    @param color Color3 -- Color to convert
    @return string -- Hex string (without #)
]=]
function ColorUtils.Color3ToHex(color: Color3): string
	return string.format("%02X%02X%02X", 
		math.floor(color.R * 255 + 0.5),
		math.floor(color.G * 255 + 0.5),
		math.floor(color.B * 255 + 0.5)
	)
end

--[=[
    Get perceived brightness of a color (luminance).
    
    @param color Color3 -- Input color
    @return number -- Perceived brightness (0-1)
]=]
function ColorUtils.GetLuminance(color: Color3): number
	-- Using relative luminance formula
	return 0.2126 * color.R + 0.7152 * color.G + 0.0722 * color.B
end

--[=[
    Determine if color is light or dark.
    
    @param color Color3 -- Input color
    @return boolean -- True if light, false if dark
]=]
function ColorUtils.IsLight(color: Color3): boolean
	return ColorUtils.GetLuminance(color) > 0.5
end

--[=[
    Get contrasting color (black or white) for text on background.
    
    @param backgroundColor Color3 -- Background color
    @return Color3 -- Contrasting color for text
]=]
function ColorUtils.GetContrastColor(backgroundColor: Color3): Color3
	if ColorUtils.IsLight(backgroundColor) then
		return Color3.new(0, 0, 0)
	else
		return Color3.new(1, 1, 1)
	end
end

--// ═══════════════════════════════════════════════════════════════════════════════
--// SECTION 6: GRADIENT UTILITIES
--// ═══════════════════════════════════════════════════════════════════════════════

--[[
    Gradient creation utilities for various liquid glass effects.
    Includes radial, linear, and custom gradient generators.
]]

local GradientUtils = {}

--[=[
    Create a linear gradient UIGradient.
    
    @param colors { GradientStop } -- Color stops
    @param rotation number -- Rotation in degrees
    @return UIGradient -- Created gradient
]=]
function GradientUtils.CreateLinearGradient(colors: { GradientStop }, rotation: number?): UIGradient
	local colorKeypoints = {}
	local transparencyKeypoints = {}
	
	for _, stop in ipairs(colors) do
		table.insert(colorKeypoints, ColorSequenceKeypoint.new(stop.Position, stop.Color))
		table.insert(transparencyKeypoints, NumberSequenceKeypoint.new(
			stop.Position,
			stop.Transparency or 0
		))
	end
	
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new(colorKeypoints)
	gradient.Transparency = NumberSequence.new(transparencyKeypoints)
	gradient.Rotation = rotation or 0
	
	return gradient
end

--[=[
    Create a radial-like gradient using offset.
    Note: Roblox UIGradient doesn't support true radial gradients,
    this simulates it using the Offset property.
    
    @param centerColor Color3 -- Color at center
    @param edgeColor Color3 -- Color at edges
    @param centerTransparency number -- Transparency at center
    @param edgeTransparency number -- Transparency at edges
    @return UIGradient -- Created gradient
]=]
function GradientUtils.CreateRadialGradient(
	centerColor: Color3,
	edgeColor: Color3,
	centerTransparency: number,
	edgeTransparency: number
): UIGradient
	local gradient = Instance.new("UIGradient")
	
	-- Create a gradient that goes from edge to center to edge
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, edgeColor),
		ColorSequenceKeypoint.new(0.5, centerColor),
		ColorSequenceKeypoint.new(1, edgeColor),
	})
	
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, edgeTransparency),
		NumberSequenceKeypoint.new(0.5, centerTransparency),
		NumberSequenceKeypoint.new(1, edgeTransparency),
	})
	
	return gradient
end

--[=[
    Create the dynamic border gradient for liquid glass.
    This is the characteristic moving highlight effect.
    
    @param config BorderGradientConfig -- Border configuration
    @return UIGradient -- Created gradient
]=]
function GradientUtils.CreateDynamicBorderGradient(config: BorderGradientConfig): UIGradient
	local colorKeypoints = {}
	local transparencyKeypoints = {}
	
	for _, stop in ipairs(config.Colors) do
		table.insert(colorKeypoints, ColorSequenceKeypoint.new(stop.Position, stop.Color))
		table.insert(transparencyKeypoints, NumberSequenceKeypoint.new(
			stop.Position,
			stop.Transparency or 0
		))
	end
	
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new(colorKeypoints)
	gradient.Transparency = NumberSequence.new(transparencyKeypoints)
	gradient.Rotation = config.BaseRotation
	
	return gradient
end

--[=[
    Create top-glow gradient for depth effect.
    Simulates light hitting top edge of glass.
    
    @param glowColor Color3 -- Glow color
    @param opacity number -- Maximum opacity
    @param size number -- Glow size as fraction (0-1)
    @return UIGradient -- Created gradient
]=]
function GradientUtils.CreateTopGlowGradient(glowColor: Color3, opacity: number, size: number): UIGradient
	local gradient = Instance.new("UIGradient")
	
	gradient.Color = ColorSequence.new(glowColor)
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1 - opacity),
		NumberSequenceKeypoint.new(size, 1),
		NumberSequenceKeypoint.new(1, 1),
	})
	gradient.Rotation = 180 -- Top to bottom
	
	return gradient
end

--[=[
    Create bottom-shadow gradient for depth effect.
    Simulates shadow at bottom edge of glass.
    
    @param shadowColor Color3 -- Shadow color
    @param opacity number -- Maximum opacity
    @param size number -- Shadow size as fraction (0-1)
    @return UIGradient -- Created gradient
]=]
function GradientUtils.CreateBottomShadowGradient(shadowColor: Color3, opacity: number, size: number): UIGradient
	local gradient = Instance.new("UIGradient")
	
	gradient.Color = ColorSequence.new(shadowColor)
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(1 - size, 1),
		NumberSequenceKeypoint.new(1, 1 - opacity),
	})
	gradient.Rotation = 180 -- Top to bottom
	
	return gradient
end

--[=[
    Create inner glow gradient.
    Subtle glow around inner edges of glass.
    
    @param glowColor Color3 -- Glow color
    @param opacity number -- Glow opacity
    @return UIGradient -- Created gradient
]=]
function GradientUtils.CreateInnerGlowGradient(glowColor: Color3, opacity: number): UIGradient
	local gradient = Instance.new("UIGradient")
	
	gradient.Color = ColorSequence.new(glowColor)
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1 - opacity),
		NumberSequenceKeypoint.new(0.3, 1),
		NumberSequenceKeypoint.new(0.7, 1),
		NumberSequenceKeypoint.new(1, 1 - opacity),
	})
	
	return gradient
end

--[=[
    Create edge-only transparency gradient.
    Used for effects that should only appear at edges (chromatic aberration).
    
    @param edgeWidth number -- Width of edge zone as fraction (0-1)
    @param edgeOpacity number -- Opacity at edges
    @return UIGradient -- Created gradient
]=]
function GradientUtils.CreateEdgeOnlyGradient(edgeWidth: number, edgeOpacity: number): UIGradient
	local gradient = Instance.new("UIGradient")
	
	gradient.Color = ColorSequence.new(Color3.new(1, 1, 1))
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1 - edgeOpacity),
		NumberSequenceKeypoint.new(edgeWidth, 1),
		NumberSequenceKeypoint.new(1 - edgeWidth, 1),
		NumberSequenceKeypoint.new(1, 1 - edgeOpacity),
	})
	
	return gradient
end

--[=[
    Create frosted glass overlay gradient.
    Provides the characteristic frosted appearance.
    
    @param tint Color3 -- Tint color
    @param opacity number -- Overall opacity
    @return UIGradient -- Created gradient
]=]
function GradientUtils.CreateFrostGradient(tint: Color3, opacity: number): UIGradient
	local gradient = Instance.new("UIGradient")
	
	-- Subtle variation in tint for more natural look
	local lightTint = ColorUtils.AdjustBrightness(tint, 1.1)
	local darkTint = ColorUtils.AdjustBrightness(tint, 0.95)
	
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, lightTint),
		ColorSequenceKeypoint.new(0.5, tint),
		ColorSequenceKeypoint.new(1, darkTint),
	})
	
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1 - opacity * 0.9),
		NumberSequenceKeypoint.new(0.5, 1 - opacity),
		NumberSequenceKeypoint.new(1, 1 - opacity * 0.95),
	})
	
	gradient.Rotation = 180
	
	return gradient
end

--[=[
    Update gradient rotation based on mouse position.
    Core function for dynamic border effect.
    
    @param gradient UIGradient -- Gradient to update
    @param mouseOffset Vector2 -- Normalized mouse offset (-1 to 1)
    @param baseRotation number -- Base rotation in degrees
    @param influence number -- How much mouse affects rotation
]=]
function GradientUtils.UpdateDynamicRotation(
	gradient: UIGradient,
	mouseOffset: Vector2,
	baseRotation: number,
	influence: number
)
	local rotation = baseRotation + mouseOffset.X * influence * 30
	gradient.Rotation = rotation
end

--// ═══════════════════════════════════════════════════════════════════════════════
--// SECTION 7: ANIMATION & EASING UTILITIES
--// ═══════════════════════════════════════════════════════════════════════════════

--[[
    Animation utilities including easing functions and tween helpers.
    These provide smooth, natural-feeling transitions for the glass effects.
]]

local AnimationUtils = {}

-- Standard easing functions
AnimationUtils.Easings = {}

--[=[
    Linear easing - no acceleration.
    
    @param t number -- Progress (0-1)
    @return number -- Eased value
]=]
function AnimationUtils.Easings.Linear(t: number): number
	return t
end

--[=[
    Quadratic ease in - accelerating.
    
    @param t number -- Progress (0-1)
    @return number -- Eased value
]=]
function AnimationUtils.Easings.QuadIn(t: number): number
	return t * t
end

--[=[
    Quadratic ease out - decelerating.
    
    @param t number -- Progress (0-1)
    @return number -- Eased value
]=]
function AnimationUtils.Easings.QuadOut(t: number): number
	return t * (2 - t)
end

--[=[
    Quadratic ease in-out - accelerate then decelerate.
    
    @param t number -- Progress (0-1)
    @return number -- Eased value
]=]
function AnimationUtils.Easings.QuadInOut(t: number): number
	if t < 0.5 then
		return 2 * t * t
	else
		return -1 + (4 - 2 * t) * t
	end
end

--[=[
    Cubic ease in.
    
    @param t number -- Progress (0-1)
    @return number -- Eased value
]=]
function AnimationUtils.Easings.CubicIn(t: number): number
	return t * t * t
end

--[=[
    Cubic ease out.
    
    @param t number -- Progress (0-1)
    @return number -- Eased value
]=]
function AnimationUtils.Easings.CubicOut(t: number): number
	local t1 = t - 1
	return t1 * t1 * t1 + 1
end

--[=[
    Cubic ease in-out.
    
    @param t number -- Progress (0-1)
    @return number -- Eased value
]=]
function AnimationUtils.Easings.CubicInOut(t: number): number
	if t < 0.5 then
		return 4 * t * t * t
	else
		local t1 = 2 * t - 2
		return 0.5 * t1 * t1 * t1 + 1
	end
end

--[=[
    Quartic ease out - smooth deceleration.
    This is the primary easing for liquid glass transitions.
    
    @param t number -- Progress (0-1)
    @return number -- Eased value
]=]
function AnimationUtils.Easings.QuartOut(t: number): number
	local t1 = t - 1
	return 1 - t1 * t1 * t1 * t1
end

--[=[
    Quartic ease in-out.
    
    @param t number -- Progress (0-1)
    @return number -- Eased value
]=]
function AnimationUtils.Easings.QuartInOut(t: number): number
	if t < 0.5 then
		return 8 * t * t * t * t
	else
		local t1 = t - 1
		return 1 - 8 * t1 * t1 * t1 * t1
	end
end

--[=[
    Exponential ease out.
    
    @param t number -- Progress (0-1)
    @return number -- Eased value
]=]
function AnimationUtils.Easings.ExpoOut(t: number): number
	if t >= 1 then
		return 1
	end
	return 1 - math.pow(2, -10 * t)
end

--[=[
    Back ease out - overshoots then settles.
    Good for playful, bouncy interactions.
    
    @param t number -- Progress (0-1)
    @return number -- Eased value
]=]
function AnimationUtils.Easings.BackOut(t: number): number
	local c1 = 1.70158
	local c3 = c1 + 1
	local t1 = t - 1
	return 1 + c3 * t1 * t1 * t1 + c1 * t1 * t1
end

--[=[
    Elastic ease out - springs past target then settles.
    
    @param t number -- Progress (0-1)
    @return number -- Eased value
]=]
function AnimationUtils.Easings.ElasticOut(t: number): number
	if t == 0 or t == 1 then
		return t
	end
	local c4 = (2 * math.pi) / 3
	return math.pow(2, -10 * t) * math.sin((t * 10 - 0.75) * c4) + 1
end

--[=[
    Bounce ease out - bounces at the end.
    
    @param t number -- Progress (0-1)
    @return number -- Eased value
]=]
function AnimationUtils.Easings.BounceOut(t: number): number
	local n1 = 7.5625
	local d1 = 2.75
	
	if t < 1 / d1 then
		return n1 * t * t
	elseif t < 2 / d1 then
		t = t - 1.5 / d1
		return n1 * t * t + 0.75
	elseif t < 2.5 / d1 then
		t = t - 2.25 / d1
		return n1 * t * t + 0.9375
	else
		t = t - 2.625 / d1
		return n1 * t * t + 0.984375
	end
end

--[=[
    Apply easing function by name.
    
    @param t number -- Progress (0-1)
    @param easingName string -- Name of easing function
    @return number -- Eased value
]=]
function AnimationUtils.ApplyEasing(t: number, easingName: string): number
	local easingFunc = AnimationUtils.Easings[easingName]
	if easingFunc then
		return easingFunc(t)
	end
	return t -- Default to linear
end

--[=[
    Create a TweenInfo from config.
    
    @param config TweenConfig -- Tween configuration
    @return TweenInfo -- Created TweenInfo
]=]
function AnimationUtils.CreateTweenInfo(config: TweenConfig): TweenInfo
	return TweenInfo.new(
		config.Duration,
		config.Style or Enum.EasingStyle.Quart,
		config.Direction or Enum.EasingDirection.Out,
		config.RepeatCount or 0,
		config.Reverses or false,
		config.DelayTime or 0
	)
end

--[=[
    Create and play a tween.
    
    @param instance Instance -- Object to tween
    @param properties { [string]: any } -- Properties to animate
    @param config TweenConfig -- Tween configuration
    @return Tween -- Created tween
]=]
function AnimationUtils.Tween(
	instance: Instance,
	properties: { [string]: any },
	config: TweenConfig
): Tween
	local tweenInfo = AnimationUtils.CreateTweenInfo(config)
	local tween = TweenService:Create(instance, tweenInfo, properties)
	tween:Play()
	return tween
end

--[=[
    Cancel all tweens on an instance.
    
    @param instance Instance -- Object with tweens to cancel
]=]
function AnimationUtils.CancelTweens(instance: Instance)
	-- Note: TweenService doesn't provide a way to get active tweens
	-- This is handled by storing references in component state
end

--[=[
    Animate a value over time using custom easing.
    Returns a function that provides the current value.
    
    @param startValue number -- Starting value
    @param endValue number -- Target value
    @param duration number -- Animation duration
    @param easingFunc function -- Easing function
    @return function -- Function that returns current value given elapsed time
]=]
function AnimationUtils.AnimateValue(
	startValue: number,
	endValue: number,
	duration: number,
	easingFunc: (number) -> number
): (number) -> number
	return function(elapsed: number): number
		local t = MathUtils.Clamp(elapsed / duration, 0, 1)
		local eased = easingFunc(t)
		return MathUtils.Lerp(startValue, endValue, eased)
	end
end

--// ═══════════════════════════════════════════════════════════════════════════════
--// SECTION 8: SPRING PHYSICS SIMULATION
--// ═══════════════════════════════════════════════════════════════════════════════

--[[
    Spring physics simulation for natural, elastic animations.
    This creates the organic, fluid feel of liquid glass interactions.
    Based on the physics of damped harmonic oscillators.
]]

local SpringPhysics = {}

--[=[
    Spring state representation.
]=]
export type SpringState = {
	Position: number,
	Velocity: number,
	Target: number,
	AtRest: boolean,
}

export type Spring2DState = {
	Position: Vector2,
	Velocity: Vector2,
	Target: Vector2,
	AtRest: boolean,
}

--[=[
    Create a new 1D spring state.
    
    @param initialPosition number -- Starting position
    @param config SpringConfig -- Spring configuration
    @return SpringState -- New spring state
]=]
function SpringPhysics.Create(initialPosition: number, config: SpringConfig?): SpringState
	return {
		Position = initialPosition,
		Velocity = config and config.Velocity or 0,
		Target = initialPosition,
		AtRest = true,
	}
end

--[=[
    Create a new 2D spring state.
    
    @param initialPosition Vector2 -- Starting position
    @param config SpringConfig -- Spring configuration
    @return Spring2DState -- New spring state
]=]
function SpringPhysics.Create2D(initialPosition: Vector2, config: SpringConfig?): Spring2DState
	return {
		Position = initialPosition,
		Velocity = Vector2.new(0, 0),
		Target = initialPosition,
		AtRest = true,
	}
end

--[=[
    Set the target position for a spring.
    
    @param spring SpringState -- Spring to update
    @param target number -- New target position
]=]
function SpringPhysics.SetTarget(spring: SpringState, target: number)
	spring.Target = target
	spring.AtRest = false
end

--[=[
    Set the target position for a 2D spring.
    
    @param spring Spring2DState -- Spring to update
    @param target Vector2 -- New target position
]=]
function SpringPhysics.SetTarget2D(spring: Spring2DState, target: Vector2)
	spring.Target = target
	spring.AtRest = false
end

--[=[
    Step a 1D spring simulation forward.
    Uses semi-implicit Euler integration for stability.
    
    @param spring SpringState -- Spring to simulate
    @param config SpringConfig -- Spring configuration
    @param dt number -- Time step
    @return boolean -- Whether spring is at rest
]=]
function SpringPhysics.Step(spring: SpringState, config: SpringConfig, dt: number): boolean
	if spring.AtRest then
		return true
	end
	
	local tension = config.Tension
	local friction = config.Friction
	local mass = config.Mass or 1
	local precision = config.Precision or 0.01
	
	-- Calculate spring force: F = -k * (position - target)
	local displacement = spring.Position - spring.Target
	local springForce = -tension * displacement
	
	-- Calculate damping force: F = -c * velocity
	local dampingForce = -friction * spring.Velocity
	
	-- Total acceleration: a = F / m
	local acceleration = (springForce + dampingForce) / mass
	
	-- Semi-implicit Euler integration
	spring.Velocity = spring.Velocity + acceleration * dt
	spring.Position = spring.Position + spring.Velocity * dt
	
	-- Clamping if configured
	if config.Clamp then
		if spring.Position > spring.Target and spring.Velocity > 0 then
			spring.Position = spring.Target
			spring.Velocity = 0
		elseif spring.Position < spring.Target and spring.Velocity < 0 then
			spring.Position = spring.Target
			spring.Velocity = 0
		end
	end
	
	-- Check if at rest
	local isAtRest = math.abs(spring.Velocity) < precision and 
		math.abs(spring.Position - spring.Target) < precision
	
	if isAtRest then
		spring.Position = spring.Target
		spring.Velocity = 0
		spring.AtRest = true
	end
	
	return spring.AtRest
end

--[=[
    Step a 2D spring simulation forward.
    
    @param spring Spring2DState -- Spring to simulate
    @param config SpringConfig -- Spring configuration
    @param dt number -- Time step
    @return boolean -- Whether spring is at rest
]=]
function SpringPhysics.Step2D(spring: Spring2DState, config: SpringConfig, dt: number): boolean
	if spring.AtRest then
		return true
	end
	
	local tension = config.Tension
	local friction = config.Friction
	local mass = config.Mass or 1
	local precision = config.Precision or 0.01
	
	-- Calculate spring force for each axis
	local displacementX = spring.Position.X - spring.Target.X
	local displacementY = spring.Position.Y - spring.Target.Y
	
	local springForceX = -tension * displacementX
	local springForceY = -tension * displacementY
	
	local dampingForceX = -friction * spring.Velocity.X
	local dampingForceY = -friction * spring.Velocity.Y
	
	local accelerationX = (springForceX + dampingForceX) / mass
	local accelerationY = (springForceY + dampingForceY) / mass
	
	-- Semi-implicit Euler integration
	local newVelocityX = spring.Velocity.X + accelerationX * dt
	local newVelocityY = spring.Velocity.Y + accelerationY * dt
	
	spring.Velocity = Vector2.new(newVelocityX, newVelocityY)
	spring.Position = Vector2.new(
		spring.Position.X + spring.Velocity.X * dt,
		spring.Position.Y + spring.Velocity.Y * dt
	)
	
	-- Check if at rest
	local velocityMag = MathUtils.Magnitude(spring.Velocity)
	local displacementMag = MathUtils.Magnitude(spring.Position - spring.Target)
	
	local isAtRest = velocityMag < precision and displacementMag < precision
	
	if isAtRest then
		spring.Position = spring.Target
		spring.Velocity = Vector2.new(0, 0)
		spring.AtRest = true
	end
	
	return spring.AtRest
end

--[=[
    Run spring simulation to completion and return all positions.
    Useful for pre-calculating animation paths.
    
    @param spring SpringState -- Spring to simulate
    @param config SpringConfig -- Spring configuration
    @param maxTime number -- Maximum simulation time
    @param dt number -- Time step
    @return { number } -- Array of positions over time
]=]
function SpringPhysics.Simulate(
	spring: SpringState,
	config: SpringConfig,
	maxTime: number,
	dt: number?
): { number }
	dt = dt or Constants.Timing.SPRING_STEP
	local positions = {}
	local time = 0
	
	-- Clone spring to not modify original
	local simSpring = {
		Position = spring.Position,
		Velocity = spring.Velocity,
		Target = spring.Target,
		AtRest = spring.AtRest,
	}
	
	while time < maxTime and not simSpring.AtRest do
		table.insert(positions, simSpring.Position)
		SpringPhysics.Step(simSpring, config, dt)
		time = time + dt
	end
	
	-- Add final position
	table.insert(positions, simSpring.Target)
	
	return positions
end

--[=[
    Create a spring animator that updates a value smoothly.
    Returns update and destroy functions.
    
    @param initialValue number -- Starting value
    @param config SpringConfig -- Spring configuration
    @param onUpdate function -- Callback with current value
    @return table -- { SetTarget: function, Destroy: function }
]=]
function SpringPhysics.CreateAnimator(
	initialValue: number,
	config: SpringConfig,
	onUpdate: (number) -> ()
): { SetTarget: (number) -> (), Destroy: () -> () }
	local spring = SpringPhysics.Create(initialValue, config)
	local connection: RBXScriptConnection? = nil
	local lastTime = tick()
	
	local function update()
		local currentTime = tick()
		local dt = currentTime - lastTime
		lastTime = currentTime
		
		-- Use fixed time step with accumulator for stability
		local accumulator = dt
		local stepTime = Constants.Timing.SPRING_STEP
		
		while accumulator >= stepTime do
			SpringPhysics.Step(spring, config, stepTime)
			accumulator = accumulator - stepTime
		end
		
		onUpdate(spring.Position)
		
		if spring.AtRest and connection then
			connection:Disconnect()
			connection = nil
		end
	end
	
	return {
		SetTarget = function(target: number)
			SpringPhysics.SetTarget(spring, target)
			
			if not connection then
				lastTime = tick()
				connection = RunService.Heartbeat:Connect(update)
			end
		end,
		
		Destroy = function()
			if connection then
				connection:Disconnect()
				connection = nil
			end
		end,
		
		GetPosition = function(): number
			return spring.Position
		end,
		
		IsAtRest = function(): boolean
			return spring.AtRest
		end,
	}
end

--[=[
    Create a 2D spring animator for mouse following effects.
    
    @param initialPosition Vector2 -- Starting position
    @param config SpringConfig -- Spring configuration
    @param onUpdate function -- Callback with current position
    @return table -- { SetTarget: function, Destroy: function }
]=]
function SpringPhysics.CreateAnimator2D(
	initialPosition: Vector2,
	config: SpringConfig,
	onUpdate: (Vector2) -> ()
): { SetTarget: (Vector2) -> (), Destroy: () -> () }
	local spring = SpringPhysics.Create2D(initialPosition, config)
	local connection: RBXScriptConnection? = nil
	local lastTime = tick()
	
	local function update()
		local currentTime = tick()
		local dt = currentTime - lastTime
		lastTime = currentTime
		
		local accumulator = dt
		local stepTime = Constants.Timing.SPRING_STEP
		
		while accumulator >= stepTime do
			SpringPhysics.Step2D(spring, config, stepTime)
			accumulator = accumulator - stepTime
		end
		
		onUpdate(spring.Position)
		
		if spring.AtRest and connection then
			connection:Disconnect()
			connection = nil
		end
	end
	
	return {
		SetTarget = function(target: Vector2)
			SpringPhysics.SetTarget2D(spring, target)
			
			if not connection then
				lastTime = tick()
				connection = RunService.Heartbeat:Connect(update)
			end
		end,
		
		Destroy = function()
			if connection then
				connection:Disconnect()
				connection = nil
			end
		end,
		
		GetPosition = function(): Vector2
			return spring.Position
		end,
		
		IsAtRest = function(): boolean
			return spring.AtRest
		end,
	}
end

--// ═══════════════════════════════════════════════════════════════════════════════
--// SECTION 9: INSTANCE CREATION UTILITIES
--// ═══════════════════════════════════════════════════════════════════════════════

--[[
    Utility functions for creating and configuring UI instances.
    Provides clean, chainable instance creation.
]]

local InstanceUtils = {}

--[=[
    Create a Frame with common liquid glass properties.
    
    @param properties table -- Frame properties
    @return Frame -- Created frame
]=]
function InstanceUtils.CreateFrame(properties: { [string]: any }?): Frame
	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = Color3.new(1, 1, 1)
	frame.BorderSizePixel = 0
	
	if properties then
		for key, value in pairs(properties) do
			(frame :: any)[key] = value
		end
	end
	
	return frame
end

--[=[
    Create a UICorner with specified radius.
    
    @param radius UDim -- Corner radius
    @return UICorner -- Created corner
]=]
function InstanceUtils.CreateCorner(radius: UDim): UICorner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = radius
	return corner
end

--[=[
    Create a UIStroke for borders.
    
    @param properties table -- Stroke properties
    @return UIStroke -- Created stroke
]=]
function InstanceUtils.CreateStroke(properties: { [string]: any }?): UIStroke
	local stroke = Instance.new("UIStroke")
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Thickness = 1
	
	if properties then
		for key, value in pairs(properties) do
			(stroke :: any)[key] = value
		end
	end
	
	return stroke
end

--[=[
    Create a UIGradient with properties.
    
    @param properties table -- Gradient properties
    @return UIGradient -- Created gradient
]=]
function InstanceUtils.CreateGradient(properties: { [string]: any }?): UIGradient
	local gradient = Instance.new("UIGradient")
	
	if properties then
		for key, value in pairs(properties) do
			(gradient :: any)[key] = value
		end
	end
	
	return gradient
end

--[=[
    Create an ImageLabel for shadow effects.
    
    @param properties table -- ImageLabel properties
    @return ImageLabel -- Created image
]=]
function InstanceUtils.CreateImage(properties: { [string]: any }?): ImageLabel
	local image = Instance.new("ImageLabel")
	image.BackgroundTransparency = 1
	image.BorderSizePixel = 0
	
	if properties then
		for key, value in pairs(properties) do
			(image :: any)[key] = value
		end
	end
	
	return image
end

--[=[
    Apply UICorner to a frame.
    
    @param frame Frame -- Frame to apply corner to
    @param radius UDim -- Corner radius
    @return UICorner -- Applied corner
]=]
function InstanceUtils.ApplyCorner(frame: Frame, radius: UDim): UICorner
	local corner = InstanceUtils.CreateCorner(radius)
	corner.Parent = frame
	return corner
end

--[=[
    Apply UIGradient to a frame.
    
    @param frame Frame -- Frame to apply gradient to
    @param gradient UIGradient -- Gradient to apply
]=]
function InstanceUtils.ApplyGradient(frame: Frame, gradient: UIGradient)
	gradient.Parent = frame
end

--[=[
    Batch set properties on an instance.
    
    @param instance Instance -- Instance to modify
    @param properties table -- Properties to set
]=]
function InstanceUtils.SetProperties(instance: Instance, properties: { [string]: any })
	for key, value in pairs(properties) do
		(instance :: any)[key] = value
	end
end

--[=[
    Create a full-size child frame (fills parent).
    
    @param parent Frame -- Parent frame
    @param name string -- Child name
    @param properties table -- Additional properties
    @return Frame -- Created child frame
]=]
function InstanceUtils.CreateFullSizeChild(
	parent: Frame,
	name: string,
	properties: { [string]: any }?
): Frame
	local child = InstanceUtils.CreateFrame({
		Name = name,
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0, 0),
		BackgroundTransparency = 1,
		Parent = parent,
	})
	
	if properties then
		InstanceUtils.SetProperties(child, properties)
	end
	
	return child
end

--[=[
    Safely destroy an instance and its connections.
    
    @param instance Instance? -- Instance to destroy
]=]
function InstanceUtils.SafeDestroy(instance: Instance?)
	if instance then
		instance:Destroy()
	end
end

--[=[
    Create a container for liquid glass effects.
    
    @param size UDim2 -- Container size
    @param position UDim2 -- Container position
    @param cornerRadius UDim -- Corner radius
    @return Frame, UICorner -- Container and its corner
]=]
function InstanceUtils.CreateGlassContainer(
	size: UDim2,
	position: UDim2?,
	cornerRadius: UDim?
): (Frame, UICorner)
	local container = InstanceUtils.CreateFrame({
		Name = "LiquidGlassContainer",
		Size = size,
		Position = position or UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
	})
	
	local corner = InstanceUtils.CreateCorner(cornerRadius or UDim.new(0, 16))
	corner.Parent = container
	
	return container, corner
end

--// ═══════════════════════════════════════════════════════════════════════════════
--// ╔═══════════════════════════════════════════════════════════════════════════════╗
--// ║                           CHUNK 2: LAYER BUILDERS                             ║
--// ║                                                                               ║
--// ║  This section implements all the visual layer systems that combine to        ║
--// ║  create the complete liquid glass effect. Each layer system is responsible   ║
--// ║  for a specific visual aspect of the glass appearance.                       ║
--// ╚═══════════════════════════════════════════════════════════════════════════════╝
--// ═══════════════════════════════════════════════════════════════════════════════

--// ═══════════════════════════════════════════════════════════════════════════════
--// SECTION 10: FROST LAYER SYSTEM
--// ═══════════════════════════════════════════════════════════════════════════════

--[[
    The Frost Layer System creates the frosted glass effect through multiple
    overlapping semi-transparent layers. This simulates the blur/frost effect
    that cannot be achieved with actual blur in Roblox.
    
    Layer Stack (bottom to top):
    1. Base Glass Tint Layer - Primary colored semi-transparent background
    2. Noise Texture Overlays - Simulate blur grain/noise
    3. Top Glow Gradient - Light from above hitting the glass
    4. Bottom Shadow Gradient - Subtle shadow at bottom edge
    
    The combination creates a convincing frosted glass appearance without
    requiring actual blur shaders.
]]

local FrostLayerBuilder = {}

--[=[
    Create the base glass tint layer.
    This is the foundational layer that gives the glass its color.
    
    @param parent Frame -- Parent container
    @param config FrostConfig -- Frost configuration
    @param cornerRadius UDim -- Corner radius to match parent
    @return Frame -- Created base layer
]=]
function FrostLayerBuilder.CreateBaseTintLayer(
	parent: Frame,
	config: FrostConfig,
	cornerRadius: UDim
): Frame
	local baseTint = InstanceUtils.CreateFrame({
		Name = "FrostBaseTint",
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0, 0),
		BackgroundColor3 = config.Tint,
		BackgroundTransparency = 1 - config.TintOpacity,
		ZIndex = Constants.ZOrder.FrostBase,
		Parent = parent,
	})
	
	-- Apply corner radius
	InstanceUtils.ApplyCorner(baseTint, cornerRadius)
	
	-- Apply subtle gradient for depth
	local tintGradient = GradientUtils.CreateFrostGradient(config.Tint, config.TintOpacity)
	tintGradient.Parent = baseTint
	
	return baseTint
end

--[=[
    Create noise texture overlay layers.
    Multiple overlapping gradient layers simulate the grain/noise of frosted glass.
    Since Roblox doesn't have noise textures, we use rotated gradients.
    
    @param parent Frame -- Parent container
    @param config FrostConfig -- Frost configuration
    @param cornerRadius UDim -- Corner radius to match parent
    @return { Frame } -- Array of noise layers
]=]
function FrostLayerBuilder.CreateNoiseLayers(
	parent: Frame,
	config: FrostConfig,
	cornerRadius: UDim
): { Frame }
	local noiseLayers = {}
	local layerCount = config.Layers or 3
	
	-- Create multiple noise simulation layers at different angles
	local rotations = { 0, 45, 90, 135, 22.5, 67.5 }
	
	for i = 1, layerCount do
		local noiseLayer = InstanceUtils.CreateFrame({
			Name = "FrostNoise_" .. i,
			Size = UDim2.fromScale(1, 1),
			Position = UDim2.fromScale(0, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0,
			ZIndex = Constants.ZOrder.FrostLayers + i,
			Parent = parent,
		})
		
		InstanceUtils.ApplyCorner(noiseLayer, cornerRadius)
		
		-- Create noise-simulating gradient
		-- Each layer has different rotation and offset to create grain pattern
		local rotation = rotations[((i - 1) % #rotations) + 1]
		local scale = config.NoiseScale * (1 + (i - 1) * 0.2)
		
		local noiseGradient = Instance.new("UIGradient")
		
		-- Create multi-stop gradient for noise-like pattern
		local stops = math.min(8, 4 + i)
		local colorKeypoints = {}
		local transparencyKeypoints = {}
		
		for j = 0, stops do
			local position = j / stops
			-- Use seeded random for consistent noise pattern
			local noiseValue = MathUtils.SeededRandom(
				Constants.NoiseTexture.Seed + i * 1000 + j * 100
			)
			
			local brightness = 0.95 + noiseValue * 0.1
			table.insert(colorKeypoints, ColorSequenceKeypoint.new(
				position,
				Color3.new(brightness, brightness, brightness)
			))
			
			-- Varying transparency creates the grain effect
			local baseTransparency = 1 - config.NoiseOpacity
			local transparencyVariation = noiseValue * config.NoiseOpacity * 0.5
			table.insert(transparencyKeypoints, NumberSequenceKeypoint.new(
				position,
				MathUtils.Clamp(baseTransparency + transparencyVariation, 0.5, 1)
			))
		end
		
		noiseGradient.Color = ColorSequence.new(colorKeypoints)
		noiseGradient.Transparency = NumberSequence.new(transparencyKeypoints)
		noiseGradient.Rotation = rotation
		noiseGradient.Parent = noiseLayer
		
		table.insert(noiseLayers, noiseLayer)
	end
	
	return noiseLayers
end

--[=[
    Create the top glow layer.
    Simulates light from above hitting the top edge of the glass.
    
    @param parent Frame -- Parent container
    @param config DepthConfig -- Depth configuration
    @param cornerRadius UDim -- Corner radius to match parent
    @return Frame -- Created glow layer
]=]
function FrostLayerBuilder.CreateTopGlowLayer(
	parent: Frame,
	config: DepthConfig,
	cornerRadius: UDim
): Frame
	local topGlow = InstanceUtils.CreateFrame({
		Name = "FrostTopGlow",
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0, 0),
		BackgroundColor3 = config.TopGlowColor,
		BackgroundTransparency = 0,
		ZIndex = Constants.ZOrder.DepthTop,
		Parent = parent,
	})
	
	InstanceUtils.ApplyCorner(topGlow, cornerRadius)
	
	-- Create top-down gradient that fades out
	local glowSize = config.TopGlowSize / 100 -- Convert pixels to fraction (approximate)
	glowSize = MathUtils.Clamp(glowSize, 0.1, 0.5)
	
	local glowGradient = GradientUtils.CreateTopGlowGradient(
		config.TopGlowColor,
		config.TopGlowOpacity,
		glowSize
	)
	glowGradient.Parent = topGlow
	
	return topGlow
end

--[=[
    Create the bottom shadow layer.
    Adds subtle shadow at the bottom edge for depth.
    
    @param parent Frame -- Parent container
    @param config DepthConfig -- Depth configuration
    @param cornerRadius UDim -- Corner radius to match parent
    @return Frame -- Created shadow layer
]=]
function FrostLayerBuilder.CreateBottomShadowLayer(
	parent: Frame,
	config: DepthConfig,
	cornerRadius: UDim
): Frame
	local bottomShadow = InstanceUtils.CreateFrame({
		Name = "FrostBottomShadow",
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0, 0),
		BackgroundColor3 = config.BottomShadowColor,
		BackgroundTransparency = 0,
		ZIndex = Constants.ZOrder.DepthBottom,
		Parent = parent,
	})
	
	InstanceUtils.ApplyCorner(bottomShadow, cornerRadius)
	
	-- Create bottom-up shadow gradient
	local shadowSize = config.BottomShadowSize / 100
	shadowSize = MathUtils.Clamp(shadowSize, 0.05, 0.3)
	
	local shadowGradient = GradientUtils.CreateBottomShadowGradient(
		config.BottomShadowColor,
		config.BottomShadowOpacity,
		shadowSize
	)
	shadowGradient.Parent = bottomShadow
	
	return bottomShadow
end

--[=[
    Build the complete frost layer system.
    Creates all frost-related layers and returns references.
    
    @param parent Frame -- Parent container
    @param frostConfig FrostConfig -- Frost configuration
    @param depthConfig DepthConfig -- Depth configuration
    @param cornerRadius UDim -- Corner radius to match parent
    @return table -- Layer references
]=]
function FrostLayerBuilder.BuildFrostLayers(
	parent: Frame,
	frostConfig: FrostConfig,
	depthConfig: DepthConfig,
	cornerRadius: UDim
): {
	BaseTint: Frame?,
	NoiseLayers: { Frame },
	TopGlow: Frame?,
	BottomShadow: Frame?,
}
	local layers = {
		BaseTint = nil,
		NoiseLayers = {},
		TopGlow = nil,
		BottomShadow = nil,
	}
	
	if not frostConfig.Enabled then
		return layers
	end
	
	-- Create base tint layer
	layers.BaseTint = FrostLayerBuilder.CreateBaseTintLayer(parent, frostConfig, cornerRadius)
	
	-- Create noise simulation layers
	layers.NoiseLayers = FrostLayerBuilder.CreateNoiseLayers(parent, frostConfig, cornerRadius)
	
	-- Create depth layers if enabled
	if depthConfig.Enabled then
		layers.TopGlow = FrostLayerBuilder.CreateTopGlowLayer(parent, depthConfig, cornerRadius)
		layers.BottomShadow = FrostLayerBuilder.CreateBottomShadowLayer(parent, depthConfig, cornerRadius)
	end
	
	return layers
end

--[=[
    Update frost layer intensity.
    Can be called to animate frost effect on hover.
    
    @param layers table -- Frost layer references
    @param intensity number -- New intensity (0-1)
    @param duration number -- Animation duration
]=]
function FrostLayerBuilder.UpdateIntensity(
	layers: { BaseTint: Frame?, NoiseLayers: { Frame } },
	intensity: number,
	duration: number
)
	local tweenConfig: TweenConfig = {
		Duration = duration,
		Style = Enum.EasingStyle.Quart,
		Direction = Enum.EasingDirection.Out,
	}
	
	-- Update base tint transparency
	if layers.BaseTint then
		local targetTransparency = 1 - (0.15 * intensity)
		AnimationUtils.Tween(layers.BaseTint, {
			BackgroundTransparency = targetTransparency
		}, tweenConfig)
	end
	
	-- Update noise layers
	for i, noiseLayer in ipairs(layers.NoiseLayers) do
		local targetTransparency = 1 - (0.08 * intensity * (1 - (i - 1) * 0.1))
		AnimationUtils.Tween(noiseLayer, {
			BackgroundTransparency = targetTransparency
		}, tweenConfig)
	end
end

--// ═══════════════════════════════════════════════════════════════════════════════
--// SECTION 11: CHROMATIC ABERRATION LAYER SYSTEM
--// ═══════════════════════════════════════════════════════════════════════════════

--[[
    The Chromatic Aberration Layer System creates the signature RGB color
    separation effect at the edges of the glass. This simulates how light
    separates into its component colors when passing through a prism or
    thick glass at an angle.
    
    Implementation:
    - Three edge layers tinted Red, Green, and Blue
    - Each layer has slight position offset from center
    - Transparency gradient makes effect visible only at edges
    - Mouse position dynamically affects the offset amounts
    
    Visual Effect:
    - At edges: Visible rainbow-like color fringing
    - At center: Completely transparent (invisible)
    - On mouse movement: Offsets shift, creating dynamic refraction
]]

local ChromaticLayerBuilder = {}

--[=[
    Create a single chromatic aberration channel layer.
    
    @param parent Frame -- Parent container
    @param channel string -- "Red", "Green", or "Blue"
    @param config ChromaticConfig -- Chromatic configuration
    @param cornerRadius UDim -- Corner radius to match parent
    @return Frame -- Created channel layer
]=]
function ChromaticLayerBuilder.CreateChannelLayer(
	parent: Frame,
	channel: string,
	config: ChromaticConfig,
	cornerRadius: UDim
): Frame
	-- Determine color and offset for this channel
	local color: Color3
	local offset: Vector2
	local zIndex: number
	
	if channel == "Red" then
		color = Constants.Colors.Chromatic.RedAdjusted
		offset = config.RedOffset
		zIndex = Constants.ZOrder.ChromaticRed
	elseif channel == "Green" then
		color = Constants.Colors.Chromatic.GreenAdjusted
		offset = config.GreenOffset
		zIndex = Constants.ZOrder.ChromaticGreen
	else -- Blue
		color = Constants.Colors.Chromatic.BlueAdjusted
		offset = config.BlueOffset
		zIndex = Constants.ZOrder.ChromaticBlue
	end
	
	-- Apply intensity to offset
	offset = Vector2.new(
		offset.X * config.Intensity,
		offset.Y * config.Intensity
	)
	
	local channelLayer = InstanceUtils.CreateFrame({
		Name = "Chromatic" .. channel,
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromOffset(offset.X, offset.Y),
		BackgroundColor3 = color,
		BackgroundTransparency = 0,
		ZIndex = zIndex,
		Parent = parent,
	})
	
	InstanceUtils.ApplyCorner(channelLayer, cornerRadius)
	
	-- Create edge-only transparency gradient
	-- Effect should only be visible at the edges
	if config.EdgeOnly then
		local edgeWidth = 0.15 -- 15% of width for edge zone
		local edgeGradient = GradientUtils.CreateEdgeOnlyGradient(edgeWidth, config.Opacity)
		edgeGradient.Parent = channelLayer
	else
		-- Apply uniform transparency if not edge-only
		channelLayer.BackgroundTransparency = 1 - config.Opacity
	end
	
	return channelLayer
end

--[=[
    Create complete set of chromatic aberration layers.
    
    @param parent Frame -- Parent container
    @param config ChromaticConfig -- Chromatic configuration
    @param cornerRadius UDim -- Corner radius
    @return table -- { Red: Frame, Green: Frame, Blue: Frame }
]=]
function ChromaticLayerBuilder.CreateChromaticLayers(
	parent: Frame,
	config: ChromaticConfig,
	cornerRadius: UDim
): { Red: Frame?, Green: Frame?, Blue: Frame? }
	if not config.Enabled then
		return { Red = nil, Green = nil, Blue = nil }
	end
	
	return {
		Red = ChromaticLayerBuilder.CreateChannelLayer(parent, "Red", config, cornerRadius),
		Green = ChromaticLayerBuilder.CreateChannelLayer(parent, "Green", config, cornerRadius),
		Blue = ChromaticLayerBuilder.CreateChannelLayer(parent, "Blue", config, cornerRadius),
	}
end

--[=[
    Update chromatic aberration offsets based on mouse position.
    This is the key function that makes the effect dynamic.
    
    Formula: Each channel offset = baseOffset * intensity + mouseOffset * multiplier
    
    @param layers table -- Chromatic layer references
    @param mouseOffset Vector2 -- Normalized mouse offset from center (-1 to 1)
    @param config ChromaticConfig -- Chromatic configuration
    @param animate boolean -- Whether to animate the transition
]=]
function ChromaticLayerBuilder.UpdateOffsets(
	layers: { Red: Frame?, Green: Frame?, Blue: Frame? },
	mouseOffset: Vector2,
	config: ChromaticConfig,
	animate: boolean?
)
	if not config.Enabled then
		return
	end
	
	-- Calculate dynamic offsets based on mouse position
	local mouseInfluence = config.Intensity * 1.5
	
	-- Red shifts one way based on mouse
	local redOffset = Vector2.new(
		config.RedOffset.X * config.Intensity + mouseOffset.X * mouseInfluence,
		config.RedOffset.Y * config.Intensity + mouseOffset.Y * mouseInfluence * 0.3
	)
	
	-- Green stays relatively centered
	local greenOffset = Vector2.new(
		config.GreenOffset.X * config.Intensity,
		config.GreenOffset.Y * config.Intensity
	)
	
	-- Blue shifts opposite to red
	local blueOffset = Vector2.new(
		config.BlueOffset.X * config.Intensity - mouseOffset.X * mouseInfluence * 0.5,
		config.BlueOffset.Y * config.Intensity - mouseOffset.Y * mouseInfluence * 0.3
	)
	
	-- Apply offsets
	local function applyOffset(layer: Frame?, offset: Vector2)
		if not layer then return end
		
		local newPosition = UDim2.fromOffset(offset.X, offset.Y)
		
		if animate then
			AnimationUtils.Tween(layer, { Position = newPosition }, {
				Duration = 0.1,
				Style = Enum.EasingStyle.Quad,
				Direction = Enum.EasingDirection.Out,
			})
		else
			layer.Position = newPosition
		end
	end
	
	applyOffset(layers.Red, redOffset)
	applyOffset(layers.Green, greenOffset)
	applyOffset(layers.Blue, blueOffset)
end

--[=[
    Update chromatic layer opacity.
    Used for hover effects to intensify or reduce the aberration.
    
    @param layers table -- Chromatic layer references
    @param opacity number -- New opacity (0-1)
    @param duration number -- Animation duration
]=]
function ChromaticLayerBuilder.UpdateOpacity(
	layers: { Red: Frame?, Green: Frame?, Blue: Frame? },
	opacity: number,
	duration: number
)
	local tweenConfig: TweenConfig = {
		Duration = duration,
		Style = Enum.EasingStyle.Quart,
		Direction = Enum.EasingDirection.Out,
	}
	
	for _, layer in pairs(layers) do
		if layer then
			-- Update the gradient transparency
			local gradient = layer:FindFirstChildOfClass("UIGradient")
			if gradient then
				-- Recreate transparency sequence with new opacity
				local edgeWidth = 0.15
				gradient.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1 - opacity),
					NumberSequenceKeypoint.new(edgeWidth, 1),
					NumberSequenceKeypoint.new(1 - edgeWidth, 1),
					NumberSequenceKeypoint.new(1, 1 - opacity),
				})
			end
		end
	end
end

--// ═══════════════════════════════════════════════════════════════════════════════
--// SECTION 12: REFRACTION/DISTORTION LAYER SYSTEM
--// ═══════════════════════════════════════════════════════════════════════════════

--[[
    The Refraction Layer System simulates light bending at the edges of thick
    glass. This creates the visual effect of content behind the glass being
    slightly displaced at the edges.
    
    Implementation:
    - Four edge bands (top, bottom, left, right)
    - Each band has multiple offset layers for distortion depth
    - Gradient transparency makes distortion fade toward center
    - Creates the illusion of edge bending/warping
    
    Note: True refraction requires shaders (not available in Roblox).
    This system creates a convincing approximation using layered offsets.
]]

local RefractionLayerBuilder = {}

--[=[
    Create a single edge refraction band.
    
    @param parent Frame -- Parent container
    @param edge string -- "Top", "Bottom", "Left", or "Right"
    @param layerIndex number -- Layer depth index (1 = closest to edge)
    @param config RefractionConfig -- Refraction configuration
    @param cornerRadius UDim -- Corner radius
    @return Frame -- Created refraction layer
]=]
function RefractionLayerBuilder.CreateEdgeRefractionLayer(
	parent: Frame,
	edge: string,
	layerIndex: number,
	config: RefractionConfig,
	cornerRadius: UDim
): Frame
	local edgeWidth = config.EdgeWidth
	local intensity = config.Intensity
	local falloff = config.FalloffExponent
	
	-- Calculate layer offset based on index (deeper layers have less offset)
	local depthFactor = 1 - ((layerIndex - 1) / config.Layers)
	local offsetAmount = intensity * depthFactor ^ falloff
	
	-- Calculate size and position based on edge
	local size: UDim2
	local position: UDim2
	local gradientRotation: number
	
	if edge == "Top" then
		size = UDim2.new(1, 0, 0, edgeWidth)
		position = UDim2.new(0, 0, 0, -offsetAmount * layerIndex * 0.1)
		gradientRotation = 180 -- Gradient from top (visible) to bottom (invisible)
	elseif edge == "Bottom" then
		size = UDim2.new(1, 0, 0, edgeWidth)
		position = UDim2.new(0, 0, 1, -edgeWidth + offsetAmount * layerIndex * 0.1)
		gradientRotation = 0 -- Gradient from bottom (visible) to top (invisible)
	elseif edge == "Left" then
		size = UDim2.new(0, edgeWidth, 1, 0)
		position = UDim2.new(0, -offsetAmount * layerIndex * 0.1, 0, 0)
		gradientRotation = 90 -- Gradient from left (visible) to right (invisible)
	else -- Right
		size = UDim2.new(0, edgeWidth, 1, 0)
		position = UDim2.new(1, -edgeWidth + offsetAmount * layerIndex * 0.1, 0, 0)
		gradientRotation = 270 -- Gradient from right (visible) to left (invisible)
	end
	
	local refractionLayer = InstanceUtils.CreateFrame({
		Name = "Refraction" .. edge .. "_" .. layerIndex,
		Size = size,
		Position = position,
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0,
		ZIndex = Constants.ZOrder.RefractionBase + layerIndex,
		ClipsDescendants = true,
		Parent = parent,
	})
	
	-- Apply corner radius only to relevant corners
	local corner = Instance.new("UICorner")
	corner.CornerRadius = cornerRadius
	corner.Parent = refractionLayer
	
	-- Create fade gradient - visible at edge, invisible toward center
	local opacity = 0.05 * depthFactor -- Very subtle effect
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new(Color3.new(1, 1, 1))
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1 - opacity),
		NumberSequenceKeypoint.new(1, 1),
	})
	gradient.Rotation = gradientRotation
	gradient.Parent = refractionLayer
	
	return refractionLayer
end

--[=[
    Build all refraction layers for all four edges.
    
    @param parent Frame -- Parent container
    @param config RefractionConfig -- Refraction configuration
    @param cornerRadius UDim -- Corner radius
    @return table -- { Top: { Frame }, Bottom: { Frame }, Left: { Frame }, Right: { Frame } }
]=]
function RefractionLayerBuilder.BuildRefractionLayers(
	parent: Frame,
	config: RefractionConfig,
	cornerRadius: UDim
): { Top: { Frame }, Bottom: { Frame }, Left: { Frame }, Right: { Frame } }
	local layers = {
		Top = {},
		Bottom = {},
		Left = {},
		Right = {},
	}
	
	if not config.Enabled then
		return layers
	end
	
	-- Create refraction layers for each edge
	for _, edge in ipairs({"Top", "Bottom", "Left", "Right"}) do
		for i = 1, config.Layers do
			local layer = RefractionLayerBuilder.CreateEdgeRefractionLayer(
				parent,
				edge,
				i,
				config,
				cornerRadius
			)
			table.insert(layers[edge], layer)
		end
	end
	
	return layers
end

--[=[
    Update refraction intensity based on mouse position.
    Makes the refraction effect respond to cursor movement.
    
    @param layers table -- Refraction layer references
    @param mouseOffset Vector2 -- Normalized mouse offset (-1 to 1)
    @param config RefractionConfig -- Refraction configuration
]=]
function RefractionLayerBuilder.UpdateRefraction(
	layers: { Top: { Frame }, Bottom: { Frame }, Left: { Frame }, Right: { Frame } },
	mouseOffset: Vector2,
	config: RefractionConfig
)
	if not config.Enabled then
		return
	end
	
	-- Adjust refraction based on mouse position
	-- When mouse is near an edge, intensify that edge's refraction
	
	local function updateEdgeLayers(edgeLayers: { Frame }, edgeIntensity: number)
		for i, layer in ipairs(edgeLayers) do
			local gradient = layer:FindFirstChildOfClass("UIGradient")
			if gradient then
				local baseOpacity = 0.05 * (1 - ((i - 1) / #edgeLayers))
				local adjustedOpacity = baseOpacity * (1 + edgeIntensity * 0.5)
				gradient.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1 - adjustedOpacity),
					NumberSequenceKeypoint.new(1, 1),
				})
			end
		end
	end
	
	-- Calculate edge intensities based on mouse position
	local topIntensity = math.max(0, -mouseOffset.Y)    -- More intense when mouse is at top
	local bottomIntensity = math.max(0, mouseOffset.Y)  -- More intense when mouse is at bottom
	local leftIntensity = math.max(0, -mouseOffset.X)   -- More intense when mouse is at left
	local rightIntensity = math.max(0, mouseOffset.X)   -- More intense when mouse is at right
	
	updateEdgeLayers(layers.Top, topIntensity)
	updateEdgeLayers(layers.Bottom, bottomIntensity)
	updateEdgeLayers(layers.Left, leftIntensity)
	updateEdgeLayers(layers.Right, rightIntensity)
end

--// ═══════════════════════════════════════════════════════════════════════════════
--// SECTION 13: DYNAMIC BORDER SYSTEM
--// ═══════════════════════════════════════════════════════════════════════════════

--[[
    The Border System creates the reflective, dynamic gradient border that is
    a key visual element of liquid glass design. The border responds to mouse
    movement, creating the illusion of light reflecting off the glass edge.
    
    Implementation:
    - Primary border using UIStroke with UIGradient
    - Secondary inner border for depth
    - Gradient rotation updates based on mouse position
    
    Key Formula: rotation = baseRotation + mouseOffset.X * mouseInfluence
    Default: rotation = 135 + mouseOffset.X * 1.2 * 30
]]

local BorderLayerBuilder = {}

--[=[
    Create the primary gradient border.
    This is the main reflective border that responds to mouse movement.
    
    @param parent Frame -- Parent container
    @param config BorderGradientConfig -- Border configuration
    @return Frame, UIStroke, UIGradient -- Border frame and its components
]=]
function BorderLayerBuilder.CreatePrimaryBorder(
	parent: Frame,
	config: BorderGradientConfig
): (Frame, UIStroke, UIGradient)
	-- Create a frame specifically for the border
	local borderFrame = InstanceUtils.CreateFrame({
		Name = "BorderFrame",
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0, 0),
		BackgroundTransparency = 1,
		ZIndex = Constants.ZOrder.Border,
		Parent = parent,
	})
	
	-- Create UIStroke for the border
	local stroke = InstanceUtils.CreateStroke({
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Thickness = config.Thickness,
		Color = Color3.new(1, 1, 1), -- Will be overridden by gradient
		Transparency = 0,
		Parent = borderFrame,
	})
	
	-- Create the dynamic gradient
	local gradient = GradientUtils.CreateDynamicBorderGradient(config)
	gradient.Parent = stroke
	
	-- Apply corner to match parent
	local existingCorner = parent:FindFirstChildOfClass("UICorner")
	if existingCorner then
		local borderCorner = Instance.new("UICorner")
		borderCorner.CornerRadius = existingCorner.CornerRadius
		borderCorner.Parent = borderFrame
	end
	
	return borderFrame, stroke, gradient
end

--[=[
    Create a secondary inner border for additional depth.
    This creates a subtle inner glow/highlight effect.
    
    @param parent Frame -- Parent container
    @param config BorderGradientConfig -- Border configuration
    @return Frame, UIStroke -- Secondary border and stroke
]=]
function BorderLayerBuilder.CreateSecondaryBorder(
	parent: Frame,
	config: BorderGradientConfig
): (Frame, UIStroke)
	local secondaryFrame = InstanceUtils.CreateFrame({
		Name = "SecondaryBorder",
		Size = UDim2.new(1, -4, 1, -4), -- Slightly inset
		Position = UDim2.fromOffset(2, 2),
		BackgroundTransparency = 1,
		ZIndex = Constants.ZOrder.Border - 1,
		Parent = parent,
	})
	
	local secondaryStroke = InstanceUtils.CreateStroke({
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Thickness = config.Thickness * 0.5,
		Color = Color3.new(1, 1, 1),
		Transparency = 0.85, -- Very subtle
		Parent = secondaryFrame,
	})
	
	-- Apply corner
	local existingCorner = parent:FindFirstChildOfClass("UICorner")
	if existingCorner then
		local borderCorner = Instance.new("UICorner")
		borderCorner.CornerRadius = UDim.new(
			existingCorner.CornerRadius.Scale,
			math.max(0, existingCorner.CornerRadius.Offset - 2)
		)
		borderCorner.Parent = secondaryFrame
	end
	
	return secondaryFrame, secondaryStroke
end

--[=[
    Build the complete border system.
    
    @param parent Frame -- Parent container
    @param config BorderGradientConfig -- Border configuration
    @return table -- Border layer references
]=]
function BorderLayerBuilder.BuildBorderLayers(
	parent: Frame,
	config: BorderGradientConfig
): {
	PrimaryFrame: Frame?,
	PrimaryStroke: UIStroke?,
	PrimaryGradient: UIGradient?,
	SecondaryFrame: Frame?,
	SecondaryStroke: UIStroke?,
}
	local layers = {
		PrimaryFrame = nil,
		PrimaryStroke = nil,
		PrimaryGradient = nil,
		SecondaryFrame = nil,
		SecondaryStroke = nil,
	}
	
	if not config.Enabled then
		return layers
	end
	
	-- Create primary border
	layers.PrimaryFrame, layers.PrimaryStroke, layers.PrimaryGradient = 
		BorderLayerBuilder.CreatePrimaryBorder(parent, config)
	
	-- Create secondary border
	layers.SecondaryFrame, layers.SecondaryStroke = 
		BorderLayerBuilder.CreateSecondaryBorder(parent, config)
	
	return layers
end

--[=[
    Update border gradient rotation based on mouse position.
    This is the key function that creates the dynamic reflection effect.
    
    @param gradient UIGradient -- The border gradient to update
    @param mouseOffset Vector2 -- Normalized mouse offset (-1 to 1)
    @param config BorderGradientConfig -- Border configuration
    @param animate boolean -- Whether to animate the rotation
]=]
function BorderLayerBuilder.UpdateGradientRotation(
	gradient: UIGradient?,
	mouseOffset: Vector2,
	config: BorderGradientConfig,
	animate: boolean?
)
	if not gradient then
		return
	end
	
	-- Calculate new rotation
	-- Formula: baseRotation + mouseOffset.X * mouseInfluence * 30
	local newRotation = config.BaseRotation + mouseOffset.X * config.MouseInfluence * 30
	
	-- Add subtle Y influence for more organic feel
	newRotation = newRotation + mouseOffset.Y * config.MouseInfluence * 10
	
	if animate then
		-- Use TweenService for smooth animation
		local tweenInfo = TweenInfo.new(
			0.15 / config.AnimationSpeed,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		)
		local tween = TweenService:Create(gradient, tweenInfo, {
			Rotation = newRotation
		})
		tween:Play()
	else
		gradient.Rotation = newRotation
	end
end

--[=[
    Update border opacity for hover effects.
    
    @param stroke UIStroke -- The border stroke
    @param opacity number -- New opacity (0-1)
    @param duration number -- Animation duration
]=]
function BorderLayerBuilder.UpdateBorderOpacity(
	stroke: UIStroke?,
	opacity: number,
	duration: number
)
	if not stroke then
		return
	end
	
	AnimationUtils.Tween(stroke, {
		Transparency = 1 - opacity
	}, {
		Duration = duration,
		Style = Enum.EasingStyle.Quart,
		Direction = Enum.EasingDirection.Out,
	})
end

--// ═══════════════════════════════════════════════════════════════════════════════
--// SECTION 14: SHADOW SYSTEM
--// ═══════════════════════════════════════════════════════════════════════════════

--[[
    The Shadow System creates a soft drop shadow behind the glass element.
    This adds depth and helps the glass component stand out from the background.
    
    Implementation:
    - Shadow frame positioned behind the main glass
    - Uses offset and scaling for shadow spread
    - Gradient for soft edges
    - Can animate shadow intensity on hover
]]

local ShadowLayerBuilder = {}

--[=[
    Create the drop shadow layer.
    
    @param parent Frame -- Parent container (shadow will be sibling, not child)
    @param config ShadowConfig -- Shadow configuration
    @param cornerRadius UDim -- Corner radius to match parent
    @return Frame -- Created shadow frame
]=]
function ShadowLayerBuilder.CreateShadowLayer(
	parent: Frame,
	config: ShadowConfig,
	cornerRadius: UDim
): Frame
	-- Shadow should be a sibling of the glass container, positioned behind it
	-- For now, we create it as a child with negative z-index
	
	local shadowFrame = InstanceUtils.CreateFrame({
		Name = "DropShadow",
		Size = UDim2.new(1, config.Spread * 2, 1, config.Spread * 2),
		Position = UDim2.new(0.5, config.Offset.X, 0.5, config.Offset.Y),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = config.Color,
		BackgroundTransparency = config.Transparency,
		ZIndex = Constants.ZOrder.Shadow,
		Parent = parent,
	})
	
	-- Apply larger corner radius for softer shadow
	local shadowRadius = UDim.new(
		cornerRadius.Scale,
		cornerRadius.Offset + config.Blur * 0.3
	)
	InstanceUtils.ApplyCorner(shadowFrame, shadowRadius)
	
	-- Create soft edge gradient for blur simulation
	-- We'll create multiple overlapping layers for softer effect
	local blurLayers = math.min(4, math.ceil(config.Blur / 10))
	
	for i = 1, blurLayers do
		local blurLayer = InstanceUtils.CreateFrame({
			Name = "ShadowBlur_" .. i,
			Size = UDim2.new(1, i * 4, 1, i * 4),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = config.Color,
			BackgroundTransparency = config.Transparency + i * 0.1,
			ZIndex = Constants.ZOrder.Shadow - i,
			Parent = shadowFrame,
		})
		
		local blurRadius = UDim.new(
			shadowRadius.Scale,
			shadowRadius.Offset + i * 2
		)
		InstanceUtils.ApplyCorner(blurLayer, blurRadius)
	end
	
	return shadowFrame
end

--[=[
    Build shadow system.
    
    @param parent Frame -- Parent container
    @param config ShadowConfig -- Shadow configuration
    @param cornerRadius UDim -- Corner radius
    @return Frame? -- Shadow frame or nil if disabled
]=]
function ShadowLayerBuilder.BuildShadowLayer(
	parent: Frame,
	config: ShadowConfig,
	cornerRadius: UDim
): Frame?
	if not config.Enabled then
		return nil
	end
	
	return ShadowLayerBuilder.CreateShadowLayer(parent, config, cornerRadius)
end

--[=[
    Update shadow for hover effect.
    Typically shadow grows/lifts on hover.
    
    @param shadow Frame -- Shadow frame
    @param config ShadowConfig -- Shadow configuration
    @param isHovered boolean -- Whether element is hovered
    @param duration number -- Animation duration
]=]
function ShadowLayerBuilder.UpdateShadowOnHover(
	shadow: Frame?,
	config: ShadowConfig,
	isHovered: boolean,
	duration: number
)
	if not shadow then
		return
	end
	
	local tweenConfig: TweenConfig = {
		Duration = duration,
		Style = Enum.EasingStyle.Quart,
		Direction = Enum.EasingDirection.Out,
	}
	
	if isHovered then
		-- Expand and darken shadow slightly
		AnimationUtils.Tween(shadow, {
			Size = UDim2.new(1, config.Spread * 2.5, 1, config.Spread * 2.5),
			Position = UDim2.new(0.5, config.Offset.X, 0.5, config.Offset.Y + 4),
			BackgroundTransparency = config.Transparency * 0.9,
		}, tweenConfig)
	else
		-- Return to normal
		AnimationUtils.Tween(shadow, {
			Size = UDim2.new(1, config.Spread * 2, 1, config.Spread * 2),
			Position = UDim2.new(0.5, config.Offset.X, 0.5, config.Offset.Y),
			BackgroundTransparency = config.Transparency,
		}, tweenConfig)
	end
end

--// ═══════════════════════════════════════════════════════════════════════════════
--// SECTION 15: HOVER EFFECT LAYERS
--// ═══════════════════════════════════════════════════════════════════════════════

--[[
    The Hover Effect Layer System creates interactive visual feedback when
    users hover over or press the glass element. This includes:
    
    - Radial glow that follows the mouse cursor
    - Press state darkening/highlighting
    - Subtle scale animations
    - Glow intensity changes
    
    These layers are typically hidden and animated in/out on interaction.
]]

local HoverLayerBuilder = {}

--[=[
    Create a radial hover glow layer.
    This glow follows the mouse cursor position.
    
    @param parent Frame -- Parent container
    @param glowColor Color3 -- Color of the glow
    @param maxOpacity number -- Maximum opacity of glow
    @param cornerRadius UDim -- Corner radius to match parent
    @return Frame -- Created glow layer
]=]
function HoverLayerBuilder.CreateHoverGlowLayer(
	parent: Frame,
	glowColor: Color3,
	maxOpacity: number,
	cornerRadius: UDim
): Frame
	local glowLayer = InstanceUtils.CreateFrame({
		Name = "HoverGlow",
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0, 0),
		BackgroundColor3 = glowColor,
		BackgroundTransparency = 1, -- Start hidden
		ZIndex = Constants.ZOrder.InnerGlow,
		Parent = parent,
	})
	
	InstanceUtils.ApplyCorner(glowLayer, cornerRadius)
	
	-- Create radial-style gradient (center brighter)
	local glowGradient = GradientUtils.CreateRadialGradient(
		glowColor,
		glowColor,
		1, -- Center transparent initially
		1  -- Edge transparent
	)
	glowGradient.Parent = glowLayer
	
	-- Store max opacity for later use
	glowLayer:SetAttribute("MaxOpacity", maxOpacity)
	
	return glowLayer
end

--[=[
    Create a press state overlay.
    Shows a subtle darkening when the element is pressed.
    
    @param parent Frame -- Parent container
    @param cornerRadius UDim -- Corner radius to match parent
    @return Frame -- Created press layer
]=]
function HoverLayerBuilder.CreatePressOverlay(
	parent: Frame,
	cornerRadius: UDim
): Frame
	local pressLayer = InstanceUtils.CreateFrame({
		Name = "PressOverlay",
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0, 0),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 1, -- Start hidden
		ZIndex = Constants.ZOrder.InnerGlow + 1,
		Parent = parent,
	})
	
	InstanceUtils.ApplyCorner(pressLayer, cornerRadius)
	
	return pressLayer
end

--[=[
    Build hover effect layers.
    
    @param parent Frame -- Parent container
    @param glowColor Color3 -- Glow color
    @param glowOpacity number -- Glow max opacity
    @param cornerRadius UDim -- Corner radius
    @return table -- { HoverGlow: Frame?, PressOverlay: Frame? }
]=]
function HoverLayerBuilder.BuildHoverLayers(
	parent: Frame,
	glowColor: Color3,
	glowOpacity: number,
	cornerRadius: UDim
): { HoverGlow: Frame?, PressOverlay: Frame? }
	return {
		HoverGlow = HoverLayerBuilder.CreateHoverGlowLayer(parent, glowColor, glowOpacity, cornerRadius),
		PressOverlay = HoverLayerBuilder.CreatePressOverlay(parent, cornerRadius),
	}
end

--[=[
    Update hover glow position and visibility.
    
    @param glow Frame -- Glow layer
    @param mouseOffset Vector2 -- Normalized mouse offset (-1 to 1)
    @param isVisible boolean -- Whether glow should be visible
    @param duration number -- Animation duration
]=]
function HoverLayerBuilder.UpdateHoverGlow(
	glow: Frame?,
	mouseOffset: Vector2,
	isVisible: boolean,
	duration: number
)
	if not glow then
		return
	end
	
	local gradient = glow:FindFirstChildOfClass("UIGradient")
	if not gradient then
		return
	end
	
	local maxOpacity = glow:GetAttribute("MaxOpacity") or 0.15
	
	if isVisible then
		-- Update gradient offset to follow mouse
		-- Gradient offset moves center of radial glow
		local offsetX = mouseOffset.X * 0.3
		local offsetY = mouseOffset.Y * 0.3
		gradient.Offset = Vector2.new(offsetX, offsetY)
		
		-- Fade in
		gradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1 - maxOpacity),
			NumberSequenceKeypoint.new(0.5, 1 - maxOpacity * 0.5),
			NumberSequenceKeypoint.new(1, 1),
		})
	else
		-- Fade out
		gradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 1),
		})
	end
end

--[=[
    Show/hide press overlay.
    
    @param pressOverlay Frame -- Press overlay layer
    @param isPressed boolean -- Whether element is pressed
    @param duration number -- Animation duration
]=]
function HoverLayerBuilder.UpdatePressState(
	pressOverlay: Frame?,
	isPressed: boolean,
	duration: number
)
	if not pressOverlay then
		return
	end
	
	local targetTransparency = isPressed and 0.9 or 1
	
	AnimationUtils.Tween(pressOverlay, {
		BackgroundTransparency = targetTransparency
	}, {
		Duration = duration,
		Style = Enum.EasingStyle.Quart,
		Direction = Enum.EasingDirection.Out,
	})
end

--// ═══════════════════════════════════════════════════════════════════════════════
--// SECTION 16: CONTENT CONTAINER & INPUT HANDLER
--// ═══════════════════════════════════════════════════════════════════════════════

--[[
    The Content Container and Input Handler systems manage the interactive
    aspects of the liquid glass component.
    
    Content Container:
    - Holds all user content (text, images, etc.)
    - Clips content to glass bounds
    - Applies elastic following animation
    
    Input Handler:
    - Invisible button that captures mouse events
    - Tracks mouse position within the element
    - Dispatches events to effect layers
]]

local ContentContainerBuilder = {}

--[=[
    Create the content container frame.
    This frame holds all user-added content and handles clipping.
    
    @param parent Frame -- Parent container
    @param cornerRadius UDim -- Corner radius to match parent
    @return Frame -- Created content container
]=]
function ContentContainerBuilder.CreateContentContainer(
	parent: Frame,
	cornerRadius: UDim
): Frame
	local container = InstanceUtils.CreateFrame({
		Name = "ContentContainer",
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		ZIndex = Constants.ZOrder.ContentContainer,
		Parent = parent,
	})
	
	InstanceUtils.ApplyCorner(container, cornerRadius)
	
	-- Add padding for content
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 8)
	padding.PaddingBottom = UDim.new(0, 8)
	padding.PaddingLeft = UDim.new(0, 12)
	padding.PaddingRight = UDim.new(0, 12)
	padding.Parent = container
	
	return container
end

--[=[
    Update content container position for elastic follow effect.
    Content slightly follows the mouse for depth illusion.
    
    @param container Frame -- Content container
    @param offset Vector2 -- Target offset from center
    @param intensity number -- How much to follow (0-20 pixels typically)
    @param animate boolean -- Whether to animate
]=]
function ContentContainerBuilder.UpdateContentOffset(
	container: Frame?,
	offset: Vector2,
	intensity: number,
	animate: boolean?
)
	if not container then
		return
	end
	
	-- Calculate position offset
	local offsetX = offset.X * intensity
	local offsetY = offset.Y * intensity
	
	local newPosition = UDim2.new(0.5, offsetX, 0.5, offsetY)
	
	if animate then
		AnimationUtils.Tween(container, {
			Position = newPosition
		}, {
			Duration = 0.2,
			Style = Enum.EasingStyle.Quart,
			Direction = Enum.EasingDirection.Out,
		})
	else
		container.Position = newPosition
	end
end

local InputHandlerBuilder = {}

--[=[
    Create an invisible input handler button.
    This captures all mouse interactions for the glass element.
    
    @param parent Frame -- Parent container
    @return TextButton -- Created input handler
]=]
function InputHandlerBuilder.CreateInputHandler(
	parent: Frame
): TextButton
	local handler = Instance.new("TextButton")
	handler.Name = "InputHandler"
	handler.Size = UDim2.fromScale(1, 1)
	handler.Position = UDim2.fromScale(0, 0)
	handler.BackgroundTransparency = 1
	handler.Text = ""
	handler.AutoButtonColor = false
	handler.ZIndex = Constants.ZOrder.ContentContainer + 100 -- Above everything
	handler.Parent = parent
	
	return handler
end

--[=[
    Set up mouse tracking for the input handler.
    Returns a table with connection management.
    
    @param handler TextButton -- Input handler button
    @param callbacks table -- Event callbacks
    @return table -- { Connections: { RBXScriptConnection }, Destroy: function }
]=]
function InputHandlerBuilder.SetupMouseTracking(
	handler: TextButton,
	callbacks: {
		OnMouseMove: ((position: Vector2, offset: Vector2) -> ())?,
		OnMouseEnter: (() -> ())?,
		OnMouseLeave: (() -> ())?,
		OnMouseDown: ((position: Vector2) -> ())?,
		OnMouseUp: ((position: Vector2) -> ())?,
	}
): { Connections: { RBXScriptConnection }, Destroy: () -> () }
	local connections: { RBXScriptConnection } = {}
	local isTracking = false
	local trackingConnection: RBXScriptConnection? = nil
	
	-- Helper to get normalized offset from mouse position
	local function getNormalizedOffset(inputPosition: Vector3): Vector2
		local absolutePosition = handler.AbsolutePosition
		local absoluteSize = handler.AbsoluteSize
		
		local localX = inputPosition.X - absolutePosition.X
		local localY = inputPosition.Y - absolutePosition.Y
		
		return MathUtils.GetNormalizedOffset(
			Vector2.new(localX, localY),
			absoluteSize
		)
	end
	
	-- Mouse enter
	table.insert(connections, handler.MouseEnter:Connect(function()
		isTracking = true
		
		if callbacks.OnMouseEnter then
			callbacks.OnMouseEnter()
		end
		
		-- Start tracking mouse movement
		if not trackingConnection then
			trackingConnection = RunService.RenderStepped:Connect(function()
				if not isTracking then
					return
				end
				
				local mousePos = UserInputService:GetMouseLocation()
				local absolutePosition = handler.AbsolutePosition
				local absoluteSize = handler.AbsoluteSize
				
				-- Check if mouse is within bounds
				local localX = mousePos.X - absolutePosition.X
				local localY = mousePos.Y - absolutePosition.Y
				
				if localX >= 0 and localX <= absoluteSize.X and
				   localY >= 0 and localY <= absoluteSize.Y then
					local offset = MathUtils.GetNormalizedOffset(
						Vector2.new(localX, localY),
						absoluteSize
					)
					
					if callbacks.OnMouseMove then
						callbacks.OnMouseMove(mousePos, offset)
					end
				end
			end)
		end
	end))
	
	-- Mouse leave
	table.insert(connections, handler.MouseLeave:Connect(function()
		isTracking = false
		
		if callbacks.OnMouseLeave then
			callbacks.OnMouseLeave()
		end
		
		-- Stop tracking
		if trackingConnection then
			trackingConnection:Disconnect()
			trackingConnection = nil
		end
	end))
	
	-- Mouse down
	table.insert(connections, handler.MouseButton1Down:Connect(function()
		local mousePos = UserInputService:GetMouseLocation()
		
		if callbacks.OnMouseDown then
			callbacks.OnMouseDown(mousePos)
		end
	end))
	
	-- Mouse up
	table.insert(connections, handler.MouseButton1Up:Connect(function()
		local mousePos = UserInputService:GetMouseLocation()
		
		if callbacks.OnMouseUp then
			callbacks.OnMouseUp(mousePos)
		end
	end))
	
	-- Return connection manager
	return {
		Connections = connections,
		
		Destroy = function()
			for _, conn in ipairs(connections) do
				conn:Disconnect()
			end
			
			if trackingConnection then
				trackingConnection:Disconnect()
				trackingConnection = nil
			end
		end,
	}
end

--// ═══════════════════════════════════════════════════════════════════════════════
--// SECTION 17: INNER GLOW LAYER
--// ═══════════════════════════════════════════════════════════════════════════════

--[[
    The Inner Glow Layer adds a subtle luminous effect around the inner edges
    of the glass element. This enhances the glass appearance by simulating
    light scattering within the glass material.
]]

local InnerGlowLayerBuilder = {}

--[=[
    Create the inner glow layer.
    
    @param parent Frame -- Parent container
    @param config DepthConfig -- Depth configuration
    @param cornerRadius UDim -- Corner radius to match parent
    @return Frame -- Created inner glow layer
]=]
function InnerGlowLayerBuilder.CreateInnerGlow(
	parent: Frame,
	config: DepthConfig,
	cornerRadius: UDim
): Frame
	local innerGlow = InstanceUtils.CreateFrame({
		Name = "InnerGlow",
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0, 0),
		BackgroundColor3 = config.InnerGlowColor,
		BackgroundTransparency = 0,
		ZIndex = Constants.ZOrder.InnerGlow,
		Parent = parent,
	})
	
	InstanceUtils.ApplyCorner(innerGlow, cornerRadius)
	
	-- Create inner edge glow gradient
	local glowGradient = GradientUtils.CreateInnerGlowGradient(
		config.InnerGlowColor,
		config.InnerGlowOpacity
	)
	glowGradient.Parent = innerGlow
	
	return innerGlow
end

--[=[
    Update inner glow intensity.
    
    @param innerGlow Frame -- Inner glow layer
    @param intensity number -- New intensity multiplier
    @param duration number -- Animation duration
]=]
function InnerGlowLayerBuilder.UpdateIntensity(
	innerGlow: Frame?,
	intensity: number,
	duration: number
)
	if not innerGlow then
		return
	end
	
	local gradient = innerGlow:FindFirstChildOfClass("UIGradient")
	if gradient then
		local baseOpacity = innerGlow:GetAttribute("BaseOpacity") or 0.05
		local newOpacity = baseOpacity * intensity
		
		gradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1 - newOpacity),
			NumberSequenceKeypoint.new(0.3, 1),
			NumberSequenceKeypoint.new(0.7, 1),
			NumberSequenceKeypoint.new(1, 1 - newOpacity),
		})
	end
end

--// ═══════════════════════════════════════════════════════════════════════════════
--// SECTION 18: BACKGROUND LAYER
--// ═══════════════════════════════════════════════════════════════════════════════

--[[
    The Background Layer provides the base visual layer of the glass element.
    It supports solid colors, gradients, and transparency settings.
]]

local BackgroundLayerBuilder = {}

--[=[
    Create the background layer.
    
    @param parent Frame -- Parent container
    @param config BackgroundConfig -- Background configuration
    @param cornerRadius UDim -- Corner radius to match parent
    @return Frame -- Created background layer
]=]
function BackgroundLayerBuilder.CreateBackground(
	parent: Frame,
	config: BackgroundConfig,
	cornerRadius: UDim
): Frame
	local background = InstanceUtils.CreateFrame({
		Name = "Background",
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0, 0),
		BackgroundColor3 = config.Color,
		BackgroundTransparency = config.Transparency,
		ZIndex = Constants.ZOrder.Background,
		Parent = parent,
	})
	
	InstanceUtils.ApplyCorner(background, cornerRadius)
	
	-- Apply gradient if enabled
	if config.GradientEnabled and config.GradientColors then
		local gradient = GradientUtils.CreateLinearGradient(
			config.GradientColors,
			config.GradientRotation
		)
		gradient.Parent = background
	end
	
	return background
end

--// ═══════════════════════════════════════════════════════════════════════════════
--// SECTION 19: COMPLETE LAYER BUILDER
--// ═══════════════════════════════════════════════════════════════════════════════

--[[
    The Complete Layer Builder orchestrates the creation of all layer systems
    to build a fully functional liquid glass element.
]]

local LayerBuilder = {}

--[=[
    Layer reference structure type.
    Contains references to all created layers for later manipulation.
]=]
export type CompleteLayerRefs = {
	-- Root container
	Root: Frame,
	
	-- Shadow
	Shadow: Frame?,
	
	-- Background
	Background: Frame?,
	
	-- Frost layers
	FrostLayers: {
		BaseTint: Frame?,
		NoiseLayers: { Frame },
		TopGlow: Frame?,
		BottomShadow: Frame?,
	},
	
	-- Chromatic aberration
	ChromaticLayers: {
		Red: Frame?,
		Green: Frame?,
		Blue: Frame?,
	},
	
	-- Refraction
	RefractionLayers: {
		Top: { Frame },
		Bottom: { Frame },
		Left: { Frame },
		Right: { Frame },
	},
	
	-- Border
	BorderLayers: {
		PrimaryFrame: Frame?,
		PrimaryStroke: UIStroke?,
		PrimaryGradient: UIGradient?,
		SecondaryFrame: Frame?,
		SecondaryStroke: UIStroke?,
	},
	
	-- Inner glow
	InnerGlow: Frame?,
	
	-- Hover effects
	HoverLayers: {
		HoverGlow: Frame?,
		PressOverlay: Frame?,
	},
	
	-- Content and input
	ContentContainer: Frame?,
	InputHandler: TextButton?,
	
	-- Input tracking
	InputTracking: {
		Connections: { RBXScriptConnection },
		Destroy: () -> (),
	}?,
}

--[=[
    Build all layers for a liquid glass component.
    This is the main entry point for creating the complete visual stack.
    
    @param parent Frame -- Parent to attach layers to
    @param config LiquidGlassConfig -- Complete configuration
    @return CompleteLayerRefs -- References to all created layers
]=]
function LayerBuilder.BuildAllLayers(
	parent: Frame,
	config: LiquidGlassConfig
): CompleteLayerRefs
	-- Merge with defaults
	local frostConfig = config.Frost or Constants.Defaults.Frost
	local depthConfig = config.Depth or Constants.Defaults.Depth
	local chromaticConfig = config.Chromatic or Constants.Defaults.Chromatic
	local refractionConfig = config.Refraction or Constants.Defaults.Refraction
	local borderConfig = config.BorderGradient or Constants.Defaults.BorderGradient
	local shadowConfig = config.Shadow or Constants.Defaults.Shadow
	local backgroundConfig = config.Background or Constants.Defaults.Background
	local interactionConfig = config.Interaction or Constants.Defaults.Interaction
	
	local cornerRadius = config.CornerRadius or UDim.new(0, 16)
	
	-- Initialize layer references
	local refs: CompleteLayerRefs = {
		Root = parent,
		Shadow = nil,
		Background = nil,
		FrostLayers = {
			BaseTint = nil,
			NoiseLayers = {},
			TopGlow = nil,
			BottomShadow = nil,
		},
		ChromaticLayers = {
			Red = nil,
			Green = nil,
			Blue = nil,
		},
		RefractionLayers = {
			Top = {},
			Bottom = {},
			Left = {},
			Right = {},
		},
		BorderLayers = {
			PrimaryFrame = nil,
			PrimaryStroke = nil,
			PrimaryGradient = nil,
			SecondaryFrame = nil,
			SecondaryStroke = nil,
		},
		InnerGlow = nil,
		HoverLayers = {
			HoverGlow = nil,
			PressOverlay = nil,
		},
		ContentContainer = nil,
		InputHandler = nil,
		InputTracking = nil,
	}
	
	-- Build layers in order (back to front)
	
	-- 1. Shadow (behind everything)
	if shadowConfig.Enabled then
		refs.Shadow = ShadowLayerBuilder.BuildShadowLayer(parent, shadowConfig, cornerRadius)
	end
	
	-- 2. Background
	refs.Background = BackgroundLayerBuilder.CreateBackground(parent, backgroundConfig, cornerRadius)
	
	-- 3. Frost layers
	refs.FrostLayers = FrostLayerBuilder.BuildFrostLayers(parent, frostConfig, depthConfig, cornerRadius)
	
	-- 4. Refraction layers
	refs.RefractionLayers = RefractionLayerBuilder.BuildRefractionLayers(parent, refractionConfig, cornerRadius)
	
	-- 5. Chromatic aberration layers
	refs.ChromaticLayers = ChromaticLayerBuilder.CreateChromaticLayers(parent, chromaticConfig, cornerRadius)
	
	-- 6. Inner glow
	if depthConfig.Enabled then
		refs.InnerGlow = InnerGlowLayerBuilder.CreateInnerGlow(parent, depthConfig, cornerRadius)
	end
	
	-- 7. Border
	refs.BorderLayers = BorderLayerBuilder.BuildBorderLayers(parent, borderConfig)
	
	-- 8. Hover effects
	if interactionConfig.Enabled then
		refs.HoverLayers = HoverLayerBuilder.BuildHoverLayers(
			parent,
			depthConfig.InnerGlowColor,
			0.15,
			cornerRadius
		)
	end
	
	-- 9. Content container
	refs.ContentContainer = ContentContainerBuilder.CreateContentContainer(parent, cornerRadius)
	
	-- 10. Input handler
	refs.InputHandler = InputHandlerBuilder.CreateInputHandler(parent)
	
	return refs
end

--[=[
    Set up interaction handlers for a liquid glass component.
    Connects mouse events to visual effects.
    
    @param refs CompleteLayerRefs -- Layer references
    @param config LiquidGlassConfig -- Configuration
    @return table -- Cleanup function
]=]
function LayerBuilder.SetupInteraction(
	refs: CompleteLayerRefs,
	config: LiquidGlassConfig
): { Destroy: () -> () }
	local chromaticConfig = config.Chromatic or Constants.Defaults.Chromatic
	local borderConfig = config.BorderGradient or Constants.Defaults.BorderGradient
	local shadowConfig = config.Shadow or Constants.Defaults.Shadow
	local interactionConfig = config.Interaction or Constants.Defaults.Interaction
	local refractionConfig = config.Refraction or Constants.Defaults.Refraction
	
	if not refs.InputHandler then
		return { Destroy = function() end }
	end
	
	-- Set up mouse tracking
	local tracking = InputHandlerBuilder.SetupMouseTracking(refs.InputHandler, {
		OnMouseMove = function(position: Vector2, offset: Vector2)
			-- Update chromatic aberration
			ChromaticLayerBuilder.UpdateOffsets(refs.ChromaticLayers, offset, chromaticConfig, false)
			
			-- Update border gradient rotation
			BorderLayerBuilder.UpdateGradientRotation(
				refs.BorderLayers.PrimaryGradient,
				offset,
				borderConfig,
				false
			)
			
			-- Update refraction
			RefractionLayerBuilder.UpdateRefraction(refs.RefractionLayers, offset, refractionConfig)
			
			-- Update hover glow
			HoverLayerBuilder.UpdateHoverGlow(refs.HoverLayers.HoverGlow, offset, true, 0.1)
			
			-- Update content offset for parallax
			ContentContainerBuilder.UpdateContentOffset(
				refs.ContentContainer,
				offset,
				interactionConfig.ContentFollowIntensity,
				false
			)
		end,
		
		OnMouseEnter = function()
			-- Show hover effects
			HoverLayerBuilder.UpdateHoverGlow(refs.HoverLayers.HoverGlow, Vector2.zero, true, 0.2)
			
			-- Update shadow
			ShadowLayerBuilder.UpdateShadowOnHover(refs.Shadow, shadowConfig, true, 0.2)
		end,
		
		OnMouseLeave = function()
			-- Hide hover effects
			HoverLayerBuilder.UpdateHoverGlow(refs.HoverLayers.HoverGlow, Vector2.zero, false, 0.3)
			
			-- Reset chromatic to center
			ChromaticLayerBuilder.UpdateOffsets(refs.ChromaticLayers, Vector2.zero, chromaticConfig, true)
			
			-- Reset border gradient
			BorderLayerBuilder.UpdateGradientRotation(
				refs.BorderLayers.PrimaryGradient,
				Vector2.zero,
				borderConfig,
				true
			)
			
			-- Update shadow
			ShadowLayerBuilder.UpdateShadowOnHover(refs.Shadow, shadowConfig, false, 0.3)
			
			-- Reset content position
			ContentContainerBuilder.UpdateContentOffset(refs.ContentContainer, Vector2.zero, 0, true)
		end,
		
		OnMouseDown = function(position: Vector2)
			HoverLayerBuilder.UpdatePressState(refs.HoverLayers.PressOverlay, true, 0.1)
		end,
		
		OnMouseUp = function(position: Vector2)
			HoverLayerBuilder.UpdatePressState(refs.HoverLayers.PressOverlay, false, 0.15)
		end,
	})
	
	refs.InputTracking = tracking
	
	return {
		Destroy = function()
			if tracking then
				tracking.Destroy()
			end
		end
	}
end

--[=[
    Destroy all layers and clean up.
    
    @param refs CompleteLayerRefs -- Layer references to destroy
]=]
function LayerBuilder.DestroyAllLayers(refs: CompleteLayerRefs)
	-- Destroy input tracking first
	if refs.InputTracking then
		refs.InputTracking.Destroy()
	end
	
	-- Destroy all frames
	local function safeDestroy(instance: Instance?)
		if instance then
			InstanceUtils.SafeDestroy(instance)
		end
	end
	
	safeDestroy(refs.Shadow)
	safeDestroy(refs.Background)
	safeDestroy(refs.FrostLayers.BaseTint)
	safeDestroy(refs.FrostLayers.TopGlow)
	safeDestroy(refs.FrostLayers.BottomShadow)
	
	for _, layer in ipairs(refs.FrostLayers.NoiseLayers) do
		safeDestroy(layer)
	end
	
	safeDestroy(refs.ChromaticLayers.Red)
	safeDestroy(refs.ChromaticLayers.Green)
	safeDestroy(refs.ChromaticLayers.Blue)
	
	for _, layers in pairs(refs.RefractionLayers) do
		for _, layer in ipairs(layers) do
			safeDestroy(layer)
		end
	end
	
	safeDestroy(refs.BorderLayers.PrimaryFrame)
	safeDestroy(refs.BorderLayers.SecondaryFrame)
	safeDestroy(refs.InnerGlow)
	safeDestroy(refs.HoverLayers.HoverGlow)
	safeDestroy(refs.HoverLayers.PressOverlay)
	safeDestroy(refs.ContentContainer)
	safeDestroy(refs.InputHandler)
end

--// ═══════════════════════════════════════════════════════════════════════════════
--// SECTION 20: SPRING-BASED LAYER ANIMATIONS
--// ═══════════════════════════════════════════════════════════════════════════════

--[[
    Spring-based animations provide more natural, physics-based motion for
    the liquid glass effects. These replace linear tweens with elastic motion.
]]

local SpringAnimations = {}

--[=[
    Spring animator state type.
]=]
export type SpringAnimatorState = {
	OffsetSpring: { Position: Vector2, Velocity: Vector2, Target: Vector2 },
	RotationSpring: { Position: number, Velocity: number, Target: number },
	ScaleSpring: { Position: number, Velocity: number, Target: number },
	Connection: RBXScriptConnection?,
}

--[=[
    Create a spring animator for layer effects.
    
    @param refs CompleteLayerRefs -- Layer references
    @param config LiquidGlassConfig -- Configuration
    @return SpringAnimatorState -- Animator state
]=]
function SpringAnimations.CreateAnimator(
	refs: CompleteLayerRefs,
	config: LiquidGlassConfig
): SpringAnimatorState
	local springConfig = config.Spring or Constants.Defaults.Springs.Default
	
	local state: SpringAnimatorState = {
		OffsetSpring = SpringPhysics.Create2D(
			Vector2.zero,
			springConfig.Stiffness,
			springConfig.Damping,
			springConfig.Mass
		),
		RotationSpring = SpringPhysics.Create(
			0,
			springConfig.Stiffness * 0.8,
			springConfig.Damping,
			springConfig.Mass
		),
		ScaleSpring = SpringPhysics.Create(
			1,
			springConfig.Stiffness * 1.2,
			springConfig.Damping * 0.9,
			springConfig.Mass
		),
		Connection = nil,
	}
	
	return state
end

--[=[
    Start spring animation loop.
    
    @param state SpringAnimatorState -- Animator state
    @param refs CompleteLayerRefs -- Layer references
    @param config LiquidGlassConfig -- Configuration
]=]
function SpringAnimations.StartAnimating(
	state: SpringAnimatorState,
	refs: CompleteLayerRefs,
	config: LiquidGlassConfig
)
	local chromaticConfig = config.Chromatic or Constants.Defaults.Chromatic
	local borderConfig = config.BorderGradient or Constants.Defaults.BorderGradient
	local interactionConfig = config.Interaction or Constants.Defaults.Interaction
	
	if state.Connection then
		state.Connection:Disconnect()
	end
	
	state.Connection = RunService.RenderStepped:Connect(function(deltaTime)
		-- Step all springs
		SpringPhysics.Step2D(state.OffsetSpring, deltaTime)
		SpringPhysics.Step(state.RotationSpring, deltaTime)
		SpringPhysics.Step(state.ScaleSpring, deltaTime)
		
		local offset = state.OffsetSpring.Position
		
		-- Apply spring-animated offset to chromatic layers
		ChromaticLayerBuilder.UpdateOffsets(refs.ChromaticLayers, offset, chromaticConfig, false)
		
		-- Apply spring-animated rotation to border
		if refs.BorderLayers.PrimaryGradient then
			local rotation = borderConfig.BaseRotation + offset.X * borderConfig.MouseInfluence * 30
			rotation = rotation + state.RotationSpring.Position
			refs.BorderLayers.PrimaryGradient.Rotation = rotation
		end
		
		-- Apply spring-animated content offset
		ContentContainerBuilder.UpdateContentOffset(
			refs.ContentContainer,
			offset,
			interactionConfig.ContentFollowIntensity,
			false
		)
	end)
end

--[=[
    Set spring targets (called on mouse move).
    
    @param state SpringAnimatorState -- Animator state
    @param offset Vector2 -- Target offset
    @param rotation number -- Target rotation addition
]=]
function SpringAnimations.SetTargets(
	state: SpringAnimatorState,
	offset: Vector2,
	rotation: number?
)
	SpringPhysics.SetTarget2D(state.OffsetSpring, offset)
	
	if rotation then
		SpringPhysics.SetTarget(state.RotationSpring, rotation)
	end
end

--[=[
    Stop spring animation loop.
    
    @param state SpringAnimatorState -- Animator state
]=]
function SpringAnimations.StopAnimating(state: SpringAnimatorState)
	if state.Connection then
		state.Connection:Disconnect()
		state.Connection = nil
	end
end

--// ═══════════════════════════════════════════════════════════════════════════════
--// SECTION 21: LAYER UPDATE UTILITIES
--// ═══════════════════════════════════════════════════════════════════════════════

--[[
    Utility functions for updating layer properties in batch.
]]

local LayerUpdateUtils = {}

--[=[
    Update all layers based on mouse position.
    Single function to update all effects at once.
    
    @param refs CompleteLayerRefs -- Layer references
    @param mouseOffset Vector2 -- Normalized mouse offset
    @param config LiquidGlassConfig -- Configuration
]=]
function LayerUpdateUtils.UpdateAllOnMouse(
	refs: CompleteLayerRefs,
	mouseOffset: Vector2,
	config: LiquidGlassConfig
)
	local chromaticConfig = config.Chromatic or Constants.Defaults.Chromatic
	local borderConfig = config.BorderGradient or Constants.Defaults.BorderGradient
	local refractionConfig = config.Refraction or Constants.Defaults.Refraction
	local interactionConfig = config.Interaction or Constants.Defaults.Interaction
	
	-- Chromatic
	ChromaticLayerBuilder.UpdateOffsets(refs.ChromaticLayers, mouseOffset, chromaticConfig, false)
	
	-- Border rotation
	BorderLayerBuilder.UpdateGradientRotation(
		refs.BorderLayers.PrimaryGradient,
		mouseOffset,
		borderConfig,
		false
	)
	
	-- Refraction
	RefractionLayerBuilder.UpdateRefraction(refs.RefractionLayers, mouseOffset, refractionConfig)
	
	-- Hover glow
	HoverLayerBuilder.UpdateHoverGlow(refs.HoverLayers.HoverGlow, mouseOffset, true, 0.1)
	
	-- Content parallax
	ContentContainerBuilder.UpdateContentOffset(
		refs.ContentContainer,
		mouseOffset,
		interactionConfig.ContentFollowIntensity,
		false
	)
end

--[=[
    Reset all layers to their default state.
    Called when mouse leaves the element.
    
    @param refs CompleteLayerRefs -- Layer references
    @param config LiquidGlassConfig -- Configuration
]=]
function LayerUpdateUtils.ResetAll(
	refs: CompleteLayerRefs,
	config: LiquidGlassConfig
)
	local chromaticConfig = config.Chromatic or Constants.Defaults.Chromatic
	local borderConfig = config.BorderGradient or Constants.Defaults.BorderGradient
	local shadowConfig = config.Shadow or Constants.Defaults.Shadow
	
	-- Reset chromatic
	ChromaticLayerBuilder.UpdateOffsets(refs.ChromaticLayers, Vector2.zero, chromaticConfig, true)
	
	-- Reset border
	BorderLayerBuilder.UpdateGradientRotation(
		refs.BorderLayers.PrimaryGradient,
		Vector2.zero,
		borderConfig,
		true
	)
	
	-- Reset hover glow
	HoverLayerBuilder.UpdateHoverGlow(refs.HoverLayers.HoverGlow, Vector2.zero, false, 0.3)
	
	-- Reset shadow
	ShadowLayerBuilder.UpdateShadowOnHover(refs.Shadow, shadowConfig, false, 0.3)
	
	-- Reset content
	ContentContainerBuilder.UpdateContentOffset(refs.ContentContainer, Vector2.zero, 0, true)
end

--[=[
    Set visibility of all effect layers.
    Useful for enabling/disabling effects.
    
    @param refs CompleteLayerRefs -- Layer references
    @param visible boolean -- Whether layers should be visible
]=]
function LayerUpdateUtils.SetEffectsVisible(
	refs: CompleteLayerRefs,
	visible: boolean
)
	local visibility = visible and 0 or 1
	
	-- Chromatic layers
	for _, layer in pairs(refs.ChromaticLayers) do
		if layer then
			layer.Visible = visible
		end
	end
	
	-- Refraction layers
	for _, edgeLayers in pairs(refs.RefractionLayers) do
		for _, layer in ipairs(edgeLayers) do
			layer.Visible = visible
		end
	end
	
	-- Frost layers
	if refs.FrostLayers.BaseTint then
		refs.FrostLayers.BaseTint.Visible = visible
	end
	for _, layer in ipairs(refs.FrostLayers.NoiseLayers) do
		layer.Visible = visible
	end
	if refs.FrostLayers.TopGlow then
		refs.FrostLayers.TopGlow.Visible = visible
	end
	if refs.FrostLayers.BottomShadow then
		refs.FrostLayers.BottomShadow.Visible = visible
	end
end

--// ═══════════════════════════════════════════════════════════════════════════════
--// ███████████████████████████████████████████████████████████████████████████████
--// CHUNK 3: MAIN LIQUIDGLASS CLASS AND PUBLIC API
--// ███████████████████████████████████████████████████████████████████████████████
--// ═══════════════════════════════════════════════════════════════════════════════

--[[
    CHUNK 3 OVERVIEW
    ================
    
    This chunk implements the main LiquidGlass class that ties everything together:
    
    SECTIONS:
    22. LiquidGlass Class Definition & Constructor
    23. UI Building Methods
    24. Interaction Setup & Event Handlers
    25. Update Methods (Mouse, Hover, Press)
    26. RunService Update Loop
    27. Public API Methods
    28. Static Factory Methods & Presets
    29. Module Export
    
    USAGE:
    ```lua
    local LiquidGlass = require(path.to.LiquidGlassPro)
    
    -- Create with full config
    local element = LiquidGlass.new({
        Size = UDim2.fromOffset(200, 60),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        CornerRadius = 16,
        Parent = screenGui,
    })
    
    -- Or use preset factories
    local button = LiquidGlass.CreateButton("Click Me", function()
        print("Clicked!")
    end)
    
    local card = LiquidGlass.CreateCard({
        Size = UDim2.fromOffset(300, 200),
    })
    ```
]]

--// ═══════════════════════════════════════════════════════════════════════════════
--// SECTION 22: LIQUIDGLASS CLASS DEFINITION
--// ═══════════════════════════════════════════════════════════════════════════════

--[[
    The main LiquidGlass class.
    Creates and manages a complete liquid glass UI element with all effects.
]]

--// Type definition for the LiquidGlass instance
export type LiquidGlassInstance = {
	-- Private state
	_config: LiquidGlassConfig,
	_container: Frame,
	_layerRefs: CompleteLayerRefs,
	_connections: { RBXScriptConnection },
	_tweens: { Tween },
	
	-- Interaction state
	_isHovered: boolean,
	_isPressed: boolean,
	_mouseOffset: Vector2,
	_lastMousePosition: Vector2,
	
	-- Spring animators
	_positionSpring: SpringAnimatorState,
	_scaleSpring: SpringAnimatorState,
	_rotationSpring: SpringAnimatorState,
	
	-- Update loop
	_updateConnection: RBXScriptConnection?,
	_isDestroyed: boolean,
	
	-- Public methods
	SetContent: (self: LiquidGlassInstance, content: GuiObject) -> (),
	SetProperty: (self: LiquidGlassInstance, key: string, value: any) -> (),
	GetFrame: (self: LiquidGlassInstance) -> Frame,
	GetContentFrame: (self: LiquidGlassInstance) -> Frame,
	IsHovered: (self: LiquidGlassInstance) -> boolean,
	IsPressed: (self: LiquidGlassInstance) -> boolean,
	SetEnabled: (self: LiquidGlassInstance, enabled: boolean) -> (),
	SetVisible: (self: LiquidGlassInstance, visible: boolean) -> (),
	TweenProperty: (self: LiquidGlassInstance, property: string, value: any, duration: number?) -> (),
	Destroy: (self: LiquidGlassInstance) -> (),
}

--// The LiquidGlass class table
local LiquidGlass = {}
LiquidGlass.__index = LiquidGlass

--// Services
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

--[=[
    Creates a new LiquidGlass element.
    
    @param config LiquidGlassConfig? -- Optional configuration table
    @return LiquidGlassInstance -- The new LiquidGlass instance
    
    @example
    ```lua
    local element = LiquidGlass.new({
        Size = UDim2.fromOffset(200, 60),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        CornerRadius = 16,
        onClick = function()
            print("Clicked!")
        end,
        Parent = playerGui.ScreenGui,
    })
    ```
]=]
function LiquidGlass.new(config: LiquidGlassConfig?): LiquidGlassInstance
	local self = setmetatable({}, LiquidGlass)
	
	-- Merge config with defaults
	local userConfig = config or {}
	self._config = LiquidGlass._mergeWithDefaults(userConfig)
	
	-- Initialize interaction state
	self._isHovered = false
	self._isPressed = false
	self._mouseOffset = Vector2.zero
	self._lastMousePosition = Vector2.zero
	
	-- Initialize connection and tween storage
	self._connections = {}
	self._tweens = {}
	self._isDestroyed = false
	
	-- Initialize spring animators for smooth movement
	local springConfig = self._config.Spring or Constants.Defaults.Spring
	self._positionSpring = SpringAnimations.CreateAnimator(
		Vector2.zero,
		springConfig.Position
	)
	self._scaleSpring = SpringAnimations.CreateAnimator(
		Vector2.new(1, 1),
		springConfig.Scale
	)
	self._rotationSpring = SpringAnimations.CreateAnimator(
		0,
		springConfig.Rotation
	)
	
	-- Build the UI hierarchy
	self:_buildUI()
	
	-- Setup interaction handlers
	self:_setupInteractions()
	
	-- Start the update loop
	self:_startUpdateLoop()
	
	-- Parent if specified
	if self._config.Parent then
		self._container.Parent = self._config.Parent
	end
	
	return self :: LiquidGlassInstance
end

--[=[
    Merges user config with default values.
    Performs deep merge for nested tables.
    
    @param userConfig LiquidGlassConfig -- User-provided configuration
    @return LiquidGlassConfig -- Merged configuration
]=]
function LiquidGlass._mergeWithDefaults(userConfig: LiquidGlassConfig): LiquidGlassConfig
	local defaults = Constants.Defaults
	
	-- Helper for deep merge
	local function deepMerge(default: any, user: any): any
		if type(default) ~= "table" or type(user) ~= "table" then
			return if user ~= nil then user else default
		end
		
		local result = {}
		for key, defaultValue in pairs(default) do
			result[key] = deepMerge(defaultValue, user[key])
		end
		-- Include any user keys not in defaults
		for key, userValue in pairs(user) do
			if result[key] == nil then
				result[key] = userValue
			end
		end
		return result
	end
	
	-- Merge each config section
	local merged: LiquidGlassConfig = {
		-- Base properties (no deep merge needed)
		Size = userConfig.Size or UDim2.fromOffset(200, 60),
		Position = userConfig.Position or UDim2.fromScale(0.5, 0.5),
		AnchorPoint = userConfig.AnchorPoint or Vector2.new(0.5, 0.5),
		CornerRadius = userConfig.CornerRadius or 16,
		ZIndex = userConfig.ZIndex or 1,
		Parent = userConfig.Parent,
		Name = userConfig.Name or "LiquidGlass",
		
		-- Callbacks
		onClick = userConfig.onClick,
		onHover = userConfig.onHover,
		onHoverEnd = userConfig.onHoverEnd,
		onPress = userConfig.onPress,
		onRelease = userConfig.onRelease,
		
		-- Deep merged sections
		Frost = deepMerge(defaults.Frost, userConfig.Frost or {}),
		Chromatic = deepMerge(defaults.Chromatic, userConfig.Chromatic or {}),
		Refraction = deepMerge(defaults.Refraction, userConfig.Refraction or {}),
		BorderGradient = deepMerge(defaults.BorderGradient, userConfig.BorderGradient or {}),
		Shadow = deepMerge(defaults.Shadow, userConfig.Shadow or {}),
		Depth = deepMerge(defaults.Depth, userConfig.Depth or {}),
		Interaction = deepMerge(defaults.Interaction, userConfig.Interaction or {}),
		Spring = deepMerge(defaults.Spring, userConfig.Spring or {}),
		InnerGlow = deepMerge(defaults.InnerGlow, userConfig.InnerGlow or {}),
	}
	
	return merged
end

--// ═══════════════════════════════════════════════════════════════════════════════
--// SECTION 23: UI BUILDING METHODS
--// ═══════════════════════════════════════════════════════════════════════════════

--[=[
    Builds the complete UI hierarchy using LayerBuilder.
    Creates all visual layers and stores references for updates.
]=]
function LiquidGlass:_buildUI()
	-- Build all layers using the orchestrator
	local container, layerRefs = LayerBuilder.BuildAllLayers(self._config)
	
	-- Store references
	self._container = container
	self._layerRefs = layerRefs
	
	-- Apply initial state
	self:_applyInitialState()
end

--[=[
    Applies initial visual state to all layers.
    Sets up starting values for animations.
]=]
function LiquidGlass:_applyInitialState()
	-- Ensure shadow starts in non-hovered state
	local shadowConfig = self._config.Shadow
	if self._layerRefs.Shadow then
		ShadowLayerBuilder.UpdateShadowOnHover(
			self._layerRefs.Shadow,
			shadowConfig,
			false,
			0 -- Instant
		)
	end
	
	-- Ensure hover layers are hidden
	if self._layerRefs.HoverLayers.HoverGlow then
		self._layerRefs.HoverLayers.HoverGlow.ImageTransparency = 1
	end
	if self._layerRefs.HoverLayers.PressOverlay then
		self._layerRefs.HoverLayers.PressOverlay.BackgroundTransparency = 1
	end
	
	-- Reset chromatic to center
	local chromaticConfig = self._config.Chromatic
	ChromaticLayerBuilder.UpdateOffsets(
		self._layerRefs.ChromaticLayers,
		Vector2.zero,
		chromaticConfig,
		false
	)
end

--// ═══════════════════════════════════════════════════════════════════════════════
--// SECTION 24: INTERACTION SETUP & EVENT HANDLERS
--// ═══════════════════════════════════════════════════════════════════════════════

--[=[
    Sets up all interaction event handlers.
    Handles mouse enter/leave, click, and movement.
]=]
function LiquidGlass:_setupInteractions()
	local inputHandler = self._layerRefs.InputHandler
	if not inputHandler then
		warn("[LiquidGlass] No input handler found, interactions disabled")
		return
	end
	
	-- Mouse Enter
	local enterConnection = inputHandler.MouseEnter:Connect(function()
		if self._isDestroyed then return end
		self:_onHoverChanged(true)
	end)
	table.insert(self._connections, enterConnection)
	
	-- Mouse Leave
	local leaveConnection = inputHandler.MouseLeave:Connect(function()
		if self._isDestroyed then return end
		self:_onHoverChanged(false)
		-- Also reset press state if leaving while pressed
		if self._isPressed then
			self:_onPressChanged(false)
		end
	end)
	table.insert(self._connections, leaveConnection)
	
	-- Mouse Button Down
	local downConnection = inputHandler.InputBegan:Connect(function(input)
		if self._isDestroyed then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or
		   input.UserInputType == Enum.UserInputType.Touch then
			self:_onPressChanged(true)
		end
	end)
	table.insert(self._connections, downConnection)
	
	-- Mouse Button Up
	local upConnection = inputHandler.InputEnded:Connect(function(input)
		if self._isDestroyed then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or
		   input.UserInputType == Enum.UserInputType.Touch then
			if self._isPressed then
				self:_onPressChanged(false)
				-- Trigger click callback if still hovering
				if self._isHovered and self._config.onClick then
					self._config.onClick()
				end
			end
		end
	end)
	table.insert(self._connections, upConnection)
	
	-- Mouse Movement (global tracking)
	local moveConnection = UserInputService.InputChanged:Connect(function(input)
		if self._isDestroyed then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			local mousePos = Vector2.new(input.Position.X, input.Position.Y)
			self._lastMousePosition = mousePos
			
			if self._isHovered then
				self:_onMouseMove(mousePos)
			end
		end
	end)
	table.insert(self._connections, moveConnection)
	
	-- Touch Movement
	local touchMoveConnection = UserInputService.TouchMoved:Connect(function(touch)
		if self._isDestroyed then return end
		if self._isHovered and self._isPressed then
			local touchPos = Vector2.new(touch.Position.X, touch.Position.Y)
			self._lastMousePosition = touchPos
			self:_onMouseMove(touchPos)
		end
	end)
	table.insert(self._connections, touchMoveConnection)
end

--// ═══════════════════════════════════════════════════════════════════════════════
--// SECTION 25: UPDATE METHODS
--// ═══════════════════════════════════════════════════════════════════════════════

--[=[
    Handles mouse movement over the element.
    Updates all dynamic effects based on mouse position.
    
    @param position Vector2 -- Absolute mouse position
]=]
function LiquidGlass:_onMouseMove(position: Vector2)
	if not self._container then return end
	
	-- Calculate element bounds
	local absPos = self._container.AbsolutePosition
	local absSize = self._container.AbsoluteSize
	local center = absPos + absSize / 2
	
	-- Calculate normalized offset (-1 to 1)
	local relativePos = position - center
	local normalizedX = math.clamp(relativePos.X / (absSize.X / 2), -1, 1)
	local normalizedY = math.clamp(relativePos.Y / (absSize.Y / 2), -1, 1)
	local normalizedOffset = Vector2.new(normalizedX, normalizedY)
	
	self._mouseOffset = normalizedOffset
	
	-- Update spring targets for elastic movement
	local interactionConfig = self._config.Interaction
	if interactionConfig.ElasticEnabled then
		local elasticIntensity = interactionConfig.ElasticIntensity or 8
		local targetOffset = normalizedOffset * elasticIntensity
		SpringAnimations.SetTarget(self._positionSpring, targetOffset)
	end
	
	-- Update all layers based on mouse position
	LayerUpdateUtils.UpdateAllOnMouse(
		self._layerRefs,
		normalizedOffset,
		self._config
	)
end

--[=[
    Handles hover state changes.
    Animates hover-related visual effects.
    
    @param isHovered boolean -- New hover state
]=]
function LiquidGlass:_onHoverChanged(isHovered: boolean)
	if self._isHovered == isHovered then return end
	self._isHovered = isHovered
	
	local interactionConfig = self._config.Interaction
	local shadowConfig = self._config.Shadow
	local duration = 0.2
	
	if isHovered then
		-- ═══ HOVER START ═══
		
		-- Show hover glow
		if self._layerRefs.HoverLayers.HoverGlow then
			HoverLayerBuilder.UpdateHoverGlow(
				self._layerRefs.HoverLayers.HoverGlow,
				self._mouseOffset,
				true,
				duration
			)
		end
		
		-- Elevate shadow
		ShadowLayerBuilder.UpdateShadowOnHover(
			self._layerRefs.Shadow,
			shadowConfig,
			true,
			duration
		)
		
		-- Brighten border
		if self._layerRefs.BorderLayers.PrimaryGradient then
			AnimationUtils.TweenTransparency(
				self._layerRefs.BorderLayers.PrimaryGradient,
				self._layerRefs.BorderLayers.PrimaryGradient.ImageTransparency - 0.1,
				duration
			)
		end
		
		-- Scale up slightly
		local hoverScale = interactionConfig.HoverScale or 1.02
		if hoverScale ~= 1 then
			SpringAnimations.SetTarget(
				self._scaleSpring,
				Vector2.new(hoverScale, hoverScale)
			)
		end
		
		-- Callback
		if self._config.onHover then
			self._config.onHover()
		end
	else
		-- ═══ HOVER END ═══
		
		-- Reset all layers
		LayerUpdateUtils.ResetAll(self._layerRefs, self._config)
		
		-- Reset spring targets
		SpringAnimations.SetTarget(self._positionSpring, Vector2.zero)
		SpringAnimations.SetTarget(self._scaleSpring, Vector2.new(1, 1))
		SpringAnimations.SetTarget(self._rotationSpring, 0)
		
		-- Reset mouse offset
		self._mouseOffset = Vector2.zero
		
		-- Callback
		if self._config.onHoverEnd then
			self._config.onHoverEnd()
		end
	end
end

--[=[
    Handles press state changes.
    Animates press-related visual effects.
    
    @param isPressed boolean -- New press state
]=]
function LiquidGlass:_onPressChanged(isPressed: boolean)
	if self._isPressed == isPressed then return end
	self._isPressed = isPressed
	
	local interactionConfig = self._config.Interaction
	local duration = isPressed and 0.1 or 0.2
	
	if isPressed then
		-- ═══ PRESS START ═══
		
		-- Scale down
		local pressScale = interactionConfig.PressScale or 0.96
		SpringAnimations.SetTarget(
			self._scaleSpring,
			Vector2.new(pressScale, pressScale)
		)
		
		-- Show press overlay
		if self._layerRefs.HoverLayers.PressOverlay then
			AnimationUtils.TweenTransparency(
				self._layerRefs.HoverLayers.PressOverlay,
				0.9,
				duration
			)
		end
		
		-- Reduce shadow elevation
		if self._layerRefs.Shadow then
			local shadowFrame = self._layerRefs.Shadow
			local currentOffset = shadowFrame.Position
			AnimationUtils.TweenProperty(
				shadowFrame,
				"Position",
				UDim2.new(
					currentOffset.X.Scale,
					currentOffset.X.Offset * 0.5,
					currentOffset.Y.Scale,
					currentOffset.Y.Offset * 0.5
				),
				duration
			)
		end
		
		-- Callback
		if self._config.onPress then
			self._config.onPress()
		end
	else
		-- ═══ PRESS END ═══
		
		-- Restore scale (to hover or normal)
		local targetScale = self._isHovered 
			and (interactionConfig.HoverScale or 1.02) 
			or 1
		SpringAnimations.SetTarget(
			self._scaleSpring,
			Vector2.new(targetScale, targetScale)
		)
		
		-- Hide press overlay
		if self._layerRefs.HoverLayers.PressOverlay then
			AnimationUtils.TweenTransparency(
				self._layerRefs.HoverLayers.PressOverlay,
				1,
				duration
			)
		end
		
		-- Restore shadow elevation
		local shadowConfig = self._config.Shadow
		ShadowLayerBuilder.UpdateShadowOnHover(
			self._layerRefs.Shadow,
			shadowConfig,
			self._isHovered,
			duration
		)
		
		-- Callback
		if self._config.onRelease then
			self._config.onRelease()
		end
	end
end

--// ═══════════════════════════════════════════════════════════════════════════════
--// SECTION 26: RUNSERVICE UPDATE LOOP
--// ═══════════════════════════════════════════════════════════════════════════════

--[=[
    Starts the per-frame update loop.
    Steps spring animators and applies animated values.
]=]
function LiquidGlass:_startUpdateLoop()
	-- Use Heartbeat for physics updates
	self._updateConnection = RunService.Heartbeat:Connect(function(deltaTime)
		if self._isDestroyed then return end
		self:_updateFrame(deltaTime)
	end)
	table.insert(self._connections, self._updateConnection)
end

--[=[
    Per-frame update function.
    Steps all spring animators and applies values to UI.
    
    @param deltaTime number -- Time since last frame
]=]
function LiquidGlass:_updateFrame(deltaTime: number)
	local interactionConfig = self._config.Interaction
	
	-- Step position spring
	local positionValue = SpringAnimations.Step(self._positionSpring, deltaTime)
	
	-- Step scale spring
	local scaleValue = SpringAnimations.Step(self._scaleSpring, deltaTime)
	
	-- Step rotation spring
	local rotationValue = SpringAnimations.Step(self._rotationSpring, deltaTime)
	
	-- Apply elastic position offset
	if interactionConfig.ElasticEnabled and self._container then
		-- Position offset
		if typeof(positionValue) == "Vector2" then
			local basePos = self._config.Position
			self._container.Position = UDim2.new(
				basePos.X.Scale,
				basePos.X.Offset + positionValue.X,
				basePos.Y.Scale,
				basePos.Y.Offset + positionValue.Y
			)
		end
	end
	
	-- Apply scale
	if typeof(scaleValue) == "Vector2" then
		-- Check if significantly different from current
		local currentSizeX = self._container.Size.X.Scale
		local targetScaleX = scaleValue.X
		
		-- Only update if there's meaningful change
		if math.abs(targetScaleX - 1) > 0.001 or math.abs(scaleValue.Y - 1) > 0.001 then
			-- Apply via UIScale if available, otherwise transform the size
			local uiScale = self._container:FindFirstChildOfClass("UIScale")
			if uiScale then
				uiScale.Scale = scaleValue.X
			else
				-- Fallback: adjust anchor to scale from center
				-- This is less ideal but works without UIScale
			end
		end
	end
	
	-- Apply rotation (subtle)
	if typeof(rotationValue) == "number" and math.abs(rotationValue) > 0.001 then
		self._container.Rotation = rotationValue
	end
end

--// ═══════════════════════════════════════════════════════════════════════════════
--// SECTION 27: PUBLIC API METHODS
--// ═══════════════════════════════════════════════════════════════════════════════

--[=[
    Sets content inside the LiquidGlass element.
    Parents the content to the internal content frame.
    
    @param content GuiObject -- The UI element to add as content
    
    @example
    ```lua
    local label = Instance.new("TextLabel")
    label.Text = "Hello World"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    
    liquidGlass:SetContent(label)
    ```
]=]
function LiquidGlass:SetContent(content: GuiObject)
	if self._isDestroyed then
		warn("[LiquidGlass] Cannot set content on destroyed instance")
		return
	end
	
	local contentFrame = self._layerRefs.ContentContainer
	if contentFrame then
		-- Clear existing content
		for _, child in ipairs(contentFrame:GetChildren()) do
			if not child:IsA("UIListLayout") and 
			   not child:IsA("UIPadding") and
			   not child:IsA("UICorner") then
				child:Destroy()
			end
		end
		
		-- Parent new content
		content.Parent = contentFrame
	else
		warn("[LiquidGlass] No content container found")
	end
end

--[=[
    Updates a configuration property and applies the change.
    
    @param key string -- The property key to update
    @param value any -- The new value
    
    @example
    ```lua
    liquidGlass:SetProperty("CornerRadius", 24)
    liquidGlass:SetProperty("Frost.Intensity", 0.9)
    ```
]=]
function LiquidGlass:SetProperty(key: string, value: any)
	if self._isDestroyed then return end
	
	-- Handle nested keys (e.g., "Frost.Intensity")
	local keys = string.split(key, ".")
	
	if #keys == 1 then
		-- Top-level property
		self._config[key] = value
		self:_applyPropertyChange(key, value)
	else
		-- Nested property
		local current = self._config
		for i = 1, #keys - 1 do
			current = current[keys[i]]
			if not current then return end
		end
		current[keys[#keys]] = value
		self:_applyPropertyChange(keys[1], self._config[keys[1]])
	end
end

--[=[
    Applies a property change to the UI.
    
    @param key string -- The property category that changed
    @param value any -- The new value
]=]
function LiquidGlass:_applyPropertyChange(key: string, value: any)
	if key == "Size" then
		self._container.Size = value
	elseif key == "Position" then
		self._config.Position = value
		self._container.Position = value
	elseif key == "CornerRadius" then
		-- Update all UICorner instances
		for _, descendant in ipairs(self._container:GetDescendants()) do
			if descendant:IsA("UICorner") then
				descendant.CornerRadius = UDim.new(0, value)
			end
		end
	elseif key == "Frost" then
		-- Rebuild frost layers would be complex, mark for future enhancement
	elseif key == "Shadow" then
		-- Update shadow
		ShadowLayerBuilder.UpdateShadowOnHover(
			self._layerRefs.Shadow,
			value,
			self._isHovered,
			0.2
		)
	end
end

--[=[
    Returns the main container frame.
    
    @return Frame -- The root frame of the LiquidGlass element
]=]
function LiquidGlass:GetFrame(): Frame
	return self._container
end

--[=[
    Returns the content container frame.
    
    @return Frame -- The content frame where child elements should be parented
]=]
function LiquidGlass:GetContentFrame(): Frame
	return self._layerRefs.ContentContainer
end

--[=[
    Returns whether the element is currently hovered.
    
    @return boolean -- True if mouse is over the element
]=]
function LiquidGlass:IsHovered(): boolean
	return self._isHovered
end

--[=[
    Returns whether the element is currently pressed.
    
    @return boolean -- True if element is being pressed
]=]
function LiquidGlass:IsPressed(): boolean
	return self._isPressed
end

--[=[
    Sets the enabled state of the element.
    When disabled, interactions are ignored and visual state changes.
    
    @param enabled boolean -- Whether the element should be enabled
]=]
function LiquidGlass:SetEnabled(enabled: boolean)
	if self._isDestroyed then return end
	
	self._config.Enabled = enabled
	
	if enabled then
		-- Restore normal appearance
		self._container.BackgroundTransparency = 0
		if self._layerRefs.InputHandler then
			self._layerRefs.InputHandler.Active = true
		end
	else
		-- Dim appearance
		self._container.BackgroundTransparency = 0.5
		if self._layerRefs.InputHandler then
			self._layerRefs.InputHandler.Active = false
		end
		
		-- Reset interaction states
		if self._isHovered then
			self:_onHoverChanged(false)
		end
		if self._isPressed then
			self:_onPressChanged(false)
		end
	end
end

--[=[
    Sets the visibility of the element.
    
    @param visible boolean -- Whether the element should be visible
]=]
function LiquidGlass:SetVisible(visible: boolean)
	if self._isDestroyed then return end
	self._container.Visible = visible
end

--[=[
    Animates a property change using TweenService.
    
    @param property string -- The property to animate
    @param value any -- The target value
    @param duration number? -- Animation duration (default 0.3)
    
    @example
    ```lua
    liquidGlass:TweenProperty("Position", UDim2.fromScale(0.8, 0.5), 0.5)
    ```
]=]
function LiquidGlass:TweenProperty(property: string, value: any, duration: number?)
	if self._isDestroyed then return end
	
	local tweenDuration = duration or 0.3
	local tweenInfo = TweenInfo.new(
		tweenDuration,
		Enum.EasingStyle.Quint,
		Enum.EasingDirection.Out
	)
	
	local tween = TweenService:Create(self._container, tweenInfo, {
		[property] = value
	})
	
	table.insert(self._tweens, tween)
	tween:Play()
	
	-- Update config after tween
	tween.Completed:Connect(function()
		if property == "Position" then
			self._config.Position = value
		elseif property == "Size" then
			self._config.Size = value
		end
	end)
end

--[=[
    Returns the current configuration.
    
    @return LiquidGlassConfig -- The current configuration table
]=]
function LiquidGlass:GetConfig(): LiquidGlassConfig
	return self._config
end

--[=[
    Cleans up and destroys the LiquidGlass element.
    Disconnects all events, cancels tweens, and destroys the UI.
]=]
function LiquidGlass:Destroy()
	if self._isDestroyed then return end
	self._isDestroyed = true
	
	-- Disconnect all connections
	for _, connection in ipairs(self._connections) do
		if connection.Connected then
			connection:Disconnect()
		end
	end
	self._connections = {}
	
	-- Cancel all tweens
	for _, tween in ipairs(self._tweens) do
		tween:Cancel()
	end
	self._tweens = {}
	
	-- Destroy UI hierarchy
	if self._container then
		self._container:Destroy()
	end
	
	-- Clear references
	self._container = nil :: any
	self._layerRefs = nil :: any
	self._config = nil :: any
end

--// ═══════════════════════════════════════════════════════════════════════════════
--// SECTION 28: STATIC FACTORY METHODS & PRESETS
--// ═══════════════════════════════════════════════════════════════════════════════

--[[
    Pre-configured style presets for common UI patterns.
    These can be used directly or as a base for customization.
]]

LiquidGlass.Presets = {
	--[=[
        Default preset - balanced frosted glass effect.
    ]=]
	Default = {
		CornerRadius = 16,
		Frost = {
			Intensity = 0.7,
			TintColor = Color3.fromRGB(255, 255, 255),
			TintOpacity = 0.1,
			NoiseIntensity = 0.03,
		},
		Chromatic = {
			Enabled = true,
			Intensity = 1.0,
			MaxOffset = 3,
		},
		BorderGradient = {
			Enabled = true,
			Width = 1.5,
			BaseOpacity = 0.4,
		},
		Shadow = {
			Enabled = true,
			Blur = 24,
			Offset = Vector2.new(0, 8),
			Opacity = 0.15,
		},
	},
	
	--[=[
        Button preset - optimized for clickable elements.
    ]=]
	Button = {
		Size = UDim2.fromOffset(160, 48),
		CornerRadius = 12,
		Frost = {
			Intensity = 0.8,
			TintColor = Color3.fromRGB(255, 255, 255),
			TintOpacity = 0.15,
			NoiseIntensity = 0.02,
		},
		Chromatic = {
			Enabled = true,
			Intensity = 0.8,
			MaxOffset = 2,
		},
		BorderGradient = {
			Enabled = true,
			Width = 1,
			BaseOpacity = 0.5,
		},
		Shadow = {
			Enabled = true,
			Blur = 16,
			Offset = Vector2.new(0, 4),
			Opacity = 0.2,
		},
		Interaction = {
			HoverScale = 1.03,
			PressScale = 0.97,
			ElasticEnabled = true,
			ElasticIntensity = 4,
		},
	},
	
	--[=[
        Card preset - larger container with subtle effects.
    ]=]
	Card = {
		Size = UDim2.fromOffset(300, 200),
		CornerRadius = 20,
		Frost = {
			Intensity = 0.6,
			TintColor = Color3.fromRGB(245, 245, 250),
			TintOpacity = 0.12,
			NoiseIntensity = 0.025,
		},
		Chromatic = {
			Enabled = true,
			Intensity = 0.6,
			MaxOffset = 4,
		},
		BorderGradient = {
			Enabled = true,
			Width = 1,
			BaseOpacity = 0.3,
		},
		Shadow = {
			Enabled = true,
			Blur = 32,
			Offset = Vector2.new(0, 12),
			Opacity = 0.12,
			HoverLift = 8,
		},
		Interaction = {
			HoverScale = 1.01,
			PressScale = 0.99,
			ElasticEnabled = true,
			ElasticIntensity = 3,
		},
	},
	
	--[=[
        Pill preset - rounded capsule shape.
    ]=]
	Pill = {
		Size = UDim2.fromOffset(120, 36),
		CornerRadius = 18, -- Half of height for pill shape
		Frost = {
			Intensity = 0.85,
			TintColor = Color3.fromRGB(255, 255, 255),
			TintOpacity = 0.2,
			NoiseIntensity = 0.015,
		},
		Chromatic = {
			Enabled = true,
			Intensity = 0.7,
			MaxOffset = 2,
		},
		BorderGradient = {
			Enabled = true,
			Width = 1,
			BaseOpacity = 0.6,
		},
		Shadow = {
			Enabled = true,
			Blur = 12,
			Offset = Vector2.new(0, 3),
			Opacity = 0.18,
		},
		Interaction = {
			HoverScale = 1.05,
			PressScale = 0.95,
			ElasticEnabled = false,
		},
	},
	
	--[=[
        StatusBadge preset - small indicator badge.
    ]=]
	StatusBadge = {
		Size = UDim2.fromOffset(80, 28),
		CornerRadius = 14,
		Frost = {
			Intensity = 0.9,
			TintColor = Color3.fromRGB(100, 200, 100),
			TintOpacity = 0.25,
			NoiseIntensity = 0.01,
		},
		Chromatic = {
			Enabled = false, -- Disabled for badges
		},
		BorderGradient = {
			Enabled = true,
			Width = 1,
			BaseOpacity = 0.7,
		},
		Shadow = {
			Enabled = true,
			Blur = 8,
			Offset = Vector2.new(0, 2),
			Opacity = 0.15,
		},
		Interaction = {
			HoverScale = 1.0, -- No scale on hover
			PressScale = 1.0,
			ElasticEnabled = false,
		},
	},
	
	--[=[
        Panel preset - large container panel.
    ]=]
	Panel = {
		Size = UDim2.fromOffset(400, 300),
		CornerRadius = 24,
		Frost = {
			Intensity = 0.5,
			TintColor = Color3.fromRGB(240, 240, 245),
			TintOpacity = 0.08,
			NoiseIntensity = 0.02,
		},
		Chromatic = {
			Enabled = true,
			Intensity = 0.4,
			MaxOffset = 5,
		},
		BorderGradient = {
			Enabled = true,
			Width = 1,
			BaseOpacity = 0.25,
		},
		Shadow = {
			Enabled = true,
			Blur = 48,
			Offset = Vector2.new(0, 16),
			Opacity = 0.1,
			HoverLift = 4,
		},
		Interaction = {
			HoverScale = 1.0,
			PressScale = 1.0,
			ElasticEnabled = false,
		},
	},
	
	--[=[
        Modal preset - popup/dialog style.
    ]=]
	Modal = {
		Size = UDim2.fromOffset(450, 320),
		CornerRadius = 20,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Frost = {
			Intensity = 0.75,
			TintColor = Color3.fromRGB(250, 250, 255),
			TintOpacity = 0.15,
			NoiseIntensity = 0.02,
		},
		Chromatic = {
			Enabled = true,
			Intensity = 0.5,
			MaxOffset = 3,
		},
		BorderGradient = {
			Enabled = true,
			Width = 1.5,
			BaseOpacity = 0.35,
		},
		Shadow = {
			Enabled = true,
			Blur = 64,
			Offset = Vector2.new(0, 24),
			Opacity = 0.25,
		},
		Interaction = {
			HoverScale = 1.0,
			PressScale = 1.0,
			ElasticEnabled = false,
		},
	},
	
	--[=[
        Toolbar preset - horizontal toolbar/navbar style.
    ]=]
	Toolbar = {
		Size = UDim2.new(1, -32, 0, 56),
		CornerRadius = 16,
		Frost = {
			Intensity = 0.65,
			TintColor = Color3.fromRGB(255, 255, 255),
			TintOpacity = 0.1,
			NoiseIntensity = 0.02,
		},
		Chromatic = {
			Enabled = false,
		},
		BorderGradient = {
			Enabled = true,
			Width = 1,
			BaseOpacity = 0.3,
		},
		Shadow = {
			Enabled = true,
			Blur = 20,
			Offset = Vector2.new(0, 6),
			Opacity = 0.12,
		},
		Interaction = {
			HoverScale = 1.0,
			PressScale = 1.0,
			ElasticEnabled = false,
		},
	},
}

--[=[
    Creates a LiquidGlass button with text.
    
    @param text string -- Button text
    @param onClick (() -> ())? -- Click callback
    @param customConfig LiquidGlassConfig? -- Additional configuration overrides
    @return LiquidGlassInstance -- The created button
    
    @example
    ```lua
    local button = LiquidGlass.CreateButton("Submit", function()
        print("Button clicked!")
    end, {
        Size = UDim2.fromOffset(200, 50),
        Parent = screenGui,
    })
    ```
]=]
function LiquidGlass.CreateButton(
	text: string,
	onClick: (() -> ())?,
	customConfig: LiquidGlassConfig?
): LiquidGlassInstance
	-- Merge button preset with custom config
	local config = LiquidGlass._mergeConfigs(
		LiquidGlass.Presets.Button,
		customConfig or {}
	)
	config.onClick = onClick
	
	-- Create the element
	local element = LiquidGlass.new(config)
	
	-- Create text label
	local label = Instance.new("TextLabel")
	label.Name = "ButtonLabel"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamMedium
	label.Text = text
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextSize = 16
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextYAlignment = Enum.TextYAlignment.Center
	
	element:SetContent(label)
	
	return element
end

--[=[
    Creates a LiquidGlass card container.
    
    @param customConfig LiquidGlassConfig? -- Configuration overrides
    @return LiquidGlassInstance -- The created card
    
    @example
    ```lua
    local card = LiquidGlass.CreateCard({
        Size = UDim2.fromOffset(350, 250),
        Position = UDim2.fromScale(0.5, 0.5),
        Parent = screenGui,
    })
    
    -- Add content to the card
    card:SetContent(myContentFrame)
    ```
]=]
function LiquidGlass.CreateCard(customConfig: LiquidGlassConfig?): LiquidGlassInstance
	local config = LiquidGlass._mergeConfigs(
		LiquidGlass.Presets.Card,
		customConfig or {}
	)
	
	return LiquidGlass.new(config)
end

--[=[
    Creates a LiquidGlass pill/tag element.
    
    @param text string -- Pill text
    @param customConfig LiquidGlassConfig? -- Configuration overrides
    @return LiquidGlassInstance -- The created pill
    
    @example
    ```lua
    local pill = LiquidGlass.CreatePill("Active", {
        Frost = {
            TintColor = Color3.fromRGB(100, 200, 100),
        },
        Parent = screenGui,
    })
    ```
]=]
function LiquidGlass.CreatePill(
	text: string,
	customConfig: LiquidGlassConfig?
): LiquidGlassInstance
	local config = LiquidGlass._mergeConfigs(
		LiquidGlass.Presets.Pill,
		customConfig or {}
	)
	
	local element = LiquidGlass.new(config)
	
	-- Create text label
	local label = Instance.new("TextLabel")
	label.Name = "PillLabel"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamMedium
	label.Text = text
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextYAlignment = Enum.TextYAlignment.Center
	
	element:SetContent(label)
	
	return element
end

--[=[
    Creates a LiquidGlass panel container.
    
    @param customConfig LiquidGlassConfig? -- Configuration overrides
    @return LiquidGlassInstance -- The created panel
]=]
function LiquidGlass.CreatePanel(customConfig: LiquidGlassConfig?): LiquidGlassInstance
	local config = LiquidGlass._mergeConfigs(
		LiquidGlass.Presets.Panel,
		customConfig or {}
	)
	
	return LiquidGlass.new(config)
end

--[=[
    Creates a LiquidGlass modal dialog.
    
    @param customConfig LiquidGlassConfig? -- Configuration overrides
    @return LiquidGlassInstance -- The created modal
]=]
function LiquidGlass.CreateModal(customConfig: LiquidGlassConfig?): LiquidGlassInstance
	local config = LiquidGlass._mergeConfigs(
		LiquidGlass.Presets.Modal,
		customConfig or {}
	)
	
	return LiquidGlass.new(config)
end

--[=[
    Creates a LiquidGlass status badge.
    
    @param text string -- Badge text
    @param color Color3? -- Badge tint color
    @param customConfig LiquidGlassConfig? -- Configuration overrides
    @return LiquidGlassInstance -- The created badge
]=]
function LiquidGlass.CreateStatusBadge(
	text: string,
	color: Color3?,
	customConfig: LiquidGlassConfig?
): LiquidGlassInstance
	local baseConfig = LiquidGlass._mergeConfigs(
		LiquidGlass.Presets.StatusBadge,
		customConfig or {}
	)
	
	-- Apply color if provided
	if color then
		baseConfig.Frost = baseConfig.Frost or {}
		baseConfig.Frost.TintColor = color
	end
	
	local element = LiquidGlass.new(baseConfig)
	
	-- Create text label
	local label = Instance.new("TextLabel")
	label.Name = "BadgeLabel"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextSize = 11
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextYAlignment = Enum.TextYAlignment.Center
	
	element:SetContent(label)
	
	return element
end

--[=[
    Helper to merge two config tables.
    
    @param base LiquidGlassConfig -- Base configuration
    @param override LiquidGlassConfig -- Override configuration
    @return LiquidGlassConfig -- Merged configuration
]=]
function LiquidGlass._mergeConfigs(
	base: LiquidGlassConfig,
	override: LiquidGlassConfig
): LiquidGlassConfig
	local function deepMerge(a: any, b: any): any
		if type(a) ~= "table" or type(b) ~= "table" then
			return if b ~= nil then b else a
		end
		
		local result = {}
		for key, value in pairs(a) do
			result[key] = deepMerge(value, b[key])
		end
		for key, value in pairs(b) do
			if result[key] == nil then
				result[key] = value
			end
		end
		return result
	end
	
	return deepMerge(base, override)
end

--// ═══════════════════════════════════════════════════════════════════════════════
--// SECTION 29: MODULE EXPORT (COMPLETE LIBRARY)
--// ═══════════════════════════════════════════════════════════════════════════════

--[[
    This completes the LiquidGlass Pro library.
    
    COMPLETE API:
    
    -- Main class
    LiquidGlass.new(config) -> LiquidGlassInstance
    
    -- Factory methods
    LiquidGlass.CreateButton(text, onClick, config)
    LiquidGlass.CreateCard(config)
    LiquidGlass.CreatePill(text, config)
    LiquidGlass.CreatePanel(config)
    LiquidGlass.CreateModal(config)
    LiquidGlass.CreateStatusBadge(text, color, config)
    
    -- Presets
    LiquidGlass.Presets.Default
    LiquidGlass.Presets.Button
    LiquidGlass.Presets.Card
    LiquidGlass.Presets.Pill
    LiquidGlass.Presets.StatusBadge
    LiquidGlass.Presets.Panel
    LiquidGlass.Presets.Modal
    LiquidGlass.Presets.Toolbar
    
    -- Instance methods
    instance:SetContent(content)
    instance:SetProperty(key, value)
    instance:GetFrame()
    instance:GetContentFrame()
    instance:IsHovered()
    instance:IsPressed()
    instance:SetEnabled(enabled)
    instance:SetVisible(visible)
    instance:TweenProperty(property, value, duration)
    instance:GetConfig()
    instance:Destroy()
    
    -- Utilities (exported for advanced usage)
    LiquidGlass.Math
    LiquidGlass.Color
    LiquidGlass.Gradient
    LiquidGlass.Animation
    LiquidGlass.Spring
    LiquidGlass.Instance
    LiquidGlass.Layers.*
    LiquidGlass.SpringAnimations
    LiquidGlass.LayerUpdates
]]

return {
	-- Version info
	VERSION = Constants.VERSION,
	BUILD_DATE = Constants.BUILD_DATE,
	
	-- Main class constructor
	new = LiquidGlass.new,
	
	-- Factory methods
	CreateButton = LiquidGlass.CreateButton,
	CreateCard = LiquidGlass.CreateCard,
	CreatePill = LiquidGlass.CreatePill,
	CreatePanel = LiquidGlass.CreatePanel,
	CreateModal = LiquidGlass.CreateModal,
	CreateStatusBadge = LiquidGlass.CreateStatusBadge,
	
	-- Presets
	Presets = LiquidGlass.Presets,
	
	-- Constants
	Constants = Constants,
	
	-- Utilities (for advanced usage)
	Math = MathUtils,
	Color = ColorUtils,
	Gradient = GradientUtils,
	Animation = AnimationUtils,
	Spring = SpringPhysics,
	Instance = InstanceUtils,
	
	-- Layer Builders (for custom implementations)
	Layers = {
		Frost = FrostLayerBuilder,
		Chromatic = ChromaticLayerBuilder,
		Refraction = RefractionLayerBuilder,
		Border = BorderLayerBuilder,
		Shadow = ShadowLayerBuilder,
		Hover = HoverLayerBuilder,
		InnerGlow = InnerGlowLayerBuilder,
		Background = BackgroundLayerBuilder,
		Content = ContentContainerBuilder,
		Input = InputHandlerBuilder,
		Builder = LayerBuilder,
	},
	
	-- Animation systems
	SpringAnimations = SpringAnimations,
	LayerUpdates = LayerUpdateUtils,
	
	-- Type exports (for documentation/autocomplete)
	Types = {
		SpringConfig = nil :: SpringConfig?,
		ChromaticConfig = nil :: ChromaticConfig?,
		RefractionConfig = nil :: RefractionConfig?,
		FrostConfig = nil :: FrostConfig?,
		BorderGradientConfig = nil :: BorderGradientConfig?,
		DepthConfig = nil :: DepthConfig?,
		InteractionConfig = nil :: InteractionConfig?,
		LiquidGlassConfig = nil :: LiquidGlassConfig?,
		CompleteLayerRefs = nil :: CompleteLayerRefs?,
		SpringAnimatorState = nil :: SpringAnimatorState?,
		LiquidGlassInstance = nil :: LiquidGlassInstance?,
	},
}
