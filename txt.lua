local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "0nyxhub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local function corner(object,radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0,radius)
	c.Parent = object
	return c
end

local function outline(object,color,transparency,thickness)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Transparency = transparency or 0
	s.Thickness = thickness or 1
	s.Parent = object
	return s
end

local function glow(object,color,size)
	local s = Instance.new("UIStroke")
	s.Name = "TextGlow"
	s.Color = color
	s.Transparency = 0.48
	s.Thickness = size or 2
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	s.Parent = object

	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0,color),
		ColorSequenceKeypoint.new(0.5,Color3.fromRGB(255,255,255)),
		ColorSequenceKeypoint.new(1,color)
	})
	gradient.Parent = s

	return s
end

local function pad(parent,all)
	local p = Instance.new("UIPadding")
	p.PaddingTop = UDim.new(0,all)
	p.PaddingBottom = UDim.new(0,all)
	p.PaddingLeft = UDim.new(0,all)
	p.PaddingRight = UDim.new(0,all)
	p.Parent = parent
	return p
end

local function listLayout(parent,gap)
	local l = Instance.new("UIListLayout")
	l.Padding = UDim.new(0,gap)
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.Parent = parent
	return l
end

-- ===== Windows-style error dialog builder =====
local function createWindowsDialog(titleText,messageText)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0,330,0,168)
	frame.BackgroundColor3 = Color3.fromRGB(240,240,240)
	frame.BorderSizePixel = 0
	frame.ZIndex = 200
	corner(frame,7)
	outline(frame,Color3.fromRGB(110,110,110),0,1)

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(1,0,0,28)
	bar.BackgroundColor3 = Color3.fromRGB(0,88,238)
	bar.BorderSizePixel = 0
	bar.ZIndex = 201
	bar.Parent = frame
	corner(bar,7)

	local barGradient = Instance.new("UIGradient")
	barGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0,Color3.fromRGB(0,88,238)),
		ColorSequenceKeypoint.new(1,Color3.fromRGB(61,139,255))
	})
	barGradient.Parent = bar

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
	corner(closeX,4)

	local icon = Instance.new("Frame")
	icon.Size = UDim2.new(0,34,0,34)
	icon.Position = UDim2.new(0,16,0,46)
	icon.BackgroundColor3 = Color3.fromRGB(220,50,45)
	icon.BorderSizePixel = 0
	icon.ZIndex = 202
	icon.Parent = frame
	corner(icon,17)

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

	return frame,closeX
end

local function dialogButton(parent,text,xOffset)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0,84,0,28)
	b.Position = UDim2.new(1,xOffset,1,-38)
	b.BackgroundColor3 = Color3.fromRGB(225,225,225)
	b.BorderSizePixel = 0
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 11
	b.TextColor3 = Color3.fromRGB(20,20,20)
	b.ZIndex = 202
	b.Parent = parent
	corner(b,5)
	outline(b,Color3.fromRGB(140,140,140),0,1)
	return b
end

local dragConnections = {}

local function makeDraggable(object,handle)
	local dragging = false
	local dragStart
	local startPosition

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPosition = object.Position
			object:SetAttribute("Dragged",false)
		end
	end)

	handle.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	if dragConnections[handle] then
		dragConnections[handle]:Disconnect()
	end

	dragConnections[handle] = UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end

		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			local delta = input.Position - dragStart

			if math.abs(delta.X) > 3 or math.abs(delta.Y) > 3 then
				object:SetAttribute("Dragged",true)
			end

			object.Position = UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + delta.X,
				startPosition.Y.Scale,
				startPosition.Y.Offset + delta.Y
			)
		end
	end)
end

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
	TweenService:Create(
		damageOverlay,
		TweenInfo.new(0.45,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
		{ BackgroundTransparency = 1 }
	):Play()
end

local voidFlash = Instance.new("Frame")
voidFlash.Name = "VoidFlash"
voidFlash.Size = UDim2.new(1,0,1,0)
voidFlash.BackgroundColor3 = Color3.fromRGB(255,255,255)
voidFlash.BackgroundTransparency = 1
voidFlash.BorderSizePixel = 0
voidFlash.ZIndex = 60
voidFlash.Parent = gui

local voidCover = Instance.new("Frame")
voidCover.Name = "VoidCover"
voidCover.Position = UDim2.new(0,0,0,0)
voidCover.Size = UDim2.new(1,0,1,0)
voidCover.BackgroundColor3 = Color3.fromRGB(7,7,7)
voidCover.BackgroundTransparency = 1
voidCover.BorderSizePixel = 0
voidCover.Visible = false
voidCover.ZIndex = 61
voidCover.Parent = gui

local function addRescueOrb(size, position, fillColor, fillTransparency, strokeTransparency)
	local orb = Instance.new("Frame")
	orb.Name = "RescueBackgroundOrb"
	orb.Size = size
	orb.Position = position
	orb.BackgroundColor3 = fillColor
	orb.BackgroundTransparency = fillTransparency
	orb.BorderSizePixel = 0
	orb.ZIndex = 61
	orb.Parent = voidCover
	corner(orb, 999)
	outline(orb, Color3.fromRGB(210,210,210), strokeTransparency, 1)
	return orb
end

addRescueOrb(UDim2.new(0,220,0,220), UDim2.new(0.64,0,0.08,0), Color3.fromRGB(255,255,255), 0.96, 0.76)
addRescueOrb(UDim2.new(0,150,0,150), UDim2.new(0.20,0,0.62,0), Color3.fromRGB(190,190,190), 0.97, 0.84)
addRescueOrb(UDim2.new(0,70,0,70), UDim2.new(0.78,0,0.70,0), Color3.fromRGB(255,255,255), 0.94, 0.82)

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

local voidTitleStroke = glow(voidTitle,Color3.fromRGB(255,255,255),3)
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

local voidSubStroke = glow(voidSub,Color3.fromRGB(255,255,255),2)
voidSubStroke.Transparency = 1

local function hideVoidText()
	voidTitle.Visible = false
	voidSub.Visible = false
	voidTitle.TextTransparency = 1
	voidSub.TextTransparency = 1
	voidTitleStroke.Transparency = 1
	voidSubStroke.Transparency = 1
end

local states = {
	Godmode = false,
	InfiniteJump = false,
	AntiFling = false,
	AntiAFK = false,
	Flight = false,
	Noclip = false,
	Invisible = false,
	ESP = false,
	ESPBox = true,
	ESPNames = false,
	Fullbright = false,
	HighJump = false,
	Freeze = false,
	NoDamage = false,
	TeleportTool = false,
	ClickTeleport = false,
	Aimbot = false,
	AntiKick = false,
	AntiBan = false
}

local walkSpeed = 16
local flightSpeed = 50
local jumpPower = 100

local aim = { fov = 150, smooth = 0.25 }

local conn = {}

local saved = {
	noclip = {},
	transparency = {},
	god = setmetatable({},{__mode = "k"}),
	jump = setmetatable({},{__mode = "k"})
}

local closed = false
local fullscreenEnabled = false
local minimized = false

local currentAnimationPack = "Default"
local customAnimationEnabled = false

local animationTracks = {}
local animationConnections = {}

local currentAnimationName = nil
local animationGeneration = 0
local animationLoopConnection

local VOID_Y = -75
local lastSafePos = nil
local voidBusy = false

local espSelected = {}

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0,520,0,400)
main.Position = UDim2.new(0.5,-260,0.5,-200)
main.BackgroundColor3 = Color3.fromRGB(10,10,10)
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Visible = false
main.ZIndex = 1
main.Parent = gui

corner(main,12)
outline(main,Color3.fromRGB(80,80,80),0.2,1)

local uiScale = Instance.new("UIScale")
uiScale.Scale = 1
uiScale.Parent = main

local function updateScale()
	local camera = workspace.CurrentCamera
	if not camera then return end

	local width = camera.ViewportSize.X

	if width <= 360 then
		uiScale.Scale = 0.65
	elseif width <= 480 then
		uiScale.Scale = 0.75
	elseif width <= 700 then
		uiScale.Scale = 0.88
	else
		uiScale.Scale = 1
	end
end

updateScale()

local cameraConnections = {}

local function disconnectCameraConnections()
	for _,c in ipairs(cameraConnections) do
		if c then c:Disconnect() end
	end
	table.clear(cameraConnections)
end

local function connectCamera()
	disconnectCameraConnections()

	local camera = workspace.CurrentCamera
	if camera then
		table.insert(cameraConnections,camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale))
	end
end

connectCamera()

local currentCameraConnection = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	task.wait()
	updateScale()
	connectCamera()
end)

local backgroundFX = Instance.new("Frame")
backgroundFX.Name = "FloatingBackground"
backgroundFX.Size = UDim2.new(1,0,1,0)
backgroundFX.BackgroundTransparency = 1
backgroundFX.BorderSizePixel = 0
backgroundFX.ClipsDescendants = true
backgroundFX.ZIndex = 1
backgroundFX.Parent = main

local orb1 = Instance.new("Frame")
orb1.Size = UDim2.new(0,220,0,220)
orb1.Position = UDim2.new(0.64,0,0.01,0)
orb1.BackgroundColor3 = Color3.fromRGB(255,255,255)
orb1.BackgroundTransparency = 0.91
orb1.BorderSizePixel = 0
orb1.ZIndex = 1
orb1.Parent = backgroundFX

corner(orb1,110)
outline(orb1,Color3.fromRGB(255,255,255),0.72,1)

do
	local orb1Gradient = Instance.new("UIGradient")
	orb1Gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,1),
		NumberSequenceKeypoint.new(0.5,0.15),
		NumberSequenceKeypoint.new(1,1)
	})
	orb1Gradient.Parent = orb1
end

TweenService:Create(
	orb1,
	TweenInfo.new(8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),
	{ Position = UDim2.new(0.55,0,0.18,0), BackgroundTransparency = 0.95 }
):Play()

local orb2 = Instance.new("Frame")
orb2.Size = UDim2.new(0,150,0,150)
orb2.Position = UDim2.new(0.20,0,0.60,0)
orb2.BackgroundColor3 = Color3.fromRGB(190,190,190)
orb2.BackgroundTransparency = 0.93
orb2.BorderSizePixel = 0
orb2.ZIndex = 1
orb2.Parent = backgroundFX

corner(orb2,100)
outline(orb2,Color3.fromRGB(200,200,200),0.82,1)

TweenService:Create(
	orb2,
	TweenInfo.new(10,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),
	{ Position = UDim2.new(0.34,0,0.44,0), BackgroundTransparency = 0.96 }
):Play()

local orb3 = Instance.new("Frame")
orb3.Size = UDim2.new(0,70,0,70)
orb3.Position = UDim2.new(0.78,0,0.68,0)
orb3.BackgroundColor3 = Color3.fromRGB(255,255,255)
orb3.BackgroundTransparency = 0.88
orb3.BorderSizePixel = 0
orb3.ZIndex = 1
orb3.Parent = backgroundFX

corner(orb3,50)
outline(orb3,Color3.fromRGB(255,255,255),0.8,1)

TweenService:Create(
	orb3,
	TweenInfo.new(6,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),
	{ Position = UDim2.new(0.70,0,0.58,0), BackgroundTransparency = 0.95 }
):Play()

local function createFloatingParticle()
	local particle = Instance.new("Frame")
	local size = math.random(2,5)

	particle.Size = UDim2.new(0,size,0,size)
	particle.Position = UDim2.new(math.random(5,95)/100,0,1.08,0)
	particle.BackgroundColor3 = Color3.fromRGB(255,255,255)
	particle.BackgroundTransparency = 1
	particle.BorderSizePixel = 0
	particle.ZIndex = 2
	particle.Parent = backgroundFX

	corner(particle,size)

	local duration = math.random(7,13)
	local startX = particle.Position.X.Scale
	local endX = math.clamp(startX + math.random(-15,15)/100, 0.02, 0.98)

	TweenService:Create(
		particle,
		TweenInfo.new(1.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),
		{ BackgroundTransparency = math.random(15,40)/100 }
	):Play()

	local movement = TweenService:Create(
		particle,
		TweenInfo.new(duration,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),
		{ Position = UDim2.new(endX,0,-0.12,0) }
	)

	task.delay(1.3,function()
		if particle.Parent then movement:Play() end
	end)

	task.delay(duration - 2,function()
		if particle.Parent then
			TweenService:Create(
				particle,
				TweenInfo.new(2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),
				{ BackgroundTransparency = 1 }
			):Play()
		end
	end)

	movement.Completed:Connect(function()
		if particle.Parent then particle:Destroy() end
	end)
