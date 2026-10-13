--=====================================================================
--  0nyx Hub  •  ENHANCED EDITION (Xeno fix)
--=====================================================================

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local VirtualUser      = game:GetService("VirtualUser")
local Lighting         = game:GetService("Lighting")
local HttpService      = game:GetService("HttpService")
local TeleportService  = game:GetService("TeleportService")
local SoundService     = game:GetService("SoundService")

local player = Players.LocalPlayer
local mouse  = player:GetMouse()

-- optional Drawing API (for tracers)
local DrawingLib
do
	local ok, d = pcall(function() return Drawing end)
	if ok and d then DrawingLib = d end
end

local THEME = {
	bg      = Color3.fromRGB(9,9,13),
	panel   = Color3.fromRGB(18,18,24),
	panel2  = Color3.fromRGB(24,24,32),
	stroke  = Color3.fromRGB(48,48,62),
	accent  = Color3.fromRGB(168,120,255),
	accent2 = Color3.fromRGB(96,170,255),
	text    = Color3.fromRGB(234,234,244),
	sub     = Color3.fromRGB(148,148,166),
}

local gui = Instance.new("ScreenGui")
gui.Name = "0nyxhub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

--=====================================================================
--  UI HELPERS
--=====================================================================
local function corner(o, r)
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r); c.Parent = o; return c
end
local function outline(o, col, tr, th)
	local s = Instance.new("UIStroke"); s.Color = col; s.Transparency = tr or 0
	s.Thickness = th or 1; s.Parent = o; return s
end
local function glow(o, col, size)
	local s = Instance.new("UIStroke"); s.Name = "TextGlow"; s.Color = col
	s.Transparency = 0.5; s.Thickness = size or 2
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual; s.Parent = o; return s
end
local function gradient(o, c1, c2, rot)
	local g = Instance.new("UIGradient"); g.Color = ColorSequence.new(c1, c2)
	g.Rotation = rot or 0; g.Parent = o; return g
end
local function pad(parent, all)
	local p = Instance.new("UIPadding")
	p.PaddingTop = UDim.new(0, all); p.PaddingBottom = UDim.new(0, all)
	p.PaddingLeft = UDim.new(0, all); p.PaddingRight = UDim.new(0, all)
	p.Parent = parent; return p
end
local function listLayout(parent, gap)
	local l = Instance.new("UIListLayout"); l.Padding = UDim.new(0, gap)
	l.SortOrder = Enum.SortOrder.LayoutOrder; l.Parent = parent; return l
end
local function addHover(btn, baseCol, hoverCol)
	local base = baseCol or btn.BackgroundColor3
	local hover = hoverCol or Color3.fromRGB(
		math.min(255, base.R + 22), math.min(255, base.G + 22), math.min(255, base.B + 22))
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.14), { BackgroundColor3 = hover }):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.14), { BackgroundColor3 = base }):Play()
	end)
end
local function addRipple(btn)
	btn.ClipsDescendants = true
	btn.MouseButton1Down:Connect(function()
		local r = Instance.new("Frame")
		r.Size = UDim2.new(0, 6, 0, 6)
		r.Position = UDim2.new(0.5, -3, 0.5, -3)
		r.BackgroundColor3 = Color3.fromRGB(255,255,255)
		r.BackgroundTransparency = 0.6
		r.BorderSizePixel = 0
		r.ZIndex = (btn.ZIndex or 1) + 1
		r.Parent = btn
		corner(r, 999)
		TweenService:Create(r, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(1.4, 0, 2.6, 0),
			Position = UDim2.new(-0.2, 0, -0.8, 0),
			BackgroundTransparency = 1,
		}):Play()
		task.delay(0.36, function() if r.Parent then r:Destroy() end end)
	end)
end

--=====================================================================
--  TOASTS
--=====================================================================
local toastHolder = Instance.new("Frame")
toastHolder.Name = "Toasts"
toastHolder.Size = UDim2.new(0, 240, 0, 400)
toastHolder.Position = UDim2.new(1, -252, 0.5, -200)
toastHolder.BackgroundTransparency = 1
toastHolder.ZIndex = 150
toastHolder.Parent = gui
local toastLayout = Instance.new("UIListLayout")
toastLayout.Padding = UDim.new(0, 6)
toastLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
toastLayout.VerticalAlignment = Enum.VerticalAlignment.Center
toastLayout.SortOrder = Enum.SortOrder.LayoutOrder
toastLayout.Parent = toastHolder

local toastOrder = 0
local function notify(text, col)
	toastOrder += 1
	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(1, 0, 0, 30)
	t.BackgroundColor3 = THEME.panel
	t.BackgroundTransparency = 0.05
	t.BorderSizePixel = 0
	t.Text = "  " .. text
	t.Font = Enum.Font.GothamMedium
	t.TextSize = 11
	t.TextColor3 = THEME.text
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.LayoutOrder = toastOrder
	t.ZIndex = 151
	t.Parent = toastHolder
	corner(t, 7)
	local st = outline(t, col or THEME.accent, 0.35, 1)
	local accentBar = Instance.new("Frame")
	accentBar.Size = UDim2.new(0, 3, 1, -10)
	accentBar.Position = UDim2.new(0, 6, 0, 5)
	accentBar.BackgroundColor3 = col or THEME.accent
	accentBar.BorderSizePixel = 0
	accentBar.ZIndex = 152
	accentBar.Parent = t
	corner(accentBar, 3)
	t.Position = UDim2.new(1, 60, 0, 0)
	TweenService:Create(t, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Position = UDim2.new(0, 0, 0, 0) }):Play()
	task.delay(2.2, function()
		if not t.Parent then return end
		TweenService:Create(t, TweenInfo.new(0.25), {
			Position = UDim2.new(1, 60, 0, 0), BackgroundTransparency = 1, TextTransparency = 1 }):Play()
		st.Transparency = 1
		accentBar.BackgroundTransparency = 1
		task.delay(0.3, function() if t.Parent then t:Destroy() end end)
	end)
end

--=====================================================================
--  WATERMARK + HUD
--=====================================================================
local watermark = Instance.new("TextLabel")
watermark.BackgroundTransparency = 1
watermark.Position = UDim2.new(0, 12, 0, 8)
watermark.Size = UDim2.new(0, 400, 0, 18)
watermark.Text = "0nyxhub  •  " .. tostring(game.PlaceId)
watermark.Font = Enum.Font.GothamBold
watermark.TextSize = 12
watermark.TextColor3 = Color3.fromRGB(255,255,255)
watermark.TextTransparency = 0.35
watermark.TextXAlignment = Enum.TextXAlignment.Left
watermark.ZIndex = 30
watermark.Parent = gui

local hud = Instance.new("TextLabel")
hud.BackgroundTransparency = 1
hud.Position = UDim2.new(0, 12, 1, -28)
hud.Size = UDim2.new(0, 400, 0, 18)
hud.Text = "FPS 60 | PING 0ms"
hud.Font = Enum.Font.GothamBold
hud.TextSize = 12
hud.TextColor3 = THEME.accent
hud.TextTransparency = 0.2
hud.TextXAlignment = Enum.TextXAlignment.Left
hud.ZIndex = 30
hud.Visible = false
hud.Parent = gui

--=====================================================================
--  DRAGGING / DIALOGS
--=====================================================================
local dragConnections = {}
local function makeDraggable(object, handle)
	local dragging, dragStart, startPosition = false, nil, nil
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPosition = object.Position
			object:SetAttribute("Dragged", false)
		end
	end)
	handle.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	if dragConnections[handle] then dragConnections[handle]:Disconnect() end
	dragConnections[handle] = UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			local delta = input.Position - dragStart
			if math.abs(delta.X) > 3 or math.abs(delta.Y) > 3 then
				object:SetAttribute("Dragged", true)
			end
			object.Position = UDim2.new(
				startPosition.X.Scale, startPosition.X.Offset + delta.X,
				startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
		end
	end)
end

local function createWindowsDialog(titleText, messageText)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 330, 0, 168)
	frame.BackgroundColor3 = Color3.fromRGB(240,240,240)
	frame.BorderSizePixel = 0
	frame.ZIndex = 200
	corner(frame, 7)
	outline(frame, Color3.fromRGB(110,110,110), 0, 1)

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(1,0,0,28)
	bar.BackgroundColor3 = Color3.fromRGB(0,88,238)
	bar.BorderSizePixel = 0
	bar.ZIndex = 201
	bar.Parent = frame
	corner(bar, 7)
	gradient(bar, Color3.fromRGB(0,88,238), Color3.fromRGB(61,139,255))

	local barTitle = Instance.new("TextLabel")
	barTitle.BackgroundTransparency = 1
	barTitle.Position = UDim2.new(0,10,0,0)
	barTitle.Size = UDim2.new(1,-40,1,0)
	barTitle.Text = titleText
	barTitle.Font = Enum.Font.GothamBold
	barTitle.TextSize = 12
	barTitle.TextColor3 = Color3.fromRGB(255,255,255)
	barTitle.TextXAlignment = Enum.TextXAlignment.Left
	barTitle.ZIndex = 202
	barTitle.Parent = bar

	local closeX = Instance.new("TextButton")
	closeX.Size = UDim2.new(0,20,0,20)
	closeX.Position = UDim2.new(1,-24,0,4)
	closeX.BackgroundColor3 = Color3.fromRGB(230,80,70)
	closeX.BorderSizePixel = 0
	closeX.Text = "X"
	closeX.Font = Enum.Font.GothamBold
	closeX.TextSize = 11
	closeX.TextColor3 = Color3.fromRGB(255,255,255)
	closeX.ZIndex = 202
	closeX.Parent = bar
	corner(closeX, 4)

	local icon = Instance.new("Frame")
	icon.Size = UDim2.new(0,34,0,34)
	icon.Position = UDim2.new(0,16,0,46)
	icon.BackgroundColor3 = Color3.fromRGB(220,50,45)
	icon.BorderSizePixel = 0
	icon.ZIndex = 202
	icon.Parent = frame
	corner(icon, 17)

	local iconX = Instance.new("TextLabel")
	iconX.BackgroundTransparency = 1
	iconX.Size = UDim2.new(1,0,1,0)
	iconX.Text = "X"
	iconX.Font = Enum.Font.GothamBold
	iconX.TextSize = 19
	iconX.TextColor3 = Color3.fromRGB(255,255,255)
	iconX.ZIndex = 203
	iconX.Parent = icon

	local message = Instance.new("TextLabel")
	message.BackgroundTransparency = 1
	message.Position = UDim2.new(0,60,0,46)
	message.Size = UDim2.new(1,-76,0,70)
	message.Text = messageText
	message.Font = Enum.Font.GothamMedium
	message.TextSize = 11
	message.TextColor3 = Color3.fromRGB(20,20,20)
	message.TextWrapped = true
	message.TextXAlignment = Enum.TextXAlignment.Left
	message.TextYAlignment = Enum.TextYAlignment.Top
	message.ZIndex = 202
	message.Parent = frame

	return frame, closeX
end

local function dialogButton(parent, text, xOffset)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0,84,0,28)
	b.Position = UDim2.new(1, xOffset, 1, -38)
	b.BackgroundColor3 = Color3.fromRGB(225,225,225)
	b.BorderSizePixel = 0
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 11
	b.TextColor3 = Color3.fromRGB(20,20,20)
	b.ZIndex = 202
	b.Parent = parent
	corner(b, 5)
	outline(b, Color3.fromRGB(140,140,140), 0, 1)
	return b
end

--=====================================================================
--  OVERLAYS
--=====================================================================
local damageOverlay = Instance.new("Frame")
damageOverlay.Name = "DamageOverlay"
damageOverlay.Size = UDim2.new(1,0,1,0)
damageOverlay.BackgroundColor3 = Color3.fromRGB(255,25,25)
damageOverlay.BackgroundTransparency = 1
damageOverlay.BorderSizePixel = 0
damageOverlay.ZIndex = 40
damageOverlay.Parent = gui

local function flashDamage()
	damageOverlay.BackgroundTransparency = 0.7
	TweenService:Create(damageOverlay, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 1 }):Play()
end

local hitmarker = Instance.new("TextLabel")
hitmarker.BackgroundTransparency = 1
hitmarker.Position = UDim2.new(0.5, -12, 0.5, -14)
hitmarker.Size = UDim2.new(0, 24, 0, 24)
hitmarker.Text = "X"
hitmarker.Font = Enum.Font.GothamBold
hitmarker.TextSize = 20
hitmarker.TextColor3 = Color3.fromRGB(255,255,255)
hitmarker.TextTransparency = 1
hitmarker.ZIndex = 45
hitmarker.Parent = gui

local function showHitmarker()
	hitmarker.TextTransparency = 0
	hitmarker.Rotation = 45
	TweenService:Create(hitmarker, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ TextTransparency = 1, Rotation = 90 }):Play()
end

local voidFlash = Instance.new("Frame")
voidFlash.Size = UDim2.new(1,0,1,0)
voidFlash.BackgroundColor3 = Color3.fromRGB(255,255,255)
voidFlash.BackgroundTransparency = 1
voidFlash.BorderSizePixel = 0
voidFlash.ZIndex = 60
voidFlash.Parent = gui

local voidCover = Instance.new("Frame")
voidCover.Size = UDim2.new(1,0,1,0)
voidCover.BackgroundColor3 = Color3.fromRGB(7,7,7)
voidCover.BackgroundTransparency = 1
voidCover.BorderSizePixel = 0
voidCover.Visible = false
voidCover.ZIndex = 61
voidCover.Parent = gui

local function addRescueOrb(size, position, fillColor, ft, st)
	local orb = Instance.new("Frame")
	orb.Size = size; orb.Position = position
	orb.BackgroundColor3 = fillColor; orb.BackgroundTransparency = ft
	orb.BorderSizePixel = 0; orb.ZIndex = 61; orb.Parent = voidCover
	corner(orb, 999)
	outline(orb, Color3.fromRGB(210,210,210), st, 1)
end
addRescueOrb(UDim2.new(0,220,0,220), UDim2.new(0.64,0,0.08,0), Color3.fromRGB(255,255,255), 0.96, 0.76)
addRescueOrb(UDim2.new(0,150,0,150), UDim2.new(0.20,0,0.62,0), Color3.fromRGB(190,190,190), 0.97, 0.84)
addRescueOrb(UDim2.new(0,70,0,70),  UDim2.new(0.78,0,0.70,0), Color3.fromRGB(255,255,255), 0.94, 0.82)

local voidTitle = Instance.new("TextLabel")
voidTitle.BackgroundTransparency = 1
voidTitle.Position = UDim2.new(0,0,0.5,-40)
voidTitle.Size = UDim2.new(1,0,0,45)
voidTitle.Text = "VOID RESCUE"
voidTitle.Font = Enum.Font.GothamBlack
voidTitle.TextSize = 40
voidTitle.TextColor3 = Color3.fromRGB(255,255,255)
voidTitle.TextTransparency = 1
voidTitle.Visible = false
voidTitle.ZIndex = 63
voidTitle.Parent = voidCover
local voidTitleStroke = glow(voidTitle, Color3.fromRGB(255,255,255), 3)
voidTitleStroke.Transparency = 1

local voidSub = Instance.new("TextLabel")
voidSub.BackgroundTransparency = 1
voidSub.Position = UDim2.new(0,0,0.5,8)
voidSub.Size = UDim2.new(1,0,0,22)
voidSub.Text = "Returning you to safety"
voidSub.Font = Enum.Font.Gotham
voidSub.TextSize = 13
voidSub.TextColor3 = Color3.fromRGB(200,200,200)
voidSub.TextTransparency = 1
voidSub.Visible = false
voidSub.ZIndex = 63
voidSub.Parent = voidCover
local voidSubStroke = glow(voidSub, Color3.fromRGB(255,255,255), 2)
voidSubStroke.Transparency = 1

--=====================================================================
--  STATES
--=====================================================================
local states = {
	Godmode = false, InfiniteJump = false, AntiFling = false, AntiAFK = false,
	Flight = false, Noclip = false, Invisible = false, ESP = false, ESPBox = true,
	ESPNames = false, Fullbright = false, HighJump = false, Freeze = false,
	NoDamage = false, TeleportTool = false, ClickTeleport = false, Aimbot = false,
	AntiKick = false, AntiBan = false,
	Sprint = false, DoubleJump = false, LowGravity = false, Hover = false,
	SwimAnywhere = false, NoFallDamage = false, BunnyHop = false,
	PlatformStand = false, Spin = false, FaceCamera = false,
	HealthRegen = false, Immortal = false, NoRagdoll = false, NoCameraShake = false,
	FastRespawn = false, HitboxExpander = false, AntiVoid = false,
	HighlightESP = false, TracerESP = false, DistanceESP = false, HealthESP = false,
	Crosshair = false, SelfHighlight = false, RemoveFog = false, NoTextures = false,
	NoShadows = false, NoBloom = false, FPSHud = false,
	AutoClicker = false, KillAura = false, Reach = false, FastAttack = false,
	AutoEquip = false, DamageIndicator = false,
	FreeCam = false,
}

local walkSpeed   = 16
local flightSpeed = 50
local jumpPower   = 100
local aim         = { fov = 150, smooth = 0.25 }

