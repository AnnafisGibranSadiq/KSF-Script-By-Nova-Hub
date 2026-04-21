local PathfindingService = game:GetService("PathfindingService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local killAuraEnabled = false
local killAuraRange = 0
local auraSphere = nil
local autoClickerEnabled = false

local walkSpeedEnabled, jumpPowerEnabled = false, false
local flyEnabled, spinEnabled = false, false
local targetSpeed, targetJump = 16, 50
local targetFlySpeed, targetSpinSpeed = 15, 35

local autoSwordEnabled = false
local autoBotEnabled, autoPlayerEnabled = false, false
local noclipEnabled, antiVoidEnabled = false, false

local damageAmpEnabled = false
local ampRotateSpeed = 0
local playerEspEnabled = false
local botEspEnabled = false

local navButtons = {}
local activeColor = Color3.fromRGB(0, 170, 255)
local normalColor = Color3.fromRGB(30, 30, 30)

local guiDraggable = true
local killAuraSwings = true

local ConfigFileName = "NovaHub_Mobile_Slots.json"

local function GetCurrentConfig()
	return {
		walkSpeed = {enabled = walkSpeedEnabled, val = targetSpeed},
		jumpPower = {enabled = jumpPowerEnabled, val = targetJump},
		killAura = {enabled = killAuraEnabled, range = killAuraRange, swings = killAuraSwings},
		esp = {players = playerEspEnabled, bots = botEspEnabled},
		misc = {noclip = noclipEnabled, antiVoid = antiVoidEnabled, draggable = guiDraggable}
	}
end

local function LoadConfig(data)
	walkSpeedEnabled = data.walkSpeed.enabled
	targetSpeed = data.walkSpeed.val
	killAuraEnabled = data.killAura.enabled
	killAuraRange = data.killAura.range
	killAuraSwings = data.killAura.swings
	playerEspEnabled = data.esp.players
	botEspEnabled = data.esp.bots
	noclipEnabled = data.misc.noclip
	antiVoidEnabled = data.misc.antiVoid
	guiDraggable = data.misc.draggable
end

local function SaveToDisk(data)
	local success, err = pcall(function()
		writefile(ConfigFileName, HttpService:JSONEncode(data))
	end)
	if not success then warn("Save failed: " .. tostring(err)) end
end

local function LoadFromDisk()
	if isfile and isfile(ConfigFileName) then
		local success, content = pcall(function() return readfile(ConfigFileName) end)
		if success then return HttpService:JSONDecode(content) end
	end
	return {}
end

local _G_Slots = LoadFromDisk()

local GuiParent = LocalPlayer:WaitForChild("PlayerGui") 

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KSF_NovaHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = GuiParent

local function addCorner(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = instance
end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 350)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Active = true
MainFrame.Selectable = true
MainFrame.Parent = ScreenGui
addCorner(MainFrame, 10)

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 100, 0, 40)
ToggleButton.Position = UDim2.new(0, 10, 0.5, -20)
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.Text = "NH-KSF"
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = ScreenGui
addCorner(ToggleButton, 8)

MainFrame.Visible = false 
ToggleButton.MouseButton1Click:Connect(function()
	MainFrame.Visible = not MainFrame.Visible
end)

local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
	if not guiDraggable then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local target = UserInputService:GetFocusedTextBox()
		if target then return end

		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TitleBar.Parent = MainFrame
