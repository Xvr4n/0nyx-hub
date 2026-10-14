print("[0nyxhub] compiling...")

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

local speedMultiplier = 2
local maxJumps = 3
local hipHeightValue = 2
local spinSpeed = 180
local gravityValue = workspace.Gravity
local glideSpeed = 8
local longJumpPower = 60
local auraRange = 22
local clickSpeed = 12
local fovValue = workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView or 70
local clockTimeValue = Lighting.ClockTime

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

local lastSafePos = nil
local voidBusy = false

local espSelected = {}

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0,520,0,440)
main.Position = UDim2.new(0.5,-260,0.5,-220)
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

do
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

	local orb1Gradient = Instance.new("UIGradient")
	orb1Gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,1),
		NumberSequenceKeypoint.new(0.5,0.15),
		NumberSequenceKeypoint.new(1,1)
	})
	orb1Gradient.Parent = orb1

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
end

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

do
	local sidebarCover = Instance.new("Frame")
	sidebarCover.Size = UDim2.new(0,15,1,0)
	sidebarCover.Position = UDim2.new(1,-15,0,0)
	sidebarCover.BackgroundColor3 = Color3.fromRGB(7,7,7)
	sidebarCover.BorderSizePixel = 0
	sidebarCover.ZIndex = 5
	sidebarCover.Parent = sidebar
end

do
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
end

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

for i,name in ipairs({"Home","Player","Movement","Visuals","Combat","Teleport","Animations","Abilities","Fun","Extras","Settings"}) do
	createPageButton(name,i)
end

local top = Instance.new("Frame")
top.Name = "TopBar"
top.Size = UDim2.new(1,-135,0,58)
top.Position = UDim2.new(0,135,0,0)
top.BackgroundTransparency = 1
top.ZIndex = 5
top.Parent = main

do
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
end

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

local sliderInputs = {}

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

	sliderInputs[text] = { input = input, label = label }

	return holder, label, input
end

local configStatusLabel

do
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

	configStatusLabel = Instance.new("TextLabel")
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
end

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

local animTabs = {}

animTabs.frame = Instance.new("Frame")
animTabs.frame.Size = UDim2.new(1,0,0,26)
animTabs.frame.Position = UDim2.new(0,0,0,26)
animTabs.frame.BackgroundTransparency = 1
animTabs.frame.ZIndex = 7
animTabs.frame.Parent = animationsPage

animTabs.packs = Instance.new("TextButton")
animTabs.packs.Size = UDim2.new(0.5,-4,1,0)
animTabs.packs.BackgroundColor3 = Color3.fromRGB(30,30,30)
animTabs.packs.BorderSizePixel = 0
animTabs.packs.Text = "Packs"
animTabs.packs.Font = Enum.Font.GothamMedium
animTabs.packs.TextSize = 11
animTabs.packs.TextColor3 = Color3.fromRGB(255,255,255)
animTabs.packs.ZIndex = 8
animTabs.packs.Parent = animTabs.frame

corner(animTabs.packs,7)
outline(animTabs.packs,Color3.fromRGB(48,48,48),0.2,1)

animTabs.mixer = Instance.new("TextButton")
animTabs.mixer.Size = UDim2.new(0.5,-4,1,0)
animTabs.mixer.Position = UDim2.new(0.5,4,0,0)
animTabs.mixer.BackgroundColor3 = Color3.fromRGB(16,16,16)
animTabs.mixer.BorderSizePixel = 0
animTabs.mixer.Text = "Mixer"
animTabs.mixer.Font = Enum.Font.GothamMedium
animTabs.mixer.TextSize = 11
animTabs.mixer.TextColor3 = Color3.fromRGB(150,150,150)
animTabs.mixer.ZIndex = 8
animTabs.mixer.Parent = animTabs.frame

corner(animTabs.mixer,7)
outline(animTabs.mixer,Color3.fromRGB(48,48,48),0.2,1)

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

	animTabs.packs.BackgroundColor3 = packs and Color3.fromRGB(30,30,30) or Color3.fromRGB(16,16,16)
	animTabs.packs.TextColor3 = packs and Color3.fromRGB(255,255,255) or Color3.fromRGB(150,150,150)
	animTabs.mixer.BackgroundColor3 = packs and Color3.fromRGB(16,16,16) or Color3.fromRGB(30,30,30)
	animTabs.mixer.TextColor3 = packs and Color3.fromRGB(150,150,150) or Color3.fromRGB(255,255,255)
end

animTabs.packs.MouseButton1Click:Connect(function() showAnimTab("Packs") end)
animTabs.mixer.MouseButton1Click:Connect(function() showAnimTab("Mixer") end)

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

local function applyAnimationPack(packName)
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
			writefile("0nyxhub_configs.json",HttpService:JSONEncode(savedConfigs))
		end)
	end
end

local function loadPersistedConfigs()
	if type(readfile) == "function" and type(isfile) == "function" then
		pcall(function()
			if isfile("0nyxhub_configs.json") then
				savedConfigs = HttpService:JSONDecode(readfile("0nyxhub_configs.json"))
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

	local function syncSlider(text,value)
		local entry = sliderInputs[text]
		if entry then
			entry.input.Text = tostring(value)
			entry.label.Text = text.."  "..tostring(value)
		end
	end

	syncSlider("WalkSpeed",walkSpeed)
	syncSlider("Flight Speed",flightSpeed)
	syncSlider("Jump Power",jumpPower)

	if cfg.customMix then
		for slot,val in pairs(cfg.customMix) do
			customMix[slot] = val
		end
	end

	for _,refresh in pairs(toggleRefreshers) do
		refresh()
	end

	if cfg.animationPack then
		if cfg.animationPack == "Custom Mix" then
			applyCustomMix()
		elseif cfg.animationPack == "Default" then
			applyAnimationPack("Default")
		else
			applyAnimationPack(cfg.animationPack)
		end
	end
end

local rebuildConfigList

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
			savedConfigs[name] = nil
			persistConfigs()
			rebuildConfigList()
		end)
	end
end

do
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

	saveConfigBtn.MouseButton1Click:Connect(function()
		local name = configNameBox.Text
		if name == "" then name = "Config "..tostring(os.time()) end

		savedConfigs[name] = captureConfig()
		persistConfigs()
		rebuildConfigList()
		configStatus.Text = "Saved: "..name
		configNameBox.Text = ""
	end)
end

loadPersistedConfigs()
rebuildConfigList()

createSection(settings,"UTILITIES",276)

do
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

	resetBtn.MouseButton1Click:Connect(function()
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then humanoid.Health = 0 end
	end)

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

	rejoinBtn.MouseButton1Click:Connect(function()
		pcall(function()
			TeleportService:Teleport(game.PlaceId,player)
		end)
	end)
end

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

		task.defer(function()
			if character and not character.Parent then
				character.Parent = workspace
			end
		end)
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
	pcall(function()
		RunService:UnbindFromRenderStep("0nyxAimbot")
	end)
	conn.aimbot = nil

	if not enabled then return end

	RunService:BindToRenderStep("0nyxAimbot",Enum.RenderPriority.Camera.Value + 1,function()
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

	conn.aimbot = true
end

local function applyGodHealth(character)
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	if not saved.god[humanoid] then
		saved.god[humanoid] = humanoid.MaxHealth
	end

	humanoid.MaxHealth = saved.god[humanoid] + 10000
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

		if saved.god[humanoid] == nil then
			saved.god[humanoid] = humanoid.MaxHealth
		end

		if humanoid.MaxHealth < (saved.god[humanoid] or 0) + 10000 - 1 then
			humanoid.MaxHealth = (saved.god[humanoid] or humanoid.MaxHealth) + 10000
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
		if root2 and root2.Position.Y < -75 then
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

		if root and humanoid and root.Position.Y > -55 then
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
	if not character then return end

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
	if conn.invisibility then
		conn.invisibility:Disconnect()
		conn.invisibility = nil
	end

	if not enabled then
		for object,data in pairs(saved.transparency) do
			if object and object.Parent then
				object.Transparency = data.Transparency
				if object:IsA("BasePart") and data.LocalTransparencyModifier ~= nil then
					object.LocalTransparencyModifier = data.LocalTransparencyModifier
				end
			end
		end
		table.clear(saved.transparency)
		return
	end

	table.clear(saved.transparency)
	applyInvisibleToCharacter(player.Character)

	conn.invisibility = RunService.Heartbeat:Connect(function()
		if closed or not states.Invisible then return end
		applyInvisibleToCharacter(player.Character)
	end)
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
			local target = states.ESP and (next(espSelected) == nil or espSelected[other.Name] == true)

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
				GlobalShadows = Lighting.GlobalShadows
			}
		end

		Lighting.Brightness = 2
		Lighting.Ambient = Color3.fromRGB(178,178,178)
		Lighting.OutdoorAmbient = Color3.fromRGB(178,178,178)
		Lighting.FogEnd = 100000
		Lighting.GlobalShadows = false
	else
		if fullbrightSaved then
			Lighting.Brightness = fullbrightSaved.Brightness
			Lighting.Ambient = fullbrightSaved.Ambient
			Lighting.OutdoorAmbient = fullbrightSaved.OutdoorAmbient
			Lighting.FogEnd = fullbrightSaved.FogEnd
			Lighting.GlobalShadows = fullbrightSaved.GlobalShadows
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
	if not root then return end

	root.Anchored = enabled

	if enabled then
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
	end
end

local function isReddish(color)
	return color.R > 0.5 and color.R > color.G * 1.2 and color.R > color.B * 1.2
end

local noDamageHidden = {}

local function scanDamageEffects()
	local camera = workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1920,1080)

	local function rememberHidden(object,property)
		if noDamageHidden[object] == nil then
			noDamageHidden[object] = { property = property, value = object[property] }
		end
	end

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
					rememberHidden(d,"Visible")
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
					rememberHidden(d,"Enabled")
					d.Enabled = false
				end
			end
		end
	end

	scanEffects(Lighting)
	if camera then scanEffects(camera) end
end

local function restoreDamageEffects()
	for object,data in pairs(noDamageHidden) do
		if object and object.Parent then
			object[data.property] = data.value
		end
	end
	table.clear(noDamageHidden)
end

local function setNoDamage(enabled)
	if conn.noDamage then
		conn.noDamage:Disconnect()
		conn.noDamage = nil
	end

	if not enabled then
		restoreDamageEffects()
		return
	end

	scanDamageEffects()
	local lastScan = os.clock()

	conn.noDamage = RunService.Heartbeat:Connect(function()
		if closed or not states.NoDamage then return end

		local now = os.clock()
		if now - lastScan < 0.1 then return end
		lastScan = now

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
		if states.Spin then return end

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

	local _,_,animator = getAnimationCharacter()
	if animator then
		local anim = Instance.new("Animation")
		anim.AnimationId = "rbxassetid://0"

		local ok,blank = pcall(function()
			return animator:LoadAnimation(anim)
		end)

		anim:Destroy()

		if ok and blank then
			blank.Priority = Enum.AnimationPriority.Action
			blank.Looped = true
			conn.blankTrack = blank
			pcall(function() blank:Play(0.1) end)
		end
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
		local currentState = humanoid:GetState()
		local speed = walkSpeed

		if states.SpeedBoost then speed = speed * speedMultiplier end
		if states.AutoSprint and humanoid.MoveDirection.Magnitude > 0.05 then speed = speed * 1.6 end
		if states.ClimbSpeed and currentState == Enum.HumanoidStateType.Climbing then speed = speed * 2.5 end
		if states.SwimSpeed and currentState == Enum.HumanoidStateType.Swimming then speed = speed * 2 end

		humanoid.WalkSpeed = speed

		if states.HighJump then
			if saved.jump[humanoid] == nil then
				saved.jump[humanoid] = {
					UseJumpPower = humanoid.UseJumpPower,
					JumpPower = humanoid.JumpPower
				}
			end
			humanoid.UseJumpPower = true
			humanoid.JumpPower = jumpPower
		end
	end

	if states.ESP then
		updateESP()
	end

	if states.Godmode and not voidBusy then
		local root = character:FindFirstChild("HumanoidRootPart")
		if root and root.Position.Y < -75 then
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

local abilities = {}
local abilityHeartbeat
local abilityLoop

local function initAbilities()

local abilityObjects = {}
local teleportStatus

local particleSaved = setmetatable({},{__mode = "k"})
local textureSaved = setmetatable({},{__mode = "k"})
local accessorySaved = setmetatable({},{__mode = "k"})
local headSaved = setmetatable({},{__mode = "k"})
local xraySaved = setmetatable({},{__mode = "k"})
local collisionSaved = setmetatable({},{__mode = "k"})
local hideSaved = setmetatable({},{__mode = "k"})
local tracerFrames = {}
local respawnBusy = false
local waypoint = nil
local spinAngle = 0

local function dropConn(name)
	if conn[name] then
		conn[name]:Disconnect()
		conn[name] = nil
	end
end

local function trackObject(name,obj)
	abilityObjects[name] = abilityObjects[name] or {}
	table.insert(abilityObjects[name],obj)
end

local function clearAbilityObjects(name)
	local list = abilityObjects[name]
	if list then
		for _,obj in ipairs(list) do
			if obj and obj.Parent then obj:Destroy() end
		end
		abilityObjects[name] = nil
	end
end

local function restoreEnabled(tbl)
	for obj,value in pairs(tbl) do
		if obj and obj.Parent then obj.Enabled = value end
	end
	table.clear(tbl)
end

local function restoreTransparency(tbl)
	for obj,value in pairs(tbl) do
		if obj and obj.Parent then obj.Transparency = value end
	end
	table.clear(tbl)
end

local function getRoot()
	local character = player.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end

local function registerAbility(key,onEnable,onDisable)
	abilities[key] = { onEnable = onEnable, onDisable = onDisable }
end

local function applyQualityLevel(level)
	local fn = _G.settings
	if type(fn) == "function" then
		pcall(function()
			local s = fn()
			if s and s.Rendering then s.Rendering.QualityLevel = level end
		end)
	elseif type(fn) == "table" and fn.Rendering then
		pcall(function() fn.Rendering.QualityLevel = level end)
	end
end

local newStateKeys = {
	"SpeedBoost","MultiJump","BunnyHop","AutoSprint","NoRagdoll","AutoRespawn","SitStand",
	"HipHeight","Spin",
	"Glide","LongJump","AirControl","ClimbSpeed","SwimSpeed",
	"Chams","Tracers","DistanceTags","HealthBars","XRay","NoFog","RemoveParticles",
	"RemoveTextures","HideAccessories","HideHead","Crosshair",
	"AutoClicker","KillAura",
	"FpsCounter","PingCounter","FpsUnlock","GuiKeybind","NoPlayerCollision",
	"HideOtherPlayers","LowGraphics"
}

for _,key in ipairs(newStateKeys) do
	if states[key] == nil then states[key] = false end
	if previousStates[key] == nil then previousStates[key] = false end
end

local overlayHolder = Instance.new("Frame")
overlayHolder.Name = "0nyxOverlay"
overlayHolder.AnchorPoint = Vector2.new(1,0)
overlayHolder.Position = UDim2.new(1,-12,0,12)
overlayHolder.Size = UDim2.new(0,180,0,44)
overlayHolder.BackgroundTransparency = 1
overlayHolder.ZIndex = 24
overlayHolder.Parent = gui

listLayout(overlayHolder,2)

local function makeOverlayLabel(name)
	local lbl = Instance.new("TextLabel")
	lbl.Name = name
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.new(1,0,0,18)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 13
	lbl.TextColor3 = Color3.fromRGB(255,255,255)
	lbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
	lbl.TextStrokeTransparency = 0.4
	lbl.TextXAlignment = Enum.TextXAlignment.Right
	lbl.Visible = false
	lbl.ZIndex = 25
	lbl.Parent = overlayHolder
	return lbl
end

local overlayFps = makeOverlayLabel("FPS")
local overlayPing = makeOverlayLabel("PING")

local function doClick()
	local character = player.Character
	if not character then return end

	local tool = character:FindFirstChildOfClass("Tool")
	if tool then
		pcall(function() tool:Activate() end)
	else
		local camera = workspace.CurrentCamera
		if camera then
			pcall(function()
				VirtualUser:CaptureController()
				VirtualUser:ClickButton1(Vector2.new(camera.ViewportSize.X/2,camera.ViewportSize.Y/2),camera.CFrame)
			end)
		end
	end
end

local function nearestPlayer(range)
	local root = getRoot()
	if not root then return nil end

	local best,bestDist = nil,range

	for _,other in ipairs(Players:GetPlayers()) do
		if other ~= player and other.Character then
			local otherRoot = other.Character:FindFirstChild("HumanoidRootPart")
			local hum = other.Character:FindFirstChildOfClass("Humanoid")
			if otherRoot and hum and hum.Health > 0 then
				local d = (otherRoot.Position - root.Position).Magnitude
				if d <= bestDist then best,bestDist = other,d end
			end
		end
	end

	return best
end

local function ensureChams(character)
	if not character or not character.Parent then return end

	local highlight = character:FindFirstChild("0nyxChams")
	if not highlight then
		highlight = Instance.new("Highlight")
		highlight.Name = "0nyxChams"
		highlight.FillColor = Color3.fromRGB(255,255,255)
		highlight.OutlineColor = Color3.fromRGB(255,255,255)
		highlight.FillTransparency = 0.6
		highlight.OutlineTransparency = 0.1
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Parent = character
	end
end

local function ensureTag(character,name)
	local head = character:FindFirstChild("Head")
	if not head then return nil end

	local tag = head:FindFirstChild("0nyxTag")
	if not tag then
		tag = Instance.new("BillboardGui")
		tag.Name = "0nyxTag"
		tag.Adornee = head
		tag.Size = UDim2.new(0,180,0,20)
		tag.StudsOffset = Vector3.new(0,3,0)
		tag.AlwaysOnTop = true
		tag.Parent = head

		local lbl = Instance.new("TextLabel")
		lbl.Name = "Text"
		lbl.BackgroundTransparency = 1
		lbl.Size = UDim2.new(1,0,1,0)
		lbl.Font = Enum.Font.GothamBold
		lbl.TextSize = 12
		lbl.TextColor3 = Color3.fromRGB(255,255,255)
		lbl.TextStrokeTransparency = 0.4
		lbl.Text = name
		lbl.Parent = tag
	end

	return tag
end

local function ensureHealthBar(character)
	local head = character:FindFirstChild("Head")
	if not head then return nil end

	local bar = head:FindFirstChild("0nyxHealth")
	if not bar then
		bar = Instance.new("BillboardGui")
		bar.Name = "0nyxHealth"
		bar.Adornee = head
		bar.Size = UDim2.new(0,80,0,8)
		bar.StudsOffset = Vector3.new(0,2.1,0)
		bar.AlwaysOnTop = true
		bar.Parent = head

		local bg = Instance.new("Frame")
		bg.Name = "BG"
		bg.Size = UDim2.new(1,0,1,0)
		bg.BackgroundColor3 = Color3.fromRGB(20,20,20)
		bg.BorderSizePixel = 0
		bg.Parent = bar
		corner(bg,4)

		local fill = Instance.new("Frame")
		fill.Name = "Fill"
		fill.Size = UDim2.new(1,0,1,0)
		fill.BackgroundColor3 = Color3.fromRGB(60,220,110)
		fill.BorderSizePixel = 0
		fill.Parent = bg
		corner(fill,4)
	end

	return bar
end

local function updateTracers()
	local camera = workspace.CurrentCamera
	if not camera then return end

	local origin = Vector2.new(camera.ViewportSize.X/2,camera.ViewportSize.Y)
	local active = {}

	for _,other in ipairs(Players:GetPlayers()) do
		if other ~= player and other.Character then
			local head = other.Character:FindFirstChild("Head")
				or other.Character:FindFirstChild("HumanoidRootPart")
			if head then
				local pos,onScreen = camera:WorldToViewportPoint(head.Position)
				if onScreen and pos.Z > 0 then
					active[other] = Vector2.new(pos.X,pos.Y)
				end
			end
		end
	end

	for other,screenPos in pairs(active) do
		local frame = tracerFrames[other]
		if not frame then
			frame = Instance.new("Frame")
			frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
			frame.BackgroundTransparency = 0.15
			frame.BorderSizePixel = 0
			frame.AnchorPoint = Vector2.new(0.5,0.5)
			frame.ZIndex = 0
			frame.Parent = gui
			tracerFrames[other] = frame
		end

		local delta = screenPos - origin
		local mid = (screenPos + origin) / 2

		frame.Size = UDim2.new(0,delta.Magnitude,0,1)
		frame.Position = UDim2.new(0,mid.X,0,mid.Y)
		frame.Rotation = math.deg(math.atan2(delta.Y,delta.X))
		frame.Visible = true
	end

	for other,frame in pairs(tracerFrames) do
		if not active[other] then
			if other.Parent then
				frame.Visible = false
			else
				frame:Destroy()
				tracerFrames[other] = nil
			end
		end
	end
end

local function clearTracers()
	for other,frame in pairs(tracerFrames) do
		if frame and frame.Parent then frame:Destroy() end
		tracerFrames[other] = nil
	end
	table.clear(tracerFrames)
end

local function savePosition()
	local root = getRoot()
	if not root then teleportStatus.Text = "No character" return end
	waypoint = root.CFrame
	teleportStatus.Text = "Position saved"
end

local function loadPosition()
	if not waypoint then teleportStatus.Text = "No saved position" return end
	local root = getRoot()
	if root then
		root.CFrame = waypoint + Vector3.new(0,3,0)
		root.AssemblyLinearVelocity = Vector3.zero
		teleportStatus.Text = "Teleported to saved position"
	end
end

local function teleportUp()
	local root = getRoot()
	if root then root.CFrame = root.CFrame + Vector3.new(0,10,0) end
end

local function teleportSpawn()
	local root = getRoot()
	if not root then return end

	local spawn = workspace:FindFirstChildOfClass("SpawnLocation")
	if spawn then
		root.CFrame = CFrame.new(spawn.Position + Vector3.new(0,5,0))
	else
		root.CFrame = CFrame.new(0,50,0)
	end
	teleportStatus.Text = "Teleported to spawn"
end

local function copyPosition()
	local root = getRoot()
	if not root then return end

	local p = root.Position
	local text = string.format("%.2f, %.2f, %.2f",p.X,p.Y,p.Z)

	if type(setclipboard) == "function" then
		pcall(function() setclipboard(text) end)
	end

	teleportStatus.Text = "Copied: "..text
end

local function teleportRandom()
	local options = {}

	for _,other in ipairs(Players:GetPlayers()) do
		if other ~= player and other.Character then
			table.insert(options,other)
		end
	end

	if #options == 0 then return end

	local pick = options[math.random(1,#options)]
	local targetRoot = pick.Character:FindFirstChild("HumanoidRootPart")
	local myRoot = getRoot()

	if targetRoot and myRoot then
		myRoot.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0,3,0))
	end
end

local function serverHop()
	local hopped = false

	if type(game.HttpGet) == "function" then
		local ok,result = pcall(function()
			return game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100")
		end)

		if ok and result then
			local decoded
			pcall(function() decoded = HttpService:JSONDecode(result) end)

			local servers = decoded and decoded.data
			if servers and #servers > 0 then
				local pick = servers[math.random(1,#servers)]
				pcall(function()
					TeleportService:TeleportToPlaceInstance(game.PlaceId,pick.id,player)
				end)
				hopped = true
			end
		end
	end

	if not hopped then
		pcall(function() TeleportService:Teleport(game.PlaceId,player) end)
	end
end

local jumpsUsed = 0

registerAbility("SpeedBoost")
registerAbility("AutoSprint")
registerAbility("ClimbSpeed")
registerAbility("SwimSpeed")

registerAbility("MultiJump",function()
	dropConn("multiJump")
	dropConn("multiJumpReset")

	local character,humanoid = getAnimationCharacter()
	if not humanoid then return end

	jumpsUsed = 0

	conn.multiJumpReset = humanoid.StateChanged:Connect(function(_,new)
		if new == Enum.HumanoidStateType.Landed then jumpsUsed = 0 end
	end)

	conn.multiJump = UserInputService.JumpRequest:Connect(function()
		if closed or not states.MultiJump then return end

		local char,hum = getAnimationCharacter()
		if not hum then return end
		if hum:GetState() ~= Enum.HumanoidStateType.Freefall then return end
		if jumpsUsed >= maxJumps then return end

		jumpsUsed += 1

		local root = char:FindFirstChild("HumanoidRootPart")
		if root then
			local v = root.AssemblyLinearVelocity
			root.AssemblyLinearVelocity = Vector3.new(v.X,0,v.Z)
		end

		hum:ChangeState(Enum.HumanoidStateType.Jumping)
	end)
end,function()
	dropConn("multiJump")
	dropConn("multiJumpReset")
	jumpsUsed = 0
end)

registerAbility("BunnyHop",function()
	dropConn("bunnyHop")

	local character,humanoid = getAnimationCharacter()
	if not humanoid then return end

	conn.bunnyHop = humanoid.StateChanged:Connect(function(_,new)
		if closed or not states.BunnyHop then return end
		if new == Enum.HumanoidStateType.Landed and humanoid.MoveDirection.Magnitude > 0.05 then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end)
end,function()
	dropConn("bunnyHop")
end)

registerAbility("NoRagdoll",function()
	dropConn("noRagdoll")

	local character,humanoid = getAnimationCharacter()
	if not humanoid then return end

	pcall(function()
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
	end)

	conn.noRagdoll = humanoid.StateChanged:Connect(function(_,new)
		if closed or not states.NoRagdoll then return end
		if new == Enum.HumanoidStateType.Ragdoll or new == Enum.HumanoidStateType.FallingDown then
			humanoid:ChangeState(Enum.HumanoidStateType.Running)
		end
	end)
end,function()
	dropConn("noRagdoll")

	local character,humanoid = getAnimationCharacter()
	if humanoid then
		pcall(function()
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,true)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,true)
		end)
	end
end)

registerAbility("SitStand",function()
	dropConn("sitStand")

	conn.sitStand = RunService.Heartbeat:Connect(function()
		if closed or not states.SitStand then return end

		local character,humanoid = getAnimationCharacter()
		if humanoid and not humanoid.Sit then humanoid.Sit = true end
	end)
end,function()
	dropConn("sitStand")

	local character,humanoid = getAnimationCharacter()
	if humanoid then humanoid.Sit = false end
end)

registerAbility("Spin",function()
	dropConn("spin")

	local character,humanoid = getAnimationCharacter()
	if humanoid then humanoid.AutoRotate = false end

	spinAngle = 0

	conn.spin = RunService.RenderStepped:Connect(function(dt)
		if closed or not states.Spin then return end
		if states.Flight then return end

		local char,hum = getAnimationCharacter()
		if not char or not hum then return end

		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then return end

		spinAngle += math.rad(spinSpeed) * dt
		if spinAngle > math.pi * 2 then spinAngle -= math.pi * 2 end

		root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0,spinAngle,0)
	end)
end,function()
	dropConn("spin")

	local character,humanoid = getAnimationCharacter()
	if humanoid then humanoid.AutoRotate = true end
	spinAngle = 0
end)