local cfg = {
	regenRate = 4, hitboxSize = 6, gravity = 196, spinSpeed = 8,
	scale = 1, hipHeight = nil, reach = 1.6, clickDelay = 0.05,
	killAuraRange = 25, fov = 70,
}

local conn = {}
local saved = {
	noclip = {}, transparency = {}, reach = {},
	god = setmetatable({}, {__mode = "k"}),
	jump = setmetatable({}, {__mode = "k"}),
	hitbox = setmetatable({}, {__mode = "k"}),
}

local closed, fullscreenEnabled = false, false
local currentAnimationPack = "Default"
local customAnimationEnabled = false
local animationTracks = {}
local animationConnections = {}
local currentAnimationName, animationGeneration, animationLoopConnection = nil, 0, nil
local VOID_Y = -75
local lastSafePos, voidBusy = nil, false
local espSelected = {}
local frozenPlayers = {}
local jumpsLeft, maxJumps = 2, 2

--=====================================================================
--  MAIN WINDOW
--=====================================================================
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 560, 0, 420)
main.Position = UDim2.new(0.5, -280, 0.5, -210)
main.BackgroundColor3 = THEME.bg
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Visible = false
main.ZIndex = 1
main.Parent = gui
corner(main, 14)
outline(main, THEME.stroke, 0.15, 1)
gradient(main, Color3.fromRGB(12,12,18), Color3.fromRGB(7,7,11), 90)

local uiScale = Instance.new("UIScale")
uiScale.Scale = 1
uiScale.Parent = main

local cameraConnections = {}
local function updateScale()
	local cam = workspace.CurrentCamera
	if not cam then return end
	local w = cam.ViewportSize.X
	if w <= 360 then uiScale.Scale = 0.6
	elseif w <= 480 then uiScale.Scale = 0.72
	elseif w <= 700 then uiScale.Scale = 0.86
	else uiScale.Scale = 1 end
end
updateScale()

local function connectCamera()
	for _, c in ipairs(cameraConnections) do if c then c:Disconnect() end end
	table.clear(cameraConnections)
	local cam = workspace.CurrentCamera
	if cam then
		table.insert(cameraConnections, cam:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale))
	end
end
connectCamera()
local currentCameraConnection = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	task.wait(); updateScale(); connectCamera()
end)

-- background fx
local backgroundFX = Instance.new("Frame")
backgroundFX.Size = UDim2.new(1,0,1,0)
backgroundFX.BackgroundTransparency = 1
backgroundFX.ClipsDescendants = true
backgroundFX.ZIndex = 1
backgroundFX.Parent = main

local function makeOrb(size, pos, col, tr, edge, dur, toPos)
	local o = Instance.new("Frame")
	o.Size = size; o.Position = pos
	o.BackgroundColor3 = col; o.BackgroundTransparency = tr
	o.BorderSizePixel = 0; o.ZIndex = 1; o.Parent = backgroundFX
	corner(o, 999); outline(o, edge, 0.75, 1)
	TweenService:Create(o, TweenInfo.new(dur, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{ Position = toPos, BackgroundTransparency = math.min(0.97, tr + 0.03) }):Play()
end
makeOrb(UDim2.new(0,230,0,230), UDim2.new(0.62,0,0,0), THEME.accent, 0.9, THEME.accent, 8, UDim2.new(0.52,0,0.2,0))
makeOrb(UDim2.new(0,150,0,150), UDim2.new(0.18,0,0.6,0), THEME.accent2, 0.92, THEME.accent2, 10, UDim2.new(0.32,0,0.44,0))
makeOrb(UDim2.new(0,80,0,80),  UDim2.new(0.8,0,0.7,0), Color3.fromRGB(255,255,255), 0.88, Color3.fromRGB(255,255,255), 6, UDim2.new(0.72,0,0.6,0))

local function floatParticle()
	local p = Instance.new("Frame")
	local s = math.random(2,5)
	p.Size = UDim2.new(0,s,0,s)
	p.Position = UDim2.new(math.random(5,95)/100, 0, 1.08, 0)
	p.BackgroundColor3 = Color3.fromRGB(255,255,255)
	p.BackgroundTransparency = 1
	p.BorderSizePixel = 0
	p.ZIndex = 2
	p.Parent = backgroundFX
	corner(p, s)
	local dur = math.random(7,13)
	local sx = p.Position.X.Scale
	local ex = math.clamp(sx + math.random(-15,15)/100, 0.02, 0.98)
	TweenService:Create(p, TweenInfo.new(1.5), { BackgroundTransparency = math.random(15,40)/100 }):Play()
	local mv = TweenService:Create(p, TweenInfo.new(dur, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		{ Position = UDim2.new(ex, 0, -0.12, 0) })
	task.delay(1.3, function() if p.Parent then mv:Play() end end)
	task.delay(dur - 2, function()
		if p.Parent then TweenService:Create(p, TweenInfo.new(2), { BackgroundTransparency = 1 }):Play() end
	end)
	mv.Completed:Connect(function() if p.Parent then p:Destroy() end end)
end

task.spawn(function()
	while gui.Parent do floatParticle(); task.wait(0.18) end
end)

--=====================================================================
--  SIDEBAR / TOP
--=====================================================================
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 145, 1, 0)
sidebar.BackgroundColor3 = THEME.bg
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 5
sidebar.Parent = main
corner(sidebar, 14)
gradient(sidebar, Color3.fromRGB(14,14,20), Color3.fromRGB(8,8,12), 90)

local sidebarCover = Instance.new("Frame")
sidebarCover.Size = UDim2.new(0,15,1,0)
sidebarCover.Position = UDim2.new(1,-15,0,0)
sidebarCover.BackgroundColor3 = THEME.bg
sidebarCover.BorderSizePixel = 0
sidebarCover.ZIndex = 5
sidebarCover.Parent = sidebar

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.new(0,16,0,14)
title.Size = UDim2.new(0,120,0,30)
title.Text = "0nyxhub"
title.Font = Enum.Font.GothamBlack
title.TextSize = 22
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 6
title.Parent = sidebar
glow(title, THEME.accent, 3)
gradient(title, Color3.fromRGB(255,255,255), THEME.accent, 20)

local subtitle = Instance.new("TextLabel")
subtitle.BackgroundTransparency = 1
subtitle.Position = UDim2.new(0,17,0,42)
subtitle.Size = UDim2.new(0,120,0,16)
subtitle.Text = "ENHANCED EDITION"
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 8
subtitle.TextColor3 = THEME.sub
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.ZIndex = 6
subtitle.Parent = sidebar

local pageButtons, pageFrames = {}, {}
local activeIndicator = Instance.new("Frame")
activeIndicator.Size = UDim2.new(0, 3, 0, 18)
activeIndicator.BackgroundColor3 = THEME.accent
activeIndicator.BorderSizePixel = 0
activeIndicator.ZIndex = 7
activeIndicator.Parent = sidebar
corner(activeIndicator, 3)
gradient(activeIndicator, THEME.accent, THEME.accent2, 90)

local function createPageButton(name, index)
	local b = Instance.new("TextButton")
	b.Name = name
	b.Size = UDim2.new(0, 120, 0, 28)
	b.Position = UDim2.new(0, 12, 0, 66 + ((index-1) * 30))
	b.BackgroundColor3 = Color3.fromRGB(24,24,32)
	b.BackgroundTransparency = 1
	b.BorderSizePixel = 0
	b.Text = name
	b.Font = Enum.Font.GothamMedium
	b.TextSize = 10
	b.TextColor3 = THEME.sub
	b.TextXAlignment = Enum.TextXAlignment.Left
	b.ZIndex = 6
	b.Parent = sidebar
	corner(b, 7)
	local p = Instance.new("UIPadding"); p.PaddingLeft = UDim.new(0, 12); p.Parent = b
	addHover(b, Color3.fromRGB(24,24,32), Color3.fromRGB(34,34,46))
	pageButtons[name] = b
	return b
end
for i, name in ipairs({"Home","Player","Movement","Visuals","Combat","Players","World","Teleport","Animations","Emotes","Settings"}) do
	createPageButton(name, i)
end

local top = Instance.new("Frame")
top.Size = UDim2.new(1, -145, 0, 58)
top.Position = UDim2.new(0, 145, 0, 0)
top.BackgroundTransparency = 1
top.ZIndex = 5
top.Parent = main

local topTitle = Instance.new("TextLabel")
topTitle.BackgroundTransparency = 1
topTitle.Position = UDim2.new(0, 20, 0, 10)
topTitle.Size = UDim2.new(0, 220, 0, 25)
topTitle.Text = "Home"
topTitle.Font = Enum.Font.GothamBold
topTitle.TextSize = 17
topTitle.TextColor3 = Color3.fromRGB(255,255,255)
topTitle.TextXAlignment = Enum.TextXAlignment.Left
topTitle.ZIndex = 6
topTitle.Parent = top
glow(topTitle, THEME.accent, 3)

local topSub = Instance.new("TextLabel")
topSub.BackgroundTransparency = 1
topSub.Position = UDim2.new(0, 20, 0, 32)
topSub.Size = UDim2.new(0, 220, 0, 18)
topSub.Text = "Control Panel"
topSub.Font = Enum.Font.Gotham
topSub.TextSize = 9
topSub.TextColor3 = THEME.sub
topSub.TextXAlignment = Enum.TextXAlignment.Left
topSub.ZIndex = 6
topSub.Parent = top

local function windowButton(text, xOff, hoverCol)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 32, 0, 28)
	b.Position = UDim2.new(1, xOff, 0, 14)
	b.BackgroundColor3 = THEME.panel2
	b.BorderSizePixel = 0
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	b.TextColor3 = Color3.fromRGB(220,220,220)
	b.ZIndex = 6
	b.Parent = top
	corner(b, 6); outline(b, THEME.stroke, 0.2, 1)
	addHover(b, THEME.panel2, hoverCol or Color3.fromRGB(40,40,54))
	addRipple(b)
	return b
end
local fullscreen  = windowButton("□", -112)
local minimize    = windowButton("—", -75)
local closeButton = windowButton("X", -38, Color3.fromRGB(180,60,60))

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -165, 1, -72)
content.Position = UDim2.new(0, 158, 0, 65)
content.BackgroundTransparency = 1
content.ZIndex = 5
content.Parent = main

local function createPage(name)
	local f = Instance.new("ScrollingFrame")
	f.Name = name .. "Page"
	f.Size = UDim2.new(1,0,1,0)
	f.BackgroundTransparency = 1
	f.BorderSizePixel = 0
	f.Visible = false
	f.ScrollBarThickness = 4
	f.ScrollBarImageColor3 = THEME.accent
	f.CanvasSize = UDim2.new(0,0,0,0)
	f.AutomaticCanvasSize = Enum.AutomaticSize.Y
	f.ZIndex = 5
	f.Parent = content
	pageFrames[name] = f
	return f
end

--=====================================================================
--  COMPONENTS
--=====================================================================
local toggleRefreshers = {}

local function createSection(parent, text, y)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.new(0, 0, 0, y)
	label.Size = UDim2.new(1, 0, 0, 22)
	label.Text = text
	label.Font = Enum.Font.GothamBold
	label.TextSize = 10
	label.TextColor3 = THEME.sub
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 6
	label.Parent = parent
	glow(label, THEME.accent, 2)
	local line = Instance.new("Frame")
	line.Position = UDim2.new(0, 0, 0, y + 22)
	line.Size = UDim2.new(1, 0, 0, 1)
	line.BackgroundColor3 = THEME.stroke
	line.BackgroundTransparency = 0.5
	line.BorderSizePixel = 0
	line.ZIndex = 6
	line.Parent = parent
	gradient(line, THEME.accent, Color3.fromRGB(0,0,0), 0)
	return label
end

local function createToggle(parent, text, y, key)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, 0, 0, 42)
	holder.Position = UDim2.new(0, 0, 0, y)
	holder.BackgroundColor3 = THEME.panel
	holder.BorderSizePixel = 0
	holder.ZIndex = 6
	holder.Parent = parent
	corner(holder, 8); outline(holder, THEME.stroke, 0.4, 1)
	addHover(holder, THEME.panel, THEME.panel2)

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.new(0, 12, 0, 0)
	label.Size = UDim2.new(1, -70, 1, 0)
	label.Text = text
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 11
	label.TextColor3 = THEME.text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 7
	label.Parent = holder

	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.new(0, 36, 0, 19)
	toggle.Position = UDim2.new(1, -48, 0.5, -9)
	toggle.BackgroundColor3 = Color3.fromRGB(35,35,44)
	toggle.BorderSizePixel = 0
	toggle.Text = ""
	toggle.ZIndex = 7
	toggle.Parent = holder
	corner(toggle, 10)

	local circle = Instance.new("Frame")
	circle.Size = UDim2.new(0, 13, 0, 13)
	circle.Position = UDim2.new(0, 3, 0.5, -6.5)
	circle.BackgroundColor3 = Color3.fromRGB(160,160,160)
	circle.BorderSizePixel = 0
	circle.ZIndex = 8
	circle.Parent = toggle
	corner(circle, 10)

	local function update(announce)
		local enabled = states[key]
		TweenService:Create(toggle, TweenInfo.new(0.15), {
			BackgroundColor3 = enabled and THEME.accent or Color3.fromRGB(35,35,44) }):Play()
		TweenService:Create(circle, TweenInfo.new(0.15), {
			Position = enabled and UDim2.new(1,-16,0.5,-6.5) or UDim2.new(0,3,0.5,-6.5),
			BackgroundColor3 = enabled and Color3.fromRGB(12,12,16) or Color3.fromRGB(160,160,160) }):Play()
		if announce then
			notify(text .. (enabled and "  •  ON" or "  •  OFF"), enabled and THEME.accent or Color3.fromRGB(90,90,110))
		end
	end

	toggle.MouseButton1Click:Connect(function()
		states[key] = not states[key]
		update(true)
	end)
	toggleRefreshers[key] = update
	update(false)
	return holder, toggle
end

