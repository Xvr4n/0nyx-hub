local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local gui = Instance.new("ScreenGui")
gui.Name = "0nyxhub"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local states = {
	InfiniteJump = false,
	AntiFling = false,
	Flight = false,
	Noclip = false,
	Invisible = false,
	ESP = false,
	ClickTeleport = false,
	TeleportTool = false
}

local walkSpeed = 16
local flightSpeed = 50
local teleportTool
local closed = false
local fullscreenEnabled = false
local connections = {}

local function connect(signal, callback)
	local connection = signal:Connect(callback)
	table.insert(connections, connection)
	return connection
end

local function disconnectAll()
	for _, connection in ipairs(connections) do
		if connection and connection.Connected then
			connection:Disconnect()
		end
	end
	table.clear(connections)
end

local function resetCharacter()
	local character = player.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")

	if humanoid then
		humanoid.WalkSpeed = 16
		humanoid.PlatformStand = false
		humanoid.AutoRotate = true
	end

	if root then
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
	end

	for _, object in ipairs(character:GetDescendants()) do
		if object:IsA("BasePart") then
			object.CanCollide = true
			object.Transparency = 0
		elseif object:IsA("Decal") then
			object.Transparency = 0
		end
	end
end

local function removeESP()
	for _, otherPlayer in ipairs(Players:GetPlayers()) do
		if otherPlayer.Character then
			local esp = otherPlayer.Character:FindFirstChild("0nyxESP")

			if esp then
				esp:Destroy()
			end
		end
	end
end

local function resetAndExit()
	if closed then
		return
	end

	closed = true

	for key in pairs(states) do
		states[key] = false
	end

	if teleportTool then
		teleportTool:Destroy()
		teleportTool = nil
	end

	resetCharacter()
	removeESP()
	disconnectAll()

	if gui and gui.Parent then
		gui:Destroy()
	end
end

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
	return s
end

local function makeDraggable(object,handle)
	local dragging = false
	local dragStart
	local startPosition

	connect(handle.InputBegan,function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = true
			dragStart = input.Position
			startPosition = object.Position
		end
	end)

	connect(handle.InputEnded,function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = false
		end
	end)

	connect(UserInputService.InputChanged,function(input)
		if not dragging then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then

			local delta = input.Position - dragStart

			object.Position = UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + delta.X,
				startPosition.Y.Scale,
				startPosition.Y.Offset + delta.Y
			)
		end
	end)
end

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0,720,0,470)
main.Position = UDim2.new(0.5,-360,0.5,-235)
main.BackgroundColor3 = Color3.fromRGB(10,10,10)
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.ZIndex = 1
main.Parent = gui

corner(main,12)
outline(main,Color3.fromRGB(80,80,80),0.2,1)

local backgroundFX = Instance.new("Frame")
backgroundFX.Size = UDim2.new(1,0,1,0)
backgroundFX.BackgroundTransparency = 1
backgroundFX.ClipsDescendants = true
backgroundFX.ZIndex = 1
backgroundFX.Parent = main

local orb1 = Instance.new("Frame")
orb1.Size = UDim2.new(0,280,0,280)
orb1.Position = UDim2.new(0.64,0,0.01,0)
orb1.BackgroundColor3 = Color3.fromRGB(255,255,255)
orb1.BackgroundTransparency = 0.91
orb1.BorderSizePixel = 0
orb1.ZIndex = 1
orb1.Parent = backgroundFX
corner(orb1,140)
outline(orb1,Color3.fromRGB(255,255,255),0.72,1)

TweenService:Create(
	orb1,
	TweenInfo.new(8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),
	{
		Position = UDim2.new(0.55,0,0.18,0),
		BackgroundTransparency = 0.95
	}
):Play()

local orb2 = Instance.new("Frame")
orb2.Size = UDim2.new(0,190,0,190)
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
	{
		Position = UDim2.new(0.34,0,0.44,0),
		BackgroundTransparency = 0.96
	}
):Play()