end

task.spawn(function()
	while gui.Parent do
		createFloatingParticle()
		task.wait(0.18)
	end
end)

local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0,135,1,0)
sidebar.BackgroundColor3 = Color3.fromRGB(7,7,7)
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 5
sidebar.Parent = main

corner(sidebar,12)

local sidebarCover = Instance.new("Frame")
sidebarCover.Size = UDim2.new(0,15,1,0)
sidebarCover.Position = UDim2.new(1,-15,0,0)
sidebarCover.BackgroundColor3 = Color3.fromRGB(7,7,7)
sidebarCover.BorderSizePixel = 0
sidebarCover.ZIndex = 5
sidebarCover.Parent = sidebar

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.new(0,16,0,14)
title.Size = UDim2.new(0,110,0,30)
title.Text = "0nyxhub"
title.Font = Enum.Font.GothamBold
title.TextSize = 21
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 6
title.Parent = sidebar

glow(title,Color3.fromRGB(255,255,255),3)

local subtitle = Instance.new("TextLabel")
subtitle.BackgroundTransparency = 1
subtitle.Position = UDim2.new(0,17,0,40)
subtitle.Size = UDim2.new(0,110,0,20)
subtitle.Text = "CONTROL PANEL"
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 8
subtitle.TextColor3 = Color3.fromRGB(145,145,145)
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.ZIndex = 6
subtitle.Parent = sidebar

local pageButtons = {}
local pageFrames = {}

local function createPageButton(name,index)
	local button = Instance.new("TextButton")

	button.Name = name
	button.Size = UDim2.new(0,110,0,30)
	button.Position = UDim2.new(0,12,0,66+((index-1)*34))
	button.BackgroundColor3 = Color3.fromRGB(15,15,15)
	button.BackgroundTransparency = 1
	button.BorderSizePixel = 0
	button.Text = name
	button.Font = Enum.Font.GothamMedium
	button.TextSize = 10
	button.TextColor3 = Color3.fromRGB(155,155,155)
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.ZIndex = 6
	button.Parent = sidebar

	corner(button,7)

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0,12)
	padding.Parent = button

	pageButtons[name] = button
	return button
end

-- "Emotes" removed
for i,name in ipairs({"Home","Player","Movement","Visuals","Combat","Teleport","Animations","Settings"}) do
	createPageButton(name,i)
end

local top = Instance.new("Frame")
top.Name = "TopBar"
top.Size = UDim2.new(1,-135,0,58)
top.Position = UDim2.new(0,135,0,0)
top.BackgroundTransparency = 1
top.ZIndex = 5
top.Parent = main

local topTitle = Instance.new("TextLabel")
topTitle.BackgroundTransparency = 1
topTitle.Position = UDim2.new(0,20,0,10)
topTitle.Size = UDim2.new(0,200,0,25)
topTitle.Text = "0nyxhub"
topTitle.Font = Enum.Font.GothamBold
topTitle.TextSize = 17
topTitle.TextColor3 = Color3.fromRGB(255,255,255)
topTitle.TextXAlignment = Enum.TextXAlignment.Left
topTitle.ZIndex = 6
topTitle.Parent = top

glow(topTitle,Color3.fromRGB(255,255,255),3)

local topSub = Instance.new("TextLabel")
topSub.BackgroundTransparency = 1
topSub.Position = UDim2.new(0,20,0,32)
topSub.Size = UDim2.new(0,200,0,18)
topSub.Text = "CONTROL PANEL"
topSub.Font = Enum.Font.Gotham
topSub.TextSize = 8
topSub.TextColor3 = Color3.fromRGB(120,120,120)
topSub.TextXAlignment = Enum.TextXAlignment.Left
topSub.ZIndex = 6
topSub.Parent = top

local fullscreen = Instance.new("TextButton")
fullscreen.Size = UDim2.new(0,32,0,28)
fullscreen.Position = UDim2.new(1,-112,0,14)
fullscreen.BackgroundColor3 = Color3.fromRGB(20,20,20)
fullscreen.BorderSizePixel = 0
fullscreen.Text = "□"
fullscreen.Font = Enum.Font.GothamBold
fullscreen.TextSize = 15
fullscreen.TextColor3 = Color3.fromRGB(220,220,220)
fullscreen.ZIndex = 6
fullscreen.Parent = top

corner(fullscreen,6)
outline(fullscreen,Color3.fromRGB(65,65,65),0.2,1)

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0,32,0,28)
minimize.Position = UDim2.new(1,-75,0,14)
minimize.BackgroundColor3 = Color3.fromRGB(20,20,20)
minimize.BorderSizePixel = 0
minimize.Text = "—"
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 15
minimize.TextColor3 = Color3.fromRGB(220,220,220)
minimize.ZIndex = 6
minimize.Parent = top

corner(minimize,6)
outline(minimize,Color3.fromRGB(65,65,65),0.2,1)

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0,32,0,28)
closeButton.Position = UDim2.new(1,-38,0,14)
closeButton.BackgroundColor3 = Color3.fromRGB(20,20,20)
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 12
closeButton.TextColor3 = Color3.fromRGB(220,220,220)
closeButton.ZIndex = 6
closeButton.Parent = top

corner(closeButton,6)
outline(closeButton,Color3.fromRGB(65,65,65),0.2,1)

local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1,-155,1,-72)
content.Position = UDim2.new(0,150,0,65)
content.BackgroundTransparency = 1
content.ZIndex = 5
content.Parent = main

local function createPage(name)
	local frame = Instance.new("ScrollingFrame")
	frame.Name = name.."Page"
	frame.Size = UDim2.new(1,0,1,0)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Visible = false
	frame.ScrollBarThickness = 4
	frame.ScrollBarImageColor3 = Color3.fromRGB(150,150,150)
	frame.CanvasSize = UDim2.new(0,0,0,0)
	frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	frame.ZIndex = 5
	frame.Parent = content

	pageFrames[name] = frame
	return frame
end

local function createSection(parent,text,y)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.new(0,0,0,y)
	label.Size = UDim2.new(1,0,0,22)
	label.Text = text
	label.Font = Enum.Font.GothamBold
	label.TextSize = 10
	label.TextColor3 = Color3.fromRGB(170,170,170)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 6
	label.Parent = parent

	glow(label,Color3.fromRGB(255,255,255),2)
	return label
end

local toggleRefreshers = {}

local function createToggle(parent,text,y,key)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1,0,0,42)
	holder.Position = UDim2.new(0,0,0,y)
	holder.BackgroundColor3 = Color3.fromRGB(17,17,17)
	holder.BorderSizePixel = 0
	holder.ZIndex = 6
	holder.Parent = parent

	corner(holder,7)
	outline(holder,Color3.fromRGB(45,45,45),0.25,1)

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.new(0,12,0,0)
	label.Size = UDim2.new(1,-70,1,0)
	label.Text = text
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 11
	label.TextColor3 = Color3.fromRGB(225,225,225)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 7
	label.Parent = holder

	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.new(0,36,0,19)
	toggle.Position = UDim2.new(1,-48,0.5,-9)
	toggle.BackgroundColor3 = Color3.fromRGB(35,35,35)
	toggle.BorderSizePixel = 0
	toggle.Text = ""
	toggle.ZIndex = 7
	toggle.Parent = holder

	corner(toggle,10)

	local circle = Instance.new("Frame")
	circle.Size = UDim2.new(0,13,0,13)
	circle.Position = UDim2.new(0,3,0.5,-6.5)
	circle.BackgroundColor3 = Color3.fromRGB(160,160,160)
	circle.BorderSizePixel = 0
	circle.ZIndex = 8
	circle.Parent = toggle

	corner(circle,10)

	local function update()
		local enabled = states[key]

		TweenService:Create(
			toggle,
			TweenInfo.new(0.15),
			{ BackgroundColor3 = enabled and Color3.fromRGB(235,235,235) or Color3.fromRGB(35,35,35) }
		):Play()

		TweenService:Create(
			circle,
			TweenInfo.new(0.15),
			{
				Position = enabled and UDim2.new(1,-16,0.5,-6.5) or UDim2.new(0,3,0.5,-6.5),
				BackgroundColor3 = enabled and Color3.fromRGB(10,10,10) or Color3.fromRGB(160,160,160)
			}
		):Play()
	end

	toggle.MouseButton1Click:Connect(function()
		states[key] = not states[key]
		update()
	end)

	toggleRefreshers[key] = update
	update()

	return holder,toggle
end

local function createSlider(parent,text,y,defaultValue,minValue,maxValue,callback)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1,0,0,55)
	holder.Position = UDim2.new(0,0,0,y)
	holder.BackgroundColor3 = Color3.fromRGB(17,17,17)
	holder.BorderSizePixel = 0
	holder.ZIndex = 6
	holder.Parent = parent

	corner(holder,7)
	outline(holder,Color3.fromRGB(45,45,45),0.25,1)

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.new(0,12,0,5)
	label.Size = UDim2.new(1,-24,0,18)
	label.Text = text.."  "..defaultValue
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 11
	label.TextColor3 = Color3.fromRGB(225,225,225)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 7
	label.Parent = holder

	local input = Instance.new("TextBox")
	input.Size = UDim2.new(1,-24,0,22)
	input.Position = UDim2.new(0,12,0,28)
	input.BackgroundColor3 = Color3.fromRGB(28,28,28)
	input.BorderSizePixel = 0
	input.Text = tostring(defaultValue)
	input.TextColor3 = Color3.fromRGB(235,235,235)
	input.TextSize = 10
	input.Font = Enum.Font.Gotham
	input.ClearTextOnFocus = false
	input.ZIndex = 7
	input.Parent = holder

	corner(input,5)

	input.FocusLost:Connect(function()
		local value = tonumber(input.Text)

		if value then
			value = math.clamp(value,minValue,maxValue)
			input.Text = tostring(value)
			label.Text = text.."  "..value
			callback(value)
		else
			input.Text = tostring(defaultValue)
		end
	end)

	return holder, label, input
end

local home = createPage("Home")

createSection(home,"WELCOME",0)

local welcome = Instance.new("TextLabel")
welcome.BackgroundTransparency = 1
welcome.Position = UDim2.new(0,0,0,30)
welcome.Size = UDim2.new(1,0,0,45)
welcome.Text = "Welcome to 0nyxhub!"
welcome.Font = Enum.Font.GothamBold
welcome.TextSize = 22
welcome.TextColor3 = Color3.fromRGB(255,255,255)
welcome.TextXAlignment = Enum.TextXAlignment.Left
welcome.ZIndex = 6
welcome.Parent = home

glow(welcome,Color3.fromRGB(255,255,255),4)

local welcomeDescription = Instance.new("TextLabel")
welcomeDescription.BackgroundTransparency = 1
welcomeDescription.Position = UDim2.new(0,0,0,70)
welcomeDescription.Size = UDim2.new(1,-10,0,50)
welcomeDescription.Text = "Your personal control panel for a cleaner, smoother and more powerful experience."
welcomeDescription.Font = Enum.Font.Gotham
welcomeDescription.TextSize = 11
welcomeDescription.TextColor3 = Color3.fromRGB(145,145,145)
welcomeDescription.TextWrapped = true
welcomeDescription.TextXAlignment = Enum.TextXAlignment.Left
welcomeDescription.ZIndex = 6
welcomeDescription.Parent = home