local function createSlider(parent, text, y, defaultValue, minValue, maxValue, callback, suffix)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, 0, 0, 52)
	holder.Position = UDim2.new(0, 0, 0, y)
	holder.BackgroundColor3 = THEME.panel
	holder.BorderSizePixel = 0
	holder.ZIndex = 6
	holder.Parent = parent
	corner(holder, 8); outline(holder, THEME.stroke, 0.4, 1)

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.new(0, 12, 0, 6)
	label.Size = UDim2.new(1, -90, 0, 16)
	label.Text = text
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 11
	label.TextColor3 = THEME.text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 7
	label.Parent = holder

	local valueLabel = Instance.new("TextLabel")
	valueLabel.BackgroundTransparency = 1
	valueLabel.Position = UDim2.new(1, -84, 0, 6)
	valueLabel.Size = UDim2.new(0, 72, 0, 16)
	valueLabel.Text = tostring(defaultValue)
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextSize = 11
	valueLabel.TextColor3 = THEME.accent
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.ZIndex = 7
	valueLabel.Parent = holder

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, -24, 0, 6)
	track.Position = UDim2.new(0, 12, 0, 32)
	track.BackgroundColor3 = Color3.fromRGB(38,38,48)
	track.BorderSizePixel = 0
	track.ZIndex = 7
	track.Parent = holder
	corner(track, 3)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = THEME.accent
	fill.BorderSizePixel = 0
	fill.ZIndex = 8
	fill.Parent = track
	corner(fill, 3); gradient(fill, THEME.accent, THEME.accent2, 0)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 14, 0, 14)
	knob.Position = UDim2.new(0, -7, 0.5, -7)
	knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
	knob.BorderSizePixel = 0
	knob.ZIndex = 9
	knob.Parent = track
	corner(knob, 999)

	local current = defaultValue
	local dragging = false

	local function setValue(v, fire)
		v = math.clamp(v, minValue, maxValue)
		current = v
		local alpha = (v - minValue) / (maxValue - minValue)
		fill.Size = UDim2.new(alpha, 0, 1, 0)
		knob.Position = UDim2.new(alpha, -7, 0.5, -7)
		valueLabel.Text = tostring(math.floor(v * 100 + 0.5) / 100) .. (suffix or "")
		if fire then callback(v) end
	end
	local function fromMouse(x)
		local rel = (x - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X)
		setValue(minValue + rel * (maxValue - minValue), true)
	end
	knob.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
		end
	end)
	track.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			fromMouse(i.Position.X)
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if not dragging then return end
		if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
			fromMouse(i.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	setValue(defaultValue, false)
	return holder, setValue
end

local function createButton(parent, text, y, callback, opts)
	opts = opts or {}
	local wScale = opts.width
	if wScale == nil then wScale = 1 end
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(wScale, opts.wx or 0, 0, opts.height or 32)
	b.Position = UDim2.new(opts.x or 0, 0, 0, y)
	b.BackgroundColor3 = opts.primary and THEME.accent or THEME.panel2
	b.BorderSizePixel = 0
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 11
	b.TextColor3 = opts.primary and Color3.fromRGB(12,12,16) or THEME.text
	b.ZIndex = 7
	b.Parent = parent
	corner(b, 7)
	if not opts.primary then outline(b, THEME.stroke, 0.3, 1) end
	addHover(b, b.BackgroundColor3, opts.primary and Color3.fromRGB(200,160,255) or Color3.fromRGB(40,40,54))
	addRipple(b)
	b.MouseButton1Click:Connect(function() pcall(callback) end)
	return b
end

--=====================================================================
--  GETTERS
--=====================================================================
local function getRoot(plr)
	local c = (plr or player).Character
	return c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Head"))
end
local function getHumanoid(plr)
	local c = (plr or player).Character
	return c and c:FindFirstChildOfClass("Humanoid")
end
local function getTool()
	local c = player.Character
	return c and c:FindFirstChildOfClass("Tool")
end

--=====================================================================
--  PAGES
--=====================================================================
local home = createPage("Home")
createSection(home, "WELCOME", 0)
local welcome = Instance.new("TextLabel")
welcome.BackgroundTransparency = 1
welcome.Position = UDim2.new(0, 0, 0, 34)
welcome.Size = UDim2.new(1, 0, 0, 42)
welcome.Text = "Welcome to 0nyxhub"
welcome.Font = Enum.Font.GothamBlack
welcome.TextSize = 26
welcome.TextColor3 = Color3.fromRGB(255,255,255)
welcome.TextXAlignment = Enum.TextXAlignment.Left
welcome.ZIndex = 6
welcome.Parent = home
glow(welcome, THEME.accent, 4)
gradient(welcome, Color3.fromRGB(255,255,255), THEME.accent2, 20)

local welcomeDesc = Instance.new("TextLabel")
welcomeDesc.BackgroundTransparency = 1
welcomeDesc.Position = UDim2.new(0, 0, 0, 78)
welcomeDesc.Size = UDim2.new(1, -10, 0, 46)
welcomeDesc.Text = "Enhanced Edition • 50+ new abilities • redesigned UI • built to work on any game."
welcomeDesc.Font = Enum.Font.Gotham
welcomeDesc.TextSize = 11
welcomeDesc.TextColor3 = THEME.sub
welcomeDesc.TextWrapped = true
welcomeDesc.TextXAlignment = Enum.TextXAlignment.Left
welcomeDesc.ZIndex = 6
welcomeDesc.Parent = home

local statLabel = Instance.new("TextLabel")
statLabel.BackgroundTransparency = 1
statLabel.Position = UDim2.new(0, 0, 0, 130)
statLabel.Size = UDim2.new(1, 0, 0, 20)
statLabel.Text = "Loaded config: None"
statLabel.Font = Enum.Font.GothamBold
statLabel.TextSize = 12
statLabel.TextColor3 = THEME.accent
statLabel.TextXAlignment = Enum.TextXAlignment.Left
statLabel.ZIndex = 6
statLabel.Parent = home

-- PLAYER
local playerPage = createPage("Player")
createSection(playerPage, "PLAYER", 0)
createToggle(playerPage, "Godmode", 30, "Godmode")
createToggle(playerPage, "Infinite Jump", 78, "InfiniteJump")
createToggle(playerPage, "Immortal", 126, "Immortal")
createToggle(playerPage, "Health Regen", 174, "HealthRegen")
createToggle(playerPage, "Anti Fling", 222, "AntiFling")
createToggle(playerPage, "Anti AFK", 270, "AntiAFK")
createToggle(playerPage, "Anti Kick", 318, "AntiKick")
createToggle(playerPage, "Anti Ban", 366, "AntiBan")
createToggle(playerPage, "No Ragdoll", 414, "NoRagdoll")
createToggle(playerPage, "No Camera Shake", 462, "NoCameraShake")
createToggle(playerPage, "Hitbox Expander", 510, "HitboxExpander")
createToggle(playerPage, "Fast Respawn", 558, "FastRespawn")
createToggle(playerPage, "Anti Void", 606, "AntiVoid")
createSlider(playerPage, "Max Health", 660, 100, 10, 100000, function(v)
	local h = getHumanoid(); if h then h.MaxHealth = v end
end)
createSlider(playerPage, "Regen Rate", 720, 4, 1, 50, function(v) cfg.regenRate = v end)
createSlider(playerPage, "Hitbox Size", 780, 6, 2, 30, function(v) cfg.hitboxSize = v end)
createSlider(playerPage, "Character Scale", 840, 1, 0.3, 5, function(v)
	cfg.scale = v
	local c = player.Character
	if c then pcall(function() c:ScaleTo(v) end) end
end)
createSlider(playerPage, "Hip Height", 900, 2, -5, 20, function(v)
	cfg.hipHeight = v
	local h = getHumanoid(); if h then h.HipHeight = v end
end)

-- MOVEMENT
local movement = createPage("Movement")
createSection(movement, "MOVEMENT", 0)
createToggle(movement, "Flight", 30, "Flight")
createToggle(movement, "Noclip", 78, "Noclip")
createToggle(movement, "High Jump", 126, "HighJump")
createToggle(movement, "Double Jump", 174, "DoubleJump")
createToggle(movement, "Sprint (Shift)", 222, "Sprint")
createToggle(movement, "Bunny Hop", 270, "BunnyHop")
createToggle(movement, "Low Gravity", 318, "LowGravity")
createToggle(movement, "Hover (Space)", 366, "Hover")
createToggle(movement, "Swim Anywhere", 414, "SwimAnywhere")
createToggle(movement, "No Fall Damage", 462, "NoFallDamage")
createToggle(movement, "Platform Stand", 510, "PlatformStand")
createToggle(movement, "Spin", 558, "Spin")
createToggle(movement, "Face Camera", 606, "FaceCamera")
createToggle(movement, "Freeze", 654, "Freeze")
createSlider(movement, "WalkSpeed", 708, 16, 0, 500, function(v) walkSpeed = v end)
createSlider(movement, "Flight Speed", 768, 50, 10, 500, function(v) flightSpeed = v end)
createSlider(movement, "Jump Power", 828, 100, 50, 1000, function(v) jumpPower = v end)
createSlider(movement, "Spin Speed", 888, 8, 1, 60, function(v) cfg.spinSpeed = v end)
createSlider(movement, "Gravity", 948, 196, 0, 500, function(v) cfg.gravity = v end)

-- VISUALS
local visuals = createPage("Visuals")
createSection(visuals, "VISUALS", 0)
createToggle(visuals, "Invisible", 30, "Invisible")
createToggle(visuals, "Fullbright", 78, "Fullbright")
createToggle(visuals, "No Damage Effect", 126, "NoDamage")
createToggle(visuals, "Player ESP", 174, "ESP")
createToggle(visuals, "ESP Box", 222, "ESPBox")
createToggle(visuals, "ESP Names", 270, "ESPNames")
createToggle(visuals, "ESP Distance", 318, "DistanceESP")
createToggle(visuals, "ESP Health Bars", 366, "HealthESP")
createToggle(visuals, "Highlight ESP", 414, "HighlightESP")
createToggle(visuals, "Tracer ESP", 462, "TracerESP")
createToggle(visuals, "Self Highlight", 510, "SelfHighlight")
createToggle(visuals, "Crosshair", 558, "Crosshair")
createToggle(visuals, "Remove Fog", 606, "RemoveFog")
createToggle(visuals, "No Shadows", 654, "NoShadows")
createToggle(visuals, "No Bloom", 702, "NoBloom")
createToggle(visuals, "No Textures", 750, "NoTextures")
createToggle(visuals, "Free Camera", 798, "FreeCam")
createToggle(visuals, "FPS / Ping HUD", 846, "FPSHud")
createSlider(visuals, "Camera FOV", 900, 70, 20, 120, function(v)
	cfg.fov = v
	local cam = workspace.CurrentCamera
	if cam and not states.FreeCam then cam.FieldOfView = v end
end)
createSlider(visuals, "Time of Day", 960, 14, 0, 24, function(v) Lighting.ClockTime = v end)

createSection(visuals, "ESP TARGETS", 1024)
local espTargetList = Instance.new("ScrollingFrame")
espTargetList.Size = UDim2.new(1, 0, 0, 160)
espTargetList.Position = UDim2.new(0, 0, 0, 1050)
espTargetList.BackgroundColor3 = Color3.fromRGB(14,14,18)
espTargetList.BackgroundTransparency = 0.15
espTargetList.BorderSizePixel = 0
espTargetList.ScrollBarThickness = 4
espTargetList.ScrollBarImageColor3 = THEME.accent
espTargetList.CanvasSize = UDim2.new(0,0,0,0)
espTargetList.AutomaticCanvasSize = Enum.AutomaticSize.Y
espTargetList.ZIndex = 7
espTargetList.Parent = visuals
corner(espTargetList, 8); outline(espTargetList, THEME.stroke, 0.25, 1)
pad(espTargetList, 6); listLayout(espTargetList, 5)

-- COMBAT
local combatPage = createPage("Combat")
createSection(combatPage, "AIMBOT", 0)
createToggle(combatPage, "Aimbot", 30, "Aimbot")
createSlider(combatPage, "Aimbot FOV", 84, 150, 20, 900, function(v) aim.fov = v end)
createSlider(combatPage, "Aimbot Smoothness %", 144, 25, 5, 100, function(v) aim.smooth = v/100 end)
createSection(combatPage, "COMBAT", 206)
createToggle(combatPage, "Auto Clicker", 236, "AutoClicker")
createToggle(combatPage, "Kill Aura", 284, "KillAura")
createToggle(combatPage, "Reach", 332, "Reach")
createToggle(combatPage, "Fast Attack", 380, "FastAttack")
createToggle(combatPage, "Auto Equip", 428, "AutoEquip")
createToggle(combatPage, "Damage Indicator", 476, "DamageIndicator")
createSlider(combatPage, "Reach Multiplier", 530, 1.6, 1, 6, function(v) cfg.reach = v end)
createSlider(combatPage, "Click Delay", 590, 0.05, 0.01, 0.5, function(v) cfg.clickDelay = v end, "s")
createSlider(combatPage, "Kill Aura Range", 650, 25, 5, 120, function(v) cfg.killAuraRange = v end)

-- PLAYERS
local playersPage = createPage("Players")
createSection(playersPage, "PLAYERS IN SERVER", 0)
local playerSearch = Instance.new("TextBox")
playerSearch.Size = UDim2.new(1, 0, 0, 28)
playerSearch.Position = UDim2.new(0, 0, 0, 26)
playerSearch.BackgroundColor3 = Color3.fromRGB(20,20,26)
playerSearch.BorderSizePixel = 0
playerSearch.Text = ""
playerSearch.PlaceholderText = "Search players..."
playerSearch.TextColor3 = THEME.text
playerSearch.TextSize = 11
playerSearch.Font = Enum.Font.Gotham
playerSearch.ClearTextOnFocus = false
playerSearch.ZIndex = 7
playerSearch.Parent = playersPage
corner(playerSearch, 6); outline(playerSearch, THEME.stroke, 0.25, 1)

local playerList = Instance.new("ScrollingFrame")
playerList.Size = UDim2.new(1, 0, 0, 300)
playerList.Position = UDim2.new(0, 0, 0, 62)
playerList.BackgroundColor3 = Color3.fromRGB(14,14,18)
playerList.BackgroundTransparency = 0.15
playerList.BorderSizePixel = 0
playerList.ScrollBarThickness = 4
playerList.ScrollBarImageColor3 = THEME.accent
playerList.CanvasSize = UDim2.new(0,0,0,0)
playerList.AutomaticCanvasSize = Enum.AutomaticSize.Y
playerList.ZIndex = 7
playerList.Parent = playersPage
corner(playerList, 8); outline(playerList, THEME.stroke, 0.25, 1)
pad(playerList, 6); listLayout(playerList, 6)

-- WORLD
local world = createPage("World")
createSection(world, "WORLD & UTILITIES", 0)
createButton(world, "Get All Tools", 30, function()
	local bp = player:FindFirstChildOfClass("Backpack")
	if not bp then return end
	local n = 0
	for _, d in ipairs(workspace:GetDescendants()) do
		if d:IsA("Tool") and not Players:GetPlayerFromCharacter(d.Parent) then
			d.Parent = bp; n += 1
		end
	end
	notify("Grabbed " .. n .. " tools", THEME.accent)
end, { primary = true })
createButton(world, "Copy My Position", 68, function()
	local r = getRoot()
	if not r then return end
	local p = r.Position
	local s = string.format("%.1f, %.1f, %.1f", p.X, p.Y, p.Z)
	if setclipboard then pcall(setclipboard, s) end
	notify("Copied: " .. s, THEME.accent)
end)
createButton(world, "Server Hop", 106, function()
	local ok = pcall(function()
		local url = "https://games.roblox.com/v1/games/" .. game.PlaceId ..
			"/servers/Public?sortOrder=Asc&limit=100"
		local data = HttpService:JSONDecode(game:HttpGet(url))
		for _, srv in ipairs(data.data) do
			if srv.id ~= game.JobId and srv.playing < srv.maxPlayers then
				TeleportService:TeleportToPlaceInstance(game.PlaceId, srv.id, player)
				return
			end
		end
	end)
	if not ok then pcall(function() TeleportService:Teleport(game.PlaceId, player) end) end
end)
createButton(world, "Rejoin Server", 144, function()
	pcall(function() TeleportService:Teleport(game.PlaceId, player) end)
end)
createButton(world, "Reset Character", 182, function()
	local h = getHumanoid(); if h then h.Health = 0 end
end)
createButton(world, "Full Heal", 220, function()
	local h = getHumanoid(); if h then h.Health = h.MaxHealth end
end)

createSection(world, "MUSIC PLAYER", 262)
local musicBox = Instance.new("TextBox")
musicBox.Size = UDim2.new(1, -100, 0, 30)
musicBox.Position = UDim2.new(0, 0, 0, 290)
musicBox.BackgroundColor3 = Color3.fromRGB(20,20,26)
musicBox.BorderSizePixel = 0
musicBox.PlaceholderText = "Sound ID..."
musicBox.Text = ""
musicBox.TextColor3 = THEME.text
musicBox.TextSize = 11
musicBox.Font = Enum.Font.Gotham
musicBox.ClearTextOnFocus = false
musicBox.ZIndex = 7
musicBox.Parent = world
corner(musicBox, 6); outline(musicBox, THEME.stroke, 0.25, 1)

local musicSound
local playBtn = createButton(world, "Play", 290, function()
	if musicSound then musicSound:Destroy() end
	local id = tonumber(musicBox.Text)
	if not id then return end
	musicSound = Instance.new("Sound")
	musicSound.SoundId = "rbxassetid://" .. id
	musicSound.Volume = 1
	pcall(function() SoundService:PlayLocalSound(musicSound) end)
	notify("Playing " .. id, THEME.accent)
end, { primary = true })
playBtn.Size = UDim2.new(0, 92, 0, 30)
playBtn.Position = UDim2.new(1, -92, 0, 290)

-- TELEPORT
local teleport = createPage("Teleport")
createSection(teleport, "TELEPORT", 0)
createToggle(teleport, "Teleport Tool", 30, "TeleportTool")
createToggle(teleport, "Click Teleport", 78, "ClickTeleport")

-- ANIMATIONS
local animationsPage = createPage("Animations")
createSection(animationsPage, "ANIMATION BROWSER", 0)
local animTabs = Instance.new("Frame")
animTabs.Size = UDim2.new(1, 0, 0, 26)
animTabs.Position = UDim2.new(0, 0, 0, 26)
animTabs.BackgroundTransparency = 1
animTabs.ZIndex = 7
animTabs.Parent = animationsPage

local function styleTab(b, active)
	b.BackgroundColor3 = active and THEME.accent or THEME.panel
	b.TextColor3 = active and Color3.fromRGB(12,12,16) or THEME.sub
end

local packsTab = Instance.new("TextButton")
packsTab.Size = UDim2.new(0.5, -4, 1, 0)
packsTab.BackgroundColor3 = THEME.accent
packsTab.BorderSizePixel = 0
packsTab.Text = "Packs"
packsTab.Font = Enum.Font.GothamBold
packsTab.TextSize = 11
packsTab.TextColor3 = Color3.fromRGB(12,12,16)
packsTab.ZIndex = 8
packsTab.Parent = animTabs
corner(packsTab, 7)

local mixerTab = Instance.new("TextButton")
mixerTab.Size = UDim2.new(0.5, -4, 1, 0)
mixerTab.Position = UDim2.new(0.5, 4, 0, 0)
mixerTab.BackgroundColor3 = THEME.panel
mixerTab.BorderSizePixel = 0
mixerTab.Text = "Mixer"
mixerTab.Font = Enum.Font.GothamBold
mixerTab.TextSize = 11
mixerTab.TextColor3 = THEME.sub
mixerTab.ZIndex = 8
mixerTab.Parent = animTabs
corner(mixerTab, 7)

local selectedLabel = Instance.new("TextLabel")
selectedLabel.BackgroundTransparency = 1
selectedLabel.Position = UDim2.new(0, 0, 0, 56)
selectedLabel.Size = UDim2.new(1, 0, 0, 20)
selectedLabel.Text = "Selected: Default"
selectedLabel.Font = Enum.Font.GothamMedium
selectedLabel.TextSize = 11
selectedLabel.TextColor3 = THEME.text
selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
selectedLabel.ZIndex = 7
selectedLabel.Parent = animationsPage

local animationStatus = Instance.new("TextLabel")
animationStatus.BackgroundTransparency = 1
animationStatus.Position = UDim2.new(0, 0, 0, 76)
animationStatus.Size = UDim2.new(1, 0, 0, 18)
animationStatus.Text = "Animation browser"
animationStatus.Font = Enum.Font.Gotham
animationStatus.TextSize = 9
animationStatus.TextColor3 = THEME.sub
animationStatus.TextXAlignment = Enum.TextXAlignment.Left
animationStatus.ZIndex = 7
animationStatus.Parent = animationsPage

local function makeListFrame()
	local f = Instance.new("ScrollingFrame")
	f.Size = UDim2.new(1, 0, 0, 230)
	f.Position = UDim2.new(0, 0, 0, 96)
	f.BackgroundColor3 = Color3.fromRGB(14,14,18)
	f.BackgroundTransparency = 0.15
	f.BorderSizePixel = 0
	f.ScrollBarThickness = 4
	f.ScrollBarImageColor3 = THEME.accent
	f.CanvasSize = UDim2.new(0,0,0,0)
	f.AutomaticCanvasSize = Enum.AutomaticSize.Y
	f.ZIndex = 7
	f.Parent = animationsPage
	corner(f, 8); outline(f, THEME.stroke, 0.25, 1)
	pad(f, 8); listLayout(f, 6)
	return f
end
local animationList = makeListFrame()
local mixerFrame = makeListFrame()
mixerFrame.Visible = false

local function showAnimTab(name)
	local packs = name == "Packs"
	animationList.Visible = packs
	mixerFrame.Visible = not packs
	styleTab(packsTab, packs)
	styleTab(mixerTab, not packs)
end
packsTab.MouseButton1Click:Connect(function() showAnimTab("Packs") end)
mixerTab.MouseButton1Click:Connect(function() showAnimTab("Mixer") end)

local animationPacks = {
	["Default"] = { Idle1="507766388", Idle2="507766666", Walk="507777826", Run="507767714", Jump="507765000", Fall="507767968", Climb="507765644", Swim="507784897", SwimIdle="507785072" },
	["Ninja"] = { Idle1="656117400", Idle2="656118341", Walk="656121766", Run="656118852", Jump="656117878", Fall="656115606", Climb="656114359", Swim="656119721", SwimIdle="656121397" },
	["Pirate"] = { Idle1="750781874", Idle2="750782770", Walk="750785693", Run="750783738", Jump="750782230", Fall="750780242", Climb="750779899", Swim="750784579", SwimIdle="750785176" },
	["Mage"] = { Idle1="707742142", Idle2="707855907", Walk="707897309", Run="707861613", Jump="707853694", Fall="707829716", Climb="707826056", Swim="707876443", SwimIdle="707894699" },
	["Robot"] = { Idle1="616088211", Idle2="616089559", Walk="616095330", Run="616091570", Jump="616090535", Fall="616087089", Climb="616086039", Swim="616092998", SwimIdle="616094091" },
	["Rthro"] = { Idle1="2510197257", Idle2="2510196951", Walk="2510202577", Run="2510198475", Jump="2510197830", Fall="2510195892", Climb="2510192778", Swim="2510199791", SwimIdle="2510201162" },
	["Stylish"] = { Idle1="616136790", Idle2="616138447", Walk="616146177", Run="616140816", Jump="616139451", Fall="616134815", Climb="616133594", Swim="616143378", SwimIdle="616144772" },
	["Superhero"] = { Idle1="616111295", Idle2="616113536", Walk="616122287", Run="616117076", Jump="616115533", Fall="616108001", Climb="616104706", Swim="616119360", SwimIdle="616120861" },
	["Toy"] = { Idle1="782841498", Idle2="782845736", Walk="782843345", Run="782842708", Jump="782847020", Fall="782846423", Climb="782843869", Swim="782844582", SwimIdle="782845186" },
	["Vampire"] = { Idle1="1083445855", Idle2="1083450166", Walk="1083473930", Run="1083462077", Jump="1083455352", Fall="1083443587", Climb="1083439238", Swim="1083464683", SwimIdle="1083467779" },
	["Werewolf"] = { Idle1="1083195517", Idle2="1083214717", Walk="1083178339", Run="1083216690", Jump="1083218792", Fall="1083189019", Climb="1083182000", Swim="1083222527", SwimIdle="1083225406" },
	["Zombie"] = { Idle1="616158929", Idle2="616160636", Walk="616168032", Run="616163682", Jump="616161997", Fall="616157476", Climb="616156119", Swim="616165109", SwimIdle="616166655" },
	["Knight"] = { Idle1="657595757", Idle2="657568135", Walk="657552124", Run="657564596", Jump="658409194", Fall="657600094", Climb="657607315", Swim="657555678", SwimIdle="658629950" },
	["Astronaut"] = { Idle1="891621366", Idle2="891633237", Walk="891667138", Run="891636393", Jump="891627522", Fall="891609353", Climb="891617961", Swim="891639666", SwimIdle="891663592" },
	["Cartoony"] = { Idle1="742637512", Idle2="742638842", Walk="742640026", Run="742638054", Jump="742637724", Fall="742639845", Climb="742636889", Swim="742639845", SwimIdle="742637151" },
	["Elder"] = { Idle1="845397383", Idle2="845401622", Walk="845403368", Run="845400531", Jump="845397478", Fall="845397286", Climb="845396530", Swim="845399688", SwimIdle="845400531" },
	["Levitation"] = { Idle1="616006778", Idle2="616008087", Walk="616013216", Run="616010382", Jump="616008936", Fall="616005863", Climb="616003968", Swim="616011500", SwimIdle="616012453" },
}

local emoteNames = {
	"Wave","Point","Dance","Dance2","Dance3","Laugh","Cheer","Shrug","Salute","Stomp",
	"Sit","Lay","Cry","Confused","Facepalm","Kick","Punch","Ninja","Robot","Floss",
	"Dab","Orange Justice","Electro Shuffle","Karaoke","Sneaky","Worm","Hype Dance","Old Man Dance","Fancy Feet","Strike a Pose",
	"Zombie Dance","Default Dance","Tilt","Ballet","Boombox","Breakdance","Cabbage Patch","Catwalk","Charleston","Cheerleader",
	"Chicken Dance","Chill","Clap","Clown","Cowboy","Cross Arms","Curtsy","Disco","Dolphin","Drop the Bass",
	"Drummer","Duck Walk","Eagle","Elbow Bump","Fairy","Fashion","Finger Gun","Fist Pump","Flex","Floating",
	"Fling","Gallop","Gangnam Style","Gig","Guitar","Hair Flip","Handstand","Head Bang","Heart","Hip Hop",
	"Hula","Jazz","Jog","Jump Rope","Karate","Kick Flip","Knee Slide","Lasso","Lean","Levitate",
	"Limbo","Macarena","March","Moonwalk","Muscle","Nae Nae","Naruto Run","Pace","Party","Penguin",
	"Photograph","Pirate","Pop","Pose","Pray","Push Up","Rabbit","Rainbow","Rap","Renegade",
	"Ride","Ring","Rock","Roll","Runway","Salsa","Samba","Saxophone","Shimmy","Shoot",
	"Shop","Sing","Skate","Skip","Slide","Smooth","Snake","Space","Spin","Splits",
	"Sprinkler","Squat","Stand","Star","Stretch","Strut","Surf","Swan","Swing","Sword",
	"T-Pose","Tap Dance","Tea","Tennis","Think","Throw","Tiptoe","Tornado","Train","Twist",
	"Type","Vogue","Volleyball","Waltz","Wiggle","Wobble","Yoga","Yo Yo","Applause","Backflip",
}

do
	local emotePage = createPage("Emotes")
	createSection(emotePage, "EMOTE BROWSER", 0)
	local emoteSearch = Instance.new("TextBox")
	emoteSearch.Size = UDim2.new(1, 0, 0, 26)
	emoteSearch.Position = UDim2.new(0, 0, 0, 24)
	emoteSearch.BackgroundColor3 = Color3.fromRGB(20,20,26)
	emoteSearch.BorderSizePixel = 0
	emoteSearch.PlaceholderText = "Search emotes..."
	emoteSearch.Text = ""
	emoteSearch.TextColor3 = THEME.text
	emoteSearch.TextSize = 11
	emoteSearch.Font = Enum.Font.Gotham
	emoteSearch.ClearTextOnFocus = false
	emoteSearch.ZIndex = 7
	emoteSearch.Parent = emotePage
	corner(emoteSearch, 6); outline(emoteSearch, THEME.stroke, 0.25, 1)

	local emoteListFrame = Instance.new("ScrollingFrame")
	emoteListFrame.Size = UDim2.new(1, 0, 0, 300)
	emoteListFrame.Position = UDim2.new(0, 0, 0, 58)
	emoteListFrame.BackgroundColor3 = Color3.fromRGB(14,14,18)
	emoteListFrame.BackgroundTransparency = 0.15
	emoteListFrame.BorderSizePixel = 0
	emoteListFrame.ScrollBarThickness = 4
	emoteListFrame.ScrollBarImageColor3 = THEME.accent
	emoteListFrame.CanvasSize = UDim2.new(0,0,0,0)
	emoteListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	emoteListFrame.ZIndex = 7
	emoteListFrame.Parent = emotePage
	corner(emoteListFrame, 8); outline(emoteListFrame, THEME.stroke, 0.25, 1)
	pad(emoteListFrame, 8); listLayout(emoteListFrame, 5)

	local function buildEmoteList(filter)
		for _, ch in ipairs(emoteListFrame:GetChildren()) do
			if ch:IsA("TextButton") then ch:Destroy() end
		end
		local lf = string.lower(filter or "")
		local order = 0
		for _, name in ipairs(emoteNames) do
			if lf == "" or string.find(string.lower(name), lf, 1, true) then
				order += 1
				local b = Instance.new("TextButton")
				b.LayoutOrder = order
				b.Size = UDim2.new(1, 0, 0, 28)
				b.BackgroundColor3 = Color3.fromRGB(20,20,26)
				b.BorderSizePixel = 0
				b.Text = name
				b.Font = Enum.Font.GothamMedium
				b.TextSize = 11
				b.TextColor3 = THEME.text
				b.TextXAlignment = Enum.TextXAlignment.Left
				b.ZIndex = 8
				b.Parent = emoteListFrame
				corner(b, 6)
				local bp = Instance.new("UIPadding"); bp.PaddingLeft = UDim.new(0, 10); bp.Parent = b
				addHover(b, Color3.fromRGB(20,20,26), Color3.fromRGB(32,32,42))
				b.MouseButton1Click:Connect(function()
					local h = getHumanoid()
					if h then pcall(function() h:PlayEmote(name) end) end
				end)
			end
		end
	end
	buildEmoteList("")
	emoteSearch:GetPropertyChangedSignal("Text"):Connect(function() buildEmoteList(emoteSearch.Text) end)
end

--=====================================================================
--  ANIMATION ENGINE
--=====================================================================
local mixSlots = {"Idle1","Idle2","Walk","Run","Jump","Fall","Climb","Swim","SwimIdle"}
local customMix = {}
for _, s in ipairs(mixSlots) do customMix[s] = "Default" end
local sortedPackNames = {}
for n in pairs(animationPacks) do table.insert(sortedPackNames, n) end
table.sort(sortedPackNames, function(a,b)
	if a == "Default" then return true end
	if b == "Default" then return false end
	return a < b
end)

local function getAnimationCharacter()
	local c = player.Character
	if not c then return nil, nil, nil end
	local h = c:FindFirstChildOfClass("Humanoid")
	if not h then return c, nil, nil end
	local a = h:FindFirstChildOfClass("Animator")
	if not a then a = Instance.new("Animator"); a.Parent = h end
	return c, h, a
end

local function stopCustomTracks()
	for name, track in pairs(animationTracks) do
		if track then pcall(function() track:Stop(0.12); track:Destroy() end) end
		animationTracks[name] = nil
	end
	currentAnimationName = nil
end
local function disconnectAnimationConnections()
	for _, c in ipairs(animationConnections) do if c then c:Disconnect() end end
	table.clear(animationConnections)
end
local function disableDefaultAnimate(c)
	local a = c and c:FindFirstChild("Animate")
	if a and a:IsA("LocalScript") then a.Disabled = true end
end
local function enableDefaultAnimate(c)
	local a = c and c:FindFirstChild("Animate")
	if a and a:IsA("LocalScript") then a.Disabled = false end
end

local function makeAnimation(animator, id, name)
	local anim = Instance.new("Animation")
	anim.AnimationId = "rbxassetid://" .. tostring(id)
	local ok, track = pcall(function() return animator:LoadAnimation(anim) end)
	anim:Destroy()
	if not ok or not track then return nil end
	local looping = (name == "Idle1" or name == "Idle2" or name == "Walk" or name == "Run"
		or name == "Swim" or name == "SwimIdle" or name == "Climb" or name == "Fall" or name == "Sit")
	track.Looped = looping
	track.Priority = Enum.AnimationPriority.Movement
	return track
end

local function loadAnimationTracks(pack)
	stopCustomTracks()
	local c, h, a = getAnimationCharacter()
	if not c or not h or not a then return false end
	if h.RigType ~= Enum.HumanoidRigType.R15 then animationStatus.Text = "R15 required"; return false end
	disableDefaultAnimate(c)
	for name, id in pairs(pack) do
		local t = makeAnimation(a, id, name)
		if t then animationTracks[name] = t end
	end
	local st = makeAnimation(a, "2506281703", "Sit")
	if st then st.Looped = true; animationTracks["Sit"] = st end
	return true
end

local function playCustomAnimation(name)
	if not customAnimationEnabled or currentAnimationName == name then return end
	local track = animationTracks[name]
	if not track then return end
	for otherName, otherTrack in pairs(animationTracks) do
		if otherTrack and otherName ~= name then pcall(function() otherTrack:Stop(0.12) end) end
	end
	currentAnimationName = name
	local _, h = getAnimationCharacter()
	if not h then return end
	local speed = 1
	if name == "Walk" then speed = math.max(0.7, h.WalkSpeed / 8)
	elseif name == "Run" then speed = math.max(0.7, h.WalkSpeed / 16) end
	track:Play(0.12, 1, speed)
end

local function updateCustomAnimation()
	if not customAnimationEnabled then return end
	local _, h = getAnimationCharacter()
	if not h or h.RigType ~= Enum.HumanoidRigType.R15 then return end
	local state = h:GetState()
	local moving = h.MoveDirection.Magnitude > 0.05
	if state == Enum.HumanoidStateType.Jumping then playCustomAnimation("Jump"); return end
	if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.FallingDown then playCustomAnimation("Fall"); return end
	if state == Enum.HumanoidStateType.Climbing then playCustomAnimation("Climb"); return end
	if state == Enum.HumanoidStateType.Swimming then
		if moving then playCustomAnimation("Swim") else playCustomAnimation("SwimIdle") end
		return
	end
	if state == Enum.HumanoidStateType.Seated then playCustomAnimation("Sit"); return end
	if moving then
		if h.WalkSpeed > 16 then playCustomAnimation("Run") else playCustomAnimation("Walk") end
		return
	end
	playCustomAnimation("Idle1")
end

local function startCustomAnimationController()
	animationGeneration += 1
	local gen = animationGeneration
	disconnectAnimationConnections()
	if animationLoopConnection then animationLoopConnection:Disconnect(); animationLoopConnection = nil end
	local _, h = getAnimationCharacter()
	if not h or h.RigType ~= Enum.HumanoidRigType.R15 then animationStatus.Text = "R15 required"; return end
	animationLoopConnection = RunService.Heartbeat:Connect(function()
		if gen ~= animationGeneration or closed or not customAnimationEnabled then return end
		updateCustomAnimation()
	end)
	table.insert(animationConnections, h.StateChanged:Connect(function()
		if not customAnimationEnabled then return end
		task.defer(function() if gen == animationGeneration then updateCustomAnimation() end end)
	end))
	table.insert(animationConnections, h:GetPropertyChangedSignal("MoveDirection"):Connect(function()
		if customAnimationEnabled then updateCustomAnimation() end
	end))
	table.insert(animationConnections, h:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		if customAnimationEnabled then updateCustomAnimation() end
	end))
	updateCustomAnimation()