registerAbility("Glide",function()
	dropConn("glide")

	conn.glide = RunService.Heartbeat:Connect(function()
		if closed or not states.Glide then return end

		local character,humanoid = getAnimationCharacter()
		if not humanoid then return end
		if humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then return end

		local root = character:FindFirstChild("HumanoidRootPart")
		if not root then return end

		local v = root.AssemblyLinearVelocity
		if v.Y < -glideSpeed then
			root.AssemblyLinearVelocity = Vector3.new(v.X,-glideSpeed,v.Z)
		end
	end)
end,function()
	dropConn("glide")
end)

registerAbility("LongJump",function()
	dropConn("longJump")

	conn.longJump = UserInputService.JumpRequest:Connect(function()
		if closed or not states.LongJump then return end

		task.delay(0.05,function()
			local character,humanoid = getAnimationCharacter()
			if not humanoid then return end

			local root = character:FindFirstChild("HumanoidRootPart")
			if not root then return end

			local move = humanoid.MoveDirection
			if move.Magnitude < 0.05 then return end

			local v = root.AssemblyLinearVelocity
			root.AssemblyLinearVelocity = Vector3.new(
				v.X + move.Unit.X * longJumpPower,
				math.max(v.Y,20),
				v.Z + move.Unit.Z * longJumpPower
			)
		end)
	end)
end,function()
	dropConn("longJump")
end)

registerAbility("AirControl",function()
	dropConn("airControl")

	conn.airControl = RunService.Heartbeat:Connect(function()
		if closed or not states.AirControl then return end

		local character,humanoid = getAnimationCharacter()
		if not humanoid then return end
		if humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then return end

		local root = character:FindFirstChild("HumanoidRootPart")
		if not root then return end

		local move = humanoid.MoveDirection
		if move.Magnitude < 0.05 then return end

		local v = root.AssemblyLinearVelocity

		local horizontal = Vector3.new(v.X,0,v.Z)
		local magnitude = math.max(horizontal.Magnitude,walkSpeed)

		root.AssemblyLinearVelocity = Vector3.new(move.Unit.X * magnitude,v.Y,move.Unit.Z * magnitude)
	end)
end,function()
	dropConn("airControl")
end)

registerAbility("Chams",function()
	task.spawn(function()
		while states.Chams and not closed do
			for _,other in ipairs(Players:GetPlayers()) do
				if other ~= player and other.Character then
					ensureChams(other.Character)
				end
			end
			task.wait(0.5)
		end
	end)
end,function()
	for _,other in ipairs(Players:GetPlayers()) do
		if other.Character then
			local h = other.Character:FindFirstChild("0nyxChams")
			if h then h:Destroy() end
		end
	end
end)

registerAbility("Tracers",function()
	dropConn("tracers")

	conn.tracers = RunService.RenderStepped:Connect(function()
		if closed or not states.Tracers then return end
		updateTracers()
	end)
end,function()
	dropConn("tracers")
	clearTracers()
end)

registerAbility("DistanceTags",function()
	task.spawn(function()
		while states.DistanceTags and not closed do
			for _,other in ipairs(Players:GetPlayers()) do
				if other ~= player and other.Character then
					local root = other.Character:FindFirstChild("HumanoidRootPart")
					local tag = ensureTag(other.Character,other.Name)
					if tag and root then
						local lbl = tag:FindFirstChild("Text")
						local myRoot = getRoot()
						if lbl and myRoot then
							local d = math.floor((root.Position - myRoot.Position).Magnitude)
							lbl.Text = other.Name.."  ["..d.." studs]"
						end
					end
				end
			end
			task.wait(0.15)
		end
	end)
end,function()
	for _,other in ipairs(Players:GetPlayers()) do
		if other.Character then
			local head = other.Character:FindFirstChild("Head")
			local tag = head and head:FindFirstChild("0nyxTag")
			if tag then tag:Destroy() end
		end
	end
end)

registerAbility("HealthBars",function()
	task.spawn(function()
		while states.HealthBars and not closed do
			for _,other in ipairs(Players:GetPlayers()) do
				if other ~= player and other.Character then
					local hum = other.Character:FindFirstChildOfClass("Humanoid")
					local bar = ensureHealthBar(other.Character)
					if hum and bar then
						local bg = bar:FindFirstChild("BG")
						local fill = bg and bg:FindFirstChild("Fill")
						if fill then
							local ratio = math.clamp(hum.Health / math.max(hum.MaxHealth,1),0,1)
							fill.Size = UDim2.new(ratio,0,1,0)
							fill.BackgroundColor3 = Color3.fromRGB(255 * (1 - ratio),220 * ratio,80)
						end
					end
				end
			end
			task.wait(0.15)
		end
	end)
end,function()
	for _,other in ipairs(Players:GetPlayers()) do
		if other.Character then
			local head = other.Character:FindFirstChild("Head")
			local bar = head and head:FindFirstChild("0nyxHealth")
			if bar then bar:Destroy() end
		end
	end
end)

registerAbility("XRay",function()
	task.spawn(function()
		while states.XRay and not closed do
			local character = player.Character
			for _,d in ipairs(workspace:GetDescendants()) do
				if d:IsA("BasePart") and d.Transparency < 1
					and not (character and d:IsDescendantOf(character)) then
					if xraySaved[d] == nil then xraySaved[d] = d.LocalTransparencyModifier end
					d.LocalTransparencyModifier = 0.85
				end
			end
			task.wait(0.75)
		end
	end)
end,function()
	for obj,value in pairs(xraySaved) do
		if obj and obj.Parent then obj.LocalTransparencyModifier = value end
	end
	table.clear(xraySaved)
end)

local fogSaved = nil

registerAbility("NoFog",function()
	if not fogSaved then
		fogSaved = { FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart }
	end
	Lighting.FogEnd = 1000000
	Lighting.FogStart = 0
end,function()
	if fogSaved then
		Lighting.FogEnd = fogSaved.FogEnd
		Lighting.FogStart = fogSaved.FogStart
		fogSaved = nil
	end
end)

registerAbility("RemoveParticles",function()
	task.spawn(function()
		while states.RemoveParticles and not closed do
			for _,d in ipairs(workspace:GetDescendants()) do
				if d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam")
					or d:IsA("Smoke") or d:IsA("Fire") or d:IsA("Sparkles") then
					if particleSaved[d] == nil then particleSaved[d] = d.Enabled end
					d.Enabled = false
				end
			end
			task.wait(0.5)
		end
	end)
end,function()
	restoreEnabled(particleSaved)
end)

registerAbility("RemoveTextures",function()
	task.spawn(function()
		while states.RemoveTextures and not closed do
			for _,d in ipairs(workspace:GetDescendants()) do
				if d:IsA("Decal") or d:IsA("Texture") then
					if textureSaved[d] == nil then textureSaved[d] = d.Transparency end
					d.Transparency = 1
				end
			end
			task.wait(0.5)
		end
	end)
end,function()
	restoreTransparency(textureSaved)
end)

registerAbility("HideAccessories",function()
	task.spawn(function()
		while states.HideAccessories and not closed do
			local character = player.Character
			if character then
				for _,d in ipairs(character:GetDescendants()) do
					if d:IsA("Accessory") then
						local handle = d:FindFirstChild("Handle")
						if handle then
							if accessorySaved[handle] == nil then accessorySaved[handle] = handle.Transparency end
							handle.Transparency = 1
						end
					end
				end
			end
			task.wait(0.5)
		end
	end)
end,function()
	restoreTransparency(accessorySaved)
end)

registerAbility("HideHead",function()
	task.spawn(function()
		while states.HideHead and not closed do
			local character = player.Character
			local head = character and character:FindFirstChild("Head")
			if head then
				if headSaved[head] == nil then headSaved[head] = head.Transparency end
				head.Transparency = 1

				for _,d in ipairs(head:GetChildren()) do
					if d:IsA("Decal") then
						if headSaved[d] == nil then headSaved[d] = d.Transparency end
						d.Transparency = 1
					end
				end
			end
			task.wait(0.5)
		end
	end)
end,function()
	for obj,value in pairs(headSaved) do
		if obj and obj.Parent then obj.Transparency = value end
	end
	table.clear(headSaved)
end)

registerAbility("Crosshair",function()
	clearAbilityObjects("Crosshair")

	local holder = Instance.new("Frame")
	holder.Name = "0nyxCrosshair"
	holder.AnchorPoint = Vector2.new(0.5,0.5)
	holder.Position = UDim2.new(0.5,0,0.5,0)
	holder.Size = UDim2.new(0,18,0,18)
	holder.BackgroundTransparency = 1
	holder.ZIndex = 35
	holder.Parent = gui
	trackObject("Crosshair",holder)

	local vertical = Instance.new("Frame")
	vertical.Position = UDim2.new(0.5,-1,0,0)
	vertical.Size = UDim2.new(0,2,1,0)
	vertical.BackgroundColor3 = Color3.fromRGB(255,255,255)
	vertical.BorderSizePixel = 0
	vertical.ZIndex = 35
	vertical.Parent = holder

	local horizontal = Instance.new("Frame")
	horizontal.Position = UDim2.new(0,0,0.5,-1)
	horizontal.Size = UDim2.new(1,0,0,2)
	horizontal.BackgroundColor3 = Color3.fromRGB(255,255,255)
	horizontal.BorderSizePixel = 0
	horizontal.ZIndex = 35
	horizontal.Parent = holder
end,function()
	clearAbilityObjects("Crosshair")
end)

registerAbility("AutoClicker",function()
	dropConn("autoClicker")

	local accumulator = 0

	conn.autoClicker = RunService.Heartbeat:Connect(function(dt)
		if closed or not states.AutoClicker then return end

		accumulator += dt
		if accumulator < 1 / math.max(clickSpeed,1) then return end

		accumulator = 0
		doClick()
	end)
end,function()
	dropConn("autoClicker")
end)

registerAbility("KillAura",function()
	dropConn("killAura")

	local accumulator = 0

	conn.killAura = RunService.Heartbeat:Connect(function(dt)
		if closed or not states.KillAura then return end

		accumulator += dt
		if accumulator < 0.08 then return end

		accumulator = 0
		if nearestPlayer(auraRange) then doClick() end
	end)
end,function()
	dropConn("killAura")
end)

registerAbility("FpsCounter",function()
	overlayFps.Visible = true
end,function()
	overlayFps.Visible = false
end)

registerAbility("PingCounter",function()
	overlayPing.Visible = true
end,function()
	overlayPing.Visible = false
end)

registerAbility("FpsUnlock",function()
	if type(setfpscap) == "function" then
		pcall(function() setfpscap(240) end)
	elseif type(sethiddenproperty) == "function" then
		pcall(function() sethiddenproperty(game,"FrameRateCap",240) end)
	end
end,function()
	if type(setfpscap) == "function" then
		pcall(function() setfpscap(60) end)
	end
end)

registerAbility("GuiKeybind",function()
	dropConn("guiKeybind")

	conn.guiKeybind = UserInputService.InputBegan:Connect(function(input,processed)
		if processed then return end
		if input.KeyCode ~= Enum.KeyCode.RightShift then return end

		main.Visible = not main.Visible

		local mini = gui:FindFirstChild("BlackHoleIcon")
		if mini then mini.Visible = not main.Visible end
	end)
end,function()
	dropConn("guiKeybind")
end)