local configStatusLabel = Instance.new("TextLabel")
configStatusLabel.BackgroundTransparency = 1
configStatusLabel.Position = UDim2.new(0,0,0,132)
configStatusLabel.Size = UDim2.new(1,0,0,25)
configStatusLabel.Text = "Loaded config: None"
configStatusLabel.Font = Enum.Font.GothamBold
configStatusLabel.TextSize = 12
configStatusLabel.TextColor3 = Color3.fromRGB(200,200,200)
configStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
configStatusLabel.ZIndex = 6
configStatusLabel.Parent = home

local playerPage = createPage("Player")

createSection(playerPage,"PLAYER",0)
createToggle(playerPage,"Godmode",30,"Godmode")
createToggle(playerPage,"Infinite Jump",78,"InfiniteJump")
createToggle(playerPage,"Anti Fling",126,"AntiFling")
createToggle(playerPage,"Anti AFK",174,"AntiAFK")
createToggle(playerPage,"Anti Kick",222,"AntiKick")
createToggle(playerPage,"Anti Ban",270,"AntiBan")

local movement = createPage("Movement")

createSection(movement,"MOVEMENT",0)
createToggle(movement,"Flight",30,"Flight")
createToggle(movement,"Noclip",78,"Noclip")
createToggle(movement,"High Jump",126,"HighJump")
createToggle(movement,"Freeze",174,"Freeze")

createSlider(movement,"WalkSpeed",222,16,0,200,function(value) walkSpeed = value end)
createSlider(movement,"Flight Speed",287,50,10,300,function(value) flightSpeed = value end)
createSlider(movement,"Jump Power",352,100,50,500,function(value) jumpPower = value end)

local visuals = createPage("Visuals")

createSection(visuals,"VISUALS",0)
createToggle(visuals,"Invisible",30,"Invisible")
createToggle(visuals,"Fullbright",78,"Fullbright")
createToggle(visuals,"No Damage Effect",126,"NoDamage")
createToggle(visuals,"Player ESP",174,"ESP")
createToggle(visuals,"ESP Box",222,"ESPBox")
createToggle(visuals,"ESP Names",270,"ESPNames")

createSection(visuals,"ESP TARGETS",320)

local espTargetList = Instance.new("ScrollingFrame")
espTargetList.Name = "ESPTargets"
espTargetList.Size = UDim2.new(1,0,0,150)
espTargetList.Position = UDim2.new(0,0,0,346)
espTargetList.BackgroundColor3 = Color3.fromRGB(12,12,12)
espTargetList.BackgroundTransparency = 0.15
espTargetList.BorderSizePixel = 0
espTargetList.ScrollBarThickness = 4
espTargetList.ScrollBarImageColor3 = Color3.fromRGB(150,150,150)
espTargetList.CanvasSize = UDim2.new(0,0,0,0)
espTargetList.AutomaticCanvasSize = Enum.AutomaticSize.Y
espTargetList.ZIndex = 7
espTargetList.Parent = visuals

corner(espTargetList,8)
outline(espTargetList,Color3.fromRGB(45,45,45),0.25,1)
pad(espTargetList,6)
listLayout(espTargetList,5)

do
	local combatPage = createPage("Combat")

	createSection(combatPage,"AIMBOT",0)
	createToggle(combatPage,"Aimbot",30,"Aimbot")
	createSlider(combatPage,"Aimbot FOV",78,150,20,600,function(value) aim.fov = value end)
	createSlider(combatPage,"Aimbot Smoothness %",143,25,5,100,function(value) aim.smooth = value/100 end)
end

local teleport = createPage("Teleport")

createSection(teleport,"TELEPORT",0)
createToggle(teleport,"Teleport Tool",30,"TeleportTool")
createToggle(teleport,"Click Teleport",78,"ClickTeleport")

local animationsPage = createPage("Animations")

createSection(animationsPage,"ANIMATION BROWSER",0)

local animTabs = Instance.new("Frame")
animTabs.Size = UDim2.new(1,0,0,26)
animTabs.Position = UDim2.new(0,0,0,26)
animTabs.BackgroundTransparency = 1
animTabs.ZIndex = 7
animTabs.Parent = animationsPage

local function styleTab(button,active)
	button.BackgroundColor3 = active and Color3.fromRGB(30,30,30) or Color3.fromRGB(16,16,16)
	button.TextColor3 = active and Color3.fromRGB(255,255,255) or Color3.fromRGB(150,150,150)
end

local packsTab = Instance.new("TextButton")
packsTab.Size = UDim2.new(0.5,-4,1,0)
packsTab.BackgroundColor3 = Color3.fromRGB(30,30,30)
packsTab.BorderSizePixel = 0
packsTab.Text = "Packs"
packsTab.Font = Enum.Font.GothamMedium
packsTab.TextSize = 11
packsTab.TextColor3 = Color3.fromRGB(255,255,255)
packsTab.ZIndex = 8
packsTab.Parent = animTabs

corner(packsTab,7)
outline(packsTab,Color3.fromRGB(48,48,48),0.2,1)

local mixerTab = Instance.new("TextButton")
mixerTab.Size = UDim2.new(0.5,-4,1,0)
mixerTab.Position = UDim2.new(0.5,4,0,0)
mixerTab.BackgroundColor3 = Color3.fromRGB(16,16,16)
mixerTab.BorderSizePixel = 0
mixerTab.Text = "Mixer"
mixerTab.Font = Enum.Font.GothamMedium
mixerTab.TextSize = 11
mixerTab.TextColor3 = Color3.fromRGB(150,150,150)
mixerTab.ZIndex = 8
mixerTab.Parent = animTabs

corner(mixerTab,7)
outline(mixerTab,Color3.fromRGB(48,48,48),0.2,1)

local selectedLabel = Instance.new("TextLabel")
selectedLabel.BackgroundTransparency = 1
selectedLabel.Position = UDim2.new(0,0,0,56)
selectedLabel.Size = UDim2.new(1,0,0,20)
selectedLabel.Text = "Selected: Default"
selectedLabel.Font = Enum.Font.GothamMedium
selectedLabel.TextSize = 11
selectedLabel.TextColor3 = Color3.fromRGB(200,200,200)
selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
selectedLabel.ZIndex = 7
selectedLabel.Parent = animationsPage

local animationStatus = Instance.new("TextLabel")
animationStatus.BackgroundTransparency = 1
animationStatus.Position = UDim2.new(0,0,0,76)
animationStatus.Size = UDim2.new(1,0,0,18)
animationStatus.Text = "Animation browser"
animationStatus.Font = Enum.Font.Gotham
animationStatus.TextSize = 9
animationStatus.TextColor3 = Color3.fromRGB(125,125,125)
animationStatus.TextXAlignment = Enum.TextXAlignment.Left
animationStatus.ZIndex = 7
animationStatus.Parent = animationsPage

local animationList = Instance.new("ScrollingFrame")
animationList.Name = "AnimationList"
animationList.Size = UDim2.new(1,0,0,230)
animationList.Position = UDim2.new(0,0,0,96)
animationList.BackgroundColor3 = Color3.fromRGB(12,12,12)
animationList.BackgroundTransparency = 0.15
animationList.BorderSizePixel = 0
animationList.ScrollBarThickness = 4
animationList.ScrollBarImageColor3 = Color3.fromRGB(150,150,150)
animationList.CanvasSize = UDim2.new(0,0,0,0)
animationList.AutomaticCanvasSize = Enum.AutomaticSize.Y
animationList.ZIndex = 7
animationList.Parent = animationsPage

corner(animationList,8)
outline(animationList,Color3.fromRGB(45,45,45),0.25,1)
pad(animationList,8)
listLayout(animationList,6)

local mixerFrame = Instance.new("ScrollingFrame")
mixerFrame.Name = "MixerFrame"
mixerFrame.Size = UDim2.new(1,0,0,230)
mixerFrame.Position = UDim2.new(0,0,0,96)
mixerFrame.BackgroundColor3 = Color3.fromRGB(12,12,12)
mixerFrame.BackgroundTransparency = 0.15
mixerFrame.BorderSizePixel = 0
mixerFrame.ScrollBarThickness = 4
mixerFrame.ScrollBarImageColor3 = Color3.fromRGB(150,150,150)
mixerFrame.CanvasSize = UDim2.new(0,0,0,0)
mixerFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
mixerFrame.Visible = false
mixerFrame.ZIndex = 7
mixerFrame.Parent = animationsPage

corner(mixerFrame,8)
outline(mixerFrame,Color3.fromRGB(45,45,45),0.25,1)
pad(mixerFrame,8)
listLayout(mixerFrame,6)

local function showAnimTab(name)
	local packs = name == "Packs"
	animationList.Visible = packs
	mixerFrame.Visible = not packs
	styleTab(packsTab,packs)
	styleTab(mixerTab,not packs)
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
	["Bubbly"] = { Idle1="91000483675970", Idle2="91002974411141", Walk="91002267168747", Run="91002449779547", Jump="91003305881939", Fall="91003132202883", Climb="91001648909116", Swim="91000923894432", SwimIdle="91001421353015" },
	["Levitation"] = { Idle1="616006778", Idle2="616008087", Walk="616013216", Run="616010382", Jump="616008936", Fall="616005863", Climb="616003968", Swim="616011500", SwimIdle="616012453" },
	["Adidas Community"] = { Idle1="122257458498464", Idle2="102357151005774", Walk="122150855457006", Run="82598234841035", Jump="75290611992385", Fall="98600215928904", Climb="88763136693023", Swim="106537993816942", SwimIdle="109346520324160" },
	["Man"] = { Idle1="2510197257", Idle2="2510196951", Walk="2510202577", Run="2510198475", Jump="2510197830", Fall="2510195892", Climb="2510192778", Swim="2510199791", SwimIdle="2510201162" },
	["Woman"] = { Idle1="507766388", Idle2="507766666", Walk="507777826", Run="507767714", Jump="507765000", Fall="507767968", Climb="507765644", Swim="507784897", SwimIdle="507785072" },
	["Confident"] = { Idle1="616136790", Idle2="616138447", Walk="616146177", Run="616140816", Jump="616139451", Fall="616134815", Climb="616133594", Swim="616143378", SwimIdle="616144772" },
	["Cheerful"] = { Idle1="616006778", Idle2="616008087", Walk="616013216", Run="616010382", Jump="616008936", Fall="616005863", Climb="616003968", Swim="616011500", SwimIdle="616012453" }
}

local mixSlots = {"Idle1","Idle2","Walk","Run","Jump","Fall","Climb","Swim","SwimIdle"}

local customMix = {}
for _,slot in ipairs(mixSlots) do
	customMix[slot] = "Default"
end

local sortedPackNames = {}
for name in pairs(animationPacks) do
	table.insert(sortedPackNames,name)
end

table.sort(sortedPackNames,function(a,b)
	if a == "Default" then return true end
	if b == "Default" then return false end
	return a < b
end)

local function getAnimationCharacter()
	local character = player.Character
	if not character then return nil,nil,nil end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return character,nil,nil end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	return character,humanoid,animator
end

local function stopCustomTracks()
	for name,track in pairs(animationTracks) do
		if track then
			pcall(function()
				track:Stop(0.12)
				track:Destroy()
			end)
		end
		animationTracks[name] = nil
	end
	currentAnimationName = nil
end

local function disconnectAnimationConnections()
	for _,connection in ipairs(animationConnections) do
		if connection then connection:Disconnect() end
	end
	table.clear(animationConnections)
end

local function disableDefaultAnimate(character)
	local animate = character and character:FindFirstChild("Animate")
	if animate and animate:IsA("LocalScript") then animate.Disabled = true end
end

local function enableDefaultAnimate(character)
	local animate = character and character:FindFirstChild("Animate")
	if animate and animate:IsA("LocalScript") then animate.Disabled = false end
end