addCorner(TitleBar, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "KSF Script By Nova Hub"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true
Title.Parent = TitleBar

local NavBar = Instance.new("Frame")
NavBar.Size = UDim2.new(0.3, 0, 1, -40)
NavBar.Position = UDim2.new(0, 0, 0, 40)
NavBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
NavBar.Parent = MainFrame
addCorner(NavBar, 10)

local NavList = Instance.new("UIListLayout", NavBar)
NavList.Padding = UDim.new(0, 5)
NavList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(0.7, -10, 1, -50)
ContentArea.Position = UDim2.new(0.3, 5, 0, 45)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

local Pages = {}
local function createPage(name)
	local p = Instance.new("ScrollingFrame")
	p.Size = UDim2.new(1, 0, 1, 0)
	p.BackgroundTransparency = 1
	p.ScrollBarThickness = 2
	p.CanvasSize = UDim2.new(0, 0, 2, 0)
	p.Parent = ContentArea
	p.Visible = false -- Make them all invisible by default
	local layout = Instance.new("UIListLayout", p)
	layout.Padding = UDim.new(0, 10)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	Pages[name] = p
	return p
end

local LPPage = createPage("LocalPlayer")
local FunPage = createPage("Fun")
local ESPPage = createPage("ESP")
local AutoPage = createPage("Auto")
createPage("Home")
local FilePage = createPage("File")
local OthersPage = createPage("Others")
createPage("Settings")
LPPage.Visible = true

local function createMenuBtn(name, isDefault)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.9, 0, 0, 30)
	btn.BackgroundColor3 = isDefault and activeColor or normalColor
	btn.Text = name
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamBold
	btn.Parent = NavBar
	addCorner(btn, 6)

	navButtons[name] = btn

	btn.MouseButton1Click:Connect(function()
		local targetName = (name == "Others Script") and "Others" or name

		for _, b in pairs(navButtons) do b.BackgroundColor3 = normalColor end
		for _, p in pairs(Pages) do p.Visible = false end

		btn.BackgroundColor3 = activeColor
		if Pages[targetName] then
			Pages[targetName].Visible = true
		end
	end)
end

createMenuBtn("Home", true)
createMenuBtn("LocalPlayer")
createMenuBtn("Fun")
createMenuBtn("ESP")
createMenuBtn("Auto")
createMenuBtn("File")
createMenuBtn("Others Script")
createMenuBtn("Settings")

for _, page in pairs(Pages) do
	page.Visible = false
end
Pages["Home"].Visible = true
MainFrame.Visible = false

for i = 1, 5 do
	local slotKey = tostring(i)
	local slotFrame = Instance.new("Frame", FilePage)
	slotFrame.Size = UDim2.new(0.9, 0, 0, 100)
	slotFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	addCorner(slotFrame, 8)

	local nameBox = Instance.new("TextBox", slotFrame)
	nameBox.Size = UDim2.new(1, -10, 0, 30)
	nameBox.Position = UDim2.new(0, 10, 0, 5)
	nameBox.BackgroundTransparency = 1
	nameBox.Text = (_G_Slots[slotKey] and _G_Slots[slotKey].Name) or "Slot " .. i .. " (Click to rename)"
	nameBox.TextColor3 = Color3.fromRGB(0, 170, 255)
	nameBox.Font = Enum.Font.GothamBold
	nameBox.TextSize = 14
	nameBox.TextXAlignment = Enum.TextXAlignment.Left

	local saveBtn = Instance.new("TextButton", slotFrame)
	saveBtn.Size = UDim2.new(0.3, -5, 0, 35)
	saveBtn.Position = UDim2.new(0, 5, 0, 45)
	saveBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
	saveBtn.Text = "Save Config"
	saveBtn.TextColor3 = Color3.new(1, 1, 1)
	saveBtn.Font = Enum.Font.GothamBold
	addCorner(saveBtn, 4)

	local loadBtn = Instance.new("TextButton", slotFrame)
	loadBtn.Size = UDim2.new(0.3, -5, 0, 35)
	loadBtn.Position = UDim2.new(0.35, 0, 0, 45)
	loadBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
	loadBtn.Text = "Load"
	loadBtn.TextColor3 = Color3.new(1, 1, 1)
	loadBtn.Font = Enum.Font.GothamBold
	addCorner(loadBtn, 4)

	saveBtn.MouseButton1Click:Connect(function()
		_G_Slots[slotKey] = {Data = GetCurrentConfig(), Name = nameBox.Text}
		SaveToDisk(_G_Slots)
		nameBox.TextColor3 = Color3.fromRGB(0, 255, 100)
	end)

	loadBtn.MouseButton1Click:Connect(function()
		if _G_Slots[slotKey] then
			LoadConfig(_G_Slots[slotKey].Data)
			nameBox.Text = _G_Slots[slotKey].Name .. " (LOADED)"
			nameBox.TextColor3 = Color3.fromRGB(0, 255, 100)
		else
			nameBox.TextColor3 = Color3.fromRGB(255, 0, 0)
		end
	end)
end