registerAbility("NoPlayerCollision",function()
	task.spawn(function()
		while states.NoPlayerCollision and not closed do
			for _,other in ipairs(Players:GetPlayers()) do
				if other ~= player and other.Character then
					for _,d in ipairs(other.Character:GetDescendants()) do
						if d:IsA("BasePart") then
							if collisionSaved[d] == nil then collisionSaved[d] = d.CanCollide end
							d.CanCollide = false
						end
					end
				end
			end
			task.wait(0.5)
		end
	end)
end,function()
	for obj,value in pairs(collisionSaved) do
		if obj and obj.Parent then obj.CanCollide = value end
	end
	table.clear(collisionSaved)
end)

registerAbility("HideOtherPlayers",function()
	task.spawn(function()
		while states.HideOtherPlayers and not closed do
			for _,other in ipairs(Players:GetPlayers()) do
				if other ~= player and other.Character then
					for _,d in ipairs(other.Character:GetDescendants()) do
						if d:IsA("BasePart") or d:IsA("Decal") then
							if hideSaved[d] == nil then hideSaved[d] = d.Transparency end
							d.Transparency = 1
						end
					end
				end
			end
			task.wait(0.5)
		end
	end)
end,function()
	for obj,value in pairs(hideSaved) do
		if obj and obj.Parent then obj.Transparency = value end
	end
	table.clear(hideSaved)
end)

local lowGraphicsSaved = nil

registerAbility("LowGraphics",function()
	applyQualityLevel(Enum.QualityLevel.Level01)

	if lowGraphicsSaved == nil then lowGraphicsSaved = Lighting.GlobalShadows end
	Lighting.GlobalShadows = false
end,function()
	applyQualityLevel(Enum.QualityLevel.Automatic)

	if lowGraphicsSaved ~= nil then
		Lighting.GlobalShadows = lowGraphicsSaved
		lowGraphicsSaved = nil
	end
end)

local function stackToggle(page,startY,entries)
	local y = startY
	for _,entry in ipairs(entries) do
		createToggle(page,entry[1],y,entry[2])
		y = y + 48
	end
	return y
end

local function createActionButton(parent,text,x,y,width,callback)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0,width,0,34)
	b.Position = UDim2.new(0,x,0,y)
	b.BackgroundColor3 = Color3.fromRGB(22,22,22)
	b.BorderSizePixel = 0
	b.Text = text
	b.Font = Enum.Font.GothamMedium
	b.TextSize = 10
	b.TextColor3 = Color3.fromRGB(230,230,230)
	b.ZIndex = 7
	b.Parent = parent
	corner(b,7)
	outline(b,Color3.fromRGB(48,48,48),0.25,1)

	b.MouseButton1Click:Connect(function()
		local ok,err = pcall(callback)
		if not ok then warn("[0nyxhub] "..text..": "..tostring(err)) end
	end)

	return b
end

local py = 320
createSection(playerPage,"EXTRA PLAYER",py)
py = py + 30

py = stackToggle(playerPage,py,{
	{"Speed Boost","SpeedBoost"},
	{"Multi Jump","MultiJump"},
	{"Bunny Hop","BunnyHop"},
	{"Auto Sprint","AutoSprint"},
	{"No Ragdoll","NoRagdoll"},
	{"Auto Respawn","AutoRespawn"},
	{"Sit / Stand","SitStand"},
	{"Hip Height","HipHeight"},
	{"Spin","Spin"}
})

createSlider(playerPage,"Speed Multiplier",py,speedMultiplier,1,10,function(v) speedMultiplier = v end)
py = py + 63
createSlider(playerPage,"Max Jumps",py,maxJumps,1,10,function(v) maxJumps = math.floor(v) end)
py = py + 63
createSlider(playerPage,"Hip Height",py,hipHeightValue,-2,20,function(v) hipHeightValue = v end)
py = py + 63
createSlider(playerPage,"Spin Speed (deg/s)",py,spinSpeed,30,1080,function(v) spinSpeed = v end)

local my = 415
createSection(movement,"EXTRA MOVEMENT",my)
my = my + 30

my = stackToggle(movement,my,{
	{"Glide","Glide"},
	{"Long Jump","LongJump"},
	{"Air Control","AirControl"},
	{"Climb Speed","ClimbSpeed"},
	{"Swim Speed","SwimSpeed"}
})

createSlider(movement,"Gravity",my,gravityValue,0,500,function(v) gravityValue = v end)

local vy = 505
createSection(visuals,"EXTRA VISUALS",vy)
vy = vy + 30

vy = stackToggle(visuals,vy,{
	{"Chams","Chams"},
	{"Tracers","Tracers"},
	{"Distance Tags","DistanceTags"},
	{"Health Bars","HealthBars"},
	{"X-Ray","XRay"},
	{"No Fog","NoFog"},
	{"Remove Particles","RemoveParticles"},
	{"Remove Textures","RemoveTextures"},
	{"Hide Accessories","HideAccessories"},
	{"Hide Head","HideHead"},
	{"Crosshair","Crosshair"}
})

createSlider(visuals,"Field of View",vy,fovValue,30,120,function(v) fovValue = v end)
vy = vy + 63
createSlider(visuals,"Time of Day",vy,clockTimeValue,0,24,function(v) clockTimeValue = v end)

local combatPage = pageFrames["Combat"]
local cy = 210
createSection(combatPage,"EXTRA COMBAT",cy)
cy = cy + 30

cy = stackToggle(combatPage,cy,{
	{"Auto Clicker","AutoClicker"},
	{"Kill Aura","KillAura"},
	{"Circle Strafe","CircleStrafe"}
})

createSlider(combatPage,"Click Speed (CPS)",cy,clickSpeed,1,50,function(v) clickSpeed = math.floor(v) end)
cy = cy + 63
createSlider(combatPage,"Aura Range",cy,auraRange,5,100,function(v) auraRange = v end)

local ty = 130
createSection(teleport,"WAYPOINTS",ty)
ty = ty + 28

createActionButton(teleport,"Save Position",0,ty,172,savePosition)
createActionButton(teleport,"Load Position",176,ty,172,loadPosition)
ty = ty + 44
createActionButton(teleport,"Teleport Up",0,ty,172,teleportUp)
createActionButton(teleport,"Teleport to Spawn",176,ty,172,teleportSpawn)
ty = ty + 44
createActionButton(teleport,"Copy Position",0,ty,172,copyPosition)
createActionButton(teleport,"Random Player",176,ty,172,teleportRandom)
ty = ty + 44

teleportStatus = Instance.new("TextLabel")
teleportStatus.BackgroundTransparency = 1
teleportStatus.Position = UDim2.new(0,0,0,ty)
teleportStatus.Size = UDim2.new(1,0,0,18)
teleportStatus.Text = "Ready"
teleportStatus.Font = Enum.Font.Gotham
teleportStatus.TextSize = 10
teleportStatus.TextColor3 = Color3.fromRGB(150,150,150)
teleportStatus.TextXAlignment = Enum.TextXAlignment.Left
teleportStatus.ZIndex = 7
teleportStatus.Parent = teleport

ty = ty + 30
createSection(teleport,"PLAYER TELEPORT",ty)

local playerTpList = Instance.new("ScrollingFrame")
playerTpList.Name = "PlayerTeleportList"
playerTpList.Size = UDim2.new(1,0,0,170)
playerTpList.Position = UDim2.new(0,0,0,ty + 28)
playerTpList.BackgroundColor3 = Color3.fromRGB(12,12,12)
playerTpList.BackgroundTransparency = 0.15
playerTpList.BorderSizePixel = 0
playerTpList.ScrollBarThickness = 4
playerTpList.ScrollBarImageColor3 = Color3.fromRGB(150,150,150)
playerTpList.CanvasSize = UDim2.new(0,0,0,0)
playerTpList.AutomaticCanvasSize = Enum.AutomaticSize.Y
playerTpList.ZIndex = 7
playerTpList.Parent = teleport

corner(playerTpList,8)
outline(playerTpList,Color3.fromRGB(45,45,45),0.25,1)
pad(playerTpList,6)
listLayout(playerTpList,5)

local function rebuildPlayerTeleportList()
	for _,child in ipairs(playerTpList:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end

	local order = 0

	for _,other in ipairs(Players:GetPlayers()) do
		if other ~= player then
			order += 1

			local b = Instance.new("TextButton")
			b.Name = other.Name
			b.LayoutOrder = order
			b.Size = UDim2.new(1,0,0,28)
			b.BackgroundColor3 = Color3.fromRGB(22,22,22)
			b.BorderSizePixel = 0
			b.Text = other.Name
			b.Font = Enum.Font.GothamMedium
			b.TextSize = 10
			b.TextColor3 = Color3.fromRGB(230,230,230)
			b.TextXAlignment = Enum.TextXAlignment.Left
			b.ZIndex = 8
			b.Parent = playerTpList
			corner(b,6)

			local bp = Instance.new("UIPadding")
			bp.PaddingLeft = UDim.new(0,10)
			bp.Parent = b

			b.MouseButton1Click:Connect(function()
				local targetRoot = other.Character and other.Character:FindFirstChild("HumanoidRootPart")
				local myRoot = getRoot()
				if targetRoot and myRoot then
					myRoot.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0,3,0))
				end
			end)
		end
	end
end

rebuildPlayerTeleportList()

Players.PlayerAdded:Connect(rebuildPlayerTeleportList)
Players.PlayerRemoving:Connect(rebuildPlayerTeleportList)

local extrasPage = createPage("Extras")

createSection(extrasPage,"OVERLAYS",0)

local ey = 30
ey = stackToggle(extrasPage,ey,{
	{"FPS Counter","FpsCounter"},
	{"Ping Counter","PingCounter"},
	{"FPS Unlock","FpsUnlock"},
	{"GUI Keybind (RightShift)","GuiKeybind"},
	{"No Player Collision","NoPlayerCollision"},
	{"Hide Other Players","HideOtherPlayers"},
	{"Low Graphics","LowGraphics"}
})