local function makeAnimation(animator,id,name)
	local animation = Instance.new("Animation")
	animation.Name = "0nyx_"..name
	animation.AnimationId = "rbxassetid://"..tostring(id)

	local success,track = pcall(function()
		return animator:LoadAnimation(animation)
	end)

	animation:Destroy()

	if not success or not track then return nil end

	track.Name = "0nyx_"..name

	-- FIX: Fall / Climb / Swim now loop like Roblox's own animations.
	if name == "Idle1" or name == "Idle2" or name == "Walk" or name == "Run"
		or name == "Swim" or name == "SwimIdle" or name == "Climb" or name == "Fall"
		or name == "Sit" then
		track.Looped = true
	else
		track.Looped = false
	end

	track.Priority = Enum.AnimationPriority.Movement
	return track
end

local function loadAnimationTracks(pack)
	stopCustomTracks()

	local character,humanoid,animator = getAnimationCharacter()
	if not character or not humanoid or not animator then return false end

	if humanoid.RigType ~= Enum.HumanoidRigType.R15 then
		animationStatus.Text = "R15 is required"
		return false
	end

	disableDefaultAnimate(character)

	for name,id in pairs(pack) do
		local track = makeAnimation(animator,id,name)
		if track then animationTracks[name] = track end
	end

	local sitId = (humanoid.RigType == Enum.HumanoidRigType.R6) and "178130996" or "2506281703"
	local sitTrack = makeAnimation(animator,sitId,"Sit")
	if sitTrack then
		sitTrack.Looped = true
		animationTracks["Sit"] = sitTrack
	end

	return true
end

local function playCustomAnimation(name)
	if not customAnimationEnabled then return end
	if currentAnimationName == name then return end

	local track = animationTracks[name]
	if not track then return end

	for otherName,otherTrack in pairs(animationTracks) do
		if otherTrack and otherName ~= name then
			pcall(function() otherTrack:Stop(0.12) end)
		end
	end

	currentAnimationName = name

	local character,humanoid = getAnimationCharacter()
	if not humanoid then return end

	local fadeTime = 0.12
	local speed = 1

	if name == "Walk" then
		speed = math.max(0.7,humanoid.WalkSpeed / 8)
	elseif name == "Run" then
		speed = math.max(0.7,humanoid.WalkSpeed / 16)
	end

	track:Play(fadeTime,1,speed)
end

local function updateCustomAnimation()
	if not customAnimationEnabled then return end

	local character,humanoid = getAnimationCharacter()
	if not character or not humanoid then return end
	if humanoid.RigType ~= Enum.HumanoidRigType.R15 then return end

	local state = humanoid:GetState()
	local moving = humanoid.MoveDirection.Magnitude > 0.05

	if state == Enum.HumanoidStateType.Jumping then playCustomAnimation("Jump") return end
	if state == Enum.HumanoidStateType.Freefall then playCustomAnimation("Fall") return end
	if state == Enum.HumanoidStateType.FallingDown then playCustomAnimation("Fall") return end
	if state == Enum.HumanoidStateType.Climbing then playCustomAnimation("Climb") return end

	if state == Enum.HumanoidStateType.Swimming then
		if moving then playCustomAnimation("Swim") else playCustomAnimation("SwimIdle") end
		return
	end

	if state == Enum.HumanoidStateType.Seated then
		playCustomAnimation("Sit")
		return
	end

	if moving then
		if humanoid.WalkSpeed > 16 then
			playCustomAnimation("Run")
		else
			playCustomAnimation("Walk")
		end
		return
	end

	playCustomAnimation("Idle1")
end

local function startCustomAnimationController()
	animationGeneration += 1
	local generation = animationGeneration

	disconnectAnimationConnections()

	if animationLoopConnection then
		animationLoopConnection:Disconnect()
		animationLoopConnection = nil
	end

	local character,humanoid = getAnimationCharacter()
	if not character or not humanoid then return end

	if humanoid.RigType ~= Enum.HumanoidRigType.R15 then
		animationStatus.Text = "R15 is required"
		return
	end

	animationLoopConnection = RunService.Heartbeat:Connect(function()
		if generation ~= animationGeneration then return end
		if closed then return end
		if not customAnimationEnabled then return end
		updateCustomAnimation()
	end)

	table.insert(animationConnections,humanoid.StateChanged:Connect(function()
		if not customAnimationEnabled then return end
		task.defer(function()
			if generation == animationGeneration then updateCustomAnimation() end
		end)
	end))

	table.insert(animationConnections,humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
		if not customAnimationEnabled then return end
		updateCustomAnimation()
	end))

	table.insert(animationConnections,humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		if not customAnimationEnabled then return end
		updateCustomAnimation()
	end))

	updateCustomAnimation()
end

local function stopCustomAnimationController()
	animationGeneration += 1
	if animationLoopConnection then
		animationLoopConnection:Disconnect()
		animationLoopConnection = nil
	end
	disconnectAnimationConnections()
	stopCustomTracks()
end

function applyAnimationPack(packName)
	local pack = animationPacks[packName]
	if not pack then return end

	local character,humanoid = getAnimationCharacter()
	if not character or not humanoid then
		animationStatus.Text = "Character not ready"
		return
	end

	if humanoid.RigType ~= Enum.HumanoidRigType.R15 then
		animationStatus.Text = "R15 is required"
		return
	end

	currentAnimationPack = packName

	if packName == "Default" then
		customAnimationEnabled = false
		stopCustomAnimationController()
		enableDefaultAnimate(character)
		selectedLabel.Text = "Selected: Default"
		animationStatus.Text = "Default Roblox animations restored"
		return
	end

	customAnimationEnabled = false
	stopCustomAnimationController()

	customAnimationEnabled = loadAnimationTracks(pack)
	if not customAnimationEnabled then
		animationStatus.Text = "Could not load animation pack"
		return
	end

	selectedLabel.Text = "Selected: "..packName
	animationStatus.Text = "Custom controller active"

	startCustomAnimationController()
end

local function buildMixPack()
	local pack = {}
	for _,slot in ipairs(mixSlots) do
		local source = animationPacks[customMix[slot]]
		if source and source[slot] then pack[slot] = source[slot] end
	end
	return pack
end

local function applyCustomMix()
	local character,humanoid = getAnimationCharacter()
	if not character or not humanoid then
		animationStatus.Text = "Character not ready"
		return
	end

	if humanoid.RigType ~= Enum.HumanoidRigType.R15 then
		animationStatus.Text = "R15 is required"
		return
	end

	local pack = buildMixPack()

	customAnimationEnabled = false
	stopCustomAnimationController()

	customAnimationEnabled = loadAnimationTracks(pack)
	if not customAnimationEnabled then
		animationStatus.Text = "Could not load custom mix"
		return
	end

	currentAnimationPack = "Custom Mix"
	selectedLabel.Text = "Selected: Custom Mix"
	animationStatus.Text = "Custom animation mix active"

	startCustomAnimationController()
end