end

local function stopCustomAnimationController()
	animationGeneration += 1
	if animationLoopConnection then animationLoopConnection:Disconnect(); animationLoopConnection = nil end
	disconnectAnimationConnections()
	stopCustomTracks()
end

local function applyAnimationPack(packName)
	local pack = animationPacks[packName]
	if not pack then return end
	local c, h = getAnimationCharacter()
	if not c or not h then animationStatus.Text = "Character not ready"; return end
	if h.RigType ~= Enum.HumanoidRigType.R15 then animationStatus.Text = "R15 required"; return end
	currentAnimationPack = packName
	if packName == "Default" then
		customAnimationEnabled = false
		stopCustomAnimationController()
		enableDefaultAnimate(c)
		selectedLabel.Text = "Selected: Default"
		animationStatus.Text = "Default animations restored"
		return
	end
	customAnimationEnabled = false
	stopCustomAnimationController()
	customAnimationEnabled = loadAnimationTracks(pack)
	if not customAnimationEnabled then animationStatus.Text = "Could not load pack"; return end
	selectedLabel.Text = "Selected: " .. packName
	animationStatus.Text = "Custom controller active"
	startCustomAnimationController()
end

local function buildMixPack()
	local pack = {}
	for _, slot in ipairs(mixSlots) do
		local src = animationPacks[customMix[slot]]
		if src and src[slot] then pack[slot] = src[slot] end
	end
	return pack
end