local orb3 = Instance.new("Frame")
orb3.Size = UDim2.new(0,90,0,90)
orb3.Position = UDim2.new(0.78,0,0.68,0)
orb3.BackgroundColor3 = Color3.fromRGB(255,255,255)
orb3.BackgroundTransparency = 0.88
orb3.BorderSizePixel = 0
orb3.ZIndex = 1
orb3.Parent = backgroundFX
corner(orb3,50)

TweenService:Create(
	orb3,
	TweenInfo.new(6,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),
	{
		Position = UDim2.new(0.70,0,0.58,0),
		BackgroundTransparency = 0.95
	}
):Play()

local function createFloatingParticle()
	if closed or not backgroundFX.Parent then
		return
	end

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

	local endX = math.clamp(
		startX + math.random(-15,15)/100,
		0.02,
		0.98
	)

	TweenService:Create(
		particle,
		TweenInfo.new(1.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),
		{
			BackgroundTransparency = math.random(15,40)/100
		}
	):Play()

	local movement = TweenService:Create(
		particle,
		TweenInfo.new(duration,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),
		{
			Position = UDim2.new(endX,0,-0.12,0)
		}
	)

	movement:Play()

	task.delay(duration-2,function()
		if particle.Parent and not closed then
			TweenService:Create(
				particle,
				TweenInfo.new(2),
				{
					BackgroundTransparency = 1
				}
			):Play()
		end
	end)

	movement.Completed:Connect(function()
		if particle.Parent then
			particle:Destroy()
		end
	end)
end

task.spawn(function()
	while gui.Parent and not closed do
		createFloatingParticle()
		task.wait(0.18)
	end
end)

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0,170,1,0)
sidebar.BackgroundColor3 = Color3.fromRGB(7,7,7)
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 5
sidebar.Parent = main
corner(sidebar,12)

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.new(0,20,0,18)
title.Size = UDim2.new(0,130,0,30)
title.Text = "0nyxhub"
title.Font = Enum.Font.GothamBold
title.TextSize = 23
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 6
title.Parent = sidebar
glow(title,Color3.fromRGB(255,255,255),3)

local subtitle = Instance.new("TextLabel")
subtitle.BackgroundTransparency = 1
subtitle.Position = UDim2.new(0,21,0,47)
subtitle.Size = UDim2.new(0,130,0,20)
subtitle.Text = "CONTROL PANEL"
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 9
subtitle.TextColor3 = Color3.fromRGB(145,145,145)
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.ZIndex = 6
subtitle.Parent = sidebar

local pages = {
	"Home",
	"Player",
	"Movement",
	"Visuals",
	"Teleport",
	"Settings"
}

local pageButtons = {}
local pageFrames = {}

local function createPageButton(name,index)
	local button = Instance.new("TextButton")

	button.Name = name
	button.Size = UDim2.new(0,140,0,38)
	button.Position = UDim2.new(0,15,0,82+((index-1)*45))
	button.BackgroundColor3 = Color3.fromRGB(15,15,15)
	button.BackgroundTransparency = 1
	button.BorderSizePixel = 0
	button.Text = name
	button.Font = Enum.Font.GothamMedium
	button.TextSize = 13
	button.TextColor3 = Color3.fromRGB(155,155,155)
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.ZIndex = 6
	button.Parent = sidebar

	corner(button,7)

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0,14)
	padding.Parent = button

	pageButtons[name] = button
end

for i,name in ipairs(pages) do
	createPageButton(name,i)
end

local top = Instance.new("Frame")
top.Size = UDim2.new(1,-170,0,65)
top.Position = UDim2.new(0,170,0,0)
top.BackgroundTransparency = 1
top.ZIndex = 5
top.Parent = main