local function rebuildAnimationButtons()
	for _,child in ipairs(animationList:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end

	local names = {}
	for name in pairs(animationPacks) do
		table.insert(names,name)
	end

	table.sort(names,function(a,b)
		if a == "Default" then return true end
		if b == "Default" then return false end
		if a == "Adidas Community" then return false end
		if b == "Adidas Community" then return true end
		return a < b
	end)

	for index,name in ipairs(names) do
		local button = Instance.new("TextButton")
		button.Name = name
		button.LayoutOrder = index
		button.Size = UDim2.new(1,0,0,40)
		button.BackgroundColor3 = Color3.fromRGB(18,18,18)
		button.BorderSizePixel = 0
		button.Text = name
		button.Font = Enum.Font.GothamMedium
		button.TextSize = 11
		button.TextColor3 = Color3.fromRGB(225,225,225)
		button.ZIndex = 8
		button.Parent = animationList

		corner(button,7)
		outline(button,Color3.fromRGB(48,48,48),0.2,1)

		button.MouseButton1Click:Connect(function()
			applyAnimationPack(name)
		end)
	end
end

rebuildAnimationButtons()

local mixValueLabels = {}

local function cycleMix(slot,direction)
	local index = table.find(sortedPackNames,customMix[slot]) or 1
	index = ((index - 1 + direction) % #sortedPackNames) + 1
	customMix[slot] = sortedPackNames[index]

	if mixValueLabels[slot] then
		mixValueLabels[slot].Text = customMix[slot]
	end

	applyCustomMix()
end

local function buildMixer()
	for _,child in ipairs(mixerFrame:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	table.clear(mixValueLabels)

	for index,slot in ipairs(mixSlots) do
		local row = Instance.new("Frame")
		row.Name = slot
		row.LayoutOrder = index
		row.Size = UDim2.new(1,0,0,34)
		row.BackgroundColor3 = Color3.fromRGB(18,18,18)
		row.BorderSizePixel = 0
		row.ZIndex = 8
		row.Parent = mixerFrame

		corner(row,7)
		outline(row,Color3.fromRGB(48,48,48),0.2,1)

		local label = Instance.new("TextLabel")
		label.BackgroundTransparency = 1
		label.Position = UDim2.new(0,12,0,0)
		label.Size = UDim2.new(0,70,1,0)
		label.Text = slot
		label.Font = Enum.Font.GothamMedium
		label.TextSize = 11
		label.TextColor3 = Color3.fromRGB(225,225,225)
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.ZIndex = 9
		label.Parent = row

		local left = Instance.new("TextButton")
		left.Size = UDim2.new(0,26,0,22)
		left.Position = UDim2.new(1,-152,0.5,-11)
		left.BackgroundColor3 = Color3.fromRGB(30,30,30)
		left.BorderSizePixel = 0
		left.Text = "<"
		left.Font = Enum.Font.GothamBold
		left.TextSize = 13
		left.TextColor3 = Color3.fromRGB(230,230,230)
		left.ZIndex = 9
		left.Parent = row

		corner(left,6)

		local value = Instance.new("TextLabel")
		value.BackgroundTransparency = 1
		value.Position = UDim2.new(1,-124,0,0)
		value.Size = UDim2.new(0,90,1,0)
		value.Text = customMix[slot]
		value.Font = Enum.Font.GothamMedium
		value.TextSize = 10
		value.TextColor3 = Color3.fromRGB(255,255,255)
		value.TextTruncate = Enum.TextTruncate.AtEnd
		value.ZIndex = 9
		value.Parent = row

		mixValueLabels[slot] = value

		local right = Instance.new("TextButton")
		right.Size = UDim2.new(0,26,0,22)
		right.Position = UDim2.new(1,-30,0.5,-11)
		right.BackgroundColor3 = Color3.fromRGB(30,30,30)
		right.BorderSizePixel = 0
		right.Text = ">"
		right.Font = Enum.Font.GothamBold
		right.TextSize = 13
		right.TextColor3 = Color3.fromRGB(230,230,230)
		right.ZIndex = 9
		right.Parent = row

		corner(right,6)

		left.MouseButton1Click:Connect(function() cycleMix(slot,-1) end)
		right.MouseButton1Click:Connect(function() cycleMix(slot,1) end)
	end

	local reset = Instance.new("TextButton")
	reset.Name = "ResetMix"
	reset.LayoutOrder = #mixSlots + 1
	reset.Size = UDim2.new(1,0,0,32)
	reset.BackgroundColor3 = Color3.fromRGB(230,230,230)
	reset.BorderSizePixel = 0
	reset.Text = "Reset Mix"
	reset.Font = Enum.Font.GothamBold
	reset.TextSize = 11
	reset.TextColor3 = Color3.fromRGB(10,10,10)
	reset.ZIndex = 8
	reset.Parent = mixerFrame

	corner(reset,7)

	reset.MouseButton1Click:Connect(function()
		for _,slot in ipairs(mixSlots) do
			customMix[slot] = "Default"
			if mixValueLabels[slot] then mixValueLabels[slot].Text = "Default" end
		end
		applyCustomMix()
	end)
end

buildMixer()
showAnimTab("Packs")

local settings = createPage("Settings")

createSection(settings,"CONFIGURATIONS",0)

local configStatus = Instance.new("TextLabel")
configStatus.BackgroundTransparency = 1
configStatus.Position = UDim2.new(0,0,0,22)
configStatus.Size = UDim2.new(1,0,0,18)
configStatus.Text = "Save, load and manage your setups"
configStatus.Font = Enum.Font.Gotham
configStatus.TextSize = 10
configStatus.TextColor3 = Color3.fromRGB(150,150,150)
configStatus.TextXAlignment = Enum.TextXAlignment.Left
configStatus.ZIndex = 7
configStatus.Parent = settings

local configNameBox = Instance.new("TextBox")
configNameBox.Size = UDim2.new(1,-104,0,30)
configNameBox.Position = UDim2.new(0,0,0,44)
configNameBox.BackgroundColor3 = Color3.fromRGB(22,22,22)
configNameBox.BorderSizePixel = 0
configNameBox.Text = ""
configNameBox.PlaceholderText = "Config name..."
configNameBox.TextColor3 = Color3.fromRGB(235,235,235)
configNameBox.TextSize = 11
configNameBox.Font = Enum.Font.Gotham
configNameBox.ClearTextOnFocus = false
configNameBox.ZIndex = 7
configNameBox.Parent = settings

corner(configNameBox,6)
outline(configNameBox,Color3.fromRGB(45,45,45),0.25,1)

local saveConfigBtn = Instance.new("TextButton")
saveConfigBtn.Size = UDim2.new(0,94,0,30)
saveConfigBtn.Position = UDim2.new(1,-94,0,44)
saveConfigBtn.BackgroundColor3 = Color3.fromRGB(235,235,235)
saveConfigBtn.BorderSizePixel = 0
saveConfigBtn.Text = "Save"
saveConfigBtn.Font = Enum.Font.GothamBold
saveConfigBtn.TextSize = 11
saveConfigBtn.TextColor3 = Color3.fromRGB(10,10,10)
saveConfigBtn.ZIndex = 7
saveConfigBtn.Parent = settings

corner(saveConfigBtn,6)

local configList = Instance.new("ScrollingFrame")
configList.Name = "ConfigList"
configList.Size = UDim2.new(1,0,0,180)
configList.Position = UDim2.new(0,0,0,84)
configList.BackgroundColor3 = Color3.fromRGB(12,12,12)
configList.BackgroundTransparency = 0.15
configList.BorderSizePixel = 0
configList.ScrollBarThickness = 4
configList.ScrollBarImageColor3 = Color3.fromRGB(150,150,150)
configList.CanvasSize = UDim2.new(0,0,0,0)
configList.AutomaticCanvasSize = Enum.AutomaticSize.Y
configList.ZIndex = 7
configList.Parent = settings

corner(configList,8)
outline(configList,Color3.fromRGB(45,45,45),0.25,1)
pad(configList,8)
listLayout(configList,6)

local savedConfigs = {}

local CONFIG_FILE = "0nyxhub_configs.json"

local function deepCopy(t)
	local c = {}
	for k,v in pairs(t) do
		if type(v) == "table" then c[k] = deepCopy(v) else c[k] = v end
	end
	return c
end

local function persistConfigs()
	if type(writefile) == "function" then
		pcall(function()
			writefile(CONFIG_FILE,HttpService:JSONEncode(savedConfigs))
		end)
	end
end

local function loadPersistedConfigs()
	if type(readfile) == "function" and type(isfile) == "function" then
		pcall(function()
			if isfile(CONFIG_FILE) then
				savedConfigs = HttpService:JSONDecode(readfile(CONFIG_FILE))
			end
		end)
	end
end

local function captureConfig()
	return {
		states = deepCopy(states),
		walkSpeed = walkSpeed,
		flightSpeed = flightSpeed,
		jumpPower = jumpPower,
		animationPack = currentAnimationPack,
		customMix = deepCopy(customMix)
	}
end

local function applyConfig(cfg)
	if not cfg then return end

	if cfg.states then
		for k,v in pairs(cfg.states) do
			if states[k] ~= nil then states[k] = v end
		end
	end

	if cfg.walkSpeed then walkSpeed = cfg.walkSpeed end
	if cfg.flightSpeed then flightSpeed = cfg.flightSpeed end
	if cfg.jumpPower then jumpPower = cfg.jumpPower end

	if cfg.customMix then
		for slot,val in pairs(cfg.customMix) do
			customMix[slot] = val
		end
	end

	for _,refresh in pairs(toggleRefreshers) do
		refresh()
	end

	if cfg.animationPack and cfg.animationPack ~= "Default" then
		if cfg.animationPack == "Custom Mix" then
			applyCustomMix()
		else
			applyAnimationPack(cfg.animationPack)
		end
	end
end

local rebuildConfigList

local function deleteConfig(name)
	savedConfigs[name] = nil
	persistConfigs()
	rebuildConfigList()
end

rebuildConfigList = function()
	for _,child in ipairs(configList:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	local names = {}
	for name in pairs(savedConfigs) do
		table.insert(names,name)
	end
	table.sort(names)

	if #names == 0 then
		local empty = Instance.new("TextLabel")
		empty.Size = UDim2.new(1,0,0,30)
		empty.BackgroundTransparency = 1
		empty.Text = "No saved configs yet"
		empty.Font = Enum.Font.Gotham
		empty.TextSize = 10
		empty.TextColor3 = Color3.fromRGB(120,120,120)
		empty.ZIndex = 8
		empty.Parent = configList
		return
	end

	for index,name in ipairs(names) do
		local row = Instance.new("Frame")
		row.Name = name
		row.LayoutOrder = index
		row.Size = UDim2.new(1,0,0,38)
		row.BackgroundColor3 = Color3.fromRGB(18,18,18)
		row.BorderSizePixel = 0
		row.ZIndex = 8
		row.Parent = configList

		corner(row,7)
		outline(row,Color3.fromRGB(48,48,48),0.2,1)

		local label = Instance.new("TextLabel")
		label.BackgroundTransparency = 1
		label.Position = UDim2.new(0,12,0,0)
		label.Size = UDim2.new(1,-140,1,0)
		label.Text = name
		label.Font = Enum.Font.GothamMedium
		label.TextSize = 11
		label.TextColor3 = Color3.fromRGB(225,225,225)
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextTruncate = Enum.TextTruncate.AtEnd
		label.ZIndex = 9
		label.Parent = row

		local loadBtn = Instance.new("TextButton")
		loadBtn.Size = UDim2.new(0,58,0,24)
		loadBtn.Position = UDim2.new(1,-128,0.5,-12)
		loadBtn.BackgroundColor3 = Color3.fromRGB(235,235,235)
		loadBtn.BorderSizePixel = 0
		loadBtn.Text = "Load"
		loadBtn.Font = Enum.Font.GothamBold
		loadBtn.TextSize = 10
		loadBtn.TextColor3 = Color3.fromRGB(10,10,10)
		loadBtn.ZIndex = 9
		loadBtn.Parent = row

		corner(loadBtn,6)

		local delBtn = Instance.new("TextButton")
		delBtn.Size = UDim2.new(0,58,0,24)
		delBtn.Position = UDim2.new(1,-64,0.5,-12)
		delBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
		delBtn.BorderSizePixel = 0
		delBtn.Text = "Delete"
		delBtn.Font = Enum.Font.GothamMedium
		delBtn.TextSize = 10
		delBtn.TextColor3 = Color3.fromRGB(230,230,230)
		delBtn.ZIndex = 9
		delBtn.Parent = row

		corner(delBtn,6)

		loadBtn.MouseButton1Click:Connect(function()
			applyConfig(savedConfigs[name])
			configStatus.Text = "Loaded: "..name
			configStatusLabel.Text = "Loaded config: "..name
		end)

		delBtn.MouseButton1Click:Connect(function()
			deleteConfig(name)
		end)
	end
end

saveConfigBtn.MouseButton1Click:Connect(function()
	local name = configNameBox.Text
	if name == "" then name = "Config "..tostring(os.time()) end

	savedConfigs[name] = captureConfig()
	persistConfigs()
	rebuildConfigList()
	configStatus.Text = "Saved: "..name
	configNameBox.Text = ""
end)

loadPersistedConfigs()
rebuildConfigList()

createSection(settings,"UTILITIES",276)

local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(0.5,-5,0,32)
resetBtn.Position = UDim2.new(0,0,0,302)
resetBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
resetBtn.BorderSizePixel = 0
resetBtn.Text = "Reset Character"
resetBtn.Font = Enum.Font.GothamMedium
resetBtn.TextSize = 11
resetBtn.TextColor3 = Color3.fromRGB(230,230,230)
resetBtn.ZIndex = 7
resetBtn.Parent = settings

corner(resetBtn,6)
outline(resetBtn,Color3.fromRGB(60,60,60),0.3,1)

local rejoinBtn = Instance.new("TextButton")
rejoinBtn.Size = UDim2.new(0.5,-5,0,32)
rejoinBtn.Position = UDim2.new(0.5,5,0,302)
rejoinBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
rejoinBtn.BorderSizePixel = 0
rejoinBtn.Text = "Rejoin Server"
rejoinBtn.Font = Enum.Font.GothamMedium
rejoinBtn.TextSize = 11
rejoinBtn.TextColor3 = Color3.fromRGB(230,230,230)
rejoinBtn.ZIndex = 7
rejoinBtn.Parent = settings

corner(rejoinBtn,6)
outline(rejoinBtn,Color3.fromRGB(60,60,60),0.3,1)

resetBtn.MouseButton1Click:Connect(function()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then humanoid.Health = 0 end
end)

rejoinBtn.MouseButton1Click:Connect(function()
	pcall(function()
		TeleportService:Teleport(game.PlaceId,player)
	end)
end)

local function setAntiAFK(enabled)
	if conn.antiAFK then
		conn.antiAFK:Disconnect()
		conn.antiAFK = nil
	end

	if enabled then
		conn.antiAFK = player.Idled:Connect(function()
			VirtualUser:CaptureController()
			VirtualUser:ClickButton1(Vector2.new(math.random(0,100),math.random(0,100)),workspace.CurrentCamera.CFrame)
		end)
	end
end

local function setAntiKick(enabled)
	if conn.antiKick then
		conn.antiKick:Disconnect()
		conn.antiKick = nil
	end

	if not enabled then return end

	conn.antiKick = player.CharacterRemoving:Connect(function(character)
		if not states.AntiKick then return end
		task.wait(0.05)
		if character and not character.Parent then
			character.Parent = workspace
		end
	end)
end

local function setAntiBan(enabled)
	if conn.antiBan then
		conn.antiBan:Disconnect()
		conn.antiBan = nil
	end

	if not enabled then return end

	conn.antiBan = RunService.Heartbeat:Connect(function()
		if closed or not states.AntiBan then return end

		local pg = player:FindFirstChild("PlayerGui")
		if pg and gui.Parent ~= pg then
			gui.Parent = pg
		end
	end)
end

local function setAimbot(enabled)
	if conn.aimbot then
		conn.aimbot:Disconnect()
		conn.aimbot = nil
	end

	if not enabled then return end

	conn.aimbot = RunService.RenderStepped:Connect(function()
		if closed or not states.Aimbot then return end

		local camera = workspace.CurrentCamera
		if not camera then return end

		local center = Vector2.new(camera.ViewportSize.X/2,camera.ViewportSize.Y/2)
		local best = nil
		local bestDist = aim.fov

		for _,other in ipairs(Players:GetPlayers()) do
			if other ~= player and other.Character then
				local head = other.Character:FindFirstChild("Head")
				local hum = other.Character:FindFirstChildOfClass("Humanoid")
				if head and hum and hum.Health > 0 then
					local pos,onScreen = camera:WorldToViewportPoint(head.Position)
					if onScreen and pos.Z > 0 then
						local d = (Vector2.new(pos.X,pos.Y) - center).Magnitude
						if d < bestDist then
							best = head
							bestDist = d
						end
					end
				end
			end
		end

		if best then
			local goal = CFrame.lookAt(camera.CFrame.Position,best.Position)
			camera.CFrame = camera.CFrame:Lerp(goal,math.clamp(aim.smooth,0.02,1))
		end
	end)
end

local GOD_BONUS = 10000

local function applyGodHealth(character)
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	if not saved.god[humanoid] then
		saved.god[humanoid] = humanoid.MaxHealth
	end

	humanoid.MaxHealth = saved.god[humanoid] + GOD_BONUS
	humanoid.Health = humanoid.MaxHealth
end

local function removeGodHealth(character)
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	if saved.god[humanoid] then
		humanoid.MaxHealth = saved.god[humanoid]
		humanoid.Health = math.min(humanoid.Health,humanoid.MaxHealth)
		saved.god[humanoid] = nil
	end
end

local function startGodLoop()
	if conn.god then
		conn.god:Disconnect()
		conn.god = nil
	end

	conn.god = RunService.Stepped:Connect(function()
		if closed or not states.Godmode then return end

		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not humanoid then return end

		if humanoid.MaxHealth < (saved.god[humanoid] or 0) + GOD_BONUS - 1 then
			humanoid.MaxHealth = (saved.god[humanoid] or humanoid.MaxHealth) + GOD_BONUS
		end

		if humanoid.Health < humanoid.MaxHealth then
			humanoid.Health = humanoid.MaxHealth
		end

		local state = humanoid:GetState()

		if state == Enum.HumanoidStateType.Dead then
			humanoid.Health = humanoid.MaxHealth
			humanoid:ChangeState(Enum.HumanoidStateType.Running)
		elseif state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown then
			humanoid:ChangeState(Enum.HumanoidStateType.Running)
		end
	end)
end

local function setGodmode(enabled)
	local character = player.Character

	if enabled then
		if character then applyGodHealth(character) end
		startGodLoop()
	else
		if conn.god then
			conn.god:Disconnect()
			conn.god = nil
		end
		if character then removeGodHealth(character) end
	end
end

local function voidRescue()
	if voidBusy then return end
	voidBusy = true

	voidFlash.BackgroundTransparency = 0
	TweenService:Create(
		voidFlash,
		TweenInfo.new(0.35,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
		{ BackgroundTransparency = 1 }
	):Play()

	task.wait(0.12)

	voidCover.Visible = true
	voidCover.BackgroundTransparency = 1

	TweenService:Create(voidCover,TweenInfo.new(0.4),{ BackgroundTransparency = 0 }):Play()
	task.wait(0.45)

	voidTitle.Visible = true
	voidSub.Visible = true

	TweenService:Create(voidTitle,TweenInfo.new(0.35),{ TextTransparency = 0 }):Play()
	TweenService:Create(voidSub,TweenInfo.new(0.35),{ TextTransparency = 0 }):Play()
	TweenService:Create(voidTitleStroke,TweenInfo.new(0.35),{ Transparency = 0.3 }):Play()
	TweenService:Create(voidSubStroke,TweenInfo.new(0.35),{ Transparency = 0.5 }):Play()

	task.wait(0.7)

	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")

	local target = lastSafePos
	if not target then
		local spawn = workspace:FindFirstChildOfClass("SpawnLocation")
		target = spawn and spawn.Position or Vector3.new(0,50,0)
	end

	if root then
		root.CFrame = CFrame.new(target + Vector3.new(0,4,0))
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
	end

	task.wait(0.45)

	TweenService:Create(voidCover,TweenInfo.new(0.5),{ BackgroundTransparency = 1 }):Play()
	TweenService:Create(voidTitle,TweenInfo.new(0.5),{ TextTransparency = 1 }):Play()
	TweenService:Create(voidSub,TweenInfo.new(0.5),{ TextTransparency = 1 }):Play()
	TweenService:Create(voidTitleStroke,TweenInfo.new(0.5),{ Transparency = 1 }):Play()
	TweenService:Create(voidSubStroke,TweenInfo.new(0.5),{ Transparency = 1 }):Play()

	task.wait(0.55)

	voidCover.Visible = false
	hideVoidText()

	task.delay(0.6,function()
		local character2 = player.Character
		local root2 = character2 and character2:FindFirstChild("HumanoidRootPart")
		if root2 and root2.Position.Y < VOID_Y then
			root2.CFrame = CFrame.new(target + Vector3.new(0,4,0))
			root2.AssemblyLinearVelocity = Vector3.zero
		end
	end)

	voidBusy = false
end

task.spawn(function()
	while not closed do
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if root and humanoid and root.Position.Y > VOID_Y + 20 then
			if humanoid.FloorMaterial ~= Enum.Material.Air then
				lastSafePos = root.Position
			end
		end

		task.wait(0.25)
	end
end)

local function rememberPartTransparency(object)
	if saved.transparency[object] == nil then
		saved.transparency[object] = {
			Transparency = object.Transparency,
			LocalTransparencyModifier = object:IsA("BasePart") and object.LocalTransparencyModifier or nil
		}
	end
end

local function applyInvisibleToCharacter(character)
	for _,object in ipairs(character:GetDescendants()) do
		if object:IsA("BasePart") or object:IsA("Decal") then
			rememberPartTransparency(object)

			object.Transparency = 1
			if object:IsA("BasePart") then
				object.LocalTransparencyModifier = 1
			end
		end
	end
end

local function setInvisible(enabled)
	local character = player.Character
	if not character then return end

	if conn.invisibility then
		conn.invisibility:Disconnect()
		conn.invisibility = nil
	end

	if enabled then
		table.clear(saved.transparency)
		applyInvisibleToCharacter(character)

		conn.invisibility = character.DescendantAdded:Connect(function(object)
			if not states.Invisible then return end

			if object:IsA("BasePart") or object:IsA("Decal") then
				task.defer(function()
					if object and object.Parent and states.Invisible then
						rememberPartTransparency(object)
						object.Transparency = 1
						if object:IsA("BasePart") then
							object.LocalTransparencyModifier = 1
						end
					end
				end)
			end
		end)
	else
		for object,data in pairs(saved.transparency) do
			if object and object.Parent then
				object.Transparency = data.Transparency
				if object:IsA("BasePart") and data.LocalTransparencyModifier ~= nil then
					object.LocalTransparencyModifier = data.LocalTransparencyModifier
				end
			end
		end
		table.clear(saved.transparency)
	end
end

local function isESPTarget(other)
	if next(espSelected) == nil then return true end
	return espSelected[other.Name] == true
end

local function createESPBox(character)
	local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
	if not root then return end

	local bb = Instance.new("BillboardGui")
	bb.Name = "0nyxESPBox"
	bb.Adornee = root
	bb.AlwaysOnTop = true
	bb.LightInfluence = 0
	bb.Size = UDim2.new(0,60,0,80)
	bb.Parent = character

	local box = Instance.new("Frame")
	box.Name = "Box"
	box.Size = UDim2.new(1,0,1,0)
	box.BackgroundTransparency = 1
	box.BorderSizePixel = 0
	box.Parent = bb

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255,255,255)
	stroke.Thickness = 1.5
	stroke.Transparency = 0.1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = box
end

local function createESPName(character,name)
	local head = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
	if not head then return end

	local bb = Instance.new("BillboardGui")
	bb.Name = "0nyxESPName"
	bb.Adornee = head
	bb.Size = UDim2.new(0,200,0,36)
	bb.StudsOffset = Vector3.new(0,2.6,0)
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
	lbl.ZIndex = 10
	lbl.Parent = bb
end

local function updateESP()
	local camera = workspace.CurrentCamera

	for _,other in ipairs(Players:GetPlayers()) do
		if other ~= player and other.Character then
			local target = states.ESP and isESPTarget(other)

			local box = other.Character:FindFirstChild("0nyxESPBox")
			if target and states.ESPBox then
				if not box then
					createESPBox(other.Character)
					box = other.Character:FindFirstChild("0nyxESPBox")
				end

				if box and camera then
					local root = other.Character:FindFirstChild("HumanoidRootPart")
					if root then
						local distance = (camera.CFrame.Position - root.Position).Magnitude
						local pixelsPerStud = (camera.ViewportSize.Y / 2)
							/ (math.max(distance,0.1) * math.tan(math.rad(camera.FieldOfView) / 2))

						box.Size = UDim2.new(
							0,math.clamp(3 * pixelsPerStud,6,1000),
							0,math.clamp(6 * pixelsPerStud,8,2000)
						)
					end
				end
			elseif box then
				box:Destroy()
			end

			local nameTag = other.Character:FindFirstChild("0nyxESPName")
			if target and states.ESPNames then
				if not nameTag then createESPName(other.Character,other.Name) end
			elseif nameTag then
				nameTag:Destroy()
			end
		end
	end
end

local fullbrightSaved = nil

local function setFullbright(enabled)
	if enabled then
		if not fullbrightSaved then
			fullbrightSaved = {
				Brightness = Lighting.Brightness,
				Ambient = Lighting.Ambient,
				OutdoorAmbient = Lighting.OutdoorAmbient,
				FogEnd = Lighting.FogEnd,
				GlobalShadows = Lighting.GlobalShadows,
				ClockTime = Lighting.ClockTime
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
			Lighting.Brightness = fullbrightSaved.Brightness
			Lighting.Ambient = fullbrightSaved.Ambient
			Lighting.OutdoorAmbient = fullbrightSaved.OutdoorAmbient
			Lighting.FogEnd = fullbrightSaved.FogEnd
			Lighting.GlobalShadows = fullbrightSaved.GlobalShadows
			Lighting.ClockTime = fullbrightSaved.ClockTime
			fullbrightSaved = nil
		end
	end
end

local function setHighJump(enabled)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	if enabled then
		if saved.jump[humanoid] == nil then
			saved.jump[humanoid] = {
				UseJumpPower = humanoid.UseJumpPower,
				JumpPower = humanoid.JumpPower
			}
		end

		humanoid.UseJumpPower = true
		humanoid.JumpPower = jumpPower
	else
		local original = saved.jump[humanoid]
		if original then
			humanoid.UseJumpPower = original.UseJumpPower
			humanoid.JumpPower = original.JumpPower
			saved.jump[humanoid] = nil
		end
	end
end

local function setFreeze(enabled)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root then root.Anchored = enabled end
end

local function isReddish(color)
	return color.R > 0.5 and color.R > color.G * 1.2 and color.R > color.B * 1.2
end

-- FIX: rewritten to catch far more games (name match OR full-screen red overlay).
local function scanDamageEffects()
	local camera = workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1920,1080)

	local function scanContainer(container)
		for _,d in ipairs(container:GetDescendants()) do
			if d:IsA("GuiObject") and d.Name ~= "DamageOverlay" and d.Visible then
				local n = string.lower(d.Name)
				local nameMatch = n:find("damage") or n:find("hurt") or n:find("vignette")
					or n:find("redflash") or n:find("blood") or n:find("hitmarker")
					or n:find("redoverlay") or n:find("redscreen") or n:find("pain")

				local fullScreen = d.AbsoluteSize.X >= viewport.X * 0.85
					and d.AbsoluteSize.Y >= viewport.Y * 0.85

				local redTint = false
				if d:IsA("Frame") or d:IsA("TextLabel") or d:IsA("TextButton") then
					redTint = isReddish(d.BackgroundColor3) and d.BackgroundTransparency < 0.95
				elseif d:IsA("ImageLabel") or d:IsA("ImageButton") then
					redTint = isReddish(d.ImageColor3)
				end

				if nameMatch or (fullScreen and redTint) then
					d.Visible = false
				end
			end
		end
	end

	local pg = player:FindFirstChild("PlayerGui")
	if pg then scanContainer(pg) end
	if camera then scanContainer(camera) end

	local function scanEffects(container)
		for _,d in ipairs(container:GetDescendants()) do
			if d:IsA("ColorCorrectionEffect") then
				local n = string.lower(d.Name)
				if n:find("damage") or n:find("hurt") or n:find("vignette") or n:find("red")
					or isReddish(d.TintColor) then
					d.Enabled = false
				end
			end
		end
	end

	scanEffects(Lighting)
	if camera then scanEffects(camera) end
end

local lastDamageScan = 0

local function setNoDamage(enabled)
	if conn.noDamage then
		conn.noDamage:Disconnect()
		conn.noDamage = nil
	end

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

local function applyNoclipParts()
	local character = player.Character
	if not character then return end

	for _,object in ipairs(character:GetDescendants()) do
		if object:IsA("BasePart") then
			if saved.noclip[object] == nil then
				saved.noclip[object] = object.CanCollide
			end
			object.CanCollide = false
		end
	end
end

local function setNoclip(enabled)
	if conn.noclip then
		conn.noclip:Disconnect()
		conn.noclip = nil
	end

	if enabled then
		table.clear(saved.noclip)
		applyNoclipParts()

		conn.noclip = RunService.Heartbeat:Connect(function()
			if closed or not states.Noclip then return end
			applyNoclipParts()
		end)
	else
		for object,canCollide in pairs(saved.noclip) do
			if object and object.Parent then
				object.CanCollide = canCollide
			end
		end
		table.clear(saved.noclip)
	end
end

local function setAntiFling(enabled)
	if conn.antiFling then
		conn.antiFling:Disconnect()
		conn.antiFling = nil
	end

	if not enabled then return end

	conn.antiFling = RunService.Heartbeat:Connect(function()
		if closed or not states.AntiFling then return end
		if states.Flight then return end

		local character = player.Character
		if not character then return end

		local root = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not root then return end

		local maxLinear = 60
		local maxAngular = 50

		local linear = root.AssemblyLinearVelocity
		local angular = root.AssemblyAngularVelocity

		if linear.Magnitude ~= linear.Magnitude then
			root.AssemblyLinearVelocity = Vector3.zero
			linear = Vector3.zero
		end
		if angular.Magnitude ~= angular.Magnitude then
			root.AssemblyAngularVelocity = Vector3.zero
			angular = Vector3.zero
		end

		if linear.Magnitude > maxLinear then
			root.AssemblyLinearVelocity = linear.Unit * maxLinear
		end
		if angular.Magnitude > maxAngular then
			root.AssemblyAngularVelocity = angular.Unit * maxAngular
		end

		if humanoid then
			local cf = root.CFrame
			if cf.UpVector.Y < 0.92 then
				local look = cf.LookVector
				local flat = Vector3.new(look.X,0,look.Z)
				if flat.Magnitude > 0.01 then
					root.CFrame = CFrame.lookAt(root.Position,root.Position + flat.Unit)
				end
			end
		end
	end)
end

local function getBlankTrack()
	local character,humanoid,animator = getAnimationCharacter()
	if not animator then return nil end

	local anim = Instance.new("Animation")
	anim.AnimationId = "rbxassetid://0"

	local ok,track = pcall(function()
		return animator:LoadAnimation(anim)
	end)

	anim:Destroy()

	if ok and track then
		track.Priority = Enum.AnimationPriority.Action
		track.Looped = true
		return track
	end

	return nil
end

local function setFlight(enabled)
	if conn.flight then
		conn.flight:Disconnect()
		conn.flight = nil
	end

	if conn.flightVelocity then
		conn.flightVelocity:Destroy()
		conn.flightVelocity = nil
	end

	if conn.flightGyro then
		conn.flightGyro:Destroy()
		conn.flightGyro = nil
	end

	if conn.blankTrack then
		pcall(function()
			conn.blankTrack:Stop(0.1)
			conn.blankTrack:Destroy()
		end)
		conn.blankTrack = nil
	end

	if not enabled then return end

	local character = player.Character
	if not character then return end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	conn.flightVelocity = Instance.new("BodyVelocity")
	conn.flightVelocity.MaxForce = Vector3.new(100000,100000,100000)
	conn.flightVelocity.Velocity = Vector3.zero
	conn.flightVelocity.Parent = root

	conn.flightGyro = Instance.new("BodyGyro")
	conn.flightGyro.MaxTorque = Vector3.new(1000000,1000000,1000000)
	conn.flightGyro.P = 1000
	conn.flightGyro.CFrame = root.CFrame
	conn.flightGyro.Parent = root

	conn.blankTrack = getBlankTrack()
	if conn.blankTrack then
		pcall(function() conn.blankTrack:Play(0.1) end)
	end

	conn.flight = RunService.RenderStepped:Connect(function()
		if not states.Flight or not root.Parent then return end

		local camera = workspace.CurrentCamera
		if not camera then return end

		local direction = Vector3.zero

		if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction += camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction -= camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction -= camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction += camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction += Vector3.new(0,1,0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction -= Vector3.new(0,1,0) end

		if direction.Magnitude > 0 then
			direction = direction.Unit
		end

		conn.flightVelocity.Velocity = direction * flightSpeed

		local look = camera.CFrame.LookVector
		if look.Magnitude > 0.001 then
			conn.flightGyro.CFrame = CFrame.lookAt(root.Position,root.Position + look)
		end
	end)
end

local function createTeleportTool()
	if conn.teleportTool then conn.teleportTool:Destroy() end

	conn.teleportTool = Instance.new("Tool")
	conn.teleportTool.Name = "0nyxTeleport"
	conn.teleportTool.RequiresHandle = false
	conn.teleportTool.CanBeDropped = false
	-- Red black-hole icon (matches the mini button, but red). Swap the number if you want a different one.
	conn.teleportTool.TextureId = "rbxassetid://12402621316"
	conn.teleportTool.ToolTip = "0nyx Teleport"
	conn.teleportTool.Parent = player:WaitForChild("Backpack")

	conn.teleportTool.Activated:Connect(function()
		if not states.TeleportTool then return end

		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root then
			local mouse = player:GetMouse()
			if mouse.Hit then
				root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0,3,0))
			end
		end
	end)
end

local function removeTeleportTool()
	if conn.teleportTool then
		conn.teleportTool:Destroy()
		conn.teleportTool = nil
	end

	local backpack = player:FindFirstChild("Backpack")
	if backpack then
		local tool = backpack:FindFirstChild("0nyxTeleport")
		if tool then tool:Destroy() end
	end

	local character = player.Character
	if character then
		local tool = character:FindFirstChild("0nyxTeleport")
		if tool then tool:Destroy() end
	end
end

UserInputService.JumpRequest:Connect(function()
	if not states.InfiniteJump then return end

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

UserInputService.InputBegan:Connect(function(input,processed)
	if processed then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if states.ClickTeleport then
			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			local mouse = player:GetMouse()

			if root and mouse.Hit then
				root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0,3,0))
			end
		end
	end
end)

local mainHeartbeat = RunService.Heartbeat:Connect(function()
	if closed then return end

	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		humanoid.WalkSpeed = walkSpeed

		if states.HighJump then
			humanoid.UseJumpPower = true
			humanoid.JumpPower = jumpPower
		end
	end

	if states.ESP then
		updateESP()
	end

	if states.Godmode and not voidBusy then
		local root = character:FindFirstChild("HumanoidRootPart")
		if root and root.Position.Y < VOID_Y then
			voidRescue()
		end
	end
end)

local previousStates = {}
for key,value in pairs(states) do
	previousStates[key] = value
end

local stateHeartbeat = RunService.Heartbeat:Connect(function()
	if closed then return end

	if states.Godmode ~= previousStates.Godmode then
		setGodmode(states.Godmode)
		previousStates.Godmode = states.Godmode
	end

	if states.Invisible ~= previousStates.Invisible then
		setInvisible(states.Invisible)
		previousStates.Invisible = states.Invisible
	end

	if states.Noclip ~= previousStates.Noclip then
		setNoclip(states.Noclip)
		previousStates.Noclip = states.Noclip
	end

	if states.Flight ~= previousStates.Flight then
		setFlight(states.Flight)
		previousStates.Flight = states.Flight
	end

	if states.AntiFling ~= previousStates.AntiFling then
		setAntiFling(states.AntiFling)
		previousStates.AntiFling = states.AntiFling
	end

	if states.AntiAFK ~= previousStates.AntiAFK then
		setAntiAFK(states.AntiAFK)
		previousStates.AntiAFK = states.AntiAFK
	end

	if states.AntiKick ~= previousStates.AntiKick then
		setAntiKick(states.AntiKick)
		previousStates.AntiKick = states.AntiKick
	end

	if states.AntiBan ~= previousStates.AntiBan then
		setAntiBan(states.AntiBan)
		previousStates.AntiBan = states.AntiBan
	end

	if states.Aimbot ~= previousStates.Aimbot then
		setAimbot(states.Aimbot)
		previousStates.Aimbot = states.Aimbot
	end

	if states.Fullbright ~= previousStates.Fullbright then
		setFullbright(states.Fullbright)
		previousStates.Fullbright = states.Fullbright
	end

	if states.HighJump ~= previousStates.HighJump then
		setHighJump(states.HighJump)
		previousStates.HighJump = states.HighJump
	end

	if states.Freeze ~= previousStates.Freeze then
		setFreeze(states.Freeze)
		previousStates.Freeze = states.Freeze
	end

	if states.NoDamage ~= previousStates.NoDamage then
		setNoDamage(states.NoDamage)
		previousStates.NoDamage = states.NoDamage
	end

	if states.ESP ~= previousStates.ESP
		or states.ESPBox ~= previousStates.ESPBox
		or states.ESPNames ~= previousStates.ESPNames then
		updateESP()
		previousStates.ESP = states.ESP
		previousStates.ESPBox = states.ESPBox
		previousStates.ESPNames = states.ESPNames
	end

	if states.TeleportTool ~= previousStates.TeleportTool then
		if states.TeleportTool then createTeleportTool() else removeTeleportTool() end
		previousStates.TeleportTool = states.TeleportTool
	end
end)

local function rebuildESPTargets()
	for _,child in ipairs(espTargetList:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end

	local all = Instance.new("TextButton")
	all.Name = "All"
	all.LayoutOrder = 1
	all.Size = UDim2.new(1,0,0,28)
	all.BackgroundColor3 = next(espSelected) == nil and Color3.fromRGB(60,60,60) or Color3.fromRGB(22,22,22)
	all.BorderSizePixel = 0
	all.Text = "All Players"
	all.Font = Enum.Font.GothamMedium
	all.TextSize = 11
	all.TextColor3 = Color3.fromRGB(235,235,235)
	all.ZIndex = 9
	all.Parent = espTargetList

	corner(all,6)

	all.MouseButton1Click:Connect(function()
		table.clear(espSelected)
		rebuildESPTargets()
		updateESP()
	end)

	local order = 1
	for _,other in ipairs(Players:GetPlayers()) do
		if other ~= player then
			order += 1

			local selected = espSelected[other.Name] == true

			local b = Instance.new("TextButton")
			b.Name = other.Name
			b.LayoutOrder = order
			b.Size = UDim2.new(1,0,0,28)
			b.BackgroundColor3 = selected and Color3.fromRGB(60,60,60) or Color3.fromRGB(22,22,22)
			b.BorderSizePixel = 0
			b.Text = (selected and "[x] " or "[ ] ")..other.Name
			b.Font = Enum.Font.GothamMedium
			b.TextSize = 11
			b.TextColor3 = Color3.fromRGB(235,235,235)
			b.TextXAlignment = Enum.TextXAlignment.Left
			b.ZIndex = 9
			b.Parent = espTargetList

			corner(b,6)

			local bp = Instance.new("UIPadding")
			bp.PaddingLeft = UDim.new(0,10)
			bp.Parent = b

			b.MouseButton1Click:Connect(function()
				if espSelected[other.Name] then
					espSelected[other.Name] = nil
				else
					espSelected[other.Name] = true
				end
				rebuildESPTargets()
				updateESP()
			end)
		end
	end
end

rebuildESPTargets()

Players.PlayerAdded:Connect(function()
	rebuildESPTargets()
end)

Players.PlayerRemoving:Connect(function()
	rebuildESPTargets()
	updateESP()
end)

local function bindHealthFlash(character)
	if conn.health then
		conn.health:Disconnect()
		conn.health = nil
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	local lastHealth = humanoid.Health

	conn.health = humanoid.HealthChanged:Connect(function(health)
		if states.Godmode and health < lastHealth - 0.01 then
			flashDamage()
		end
		lastHealth = health
	end)
end

local function setupCharacter(character)
	task.wait(0.75)
	if closed then return end

	if customAnimationEnabled then
		if currentAnimationPack == "Custom Mix" then
			applyCustomMix()
		elseif currentAnimationPack ~= "Default" then
			applyAnimationPack(currentAnimationPack)
		end
	end

	if states.Godmode then
		applyGodHealth(character)
		startGodLoop()
	end

	if states.Invisible then setInvisible(true) end
	if states.Noclip then setNoclip(true) end
	if states.Flight then setFlight(true) end
	if states.AntiFling then setAntiFling(true) end
	if states.Freeze then setFreeze(true) end
	if states.TeleportTool then createTeleportTool() end

	local root = character:FindFirstChild("HumanoidRootPart")
	if root then lastSafePos = root.Position end

	bindHealthFlash(character)
end

player.CharacterAdded:Connect(setupCharacter)

if player.Character then
	task.spawn(function()
		setupCharacter(player.Character)
	end)
end

local function showPage(name)
	for pageName,frame in pairs(pageFrames) do
		frame.Visible = pageName == name
	end

	for buttonName,button in pairs(pageButtons) do
		if buttonName == name then
			button.BackgroundTransparency = 0
			button.BackgroundColor3 = Color3.fromRGB(25,25,25)
			button.TextColor3 = Color3.fromRGB(255,255,255)
		else
			button.BackgroundTransparency = 1
			button.TextColor3 = Color3.fromRGB(155,155,155)
		end
	end
end

for name,button in pairs(pageButtons) do
	button.MouseButton1Click:Connect(function()
		showPage(name)
	end)
end

showPage("Home")

local miniButton = Instance.new("TextButton")
miniButton.Name = "BlackHoleIcon"
miniButton.Size = UDim2.new(0,58,0,58)
-- Sits directly underneath the Roblox Esc (menu) button, top-left.
miniButton.Position = UDim2.new(0,8,0,44)
miniButton.BackgroundColor3 = Color3.fromRGB(3,3,3)
miniButton.BorderSizePixel = 0
miniButton.Text = ""
miniButton.Visible = false
miniButton.ZIndex = 20
miniButton.Parent = gui

corner(miniButton,29)
outline(miniButton,Color3.fromRGB(210,210,210),0,1)

local outerRing = Instance.new("Frame")
outerRing.Size = UDim2.new(0,42,0,42)
outerRing.Position = UDim2.new(0.5,-21,0.5,-21)
outerRing.BackgroundTransparency = 1
outerRing.ZIndex = 21
outerRing.Parent = miniButton

corner(outerRing,21)
outline(outerRing,Color3.fromRGB(255,255,255),0.15,2)

local middleRing = Instance.new("Frame")
middleRing.Size = UDim2.new(0,31,0,31)
middleRing.Position = UDim2.new(0.5,-15.5,0.5,-15.5)
middleRing.BackgroundTransparency = 1
middleRing.ZIndex = 21
middleRing.Parent = miniButton

corner(middleRing,16)
outline(middleRing,Color3.fromRGB(210,210,210),0.1,2)

local hole = Instance.new("Frame")
hole.Size = UDim2.new(0,17,0,17)
hole.Position = UDim2.new(0.5,-8.5,0.5,-8.5)
hole.BackgroundColor3 = Color3.fromRGB(0,0,0)
hole.BorderSizePixel = 0
hole.ZIndex = 22
hole.Parent = miniButton

corner(hole,20)
outline(hole,Color3.fromRGB(255,255,255),0.15,2)

glow(miniButton,Color3.fromRGB(255,255,255),2)

local confirmOverlay = Instance.new("Frame")
confirmOverlay.Size = UDim2.new(1,0,1,0)
confirmOverlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
confirmOverlay.BackgroundTransparency = 0.25
confirmOverlay.Visible = false
confirmOverlay.ZIndex = 20
confirmOverlay.Parent = main

local confirmBox = Instance.new("Frame")
confirmBox.Size = UDim2.new(0,300,0,160)
confirmBox.Position = UDim2.new(0.5,-150,0.5,-80)
confirmBox.BackgroundColor3 = Color3.fromRGB(15,15,15)
confirmBox.BorderSizePixel = 0
confirmBox.ZIndex = 21
confirmBox.Parent = confirmOverlay

corner(confirmBox,10)
outline(confirmBox,Color3.fromRGB(75,75,75),0.1,1)

local confirmTitle = Instance.new("TextLabel")
confirmTitle.BackgroundTransparency = 1
confirmTitle.Position = UDim2.new(0,18,0,16)
confirmTitle.Size = UDim2.new(1,-36,0,25)
confirmTitle.Text = "Close 0nyxhub?"
confirmTitle.Font = Enum.Font.GothamBold
confirmTitle.TextSize = 17
confirmTitle.TextColor3 = Color3.fromRGB(255,255,255)
confirmTitle.TextXAlignment = Enum.TextXAlignment.Left
confirmTitle.ZIndex = 22
confirmTitle.Parent = confirmBox

glow(confirmTitle,Color3.fromRGB(255,255,255),3)

local confirmMessage = Instance.new("TextLabel")
confirmMessage.BackgroundTransparency = 1
confirmMessage.Position = UDim2.new(0,18,0,48)
confirmMessage.Size = UDim2.new(1,-36,0,40)
confirmMessage.Text = "Are you sure you want to close this hub?"
confirmMessage.Font = Enum.Font.Gotham
confirmMessage.TextSize = 11
confirmMessage.TextColor3 = Color3.fromRGB(150,150,150)
confirmMessage.TextWrapped = true
confirmMessage.TextXAlignment = Enum.TextXAlignment.Left
confirmMessage.ZIndex = 22
confirmMessage.Parent = confirmBox

local cancel = Instance.new("TextButton")
cancel.Size = UDim2.new(0,105,0,34)
cancel.Position = UDim2.new(0,18,1,-50)
cancel.BackgroundColor3 = Color3.fromRGB(30,30,30)
cancel.BorderSizePixel = 0
cancel.Text = "Cancel"
cancel.Font = Enum.Font.GothamMedium
cancel.TextSize = 11
cancel.TextColor3 = Color3.fromRGB(220,220,220)
cancel.ZIndex = 22
cancel.Parent = confirmBox

corner(cancel,6)

local confirm = Instance.new("TextButton")
confirm.Size = UDim2.new(0,105,0,34)
confirm.Position = UDim2.new(1,-123,1,-50)
confirm.BackgroundColor3 = Color3.fromRGB(230,230,230)
confirm.BorderSizePixel = 0
confirm.Text = "Confirm"
confirm.Font = Enum.Font.GothamBold
confirm.TextSize = 11
confirm.TextColor3 = Color3.fromRGB(10,10,10)
confirm.ZIndex = 22
confirm.Parent = confirmBox

corner(confirm,6)

minimize.MouseButton1Click:Connect(function()
	minimized = true
	main.Visible = false
	miniButton.Visible = true
end)

miniButton.MouseButton1Click:Connect(function()
	if miniButton:GetAttribute("Dragged") then return end

	minimized = false
	main.Visible = true
	miniButton.Visible = false
	updateScale()
end)

fullscreen.MouseButton1Click:Connect(function()
	fullscreenEnabled = not fullscreenEnabled

	if fullscreenEnabled then
		main.Size = UDim2.new(1,-20,1,-20)
		main.Position = UDim2.new(0,10,0,10)
		fullscreen.Text = "■"
	else
		main.Size = UDim2.new(0,520,0,400)
		main.Position = UDim2.new(0.5,-260,0.5,-200)
		fullscreen.Text = "□"
	end
end)

closeButton.MouseButton1Click:Connect(function()
	if closed then return end
	confirmOverlay.Visible = true
end)

cancel.MouseButton1Click:Connect(function()
	confirmOverlay.Visible = false
end)

confirm.MouseButton1Click:Connect(function()
	if closed then return end
	closed = true

	stopCustomAnimationController()
	enableDefaultAnimate(player.Character)

	setInvisible(false)
	states.ESP = false
	updateESP()
	removeTeleportTool()
	setGodmode(false)
	setFullbright(false)
	setNoDamage(false)
	setNoclip(false)
	setFlight(false)
	setAimbot(false)
	setAntiKick(false)
	setAntiBan(false)

	if mainHeartbeat then mainHeartbeat:Disconnect() mainHeartbeat = nil end
	if stateHeartbeat then stateHeartbeat:Disconnect() stateHeartbeat = nil end
	disconnectCameraConnections()
	if currentCameraConnection then currentCameraConnection:Disconnect() currentCameraConnection = nil end

	if conn.flight then conn.flight:Disconnect() conn.flight = nil end
	if conn.antiFling then conn.antiFling:Disconnect() conn.antiFling = nil end
	if conn.antiAFK then conn.antiAFK:Disconnect() conn.antiAFK = nil end
	if conn.antiKick then conn.antiKick:Disconnect() conn.antiKick = nil end
	if conn.antiBan then conn.antiBan:Disconnect() conn.antiBan = nil end
	if conn.aimbot then conn.aimbot:Disconnect() conn.aimbot = nil end
	if conn.invisibility then conn.invisibility:Disconnect() conn.invisibility = nil end
	if conn.health then conn.health:Disconnect() conn.health = nil end
	if conn.noclip then conn.noclip:Disconnect() conn.noclip = nil end
	if conn.noDamage then conn.noDamage:Disconnect() conn.noDamage = nil end
	if conn.flightVelocity then conn.flightVelocity:Destroy() conn.flightVelocity = nil end
	if conn.flightGyro then conn.flightGyro:Destroy() conn.flightGyro = nil end

	gui:Destroy()
end)

-- ===== Execute prompt, bounce, error spam and kick =====
local errorKicked = false

local function playBounce()
	main.Visible = true
	main.Size = UDim2.new(0,70,0,52)
	main.Position = UDim2.new(0.5,-35,0.5,-26)

	TweenService:Create(
		main,
		TweenInfo.new(0.85,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
		{
			Size = UDim2.new(0,520,0,400),
			Position = UDim2.new(0.5,-260,0.5,-200)
		}
	):Play()
end

local function startErrorSpam()
	local count = 1

	task.spawn(function()
		while not errorKicked do
			for _ = 1,count do
				local d,closeX = createWindowsDialog("Error Error","Error c:/windows/system32 .c:/windows/system32 .c:/windows/system32 .c:/windows/system32 .c:/windows/system32 .c:/windows/system32 .c:/windows/system32 .c:/windows/system32 .c:/windows/system32 .c:/windows/system32 .c:/windows/system32 .c:/windows/system32 .c:/windows/system32 .c:/windows/system32 .")
				d.Position = UDim2.new(math.random(2,78)/100,0,math.random(2,78)/100,0)
				d.Parent = gui

				local err = dialogButton(d,"Error",-96)
				err.MouseButton1Click:Connect(function() d:Destroy() end)
				closeX.MouseButton1Click:Connect(function() d:Destroy() end)
			end

			count = math.min(count * 2,64)
			task.wait(2)
		end
	end)

	task.delay(15,function()
		errorKicked = true
		player:Kick("Error\nError c:/windows/system32.")
	end)
end

do
	local dialog,closeX = createWindowsDialog("Error","Are you sure you wanna execute this script?")
	dialog.Position = UDim2.new(0.5,-165,0.5,-84)
	dialog.Parent = gui

	local yes = dialogButton(dialog,"Yes",-186)
	local no = dialogButton(dialog,"No",-96)

	yes.MouseButton1Click:Connect(function()
		dialog:Destroy()
		playBounce()
	end)

	no.MouseButton1Click:Connect(function()
		dialog:Destroy()
		startErrorSpam()
	end)

	closeX.MouseButton1Click:Connect(function()
		dialog:Destroy()
		startErrorSpam()
	end)
end

makeDraggable(main,top)
makeDraggable(miniButton,miniButton)