local function applyCustomMix()
	local c, h = getAnimationCharacter()
	if not c or not h then animationStatus.Text = "Character not ready"; return end
	if h.RigType ~= Enum.HumanoidRigType.R15 then animationStatus.Text = "R15 required"; return end
	local pack = buildMixPack()
	customAnimationEnabled = false
	stopCustomAnimationController()
	customAnimationEnabled = loadAnimationTracks(pack)
	if not customAnimationEnabled then animationStatus.Text = "Could not load mix"; return end
	currentAnimationPack = "Custom Mix"
	selectedLabel.Text = "Selected: Custom Mix"
	animationStatus.Text = "Custom mix active"
	startCustomAnimationController()
end

local function rebuildAnimationButtons()
	for _, ch in ipairs(animationList:GetChildren()) do
		if ch:IsA("TextButton") then ch:Destroy() end
	end
	for i, name in ipairs(sortedPackNames) do
		local b = Instance.new("TextButton")
		b.LayoutOrder = i
		b.Size = UDim2.new(1, 0, 0, 40)
		b.BackgroundColor3 = Color3.fromRGB(20,20,26)
		b.BorderSizePixel = 0
		b.Text = name
		b.Font = Enum.Font.GothamMedium
		b.TextSize = 11
		b.TextColor3 = THEME.text
		b.ZIndex = 8
		b.Parent = animationList
		corner(b, 7); outline(b, THEME.stroke, 0.3, 1)
		addHover(b, Color3.fromRGB(20,20,26), Color3.fromRGB(32,32,42))
		b.MouseButton1Click:Connect(function() applyAnimationPack(name) end)
	end
end
rebuildAnimationButtons()