local topTitle = Instance.new("TextLabel")
topTitle.BackgroundTransparency = 1
topTitle.Position = UDim2.new(0,25,0,13)
topTitle.Size = UDim2.new(0,250,0,25)
topTitle.Text = "0nyxhub"
topTitle.Font = Enum.Font.GothamBold
topTitle.TextSize = 19
topTitle.TextColor3 = Color3.fromRGB(255,255,255)
topTitle.TextXAlignment = Enum.TextXAlignment.Left
topTitle.ZIndex = 6
topTitle.Parent = top
glow(topTitle,Color3.fromRGB(255,255,255),3)

local topSub = Instance.new("TextLabel")
topSub.BackgroundTransparency = 1
topSub.Position = UDim2.new(0,25,0,35)
topSub.Size = UDim2.new(0,250,0,18)
topSub.Text = "CONTROL PANEL"
topSub.Font = Enum.Font.Gotham
topSub.TextSize = 9
topSub.TextColor3 = Color3.fromRGB(120,120,120)
topSub.TextXAlignment = Enum.TextXAlignment.Left
topSub.ZIndex = 6
topSub.Parent = top

local fullscreen = Instance.new("TextButton")
fullscreen.Name = "Fullscreen"
fullscreen.Size = UDim2.new(0,35,0,30)
fullscreen.Position = UDim2.new(1,-125,0,18)
fullscreen.BackgroundColor3 = Color3.fromRGB(20,20,20)
fullscreen.BorderSizePixel = 0
fullscreen.Text = "□"
fullscreen.Font = Enum.Font.GothamBold
fullscreen.TextSize = 17
fullscreen.TextColor3 = Color3.fromRGB(220,220,220)
fullscreen.ZIndex = 6
fullscreen.Parent = top
corner(fullscreen,6)
outline(fullscreen,Color3.fromRGB(65,65,65),0.2,1)

local minimize = Instance.new("TextButton")
minimize.Name = "Minimize"
minimize.Size = UDim2.new(0,35,0,30)
minimize.Position = UDim2.new(1,-83,0,18)
minimize.BackgroundColor3 = Color3.fromRGB(20,20,20)
minimize.BorderSizePixel = 0
minimize.Text = "—"
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 17
minimize.TextColor3 = Color3.fromRGB(220,220,220)
minimize.ZIndex = 6
minimize.Parent = top
corner(minimize,6)
outline(minimize,Color3.fromRGB(65,65,65),0.2,1)

local closeButton = Instance.new("TextButton")
closeButton.Name = "Close"
closeButton.Size = UDim2.new(0,35,0,30)
closeButton.Position = UDim2.new(1,-41,0,18)
closeButton.BackgroundColor3 = Color3.fromRGB(20,20,20)
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 14
closeButton.TextColor3 = Color3.fromRGB(220,220,220)
closeButton.ZIndex = 6
closeButton.Parent = top
corner(closeButton,6)
outline(closeButton,Color3.fromRGB(65,65,65),0.2,1)

local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1,-195,1,-85)
content.Position = UDim2.new(0,185,0,75)
content.BackgroundTransparency = 1
content.ZIndex = 5
content.Parent = main

local function createPage(name)
	local frame = Instance.new("Frame")

	frame.Name = name.."Page"
	frame.Size = UDim2.new(1,0,1,0)
	frame.BackgroundTransparency = 1
	frame.Visible = false
	frame.ZIndex = 5
	frame.Parent = content

	pageFrames[name] = frame

	return frame
end

local function createSection(parent,text,y)
	local label = Instance.new("TextLabel")

	label.BackgroundTransparency = 1
	label.Position = UDim2.new(0,0,0,y)
	label.Size = UDim2.new(1,0,0,25)
	label.Text = text
	label.Font = Enum.Font.GothamBold
	label.TextSize = 12
	label.TextColor3 = Color3.fromRGB(170,170,170)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 6
	label.Parent = parent

	glow(label,Color3.fromRGB(255,255,255),2)
end