local HomeHeader = Instance.new("TextLabel", Pages["Home"])
HomeHeader.Size = UDim2.new(0.9, 0, 0, 40)
HomeHeader.BackgroundTransparency = 1
HomeHeader.Text = "Subs To Me And Join To My Discord Server For Vip One!: 0/3"
HomeHeader.TextColor3 = Color3.new(1, 1, 1)
HomeHeader.Font = Enum.Font.GothamBold
HomeHeader.TextSize = 14
HomeHeader.TextWrapped = true

local function updateCounter()
	totalClicked = (clickedYoutube1 and 1 or 0) + (clickedDiscord and 1 or 0) + (clickedYoutube2 and 1 or 0)
	HomeHeader.Text = "Subs To YepImDarkNova, Rafli_182 And Join To My Discord Server For Vip One!: " .. totalClicked .. "/3"
end

local ytBtn1 = Instance.new("TextButton", Pages["Home"])
ytBtn1.Size = UDim2.new(0.9, 0, 0, 40)
ytBtn1.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
ytBtn1.Text = "YouTube: YepImDarkNova"
ytBtn1.TextColor3 = Color3.new(1, 1, 1)
ytBtn1.Font = Enum.Font.GothamBold
addCorner(ytBtn1, 6)

ytBtn1.MouseButton1Click:Connect(function()
	setclipboard("https://www.youtube.com/@YepImDarkNova")
	if not clickedYoutube1 then
		clickedYoutube1 = true
		updateCounter()
	end
	print("YouTube 1 Link Copied!")
end)

local dcBtn = Instance.new("TextButton", Pages["Home"])
dcBtn.Size = UDim2.new(0.9, 0, 0, 40)
dcBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
dcBtn.Text = "Discord: Nova's Dumb Server"
dcBtn.TextColor3 = Color3.new(1, 1, 1)
dcBtn.Font = Enum.Font.GothamBold
addCorner(dcBtn, 6)

dcBtn.MouseButton1Click:Connect(function()
	setclipboard("https://discord.gg/Ha6SFWrE")
	if not clickedDiscord then
		clickedDiscord = true
		updateCounter()
	end
	print("Discord Link Copied!")
end)

local ytBtn2 = Instance.new("TextButton", Pages["Home"])
ytBtn2.Size = UDim2.new(0.9, 0, 0, 40)
ytBtn2.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
ytBtn2.Text = "YouTube: Rafli_182"
ytBtn2.TextColor3 = Color3.new(1, 1, 1)
ytBtn2.Font = Enum.Font.GothamBold
addCorner(ytBtn2, 6)

ytBtn2.MouseButton1Click:Connect(function()
	setclipboard("https://www.youtube.com/@Rafli_182")
	if not clickedYoutube2 then
		clickedYoutube2 = true
		updateCounter()
	end
	print("YouTube 2 Link Copied!")
end)

local function addExecute(name, description, callback, parentPage)
	local container = Instance.new("Frame", parentPage)
	container.Size = UDim2.new(0.9, 0, 0, 60)
	container.BackgroundTransparency = 1

	local btn = Instance.new("TextButton", container)
	btn.Size = UDim2.new(1, 0, 0, 30)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	btn.Text = "Execute " .. name
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamBold
	addCorner(btn, 6)

	local desc = Instance.new("TextLabel", container)
	desc.Size = UDim2.new(1, 0, 0, 20)
	desc.Position = UDim2.new(0, 0, 0, 35)
	desc.BackgroundTransparency = 1
	desc.Text = description
	desc.TextColor3 = Color3.new(0.6, 0.6, 0.6)
	desc.Font = Enum.Font.Gotham
	desc.TextSize = 10

	btn.MouseButton1Click:Connect(function()
		callback()
	end)
end