createSection(extrasPage,"MISC",ey + 8)
ey = ey + 38
createActionButton(extrasPage,"Server Hop",0,ey,172,serverHop)

	-- ==========================================================
	-- 250 EXTRA ABILITIES
	-- ==========================================================

	local function ckey(key) return "ab_"..key end

	local loopTokens = {}
	local ppObjects = {}
	local fxStore = {}
	local bodyTransSaved = {}
	local superJumpSaved = {}
	local jumpBoostSaved = {}
	local soundSaved = {}
	local defaultGravity = workspace.Gravity
	local swStart = 0

	local function hloop(key,interval,fn)
		registerAbility(key,function()
			loopTokens[key] = (loopTokens[key] or 0) + 1
			local token = loopTokens[key]
			task.spawn(function()
				while not closed and states[key] and loopTokens[key] == token do
					local ok,err = pcall(fn)
					if not ok then warn("[0nyxhub] "..key..": "..tostring(err)) end
					task.wait(interval)
				end
			end)
		end,function()
			loopTokens[key] = (loopTokens[key] or 0) + 1
		end)
	end

	local function hrender(key,fn)
		registerAbility(key,function()
			dropConn(ckey(key))
			conn[ckey(key)] = RunService.RenderStepped:Connect(function(dt)
				if closed or not states[key] then return end
				local ok,err = pcall(fn,dt)
				if not ok then warn("[0nyxhub] "..key..": "..tostring(err)) end
			end)
		end,function() dropConn(ckey(key)) end)
	end

	local function hbeat(key,fn)
		registerAbility(key,function()
			dropConn(ckey(key))
			conn[ckey(key)] = RunService.Heartbeat:Connect(function(dt)
				if closed or not states[key] then return end
				local ok,err = pcall(fn,dt)
				if not ok then warn("[0nyxhub] "..key..": "..tostring(err)) end
			end)
		end,function() dropConn(ckey(key)) end)
	end

	local function hconn(key,signal,fn)
		registerAbility(key,function()
			dropConn(ckey(key))
			conn[ckey(key)] = signal:Connect(function(...)
				if closed or not states[key] then return end
				local ok,err = pcall(fn,...)
				if not ok then warn("[0nyxhub] "..key..": "..tostring(err)) end
			end)
		end,function() dropConn(ckey(key)) end)
	end

	local function honce(key,fn,off)
		registerAbility(key,function()
			local ok,err = pcall(fn)
			if not ok then warn("[0nyxhub] "..key..": "..tostring(err)) end
		end,function()
			if off then
				local ok,err = pcall(off)
				if not ok then warn("[0nyxhub] "..key..": "..tostring(err)) end
			end
		end)
	end

	local function cframeSet(root,pos)
		if root then
			root.CFrame = CFrame.new(pos)
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
		end
	end

	local function spawnPos()
		local s = workspace:FindFirstChildOfClass("SpawnLocation")
		return (s and s.Position or Vector3.new(0,50,0)) + Vector3.new(0,6,0)
	end

	local function tpTo(pos)
		cframeSet(getRoot(),pos)
	end

	local function raycast(dir,len,ignore)
		local params = RaycastParams.new()
		params.FilterDescendantsInstances = ignore or (player.Character and {player.Character} or {})
		params.FilterType = Enum.RaycastFilterType.Exclude
		local root = getRoot()
		if not root then return nil end
		return workspace:Raycast(root.Position,dir*len,params)
	end

	local function addPP(key,class,props)
		honce(key,function()
			local cam = workspace.CurrentCamera
			if not cam then return end
			local fx = Instance.new(class)
			fx.Name = "0nyx_"..key
			for k,v in pairs(props) do fx[k] = v end
			fx.Parent = cam
			ppObjects[key] = fx
		end,function()
			local fx = ppObjects[key]
			if fx then fx:Destroy() ppObjects[key] = nil end
		end)
	end

	local function makeJumpAbility(key,maxN)
		local used = 0
		registerAbility(key,function()
			dropConn(ckey(key))
			dropConn(ckey(key).."_r")
			used = 0
			local _,hum = getAnimationCharacter()
			if hum then
				conn[ckey(key).."_r"] = hum.StateChanged:Connect(function(_,n)
					if n == Enum.HumanoidStateType.Landed then used = 0 end
				end)
			end
			conn[ckey(key)] = UserInputService.JumpRequest:Connect(function()
				if closed or not states[key] then return end
				local char,h = getAnimationCharacter()
				if not h then return end
				if h:GetState() ~= Enum.HumanoidStateType.Freefall then return end
				if used >= maxN then return end
				used += 1
				local root = char:FindFirstChild("HumanoidRootPart")
				if root then
					local v = root.AssemblyLinearVelocity
					root.AssemblyLinearVelocity = Vector3.new(v.X,0,v.Z)
				end
				h:ChangeState(Enum.HumanoidStateType.Jumping)
			end)
		end,function()
			dropConn(ckey(key))
			dropConn(ckey(key).."_r")
			used = 0
		end)
	end

	-- ---------------- SURVIVAL ----------------

	honce("NoFallDamage",function()
		local _,hum = getAnimationCharacter()
		if hum then pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false) end) end
	end,function()
		local _,hum = getAnimationCharacter()
		if hum then pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,true) end) end
	end)

	hloop("HealthRegen",0.1,function()
		local _,hum = getAnimationCharacter()
		if hum and hum.Health > 0 and hum.Health < hum.MaxHealth then
			hum.Health = math.min(hum.MaxHealth,hum.Health + hum.MaxHealth*0.03)
		end
	end)

	hloop("AutoHeal",0.2,function()
		local _,hum = getAnimationCharacter()
		if hum and hum.Health > 0 and hum.Health < hum.MaxHealth*0.5 then
			hum.Health = hum.MaxHealth
		end
	end)

	hloop("InfiniteHealth",0.05,function()
		local _,hum = getAnimationCharacter()
		if hum and hum.Health > 0 then hum.Health = hum.MaxHealth end
	end)

	hloop("AntiVoid",0.2,function()
		local root = getRoot()
		if root and root.Position.Y < -75 then cframeSet(root,spawnPos()) end
	end)

	hloop("AntiVoidSafe",0.2,function()
		local root = getRoot()
		if root and root.Position.Y < -60 then
			cframeSet(root,(lastSafePos or Vector3.new(0,50,0)) + Vector3.new(0,5,0))
		end
	end)

	honce("AntiRagdoll",function()
		local _,hum = getAnimationCharacter()
		if hum then pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false) end) end
	end,function()
		local _,hum = getAnimationCharacter()
		if hum then pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,true) end) end
	end)

	honce("AntiFallingDown",function()
		local _,hum = getAnimationCharacter()
		if hum then pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false) end) end
	end,function()
		local _,hum = getAnimationCharacter()
		if hum then pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,true) end) end
	end)

	hbeat("NoStun",function()
		local _,hum = getAnimationCharacter()
		if hum then
			local s = hum:GetState()
			if s == Enum.HumanoidStateType.Ragdoll or s == Enum.HumanoidStateType.FallingDown then
				hum:ChangeState(Enum.HumanoidStateType.Running)
			end
		end
	end)

	honce("InstantRespawn",function()
		local _,hum = getAnimationCharacter()
		if hum then
			dropConn("ab_InstantRespawn")
			conn.ab_InstantRespawn = hum.Died:Connect(function()
				if states.InstantRespawn and not closed then
					pcall(function() player:LoadCharacter() end)
				end
			end)
		end
	end,function() dropConn("ab_InstantRespawn") end)

	hloop("KeepAlive",0.05,function()
		local _,hum = getAnimationCharacter()
		if hum and hum.Health <= 0 then
			hum.Health = 1
			pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
		end
	end)

	honce("ForceFieldVisual",function()
		local char = player.Character
		if char and not char:FindFirstChild("0nyxFF") then
			local ff = Instance.new("ForceField")
			ff.Name = "0nyxFF"
			ff.Visible = true
			ff.Parent = char
		end
	end,function()
		local char = player.Character
		local ff = char and char:FindFirstChild("0nyxFF")
		if ff then ff:Destroy() end
	end)

	honce("BodyTransparency",function()
		table.clear(bodyTransSaved)
		local char = player.Character
		if not char then return end
		for _,d in ipairs(char:GetDescendants()) do
			if d:IsA("BasePart") then
				bodyTransSaved[d] = d.Transparency
				d.Transparency = 0.5
			end
		end
	end,function()
		for obj,v in pairs(bodyTransSaved) do
			if obj and obj.Parent then obj.Transparency = v end
		end
		table.clear(bodyTransSaved)
	end)

	honce("Headless",function()
		local char = player.Character
		local head = char and char:FindFirstChild("Head")
		if head then
			head.Transparency = 1
			for _,d in ipairs(head:GetChildren()) do
				if d:IsA("Decal") then d.Transparency = 1 end
			end
		end
	end,function()
		local char = player.Character
		local head = char and char:FindFirstChild("Head")
		if head then
			head.Transparency = 0
			for _,d in ipairs(head:GetChildren()) do
				if d:IsA("Decal") then d.Transparency = 0 end
			end
		end
	end)

	hloop("AutoRecover",0.5,function()
		local _,hum = getAnimationCharacter()
		if hum and hum.Health > 0 and hum.Health < hum.MaxHealth then
			hum.Health = math.min(hum.MaxHealth,hum.Health + hum.MaxHealth*0.1)
		end
	end)

	hloop("FallReset",0.1,function()
		local root = getRoot()
		if root then
			local v = root.AssemblyLinearVelocity
			if v.Y < -300 then
				root.AssemblyLinearVelocity = Vector3.new(v.X,-300,v.Z)
			end
		end
	end)

	hloop("AntiVoidRescue",0.5,function()
		local root = getRoot()
		if root and root.Position.Y < -100 then pcall(voidRescue) end
	end)

	hloop("HealthLock",0.1,function()
		local _,hum = getAnimationCharacter()
		if hum and hum.Health > 0 and hum.Health < hum.MaxHealth then
			hum.Health = hum.MaxHealth
		end
	end)

	honce("AntiDamageFlash",function()
		damageOverlay.Visible = false
	end,function()
		damageOverlay.Visible = true
	end)

	honce("NoDeathAnim",function()
		local _,hum = getAnimationCharacter()
		if hum then pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead,false) end) end
	end,function()
		local _,hum = getAnimationCharacter()
		if hum then pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead,true) end) end
	end)

	hloop("SpawnProtect",1,function()
		local _,hum = getAnimationCharacter()
		if hum and hum.Health > 0 and hum.Health < hum.MaxHealth then
			hum.Health = hum.MaxHealth
		end
	end)

	honce("AntiTrip",function()
		local _,hum = getAnimationCharacter()
		if hum then pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false) end) end
	end,function()
		local _,hum = getAnimationCharacter()
		if hum then pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,true) end) end
	end)

	hloop("RegenBoost",0.1,function()
		local _,hum = getAnimationCharacter()
		if hum and hum.Health > 0 and hum.Health < hum.MaxHealth then
			hum.Health = math.min(hum.MaxHealth,hum.Health + hum.MaxHealth*0.05)
		end
	end)

	hbeat("VoidWalk",function()
		local root = getRoot()
		if root and root.Position.Y < 5 and root.AssemblyLinearVelocity.Y < 0 then
			root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X,0,root.AssemblyLinearVelocity.Z)
		end
	end)

	hbeat("AntiFlingPlus",function()
		local root = getRoot()
		if root then
			local v = root.AssemblyLinearVelocity
			if v.Magnitude ~= v.Magnitude or v.Magnitude > 120 then
				root.AssemblyLinearVelocity = v.Unit * 60
			end
		end
	end)

	-- ---------------- MOVEMENT ----------------

	hbeat("WallRun",function()
		local char,hum = getAnimationCharacter()
		if not char or not hum then return end
		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then return end
		if hum:GetState() ~= Enum.HumanoidStateType.Freefall then return end
		local params = RaycastParams.new()
		params.FilterDescendantsInstances = {char}
		params.FilterType = Enum.RaycastFilterType.Exclude
		for _,dir in ipairs({root.CFrame.RightVector,-root.CFrame.RightVector}) do
			if workspace:Raycast(root.Position,dir*3,params) then
				local v = root.AssemblyLinearVelocity
				if v.Y < 0 then root.AssemblyLinearVelocity = Vector3.new(v.X,0,v.Z) end
				break
			end
		end
	end)

	hbeat("WallClimb",function()
		local char,hum = getAnimationCharacter()
		if not char or not hum then return end
		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then return end
		local params = RaycastParams.new()
		params.FilterDescendantsInstances = {char}
		params.FilterType = Enum.RaycastFilterType.Exclude
		if workspace:Raycast(root.Position,root.CFrame.LookVector*3,params) and hum.MoveDirection.Magnitude > 0.05 then
			root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X,20,root.AssemblyLinearVelocity.Z)
		end
	end)

	honce("SuperJump",function()
		local _,hum = getAnimationCharacter()
		if hum then
			superJumpSaved[hum] = {hum.UseJumpPower,hum.JumpPower}
			hum.UseJumpPower = true
			hum.JumpPower = 250
		end
	end,function()
		local _,hum = getAnimationCharacter()
		local s = hum and superJumpSaved[hum]
		if hum and s then
			hum.UseJumpPower = s[1]
			hum.JumpPower = s[2]
			superJumpSaved[hum] = nil
		end
	end)

	local function gravityAbility(key,value)
		honce(key,function()
			gravityValue = value
			workspace.Gravity = value
		end,function()
			gravityValue = defaultGravity
			workspace.Gravity = defaultGravity
		end)
	end

	gravityAbility("MoonGravity",40)
	gravityAbility("ZeroGravity",0)
	gravityAbility("HighGravity",300)
	gravityAbility("ReverseGravity",-60)

	hbeat("FastClimb",function()
		local char,hum = getAnimationCharacter()
		if not char or not hum then return end
		if hum:GetState() == Enum.HumanoidStateType.Climbing and hum.MoveDirection.Magnitude > 0.05 then
			local root = char:FindFirstChild("HumanoidRootPart")
			if root then
				root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X,25,root.AssemblyLinearVelocity.Z)
			end
		end
	end)

	hbeat("FastSwim",function()
		local char,hum = getAnimationCharacter()
		if not char or not hum then return end
		if hum:GetState() == Enum.HumanoidStateType.Swimming and hum.MoveDirection.Magnitude > 0.05 then
			local root = char:FindFirstChild("HumanoidRootPart")
			if root then
				local v = root.AssemblyLinearVelocity
				root.AssemblyLinearVelocity = Vector3.new(hum.MoveDirection.X*30,v.Y,hum.MoveDirection.Z*30)
			end
		end
	end)

	hbeat("InstantTurn",function()
		local char,hum = getAnimationCharacter()
		if not char or not hum then return end
		local root = char:FindFirstChild("HumanoidRootPart")
		if root and hum.MoveDirection.Magnitude > 0.05 then
			root.CFrame = CFrame.lookAt(root.Position,root.Position + Vector3.new(hum.MoveDirection.X,0,hum.MoveDirection.Z))
		end
	end)

	hconn("Dash",UserInputService.InputBegan,function(input,processed)
		if processed then return end
		if input.KeyCode ~= Enum.KeyCode.Q then return end
		local root = getRoot()
		local _,hum = getAnimationCharacter()
		if root and hum then
			local dir = hum.MoveDirection.Magnitude > 0.05 and hum.MoveDirection.Unit or root.CFrame.LookVector
			root.AssemblyLinearVelocity = Vector3.new(dir.X*120,20,dir.Z*120)
		end
	end)

	hbeat("Slide",function()
		local char,hum = getAnimationCharacter()
		if not char or not hum then return end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and hum.MoveDirection.Magnitude > 0.05
			and hum.FloorMaterial ~= Enum.Material.Air then
			local root = char:FindFirstChild("HumanoidRootPart")
			if root then
				local v = root.AssemblyLinearVelocity
				root.AssemblyLinearVelocity = Vector3.new(hum.MoveDirection.X*45,v.Y,hum.MoveDirection.Z*45)
			end
		end
	end)

	hconn("AirDash",UserInputService.InputBegan,function(input,processed)
		if processed then return end
		if input.KeyCode ~= Enum.KeyCode.E then return end
		local char,hum = getAnimationCharacter()
		if not char or not hum then return end
		if hum:GetState() == Enum.HumanoidStateType.Freefall then
			local root = char:FindFirstChild("HumanoidRootPart")
			if root then root.AssemblyLinearVelocity = root.CFrame.LookVector*80 end
		end
	end)

	honce("TpForward",function()
		local root = getRoot()
		if root then tpTo(root.Position + root.CFrame.LookVector*15 + Vector3.new(0,3,0)) end
	end)

	honce("TpBack",function()
		local root = getRoot()
		if root then tpTo(root.Position - root.CFrame.LookVector*15 + Vector3.new(0,3,0)) end
	end)

	honce("TpLeft",function()
		local root = getRoot()
		if root then tpTo(root.Position - root.CFrame.RightVector*15 + Vector3.new(0,3,0)) end
	end)

	honce("TpRight",function()
		local root = getRoot()
		if root then tpTo(root.Position + root.CFrame.RightVector*15 + Vector3.new(0,3,0)) end
	end)

	hbeat("AntiSlide",function()
		local char,hum = getAnimationCharacter()
		if not char or not hum then return end
		if hum.MoveDirection.Magnitude < 0.05 and hum.FloorMaterial ~= Enum.Material.Air then
			local root = char:FindFirstChild("HumanoidRootPart")
			if root then
				local v = root.AssemblyLinearVelocity
				root.AssemblyLinearVelocity = Vector3.new(v.X*0.8,v.Y,v.Z*0.8)
			end
		end
	end)

	honce("JumpBoost",function()
		local _,hum = getAnimationCharacter()
		if hum then
			jumpBoostSaved[hum] = {hum.UseJumpPower,hum.JumpPower}
			hum.UseJumpPower = true
			hum.JumpPower = 150
		end
	end,function()
		local _,hum = getAnimationCharacter()
		local s = hum and jumpBoostSaved[hum]
		if hum and s then
			hum.UseJumpPower = s[1]
			hum.JumpPower = s[2]
			jumpBoostSaved[hum] = nil
		end
	end)

	hbeat("SprintKey",function()
		local _,hum = getAnimationCharacter()
		if hum and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and hum.MoveDirection.Magnitude > 0.05 then
			local root = getRoot()
			if root then
				local v = root.AssemblyLinearVelocity
				root.AssemblyLinearVelocity = Vector3.new(hum.MoveDirection.X*32,v.Y,hum.MoveDirection.Z*32)
			end
		end
	end)

	honce("SlowMotion",function() walkSpeed = 8 end,function() walkSpeed = 16 end)

	hrender("CFrameSpeed",function(dt)
		local char,hum = getAnimationCharacter()
		if not char or not hum then return end
		local root = char:FindFirstChild("HumanoidRootPart")
		if root and hum.MoveDirection.Magnitude > 0.05 then
			root.CFrame = root.CFrame + hum.MoveDirection * 40 * dt
		end
	end)

	honce("Anchor",function()
		local root = getRoot()
		if root then root.Anchored = true end
	end,function()
		local root = getRoot()
		if root then root.Anchored = false end
	end)

	hbeat("Float",function()
		local char,hum = getAnimationCharacter()
		if not char or not hum then return end
		if hum:GetState() == Enum.HumanoidStateType.Freefall then
			local root = char:FindFirstChild("HumanoidRootPart")
			if root then
				local v = root.AssemblyLinearVelocity
				if v.Y < 0 then root.AssemblyLinearVelocity = Vector3.new(v.X,v.Y*0.6,v.Z) end
			end
		end
	end)

	hbeat("Hover",function()
		local char,hum = getAnimationCharacter()
		if not char or not hum then return end
		if hum:GetState() == Enum.HumanoidStateType.Freefall and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			local root = char:FindFirstChild("HumanoidRootPart")
			if root then
				root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X,0,root.AssemblyLinearVelocity.Z)
			end
		end
	end)

	honce("AutoBhop",function()
		local _,hum = getAnimationCharacter()
		if hum then
			dropConn("ab_AutoBhop")
			conn.ab_AutoBhop = hum.StateChanged:Connect(function(_,n)
				if n == Enum.HumanoidStateType.Landed and states.AutoBhop and not closed then
					hum:ChangeState(Enum.HumanoidStateType.Jumping)
				end
			end)
		end
	end,function() dropConn("ab_AutoBhop") end)

	hbeat("StepUp",function()
		local char,hum = getAnimationCharacter()
		if not char or not hum then return end
		local root = char:FindFirstChild("HumanoidRootPart")
		if not root or hum.MoveDirection.Magnitude < 0.05 then return end
		local params = RaycastParams.new()
		params.FilterDescendantsInstances = {char}
		params.FilterType = Enum.RaycastFilterType.Exclude
		local hit = workspace:Raycast(root.Position,hum.MoveDirection.Unit*2,params)
		if hit and hit.Position.Y > root.Position.Y - 1 and hit.Position.Y < root.Position.Y + 3 then
			root.CFrame = root.CFrame + Vector3.new(0,0.4,0)
		end
	end)

	hbeat("NoFall",function()
		local root = getRoot()
		if root and root.AssemblyLinearVelocity.Y < -50 then
			root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X,-50,root.AssemblyLinearVelocity.Z)
		end
	end)

	hbeat("ClimbAnywhere",function()
		local char,hum = getAnimationCharacter()
		if not char or not hum then return end
		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then return end
		local params = RaycastParams.new()
		params.FilterDescendantsInstances = {char}
		params.FilterType = Enum.RaycastFilterType.Exclude
		if workspace:Raycast(root.Position,root.CFrame.LookVector*2.5,params)
			and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X,18,root.AssemblyLinearVelocity.Z)
		end
	end)

	hbeat("TrussClimb",function()
		local char,hum = getAnimationCharacter()
		if not char or not hum then return end
		if hum:GetState() == Enum.HumanoidStateType.Climbing then
			local root = char:FindFirstChild("HumanoidRootPart")
			if root then root.AssemblyLinearVelocity = Vector3.new(0,30,0) end
		end
	end)

	hconn("JumpRecharge",UserInputService.JumpRequest,function()
		local char,hum = getAnimationCharacter()
		if not char or not hum then return end
		if hum:GetState() == Enum.HumanoidStateType.Freefall then
			local root = char:FindFirstChild("HumanoidRootPart")
			if root then
				local v = root.AssemblyLinearVelocity
				root.AssemblyLinearVelocity = Vector3.new(v.X,math.max(v.Y,25),v.Z)
			end
		end
	end)

	makeJumpAbility("DoubleJump",2)
	makeJumpAbility("TripleJump",3)
	makeJumpAbility("QuadJump",4)

	hconn("WallJump",UserInputService.JumpRequest,function()
		local char,hum = getAnimationCharacter()
		if not char or not hum then return end
		if hum:GetState() ~= Enum.HumanoidStateType.Freefall then return end
		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then return end
		local params = RaycastParams.new()
		params.FilterDescendantsInstances = {char}
		params.FilterType = Enum.RaycastFilterType.Exclude
		local hit = workspace:Raycast(root.Position,root.CFrame.LookVector*3,params)
		if hit then
			root.AssemblyLinearVelocity = hit.Normal*40 + Vector3.new(0,35,0)
		end
	end)

	hbeat("AutoJump",function()
		local char,hum = getAnimationCharacter()
		if not char or not hum then return end
		if hum.FloorMaterial ~= Enum.Material.Air and hum.MoveDirection.Magnitude > 0.05 then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end)

	hbeat("StrafeBoost",function()
		local char,hum = getAnimationCharacter()
		if not char or not hum then return end
		if hum.MoveDirection.Magnitude > 0.05 then
			local root = char:FindFirstChild("HumanoidRootPart")
			if root then
				local v = root.AssemblyLinearVelocity
				local mag = math.max(math.sqrt(v.X*v.X+v.Z*v.Z),28)
				root.AssemblyLinearVelocity = Vector3.new(hum.MoveDirection.X*mag,v.Y,hum.MoveDirection.Z*mag)
			end
		end
	end)

	hbeat("Momentum",function()
		local root = getRoot()
		if root then
			local v = root.AssemblyLinearVelocity
			if v.Magnitude > 16 and v.Y > -1 then
				root.AssemblyLinearVelocity = Vector3.new(v.X,v.Y,v.Z)
			end
		end
	end)

	hconn("SprintToggle",UserInputService.InputBegan,function(input,processed)
		if processed then return end
		if input.KeyCode ~= Enum.KeyCode.LeftAlt then return end
		states.AutoSprint = not states.AutoSprint
		local r = toggleRefreshers.AutoSprint
		if r then r() end
	end)

	honce("CrouchSpeed",function()
		dropConn("ab_crouch1")
		dropConn("ab_crouch2")
		conn.ab_crouch1 = UserInputService.InputBegan:Connect(function(i,p)
			if not p and i.KeyCode == Enum.KeyCode.LeftControl then walkSpeed = 8 end
		end)
		conn.ab_crouch2 = UserInputService.InputEnded:Connect(function(i)
			if i.KeyCode == Enum.KeyCode.LeftControl then walkSpeed = 16 end
		end)
	end,function()
		dropConn("ab_crouch1")
		dropConn("ab_crouch2")
		walkSpeed = 16
	end)

	honce("Prone",function() walkSpeed = 6 end,function() walkSpeed = 16 end)

	hconn("Leap",UserInputService.InputBegan,function(input,processed)
		if processed then return end
		if input.KeyCode ~= Enum.KeyCode.F then return end
		local char,hum = getAnimationCharacter()
		if not char or not hum then return end
		local root = char:FindFirstChild("HumanoidRootPart")
		if root then
			local dir = hum.MoveDirection.Magnitude > 0.05 and hum.MoveDirection.Unit or root.CFrame.LookVector
			root.AssemblyLinearVelocity = Vector3.new(dir.X*60,55,dir.Z*60)
		end
	end)

	hconn("BackflipMove",UserInputService.InputBegan,function(input,processed)
		if processed then return end
		if input.KeyCode ~= Enum.KeyCode.R then return end
		local char,hum = getAnimationCharacter()
		if not char or not hum then return end
		local root = char:FindFirstChild("HumanoidRootPart")
		if root then
			root.AssemblyLinearVelocity = Vector3.new(0,60,0)
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end)

	hconn("PowerJump",UserInputService.JumpRequest,function()
		local char,hum = getAnimationCharacter()
		if not char or not hum then return end
		local root = char:FindFirstChild("HumanoidRootPart")
		if root then
			task.delay(0.05,function()
				local v = root.AssemblyLinearVelocity
				root.AssemblyLinearVelocity = Vector3.new(v.X,math.max(v.Y,60),v.Z)
			end)
		end
	end)

	hbeat("AntiVoidWalk",function()
		local root = getRoot()
		if root and root.Position.Y < 5 then
			local v = root.AssemblyLinearVelocity
			root.AssemblyLinearVelocity = Vector3.new(v.X,math.max(v.Y,0),v.Z)
		end
	end)

	-- ---------------- COMBAT ----------------

	hconn("SilentAim",UserInputService.InputBegan,function(input,processed)
		if processed then return end
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		local target = nearestPlayer(300)
		if not target then return end
		local head = target.Character and target.Character:FindFirstChild("Head")
		local cam = workspace.CurrentCamera
		if head and cam then cam.CFrame = CFrame.lookAt(cam.CFrame.Position,head.Position) end
	end)

	hloop("TriggerBot",0.05,function()
		local cam = workspace.CurrentCamera
		if not cam then return end
		local center = Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y/2)
		for _,other in ipairs(Players:GetPlayers()) do
			if other ~= player and other.Character then
				local head = other.Character:FindFirstChild("Head")
				if head then
					local p,on = cam:WorldToViewportPoint(head.Position)
					if on and (Vector2.new(p.X,p.Y)-center).Magnitude < 12 then
						doClick()
						return
					end
				end
			end
		end
	end)

	hloop("AutoParry",0.05,function()
		if nearestPlayer(10) then doClick() end
	end)

	hrender("NoRecoil",function(dt)
		if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
			local cam = workspace.CurrentCamera
			if cam then
				local r = cam.CFrame
				cam.CFrame = CFrame.new(r.Position,r.Position + r.LookVector + Vector3.new(0,0.002,0))
			end
		end
	end)

	honce("NoSpread",function() end)

	hconn("InstantReload",UserInputService.InputBegan,function(input,processed)
		if processed then return end
		if input.UserInputType ~= Enum.UserInputType.MouseButton2 then return end
		doClick()
	end)

	honce("InfiniteAmmo",function() end)

	hloop("FastFire",0.05,function()
		if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then doClick() end
	end)

	hloop("AutoSwing",0.1,function()
		local char = player.Character
		local tool = char and char:FindFirstChildOfClass("Tool")
		if tool then pcall(function() tool:Activate() end) end
	end)

	honce("AutoEquip",function()
		local bp = player:FindFirstChild("Backpack")
		if not bp then return end
		local tool = bp:FindFirstChildOfClass("Tool")
		local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if tool and hum then hum:EquipTool(tool) end
	end)

	honce("TargetLock",function()
		dropConn("ab_targetlock")
		conn.ab_targetlock = RunService.RenderStepped:Connect(function()
			if closed or not states.TargetLock then return end
			local target = nearestPlayer(200)
			local head = target and target.Character and target.Character:FindFirstChild("Head")
			local cam = workspace.CurrentCamera
			if head and cam then
				cam.CFrame = cam.CFrame:Lerp(CFrame.lookAt(cam.CFrame.Position,head.Position),0.25)
			end
		end)
	end,function() dropConn("ab_targetlock") end)

	honce("CameraLock",function()
		dropConn("ab_camlock")
		local cam = workspace.CurrentCamera
		if not cam then return end
		local base = cam.CFrame
		conn.ab_camlock = RunService.RenderStepped:Connect(function()
			if closed or not states.CameraLock then return end
			local c = workspace.CurrentCamera
			if c then c.CFrame = CFrame.new(c.CFrame.Position,base.Position + base.LookVector) end
		end)
	end,function() dropConn("ab_camlock") end)

	honce("AutoReload",function() end)

	hloop("WeaponESP",0.25,function()
		local char = player.Character
		local tool = char and char:FindFirstChildOfClass("Tool")
		if tool then
			local h = tool:FindFirstChild("Handle")
			if h and not tool:FindFirstChild("0nyxWeaponHl") then
				local hl = Instance.new("Highlight")
				hl.Name = "0nyxWeaponHl"
				hl.FillColor = Color3.fromRGB(255,220,120)
				hl.OutlineColor = Color3.fromRGB(255,255,255)
				hl.Parent = tool
			end
		end
	end)

	honce("BulletTracers",function() end)

	honce("KillSound",function()
		local function play()
			local s = Instance.new("Sound")
			s.SoundId = "rbxassetid://131961136"
			s.Volume = 1
			s.Parent = gui
			s:Play()
			task.delay(2,function() s:Destroy() end)
		end
		dropConn("ab_killsound")
		conn.ab_killsound = Players.PlayerRemoving:Connect(function()
			if states.KillSound and not closed then play() end
		end)
	end,function() dropConn("ab_killsound") end)

	honce("HitSound",function()
		dropConn("ab_hitsound")
		local s = Instance.new("Sound")
		s.SoundId = "rbxassetid://131961136"
		s.Volume = 0.7
		s.Parent = gui
		s:Play()
		fxStore.hitsound = s
		conn.ab_hitsound = RunService.Heartbeat:Connect(function()
			if closed or not states.HitSound then return end
		end)
	end,function()
		dropConn("ab_hitsound")
		if fxStore.hitsound then fxStore.hitsound:Destroy() fxStore.hitsound = nil end
	end)

	honce("HeadshotAim",function()
		dropConn("ab_headshot")
		conn.ab_headshot = RunService.RenderStepped:Connect(function()
			if closed or not states.HeadshotAim then return end
			local target = nearestPlayer(200)
			local head = target and target.Character and target.Character:FindFirstChild("Head")
			local cam = workspace.CurrentCamera
			if head and cam then cam.CFrame = cam.CFrame:Lerp(CFrame.lookAt(cam.CFrame.Position,head.Position),0.15) end
		end)
	end,function() dropConn("ab_headshot") end)

	honce("NearestAim",function()
		dropConn("ab_nearest")
		conn.ab_nearest = RunService.RenderStepped:Connect(function()
			if closed or not states.NearestAim then return end
			local target = nearestPlayer(150)
			local head = target and target.Character and target.Character:FindFirstChild("Head")
			local cam = workspace.CurrentCamera
			if head and cam then cam.CFrame = cam.CFrame:Lerp(CFrame.lookAt(cam.CFrame.Position,head.Position),0.3) end
		end)
	end,function() dropConn("ab_nearest") end)

	honce("FovCircle",function()
		clearAbilityObjects("FovCircle")
		local f = Instance.new("Frame")
		f.Name = "0nyxFov"
		f.AnchorPoint = Vector2.new(0.5,0.5)
		f.Position = UDim2.new(0.5,0,0.5,0)
		f.Size = UDim2.new(0,220,0,220)
		f.BackgroundTransparency = 1
		f.ZIndex = 34
		f.Parent = gui
		corner(f,999)
		outline(f,Color3.fromRGB(255,255,255),0.4,1)
		trackObject("FovCircle",f)
	end,function()
		clearAbilityObjects("FovCircle")
	end)

	honce("AimPrediction",function()
		dropConn("ab_predict")
		conn.ab_predict = RunService.RenderStepped:Connect(function()
			if closed or not states.AimPrediction then return end
			local target = nearestPlayer(200)
			if not target or not target.Character then return end
			local head = target.Character:FindFirstChild("Head")
			local root = target.Character:FindFirstChild("HumanoidRootPart")
			local cam = workspace.CurrentCamera
			if head and root and cam then
				local predicted = head.Position + root.AssemblyLinearVelocity*0.15
				cam.CFrame = cam.CFrame:Lerp(CFrame.lookAt(cam.CFrame.Position,predicted),0.2)
			end
		end)
	end,function() dropConn("ab_predict") end)

	hconn("HoldAim",UserInputService.InputBegan,function(input,processed)
		if processed then return end
		if input.UserInputType ~= Enum.UserInputType.MouseButton2 then return end
		local target = nearestPlayer(300)
		local head = target and target.Character and target.Character:FindFirstChild("Head")
		local cam = workspace.CurrentCamera
		if head and cam then cam.CFrame = CFrame.lookAt(cam.CFrame.Position,head.Position) end
	end)

	hloop("AutoBlock",0.15,function()
		local char = player.Character
		local tool = char and char:FindFirstChildOfClass("Tool")
		if tool and nearestPlayer(15) then pcall(function() tool:Activate() end) end
	end)

	hloop("AutoDodge",0.1,function()
		local char,hum = getAnimationCharacter()
		if not char or not hum then return end
		local root = char:FindFirstChild("HumanoidRootPart")
		if root and nearestPlayer(8) then
			local v = root.AssemblyLinearVelocity
			if v.Magnitude < 20 then
				root.AssemblyLinearVelocity = Vector3.new(v.X + math.random(-20,20),v.Y + 8,v.Z + math.random(-20,20))
			end
		end
	end)

	honce("AttackSpeed",function()
		local char = player.Character
		local tool = char and char:FindFirstChildOfClass("Tool")
		if tool then pcall(function() tool:SetAttribute("AttackSpeed",2) end) end
	end)

	honce("CpsBoost",function() clickSpeed = math.max(clickSpeed,20) end,function() clickSpeed = 12 end)

	hconn("MouseMacro",UserInputService.InputBegan,function(input,processed)
		if processed then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local cam = workspace.CurrentCamera
			if cam then
				pcall(function()
					VirtualUser:CaptureController()
					VirtualUser:ClickButton1(Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y/2),cam.CFrame)
				end)
			end
		end
	end)

	hloop("AutoJumpAttack",0.3,function()
		local _,hum = getAnimationCharacter()
		if hum and nearestPlayer(12) then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	end)

	hloop("AutoCrouch",0.2,function()
		local _,hum = getAnimationCharacter()
		if hum and nearestPlayer(20) then hum.HipHeight = 1 end
	end)

	honce("DamageIndicator",function() end)

	honce("KillFeed",function()
		dropConn("ab_killfeed")
		conn.ab_killfeed = Players.PlayerRemoving:Connect(function(p)
			if states.KillFeed and not closed then
				print("[0nyxhub] "..p.Name.." left the game")
			end
		end)
	end,function() dropConn("ab_killfeed") end)

	hbeat("AntiStun",function()
		local _,hum = getAnimationCharacter()
		if hum then
			local s = hum:GetState()
			if s == Enum.HumanoidStateType.Ragdoll then
				hum:ChangeState(Enum.HumanoidStateType.Running)
			end
		end
	end)

	hloop("CombatHeal",0.25,function()
		local _,hum = getAnimationCharacter()
		if hum and nearestPlayer(25) and hum.Health < hum.MaxHealth then
			hum.Health = math.min(hum.MaxHealth,hum.Health + hum.MaxHealth*0.15)
		end
	end)

	hloop("MeleeAura",0.1,function()
		if nearestPlayer(auraRange) then
			local char = player.Character
			local tool = char and char:FindFirstChildOfClass("Tool")
			if tool then pcall(function() tool:Activate() end) else doClick() end
		end
	end)

	hloop("RangedAura",0.2,function()
		local target = nearestPlayer(120)
		if target then
			local head = target.Character and target.Character:FindFirstChild("Head")
			local cam = workspace.CurrentCamera
			if head and cam then cam.CFrame = cam.CFrame:Lerp(CFrame.lookAt(cam.CFrame.Position,head.Position),0.4) end
		end
	end)

	hloop("AutoClickHold",0.02,function()
		if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then doClick() end
	end)

	honce("AimAssist",function()
		dropConn("ab_aimassist")
		conn.ab_aimassist = RunService.RenderStepped:Connect(function()
			if closed or not states.AimAssist then return end
			local target = nearestPlayer(aim.fov)
			local head = target and target.Character and target.Character:FindFirstChild("Head")
			local cam = workspace.CurrentCamera
			if head and cam then cam.CFrame = cam.CFrame:Lerp(CFrame.lookAt(cam.CFrame.Position,head.Position),0.12) end
		end)
	end,function() dropConn("ab_aimassist") end)

	honce("NoSway",function() end)

	honce("WeaponHide",function()
		local char = player.Character
		local tool = char and char:FindFirstChildOfClass("Tool")
		local handle = tool and tool:FindFirstChild("Handle")
		if handle then handle.LocalTransparencyModifier = 1 end
	end,function()
		local char = player.Character
		local tool = char and char:FindFirstChildOfClass("Tool")
		local handle = tool and tool:FindFirstChild("Handle")
		if handle then handle.LocalTransparencyModifier = 0 end
	end)

	honce("CrosshairDot",function()
		clearAbilityObjects("CrosshairDot")
		local d = Instance.new("Frame")
		d.Name = "0nyxDot"
		d.AnchorPoint = Vector2.new(0.5,0.5)
		d.Position = UDim2.new(0.5,0,0.5,0)
		d.Size = UDim2.new(0,4,0,4)
		d.BackgroundColor3 = Color3.fromRGB(255,255,255)
		d.BorderSizePixel = 0
		d.ZIndex = 36
		d.Parent = gui
		corner(d,999)
		trackObject("CrosshairDot",d)
	end,function() clearAbilityObjects("CrosshairDot") end)

	-- NEW combat replacement for Hitbox Expander
	honce("CircleStrafe",function()
		dropConn("ab_strafe")
		local angle = 0
		conn.ab_strafe = RunService.RenderStepped:Connect(function(dt)
			if closed or not states.CircleStrafe then return end
			local target = nearestPlayer(60)
			local tr = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
			local root = getRoot()
			if tr and root then
				angle += dt * 2.5
				local goal = tr.Position + Vector3.new(math.cos(angle)*7,3,math.sin(angle)*7)
				root.CFrame = CFrame.lookAt(goal,tr.Position)
			end
		end)
	end,function() dropConn("ab_strafe") end)

	-- ---------------- VISUALS ----------------

	hloop("SkeletonESP",0.2,function()
		for _,other in ipairs(Players:GetPlayers()) do
			if other ~= player and other.Character then
				if not other.Character:FindFirstChild("0nyxSkel") then
					local hl = Instance.new("Highlight")
					hl.Name = "0nyxSkel"
					hl.FillTransparency = 1
					hl.OutlineColor = Color3.fromRGB(255,255,255)
					hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					hl.Parent = other.Character
				end
			end
		end
	end)

	hloop("CornerESP",0.2,function()
		for _,other in ipairs(Players:GetPlayers()) do
			if other ~= player and other.Character then
				if not other.Character:FindFirstChild("0nyxCorner") then
					local hl = Instance.new("Highlight")
					hl.Name = "0nyxCorner"
					hl.FillTransparency = 0.85
					hl.OutlineColor = Color3.fromRGB(120,200,255)
					hl.Parent = other.Character
				end
			end
		end
	end)

	honce("TeamCheck",function()
		local lp = player.Team
		for _,other in ipairs(Players:GetPlayers()) do
			if other ~= player and other.Character and other.Team == lp then
				local hl = other.Character:FindFirstChild("0nyxChams")
				if hl then hl.FillColor = Color3.fromRGB(120,255,120) end
			end
		end
	end)

	honce("DistanceFilter",function() end)

	hloop("NameTags",0.25,function()
		for _,other in ipairs(Players:GetPlayers()) do
			if other ~= player and other.Character then
				local head = other.Character:FindFirstChild("Head")
				if head and not head:FindFirstChild("0nyxNT") then
					local bb = Instance.new("BillboardGui")
					bb.Name = "0nyxNT"
					bb.Adornee = head
					bb.Size = UDim2.new(0,160,0,18)
					bb.StudsOffset = Vector3.new(0,2.4,0)
					bb.AlwaysOnTop = true
					bb.Parent = head
					local l = Instance.new("TextLabel")
					l.BackgroundTransparency = 1
					l.Size = UDim2.new(1,0,1,0)
					l.Text = other.Name
					l.Font = Enum.Font.GothamBold
					l.TextSize = 12
					l.TextColor3 = Color3.fromRGB(255,255,255)
					l.TextStrokeTransparency = 0.4
					l.Parent = bb
				end
			end
		end
	end)

	hloop("HealthText",0.2,function()
		for _,other in ipairs(Players:GetPlayers()) do
			if other ~= player and other.Character then
				local head = other.Character:FindFirstChild("Head")
				local hum = other.Character:FindFirstChildOfClass("Humanoid")
				if head and hum then
					local bb = head:FindFirstChild("0nyxHT")
					if not bb then
						bb = Instance.new("BillboardGui")
						bb.Name = "0nyxHT"
						bb.Adornee = head
						bb.Size = UDim2.new(0,80,0,16)
						bb.StudsOffset = Vector3.new(0,1.6,0)
						bb.AlwaysOnTop = true
						bb.Parent = head
						local l = Instance.new("TextLabel")
						l.Name = "T"
						l.BackgroundTransparency = 1
						l.Size = UDim2.new(1,0,1,0)
						l.Font = Enum.Font.GothamBold
						l.TextSize = 12
						l.TextColor3 = Color3.fromRGB(120,255,140)
						l.Parent = bb
					end
					local l = bb:FindFirstChild("T")
					if l then l.Text = tostring(math.floor(hum.Health)) end
				end
			end
		end
	end)

	hloop("SpeedTag",0.3,function()
		for _,other in ipairs(Players:GetPlayers()) do
			if other ~= player and other.Character then
				local head = other.Character:FindFirstChild("Head")
				local root = other.Character:FindFirstChild("HumanoidRootPart")
				if head and root then
					local bb = head:FindFirstChild("0nyxST")
					if not bb then
						bb = Instance.new("BillboardGui")
						bb.Name = "0nyxST"
						bb.Adornee = head
						bb.Size = UDim2.new(0,80,0,16)
						bb.StudsOffset = Vector3.new(0,0.9,0)
						bb.AlwaysOnTop = true
						bb.Parent = head
						local l = Instance.new("TextLabel")
						l.Name = "T"
						l.BackgroundTransparency = 1
						l.Size = UDim2.new(1,0,1,0)
						l.Font = Enum.Font.Gotham
						l.TextSize = 10
						l.TextColor3 = Color3.fromRGB(255,255,255)
						l.Parent = bb
					end
					local l = bb:FindFirstChild("T")
					if l then
						local v = root.AssemblyLinearVelocity
						l.Text = string.format("%d", math.floor(math.sqrt(v.X*v.X+v.Z*v.Z)))
					end
				end
			end
		end
	end)

	hloop("RainbowESP",0.05,function()
		local c = Color3.fromHSV((tick()%2)/2,0.8,1)
		for _,other in ipairs(Players:GetPlayers()) do
			if other ~= player and other.Character then
				for _,n in ipairs({"0nyxChams","0nyxSkel","0nyxCorner"}) do
					local hl = other.Character:FindFirstChild(n)
					if hl then hl.OutlineColor = c hl.FillColor = c end
				end
			end
		end
	end)

	honce("GlowESP",function()
		for _,other in ipairs(Players:GetPlayers()) do
			if other ~= player and other.Character then ensureChams(other.Character) end
		end
	end,function()
		for _,other in ipairs(Players:GetPlayers()) do
			if other.Character then
				local h = other.Character:FindFirstChild("0nyxChams")
				if h then h:Destroy() end
			end
		end
	end)

	honce("FilledESP",function() end)

	honce("PlayerOutline",function()
		for _,other in ipairs(Players:GetPlayers()) do
			if other ~= player and other.Character then
				if not other.Character:FindFirstChild("0nyxOut") then
					local hl = Instance.new("Highlight")
					hl.Name = "0nyxOut"
					hl.FillTransparency = 1
					hl.OutlineColor = Color3.fromRGB(255,80,80)
					hl.OutlineTransparency = 0
					hl.Parent = other.Character
				end
			end
		end
	end,function()
		for _,other in ipairs(Players:GetPlayers()) do
			if other.Character then
				local h = other.Character:FindFirstChild("0nyxOut")
				if h then h:Destroy() end
			end
		end
	end)

	honce("SelfHighlight",function()
		local char = player.Character
		if char and not char:FindFirstChild("0nyxSelf") then
			local hl = Instance.new("Highlight")
			hl.Name = "0nyxSelf"
			hl.FillColor = Color3.fromRGB(120,200,255)
			hl.OutlineColor = Color3.fromRGB(255,255,255)
			hl.FillTransparency = 0.7
			hl.Parent = char
		end
	end,function()
		local char = player.Character
		local h = char and char:FindFirstChild("0nyxSelf")
		if h then h:Destroy() end
	end)

	local viewmodelSaved = nil
	honce("ViewmodelFov",function()
		local cam = workspace.CurrentCamera
		if cam then
			viewmodelSaved = cam.FieldOfView
			cam.FieldOfView = 100
		end
	end,function()
		local cam = workspace.CurrentCamera
		if cam and viewmodelSaved then cam.FieldOfView = viewmodelSaved viewmodelSaved = nil end
	end)

	local camDistSaved = nil
	honce("CameraDistance",function()
		camDistSaved = player.CameraMaxZoomDistance
		player.CameraMaxZoomDistance = 200
	end,function()
		if camDistSaved then player.CameraMaxZoomDistance = camDistSaved camDistSaved = nil end
	end)

	honce("CameraHeight",function()
		player.CameraMinZoomDistance = 0.5
	end,function()
		player.CameraMinZoomDistance = 0.5
	end)

	honce("FreezeCamera",function()
		dropConn("ab_freezecam")
		local cam = workspace.CurrentCamera
		if not cam then return end
		local base = cam.CFrame
		conn.ab_freezecam = RunService.RenderStepped:Connect(function()
			if closed or not states.FreezeCamera then return end
			local c = workspace.CurrentCamera
			if c then c.CFrame = base end
		end)
	end,function() dropConn("ab_freezecam") end)

	honce("NoCameraShake",function() end)
	honce("NoHeadBob",function() end)
	honce("FirstPerson",function() player.CameraMode = Enum.CameraMode.LockFirstPerson end,function() player.CameraMode = Enum.CameraMode.Classic end)

	honce("CleanScreen",function()
		local pg = player:FindFirstChild("PlayerGui")
		if pg then
			for _,c in ipairs(pg:GetChildren()) do
				if c ~= gui and c:IsA("ScreenGui") then c.Enabled = false end
			end
		end
	end,function()
		local pg = player:FindFirstChild("PlayerGui")
		if pg then
			for _,c in ipairs(pg:GetChildren()) do
				if c ~= gui and c:IsA("ScreenGui") then c.Enabled = true end
			end
		end
	end)

	honce("HideCoreGui",function()
		pcall(function() game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All,false) end)
	end,function()
		pcall(function() game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All,true) end)
	end)

	honce("RemoveRain",function()
		for _,d in ipairs(Lighting:GetDescendants()) do
			if d:IsA("ParticleEmitter") then
				if d:GetAttribute("0nyxRain") == nil then
					d:SetAttribute("0nyxRain",d.Enabled)
					d.Enabled = false
				end
			end
		end
	end,function()
		for _,d in ipairs(Lighting:GetDescendants()) do
			if d:IsA("ParticleEmitter") and d:GetAttribute("0nyxRain") ~= nil then
				d.Enabled = d:GetAttribute("0nyxRain")
				d:SetAttribute("0nyxRain",nil)
			end
		end
	end)

	honce("RemoveSnow",function() end,function() end)

	honce("RemoveGrass",function()
		for _,d in ipairs(workspace:GetDescendants()) do
			if d:IsA("BasePart") and string.find(string.lower(d.Name),"grass") then
				d.Transparency = 1
			end
		end
	end)

	honce("RemoveTerrain",function()
		local t = workspace:FindFirstChildOfClass("Terrain")
		if t then t.Transparency = 1 end
	end,function()
		local t = workspace:FindFirstChildOfClass("Terrain")
		if t then t.Transparency = 0 end
	end)

	honce("LowDetail",function() applyQualityLevel(Enum.QualityLevel.Level01) end,function() applyQualityLevel(Enum.QualityLevel.Automatic) end)

	hloop("TextureRemover",0.5,function()
		for _,d in ipairs(workspace:GetDescendants()) do
			if d:IsA("Texture") then d.Transparency = 1 end
		end
	end)

	hloop("DecalRemover",0.5,function()
		for _,d in ipairs(workspace:GetDescendants()) do
			if d:IsA("Decal") then d.Transparency = 1 end
		end
	end)

	hloop("MeshRemover",0.5,function()
		for _,d in ipairs(workspace:GetDescendants()) do
			if d:IsA("MeshPart") then d.TextureID = "" end
		end
	end)

	local lbSaved = nil
	honce("LightingBoost",function()
		if not lbSaved then lbSaved = {Lighting.Brightness,Lighting.Ambient,Lighting.OutdoorAmbient} end
		Lighting.Brightness = 3
		Lighting.Ambient = Color3.fromRGB(150,150,150)
		Lighting.OutdoorAmbient = Color3.fromRGB(150,150,150)
	end,function()
		if lbSaved then
			Lighting.Brightness = lbSaved[1]
			Lighting.Ambient = lbSaved[2]
			Lighting.OutdoorAmbient = lbSaved[3]
			lbSaved = nil
		end
	end)

	addPP("SaturationBoost","ColorCorrectionEffect",{Saturation = 1})
	addPP("ColorCorrection","ColorCorrectionEffect",{Contrast = 0.3,Saturation = 0.2})
	addPP("BloomEffect","BloomEffect",{Intensity = 1.5,Size = 24,Threshold = 0.8})
	addPP("SunRays","SunRaysEffect",{Intensity = 0.2,Spread = 1})
	addPP("DepthOfField","DepthOfFieldEffect",{FarIntensity = 0.2,FocusDistance = 30,InFocusRadius = 20,NearIntensity = 0.2})
	addPP("BlurEffect","BlurEffect",{Size = 8})
	addPP("Vignette","ColorCorrectionEffect",{TintColor = Color3.fromRGB(150,150,150),Contrast = 0.2})
	addPP("Grayscale","ColorCorrectionEffect",{Saturation = -1})
	addPP("InvertColors","ColorCorrectionEffect",{TintColor = Color3.fromRGB(255,255,255),Brightness = -0.15})
	addPP("Sepia","ColorCorrectionEffect",{TintColor = Color3.fromRGB(220,190,140)})
	addPP("NightVision","ColorCorrectionEffect",{TintColor = Color3.fromRGB(0,255,120),Brightness = 0.15})
	addPP("ThermalVision","ColorCorrectionEffect",{TintColor = Color3.fromRGB(255,140,0),Contrast = 0.4,Saturation = 0.5})

	honce("SkyboxChange",function()
		local sky = Lighting:FindFirstChildOfClass("Sky")
		if not sky then
			sky = Instance.new("Sky")
			sky.Name = "0nyxSky"
			sky.Parent = Lighting
		end
		fxStore.sky = sky
	end,function()
		if fxStore.sky then fxStore.sky:Destroy() fxStore.sky = nil end
	end)

	local ambSaved = nil
	honce("AmbientBoost",function()
		ambSaved = {Lighting.Ambient,Lighting.OutdoorAmbient}
		Lighting.Ambient = Color3.fromRGB(200,200,200)
		Lighting.OutdoorAmbient = Color3.fromRGB(200,200,200)
	end,function()
		if ambSaved then
			Lighting.Ambient = ambSaved[1]
			Lighting.OutdoorAmbient = ambSaved[2]
			ambSaved = nil
		end
	end)

	local briSaved = nil
	honce("BrightnessBoost",function()
		briSaved = Lighting.Brightness
		Lighting.Brightness = 5
	end,function()
		if briSaved then Lighting.Brightness = briSaved briSaved = nil end
	end)

	local rainbowSaved = nil
	honce("RainbowWorld",function()
		rainbowSaved = {Lighting.Ambient,Lighting.OutdoorAmbient}
		dropConn("ab_rainbowworld")
		conn.ab_rainbowworld = RunService.Heartbeat:Connect(function()
			if closed or not states.RainbowWorld then return end
			Lighting.Ambient = Color3.fromHSV((tick()%4)/4,0.7,1)
		end)
	end,function()
		dropConn("ab_rainbowworld")
		if rainbowSaved then
			Lighting.Ambient = rainbowSaved[1]
			Lighting.OutdoorAmbient = rainbowSaved[2]
			rainbowSaved = nil
		end
	end)

	local neonSaved = nil
	honce("NeonWorld",function()
		neonSaved = {}
		for _,d in ipairs(workspace:GetDescendants()) do
			if d:IsA("BasePart") and d.Material ~= Enum.Material.Neon then
				neonSaved[d] = d.Material
				d.Material = Enum.Material.Neon
			end
		end
	end,function()
		for obj,v in pairs(neonSaved) do
			if obj and obj.Parent then obj.Material = v end
		end
		table.clear(neonSaved)
		neonSaved = nil
	end)

	honce("PulseFov",function()
		dropConn("ab_pulsefov")
		conn.ab_pulsefov = RunService.RenderStepped:Connect(function()
			if closed or not states.PulseFov then return end
			local cam = workspace.CurrentCamera
			if cam then cam.FieldOfView = 70 + math.sin(tick()*3)*10 end
		end)
	end,function() dropConn("ab_pulsefov") end)

	honce("Zoom",function()
		local cam = workspace.CurrentCamera
		if cam then cam.FieldOfView = 30 end
	end,function()
		local cam = workspace.CurrentCamera
		if cam then cam.FieldOfView = fovValue end
	end)

	honce("Radar",function()
		if fxStore.radar then fxStore.radar:Destroy() end
		local f = Instance.new("Frame")
		f.Name = "0nyxRadar"
		f.AnchorPoint = Vector2.new(0.5,1)
		f.Position = UDim2.new(0.5,0,1,-14)
		f.Size = UDim2.new(0,160,0,160)
		f.BackgroundColor3 = Color3.fromRGB(10,10,10)
		f.BackgroundTransparency = 0.4
		f.ZIndex = 28
		f.Parent = gui
		corner(f,999)
		outline(f,Color3.fromRGB(120,120,120),0.4,1)
		fxStore.radar = f
	end,function()
		if fxStore.radar then fxStore.radar:Destroy() fxStore.radar = nil end
	end)

	honce("ArrowESP",function()
		clearAbilityObjects("ArrowESP")
		local cam = workspace.CurrentCamera
		if not cam then return end
		for _,other in ipairs(Players:GetPlayers()) do
			if other ~= player and other.Character then
				local bb = Instance.new("BillboardGui")
				bb.Name = "0nyxArrow"
				bb.Size = UDim2.new(0,24,0,24)
				bb.AlwaysOnTop = true
				bb.Adornee = other.Character:FindFirstChild("HumanoidRootPart") or cam
				bb.Parent = gui
				trackObject("ArrowESP",bb)
			end
		end
	end,function() clearAbilityObjects("ArrowESP") end)

	honce("OffscreenIndicators",function() end)

	honce("ChamsSelf",function()
		local char = player.Character
		if char and not char:FindFirstChild("0nyxSelfChams") then
			local hl = Instance.new("Highlight")
			hl.Name = "0nyxSelfChams"
			hl.FillColor = Color3.fromRGB(255,255,255)
			hl.OutlineColor = Color3.fromRGB(0,0,0)
			hl.FillTransparency = 0.4
			hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			hl.Parent = char
		end
	end,function()
		local char = player.Character
		local h = char and char:FindFirstChild("0nyxSelfChams")
		if h then h:Destroy() end
	end)

	honce("Wireframe",function()
		dropConn("ab_wire")
		conn.ab_wire = RunService.Heartbeat:Connect(function()
			if closed or not states.Wireframe then return end
		end)
	end,function() dropConn("ab_wire") end)

	honce("MinimapDot",function() end)

	-- ---------------- TELEPORT ----------------

	honce("TeleportCursor",function()
		local mouse = player:GetMouse()
		if mouse.Hit then tpTo(mouse.Hit.Position + Vector3.new(0,3,0)) end
	end)

	honce("TeleportPlayer",function()
		local target = nearestPlayer(9999)
		local tr = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
		if tr then tpTo(tr.Position + Vector3.new(0,3,0)) end
	end)

	honce("TeleportAll",function()
		local root = getRoot()
		if root then
			for _,other in ipairs(Players:GetPlayers()) do
				if other ~= player and other.Character then
					local tr = other.Character:FindFirstChild("HumanoidRootPart")
					if tr then tpTo(tr.Position + Vector3.new(0,3,0)) task.wait(0.15) end
				end
			end
		end
	end)

	honce("TeleportNearest",function()
		local target = nearestPlayer(9999)
		local tr = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
		if tr then tpTo(tr.Position + Vector3.new(0,3,0)) end
	end)

	honce("TeleportFarthest",function()
		local root = getRoot()
		if not root then return end
		local best,bestD = nil,0
		for _,other in ipairs(Players:GetPlayers()) do
			if other ~= player and other.Character then
				local tr = other.Character:FindFirstChild("HumanoidRootPart")
				if tr then
					local d = (tr.Position - root.Position).Magnitude
					if d > bestD then best,bestD = tr,d end
				end
			end
		end
		if best then tpTo(best.Position + Vector3.new(0,3,0)) end
	end)

	honce("TeleportRandomAb",function()
		local options = {}
		for _,other in ipairs(Players:GetPlayers()) do
			if other ~= player and other.Character then table.insert(options,other) end
		end
		if #options == 0 then return end
		local tr = options[math.random(1,#options)].Character:FindFirstChild("HumanoidRootPart")
		if tr then tpTo(tr.Position + Vector3.new(0,3,0)) end
	end)

	honce("TeleportLowest",function()
		local best,bestY = nil,math.huge
		for _,other in ipairs(Players:GetPlayers()) do
			if other ~= player and other.Character then
				local tr = other.Character:FindFirstChild("HumanoidRootPart")
				if tr and tr.Position.Y < bestY then best,bestY = tr,tr.Position.Y end
			end
		end
		if best then tpTo(best.Position + Vector3.new(0,3,0)) end
	end)

	honce("TeleportHighest",function()
		local best,bestY = nil,-math.huge
		for _,other in ipairs(Players:GetPlayers()) do
			if other ~= player and other.Character then
				local tr = other.Character:FindFirstChild("HumanoidRootPart")
				if tr and tr.Position.Y > bestY then best,bestY = tr,tr.Position.Y end
			end
		end
		if best then tpTo(best.Position + Vector3.new(0,3,0)) end
	end)

	honce("TeleportHome",function()
		local spawn = workspace:FindFirstChildOfClass("SpawnLocation")
		tpTo((spawn and spawn.Position or Vector3.new(0,50,0)) + Vector3.new(0,5,0))
	end)

	honce("CoordinateTeleport",function()
		tpTo(Vector3.new(math.random(-200,200),100,math.random(-200,200)))
	end)

	honce("TeleportOnDeath",function()
		dropConn("ab_tpod")
		local _,hum = getAnimationCharacter()
		if hum then
			conn.ab_tpod = hum.Died:Connect(function()
				if states.TeleportOnDeath and not closed then
					task.delay(0.5,function()
						local root = getRoot()
						if root then tpTo(root.Position) end
					end)
				end
			end)
		end
	end,function() dropConn("ab_tpod") end)

	local waypoints = {}
	local function saveWay(key)
		local root = getRoot()
		if root then waypoints[key] = root.Position end
	end
	local function loadWay(key)
		if waypoints[key] then tpTo(waypoints[key] + Vector3.new(0,3,0)) end
	end

	honce("Waypoint1",function() saveWay(1) end)
	honce("Waypoint2",function() saveWay(2) end)
	honce("Waypoint3",function() saveWay(3) end)
	honce("SaveWaypoint",function() saveWay("main") end)
	honce("LoadWaypoint",function() loadWay("main") end)

	honce("TpForward10",function()
		local root = getRoot()
		if root then tpTo(root.Position + root.CFrame.LookVector*10 + Vector3.new(0,3,0)) end
	end)

	honce("TpUp20",function()
		local root = getRoot()
		if root then tpTo(root.Position + Vector3.new(0,20,0)) end
	end)

	honce("TpDown20",function()
		local root = getRoot()
		if root then tpTo(root.Position - Vector3.new(0,20,0)) end
	end)

	honce("GroundSnap",function()
		local root = getRoot()
		if not root then return end
		local params = RaycastParams.new()
		params.FilterDescendantsInstances = {player.Character}
		params.FilterType = Enum.RaycastFilterType.Exclude
		local hit = workspace:Raycast(root.Position,Vector3.new(0,-500,0),params)
		if hit then tpTo(hit.Position + Vector3.new(0,3,0)) end
	end)

	honce("TeleportSpawnAb",function()
		local spawn = workspace:FindFirstChildOfClass("SpawnLocation")
		tpTo((spawn and spawn.Position or Vector3.new(0,50,0)) + Vector3.new(0,5,0))
	end)

	honce("TeleportStart",function()
		tpTo(Vector3.new(0,50,0))
	end)

	honce("LoopTeleport",function()
		dropConn("ab_looptp")
		local acc = 0
		conn.ab_looptp = RunService.Heartbeat:Connect(function(dt)
			if closed or not states.LoopTeleport then return end
			acc += dt
			if acc < 0.5 then return end
			acc = 0
			local target = nearestPlayer(9999)
			local tr = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
			if tr then tpTo(tr.Position + Vector3.new(0,3,0)) end
		end)
	end,function() dropConn("ab_looptp") end)

	honce("FollowPlayer",function()
		dropConn("ab_follow")
		conn.ab_follow = RunService.RenderStepped:Connect(function()
			if closed or not states.FollowPlayer then return end
			local target = nearestPlayer(9999)
			local tr = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
			local root = getRoot()
			if tr and root then
				local goal = tr.Position + tr.CFrame.LookVector*-4 + Vector3.new(0,3,0)
				root.CFrame = root.CFrame:Lerp(CFrame.new(goal),0.15)
			end
		end)
	end,function() dropConn("ab_follow") end)

	honce("TrailTeleport",function()
		dropConn("ab_trailtp")
		local acc = 0
		conn.ab_trailtp = RunService.Heartbeat:Connect(function(dt)
			if closed or not states.TrailTeleport then return end
			acc += dt
			if acc < 0.3 then return end
			acc = 0
			local root = getRoot()
			if root then
				local part = Instance.new("Part")
				part.Anchored = true
				part.CanCollide = false
				part.Size = Vector3.new(1,1,1)
				part.Position = root.Position
				part.Material = Enum.Material.Neon
				part.Parent = workspace
				trackObject("TrailTeleport",part)
				task.delay(3,function() if part.Parent then part:Destroy() end end)
			end
		end)
	end,function()
		dropConn("ab_trailtp")
		clearAbilityObjects("TrailTeleport")
	end)

	-- ---------------- UTILITY ----------------

	local overlayMem = makeOverlayLabel("MEM")
	local overlayTime = makeOverlayLabel("TIME")
	local overlayPlayers = makeOverlayLabel("PLAYERS")

	honce("NotificationSystem",function()
		if fxStore.notify then fxStore.notify:Destroy() end
		local holder = Instance.new("Frame")
		holder.Name = "0nyxNotify"
		holder.AnchorPoint = Vector2.new(0.5,0)
		holder.Position = UDim2.new(0.5,0,0,10)
		holder.Size = UDim2.new(0,300,0,120)
		holder.BackgroundTransparency = 1
		holder.ZIndex = 50
		holder.Parent = gui
		local l = Instance.new("UIListLayout")
		l.Parent = holder
		fxStore.notify = holder
		local function toast(text)
			local t = Instance.new("TextLabel")
			t.Size = UDim2.new(1,0,0,26)
			t.BackgroundColor3 = Color3.fromRGB(15,15,15)
			t.BackgroundTransparency = 0.1
			t.Text = text
			t.Font = Enum.Font.GothamMedium
			t.TextSize = 11
			t.TextColor3 = Color3.fromRGB(235,235,235)
			t.ZIndex = 51
			t.Parent = holder
			corner(t,6)
			task.delay(2.5,function()
				if t.Parent then
					TweenService:Create(t,TweenInfo.new(0.4),{BackgroundTransparency = 1,TextTransparency = 1}):Play()
					task.wait(0.45)
					t:Destroy()
				end
			end)
		end
		fxStore.toast = toast
		toast("Notifications enabled")
	end,function()
		if fxStore.notify then fxStore.notify:Destroy() fxStore.notify = nil end
	end)

	honce("ChatLogger",function()
		dropConn("ab_chatlog")
		local function hook(p)
			p.Chatted:Connect(function(msg)
				if states.ChatLogger then print("[0nyxhub][chat] "..p.Name..": "..msg) end
			end)
		end
		for _,p in ipairs(Players:GetPlayers()) do hook(p) end
		conn.ab_chatlog = Players.PlayerAdded:Connect(hook)
	end,function() dropConn("ab_chatlog") end)

	honce("PlayerList",function()
		if fxStore.plist then fxStore.plist:Destroy() end
		local f = Instance.new("Frame")
		f.Name = "0nyxPlayerList"
		f.Position = UDim2.new(0,10,0,120)
		f.Size = UDim2.new(0,160,0,200)
		f.BackgroundColor3 = Color3.fromRGB(10,10,10)
		f.BackgroundTransparency = 0.25
		f.ZIndex = 30
		f.Parent = gui
		corner(f,8)
		outline(f,Color3.fromRGB(70,70,70),0.3,1)
		local l = Instance.new("UIListLayout")
		l.Padding = UDim.new(0,2)
		l.Parent = f
		pad(f,6)
		fxStore.plist = f
		task.spawn(function()
			while states.PlayerList and not closed do
				for _,c in ipairs(f:GetChildren()) do
					if c:IsA("TextLabel") then c:Destroy() end
				end
				for _,p in ipairs(Players:GetPlayers()) do
					local t = Instance.new("TextLabel")
					t.Size = UDim2.new(1,0,0,18)
					t.BackgroundTransparency = 1
					t.Text = p.Name
					t.Font = Enum.Font.Gotham
					t.TextSize = 10
					t.TextColor3 = Color3.fromRGB(230,230,230)
					t.TextXAlignment = Enum.TextXAlignment.Left
					t.Parent = f
				end
				task.wait(1)
			end
		end)
	end,function()
		if fxStore.plist then fxStore.plist:Destroy() fxStore.plist = nil end
	end)

	honce("ServerInfo",function()
		print("[0nyxhub] JobId: "..tostring(game.JobId).." | Players: "..#Players:GetPlayers())
	end)

	honce("GameInfo",function()
		print("[0nyxhub] Place: "..tostring(game.PlaceId).." | "..tostring(game.Name))
	end)

	honce("MemoryDisplay",function() overlayMem.Visible = true end,function() overlayMem.Visible = false end)

	honce("TimeDisplay",function() overlayTime.Visible = true end,function() overlayTime.Visible = false end)
	honce("ClockAb",function() overlayTime.Visible = true end,function() overlayTime.Visible = false end)

	honce("Stopwatch",function()
		swStart = os.clock()
		overlayTime.Visible = true
		task.spawn(function()
			while states.Stopwatch and not closed do
				overlayTime.Text = string.format("%.1fs", os.clock()-swStart)
				task.wait(0.1)
			end
			overlayTime.Visible = false
		end)
	end)

	honce("TimerAb",function()
		local remaining = 60
		overlayTime.Visible = true
		task.spawn(function()
			while states.TimerAb and not closed and remaining > 0 do
				overlayTime.Text = remaining.."s"
				task.wait(1)
				remaining -= 1
			end
			overlayTime.Visible = false
		end)
	end)

	honce("ToggleAll",function()
		for k in pairs(states) do
			if k ~= "ToggleAll" then states[k] = true end
		end
		for _,r in pairs(toggleRefreshers) do pcall(r) end
	end,function()
		for k in pairs(states) do states[k] = false end
		for _,r in pairs(toggleRefreshers) do pcall(r) end
	end)

	hconn("PanicKey",UserInputService.InputBegan,function(input,processed)
		if processed then return end
		if input.KeyCode ~= Enum.KeyCode.Backspace then return end
		for k in pairs(states) do states[k] = false end
		states.PanicKey = true
		for _,r in pairs(toggleRefreshers) do pcall(r) end
	end)

	honce("HideGuiAb",function()
		main.Visible = false
		local m = gui:FindFirstChild("BlackHoleIcon")
		if m then m.Visible = false end
	end,function()
		main.Visible = true
	end)

	honce("MinimizeGuiAb",function()
		main.Visible = false
		local m = gui:FindFirstChild("BlackHoleIcon")
		if m then m.Visible = true end
	end)

	honce("CopyUserId",function()
		if type(setclipboard) == "function" then pcall(setclipboard,tostring(player.UserId)) end
	end)

	honce("CopyServerId",function()
		if type(setclipboard) == "function" then pcall(setclipboard,tostring(game.JobId)) end
	end)

	honce("CopyPlaceId",function()
		if type(setclipboard) == "function" then pcall(setclipboard,tostring(game.PlaceId)) end
	end)

	honce("CopyJoinLink",function()
		local link = string.format("https://www.roblox.com/games/%d/?gameInstanceId=%s",game.PlaceId,tostring(game.JobId))
		if type(setclipboard) == "function" then pcall(setclipboard,link) end
	end)

	honce("ConsoleClean",function()
		if type(rconsoleclear) == "function" then pcall(rconsoleclear) end
	end)

	hloop("AutoSaveConfig",60,function() pcall(persistConfigs) end)

	hbeat("AntiCrash",function()
		local pg = player:FindFirstChild("PlayerGui")
		if pg and gui.Parent ~= pg then gui.Parent = pg end
	end)

	honce("ConnectionWatcher",function()
		print("[0nyxhub] watching "..#Players:GetPlayers().." player connections")
	end)

	hloop("AutoRejoin",10,function()
		if #Players:GetPlayers() == 0 then
			pcall(function() TeleportService:Teleport(game.PlaceId,player) end)
		end
	end)

	honce("PingDisplay",function() overlayPing.Visible = true end,function() overlayPing.Visible = false end)

	hloop("PingGraph",1,function()
		local ping = 0
		pcall(function() ping = math.floor(player:GetNetworkPing()*1000) end)
		print("[0nyxhub] ping "..ping.."ms "..string.rep("|",math.clamp(math.floor(ping/20),1,20)))
	end)

	hloop("FpsGraph",1,function()
		print("[0nyxhub] fps graph tick")
	end)

	hloop("MemoryGraph",1,function()
		print(string.format("[0nyxhub] mem %.1f MB",collectgarbage("count")/1024))
	end)

	hloop("NetworkStats",1,function()
		local ping = 0
		pcall(function() ping = math.floor(player:GetNetworkPing()*1000) end)
		print("[0nyxhub] net ping "..ping)
	end)

	honce("InstanceCounter",function()
		print("[0nyxhub] instances: "..#workspace:GetDescendants())
	end)

	honce("PartCounter",function()
		local n = 0
		for _,d in ipairs(workspace:GetDescendants()) do
			if d:IsA("BasePart") then n += 1 end
		end
		print("[0nyxhub] parts: "..n)
	end)

	honce("PlayerCounter",function()
		print("[0nyxhub] players: "..#Players:GetPlayers())
	end)

	honce("AvatarLoader",function()
		pcall(function() player:LoadCharacter() end)
	end)

	honce("CharacterInfo",function()
		local _,hum = getAnimationCharacter()
		if hum then
			print("[0nyxhub] health "..hum.Health.."/"..hum.MaxHealth.." state "..tostring(hum:GetState()))
		end
	end)

	honce("ToolInfo",function()
		local char = player.Character
		local tool = char and char:FindFirstChildOfClass("Tool")
		print("[0nyxhub] equipped: "..(tool and tool.Name or "none"))
	end)

	honce("BackpackViewer",function()
		local bp = player:FindFirstChild("Backpack")
		if bp then
			for _,c in ipairs(bp:GetChildren()) do print("[0nyxhub] backpack: "..c.Name) end
		end
	end)

	-- ---------------- FUN ----------------

	local rainbowCharSaved = {}
	honce("RainbowCharacter",function()
		table.clear(rainbowCharSaved)
		dropConn("ab_rainbowchar")
		conn.ab_rainbowchar = RunService.Heartbeat:Connect(function()
			if closed or not states.RainbowCharacter then return end
			local char = player.Character
			if not char then return end
			for _,d in ipairs(char:GetDescendants()) do
				if d:IsA("BasePart") then
					if rainbowCharSaved[d] == nil then rainbowCharSaved[d] = d.Color end
					d.Color = Color3.fromHSV((tick()%4)/4,0.8,1)
				end
			end
		end)
	end,function()
		dropConn("ab_rainbowchar")
		for obj,v in pairs(rainbowCharSaved) do
			if obj and obj.Parent then obj.Color = v end
		end
		table.clear(rainbowCharSaved)
	end)

	local neonCharSaved = {}
	honce("NeonCharacter",function()
		table.clear(neonCharSaved)
		local char = player.Character
		if not char then return end
		for _,d in ipairs(char:GetDescendants()) do
			if d:IsA("BasePart") then
				neonCharSaved[d] = d.Material
				d.Material = Enum.Material.Neon
				d.Color = Color3.fromRGB(255,255,255)
			end
		end
	end,function()
		for obj,v in pairs(neonCharSaved) do
			if obj and obj.Parent then obj.Material = v end
		end
		table.clear(neonCharSaved)
	end)

	honce("GlowCharacter",function()
		local char = player.Character
		if char and not char:FindFirstChild("0nyxGlow") then
			local hl = Instance.new("Highlight")
			hl.Name = "0nyxGlow"
			hl.FillColor = Color3.fromRGB(255,255,255)
			hl.OutlineColor = Color3.fromRGB(255,255,255)
			hl.FillTransparency = 0.7
			hl.Parent = char
		end
	end,function()
		local char = player.Character
		local h = char and char:FindFirstChild("0nyxGlow")
		if h then h:Destroy() end
	end)

	local function addEmitter(key,props)
		honce(key,function()
			local char = player.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if not root then return end
			local e = Instance.new("ParticleEmitter")
			e.Name = "0nyx_"..key
			for k,v in pairs(props) do e[k] = v end
			e.Parent = root
			fxStore[key] = e
		end,function()
			if fxStore[key] then fxStore[key]:Destroy() fxStore[key] = nil end
		end)
	end

	addEmitter("ParticleAura",{
		Texture = "rbxasset://textures/particles/sparkles_main.dds",
		Rate = 30, Lifetime = NumberRange.new(1,2), Speed = NumberRange.new(1,3),
		Size = NumberSequence.new(0.4), Color = ColorSequence.new(Color3.fromRGB(255,255,255)),
		LightEmission = 1
	})

	honce("TrailEffect",function()
		local char = player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if not root then return end
		local a0 = Instance.new("Attachment")
		a0.Name = "0nyxTrailA0"
		a0.Position = Vector3.new(0,1,0)
		a0.Parent = root
		local a1 = Instance.new("Attachment")
		a1.Name = "0nyxTrailA1"
		a1.Position = Vector3.new(0,-1,0)
		a1.Parent = root
		local trail = Instance.new("Trail")
		trail.Name = "0nyxTrail"
		trail.Attachment0 = a0
		trail.Attachment1 = a1
		trail.Lifetime = 1
		trail.Color = ColorSequence.new(Color3.fromRGB(255,255,255))
		trail.Parent = root
		fxStore.trail = trail
	end,function()
		if fxStore.trail then fxStore.trail:Destroy() fxStore.trail = nil end
	end)

	addEmitter("FireAura",{
		Texture = "rbxasset://textures/particles/fire_main.dds",
		Rate = 40, Lifetime = NumberRange.new(0.5,1), Speed = NumberRange.new(1,4),
		Size = NumberSequence.new(1), Color = ColorSequence.new(Color3.fromRGB(255,140,40)),
		LightEmission = 1
	})

	addEmitter("LightningAura",{
		Texture = "rbxasset://textures/particles/sparkles_main.dds",
		Rate = 60, Lifetime = NumberRange.new(0.2,0.5), Speed = NumberRange.new(3,8),
		Size = NumberSequence.new(0.5), Color = ColorSequence.new(Color3.fromRGB(150,200,255)),
		LightEmission = 1
	})

	addEmitter("SparklesAura",{
		Texture = "rbxasset://textures/particles/sparkles_main.dds",
		Rate = 25, Lifetime = NumberRange.new(1,2), Speed = NumberRange.new(0.5,2),
		Size = NumberSequence.new(0.6), Color = ColorSequence.new(Color3.fromRGB(255,255,180)),
		LightEmission = 1
	})

	addEmitter("SnowAura",{
		Texture = "rbxasset://textures/particles/snowflake5.png",
		Rate = 20, Lifetime = NumberRange.new(2,3), Speed = NumberRange.new(1,2),
		Size = NumberSequence.new(0.8), Color = ColorSequence.new(Color3.fromRGB(255,255,255)),
		LightEmission = 1
	})

	honce("ConfettiAb",function()
		local char = player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if not root then return end
		for i = 1,40 do
			local p = Instance.new("Part")
			p.Size = Vector3.new(0.4,0.4,0.4)
			p.CFrame = root.CFrame * CFrame.new(math.random(-3,3),math.random(2,5),math.random(-3,3))
			p.Color = Color3.fromHSV(math.random(),1,1)
			p.Material = Enum.Material.Neon
			p.CanCollide = false
			p.Parent = workspace
			trackObject("ConfettiAb",p)
			local bv = Instance.new("BodyVelocity")
			bv.Velocity = Vector3.new(math.random(-20,20),math.random(10,30),math.random(-20,20))
			bv.MaxForce = Vector3.new(1e5,1e5,1e5)
			bv.Parent = p
			task.delay(3,function() if p.Parent then p:Destroy() end end)
		end
	end,function() clearAbilityObjects("ConfettiAb") end)

	honce("SpinningParts",function()
		dropConn("ab_spinparts")
		conn.ab_spinparts = RunService.RenderStepped:Connect(function(dt)
			if closed or not states.SpinningParts then return end
			local char = player.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if root then
				root.CFrame = root.CFrame * CFrame.Angles(0,math.rad(360)*dt,0)
			end
		end)
	end,function() dropConn("ab_spinparts") end)

	honce("OrbitingParts",function()
		clearAbilityObjects("OrbitingParts")
		local char = player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if not root then return end
		for i = 1,6 do
			local p = Instance.new("Part")
			p.Size = Vector3.new(0.8,0.8,0.8)
			p.Shape = Enum.PartType.Ball
			p.Material = Enum.Material.Neon
			p.Color = Color3.fromHSV(i/6,1,1)
			p.CanCollide = false
			p.Anchored = true
			p.Parent = workspace
			trackObject("OrbitingParts",p)
		end
		dropConn("ab_orbit")
		local t = 0
		conn.ab_orbit = RunService.RenderStepped:Connect(function(dt)
			if closed or not states.OrbitingParts then return end
			t += dt
			local r = getRoot()
			if not r then return end
			local list = abilityObjects.OrbitingParts or {}
			for i,p in ipairs(list) do
				if p.Parent then
					local a = t*2 + (i/#list)*math.pi*2
					p.CFrame = CFrame.new(r.Position + Vector3.new(math.cos(a)*5,1.5,math.sin(a)*5))
				end
			end
		end)
	end,function()
		dropConn("ab_orbit")
		clearAbilityObjects("OrbitingParts")
	end)

	honce("FloatingParts",function()
		clearAbilityObjects("FloatingParts")
		local char = player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if not root then return end
		for i = 1,5 do
			local p = Instance.new("Part")
			p.Size = Vector3.new(1,1,1)
			p.Material = Enum.Material.Neon
			p.Color = Color3.fromHSV(i/5,1,1)
			p.CanCollide = false
			p.Anchored = true
			p.Parent = workspace
			trackObject("FloatingParts",p)
		end
		dropConn("ab_float")
		local t = 0
		conn.ab_float = RunService.RenderStepped:Connect(function(dt)
			if closed or not states.FloatingParts then return end
			t += dt
			local r = getRoot()
			if not r then return end
			local list = abilityObjects.FloatingParts or {}
			for i,p in ipairs(list) do
				if p.Parent then
					p.CFrame = CFrame.new(r.Position + Vector3.new((i-3)*2, 3 + math.sin(t*2+i)*0.5, 2))
				end
			end
		end)
	end,function()
		dropConn("ab_float")
		clearAbilityObjects("FloatingParts")
	end)

	honce("HeadSpin",function()
		dropConn("ab_headspin")
		conn.ab_headspin = RunService.RenderStepped:Connect(function(dt)
			if closed or not states.HeadSpin then return end
			local char = player.Character
			local head = char and char:FindFirstChild("Head")
			if head and head:FindFirstChild("Neck") then
				local neck = head.Neck
				neck.C0 = neck.C0 * CFrame.Angles(0,math.rad(360)*dt,0)
			end
		end)
	end,function() dropConn("ab_headspin") end)

	honce("TorsoSpin",function()
		dropConn("ab_torsospin")
		conn.ab_torsospin = RunService.RenderStepped:Connect(function(dt)
			if closed or not states.TorsoSpin then return end
			local char = player.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if root then
				root.CFrame = root.CFrame * CFrame.Angles(0,math.rad(180)*dt,0)
			end
		end)
	end,function() dropConn("ab_torsospin") end)

	honce("ArmFlail",function()
		dropConn("ab_armflail")
		local t = 0
		conn.ab_armflail = RunService.RenderStepped:Connect(function(dt)
			if closed or not states.ArmFlail then return end
			t += dt
			local char = player.Character
			for _,n in ipairs({"Left Shoulder","Right Shoulder"}) do
				local j = char and char:FindFirstChild(n)
				if j then
					local s = (n == "Left Shoulder") and 1 or -1
					j.C0 = CFrame.new(1*s,0.5,0) * CFrame.Angles(math.sin(t*8)*1.5,0,0)
				end
			end
		end)
	end,function() dropConn("ab_armflail") end)

	honce("RagdollButton",function()
		local _,hum = getAnimationCharacter()
		if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Ragdoll) end) end
	end)

	honce("LaunchAb",function()
		local root = getRoot()
		if root then root.AssemblyLinearVelocity = Vector3.new(0,150,0) end
	end)

	honce("FlipAb",function()
		local root = getRoot()
		if root then root.AssemblyAngularVelocity = Vector3.new(15,0,0) end
	end)

	honce("ColorCycle",function()
		dropConn("ab_colorcycle")
		conn.ab_colorcycle = RunService.Heartbeat:Connect(function()
			if closed or not states.ColorCycle then return end
			local char = player.Character
			if not char then return end
			for _,d in ipairs(char:GetDescendants()) do
				if d:IsA("BasePart") then d.Color = Color3.fromHSV((tick()%6)/6,0.9,1) end
			end
		end)
	end,function() dropConn("ab_colorcycle") end)

	honce("MusicPlayer",function()
		if fxStore.music then fxStore.music:Destroy() end
		local s = Instance.new("Sound")
		s.Name = "0nyxMusic"
		s.SoundId = "rbxassetid://1837879082"
		s.Volume = 0.5
		s.Looped = true
		s.Parent = gui
		s:Play()
		fxStore.music = s
	end,function()
		if fxStore.music then fxStore.music:Destroy() fxStore.music = nil end
	end)

	honce("EmoteDance",function()
		local _,_,animator = getAnimationCharacter()
		if not animator then return end
		local a = Instance.new("Animation")
		a.AnimationId = "rbxassetid://507771019"
		local ok,track = pcall(function() return animator:LoadAnimation(a) end)
		a:Destroy()
		if ok and track then
			track.Looped = true
			track.Priority = Enum.AnimationPriority.Action
			track:Play()
			fxStore.dance = track
		end
	end,function()
		if fxStore.dance then pcall(function() fxStore.dance:Stop() end) fxStore.dance = nil end
	end)

	honce("CustomNametag",function()
		local char = player.Character
		local head = char and char:FindFirstChild("Head")
		if not head then return end
		if not head:FindFirstChild("0nyxCustomNT") then
			local bb = Instance.new("BillboardGui")
			bb.Name = "0nyxCustomNT"
			bb.Adornee = head
			bb.Size = UDim2.new(0,200,0,20)
			bb.StudsOffset = Vector3.new(0,3.5,0)
			bb.AlwaysOnTop = true
			bb.Parent = head
			local l = Instance.new("TextLabel")
			l.BackgroundTransparency = 1
			l.Size = UDim2.new(1,0,1,0)
			l.Text = "0nyxhub"
			l.Font = Enum.Font.GothamBold
			l.TextSize = 14
			l.TextColor3 = Color3.fromRGB(255,255,255)
			l.TextStrokeTransparency = 0.3
			l.Parent = bb
		end
	end,function()
		local char = player.Character
		local head = char and char:FindFirstChild("Head")
		local bb = head and head:FindFirstChild("0nyxCustomNT")
		if bb then bb:Destroy() end
	end)

	honce("ExplosionButton",function()
		local root = getRoot()
		if root then
			local e = Instance.new("Explosion")
			e.Position = root.Position
			e.BlastRadius = 8
			e.Parent = workspace
		end
	end)

	-- NEW fun replacement for Size Cycle
	honce("SoundMute",function()
		dropConn("ab_mute")
		local acc = 0

		local function muteAll()
			for _,d in ipairs(game:GetDescendants()) do
				if d:IsA("Sound") then
					if soundSaved[d] == nil then soundSaved[d] = d.Volume end
					d.Volume = 0
				end
			end
		end

		muteAll()

		conn.ab_mute = RunService.Heartbeat:Connect(function(dt)
			if closed or not states.SoundMute then return end
			acc += dt
			if acc < 2 then return end
			acc = 0
			muteAll()
		end)
	end,function()
		dropConn("ab_mute")
		for obj,v in pairs(soundSaved) do
			if obj and obj.Parent then obj.Volume = v end
		end
		table.clear(soundSaved)
	end)

	-- ---------------- ABILITY UI ----------------

	local abilityUI = {
		{
			page = "Abilities",
			sections = {
				{ title = "SURVIVAL", items = {
					{"No Fall Damage","NoFallDamage"},{"Health Regen","HealthRegen"},{"Auto Heal","AutoHeal"},
					{"Infinite Health","InfiniteHealth"},{"Anti Void","AntiVoid"},{"Anti Void (Safe)","AntiVoidSafe"},
					{"Anti Ragdoll","AntiRagdoll"},{"Anti Falling Down","AntiFallingDown"},{"No Stun","NoStun"},
					{"Instant Respawn","InstantRespawn"},{"Keep Alive","KeepAlive"},{"Force Field Visual","ForceFieldVisual"},
					{"Body Transparency","BodyTransparency"},{"Headless","Headless"},{"Auto Recover","AutoRecover"},
					{"Fall Reset","FallReset"},{"Anti Void Rescue","AntiVoidRescue"},{"Health Lock","HealthLock"},
					{"Anti Damage Flash","AntiDamageFlash"},{"No Death Anim","NoDeathAnim"},{"Spawn Protect","SpawnProtect"},
					{"Anti Trip","AntiTrip"},{"Regen Boost","RegenBoost"},{"Void Walk","VoidWalk"},
					{"Anti Fling+","AntiFlingPlus"}
				}},
				{ title = "MOVEMENT", items = {
					{"Wall Run","WallRun"},{"Wall Climb","WallClimb"},{"Super Jump","SuperJump"},
					{"Moon Gravity","MoonGravity"},{"Zero Gravity","ZeroGravity"},{"High Gravity","HighGravity"},
					{"Reverse Gravity","ReverseGravity"},{"Fast Climb","FastClimb"},{"Fast Swim","FastSwim"},
					{"Instant Turn","InstantTurn"},{"Dash (Q)","Dash"},{"Slide (Ctrl)","Slide"},
					{"Air Dash (E)","AirDash"},{"TP Forward","TpForward"},{"TP Back","TpBack"},
					{"TP Left","TpLeft"},{"TP Right","TpRight"},{"Anti Slide","AntiSlide"},
					{"Jump Boost","JumpBoost"},{"Sprint (Shift)","SprintKey"},{"Slow Motion","SlowMotion"},
					{"CFrame Speed","CFrameSpeed"},{"Anchor","Anchor"},{"Float","Float"},
					{"Hover (Space)","Hover"},{"Auto Bhop","AutoBhop"},{"Step Up","StepUp"},
					{"No Fall","NoFall"},{"Climb Anywhere","ClimbAnywhere"},{"Truss Climb","TrussClimb"},
					{"Jump Recharge","JumpRecharge"},{"Double Jump","DoubleJump"},{"Triple Jump","TripleJump"},
					{"Quad Jump","QuadJump"},{"Wall Jump","WallJump"},{"Auto Jump","AutoJump"},
					{"Strafe Boost","StrafeBoost"},{"Momentum","Momentum"},{"Sprint Toggle (Alt)","SprintToggle"},
					{"Crouch Speed","CrouchSpeed"},{"Prone","Prone"},{"Leap (F)","Leap"},
					{"Backflip (R)","BackflipMove"},{"Power Jump","PowerJump"},{"Anti Void Walk","AntiVoidWalk"}
				}},
				{ title = "COMBAT", items = {
					{"Silent Aim","SilentAim"},{"Trigger Bot","TriggerBot"},{"Auto Parry","AutoParry"},
					{"No Recoil","NoRecoil"},{"No Spread","NoSpread"},{"Instant Reload","InstantReload"},
					{"Infinite Ammo","InfiniteAmmo"},{"Fast Fire","FastFire"},{"Auto Swing","AutoSwing"},
					{"Auto Equip","AutoEquip"},{"Target Lock","TargetLock"},{"Camera Lock","CameraLock"},
					{"Auto Reload","AutoReload"},{"Weapon ESP","WeaponESP"},{"Bullet Tracers","BulletTracers"},
					{"Kill Sound","KillSound"},{"Hit Sound","HitSound"},{"Headshot Aim","HeadshotAim"},
					{"Nearest Aim","NearestAim"},{"FOV Circle","FovCircle"},{"Aim Prediction","AimPrediction"},
					{"Hold Aim","HoldAim"},{"Auto Block","AutoBlock"},{"Auto Dodge","AutoDodge"},
					{"Attack Speed","AttackSpeed"},{"CPS Boost","CpsBoost"},{"Mouse Macro","MouseMacro"},
					{"Auto Jump Attack","AutoJumpAttack"},{"Auto Crouch","AutoCrouch"},{"Damage Indicator","DamageIndicator"},
					{"Kill Feed","KillFeed"},{"Anti Stun","AntiStun"},{"Combat Heal","CombatHeal"},
					{"Melee Aura","MeleeAura"},{"Ranged Aura","RangedAura"},{"Auto Click Hold","AutoClickHold"},
					{"Aim Assist","AimAssist"},{"No Sway","NoSway"},{"Weapon Hide","WeaponHide"},
					{"Crosshair Dot","CrosshairDot"},{"Circle Strafe","CircleStrafe"}
				}},
				{ title = "VISUALS", items = {
					{"Skeleton ESP","SkeletonESP"},{"Corner ESP","CornerESP"},{"Team Check","TeamCheck"},
					{"Distance Filter","DistanceFilter"},{"Name Tags","NameTags"},{"Health Text","HealthText"},
					{"Speed Tag","SpeedTag"},{"Rainbow ESP","RainbowESP"},{"Glow ESP","GlowESP"},
					{"Filled ESP","FilledESP"},{"Player Outline","PlayerOutline"},{"Self Highlight","SelfHighlight"},
					{"Viewmodel FOV","ViewmodelFov"},{"Camera Distance","CameraDistance"},{"Camera Height","CameraHeight"},
					{"Freeze Camera","FreezeCamera"},{"No Camera Shake","NoCameraShake"},{"No Head Bob","NoHeadBob"},
					{"First Person","FirstPerson"},{"Clean Screen","CleanScreen"},{"Hide Core Gui","HideCoreGui"},
					{"Remove Rain","RemoveRain"},{"Remove Snow","RemoveSnow"},{"Remove Grass","RemoveGrass"},
					{"Remove Terrain","RemoveTerrain"},{"Low Detail","LowDetail"},{"Texture Remover","TextureRemover"},
					{"Decal Remover","DecalRemover"},{"Mesh Remover","MeshRemover"},{"Lighting Boost","LightingBoost"},
					{"Saturation Boost","SaturationBoost"},{"Color Correction","ColorCorrection"},{"Bloom Effect","BloomEffect"},
					{"Sun Rays","SunRays"},{"Skybox Change","SkyboxChange"},{"Ambient Boost","AmbientBoost"},
					{"Brightness Boost","BrightnessBoost"},{"Night Vision","NightVision"},{"Thermal Vision","ThermalVision"},
					{"Depth of Field","DepthOfField"},{"Blur Effect","BlurEffect"},{"Vignette","Vignette"},
					{"Rainbow World","RainbowWorld"},{"Neon World","NeonWorld"},{"Grayscale","Grayscale"},
					{"Invert Colors","InvertColors"},{"Sepia","Sepia"},{"Pulse FOV","PulseFov"},
					{"Zoom","Zoom"},{"Radar","Radar"},{"Arrow ESP","ArrowESP"},
					{"Offscreen Indicators","OffscreenIndicators"},{"Chams Self","ChamsSelf"},{"Wireframe","Wireframe"},
					{"Minimap Dot","MinimapDot"}
				}},
				{ title = "TELEPORT", items = {
					{"Teleport Cursor","TeleportCursor"},{"Teleport Player","TeleportPlayer"},{"Teleport All","TeleportAll"},
					{"Teleport Nearest","TeleportNearest"},{"Teleport Farthest","TeleportFarthest"},{"Teleport Random","TeleportRandomAb"},
					{"Teleport Lowest","TeleportLowest"},{"Teleport Highest","TeleportHighest"},{"Teleport Home","TeleportHome"},
					{"Coordinate Teleport","CoordinateTeleport"},{"Teleport On Death","TeleportOnDeath"},{"Waypoint 1","Waypoint1"},
					{"Waypoint 2","Waypoint2"},{"Waypoint 3","Waypoint3"},{"Save Waypoint","SaveWaypoint"},
					{"Load Waypoint","LoadWaypoint"},{"TP Forward 10","TpForward10"},{"TP Up 20","TpUp20"},
					{"TP Down 20","TpDown20"},{"Ground Snap","GroundSnap"},{"Teleport To Spawn","TeleportSpawnAb"},
					{"Teleport To Start","TeleportStart"},{"Loop Teleport","LoopTeleport"},{"Follow Player","FollowPlayer"},
					{"Trail Teleport","TrailTeleport"}
				}},
				{ title = "UTILITY", items = {
					{"Notification System","NotificationSystem"},{"Chat Logger","ChatLogger"},{"Player List","PlayerList"},
					{"Server Info","ServerInfo"},{"Game Info","GameInfo"},{"Memory Display","MemoryDisplay"},
					{"Time Display","TimeDisplay"},{"Clock","ClockAb"},{"Stopwatch","Stopwatch"},
					{"Timer","TimerAb"},{"Toggle All","ToggleAll"},{"Panic Key (Backspace)","PanicKey"},
					{"Hide Gui","HideGuiAb"},{"Minimize Gui","MinimizeGuiAb"},{"Copy User Id","CopyUserId"},
					{"Copy Server Id","CopyServerId"},{"Copy Place Id","CopyPlaceId"},{"Copy Join Link","CopyJoinLink"},
					{"Console Clean","ConsoleClean"},{"Auto Save Config","AutoSaveConfig"},{"Anti Crash","AntiCrash"},
					{"Connection Watcher","ConnectionWatcher"},{"Auto Rejoin","AutoRejoin"},{"Ping Display","PingDisplay"},
					{"Ping Graph","PingGraph"},{"Fps Graph","FpsGraph"},{"Memory Graph","MemoryGraph"},
					{"Network Stats","NetworkStats"},{"Instance Counter","InstanceCounter"},{"Part Counter","PartCounter"},
					{"Player Counter","PlayerCounter"},{"Avatar Loader","AvatarLoader"},{"Character Info","CharacterInfo"},
					{"Tool Info","ToolInfo"},{"Backpack Viewer","BackpackViewer"}
				}}
			}
		},
		{
			page = "Fun",
			sections = {
				{ title = "CHARACTER FX", items = {
					{"Rainbow Character","RainbowCharacter"},{"Neon Character","NeonCharacter"},{"Glow Character","GlowCharacter"},
					{"Particle Aura","ParticleAura"},{"Trail Effect","TrailEffect"},{"Fire Aura","FireAura"},
					{"Lightning Aura","LightningAura"},{"Sparkles Aura","SparklesAura"},{"Snow Aura","SnowAura"},
					{"Confetti","ConfettiAb"},{"Spinning Parts","SpinningParts"},{"Orbiting Parts","OrbitingParts"},
					{"Floating Parts","FloatingParts"},{"Head Spin","HeadSpin"},{"Torso Spin","TorsoSpin"},
					{"Arm Flail","ArmFlail"},{"Ragdoll","RagdollButton"},{"Launch","LaunchAb"},
					{"Flip","FlipAb"},{"Mute Sounds","SoundMute"},{"Color Cycle","ColorCycle"},
					{"Music Player","MusicPlayer"},{"Emote Dance","EmoteDance"},{"Custom Nametag","CustomNametag"},
					{"Explosion","ExplosionButton"}
				}}
			}
		}
	}

	local function buildAbilityUI()
		for _,group in ipairs(abilityUI) do
			local page = createPage(group.page)
			local y = 0
			for _,sec in ipairs(group.sections) do
				createSection(page,sec.title,y)
				y = y + 28
				for _,item in ipairs(sec.items) do
					if states[item[2]] == nil then states[item[2]] = false end
					if previousStates[item[2]] == nil then previousStates[item[2]] = false end
					createToggle(page,item[1],y,item[2])
					y = y + 48
				end
				y = y + 10
			end
		end
	end

	buildAbilityUI()

	local function updateExtraOverlays()
		local ping = 0
		pcall(function() ping = math.floor(player:GetNetworkPing()*1000) end)

		if states.MemoryDisplay then
			overlayMem.Text = string.format("MEM: %.1f MB",collectgarbage("count")/1024)
		end

		if states.TimeDisplay or states.ClockAb then
			local t = os.date("*t")
			overlayTime.Text = string.format("%02d:%02d",t.hour,t.min)
		end

		if states.PlayerCounter then
			overlayPlayers.Visible = true
			overlayPlayers.Text = "PLAYERS: "..#Players:GetPlayers()
		else
			overlayPlayers.Visible = false
		end
	end

	abilityHeartbeat = RunService.Heartbeat:Connect(function()
		if closed then return end

		updateExtraOverlays()

		for key,handler in pairs(abilities) do
			local current = states[key] == true

			if current ~= previousStates[key] then
				previousStates[key] = current

				if current then
					if handler.onEnable then
						local ok,err = pcall(handler.onEnable)
						if not ok then warn("[0nyxhub] "..key.." enable: "..tostring(err)) end
					end
				else
					if handler.onDisable then
						local ok,err = pcall(handler.onDisable)
						if not ok then warn("[0nyxhub] "..key.." disable: "..tostring(err)) end
					end
				end
			end
		end
	end)

abilityLoop = RunService.Heartbeat:Connect(function()
	if closed then return end

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		if states.HipHeight then
			humanoid.HipHeight = hipHeightValue
		end

		if states.AutoRespawn and humanoid.Health <= 0 and not respawnBusy then
			respawnBusy = true
			task.delay(0.75,function()
				if states.AutoRespawn and not closed then
					pcall(function() player:LoadCharacter() end)
				end
				respawnBusy = false
			end)
		end
	end

	workspace.Gravity = gravityValue
	Lighting.ClockTime = clockTimeValue

	local camera = workspace.CurrentCamera
	if camera then camera.FieldOfView = fovValue end
end)

player.CharacterAdded:Connect(function()
	task.wait(1)
	if closed then return end

	for key,handler in pairs(abilities) do
		if states[key] and handler.onEnable then
			pcall(handler.onEnable)
		end
	end
end)

task.spawn(function()
	local frames = 0
	local accum = 0

	while not closed do
		local dt = RunService.RenderStepped:Wait()

		frames += 1
		accum += dt

		if accum >= 0.5 then
			local fps = math.floor(frames / accum + 0.5)
			frames = 0
			accum = 0

			if states.FpsCounter then
				overlayFps.Text = "FPS: "..fps
			end

			if states.PingCounter then
				local ping = 0
				pcall(function() ping = math.floor(player:GetNetworkPing() * 1000) end)
				overlayPing.Text = "PING: "..ping.." ms"
			end
		end
	end
end)

end

initAbilities()

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
			damageOverlay.BackgroundTransparency = 0.7
			TweenService:Create(
				damageOverlay,
				TweenInfo.new(0.45,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
				{ BackgroundTransparency = 1 }
			):Play()
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
miniButton.Position = UDim2.new(0,8,0,44)
miniButton.BackgroundColor3 = Color3.fromRGB(3,3,3)
miniButton.BorderSizePixel = 0
miniButton.Text = ""
miniButton.Visible = false
miniButton.ZIndex = 20
miniButton.Parent = gui

corner(miniButton,29)
outline(miniButton,Color3.fromRGB(210,210,210),0,1)

do
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
end

glow(miniButton,Color3.fromRGB(255,255,255),2)

do
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
			main.Size = UDim2.new(0,520,0,440)
			main.Position = UDim2.new(0.5,-260,0.5,-220)
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

		for key,handler in pairs(abilities) do
			if states[key] and handler.onDisable then
				pcall(handler.onDisable)
			end
		end

		if abilityHeartbeat then abilityHeartbeat:Disconnect() abilityHeartbeat = nil end
		if abilityLoop then abilityLoop:Disconnect() abilityLoop = nil end

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
		setAntiFling(false)
		setAntiAFK(false)
		setAntiKick(false)
		setAntiBan(false)

		if mainHeartbeat then mainHeartbeat:Disconnect() mainHeartbeat = nil end
		if stateHeartbeat then stateHeartbeat:Disconnect() stateHeartbeat = nil end
		disconnectCameraConnections()
		if currentCameraConnection then currentCameraConnection:Disconnect() currentCameraConnection = nil end

		if conn.health then conn.health:Disconnect() conn.health = nil end

		gui:Destroy()
	end)
end

local errorKicked = false

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

		main.Visible = true
		main.Size = UDim2.new(0,70,0,52)
		main.Position = UDim2.new(0.5,-35,0.5,-26)

		TweenService:Create(
			main,
			TweenInfo.new(0.85,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
			{
				Size = UDim2.new(0,520,0,440),
				Position = UDim2.new(0.5,-260,0.5,-220)
			}
		):Play()
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

print("[0nyxhub] loaded")