local function createToggle(parent,text,y,key,callback)
	local holder = Instance.new("Frame")

	holder.Size = UDim2.new(1,0,0,48)
	holder.Position = UDim2.new(0,0,0,y)
	holder.BackgroundColor3 = Color3.fromRGB(17,17,17)
	holder.BorderSizePixel = 0
	holder.ZIndex = 6
	holder.Parent = parent

	corner(holder,7)
	outline(holder,Color3.fromRGB(45,45,45),0.25,1)

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.new(0,15,0,0)
	label.Size = UDim2.new(1,-75,1,0)
	label.Text = text
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 12
	label.TextColor3 = Color3.fromRGB(225,225,225)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 7
	label.Parent = holder

	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.new(0,38,0,20)
	toggle.Position = UDim2.new(1,-53,0.5,-10)
	toggle.BackgroundColor3 = Color3.fromRGB(35,35,35)
	toggle.BorderSizePixel = 0
	toggle.Text = ""
	toggle.ZIndex = 7
	toggle.Parent = holder

	corner(toggle,10)

	local circle = Instance.new("Frame")
	circle.Size = UDim2.new(0,14,0,14)
	circle.Position = UDim2.new(0,3,0.5,-7)
	circle.BackgroundColor3 = Color3.fromRGB(160,160,160)
	circle.BorderSizePixel = 0
	circle.ZIndex = 8
	circle.Parent = toggle

	corner(circle,10)

	local enabled = false

	connect(toggle.MouseButton1Click,function()
		if closed then
			return
		end

		enabled = not enabled
		states[key] = enabled

		TweenService:Create(
			toggle,
			TweenInfo.new(0.15),
			{
				BackgroundColor3 = enabled
					and Color3.fromRGB(235,235,235)
					or Color3.fromRGB(35,35,35)
			}
		):Play()

		TweenService:Create(
			circle,
			TweenInfo.new(0.15),
			{
				Position = enabled
					and UDim2.new(1,-17,0.5,-7)
					or UDim2.new(0,3,0.5,-7),

				BackgroundColor3 = enabled
					and Color3.fromRGB(10,10,10)
					or Color3.fromRGB(160,160,160)
			}
		):Play()

		if callback then
			callback(enabled)
		end
	end)

	return holder,toggle
end

local home = createPage("Home")

createSection(home,"WELCOME",0)

local welcome = Instance.new("TextLabel")
welcome.BackgroundTransparency = 1
welcome.Position = UDim2.new(0,0,0,35)
welcome.Size = UDim2.new(1,0,0,55)
welcome.Text = "Welcome to 0nyxhub!"
welcome.Font = Enum.Font.GothamBold
welcome.TextSize = 25
welcome.TextColor3 = Color3.fromRGB(255,255,255)
welcome.TextXAlignment = Enum.TextXAlignment.Left
welcome.ZIndex = 6
welcome.Parent = home
glow(welcome,Color3.fromRGB(255,255,255),4)

local welcomeDescription = Instance.new("TextLabel")
welcomeDescription.BackgroundTransparency = 1
welcomeDescription.Position = UDim2.new(0,0,0,88)
welcomeDescription.Size = UDim2.new(1,-10,0,45)
welcomeDescription.Text = "Your personal control panel for a cleaner, smoother and more powerful experience."
welcomeDescription.Font = Enum.Font.Gotham
welcomeDescription.TextSize = 12
welcomeDescription.TextColor3 = Color3.fromRGB(145,145,145)
welcomeDescription.TextWrapped = true
welcomeDescription.TextXAlignment = Enum.TextXAlignment.Left
welcomeDescription.ZIndex = 6
welcomeDescription.Parent = home

local playerPage = createPage("Player")

createSection(playerPage,"PLAYER",0)
createToggle(playerPage,"Infinite Jump",35,"InfiniteJump")
createToggle(playerPage,"Anti Fling",90,"AntiFling")

local movement = createPage("Movement")