local function addCheat(name, maxVal, color, toggleCallback, valueCallback, parentPage)
	local container = Instance.new("Frame", parentPage)
	container.Size = UDim2.new(0.9, 0, 0, (maxVal ~= nil) and 75 or 40)
	container.BackgroundTransparency = 1
	local btn = Instance.new("TextButton", container)
	btn.Size = UDim2.new(1, 0, 0, 30)
	btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
	btn.Text = name .. ": OFF"
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamBold
	addCorner(btn, 6)
	btn.MouseButton1Click:Connect(function()
		local state = toggleCallback()
		btn.Text = name .. (state and ": ON" or ": OFF")
		btn.BackgroundColor3 = state and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
	end)
	if maxVal ~= nil then
		local track = Instance.new("Frame", container)
		track.Size = UDim2.new(0.9, 0, 0, 4)
		track.Position = UDim2.new(0.05, 0, 0, 40)
		track.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		local slider = Instance.new("TextButton", track)
		slider.Size = UDim2.new(0, 20, 0, 20)
		slider.Position = UDim2.new(0, -10, 0.5, -10)
		slider.BackgroundColor3 = color
		slider.Text = ""
		addCorner(slider, 10)
		local label = Instance.new("TextLabel", container)
		label.Size = UDim2.new(1, 0, 0, 20)
		label.Position = UDim2.new(0, 0, 0, 55)
		label.BackgroundTransparency = 1
		label.Text = "Current " .. name .. ": 0"
		label.TextColor3 = Color3.new(1, 1, 1)
		label.Font = Enum.Font.Gotham
		label.TextSize = 12
		local draggingSlider = false
		slider.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then draggingSlider = true end end)
		UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then draggingSlider = false end end)
		UserInputService.InputChanged:Connect(function(i)
			if draggingSlider and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
				local x = math.clamp(i.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
				slider.Position = UDim2.new(0, x - 10, 0.5, -10)
				local val = math.floor((x / track.AbsoluteSize.X) * maxVal)
				label.Text = "Current " .. name .. ": " .. val
				valueCallback(val)
			end
		end)
	end
end

addCheat("WalkSpeed", 30, Color3.new(0, 0.5, 1), function() walkSpeedEnabled = not walkSpeedEnabled return walkSpeedEnabled end, function(v) targetSpeed = v end, LPPage)
addCheat("JumpPower", 100, Color3.new(1, 0.6, 0), function() jumpPowerEnabled = not jumpPowerEnabled return jumpPowerEnabled end, function(v) targetJump = v end, LPPage)
addCheat("FlySpeed", 30, Color3.new(0.5, 0, 1), function() flyEnabled = not flyEnabled return flyEnabled end, function(v) targetFlySpeed = v end, LPPage)
addCheat("SpinSpeed", 75, Color3.new(1, 1, 1), function() spinEnabled = not spinEnabled return spinEnabled end, function(v) targetSpinSpeed = v end, LPPage)

addCheat("AutoSword", nil, nil, function() autoSwordEnabled = not autoSwordEnabled return autoSwordEnabled end, nil, AutoPage)
addCheat("AutoClicker", nil, nil, function() autoClickerEnabled = not autoClickerEnabled return autoClickerEnabled end, nil, AutoPage)
addCheat("AutoBot", nil, nil, function() autoBotEnabled = not autoBotEnabled return autoBotEnabled end, nil, AutoPage)
addCheat("AutoPlayer", nil, nil, function() autoPlayerEnabled = not autoPlayerEnabled return autoPlayerEnabled end, nil, AutoPage)

addCheat("Player ESP", nil, nil, function() 
	playerEspEnabled = not playerEspEnabled 
	return playerEspEnabled 
end, nil, Pages["ESP"])

addCheat("Bots ESP", nil, nil, function() 
	botEspEnabled = not botEspEnabled 
	return botEspEnabled 
end, nil, Pages["ESP"])

addCheat("Kill Aura", 20, Color3.new(1, 0, 0), function() 
	killAuraEnabled = not killAuraEnabled 
	return killAuraEnabled 
end, function(v) 
	killAuraRange = v 
end, FunPage)

addCheat("Damage Amp", 75, Color3.fromRGB(255, 0, 255), function() 
	damageAmpEnabled = not damageAmpEnabled 
	return damageAmpEnabled
end, function(v) 
	ampRotateSpeed = v 
end, FunPage)

addCheat("Noclip", nil, nil, function() 
	noclipEnabled = not noclipEnabled 
	return noclipEnabled 
end, nil, FunPage)

addCheat("AntiVoid", nil, nil, function() 
	antiVoidEnabled = not antiVoidEnabled 
	return antiVoidEnabled 
end, nil, FunPage)

addCheat("Gui Draggable", nil, nil, function()
	guiDraggable = not guiDraggable
	return guiDraggable
end, nil, Pages["Settings"])

addCheat("KillAura Sword Toggle", nil, nil, function()
	killAuraSwings = not killAuraSwings
	return killAuraSwings
end, nil, Pages["Settings"])

local function getNearestTarget(mode)
	local nearest, dist = nil, math.huge
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return nil, dist end
	local myPos = char.HumanoidRootPart.Position

	if mode == "Bot" then
		local botFolder = workspace:FindFirstChild("CurrentBots")
		if botFolder then
			for _, v in pairs(botFolder:GetChildren()) do
				if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") then
					local d = (myPos - v.HumanoidRootPart.Position).Magnitude
					if d < dist then dist = d nearest = v end
				end
			end
		end
	elseif mode == "Player" then
		for _, v in pairs(Players:GetPlayers()) do
			if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
				local d = (myPos - v.Character.HumanoidRootPart.Position).Magnitude
				if d < dist then dist = d nearest = v.Character end
			end
		end
	elseif mode == "Any" then
		local p, pd = getNearestTarget("Player")
		local b, bd = getNearestTarget("Bot")
		if pd < bd then return p, pd else return b, bd end
	end
	return nearest, dist
end

local lastPos = Vector3.new(0,0,0)
local lastCheck = tick()
local stuckTimer = tick()
local forceRecalculate = false

local function smartMove(hum, hrp, targetPos)
	local distanceMoved = (hrp.Position - lastPos).Magnitude

	if distanceMoved < 2 then -- If moved less than 2 studs
		if tick() - stuckTimer > 20 then
			warn("Stuck for 20s, forcing recalculation...")
			forceRecalculate = true
			stuckTimer = tick()
			hum.Jump = true
		end
	else
		lastPos = hrp.Position
		stuckTimer = tick()
		forceRecalculate = false
	end

	local path = PathfindingService:CreatePath({
		AgentCanJump = true,
		AgentHeight = 5,
		AgentRadius = 3,
		WaypointSpacing = 4,
		Costs = forceRecalculate and {Water = 100} or {} -- Slight cost tweak if stuck
	})

	local success, _ = pcall(function()
		path:ComputeAsync(hrp.Position, targetPos)
	end)

	if success and path.Status == Enum.PathStatus.Success then
		local waypoints = path:GetWaypoints()

		if distanceMoved < 1 and tick() - lastCheck > 0.5 then
			hum.Jump = true 
			lastCheck = tick()
		end

		if waypoints[2] then
			local nextPoint = waypoints[2]
			if nextPoint.Action == Enum.PathWaypointAction.Jump then
				hum.Jump = true
			end
			hum:MoveTo(nextPoint.Position)
		end
	else
		hum:MoveTo(targetPos)
		if tick() - lastCheck > 1 then
			hum.Jump = true
			lastCheck = tick()
		end
	end
end

local function createAuraSphere()
	local part = Instance.new("Part")
	part.Name = "AuraVisual"
	part.Shape = Enum.PartType.Ball
	part.CanCollide = false
	part.CanTouch = false
	part.Material = Enum.Material.ForceField
	part.Color = Color3.fromRGB(255, 0, 0)
	part.Transparency = 0.7
	part.Anchored = true
	part.Parent = workspace
	auraSphere = part
end
createAuraSphere()

local function applyHighlight(model, enabled, color)
	local highlight = model:FindFirstChild("NovaHighlight")
	if enabled then
		if not highlight then
			highlight = Instance.new("Highlight")
			highlight.Name = "NovaHighlight"
			highlight.FillColor = color
			highlight.OutlineColor = Color3.new(1, 1, 1)
			highlight.FillTransparency = 0.5
			highlight.Parent = model
		end
	else
		if highlight then highlight:Destroy() end
	end
end

local bv, bg, bav
RunService.Stepped:Connect(function()
	local char = LocalPlayer.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp or not hum then return end

	if killAuraEnabled and killAuraRange > 0 then
		local sword = char:FindFirstChildOfClass("Tool")
		for _, v in pairs(workspace:GetDescendants()) do
			if v:IsA("Humanoid") and v.Parent ~= char and v.Health > 0 then
				local targetHrp = v.Parent:FindFirstChild("HumanoidRootPart")
				if targetHrp then
					local dist = (hrp.Position - targetHrp.Position).Magnitude
					if dist <= killAuraRange and sword then

						if killAuraSwings then
							sword:Activate()
						end

						if firetouchinterest and sword:FindFirstChild("Handle") then
							firetouchinterest(targetHrp, sword.Handle, 0)
							firetouchinterest(targetHrp, sword.Handle, 1)
						end
					end
				end
			end
		end
	end

	if damageAmpEnabled and ampRotateSpeed > 0 then
		local tool = char:FindFirstChildOfClass("Tool")
		if tool then
			local isPlayingSlash = false
			for _, track in pairs(hum:GetPlayingAnimationTracks()) do
				local name = track.Name:lower()
				if name:find("slash") or name:find("attack") or name:find("lunge") or name:find("swing") then
					isPlayingSlash = true
					break
				end
			end
			if isPlayingSlash then
				local jitter = math.sin(tick() * ampRotateSpeed) * 1.2
				hrp.CFrame = hrp.CFrame * CFrame.Angles(0, jitter, 0)
			end
		end
	end

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			applyHighlight(player.Character, playerEspEnabled, Color3.fromRGB(0, 255, 150))
		end
	end

	local botFolder = workspace:FindFirstChild("CurrentBots")
	if botFolder then
		for _, bot in pairs(botFolder:GetChildren()) do
			if bot:IsA("Model") then
				applyHighlight(bot, botEspEnabled, Color3.fromRGB(255, 0, 100))
			end
		end
	end

	if noclipEnabled then
		for _, part in pairs(char:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = false end
		end
	end

	if antiVoidEnabled then
		local threshold = workspace.FallenPartsDestroyHeight + 15
		if hrp.Position.Y < threshold then
			hrp.Velocity = Vector3.new(0, 500, 0)
		end
	end

	if walkSpeedEnabled then hum.WalkSpeed = targetSpeed end
	if jumpPowerEnabled then
		if hum.UseJumpPower then hum.JumpPower = targetJump else hum.JumpHeight = targetJump end
	end

	if flyEnabled then
		if not bv then bv = Instance.new("BodyVelocity", hrp) bv.MaxForce = Vector3.new(9e9,9e9,9e9) end
		if not bg then bg = Instance.new("BodyGyro", hrp) bg.MaxTorque = Vector3.new(9e9,9e9,9e9) end
		bg.CFrame = workspace.CurrentCamera.CFrame
		bv.Velocity = (hum.MoveDirection.Magnitude > 0) and (workspace.CurrentCamera.CFrame:VectorToWorldSpace(hum.MoveDirection) * targetFlySpeed) or Vector3.new(0,0,0)
	else
		if bv then bv:Destroy() bv = nil end
		if bg then bg:Destroy() bg = nil end
	end

	if spinEnabled then
		if not bav then bav = Instance.new("BodyAngularVelocity", hrp) bav.MaxTorque = Vector3.new(0, 9e9, 0) end
		bav.AngularVelocity = Vector3.new(0, targetSpinSpeed, 0)
	else
		if bav then bav:Destroy() bav = nil end
	end

	if autoBotEnabled then
		local bot, bDist = getNearestTarget("Bot")
		if bot and bot:FindFirstChild("Humanoid") and bot.Humanoid.Health > 0 and bDist > 4 then
			smartMove(hum, hrp, bot.HumanoidRootPart.Position)
		end
	elseif autoPlayerEnabled then
		local plr, pDist = getNearestTarget("Player")
		if plr and plr:FindFirstChild("Humanoid") and plr.Humanoid.Health > 0 and pDist > 4 then
			smartMove(hum, hrp, plr.HumanoidRootPart.Position)
		end
	end

	if autoSwordEnabled then
		local anyT, anyD = getNearestTarget("Any")
		if anyT and anyD < 25 then
			local sword = LocalPlayer.Backpack:FindFirstChildOfClass("Tool") or char:FindFirstChildOfClass("Tool")
			if sword and sword.Parent ~= char then hum:EquipTool(sword) end
		end
	end

	if autoClickerEnabled then
		local tool = char:FindFirstChildOfClass("Tool")
		if tool then tool:Activate() end
	end

	if auraSphere then
		auraSphere.CFrame = hrp.CFrame
		auraSphere.Size = Vector3.new(killAuraRange * 2, killAuraRange * 2, killAuraRange * 2)
		auraSphere.Visible = (killAuraEnabled and killAuraRange > 0)
	end
end)

addExecute("Infinite Yield", "Admin Command Script", function()
	loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
end, Pages["Others Script"])

LocalPlayer.CharacterAdded:Connect(function() 
	bv, bg, bav = nil, nil, nil 
end)