local mixValueLabels = {}
local function cycleMix(slot, dir)
	local idx = table.find(sortedPackNames, customMix[slot]) or 1
	idx = ((idx - 1 + dir) % #sortedPackNames) + 1
	customMix[slot] = sortedPackNames[idx]
	if mixValueLabels[slot] then mixValueLabels[slot].Text = customMix[slot] end
	applyCustomMix()
end

local function buildMixer()
	for _, ch in ipairs(mixerFrame:GetChildren()) do
		if ch:IsA("Frame") then ch:Destroy() end
	end
	table.clear(mixValueLabels)
	for i, slot in ipairs(mixSlots) do
		local row = Instance.new("Frame")
		row.LayoutOrder = i
		row.Size = UDim2.new(1, 0, 0, 34)
		row.BackgroundColor3 = Color3.fromRGB(20,20,26)
		row.BorderSizePixel = 0
		row.ZIndex = 8
		row.Parent = mixerFrame
		corner(row, 7); outline(row, THEME.stroke, 0.3, 1)

		local label = Instance.new("TextLabel")
		label.BackgroundTransparency = 1
		label.Position = UDim2.new(0, 12, 0, 0)
		label.Size = UDim2.new(0, 70, 1, 0)
		label.Text = slot
		label.Font = Enum.Font.GothamMedium
		label.TextSize = 11
		label.TextColor3 = THEME.text
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.ZIndex = 9
		label.Parent = row

		local left = Instance.new("TextButton")
		left.Size = UDim2.new(0, 26, 0, 22)
		left.Position = UDim2.new(1, -152, 0.5, -11)
		left.BackgroundColor3 = THEME.panel2
		left.BorderSizePixel = 0
		left.Text = "<"
		left.Font = Enum.Font.GothamBold
		left.TextSize = 13
		left.TextColor3 = THEME.text
		left.ZIndex = 9
		left.Parent = row
		corner(left, 6); addHover(left, THEME.panel2, Color3.fromRGB(40,40,54))

		local value = Instance.new("TextLabel")
		value.BackgroundTransparency = 1
		value.Position = UDim2.new(1, -124, 0, 0)
		value.Size = UDim2.new(0, 90, 1, 0)
		value.Text = customMix[slot]
		value.Font = Enum.Font.GothamMedium
		value.TextSize = 10
		value.TextColor3 = THEME.accent
		value.TextTruncate = Enum.TextTruncate.AtEnd
		value.ZIndex = 9
		value.Parent = row
		mixValueLabels[slot] = value

		local right = Instance.new("TextButton")
		right.Size = UDim2.new(0, 26, 0, 22)
		right.Position = UDim2.new(1, -30, 0.5, -11)
		right.BackgroundColor3 = THEME.panel2
		right.BorderSizePixel = 0
		right.Text = ">"
		right.Font = Enum.Font.GothamBold
		right.TextSize = 13
		right.TextColor3 = THEME.text
		right.ZIndex = 9
		right.Parent = row
		corner(right, 6); addHover(right, THEME.panel2, Color3.fromRGB(40,40,54))

		left.MouseButton1Click:Connect(function() cycleMix(slot, -1) end)
		right.MouseButton1Click:Connect(function() cycleMix(slot, 1) end)
	end
	local reset = Instance.new("TextButton")
	reset.LayoutOrder = #mixSlots + 1
	reset.Size = UDim2.new(1, 0, 0, 32)
	reset.BackgroundColor3 = THEME.accent
	reset.BorderSizePixel = 0
	reset.Text = "Reset Mix"
	reset.Font = Enum.Font.GothamBold
	reset.TextSize = 11
	reset.TextColor3 = Color3.fromRGB(12,12,16)
	reset.ZIndex = 8
	reset.Parent = mixerFrame
	corner(reset, 7)
	reset.MouseButton1Click:Connect(function()
		for _, slot in ipairs(mixSlots) do
			customMix[slot] = "Default"
			if mixValueLabels[slot] then mixValueLabels[slot].Text = "Default" end
		end
		applyCustomMix()
	end)
end
buildMixer()
showAnimTab("Packs")

--=====================================================================
--  SETTINGS
--=====================================================================
local settings = createPage("Settings")
createSection(settings, "CONFIGURATIONS", 0)
local configStatus = Instance.new("TextLabel")
configStatus.BackgroundTransparency = 1
configStatus.Position = UDim2.new(0, 0, 0, 26)
configStatus.Size = UDim2.new(1, 0, 0, 18)
configStatus.Text = "Save, load and manage your setups"
configStatus.Font = Enum.Font.Gotham
configStatus.TextSize = 10
configStatus.TextColor3 = THEME.sub
configStatus.TextXAlignment = Enum.TextXAlignment.Left
configStatus.ZIndex = 7
configStatus.Parent = settings

local configNameBox = Instance.new("TextBox")
configNameBox.Size = UDim2.new(1, -104, 0, 30)
configNameBox.Position = UDim2.new(0, 0, 0, 48)
configNameBox.BackgroundColor3 = Color3.fromRGB(20,20,26)
configNameBox.BorderSizePixel = 0
configNameBox.PlaceholderText = "Config name..."
configNameBox.Text = ""
configNameBox.TextColor3 = THEME.text
configNameBox.TextSize = 11
configNameBox.Font = Enum.Font.Gotham
configNameBox.ClearTextOnFocus = false
configNameBox.ZIndex = 7
configNameBox.Parent = settings
corner(configNameBox, 6); outline(configNameBox, THEME.stroke, 0.25, 1)

local configList = Instance.new("ScrollingFrame")
configList.Size = UDim2.new(1, 0, 0, 180)
configList.Position = UDim2.new(0, 0, 0, 88)
configList.BackgroundColor3 = Color3.fromRGB(14,14,18)
configList.BackgroundTransparency = 0.15
configList.BorderSizePixel = 0
configList.ScrollBarThickness = 4
configList.ScrollBarImageColor3 = THEME.accent
configList.CanvasSize = UDim2.new(0,0,0,0)
configList.AutomaticCanvasSize = Enum.AutomaticSize.Y
configList.ZIndex = 7
configList.Parent = settings
corner(configList, 8); outline(configList, THEME.stroke, 0.25, 1)
pad(configList, 8); listLayout(configList, 6)

local savedConfigs = {}
local CONFIG_FILE = "0nyxhub_configs.json"
local function deepCopy(t)
	local c = {}
	for k, v in pairs(t) do
		if type(v) == "table" then c[k] = deepCopy(v) else c[k] = v end
	end
	return c
end
local function persistConfigs()
	if type(writefile) == "function" then
		pcall(function() writefile(CONFIG_FILE, HttpService:JSONEncode(savedConfigs)) end)
	end
end
local function loadPersistedConfigs()
	if type(readfile) == "function" and type(isfile) == "function" then
		pcall(function()
			if isfile(CONFIG_FILE) then savedConfigs = HttpService:JSONDecode(readfile(CONFIG_FILE)) end
		end)
	end
end
local function captureConfig()
	return {
		states = deepCopy(states),
		walkSpeed = walkSpeed, flightSpeed = flightSpeed, jumpPower = jumpPower,
		cfg = deepCopy(cfg),
		animationPack = currentAnimationPack,
		customMix = deepCopy(customMix),
	}
end
local function applyConfig(cfgData)
	if not cfgData then return end
	if cfgData.states then
		for k, v in pairs(cfgData.states) do
			if states[k] ~= nil then states[k] = v end
		end
	end
	if cfgData.walkSpeed then walkSpeed = cfgData.walkSpeed end
	if cfgData.flightSpeed then flightSpeed = cfgData.flightSpeed end
	if cfgData.jumpPower then jumpPower = cfgData.jumpPower end
	if cfgData.cfg then for k, v in pairs(cfgData.cfg) do cfg[k] = v end end
	if cfgData.customMix then for s, v in pairs(cfgData.customMix) do customMix[s] = v end end
	for _, refresh in pairs(toggleRefreshers) do refresh(false) end
	if cfgData.animationPack and cfgData.animationPack ~= "Default" then
		if cfgData.animationPack == "Custom Mix" then applyCustomMix() else applyAnimationPack(cfgData.animationPack) end
	end
end

local rebuildConfigList
local function deleteConfig(name)
	savedConfigs[name] = nil
	persistConfigs()
	rebuildConfigList()
end
rebuildConfigList = function()
	for _, ch in ipairs(configList:GetChildren()) do
		if ch:IsA("Frame") then ch:Destroy() end
	end
	local names = {}
	for n in pairs(savedConfigs) do table.insert(names, n) end
	table.sort(names)
	if #names == 0 then
		local empty = Instance.new("TextLabel")
		empty.Size = UDim2.new(1, 0, 0, 30)
		empty.BackgroundTransparency = 1
		empty.Text = "No saved configs yet"
		empty.Font = Enum.Font.Gotham
		empty.TextSize = 10
		empty.TextColor3 = THEME.sub
		empty.ZIndex = 8
		empty.Parent = configList
		return
	end
	for i, name in ipairs(names) do
		local row = Instance.new("Frame")
		row.LayoutOrder = i
		row.Size = UDim2.new(1, 0, 0, 38)
		row.BackgroundColor3 = Color3.fromRGB(20,20,26)
		row.BorderSizePixel = 0
		row.ZIndex = 8
		row.Parent = configList
		corner(row, 7); outline(row, THEME.stroke, 0.3, 1)

		local label = Instance.new("TextLabel")
		label.BackgroundTransparency = 1
		label.Position = UDim2.new(0, 12, 0, 0)
		label.Size = UDim2.new(1, -140, 1, 0)
		label.Text = name
		label.Font = Enum.Font.GothamMedium
		label.TextSize = 11
		label.TextColor3 = THEME.text
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextTruncate = Enum.TextTruncate.AtEnd
		label.ZIndex = 9
		label.Parent = row

		local loadBtn = Instance.new("TextButton")
		loadBtn.Size = UDim2.new(0, 58, 0, 24)
		loadBtn.Position = UDim2.new(1, -128, 0.5, -12)
		loadBtn.BackgroundColor3 = THEME.accent
		loadBtn.BorderSizePixel = 0
		loadBtn.Text = "Load"
		loadBtn.Font = Enum.Font.GothamBold
		loadBtn.TextSize = 10
		loadBtn.TextColor3 = Color3.fromRGB(12,12,16)
		loadBtn.ZIndex = 9
		loadBtn.Parent = row
		corner(loadBtn, 6)

		local delBtn = Instance.new("TextButton")
		delBtn.Size = UDim2.new(0, 58, 0, 24)
		delBtn.Position = UDim2.new(1, -64, 0.5, -12)
		delBtn.BackgroundColor3 = THEME.panel2
		delBtn.BorderSizePixel = 0
		delBtn.Text = "Delete"
		delBtn.Font = Enum.Font.GothamMedium
		delBtn.TextSize = 10
		delBtn.TextColor3 = THEME.text
		delBtn.ZIndex = 9
		delBtn.Parent = row
		corner(delBtn, 6)

		loadBtn.MouseButton1Click:Connect(function()
			applyConfig(savedConfigs[name])
			configStatus.Text = "Loaded: " .. name
			statLabel.Text = "Loaded config: " .. name
			notify("Loaded: " .. name, THEME.accent)
		end)
		delBtn.MouseButton1Click:Connect(function() deleteConfig(name) end)
	end
end

local saveBtn = createButton(settings, "Save Config", 48, function()
	local name = configNameBox.Text
	if name == "" then name = "Config " .. tostring(os.time()) end
	savedConfigs[name] = captureConfig()
	persistConfigs()
	rebuildConfigList()
	configStatus.Text = "Saved: " .. name
	configNameBox.Text = ""
	notify("Saved: " .. name, THEME.accent)
end, { primary = true })
saveBtn.Size = UDim2.new(0, 96, 0, 30)
saveBtn.Position = UDim2.new(1, -96, 0, 48)

loadPersistedConfigs()
rebuildConfigList()

--=====================================================================
--  FEATURE SETTERS
--=====================================================================
local function setAntiAFK(enabled)
	if conn.antiAFK then conn.antiAFK:Disconnect(); conn.antiAFK = nil end
	if enabled then
		conn.antiAFK = player.Idled:Connect(function()
			VirtualUser:CaptureController()
			VirtualUser:ClickButton1(Vector2.new(math.random(0,100), math.random(0,100)), workspace.CurrentCamera.CFrame)
		end)
	end
end

local function setAntiKick(enabled)
	if conn.antiKick then conn.antiKick:Disconnect(); conn.antiKick = nil end
	if not enabled then return end
	conn.antiKick = player.CharacterRemoving:Connect(function(character)
		if not states.AntiKick then return end
		task.wait(0.05)
		if character and not character.Parent then character.Parent = workspace end
	end)
end

local function setAntiBan(enabled)
	if conn.antiBan then conn.antiBan:Disconnect(); conn.antiBan = nil end
	if not enabled then return end
	conn.antiBan = RunService.Heartbeat:Connect(function()
		if closed or not states.AntiBan then return end
		local pg = player:FindFirstChild("PlayerGui")
		if pg and gui.Parent ~= pg then gui.Parent = pg end
	end)
end

local function setAimbot(enabled)
	if conn.aimbot then conn.aimbot:Disconnect(); conn.aimbot = nil end
	if not enabled then return end
	conn.aimbot = RunService.RenderStepped:Connect(function()
		if closed or not states.Aimbot then return end
		local cam = workspace.CurrentCamera
		if not cam then return end
		local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
		local best, bestDist = nil, aim.fov
		for _, other in ipairs(Players:GetPlayers()) do
			if other ~= player then
				local head = other.Character and other.Character:FindFirstChild("Head")
				local hum = getHumanoid(other)
				if head and hum and hum.Health > 0 then
					local pos, onScreen = cam:WorldToViewportPoint(head.Position)
					if onScreen and pos.Z > 0 then
						local d = (Vector2.new(pos.X, pos.Y) - center).Magnitude
						if d < bestDist then best, bestDist = head, d end
					end
				end
			end
		end
		if best then
			local goal = CFrame.lookAt(cam.CFrame.Position, best.Position)
			cam.CFrame = cam.CFrame:Lerp(goal, math.clamp(aim.smooth, 0.02, 1))
		end
	end)
end

local GOD_BONUS = 10000
local function applyGodHealth(character)
	local h = character and character:FindFirstChildOfClass("Humanoid")
	if not h then return end
	if not saved.god[h] then saved.god[h] = h.MaxHealth end
	h.MaxHealth = saved.god[h] + GOD_BONUS
	h.Health = h.MaxHealth
end
local function removeGodHealth(character)
	local h = character and character:FindFirstChildOfClass("Humanoid")
	if not h then return end
	if saved.god[h] then
		h.MaxHealth = saved.god[h]
		h.Health = math.min(h.Health, h.MaxHealth)
		saved.god[h] = nil
	end
end
local function startGodLoop()
	if conn.god then conn.god:Disconnect(); conn.god = nil end
	conn.god = RunService.Stepped:Connect(function()
		if closed or not states.Godmode then return end
		local h = getHumanoid()
		if not h then return end
		if h.MaxHealth < (saved.god[h] or 0) + GOD_BONUS - 1 then
			h.MaxHealth = (saved.god[h] or h.MaxHealth) + GOD_BONUS
		end
		if h.Health < h.MaxHealth then h.Health = h.MaxHealth end
		local state = h:GetState()
		if state == Enum.HumanoidStateType.Dead then
			h.Health = h.MaxHealth
			h:ChangeState(Enum.HumanoidStateType.Running)
		elseif state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown then
			h:ChangeState(Enum.HumanoidStateType.Running)
		end
	end)
end
local function setGodmode(enabled)
	local c = player.Character
	if enabled then
		if c then applyGodHealth(c) end
		startGodLoop()
	else
		if conn.god then conn.god:Disconnect(); conn.god = nil end
		if c then removeGodHealth(c) end
	end
end

local function voidRescue()
	if voidBusy then return end
	voidBusy = true
	voidFlash.BackgroundTransparency = 0
	TweenService:Create(voidFlash, TweenInfo.new(0.35), { BackgroundTransparency = 1 }):Play()
	task.wait(0.12)
	voidCover.Visible = true
	voidCover.BackgroundTransparency = 1
	TweenService:Create(voidCover, TweenInfo.new(0.4), { BackgroundTransparency = 0 }):Play()
	task.wait(0.45)
	voidTitle.Visible = true; voidSub.Visible = true
	TweenService:Create(voidTitle, TweenInfo.new(0.35), { TextTransparency = 0 }):Play()
	TweenService:Create(voidSub, TweenInfo.new(0.35), { TextTransparency = 0 }):Play()
	TweenService:Create(voidTitleStroke, TweenInfo.new(0.35), { Transparency = 0.3 }):Play()
	TweenService:Create(voidSubStroke, TweenInfo.new(0.35), { Transparency = 0.5 }):Play()
	task.wait(0.7)
	local root = getRoot()
	local target = lastSafePos
	if not target then
		local spawn = workspace:FindFirstChildOfClass("SpawnLocation")
		target = spawn and spawn.Position or Vector3.new(0, 50, 0)
	end
	if root then
		root.CFrame = CFrame.new(target + Vector3.new(0, 4, 0))
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
	end
	task.wait(0.45)
	TweenService:Create(voidCover, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
	TweenService:Create(voidTitle, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
	TweenService:Create(voidSub, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
	TweenService:Create(voidTitleStroke, TweenInfo.new(0.5), { Transparency = 1 }):Play()
	TweenService:Create(voidSubStroke, TweenInfo.new(0.5), { Transparency = 1 }):Play()
	task.wait(0.55)
	voidCover.Visible = false
	voidTitle.Visible = false; voidSub.Visible = false
	voidTitle.TextTransparency = 1; voidSub.TextTransparency = 1
	voidTitleStroke.Transparency = 1; voidSubStroke.Transparency = 1
	voidBusy = false
end

task.spawn(function()
	while not closed do
		local root = getRoot()
		local h = getHumanoid()
		if root and h and root.Position.Y > VOID_Y + 20 and h.FloorMaterial ~= Enum.Material.Air then
			lastSafePos = root.Position
		end
		task.wait(0.25)
	end
end)

local function rememberPartTransparency(o)
	if saved.transparency[o] == nil then
		saved.transparency[o] = {
			Transparency = o.Transparency,
			LocalTransparencyModifier = o:IsA("BasePart") and o.LocalTransparencyModifier or nil,
		}
	end
end
local function applyInvisibleToCharacter(character)
	for _, o in ipairs(character:GetDescendants()) do
		if o:IsA("BasePart") or o:IsA("Decal") then
			rememberPartTransparency(o)
			o.Transparency = 1
			if o:IsA("BasePart") then o.LocalTransparencyModifier = 1 end
		end
	end
end
local function setInvisible(enabled)
	local character = player.Character
	if not character then return end
	if conn.invisibility then conn.invisibility:Disconnect(); conn.invisibility = nil end
	if enabled then
		table.clear(saved.transparency)
		applyInvisibleToCharacter(character)
		conn.invisibility = character.DescendantAdded:Connect(function(o)
			if not states.Invisible then return end
			if o:IsA("BasePart") or o:IsA("Decal") then
				task.defer(function()
					if o and o.Parent and states.Invisible then
						rememberPartTransparency(o)
						o.Transparency = 1
						if o:IsA("BasePart") then o.LocalTransparencyModifier = 1 end
					end
				end)
			end
		end)
	else
		for o, data in pairs(saved.transparency) do
			if o and o.Parent then
				o.Transparency = data.Transparency
				if o:IsA("BasePart") and data.LocalTransparencyModifier ~= nil then
					o.LocalTransparencyModifier = data.LocalTransparencyModifier
				end
			end
		end
		table.clear(saved.transparency)
	end
end

local function applyNoclipParts()
	local character = player.Character
	if not character then return end
	for _, o in ipairs(character:GetDescendants()) do
		if o:IsA("BasePart") then
			if saved.noclip[o] == nil then saved.noclip[o] = o.CanCollide end
			o.CanCollide = false
		end
	end
end
local function setNoclip(enabled)
	if conn.noclip then conn.noclip:Disconnect(); conn.noclip = nil end
	if enabled then
		table.clear(saved.noclip)
		applyNoclipParts()
		conn.noclip = RunService.Heartbeat:Connect(function()
			if closed or not states.Noclip then return end
			applyNoclipParts()
		end)
	else
		for o, cc in pairs(saved.noclip) do
			if o and o.Parent then o.CanCollide = cc end
		end
		table.clear(saved.noclip)
	end
end

local function setAntiFling(enabled)
	if conn.antiFling then conn.antiFling:Disconnect(); conn.antiFling = nil end
	if not enabled then return end
	conn.antiFling = RunService.Heartbeat:Connect(function()
		if closed or not states.AntiFling or states.Flight then return end
		local root = getRoot()
		if not root then return end
		local maxLinear, maxAngular = 60, 50
		local linear, angular = root.AssemblyLinearVelocity, root.AssemblyAngularVelocity
		if linear.Magnitude ~= linear.Magnitude then root.AssemblyLinearVelocity = Vector3.zero; linear = Vector3.zero end
		if angular.Magnitude ~= angular.Magnitude then root.AssemblyAngularVelocity = Vector3.zero; angular = Vector3.zero end
		if linear.Magnitude > maxLinear then root.AssemblyLinearVelocity = linear.Unit * maxLinear end
		if angular.Magnitude > maxAngular then root.AssemblyAngularVelocity = angular.Unit * maxAngular end
		local h = getHumanoid()
		if h then
			local cf = root.CFrame
			if cf.UpVector.Y < 0.92 then
				local look = cf.LookVector
				local flat = Vector3.new(look.X, 0, look.Z)
				if flat.Magnitude > 0.01 then root.CFrame = CFrame.lookAt(root.Position, root.Position + flat.Unit) end
			end
		end
	end)
end

local function getBlankTrack()
	local _, _, a = getAnimationCharacter()
	if not a then return nil end
	local anim = Instance.new("Animation")
	anim.AnimationId = "rbxassetid://0"
	local ok, track = pcall(function() return a:LoadAnimation(anim) end)
	anim:Destroy()
	if ok and track then track.Priority = Enum.AnimationPriority.Action; track.Looped = true; return track end
	return nil
end
local function setFlight(enabled)
	if conn.flight then conn.flight:Disconnect(); conn.flight = nil end
	if conn.flightVelocity then conn.flightVelocity:Destroy(); conn.flightVelocity = nil end
	if conn.flightGyro then conn.flightGyro:Destroy(); conn.flightGyro = nil end
	if conn.blankTrack then pcall(function() conn.blankTrack:Stop(0.1); conn.blankTrack:Destroy() end); conn.blankTrack = nil end
	if not enabled then return end
	local root = getRoot()
	if not root then return end
	conn.flightVelocity = Instance.new("BodyVelocity")
	conn.flightVelocity.MaxForce = Vector3.new(1e5,1e5,1e5)
	conn.flightVelocity.Velocity = Vector3.zero
	conn.flightVelocity.Parent = root
	conn.flightGyro = Instance.new("BodyGyro")
	conn.flightGyro.MaxTorque = Vector3.new(1e6,1e6,1e6)
	conn.flightGyro.P = 1000
	conn.flightGyro.CFrame = root.CFrame
	conn.flightGyro.Parent = root
	conn.blankTrack = getBlankTrack()
	if conn.blankTrack then pcall(function() conn.blankTrack:Play(0.1) end) end
	conn.flight = RunService.RenderStepped:Connect(function()
		if not states.Flight or not root.Parent then return end
		local cam = workspace.CurrentCamera
		if not cam then return end
		local dir = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
		if dir.Magnitude > 0 then dir = dir.Unit end
		conn.flightVelocity.Velocity = dir * flightSpeed
		local look = cam.CFrame.LookVector
		if look.Magnitude > 0.001 then conn.flightGyro.CFrame = CFrame.lookAt(root.Position, root.Position + look) end
	end)
end

local function createTeleportTool()
	if conn.teleportTool then conn.teleportTool:Destroy() end
	conn.teleportTool = Instance.new("Tool")
	conn.teleportTool.Name = "0nyxTeleport"
	conn.teleportTool.RequiresHandle = false
	conn.teleportTool.CanBeDropped = false
	conn.teleportTool.ToolTip = "0nyx Teleport"
	conn.teleportTool.Parent = player:WaitForChild("Backpack")
	conn.teleportTool.Activated:Connect(function()
		if not states.TeleportTool then return end
		local root = getRoot()
		if root and mouse.Hit then root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0,3,0)) end
	end)
end
local function removeTeleportTool()
	if conn.teleportTool then conn.teleportTool:Destroy(); conn.teleportTool = nil end
	local bp = player:FindFirstChild("Backpack")
	if bp and bp:FindFirstChild("0nyxTeleport") then bp:FindFirstChild("0nyxTeleport"):Destroy() end
	local c = player.Character
	if c and c:FindFirstChild("0nyxTeleport") then c:FindFirstChild("0nyxTeleport"):Destroy() end
end

local fullbrightSaved, fogSaved, shadowSaved = nil, nil, nil
local function setFullbright(enabled)
	if enabled then
		if not fullbrightSaved then
			fullbrightSaved = {
				Brightness = Lighting.Brightness, Ambient = Lighting.Ambient,
				OutdoorAmbient = Lighting.OutdoorAmbient, FogEnd = Lighting.FogEnd,
				GlobalShadows = Lighting.GlobalShadows, ClockTime = Lighting.ClockTime,
			}
		end
		Lighting.Brightness = 2
		Lighting.Ambient = Color3.fromRGB(178,178,178)
		Lighting.OutdoorAmbient = Color3.fromRGB(178,178,178)
		Lighting.FogEnd = 100000
		Lighting.GlobalShadows = false
		Lighting.ClockTime = 14
	else
		if fullbrightSaved then
			for k, v in pairs(fullbrightSaved) do Lighting[k] = v end
			fullbrightSaved = nil
		end
	end
end
local function setRemoveFog(enabled)
	if enabled then
		if not fogSaved then fogSaved = { FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart } end
		Lighting.FogEnd = 100000
		Lighting.FogStart = 0
	else
		if fogSaved then Lighting.FogEnd = fogSaved.FogEnd; Lighting.FogStart = fogSaved.FogStart; fogSaved = nil end
	end
end
local function setNoShadows(enabled)
	if enabled then
		if shadowSaved == nil then shadowSaved = Lighting.GlobalShadows end
		Lighting.GlobalShadows = false
	else
		if shadowSaved ~= nil then Lighting.GlobalShadows = shadowSaved; shadowSaved = nil end
	end
end
local function setNoBloom(enabled)
	for _, e in ipairs(Lighting:GetChildren()) do
		if e:IsA("BloomEffect") then e.Enabled = not enabled end
	end
	if enabled and not conn.bloomScan then
		conn.bloomScan = Lighting.DescendantAdded:Connect(function(d)
			if d:IsA("BloomEffect") and states.NoBloom then d.Enabled = false end
		end)
	elseif not enabled and conn.bloomScan then
		conn.bloomScan:Disconnect(); conn.bloomScan = nil
	end
end

local noTextureSaved = {}
local function setNoTextures(enabled)
	if enabled then
		table.clear(noTextureSaved)
		for _, d in ipairs(workspace:GetDescendants()) do
			if d:IsA("Decal") or d:IsA("Texture") then
				noTextureSaved[d] = d.Transparency
				d.Transparency = 1
			end
		end
	else
		for d, t in pairs(noTextureSaved) do
			if d and d.Parent then d.Transparency = t end
		end
		table.clear(noTextureSaved)
	end
end

local function setHighJump(enabled)
	local h = getHumanoid()
	if not h then return end
	if enabled then
		if saved.jump[h] == nil then
			saved.jump[h] = { UseJumpPower = h.UseJumpPower, JumpPower = h.JumpPower }
		end
		h.UseJumpPower = true
		h.JumpPower = jumpPower
	else
		local orig = saved.jump[h]
		if orig then h.UseJumpPower = orig.UseJumpPower; h.JumpPower = orig.JumpPower; saved.jump[h] = nil end
	end
end
local function setFreeze(enabled)
	local root = getRoot()
	if root then root.Anchored = enabled end
end

local function isReddish(c) return c.R > 0.5 and c.R > c.G * 1.2 and c.R > c.B * 1.2 end
local function scanDamageEffects()
	local cam = workspace.CurrentCamera
	local vp = cam and cam.ViewportSize or Vector2.new(1920,1080)
	local function scanContainer(container)
		for _, d in ipairs(container:GetDescendants()) do
			if d:IsA("GuiObject") and d.Name ~= "DamageOverlay" and d.Visible then
				local n = string.lower(d.Name)
				local nameMatch = n:find("damage") or n:find("hurt") or n:find("vignette")
					or n:find("redflash") or n:find("blood") or n:find("hitmarker")
					or n:find("redoverlay") or n:find("redscreen") or n:find("pain")
				local fullScreen = d.AbsoluteSize.X >= vp.X * 0.85 and d.AbsoluteSize.Y >= vp.Y * 0.85
				local redTint = false
				if d:IsA("Frame") or d:IsA("TextLabel") or d:IsA("TextButton") then
					redTint = isReddish(d.BackgroundColor3) and d.BackgroundTransparency < 0.95
				elseif d:IsA("ImageLabel") or d:IsA("ImageButton") then
					redTint = isReddish(d.ImageColor3)
				end
				if nameMatch or (fullScreen and redTint) then d.Visible = false end
			end
		end
	end
	local pg = player:FindFirstChild("PlayerGui")
	if pg then scanContainer(pg) end
	if cam then scanContainer(cam) end
end
local lastDamageScan = 0
local function setNoDamage(enabled)
	if conn.noDamage then conn.noDamage:Disconnect(); conn.noDamage = nil end
	if not enabled then return end
	scanDamageEffects()
	lastDamageScan = os.clock()
	conn.noDamage = RunService.Heartbeat:Connect(function()
		if closed or not states.NoDamage then return end
		local now = os.clock()
		if now - lastDamageScan < 0.1 then return end
		lastDamageScan = now
		scanDamageEffects()
	end)
end

--=====================================================================
--  NEW SETTERS
--=====================================================================
local function refreshAutoRotate()
	local h = getHumanoid()
	if h then h.AutoRotate = not (states.Spin or states.FaceCamera) end
end
local function setLowGravity(enabled)
	workspace.Gravity = enabled and cfg.gravity or 196
end
local function setPlatformStand(enabled)
	local h = getHumanoid()
	if h then h.PlatformStand = enabled end
end
local function setNoRagdoll(enabled)
	local h = getHumanoid()
	if h then h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, not enabled) end
end
local function setNoCameraShake(enabled)
	local h = getHumanoid()
	if h then h.CameraOffset = Vector3.zero end
end
local function setSpin(enabled) refreshAutoRotate() end
local function setFaceCamera(enabled) refreshAutoRotate() end
local function setSwimAnywhere(enabled)
	if not enabled then
		local h = getHumanoid()
		if h then h:ChangeState(Enum.HumanoidStateType.Running) end
	end
end
local function setFastRespawn(enabled)
	pcall(function() Players.RespawnTime = enabled and 0.1 or 5 end)
end
local function setImmortal(enabled)
	if conn.immortal then conn.immortal:Disconnect(); conn.immortal = nil end
	if not enabled then return end
	conn.immortal = RunService.Heartbeat:Connect(function()
		if closed or not states.Immortal then return end
		local h = getHumanoid()
		if not h then return end
		if h.Health < h.MaxHealth then h.Health = h.MaxHealth end
		if h:GetState() == Enum.HumanoidStateType.Dead then
			h.Health = h.MaxHealth
			h:ChangeState(Enum.HumanoidStateType.Running)
		end
	end)
end
local function setHealthRegen(enabled)
	if conn.regen then conn.regen:Disconnect(); conn.regen = nil end
	if not enabled then return end
	conn.regen = RunService.Heartbeat:Connect(function()
		if closed or not states.HealthRegen then return end
		local h = getHumanoid()
		if h and h.Health < h.MaxHealth and h.Health > 0 then
			h.Health = math.min(h.MaxHealth, h.Health + cfg.regenRate * (1/60))
		end
	end)
end
local function clearHitbox()
	for root, size in pairs(saved.hitbox) do
		if root and root.Parent then root.Size = size end
	end
	table.clear(saved.hitbox)
end
local function setHitboxExpander(enabled)
	if not enabled then clearHitbox() end
end

function clearReachCleanup()
	for h, size in pairs(saved.reach) do if h and h.Parent then h.Size = size end end
	table.clear(saved.reach)
end
local function setReach(enabled)
	if not enabled then clearReachCleanup() end
end

function updateHighlights()
	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= player and other.Character then
			local target = states.HighlightESP and isESPTarget(other)
			local hl = other.Character:FindFirstChild("0nyxHighlight")
			if target then
				if not hl then
					hl = Instance.new("Highlight")
					hl.Name = "0nyxHighlight"
					hl.FillColor = THEME.accent
					hl.OutlineColor = Color3.fromRGB(255,255,255)
					hl.FillTransparency = 0.6
					hl.OutlineTransparency = 0
					hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					hl.Parent = other.Character
				end
			elseif hl then
				hl:Destroy()
			end
		end
	end
end

local function setSelfHighlight(enabled)
	local c = player.Character
	if not c then return end
	local hl = c:FindFirstChild("0nyxSelfHighlight")
	if enabled then
		if not hl then
			hl = Instance.new("Highlight")
			hl.Name = "0nyxSelfHighlight"
			hl.FillColor = THEME.accent2
			hl.OutlineColor = Color3.fromRGB(255,255,255)
			hl.FillTransparency = 0.65
			hl.Parent = c
		end
	elseif hl then hl:Destroy() end
end

local crosshairGui
local function setCrosshair(enabled)
	if enabled then
		if crosshairGui then crosshairGui:Destroy() end
		crosshairGui = Instance.new("ScreenGui")
		crosshairGui.Name = "0nyxCrosshair"
		crosshairGui.IgnoreGuiInset = true
		crosshairGui.ResetOnSpawn = false
		crosshairGui.Parent = player:WaitForChild("PlayerGui")
		local function bar(w, h)
			local f = Instance.new("Frame")
			f.Size = UDim2.new(0, w, 0, h)
			f.BackgroundColor3 = Color3.fromRGB(255,255,255)
			f.BorderSizePixel = 0
			f.Parent = crosshairGui
			return f
		end
		bar(2, 8).Position = UDim2.new(0.5, -1, 0.5, -14)
		bar(2, 8).Position = UDim2.new(0.5, -1, 0.5, 6)
		bar(8, 2).Position = UDim2.new(0.5, -14, 0.5, -1)
		bar(8, 2).Position = UDim2.new(0.5, 6, 0.5, -1)
	else
		if crosshairGui then crosshairGui:Destroy(); crosshairGui = nil end
	end
end

local function setFreeCam(enabled)
	local cam = workspace.CurrentCamera
	if not cam then return end
	if conn.freecam then conn.freecam:Disconnect(); conn.freecam = nil end
	if enabled then
		conn.freecamSaved = { CFrame = cam.CFrame, CameraType = cam.CameraType,
			Subject = cam.CameraSubject, FOV = cam.FieldOfView }
		cam.CameraType = Enum.CameraType.Scriptable
		local pos = cam.CFrame.Position
		local look = cam.CFrame.LookVector
		local yaw = math.atan2(-look.X, -look.Z)
		local pitch = math.asin(math.clamp(look.Y, -1, 1))
		conn.freecam = RunService.RenderStepped:Connect(function(dt)
			if closed or not states.FreeCam then return end
			local delta = UserInputService:GetMouseDelta()
			yaw -= delta.X * 0.0035
			pitch = math.clamp(pitch - delta.Y * 0.0035, -1.5, 1.5)
			local rot = CFrame.fromEulerAnglesYXZ(pitch, yaw, 0)
			local move = Vector3.zero
			local speed = (UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and 120 or 40) * dt
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += rot.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= rot.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= rot.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += rot.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end
			pos += move
			cam.CFrame = CFrame.new(pos) * rot
		end)
	else
		local s = conn.freecamSaved
		if s then
			cam.CameraType = s.CameraType
			cam.CameraSubject = s.Subject
			cam.CFrame = s.CFrame
			cam.FieldOfView = s.FOV
			conn.freecamSaved = nil
		end
	end
end

local function doClick()
	if type(mouse1click) == "function" then
		pcall(mouse1click)
	else
		local t = getTool()
		if t then pcall(function() t:Activate() end) end
	end
end
local lastClick = 0

local function setAutoEquip(enabled)
	local c = player.Character
	local bp = player:FindFirstChildOfClass("Backpack")
	if enabled and c and bp then
		for _, t in ipairs(bp:GetChildren()) do
			if t:IsA("Tool") then
				local h = getHumanoid()
				if h then pcall(function() h:EquipTool(t) end) end
				break
			end
		end
	end
end

local function setDamageIndicator(enabled)
	if conn.dmg then conn.dmg:Disconnect(); conn.dmg = nil end
	if not enabled then return end
	local function bindTool(t)
		if t:IsA("Tool") then
			t.Activated:Connect(function()
				if states.DamageIndicator then showHitmarker() end
			end)
		end
	end
	local c = player.Character
	if c then
		for _, t in ipairs(c:GetChildren()) do bindTool(t) end
		conn.dmg = c.ChildAdded:Connect(bindTool)
	end
end

local function setFPSHud(enabled) hud.Visible = enabled end

--=====================================================================
--  STATE SETTER MAP
--=====================================================================
local stateSetters = {
	Godmode = setGodmode, InfiniteJump = function() end, AntiFling = setAntiFling,
	AntiAFK = setAntiAFK, Flight = setFlight, Noclip = setNoclip, Invisible = setInvisible,
	Fullbright = setFullbright, HighJump = setHighJump, Freeze = setFreeze,
	NoDamage = setNoDamage,
	TeleportTool = function(v) if v then createTeleportTool() else removeTeleportTool() end end,
	Aimbot = setAimbot, AntiKick = setAntiKick, AntiBan = setAntiBan,
	Sprint = function() end, DoubleJump = function() end, LowGravity = setLowGravity,
	Hover = function() end, SwimAnywhere = setSwimAnywhere, NoFallDamage = function() end,
	BunnyHop = function() end, PlatformStand = setPlatformStand, Spin = setSpin,
	FaceCamera = setFaceCamera, HealthRegen = setHealthRegen, Immortal = setImmortal,
	NoRagdoll = setNoRagdoll, NoCameraShake = setNoCameraShake, FastRespawn = setFastRespawn,
	HitboxExpander = setHitboxExpander, AntiVoid = function() end,
	HighlightESP = updateHighlights, TracerESP = function() end,
	DistanceESP = function() end, HealthESP = function() end,
	Crosshair = setCrosshair, SelfHighlight = setSelfHighlight, RemoveFog = setRemoveFog,
	NoTextures = setNoTextures, NoShadows = setNoShadows, NoBloom = setNoBloom,
	FPSHud = setFPSHud, AutoClicker = function() end, KillAura = function() end,
	Reach = setReach, FastAttack = function() end, AutoEquip = setAutoEquip,
	DamageIndicator = setDamageIndicator, FreeCam = setFreeCam,
}

--=====================================================================
--  INPUT
--=====================================================================
UserInputService.JumpRequest:Connect(function()
	local h = getHumanoid()
	if not h then return end
	if states.InfiniteJump then
		h:ChangeState(Enum.HumanoidStateType.Jumping)
	end
	if states.DoubleJump and h.FloorMaterial == Enum.Material.Air and jumpsLeft > 0 then
		jumpsLeft -= 1
		local root = getRoot()
		if root then
			local v = root.AssemblyLinearVelocity
			root.AssemblyLinearVelocity = Vector3.new(v.X, jumpPower, v.Z)
		end
		h:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 and states.ClickTeleport then
		local root = getRoot()
		if root and mouse.Hit then root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0,3,0)) end
	end