createSection(movement,"MOVEMENT",0)
createToggle(movement,"Flight",35,"Flight")
createToggle(movement,"Noclip",90,"Noclip")

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(1,0,0,45)
speedBox.Position = UDim2.new(0,0,0,145)
speedBox.BackgroundColor3 = Color3.fromRGB(17,17,17)
speedBox.BorderSizePixel = 0
speedBox.PlaceholderText = "WalkSpeed: 16"
speedBox.PlaceholderColor3 = Color3.fromRGB(100,100,100)
speedBox.Text = ""
speedBox.TextColor3 = Color3.fromRGB(235,235,235)
speedBox.Font = Enum.Font.Gotham
speedBox.TextSize = 12
speedBox.ClearTextOnFocus = false
speedBox.ZIndex = 7
speedBox.Parent = movement
corner(speedBox,7)
outline(speedBox,Color3.fromRGB(45,45,45),0.25,1)

connect(speedBox.FocusLost,function()
	local value = tonumber(speedBox.Text)

	if value then
		walkSpeed = math.clamp(value,8,100)

		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			humanoid.WalkSpeed = walkSpeed
		end
	end
end)

local flightBox = Instance.new("TextBox")
flightBox.Size = UDim2.new(1,0,0,45)
flightBox.Position = UDim2.new(0,0,0,200)
flightBox.BackgroundColor3 = Color3.fromRGB(17,17,17)
flightBox.BorderSizePixel = 0
flightBox.PlaceholderText = "Flight Speed: 50"
flightBox.PlaceholderColor3 = Color3.fromRGB(100,100,100)
flightBox.Text = ""
flightBox.TextColor3 = Color3.fromRGB(235,235,235)
flightBox.Font = Enum.Font.Gotham
flightBox.TextSize = 12
flightBox.ClearTextOnFocus = false
flightBox.ZIndex = 7
flightBox.Parent = movement
corner(flightBox,7)
outline(flightBox,Color3.fromRGB(45,45,45),0.25,1)

connect(flightBox.FocusLost,function()
	local value = tonumber(flightBox.Text)

	if value then
		flightSpeed = math.clamp(value,10,200)
	end
end)

local visuals = createPage("Visuals")

createSection(visuals,"VISUALS",0)

createToggle(visuals,"Invisible",35,"Invisible",function(enabled)
	local character = player.Character

	if character then
		for _,object in ipairs(character:GetDescendants()) do
			if object:IsA("BasePart") or object:IsA("Decal") then
				object.Transparency = enabled and 1 or 0
			end
		end
	end
end)

createToggle(visuals,"Player ESP",90,"ESP",function(enabled)
	for _,otherPlayer in ipairs(Players:GetPlayers()) do
		if otherPlayer ~= player and otherPlayer.Character then

			local existing = otherPlayer.Character:FindFirstChild("0nyxESP")

			if enabled and not existing then
				local highlight = Instance.new("Highlight")
				highlight.Name = "0nyxESP"
				highlight.FillTransparency = 0.8
				highlight.OutlineTransparency = 0
				highlight.Parent = otherPlayer.Character

			elseif not enabled and existing then
				existing:Destroy()
			end
		end
	end
end)

local teleport = createPage("Teleport")

createSection(teleport,"TELEPORT",0)

createToggle(teleport,"Click Teleport",35,"ClickTeleport")

createToggle(teleport,"Teleport Tool",90,"TeleportTool",function(enabled)
	if enabled then

		if teleportTool then
			teleportTool:Destroy()
		end

		teleportTool = Instance.new("Tool")
		teleportTool.Name = "0nyx Teleport"
		teleportTool.RequiresHandle = false
		teleportTool.CanBeDropped = false

		connect(teleportTool.Activated,function()
			if closed then
				return
			end

			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")

			if root and mouse.Hit then
				root.CFrame = CFrame.new(
					mouse.Hit.Position + Vector3.new(0,3,0)
				)
			end
		end)

		teleportTool.Parent = player.Backpack
	else
		if teleportTool then
			teleportTool:Destroy()
			teleportTool = nil
		end
	end
end)

local settings = createPage("Settings")

createSection(settings,"CONFIGURATION",0)

local configBox = Instance.new("TextBox")
configBox.Size = UDim2.new(1,0,0,42)
configBox.Position = UDim2.new(0,0,0,35)
configBox.BackgroundColor3 = Color3.fromRGB(17,17,17)
configBox.BorderSizePixel = 0
configBox.PlaceholderText = "Enter config name..."
configBox.PlaceholderColor3 = Color3.fromRGB(100,100,100)
configBox.Text = ""
configBox.TextColor3 = Color3.fromRGB(235,235,235)
configBox.TextSize = 12
configBox.Font = Enum.Font.Gotham
configBox.ClearTextOnFocus = false
configBox.ZIndex = 7
configBox.Parent = settings
corner(configBox,7)
outline(configBox,Color3.fromRGB(45,45,45),0.25,1)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1,0,0,25)
status.Position = UDim2.new(0,0,0,82)
status.BackgroundTransparency = 1
status.Text = "Status: Ready"
status.TextColor3 = Color3.fromRGB(150,150,150)
status.TextSize = 11
status.Font = Enum.Font.Gotham
status.TextXAlignment = Enum.TextXAlignment.Left
status.ZIndex = 7
status.Parent = settings

local autoLoad = false

createToggle(
	settings,
	"Auto Load Config",
	115,
	"AutoLoad",
	function(enabled)
		autoLoad = enabled
	end
)

local function makeSettingButton(text,y)
	local button = Instance.new("TextButton")

	button.Size = UDim2.new(1,0,0,42)
	button.Position = UDim2.new(0,0,0,y)
	button.BackgroundColor3 = Color3.fromRGB(17,17,17)
	button.BorderSizePixel = 0
	button.Text = text
	button.Font = Enum.Font.GothamMedium
	button.TextSize = 12
	button.TextColor3 = Color3.fromRGB(225,225,225)
	button.ZIndex = 7
	button.Parent = settings

	corner(button,7)
	outline(button,Color3.fromRGB(45,45,45),0.25,1)

	connect(button.MouseEnter,function()
		TweenService:Create(
			button,
			TweenInfo.new(0.15),
			{
				BackgroundColor3 = Color3.fromRGB(27,27,27),
				TextColor3 = Color3.fromRGB(255,255,255)
			}
		):Play()
	end)

	connect(button.MouseLeave,function()
		TweenService:Create(
			button,
			TweenInfo.new(0.15),
			{
				BackgroundColor3 = Color3.fromRGB(17,17,17),
				TextColor3 = Color3.fromRGB(225,225,225)
			}
		):Play()
	end)

	return button
end

local saveConfig = makeSettingButton("Save Config",173)
local loadConfig = makeSettingButton("Load Config",223)
local deleteConfig = makeSettingButton("Delete Config",273)
local resetSettings = makeSettingButton("Reset Settings",323)

local savedConfigs = {}

local function setStatus(text,success)
	status.Text = "Status: "..text

	if success then
		status.TextColor3 = Color3.fromRGB(180,255,180)
	else
		status.TextColor3 = Color3.fromRGB(255,170,170)
	end
end

connect(saveConfig.MouseButton1Click,function()
	local name = configBox.Text

	if name == "" then
		name = "MyConfig"
	end

	savedConfigs[name] = {
		InfiniteJump = states.InfiniteJump,
		AntiFling = states.AntiFling,
		Flight = states.Flight,
		Noclip = states.Noclip,
		Invisible = states.Invisible,
		ESP = states.ESP,
		ClickTeleport = states.ClickTeleport,
		TeleportTool = states.TeleportTool,
		WalkSpeed = walkSpeed,
		FlightSpeed = flightSpeed,
		AutoLoad = autoLoad
	}

	setStatus("Config saved: "..name,true)
end)