end)

--=====================================================================
--  MAIN LOOPS
--=====================================================================
local mainHeartbeat = RunService.Heartbeat:Connect(function(dt)
	if closed then return end
	local character = player.Character
	if not character then return end
	local h = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")

	if h then
		h.WalkSpeed = states.Sprint and (UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and walkSpeed * 2 or walkSpeed) or walkSpeed
		if states.HighJump then h.UseJumpPower = true; h.JumpPower = jumpPower end
	end

	if root and h then
		if h.FloorMaterial ~= Enum.Material.Air then jumpsLeft = maxJumps end
		if states.Hover and h.FloorMaterial == Enum.Material.Air and UserInputService:IsKeyDown(Enum.KeyCode.Space) and not states.Flight then
			local v = root.AssemblyLinearVelocity
			root.AssemblyLinearVelocity = Vector3.new(v.X, 0, v.Z)
		end
		if states.BunnyHop and h.FloorMaterial ~= Enum.Material.Air and h.MoveDirection.Magnitude > 0.05 then
			h:ChangeState(Enum.HumanoidStateType.Jumping)
		end
		if states.NoFallDamage and h.FloorMaterial == Enum.Material.Air and root.AssemblyLinearVelocity.Y < -60 then
			local v = root.AssemblyLinearVelocity
			root.AssemblyLinearVelocity = Vector3.new(v.X, -60, v.Z)
		end
		if states.Spin then
			root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(cfg.spinSpeed) * dt * 6, 0)
		end
		if states.FaceCamera then
			local cam = workspace.CurrentCamera
			if cam then
				local look = cam.CFrame.LookVector
				local flat = Vector3.new(look.X, 0, look.Z)
				if flat.Magnitude > 0.01 then root.CFrame = CFrame.lookAt(root.Position, root.Position + flat.Unit) end
			end
		end
		if states.SwimAnywhere and h.FloorMaterial == Enum.Material.Air then
			h:ChangeState(Enum.HumanoidStateType.Swimming)
		end
	end

	if states.HitboxExpander and root then
		for _, other in ipairs(Players:GetPlayers()) do
			local r = getRoot(other)
			if r then
				if saved.hitbox[r] == nil then saved.hitbox[r] = r.Size end
				r.Size = Vector3.new(cfg.hitboxSize, cfg.hitboxSize, cfg.hitboxSize)
			end
		end
	end

	local tool = getTool()
	if tool then
		if states.Reach and tool:FindFirstChild("Handle") then
			local hd = tool.Handle
			if saved.reach[hd] == nil then saved.reach[hd] = hd.Size end
			hd.Size = saved.reach[hd] * cfg.reach
		end
		if states.FastAttack and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
			pcall(function() tool:Activate() end)
		end
		if states.AutoClicker then
			local now = os.clock()
			if now - lastClick >= cfg.clickDelay then
				lastClick = now
				doClick()
			end
		end
		if states.KillAura and root then
			local nearest, bestD = nil, cfg.killAuraRange
			for _, other in ipairs(Players:GetPlayers()) do
				if other ~= player then
					local r = getRoot(other)
					local oh = getHumanoid(other)
					if r and oh and oh.Health > 0 then
						local d = (r.Position - root.Position).Magnitude
						if d < bestD then nearest, bestD = r, d end
					end
				end
			end
			if nearest then
				root.CFrame = CFrame.lookAt(root.Position, Vector3.new(nearest.Position.X, root.Position.Y, nearest.Position.Z))
				pcall(function() tool:Activate() end)
			end
		end
	end

	if (states.AntiVoid or states.Godmode) and not voidBusy and root and root.Position.Y < VOID_Y then
		voidRescue()
	end

	if states.ESP or states.HighlightESP or states.DistanceESP or states.HealthESP
		or states.ESPBox or states.ESPNames or states.TracerESP then
		updateESP()
		updateHighlights()
		updateTracers()
	end
end)

local previousStates = {}
for k, v in pairs(states) do previousStates[k] = v end

local stateHeartbeat = RunService.Heartbeat:Connect(function()
	if closed then return end
	for key, setter in pairs(stateSetters) do
		if states[key] ~= previousStates[key] then
			previousStates[key] = states[key]
			pcall(setter, states[key])
		end
	end
	if states.ESP ~= previousStates.ESP or states.ESPBox ~= previousStates.ESPBox or states.ESPNames ~= previousStates.ESPNames then
		previousStates.ESP = states.ESP
		previousStates.ESPBox = states.ESPBox
		previousStates.ESPNames = states.ESPNames
		updateESP()
	end
end)

local fpsAccum, fpsFrames = 0, 0
RunService.Heartbeat:Connect(function(dt)
	if closed or not states.FPSHud then return end
	fpsAccum += dt
	fpsFrames += 1
	if fpsAccum >= 0.5 then
		local fps = math.floor(fpsFrames / fpsAccum)
		fpsAccum, fpsFrames = 0, 0
		local ok, p = pcall(function()
			return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
		end)
		local ping = ok and math.floor(p) or 0
		hud.Text = "FPS " .. fps .. "  |  PING " .. ping .. "ms"
		hud.TextColor3 = fps > 45 and Color3.fromRGB(120,220,150) or Color3.fromRGB(240,180,90)
	end
end)

--=====================================================================
--  ESP ENGINE  (globals so the loops above can call them)
--=====================================================================
function isESPTarget(other)
	if next(espSelected) == nil then return true end
	return espSelected[other.Name] == true
end

local tracerLines = {}

function updateTracers()
	if not DrawingLib then return end
	local cam = workspace.CurrentCamera
	if not cam then return end
	local bottom = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y)
	for _, other in ipairs(Players:GetPlayers()) do
		local line = tracerLines[other]
		local active = other ~= player and states.TracerESP and states.ESP
			and isESPTarget(other) and other.Character
		if active then
			local head = other.Character:FindFirstChild("Head")
				or other.Character:FindFirstChild("HumanoidRootPart")
			if head then
				local pos, onScreen = cam:WorldToViewportPoint(head.Position)
				if not line then
					line = DrawingLib.new("Line")
					line.Thickness = 1
					line.Color = THEME.accent
					line.Transparency = 0.2
					tracerLines[other] = line
				end
				line.From = bottom
				line.To = Vector2.new(pos.X, pos.Y)
				line.Visible = onScreen and pos.Z > 0
			elseif line then
				line.Visible = false
			end
		elseif line then
			pcall(function() line:Remove() end)
			tracerLines[other] = nil
		end
	end
end

local function createESPBox(character)
	local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
	if not root then return end
	local bb = Instance.new("BillboardGui")
	bb.Name = "0nyxESPBox"
	bb.Adornee = root
	bb.AlwaysOnTop = true
	bb.LightInfluence = 0
	bb.Size = UDim2.new(0, 60, 0, 80)
	bb.Parent = character
	local box = Instance.new("Frame")
	box.Size = UDim2.new(1,0,1,0)
	box.BackgroundTransparency = 1
	box.BorderSizePixel = 0
	box.Parent = bb
	local stroke = Instance.new("UIStroke")
	stroke.Color = THEME.accent
	stroke.Thickness = 1.5
	stroke.Transparency = 0.1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = box
end

local function createESPName(character, name)
	local head = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
	if not head then return end
	local bb = Instance.new("BillboardGui")
	bb.Name = "0nyxESPName"
	bb.Adornee = head
	bb.Size = UDim2.new(0, 200, 0, 36)
	bb.StudsOffset = Vector3.new(0, 2.6, 0)
	bb.AlwaysOnTop = true
	bb.LightInfluence = 0
	bb.Parent = character
	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.new(1,0,1,0)
	lbl.Text = name
	lbl.TextColor3 = Color3.fromRGB(255,255,255)
	lbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
	lbl.TextStrokeTransparency = 0
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 14
	lbl.Parent = bb
end

local function createESPDistance(character)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local bb = Instance.new("BillboardGui")
	bb.Name = "0nyxESPDist"
	bb.Adornee = root
	bb.Size = UDim2.new(0, 100, 0, 20)
	bb.StudsOffset = Vector3.new(0, -3, 0)
	bb.AlwaysOnTop = true
	bb.LightInfluence = 0
	bb.Parent = character
	local lbl = Instance.new("TextLabel")
	lbl.Name = "Dist"
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.new(1,0,1,0)
	lbl.Text = "0m"
	lbl.TextColor3 = THEME.accent2
	lbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
	lbl.TextStrokeTransparency = 0
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 12
	lbl.Parent = bb
end

local function createESPHealth(character)
	local head = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
	if not head then return end
	local bb = Instance.new("BillboardGui")
	bb.Name = "0nyxESPHealth"
	bb.Adornee = head
	bb.Size = UDim2.new(0, 60, 0, 8)
	bb.StudsOffset = Vector3.new(0, 3.4, 0)
	bb.AlwaysOnTop = true
	bb.LightInfluence = 0
	bb.Parent = character
	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1,0,1,0)
	bg.BackgroundColor3 = Color3.fromRGB(30,30,30)
	bg.BorderSizePixel = 0
	bg.Parent = bb
	corner(bg, 3)
	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.new(1,0,1,0)
	fill.BackgroundColor3 = Color3.fromRGB(120,220,150)
	fill.BorderSizePixel = 0
	fill.Parent = bg
	corner(fill, 3)
end