connect(loadConfig.MouseButton1Click,function()
	local name = configBox.Text

	if name == "" then
		name = "MyConfig"
	end

	local config = savedConfigs[name]

	if not config then
		setStatus("Config not found",false)
		return
	end

	states.InfiniteJump = config.InfiniteJump or false
	states.AntiFling = config.AntiFling or false
	states.Flight = config.Flight or false
	states.Noclip = config.Noclip or false
	states.Invisible = config.Invisible or false
	states.ESP = config.ESP or false
	states.ClickTeleport = config.ClickTeleport or false
	states.TeleportTool = config.TeleportTool or false

	walkSpeed = config.WalkSpeed or 16
	flightSpeed = config.FlightSpeed or 50
	autoLoad = config.AutoLoad or false

	speedBox.Text = tostring(walkSpeed)
	flightBox.Text = tostring(flightSpeed)

	setStatus("Config loaded: "..name,true)
end)

connect(deleteConfig.MouseButton1Click,function()
	local name = configBox.Text

	if name == "" then
		name = "MyConfig"
	end

	if savedConfigs[name] then
		savedConfigs[name] = nil
		setStatus("Config deleted: "..name,true)
	else
		setStatus("Config not found",false)
	end
end)

connect(resetSettings.MouseButton1Click,function()
	configBox.Text = ""
	speedBox.Text = ""
	flightBox.Text = ""

	autoLoad = false
	walkSpeed = 16
	flightSpeed = 50

	for key in pairs(states) do
		states[key] = false
	end

	resetCharacter()
	removeESP()

	if teleportTool then
		teleportTool:Destroy()
		teleportTool = nil
	end

	setStatus("Settings reset",true)
end)

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
	connect(button.MouseButton1Click,function()
		if closed then
			return
		end

		showPage(name)
	end)
end

showPage("Home")

local miniButton = Instance.new("TextButton")
miniButton.Name = "BlackHoleIcon"
miniButton.Size = UDim2.new(0,58,0,58)
miniButton.Position = UDim2.new(0,25,0.5,-29)
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
confirmOverlay.ZIndex = 30
confirmOverlay.Parent = main

local confirmBox = Instance.new("Frame")
confirmBox.Size = UDim2.new(0,330,0,175)
confirmBox.Position = UDim2.new(0.5,-165,0.5,-87)
confirmBox.BackgroundColor3 = Color3.fromRGB(15,15,15)
confirmBox.BorderSizePixel = 0
confirmBox.ZIndex = 31
confirmBox.Parent = confirmOverlay

corner(confirmBox,10)
outline(confirmBox,Color3.fromRGB(75,75,75),0.1,1)

local confirmTitle = Instance.new("TextLabel")
confirmTitle.BackgroundTransparency = 1
confirmTitle.Position = UDim2.new(0,20,0,18)
confirmTitle.Size = UDim2.new(1,-40,0,25)
confirmTitle.Text = "Close 0nyxhub?"
confirmTitle.Font = Enum.Font.GothamBold
confirmTitle.TextSize = 18
confirmTitle.TextColor3 = Color3.fromRGB(255,255,255)
confirmTitle.TextXAlignment = Enum.TextXAlignment.Left
confirmTitle.ZIndex = 32
confirmTitle.Parent = confirmBox
glow(confirmTitle,Color3.fromRGB(255,255,255),3)

local confirmMessage = Instance.new("TextLabel")
confirmMessage.BackgroundTransparency = 1
confirmMessage.Position = UDim2.new(0,20,0,52)
confirmMessage.Size = UDim2.new(1,-40,0,40)
confirmMessage.Text = "Are you sure you want to close this hub?"
confirmMessage.Font = Enum.Font.Gotham
confirmMessage.TextSize = 12
confirmMessage.TextColor3 = Color3.fromRGB(150,150,150)
confirmMessage.TextWrapped = true
confirmMessage.TextXAlignment = Enum.TextXAlignment.Left
confirmMessage.ZIndex = 32
confirmMessage.Parent = confirmBox

local cancel = Instance.new("TextButton")
cancel.Size = UDim2.new(0,115,0,35)
cancel.Position = UDim2.new(0,20,1,-55)
cancel.BackgroundColor3 = Color3.fromRGB(30,30,30)
cancel.BorderSizePixel = 0
cancel.Text = "Cancel"
cancel.Font = Enum.Font.GothamMedium
cancel.TextSize = 12
cancel.TextColor3 = Color3.fromRGB(220,220,220)
cancel.ZIndex = 32
cancel.Parent = confirmBox
corner(cancel,6)

local confirm = Instance.new("TextButton")
confirm.Size = UDim2.new(0,115,0,35)
confirm.Position = UDim2.new(1,-135,1,-55)
confirm.BackgroundColor3 = Color3.fromRGB(230,230,230)
confirm.BorderSizePixel = 0
confirm.Text = "Confirm"
confirm.Font = Enum.Font.GothamBold
confirm.TextSize = 12
confirm.TextColor3 = Color3.fromRGB(10,10,10)
confirm.ZIndex = 32
confirm.Parent = confirmBox
corner(confirm,6)

connect(minimize.MouseButton1Click,function()
	if closed then
		return
	end

	main.Visible = false
	miniButton.Visible = true
end)

connect(miniButton.MouseButton1Click,function()
	if closed then
		return
	end

	main.Visible = true
	miniButton.Visible = false
end)

connect(fullscreen.MouseButton1Click,function()
	if closed then
		return
	end

	fullscreenEnabled = not fullscreenEnabled

	if fullscreenEnabled then
		main.Size = UDim2.new(1,-20,1,-20)
		main.Position = UDim2.new(0,10,0,10)
		fullscreen.Text = "■"
	else
		main.Size = UDim2.new(0,720,0,470)
		main.Position = UDim2.new(0.5,-360,0.5,-235)
		fullscreen.Text = "□"
	end
end)

connect(closeButton.MouseButton1Click,function()
	if closed then
		return
	end

	confirmOverlay.Visible = true
end)

connect(cancel.MouseButton1Click,function()
	if closed then
		return
	end

	confirmOverlay.Visible = false
end)

connect(confirm.MouseButton1Click,function()
	resetAndExit()
end)

connect(UserInputService.InputBegan,function(input,processed)
	if closed or processed then
		return
	end

	if states.ClickTeleport
		and input.UserInputType == Enum.UserInputType.MouseButton1 then

		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")

		if root and mouse.Hit then
			root.CFrame = CFrame.new(
				mouse.Hit.Position + Vector3.new(0,3,0)
			)
		end
	end
end)

connect(UserInputService.JumpRequest,function()
	if closed or not states.InfiniteJump then
		return
	end

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

connect(RunService.Heartbeat,function()
	if closed then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local root = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if states.AntiFling and root then
		root.AssemblyAngularVelocity = Vector3.zero
	end

	if states.Noclip then
		for _,object in ipairs(character:GetDescendants()) do
			if object:IsA("BasePart") then
				object.CanCollide = false
			end
		end
	end

	if states.Flight and root then
		local camera = workspace.CurrentCamera
		local direction = Vector3.zero

		if UserInputService:IsKeyDown(Enum.KeyCode.W) then
			direction += camera.CFrame.LookVector
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			direction -= camera.CFrame.LookVector
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			direction -= camera.CFrame.RightVector
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			direction += camera.CFrame.RightVector
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			direction += Vector3.yAxis
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			direction -= Vector3.yAxis
		end

		if direction.Magnitude > 0 then
			root.AssemblyLinearVelocity = direction.Unit * flightSpeed
		else
			root.AssemblyLinearVelocity = Vector3.zero
		end
	end

	if humanoid and not states.Flight then
		humanoid.WalkSpeed = walkSpeed
	end
end)

connect(Players.PlayerAdded,function(otherPlayer)
	connect(otherPlayer.CharacterAdded,function(character)
		if closed then
			return
		end

		if states.ESP then
			task.wait(0.2)

			if closed then
				return
			end

			local highlight = Instance.new("Highlight")
			highlight.Name = "0nyxESP"
			highlight.FillTransparency = 0.8
			highlight.OutlineTransparency = 0
			highlight.Parent = character
		end
	end)
end)

makeDraggable(main,top)
makeDraggable(miniButton,miniButton)