function updateESP()
	local cam = workspace.CurrentCamera
	if not cam then return end
	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= player and other.Character then
			local target = states.ESP and isESPTarget(other)
			local root = other.Character:FindFirstChild("HumanoidRootPart")
			local hum = getHumanoid(other)

			local box = other.Character:FindFirstChild("0nyxESPBox")
			if target and states.ESPBox and root then
				if not box then createESPBox(other.Character); box = other.Character:FindFirstChild("0nyxESPBox") end
				if box then
					local distance = (cam.CFrame.Position - root.Position).Magnitude
					local ppu = (cam.ViewportSize.Y / 2) / (math.max(distance, 0.1) * math.tan(math.rad(cam.FieldOfView) / 2))
					box.Size = UDim2.new(0, math.clamp(3 * ppu, 6, 1000), 0, math.clamp(6 * ppu, 8, 2000))
				end
			elseif box then box:Destroy() end

			local nameTag = other.Character:FindFirstChild("0nyxESPName")
			if target and states.ESPNames then
				if not nameTag then createESPName(other.Character, other.Name) end
			elseif nameTag then nameTag:Destroy() end

			local distTag = other.Character:FindFirstChild("0nyxESPDist")
			if target and states.DistanceESP and root then
				if not distTag then createESPDistance(other.Character); distTag = other.Character:FindFirstChild("0nyxESPDist") end
				if distTag then
					local lbl = distTag:FindFirstChild("Dist")
					if lbl then lbl.Text = math.floor((cam.CFrame.Position - root.Position).Magnitude) .. "m" end
				end
			elseif distTag then distTag:Destroy() end

			local hpTag = other.Character:FindFirstChild("0nyxESPHealth")
			if target and states.HealthESP then
				if not hpTag then createESPHealth(other.Character); hpTag = other.Character:FindFirstChild("0nyxESPHealth") end
				if hpTag and hum then
					local fill = hpTag:FindFirstChild("Fill")
					if fill then
						local ratio = math.clamp(hum.Health / math.max(1, hum.MaxHealth), 0, 1)
						fill.Size = UDim2.new(ratio, 0, 1, 0)
					end
				end
			elseif hpTag then hpTag:Destroy() end
		end
	end
end

--=====================================================================
--  PLAYERS PAGE
--=====================================================================
local function teleportTo(other)
	local r, tr = getRoot(), getRoot(other)
	if r and tr then r.CFrame = tr.CFrame + Vector3.new(0, 1, 0) end
end
local function spectate(other)
	local cam = workspace.CurrentCamera
	local h = getHumanoid(other)
	if cam and h then cam.CameraSubject = h; cam.CameraType = Enum.CameraType.Custom end
end
local function killPlayer(other)
	local h = getHumanoid(other)
	if h then
		pcall(function() h.Health = 0 end)
		pcall(function() h:TakeDamage(h.MaxHealth) end)
	end
end
local function freezePlayer(other)
	local r = getRoot(other)
	if not r then return end
	r.Anchored = not r.Anchored
	frozenPlayers[other] = r.Anchored
end
local function flingPlayer(other)
	local r = getRoot(other)
	if r then
		r.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
		r.AssemblyAngularVelocity = Vector3.new(0, 5000, 0)
	end
end

local function rebuildPlayerList()
	for _, ch in ipairs(playerList:GetChildren()) do
		if ch:IsA("Frame") then ch:Destroy() end
	end
	local filter = string.lower(playerSearch.Text or "")
	local order = 0
	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= player and (filter == "" or string.find(string.lower(other.Name), filter, 1, true)) then
			order += 1
			local row = Instance.new("Frame")
			row.LayoutOrder = order
			row.Size = UDim2.new(1, 0, 0, 66)
			row.BackgroundColor3 = Color3.fromRGB(20,20,26)
			row.BorderSizePixel = 0
			row.ZIndex = 8
			row.Parent = playerList
			corner(row, 8); outline(row, THEME.stroke, 0.3, 1)

			local name = Instance.new("TextLabel")
			name.BackgroundTransparency = 1
			name.Position = UDim2.new(0, 12, 0, 4)
			name.Size = UDim2.new(1, -24, 0, 20)
			name.Text = other.Name
			name.Font = Enum.Font.GothamBold
			name.TextSize = 11
			name.TextColor3 = THEME.text
			name.TextXAlignment = Enum.TextXAlignment.Left
			name.ZIndex = 9
			name.Parent = row

			local function smallBtn(text, x, cb)
				local b = Instance.new("TextButton")
				b.Size = UDim2.new(0, 44, 0, 22)
				b.Position = UDim2.new(0, x, 0, 34)
				b.BackgroundColor3 = THEME.panel2
				b.BorderSizePixel = 0
				b.Text = text
				b.Font = Enum.Font.GothamBold
				b.TextSize = 9
				b.TextColor3 = THEME.text
				b.ZIndex = 9
				b.Parent = row
				corner(b, 5); addHover(b, THEME.panel2, Color3.fromRGB(40,40,54))
				b.MouseButton1Click:Connect(cb)
			end
			smallBtn("Goto", 10, function() teleportTo(other) end)
			smallBtn("Spec", 58, function() spectate(other) end)
			smallBtn("Kill", 106, function() killPlayer(other) end)
			smallBtn("Freeze", 154, function() freezePlayer(other) end)
			smallBtn("Fling", 202, function() flingPlayer(other) end)
		end
	end
end
playerSearch:GetPropertyChangedSignal("Text"):Connect(rebuildPlayerList)

-- ESP target list
local function rebuildESPTargets()
	for _, ch in ipairs(espTargetList:GetChildren()) do
		if ch:IsA("TextButton") then ch:Destroy() end
	end
	local all = Instance.new("TextButton")
	all.LayoutOrder = 1
	all.Size = UDim2.new(1, 0, 0, 28)
	all.BackgroundColor3 = next(espSelected) == nil and THEME.accent or Color3.fromRGB(22,22,28)
	all.BorderSizePixel = 0
	all.Text = "All Players"
	all.Font = Enum.Font.GothamMedium
	all.TextSize = 11
	all.TextColor3 = next(espSelected) == nil and Color3.fromRGB(12,12,16) or THEME.text
	all.ZIndex = 9
	all.Parent = espTargetList
	corner(all, 6)
	all.MouseButton1Click:Connect(function()
		table.clear(espSelected)
		rebuildESPTargets()
		updateESP()
	end)
	local order = 1
	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= player then
			order += 1
			local selected = espSelected[other.Name] == true
			local b = Instance.new("TextButton")
			b.LayoutOrder = order
			b.Size = UDim2.new(1, 0, 0, 28)
			b.BackgroundColor3 = selected and THEME.accent or Color3.fromRGB(22,22,28)
			b.BorderSizePixel = 0
			b.Text = (selected and "[x] " or "[ ] ") .. other.Name
			b.Font = Enum.Font.GothamMedium
			b.TextSize = 11
			b.TextColor3 = selected and Color3.fromRGB(12,12,16) or THEME.text
			b.TextXAlignment = Enum.TextXAlignment.Left
			b.ZIndex = 9
			b.Parent = espTargetList
			corner(b, 6)
			local bp = Instance.new("UIPadding"); bp.PaddingLeft = UDim.new(0, 10); bp.Parent = b
			b.MouseButton1Click:Connect(function()
				if espSelected[other.Name] then espSelected[other.Name] = nil else espSelected[other.Name] = true end
				rebuildESPTargets()
				updateESP()
			end)
		end
	end
end

rebuildESPTargets()
rebuildPlayerList()
Players.PlayerAdded:Connect(function() rebuildESPTargets(); rebuildPlayerList() end)
Players.PlayerRemoving:Connect(function(plr)
	rebuildESPTargets()
	rebuildPlayerList()
	if tracerLines[plr] then pcall(function() tracerLines[plr]:Remove() end); tracerLines[plr] = nil end
	updateESP()
end)

--=====================================================================
--  CHARACTER HANDLING
--=====================================================================
local function bindHealthFlash(character)
	if conn.health then conn.health:Disconnect(); conn.health = nil end
	local h = character:FindFirstChildOfClass("Humanoid")
	if not h then return end
	local lastHealth = h.Health
	conn.health = h.HealthChanged:Connect(function(health)
		if states.Godmode and health < lastHealth - 0.01 then flashDamage() end
		lastHealth = health
	end)
end

local function reapplyActiveStates()
	for key, setter in pairs(stateSetters) do
		if states[key] then pcall(setter, true) end
	end
end

local function setupCharacter(character)
	task.wait(0.75)
	if closed then return end
	jumpsLeft = maxJumps

	if customAnimationEnabled then
		if currentAnimationPack == "Custom Mix" then applyCustomMix()
		elseif currentAnimationPack ~= "Default" then applyAnimationPack(currentAnimationPack) end
	end

	reapplyActiveStates()

	local root = character:FindFirstChild("HumanoidRootPart")
	if root then lastSafePos = root.Position end

	if states.FastRespawn then
		local h = character:FindFirstChildOfClass("Humanoid")
		if h then
			h.Died:Connect(function()
				if states.FastRespawn then task.wait(0.1); pcall(function() player:LoadCharacter() end) end
			end)
		end
	end
	bindHealthFlash(character)
end

player.CharacterAdded:Connect(setupCharacter)
if player.Character then task.spawn(function() setupCharacter(player.Character) end) end

--=====================================================================
--  NAVIGATION
--=====================================================================
local function showPage(name)
	for pageName, frame in pairs(pageFrames) do
		frame.Visible = pageName == name
		if pageName == name then
			frame.Position = UDim2.new(0, 10, 0, 0)
			TweenService:Create(frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Position = UDim2.new(0, 0, 0, 0) }):Play()
		end
	end
	for buttonName, button in pairs(pageButtons) do
		if buttonName == name then
			button.BackgroundTransparency = 0
			button.BackgroundColor3 = Color3.fromRGB(28,28,38)
			button.TextColor3 = Color3.fromRGB(255,255,255)
			TweenService:Create(activeIndicator, TweenInfo.new(0.2),
				{ Position = UDim2.new(0, 4, 0, button.Position.Y.Offset + 5) }):Play()
		else
			button.BackgroundTransparency = 1
			button.TextColor3 = THEME.sub
		end
	end
	topTitle.Text = name
end
for name, button in pairs(pageButtons) do
	button.MouseButton1Click:Connect(function() showPage(name) end)
end
showPage("Home")

--=====================================================================
--  WINDOW CONTROLS
--=====================================================================
local miniButton = Instance.new("TextButton")
miniButton.Size = UDim2.new(0, 58, 0, 58)
miniButton.Position = UDim2.new(0, 8, 0, 44)
miniButton.BackgroundColor3 = Color3.fromRGB(3,3,3)
miniButton.BorderSizePixel = 0
miniButton.Text = ""
miniButton.Visible = false
miniButton.ZIndex = 20
miniButton.Parent = gui
corner(miniButton, 29); outline(miniButton, THEME.accent, 0.2, 1)
local hole = Instance.new("Frame")
hole.Size = UDim2.new(0, 17, 0, 17)
hole.Position = UDim2.new(0.5, -8.5, 0.5, -8.5)
hole.BackgroundColor3 = Color3.fromRGB(0,0,0)
hole.BorderSizePixel = 0
hole.ZIndex = 22
hole.Parent = miniButton
corner(hole, 20); outline(hole, Color3.fromRGB(255,255,255), 0.15, 2)

local confirmOverlay = Instance.new("Frame")
confirmOverlay.Size = UDim2.new(1,0,1,0)
confirmOverlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
confirmOverlay.BackgroundTransparency = 0.25
confirmOverlay.Visible = false
confirmOverlay.ZIndex = 20
confirmOverlay.Parent = main

local confirmBox = Instance.new("Frame")
confirmBox.Size = UDim2.new(0, 300, 0, 160)
confirmBox.Position = UDim2.new(0.5, -150, 0.5, -80)
confirmBox.BackgroundColor3 = THEME.panel
confirmBox.BorderSizePixel = 0
confirmBox.ZIndex = 21
confirmBox.Parent = confirmOverlay
corner(confirmBox, 10); outline(confirmBox, THEME.stroke, 0.1, 1)

local confirmTitle = Instance.new("TextLabel")
confirmTitle.BackgroundTransparency = 1
confirmTitle.Position = UDim2.new(0, 18, 0, 16)
confirmTitle.Size = UDim2.new(1, -36, 0, 25)
confirmTitle.Text = "Close 0nyxhub?"
confirmTitle.Font = Enum.Font.GothamBold
confirmTitle.TextSize = 17
confirmTitle.TextColor3 = Color3.fromRGB(255,255,255)
confirmTitle.TextXAlignment = Enum.TextXAlignment.Left
confirmTitle.ZIndex = 22
confirmTitle.Parent = confirmBox
glow(confirmTitle, THEME.accent, 3)

local confirmMessage = Instance.new("TextLabel")
confirmMessage.BackgroundTransparency = 1
confirmMessage.Position = UDim2.new(0, 18, 0, 48)
confirmMessage.Size = UDim2.new(1, -36, 0, 40)
confirmMessage.Text = "Are you sure you want to close this hub?"
confirmMessage.Font = Enum.Font.Gotham
confirmMessage.TextSize = 11
confirmMessage.TextColor3 = THEME.sub
confirmMessage.TextWrapped = true
confirmMessage.TextXAlignment = Enum.TextXAlignment.Left
confirmMessage.ZIndex = 22
confirmMessage.Parent = confirmBox

local cancel = Instance.new("TextButton")
cancel.Size = UDim2.new(0, 105, 0, 34)
cancel.Position = UDim2.new(0, 18, 1, -50)
cancel.BackgroundColor3 = THEME.panel2
cancel.BorderSizePixel = 0
cancel.Text = "Cancel"
cancel.Font = Enum.Font.GothamMedium
cancel.TextSize = 11
cancel.TextColor3 = THEME.text
cancel.ZIndex = 22
cancel.Parent = confirmBox
corner(cancel, 6); addHover(cancel, THEME.panel2, Color3.fromRGB(40,40,54))

local confirm = Instance.new("TextButton")
confirm.Size = UDim2.new(0, 105, 0, 34)
confirm.Position = UDim2.new(1, -123, 1, -50)
confirm.BackgroundColor3 = THEME.accent
confirm.BorderSizePixel = 0
confirm.Text = "Confirm"
confirm.Font = Enum.Font.GothamBold
confirm.TextSize = 11
confirm.TextColor3 = Color3.fromRGB(12,12,16)
confirm.ZIndex = 22
confirm.Parent = confirmBox
corner(confirm, 6)

minimize.MouseButton1Click:Connect(function()
	main.Visible = false
	miniButton.Visible = true
end)
miniButton.MouseButton1Click:Connect(function()
	if miniButton:GetAttribute("Dragged") then return end
	main.Visible = true
	miniButton.Visible = false
	updateScale()
end)
fullscreen.MouseButton1Click:Connect(function()
	fullscreenEnabled = not fullscreenEnabled
	if fullscreenEnabled then
		main.Size = UDim2.new(1, -20, 1, -20)
		main.Position = UDim2.new(0, 10, 0, 10)
		fullscreen.Text = "■"
	else
		main.Size = UDim2.new(0, 560, 0, 420)
		main.Position = UDim2.new(0.5, -280, 0.5, -210)
		fullscreen.Text = "□"
	end
end)
closeButton.MouseButton1Click:Connect(function() confirmOverlay.Visible = true end)
cancel.MouseButton1Click:Connect(function() confirmOverlay.Visible = false end)

confirm.MouseButton1Click:Connect(function()
	if closed then return end
	closed = true
	stopCustomAnimationController()
	enableDefaultAnimate(player.Character)
	for _, setter in pairs(stateSetters) do pcall(setter, false) end
	setFullbright(false); setRemoveFog(false); setNoShadows(false); setNoBloom(false)
	setNoTextures(false); clearHitbox(); clearReachCleanup()
	for _, line in pairs(tracerLines) do pcall(function() line:Remove() end) end
	if mainHeartbeat then mainHeartbeat:Disconnect() end
	if stateHeartbeat then stateHeartbeat:Disconnect() end
	for _, c in ipairs(cameraConnections) do if c then c:Disconnect() end end
	if currentCameraConnection then currentCameraConnection:Disconnect() end
	gui:Destroy()
end)

--=====================================================================
--  STARTUP
--=====================================================================
local errorKicked = false
local function playBounce()
	main.Visible = true
	main.Size = UDim2.new(0, 70, 0, 52)
	main.Position = UDim2.new(0.5, -35, 0.5, -26)
	TweenService:Create(main, TweenInfo.new(0.85, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 560, 0, 420),
		Position = UDim2.new(0.5, -280, 0.5, -210),
	}):Play()
end

local function startErrorSpam()
	local count = 1
	task.spawn(function()
		while not errorKicked do
			for _ = 1, count do
				local d, closeX = createWindowsDialog("Error Error", "Error c:/windows/system32 .c:/windows/system32 .")
				d.Position = UDim2.new(math.random(2,78)/100, 0, math.random(2,78)/100, 0)
				d.Parent = gui
				local err = dialogButton(d, "Error", -96)
				err.MouseButton1Click:Connect(function() d:Destroy() end)
				closeX.MouseButton1Click:Connect(function() d:Destroy() end)
			end
			count = math.min(count * 2, 64)
			task.wait(2)
		end
	end)
	task.delay(15, function()
		errorKicked = true
		player:Kick("Error\nError c:/windows/system32.")
	end)
end

do
	local dialog, closeX = createWindowsDialog("Error", "Are you sure you wanna execute this script?")
	dialog.Position = UDim2.new(0.5, -165, 0.5, -84)
	dialog.Parent = gui
	local yes = dialogButton(dialog, "Yes", -186)
	local no = dialogButton(dialog, "No", -96)
	yes.MouseButton1Click:Connect(function() dialog:Destroy(); playBounce() end)
	no.MouseButton1Click:Connect(function() dialog:Destroy(); startErrorSpam() end)
	closeX.MouseButton1Click:Connect(function() dialog:Destroy(); startErrorSpam() end)
end

makeDraggable(main, top)
makeDraggable(miniButton, miniButton)
