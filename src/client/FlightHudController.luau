local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local plr = Players.LocalPlayer
local cam = workspace.CurrentCamera
local Shared = RS:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local IrisTransition = require(Shared:WaitForChild("IrisTransition"))
local Remotes = RS:WaitForChild("Remotes")
local UIAction = Shared:WaitForChild("UIAction")
local CooldownEvent = Shared:WaitForChild("CooldownEvent")

local gui = script.Parent
gui.ResetOnSpawn = false

local hpBar = gui:WaitForChild("HPBar")
local fill = hpBar:WaitForChild("Fill")
local hpLbl = hpBar:WaitForChild("Label")
local hpTextLbl = hpBar:FindFirstChild("TextLabel")
if not hpTextLbl then
	hpTextLbl = Instance.new("TextLabel")
	hpTextLbl.Name = "TextLabel"
	hpTextLbl.Size = hpLbl.Size
	hpTextLbl.Position = hpLbl.Position
	hpTextLbl.AnchorPoint = hpLbl.AnchorPoint
	hpTextLbl.BackgroundTransparency = 1
	hpTextLbl.Visible = false
	hpTextLbl.Text = "2000 / 2000 HP"
	hpTextLbl.Parent = hpBar
end
local row = gui:WaitForChild("AbilityRow")
local dashBtn = row:WaitForChild("Dash")
local abBtn = row:WaitForChild("AbilityBtn")
local brakeBtn = row:WaitForChild("Brake")
local hubNav = gui:FindFirstChild("HubNav")
local energyBack = gui:FindFirstChild("EnergyBack")
local paceMeter = gui:FindFirstChild("PaceMeter")
local comboLabel = gui:FindFirstChild("ComboLabel")
if comboLabel then
	comboLabel.Position = UDim2.new(0.5, 0, 1, -172)
end

local currentSkin = "Cardboard"
local activeOverride = nil
local activeAbility = "Slap"
local ends = {}

local PRES_COLORS = {
	Color3.fromRGB(205, 130, 65),
	Color3.fromRGB(70, 225, 140),
	Color3.fromRGB(60, 165, 255),
	Color3.fromRGB(240, 60, 80),
	Color3.fromRGB(175, 80, 255),
	Color3.fromRGB(255, 195, 35),
	Color3.fromRGB(100, 235, 255),
	Color3.fromRGB(235, 170, 255),
	Color3.fromRGB(255, 80, 175),
	Color3.fromRGB(255, 240, 150),
}

-- =====================================================================
local lwTemplate = (function()
	local pg = plr:WaitForChild("PlayerGui", 15)
	local mh = pg and pg:WaitForChild("MainHUD", 15)
	local lm = mh and mh:WaitForChild("LeftMenu", 15)
	return lm and lm:WaitForChild("LuckyWheelButton", 15)
end)()

local MONT_FONT = (lwTemplate and lwTemplate:FindFirstChild("Label") and lwTemplate.Label.FontFace)
	or Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal)

local function styleTextLW(lbl)
	if not lbl or not (lbl:IsA("TextLabel") or lbl:IsA("TextButton")) then return end
	lbl.FontFace = MONT_FONT
	local oldSt = lbl:FindFirstChild("TextOutline") or lbl:FindFirstChildOfClass("UIStroke")
	if oldSt then oldSt:Destroy() end
	local st = (lwTemplate and lwTemplate:FindFirstChild("Label") and lwTemplate.Label:FindFirstChild("TextOutline"))
	if st then
		st = st:Clone()
	else
		st = Instance.new("UIStroke")
		st.Thickness = 2.5
		st.Color = Color3.new(0, 0, 0)
	end
	st.Name = "TextOutline"
	st.Parent = lbl
end

local function applyLuckyWheelStyle(target, colA, colB, ringA, ringB, cornerPx)
	if not target then return end
	for _, n in ipairs({ "OuterStroke", "ButtonBackground" }) do
		local old = target:FindFirstChild(n)
		if old then old:Destroy() end
	end
	local oldSt = target:FindFirstChildOfClass("UIStroke")
	if oldSt then oldSt:Destroy() end
	local oldGr = target:FindFirstChildOfClass("UIGradient")
	if oldGr then oldGr:Destroy() end

	local baseZ = math.max(1, target.ZIndex)
	target.ZIndex = baseZ
	target.BackgroundColor3 = colB:Lerp(Color3.new(0, 0, 0), 0.38)
	target.BackgroundTransparency = 0

	local c = target:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, cornerPx or 14)
	c.Parent = target

	if lwTemplate then
		local outer = lwTemplate:FindFirstChild("OuterStroke")
		if outer then outer:Clone().Parent = target end
		local bgSrc = lwTemplate:FindFirstChild("ButtonBackground")
		if bgSrc then
			local bg = bgSrc:Clone()
			bg.ZIndex = baseZ + 1
			bg.Size = UDim2.new(1, 0, 1, -5)
			bg.Position = UDim2.fromScale(0, 0)
			local bc = bg:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
			bc.CornerRadius = UDim.new(0, cornerPx or 14)
			bc.Parent = bg
			local gr = bg:FindFirstChild("BackgroundGradient")
			if gr then
				gr.Rotation = 90
				gr.Color = ColorSequence.new(colA, colB)
			end
			local inner = bg:FindFirstChild("InnerStroke")
			if inner then
				local ig = inner:FindFirstChild("InnerStrokeGradient")
				if ig then
					ig.Color = ColorSequence.new(ringA or colA:Lerp(Color3.new(1,1,1), 0.45), ringB or Color3.new(1,1,1))
				end
			end
			local hi = bg:FindFirstChild("BackgroundHighlights")
			if hi then hi.ZIndex = baseZ + 2 end
			bg.Parent = target
		end
	end
	for _, ch in ipairs(target:GetChildren()) do
		if ch:IsA("GuiObject") and ch.Name ~= "ButtonBackground" then
			ch.ZIndex = math.max(ch.ZIndex, baseZ + 4)
		end
	end
end

-- Restyle existing FlightHud elements in LuckyWheelButton style
applyLuckyWheelStyle(hpBar, Color3.fromRGB(45, 58, 95), Color3.fromRGB(22, 28, 48), Color3.fromRGB(130, 175, 255), Color3.new(1,1,1), 12)
if fill then fill.ZIndex = 3 end
styleTextLW(hpLbl)
if hpLbl then hpLbl.ZIndex = 4 end

if energyBack then
	applyLuckyWheelStyle(energyBack, Color3.fromRGB(35, 52, 85), Color3.fromRGB(18, 26, 46), Color3.fromRGB(100, 210, 255), Color3.new(1,1,1), 10)
	local ef = energyBack:FindFirstChild("EnergyFill")
	if ef then ef.ZIndex = 3 end
	local bl = energyBack:FindFirstChild("BoostLabel")
	if bl then bl.ZIndex = 4; styleTextLW(bl) end
end

if paceMeter then
	applyLuckyWheelStyle(paceMeter, Color3.fromRGB(38, 48, 80), Color3.fromRGB(20, 25, 44), Color3.fromRGB(145, 175, 240), Color3.new(1,1,1), 10)
	for _, sub in ipairs(paceMeter:GetChildren()) do
		if sub:IsA("GuiObject") and sub.Name ~= "ButtonBackground" then
			sub.ZIndex = math.max(sub.ZIndex, 3)
			if sub:IsA("TextLabel") then styleTextLW(sub) end
		end
	end
end

if comboLabel then styleTextLW(comboLabel) end
-- Bounty Target Banner (LuckyWheelButton style)
local oldBountyBanner = gui:FindFirstChild("BountyBanner")
if oldBountyBanner then oldBountyBanner:Destroy() end
local bountyBanner = Instance.new("Frame")
bountyBanner.Name = "BountyBanner"
bountyBanner.Size = UDim2.fromOffset(310, 34)
bountyBanner.Position = UDim2.new(0.5, 0, 0, 82)
bountyBanner.AnchorPoint = Vector2.new(0.5, 0)
bountyBanner.Visible = false
bountyBanner.Parent = gui
applyLuckyWheelStyle(bountyBanner, Color3.fromRGB(255, 200, 45), Color3.fromRGB(210, 105, 10), Color3.fromRGB(255, 240, 140), Color3.new(1,1,1), 12)
local bountyLbl = Instance.new("TextLabel")
bountyLbl.Name = "Label"
bountyLbl.Size = UDim2.fromScale(0.94, 0.85)
bountyLbl.Position = UDim2.fromScale(0.5, 0.48)
bountyLbl.AnchorPoint = Vector2.new(0.5, 0.5)
bountyLbl.BackgroundTransparency = 1
bountyLbl.TextScaled = true
bountyLbl.TextColor3 = Color3.new(1, 1, 1)
bountyLbl.ZIndex = 6
bountyLbl.Parent = bountyBanner
styleTextLW(bountyLbl)

-- Draft Status Badge (Glowing / Animating indicator when Slipstream attribute is active)
local oldDraftBadge = gui:FindFirstChild("DraftStatusBadge")
if oldDraftBadge then oldDraftBadge:Destroy() end

local draftBadge = Instance.new("Frame")
draftBadge.Name = "DraftStatusBadge"
draftBadge.Size = UDim2.fromOffset(360, 36)
draftBadge.Position = UDim2.new(0.5, 0, 0, 50)
draftBadge.AnchorPoint = Vector2.new(0.5, 0)
draftBadge.Visible = false
draftBadge.Parent = gui

applyLuckyWheelStyle(draftBadge, Color3.fromRGB(0, 220, 255), Color3.fromRGB(0, 85, 180), Color3.fromRGB(180, 245, 255), Color3.new(1,1,1), 12)

local draftGlowStroke = Instance.new("UIStroke")
draftGlowStroke.Name = "DraftGlowStroke"
draftGlowStroke.Thickness = 3
draftGlowStroke.Color = Color3.fromRGB(120, 240, 255)
draftGlowStroke.Transparency = 0.2
draftGlowStroke.Parent = draftBadge

local draftLbl = Instance.new("TextLabel")
draftLbl.Name = "Label"
draftLbl.Size = UDim2.fromScale(0.96, 0.85)
draftLbl.Position = UDim2.fromScale(0.5, 0.48)
draftLbl.AnchorPoint = Vector2.new(0.5, 0.5)
draftLbl.BackgroundTransparency = 1
draftLbl.TextScaled = true
draftLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
draftLbl.Text = "DRAFTING: -40% DRAG | +45% TOP SPEED"
draftLbl.ZIndex = 8
draftLbl.Parent = draftBadge
styleTextLW(draftLbl)

-- Digital Speedometer (Speed readout in studs/s + dynamic top speed cap readout)
local oldSpeedo = gui:FindFirstChild("SpeedometerFrame")
if oldSpeedo then oldSpeedo:Destroy() end

local speedoFrame = Instance.new("Frame")
speedoFrame.Name = "SpeedometerFrame"
speedoFrame.Size = UDim2.fromOffset(240, 68)
speedoFrame.Position = UDim2.new(0, 24, 1, -28)
speedoFrame.AnchorPoint = Vector2.new(0, 1)
speedoFrame.Visible = false
speedoFrame.Parent = gui

applyLuckyWheelStyle(speedoFrame, Color3.fromRGB(30, 48, 85), Color3.fromRGB(15, 22, 42), Color3.fromRGB(100, 195, 255), Color3.new(1,1,1), 14)

local speedValLbl = Instance.new("TextLabel")
speedValLbl.Name = "SpeedValue"
speedValLbl.Size = UDim2.new(0.55, 0, 0, 36)
speedValLbl.Position = UDim2.new(0, 12, 0, 8)
speedValLbl.BackgroundTransparency = 1
speedValLbl.TextScaled = true
speedValLbl.TextColor3 = Color3.fromRGB(255, 235, 90)
speedValLbl.Text = "0"
speedValLbl.TextXAlignment = Enum.TextXAlignment.Left
speedValLbl.ZIndex = 8
speedValLbl.Parent = speedoFrame
styleTextLW(speedValLbl)

local speedUnitLbl = Instance.new("TextLabel")
speedUnitLbl.Name = "SpeedUnit"
speedUnitLbl.Size = UDim2.new(0.40, 0, 0, 18)
speedUnitLbl.Position = UDim2.new(0.55, 6, 0, 18)
speedUnitLbl.BackgroundTransparency = 1
speedUnitLbl.TextScaled = true
speedUnitLbl.TextColor3 = Color3.fromRGB(150, 220, 255)
speedUnitLbl.Text = "STUDS/S"
speedUnitLbl.TextXAlignment = Enum.TextXAlignment.Left
speedUnitLbl.ZIndex = 8
speedUnitLbl.Parent = speedoFrame
styleTextLW(speedUnitLbl)

local speedCapLbl = Instance.new("TextLabel")
speedCapLbl.Name = "SpeedCap"
speedCapLbl.Size = UDim2.new(1, -24, 0, 16)
speedCapLbl.Position = UDim2.new(0, 12, 0, 44)
speedCapLbl.BackgroundTransparency = 1
speedCapLbl.TextScaled = true
speedCapLbl.TextColor3 = Color3.fromRGB(180, 230, 255)
speedCapLbl.Text = "TOP CAP: 145 STUDS/S (+45% DRAFT CAP)"
speedCapLbl.TextXAlignment = Enum.TextXAlignment.Left
speedCapLbl.ZIndex = 8
speedCapLbl.Parent = speedoFrame
styleTextLW(speedCapLbl)

local lastSpeedHrpPos = nil
local measuredSpeedSPS = 0

-- Checkpoint Heal Toast / Banner ("+250 HP Checkpoint Heal!")
local oldHealBanner = gui:FindFirstChild("CheckpointHealBanner")
if oldHealBanner then oldHealBanner:Destroy() end

local healBanner = Instance.new("Frame")
healBanner.Name = "CheckpointHealBanner"
healBanner.Size = UDim2.fromOffset(360, 48)
healBanner.Position = UDim2.new(0.5, 0, 0, -60)
healBanner.AnchorPoint = Vector2.new(0.5, 0)
healBanner.ZIndex = 30
healBanner.Visible = false
healBanner.Parent = gui

applyLuckyWheelStyle(healBanner, Color3.fromRGB(40, 220, 110), Color3.fromRGB(15, 120, 50), Color3.fromRGB(160, 255, 200), Color3.new(1,1,1), 14)

local healIcon = Instance.new("TextLabel")
healIcon.Name = "Icon"
healIcon.Size = UDim2.fromOffset(36, 36)
healIcon.Position = UDim2.new(0, 10, 0.5, 0)
healIcon.AnchorPoint = Vector2.new(0, 0.5)
healIcon.BackgroundTransparency = 1
healIcon.TextScaled = true
healIcon.Text = "💚"
healIcon.ZIndex = 36
healIcon.Parent = healBanner

local healLbl = Instance.new("TextLabel")
healLbl.Name = "Label"
healLbl.Size = UDim2.new(1, -56, 0, 36)
healLbl.Position = UDim2.new(0, 50, 0.5, 0)
healLbl.AnchorPoint = Vector2.new(0, 0.5)
healLbl.BackgroundTransparency = 1
healLbl.TextScaled = true
healLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
healLbl.Text = "+250 HP Checkpoint Heal!"
healLbl.TextXAlignment = Enum.TextXAlignment.Left
healLbl.ZIndex = 36
healLbl.Parent = healBanner
styleTextLW(healLbl)

local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")

local function playCheckpointChime()
	local s = Instance.new("Sound")
	s.Name = "CheckpointChime"
	s.SoundId = "rbxassetid://7231519809"
	s.Volume = 0.85
	s.PlaybackSpeed = 1.0
	s.Parent = SoundService
	s:Play()
	Debris:AddItem(s, 3.5)
end

local function showCheckpointHealToast(customMsg)
	local msg = customMsg or "+250 HP Checkpoint Heal!"
	healLbl.Text = msg
	pcall(playCheckpointChime)
	healBanner.Visible = true
	healBanner.Position = UDim2.new(0.5, 0, 0, -60)

	local popIn = TS:Create(healBanner, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, 0, 52),
	})
	popIn:Play()

	task.delay(2.2, function()
		if healBanner and healBanner.Parent then
			local popOut = TS:Create(healBanner, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Position = UDim2.new(0.5, 0, 0, -60),
			})
			popOut:Play()
			popOut.Completed:Connect(function()
				healBanner.Visible = false
			end)
		end
	end)
end

local toastEvt = Remotes:FindFirstChild("Toast")
if toastEvt then
	toastEvt.OnClientEvent:Connect(function(msg, msgType)
		if type(msg) == "string" and (msg:find("Checkpoint Heal") or msg:find("250 HP") or msg:find("Checkpoint")) then
			showCheckpointHealToast(msg)
		end
	end)
end

local chEvt = Remotes:FindFirstChild("CheckpointHeal")
if chEvt then
	chEvt.OnClientEvent:Connect(function(amount)
		showCheckpointHealToast(string.format("+%d HP Checkpoint Heal!", amount or 250))
	end)
end

local lastZoneAttr = nil
workspace:GetAttributeChangedSignal("Zone"):Connect(function()
	local z = workspace:GetAttribute("Zone")
	local c = plr.Character
	local flying = c and c:GetAttribute("Flying") == true
	if flying and type(z) == "string" and z ~= "" and lastZoneAttr and z ~= lastZoneAttr then
		showCheckpointHealToast("+250 HP Checkpoint Heal!")
	end
	lastZoneAttr = z
end)

local function updateBountyBanner()
	local bt = workspace:GetAttribute("BountyTarget")
	local char = plr.Character
	local flying = char and char:GetAttribute("Flying") == true
	local spectating = plr:GetAttribute("Spectating") == true
	if (flying or spectating) and type(bt) == "string" and bt ~= "" then
		bountyLbl.Text = "BOUNTY: " .. string.upper(bt) .. " (+150c / +5g)"
		bountyBanner.Visible = true
	else
		bountyBanner.Visible = false
	end
end
workspace:GetAttributeChangedSignal("BountyTarget"):Connect(updateBountyBanner)
-- Live Rival Ahead / #1 Indicator (LuckyWheelButton style)
local oldRival = gui:FindFirstChild("RivalBanner")
if oldRival then oldRival:Destroy() end
local rivalBanner = Instance.new("Frame")
rivalBanner.Name = "RivalBanner"
rivalBanner.Size = UDim2.fromOffset(290, 30)
rivalBanner.Position = UDim2.new(0.5, 0, 0, 120)
rivalBanner.AnchorPoint = Vector2.new(0.5, 0)
rivalBanner.Visible = false
rivalBanner.Parent = gui
applyLuckyWheelStyle(rivalBanner, Color3.fromRGB(55, 165, 255), Color3.fromRGB(25, 75, 175), Color3.fromRGB(150, 225, 255), Color3.new(1,1,1), 10)
local rivalLbl = Instance.new("TextLabel")
rivalLbl.Name = "Label"
rivalLbl.Size = UDim2.fromScale(0.94, 0.84)
rivalLbl.Position = UDim2.fromScale(0.5, 0.48)
rivalLbl.AnchorPoint = Vector2.new(0.5, 0.5)
rivalLbl.BackgroundTransparency = 1
rivalLbl.TextScaled = true
rivalLbl.TextColor3 = Color3.new(1, 1, 1)
rivalLbl.ZIndex = 6
rivalLbl.Parent = rivalBanner
styleTextLW(rivalLbl)

-- Photo Finish Flash & #1 Victory Banner
local pfRemEvt = Remotes:FindFirstChild("PhotoFinish")
if pfRemEvt then
	pfRemEvt.OnClientEvent:Connect(function(place)
		local flash = Instance.new("Frame")
		flash.Size = UDim2.fromScale(1, 1)
		flash.BackgroundColor3 = Color3.new(1, 1, 1)
		flash.BackgroundTransparency = 0.25
		flash.ZIndex = 50
		flash.Parent = gui
		TS:Create(flash, TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
		task.delay(0.7, function() flash:Destroy() end)

		if cam then
			local oldFov = cam.FieldOfView
			TS:Create(cam, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { FieldOfView = math.max(52, oldFov - 18) }):Play()
			task.delay(0.75, function()
				if cam then TS:Create(cam, TweenInfo.new(0.35), { FieldOfView = oldFov }):Play() end
			end)
		end

		local vic = Instance.new("Frame")
		vic.Size = UDim2.fromOffset(360, 68)
		vic.Position = UDim2.new(0.5, 0, 0.28, 0)
		vic.AnchorPoint = Vector2.new(0.5, 0.5)
		vic.ZIndex = 40
		vic.Parent = gui
		applyLuckyWheelStyle(vic, Color3.fromRGB(255, 215, 55), Color3.fromRGB(220, 120, 15), Color3.new(1,1,1), Color3.fromRGB(255, 240, 140), 16)
		local vLbl = Instance.new("TextLabel", vic)
		vLbl.Size = UDim2.fromScale(0.92, 0.85)
		vLbl.Position = UDim2.fromScale(0.5, 0.48)
		vLbl.AnchorPoint = Vector2.new(0.5, 0.5)
		vLbl.BackgroundTransparency = 1
		vLbl.TextScaled = true
		vLbl.TextColor3 = Color3.new(1, 1, 1)
		vLbl.Text = (place == 1) and "#1 VICTORY!" or ("TOP " .. tostring(place) .. " FINISH!")
		vLbl.ZIndex = 46
		styleTextLW(vLbl)
		task.delay(1.8, function() vic:Destroy() end)
	end)
end

RunService.RenderStepped:Connect(function()
	local char = plr.Character
	local flying = char and char:GetAttribute("Flying") == true
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not flying or not hrp then
		rivalBanner.Visible = false
		return
	end
	local myZ = hrp.Position.Z
	local bestName, bestZ = nil, myZ
	for _, m in ipairs(workspace:GetChildren()) do
		if m ~= char and m:IsA("Model") and m:GetAttribute("Flying") == true then
			local oRoot = m:FindFirstChild("HumanoidRootPart")
			if oRoot and oRoot.Position.Z < bestZ then
				bestZ = oRoot.Position.Z
				bestName = m.Name
			end
		end
	end
	if bestName then
		local distM = math.max(1, math.floor((myZ - bestZ) + 0.5))
		rivalLbl.Text = string.format("^ %dm to #1 (%s)", distM, bestName)
		rivalBanner.Visible = true
	else
		rivalLbl.Text = "IN THE LEAD (#1)!"
		rivalBanner.Visible = true
	end
end)



local btnCols = {
	Dash = { Color3.fromRGB(65, 205, 255), Color3.fromRGB(20, 115, 220), Color3.fromRGB(150, 235, 255) },
	AbilityBtn = { Color3.fromRGB(255, 195, 55), Color3.fromRGB(220, 105, 15), Color3.fromRGB(255, 235, 130) },
	Brake = { Color3.fromRGB(185, 100, 255), Color3.fromRGB(110, 40, 205), Color3.fromRGB(220, 170, 255) },
}
for _, b in ipairs({ dashBtn, abBtn, brakeBtn }) do
	local c = btnCols[b.Name]
	if c then
		b.ZIndex = 2
		applyLuckyWheelStyle(b, c[1], c[2], c[3], Color3.new(1,1,1), 12)
		styleTextLW(b)
		for _, child in ipairs(b:GetChildren()) do
			if child:IsA("TextLabel") then
				child.ZIndex = math.max(child.ZIndex, 4)
				styleTextLW(child)
			elseif child.Name == "CD" and child:IsA("GuiObject") then
				child.ZIndex = math.max(child.ZIndex, 5)
			end
		end
	end
end

-- 1. ALL-PLAYERS TRACK PROGRESS / HEIGHT BAR (WITH PROFILE PICTURES)
local oldTrackBar = gui:FindFirstChild("TrackProgressBar")
if oldTrackBar then oldTrackBar:Destroy() end

if energyBack then
	energyBack.Position = UDim2.new(0.5, 0, 1, -98)
	energyBack.Size = UDim2.fromOffset(320, 22)
end
row.Position = UDim2.new(0.5, 0, 1, -18)
if comboLabel then
	comboLabel.Position = UDim2.new(0.5, 0, 1, -186)
end

local trackBar = Instance.new("Frame")
trackBar.Name = "TrackProgressBar"
trackBar.Size = UDim2.fromOffset(560, 38)
trackBar.Position = UDim2.new(0.5, 0, 1, -134)
trackBar.AnchorPoint = Vector2.new(0.5, 1)
trackBar.BackgroundColor3 = Color3.fromRGB(14, 18, 30)
trackBar.BackgroundTransparency = 0.08
trackBar.BorderSizePixel = 0
trackBar.Visible = false
trackBar.Parent = gui

local tbCorner = Instance.new("UICorner")
tbCorner.CornerRadius = UDim.new(0, 14)
tbCorner.Parent = trackBar

local tbStroke = Instance.new("UIStroke")
tbStroke.Thickness = 2.5
tbStroke.Color = Color3.fromRGB(85, 165, 255)
tbStroke.Transparency = 0.15
tbStroke.Parent = trackBar

local tbGrad = Instance.new("UIGradient")
tbGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 28, 46)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(14, 18, 32)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(26, 30, 48)),
})
tbGrad:Destroy()
applyLuckyWheelStyle(trackBar, Color3.fromRGB(48, 65, 115), Color3.fromRGB(22, 30, 58), Color3.fromRGB(125, 195, 255), Color3.new(1,1,1), 14)

local trackRail = Instance.new("Frame")
trackRail.Name = "Rail"
trackRail.Size = UDim2.new(1, -124, 0, 12)
trackRail.Position = UDim2.fromScale(0.5, 0.56)
trackRail.AnchorPoint = Vector2.new(0.5, 0.5)
trackRail.BackgroundColor3 = Color3.fromRGB(28, 34, 52)
trackRail.BorderSizePixel = 0
trackRail.Parent = trackBar
trackRail.ZIndex = 6

local railCorner = Instance.new("UICorner")
railCorner.CornerRadius = UDim.new(1, 0)
railCorner.Parent = trackRail

local railStroke = Instance.new("UIStroke")
railStroke.Thickness = 1.5
railStroke.Color = Color3.fromRGB(55, 75, 115)
railStroke.Parent = trackRail

local railFill = Instance.new("Frame")
railFill.Name = "Fill"
railFill.Size = UDim2.fromScale(0, 1)
railFill.BackgroundColor3 = Color3.fromRGB(85, 220, 255)
railFill.BorderSizePixel = 0
railFill.Parent = trackRail

local rfCorner = Instance.new("UICorner")
rfCorner.CornerRadius = UDim.new(1, 0)
rfCorner.Parent = railFill

local rfGrad = Instance.new("UIGradient")
rfGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 165, 255)),
	ColorSequenceKeypoint.new(0.7, Color3.fromRGB(95, 235, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 220, 85)),
})
rfGrad.Parent = railFill

-- Milestone ticks (25%, 50%, 75%)
for _, pct in ipairs({ 0.25, 0.5, 0.75 }) do
	local tickMark = Instance.new("Frame")
	tickMark.Size = UDim2.fromOffset(2, 14)
	tickMark.Position = UDim2.fromScale(pct, 0.5)
	tickMark.AnchorPoint = Vector2.new(0.5, 0.5)
	tickMark.BackgroundColor3 = Color3.fromRGB(180, 210, 255)
	tickMark.BackgroundTransparency = 0.65
	tickMark.BorderSizePixel = 0
	tickMark.ZIndex = 2
	tickMark.Parent = trackRail
end

local startLbl = Instance.new("TextLabel")
startLbl.Name = "StartLbl"
startLbl.Size = UDim2.fromOffset(52, 24)
startLbl.Position = UDim2.new(0, 8, 0.5, 0)
startLbl.AnchorPoint = Vector2.new(0, 0.5)
startLbl.BackgroundTransparency = 1
startLbl.ZIndex = 6
styleTextLW(startLbl)
startLbl.Text = "START"
startLbl.TextSize = 12
startLbl.TextColor3 = Color3.fromRGB(165, 195, 235)
startLbl.Parent = trackBar

local finishLbl = Instance.new("TextLabel")
finishLbl.Name = "FinishLbl"
finishLbl.Size = UDim2.fromOffset(52, 24)
finishLbl.Position = UDim2.new(1, -8, 0.5, 0)
finishLbl.AnchorPoint = Vector2.new(1, 0.5)
finishLbl.BackgroundTransparency = 1
finishLbl.ZIndex = 6
styleTextLW(finishLbl)
finishLbl.Text = "0%"
finishLbl.TextSize = 14
finishLbl.TextColor3 = Color3.fromRGB(255, 220, 85)
finishLbl.Parent = trackBar

local pinsFolder = Instance.new("Folder")
pinsFolder.Name = "Pins"
pinsFolder.Parent = trackRail

local thumbCache = {}
local function getPlayerThumb(userId)
	if not userId or userId <= 0 then return nil end
	if thumbCache[userId] ~= nil then return thumbCache[userId] end
	thumbCache[userId] = ""
	task.spawn(function()
		local ok, url = pcall(function()
			return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
		end)
		if ok and url then
			thumbCache[userId] = url
		end
	end)
	return thumbCache[userId]
end

local function populateBotHeadViewport(vp, botModel)
	pcall(function()
		vp:ClearAllChildren()
		local wm = Instance.new("WorldModel")
		wm.Parent = vp
		local head = botModel:FindFirstChild("Head")
		if not head then return end

		local cloneModel = Instance.new("Model")
		local hClone = head:Clone()
		hClone.Anchored = true
		hClone.CanCollide = false
		hClone.CFrame = CFrame.new(0, 0, 0)
		hClone.Parent = cloneModel

		for _, acc in ipairs(botModel:GetChildren()) do
			if acc:IsA("Accessory") then
				local handle = acc:FindFirstChild("Handle")
				if handle and handle:IsA("BasePart") then
					local ac = handle:Clone()
					ac.Anchored = true
					ac.CanCollide = false
					ac.CFrame = head.CFrame:ToObjectSpace(handle.CFrame)
					ac.Parent = cloneModel
				end
			end
		end
		cloneModel.Parent = wm

		local vCam = Instance.new("Camera")
		vCam.FieldOfView = 38
		vCam.CFrame = CFrame.lookAt(Vector3.new(0, 0.15, -2.55), Vector3.new(0, 0.05, 0))
		vCam.Parent = vp
		vp.CurrentCamera = vCam
	end)
end

-- 2. CORNER MATCH EVENTS INDICATOR (Zone + Weather + Mutator)
-- =====================================================================
local oldEventBadge = gui:FindFirstChild("EventCornerBadge")
if oldEventBadge then oldEventBadge:Destroy() end

local eventBadge = Instance.new("Frame")
eventBadge.Name = "EventCornerBadge"
eventBadge.Size = UDim2.fromOffset(220, 64)
eventBadge.Position = UDim2.new(1, -18, 0, 16)
eventBadge.AnchorPoint = Vector2.new(1, 0)
eventBadge.BackgroundColor3 = Color3.fromRGB(16, 20, 32)
eventBadge.BackgroundTransparency = 0.15
eventBadge.BorderSizePixel = 0
eventBadge.Visible = false
eventBadge.Parent = gui

local ebCorner = Instance.new("UICorner")
ebCorner.CornerRadius = UDim.new(0, 12)
ebCorner.Parent = eventBadge

local ebStroke = Instance.new("UIStroke")
ebStroke.Thickness = 2
ebStroke.Color = Color3.fromRGB(90, 180, 255)
ebStroke.Transparency = 0.2
ebStroke:Destroy()
applyLuckyWheelStyle(eventBadge, Color3.fromRGB(70, 45, 125), Color3.fromRGB(32, 22, 65), Color3.fromRGB(185, 130, 255), Color3.new(1,1,1), 12)

local zoneTitle = Instance.new("TextLabel")
zoneTitle.Name = "ZoneTitle"
zoneTitle.Size = UDim2.new(1, -16, 0, 22)
zoneTitle.Position = UDim2.fromOffset(8, 5)
zoneTitle.BackgroundTransparency = 1
zoneTitle.ZIndex = 6
styleTextLW(zoneTitle)
zoneTitle.Text = "📍 SKY ISLANDS"
zoneTitle.TextSize = 14
zoneTitle.TextXAlignment = Enum.TextXAlignment.Right
zoneTitle.TextColor3 = Color3.fromRGB(255, 235, 130)
zoneTitle.Parent = eventBadge

local weatherTitle = Instance.new("TextLabel")
weatherTitle.Name = "WeatherTitle"
weatherTitle.Size = UDim2.new(1, -16, 0, 18)
weatherTitle.Position = UDim2.fromOffset(8, 26)
weatherTitle.BackgroundTransparency = 1
weatherTitle.ZIndex = 6
styleTextLW(weatherTitle)
weatherTitle.Text = "☀ CLEAR SKIES"
weatherTitle.TextSize = 12
weatherTitle.TextXAlignment = Enum.TextXAlignment.Right
weatherTitle.TextColor3 = Color3.fromRGB(150, 225, 255)
weatherTitle.Parent = eventBadge

local mutatorTitle = Instance.new("TextLabel")
mutatorTitle.Name = "MutatorTitle"
mutatorTitle.Size = UDim2.new(1, -16, 0, 16)
mutatorTitle.Position = UDim2.fromOffset(8, 44)
mutatorTitle.BackgroundTransparency = 1
mutatorTitle.ZIndex = 6
styleTextLW(mutatorTitle)
mutatorTitle.Text = "⚡ STANDARD RACE"
mutatorTitle.TextSize = 11
mutatorTitle.TextXAlignment = Enum.TextXAlignment.Right
mutatorTitle.TextColor3 = Color3.fromRGB(205, 175, 255)
mutatorTitle.Parent = eventBadge

-- =====================================================================
-- 3. MOUSE UNLOCK BUTTON ([M] CURSOR: UNLOCKED / LOCKED)
-- =====================================================================
local oldMouseBtn = gui:FindFirstChild("MouseUnlockBtn")
if oldMouseBtn then oldMouseBtn:Destroy() end

local mouseBtn = Instance.new("TextButton")
mouseBtn.Name = "MouseUnlockBtn"
mouseBtn.Size = UDim2.fromOffset(124, 48)
mouseBtn.Position = UDim2.new(0.5, 202, 1, -32)
mouseBtn.AnchorPoint = Vector2.new(0, 1)
mouseBtn.BackgroundColor3 = Color3.fromRGB(28, 36, 54)
mouseBtn.AutoButtonColor = true
mouseBtn.Modal = true
mouseBtn.Font = Enum.Font.FredokaOne
mouseBtn.Text = "🖱️ [M] FREE"
mouseBtn.TextSize = 14
mouseBtn.TextColor3 = Color3.fromRGB(130, 245, 170)
mouseBtn.Visible = false
mouseBtn.Parent = gui

local mbCorner = Instance.new("UICorner")
mbCorner.CornerRadius = UDim.new(0, 12)
mbCorner.Parent = mouseBtn

local mbStroke = Instance.new("UIStroke")
mbStroke.Thickness = 2
mbStroke.Color = Color3.fromRGB(90, 220, 140)
mbStroke:Destroy()
applyLuckyWheelStyle(mouseBtn, Color3.fromRGB(45, 195, 115), Color3.fromRGB(18, 125, 65), Color3.fromRGB(140, 255, 185), Color3.new(1,1,1), 12)
styleTextLW(mouseBtn)

local function updateMouseBtnVisual()
	local unlocked = plr:GetAttribute("MouseUnlocked") ~= false
	local flying = plr.Character and plr.Character:GetAttribute("Flying") == true
	local spectating = plr:GetAttribute("Spectating") == true
	mouseBtn.Visible = flying
	mouseBtn.Modal = (flying and unlocked) or spectating
	if unlocked then
		mouseBtn.Text = "🖱️ [M] FREE"
		mouseBtn.TextColor3 = Color3.fromRGB(130, 245, 170)
		mbStroke.Color = Color3.fromRGB(90, 220, 140)
	else
		mouseBtn.Text = "🔒 [M] LOCKED"
		mouseBtn.TextColor3 = Color3.fromRGB(255, 205, 110)
		mbStroke.Color = Color3.fromRGB(240, 170, 70)
	end
end

mouseBtn.Activated:Connect(function()
	UIAction:Fire("ToggleMouse")
end)
plr:GetAttributeChangedSignal("MouseUnlocked"):Connect(updateMouseBtnVisual)

-- =====================================================================
-- 4. SPECTATE BAR (< PREV | SPECTATING: Name | NEXT > | EXIT)
-- =====================================================================
local oldSpecBar = gui:FindFirstChild("SpectateBar")
if oldSpecBar then oldSpecBar:Destroy() end

local specBar = Instance.new("Frame")
specBar.Name = "SpectateBar"
specBar.Size = UDim2.fromOffset(440, 42)
specBar.Position = UDim2.new(0.5, 0, 0, 54)
specBar.AnchorPoint = Vector2.new(0.5, 0)
specBar.BackgroundColor3 = Color3.fromRGB(18, 22, 34)
specBar.BackgroundTransparency = 0.1
specBar.BorderSizePixel = 0
specBar.Visible = false
specBar.Parent = gui

local sbCorner = Instance.new("UICorner")
sbCorner.CornerRadius = UDim.new(0, 12)
sbCorner.Parent = specBar

local sbStroke = Instance.new("UIStroke")
sbStroke.Thickness = 2
sbStroke.Color = Color3.fromRGB(100, 195, 255)
sbStroke.Parent = specBar

local function makeSpecBtn(name, text, pos, size, bgCol)
	local b = Instance.new("TextButton")
	b.Name = name
	b.Position = pos
	b.Size = size
	b.AnchorPoint = Vector2.new(0, 0.5)
	b.BackgroundColor3 = bgCol or Color3.fromRGB(36, 46, 68)
	b.Font = Enum.Font.FredokaOne
	b.Text = text
	b.TextSize = 14
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.Modal = true
	b.Parent = specBar
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = b
	return b
end

local prevSpecBtn = makeSpecBtn("PrevBtn", "◀ PREV", UDim2.new(0, 8, 0.5, 0), UDim2.fromOffset(70, 30))
local nextSpecBtn = makeSpecBtn("NextBtn", "NEXT ▶", UDim2.new(1, -152, 0.5, 0), UDim2.fromOffset(70, 30))
local exitSpecBtn = makeSpecBtn("ExitBtn", "✕ EXIT", UDim2.new(1, -76, 0.5, 0), UDim2.fromOffset(68, 30), Color3.fromRGB(215, 55, 65))

local specTargetLbl = Instance.new("TextLabel")
specTargetLbl.Name = "TargetLabel"
specTargetLbl.Position = UDim2.new(0, 84, 0.5, 0)
specTargetLbl.Size = UDim2.fromOffset(198, 30)
specTargetLbl.AnchorPoint = Vector2.new(0, 0.5)
specTargetLbl.BackgroundTransparency = 1
specTargetLbl.Font = Enum.Font.FredokaOne
specTargetLbl.Text = "🎥 SPECTATING"
specTargetLbl.TextSize = 15
specTargetLbl.TextScaled = true
specTargetLbl.TextColor3 = Color3.fromRGB(130, 230, 255)
specTargetLbl.Parent = specBar

-- Collect all active flyers in the match (players + bots)
local specIndex = 1
local specTargetModel = nil
local specYaw = 0
local specPitch = 0.15

local function getActiveFlyers()
	local list = {}
	for _, p in ipairs(Players:GetPlayers()) do
		local c = p.Character
		if c and c:GetAttribute("Flying") == true and c:FindFirstChild("HumanoidRootPart") then
			table.insert(list, {
				model = c,
				name = p.DisplayName or p.Name,
				isPlayer = true,
				isMe = (p == plr),
				prestige = p:GetAttribute("Prestige") or 0,
			})
		end
	end
	local botsFolder = workspace:FindFirstChild("Bots")
	if botsFolder then
		for _, b in ipairs(botsFolder:GetChildren()) do
			if b:GetAttribute("Flying") == true and b:FindFirstChild("HumanoidRootPart") then
				table.insert(list, {
					model = b,
					name = b:GetAttribute("FlyerName") or b.Name,
					isPlayer = false,
					isMe = false,
					prestige = 0,
				})
			end
		end
	end
	table.sort(list, function(a, b)
		local pa = a.model:GetAttribute("TrackProgress") or 0
		local pb = b.model:GetAttribute("TrackProgress") or 0
		return pa > pb
	end)
	return list
end

local function resolveAbilityForSkinAndOverride(skinName, overrideAb)
	local sig = (Config.WingAbilities and Config.WingAbilities[skinName or "Cardboard"]) or "Slap"
	local chosen = (overrideAb and overrideAb ~= "" and Config.Abilities[overrideAb] and overrideAb) or sig
	return chosen, Config.Abilities[chosen]
end

local function resolveAbility()
	local chosen, def = resolveAbilityForSkinAndOverride(currentSkin, activeOverride)
	activeAbility = chosen
	if def then
		abBtn.SubText.Text = string.upper(def.Name)
		if def.Color then abBtn.BackgroundColor3 = def.Color end
	end
end

local function refreshPrestige(presValue)
	local badge = hpBar:FindFirstChild("PrestigeBadge")
	if not badge then return end
	local pres = math.max(0, math.floor(presValue or plr:GetAttribute("Prestige") or 0))
	local txt = badge:FindFirstChild("Text")
	local st = badge:FindFirstChildOfClass("UIStroke")
	if txt and txt:IsA("TextLabel") then
		txt.ZIndex = math.max(txt.ZIndex, badge.ZIndex + 1)
		txt.Text = "★ P" .. tostring(pres)
		txt.TextColor3 = (pres > 0 and PRES_COLORS[math.clamp(pres, 1, 10)]) or Color3.fromRGB(190, 200, 220)
	end
	if st then
		st.Color = (pres > 0 and PRES_COLORS[math.clamp(pres, 1, 10)]) or Color3.fromRGB(95, 105, 125)
	end
	badge.BackgroundColor3 = (pres > 0) and Color3.fromRGB(28, 26, 44) or Color3.fromRGB(32, 36, 50)
end

local function updateCornerEvents()
	updateBountyBanner()
	local z = workspace:GetAttribute("Zone") or "Sky Islands"
	local w = workspace:GetAttribute("WeatherEvent") or ""
	local m = workspace:GetAttribute("MutatorName") or ""

	zoneTitle.Text = "📍 " .. string.upper(tostring(z))
	if w == "Rain" then
		weatherTitle.Text = "🌧️ MONSOON RAIN"
		weatherTitle.TextColor3 = Color3.fromRGB(120, 195, 255)
	elseif w == "Snow" then
		weatherTitle.Text = "❄️ BLIZZARD SNOW"
		weatherTitle.TextColor3 = Color3.fromRGB(220, 245, 255)
	elseif w == "Lightning" then
		weatherTitle.Text = "⚡ LIGHTNING STORM"
		weatherTitle.TextColor3 = Color3.fromRGB(255, 230, 95)
	else
		weatherTitle.Text = "☀️ CLEAR SKIES"
		weatherTitle.TextColor3 = Color3.fromRGB(145, 235, 175)
	end

	if m ~= "" and m ~= "None" then
		mutatorTitle.Text = "🔥 " .. string.upper(tostring(m))
	else
		mutatorTitle.Text = "🏁 STANDARD RACE"
	end
end

workspace:GetAttributeChangedSignal("Zone"):Connect(updateCornerEvents)
workspace:GetAttributeChangedSignal("WeatherEvent"):Connect(updateCornerEvents)
workspace:GetAttributeChangedSignal("MutatorName"):Connect(updateCornerEvents)

local function updateViewedHPAndAbility(viewedModel, viewedPrestige)
	if not viewedModel then return end
	local maxHp = viewedModel:GetAttribute('MaxHP') or (Config and (Config.LiveMaxHP or Config.MaxHP)) or 2000
	if maxHp <= 0 then maxHp = 2000 end
	local hp = viewedModel:GetAttribute("HP") or maxHp
	local currentHP = math.clamp(math.floor(hp + 0.5), 0, maxHp)
	local frac = math.clamp(currentHP / maxHp, 0, 1)
	TS:Create(fill, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
		Size = UDim2.fromScale(frac, 1),
		BackgroundColor3 = Color3.fromRGB(245, 70, 75):Lerp(Color3.fromRGB(85, 230, 110), frac),
	}):Play()
	local pres = math.max(0, math.floor(viewedPrestige or 0))
	refreshPrestige(pres)
	local formattedHP = string.format("%d / %d HP", currentHP, maxHp)
	hpLbl.Text = (pres > 0)
		and string.format("★ P%d | %s", pres, formattedHP)
		or formattedHP

	local altLbl = hpBar:FindFirstChild("TextLabel")
	if altLbl and altLbl:IsA("TextLabel") and altLbl ~= hpLbl then
		altLbl.Text = formattedHP
	end

	local skin = viewedModel:GetAttribute("Skin") or currentSkin
	local ov = viewedModel:GetAttribute("ActiveAbility")
	if viewedModel == plr.Character then
		skin = currentSkin
		ov = activeOverride
	end
	local _, def = resolveAbilityForSkinAndOverride(skin, ov)
	if def then
		abBtn.SubText.Text = string.upper(def.Name)
		if def.Color then abBtn.BackgroundColor3 = def.Color end
	end
end

local function refresh()
	local char = plr.Character
	local flying = char and char:GetAttribute("Flying") == true
	local spectating = (not flying) and (plr:GetAttribute("Spectating") == true)
	local inMatchHud = flying or spectating

	gui.Enabled = true
	hpBar.Visible = inMatchHud
	row.Visible = inMatchHud
	trackBar.Visible = inMatchHud
	eventBadge.Visible = inMatchHud
	specBar.Visible = spectating
	if paceMeter then paceMeter.Visible = flying end
	if energyBack then energyBack.Visible = flying end
	if speedoFrame then speedoFrame.Visible = flying end
	if not flying and draftBadge then draftBadge.Visible = false end
	if hubNav then hubNav.Visible = not inMatchHud end

	updateMouseBtnVisual()
	updateCornerEvents()

	if flying and char then
		resolveAbility()
		updateViewedHPAndAbility(char, plr:GetAttribute("Prestige") or 0)
	elseif spectating and specTargetModel then
		local pObj = Players:GetPlayerFromCharacter(specTargetModel)
		updateViewedHPAndAbility(specTargetModel, pObj and pObj:GetAttribute("Prestige") or 0)
	end
end

plr:GetAttributeChangedSignal("Prestige"):Connect(refresh)
plr:GetAttributeChangedSignal("Spectating"):Connect(function()
	if not plr:GetAttribute("Spectating") then
		specTargetModel = nil
		if not (plr.Character and plr.Character:GetAttribute("Flying") == true) and not plr:GetAttribute("InPodiumCutscene") then
			cam.CameraType = Enum.CameraType.Custom
		end
	else
		local list = getActiveFlyers()
		if #list > 0 then
			specIndex = 1
			specTargetModel = list[1].model
		end
	end
	refresh()
end)

workspace:GetAttributeChangedSignal("Phase"):Connect(function()
	local phase = workspace:GetAttribute("Phase")
	if phase ~= "Flight" and plr:GetAttribute("Spectating") then
		plr:SetAttribute("Spectating", false)
	end
	refresh()
end)

prevSpecBtn.Activated:Connect(function()
	local list = getActiveFlyers()
	if #list == 0 then return end
	specIndex = ((specIndex - 2) % #list) + 1
	specTargetModel = list[specIndex].model
	refresh()
end)

nextSpecBtn.Activated:Connect(function()
	local list = getActiveFlyers()
	if #list == 0 then return end
	specIndex = (specIndex % #list) + 1
	specTargetModel = list[specIndex].model
	refresh()
end)

exitSpecBtn.Activated:Connect(function()
	IrisTransition.Play(function()
		plr:SetAttribute("Spectating", false)
		cam.CameraType = Enum.CameraType.Custom
	end, 0.06, 0.24, 0.3)
end)

UIS.InputChanged:Connect(function(input)
	if not plr:GetAttribute("Spectating") then return end
	if input.UserInputType == Enum.UserInputType.MouseMovement and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
		specYaw = specYaw - input.Delta.X * 0.005
		specPitch = math.clamp(specPitch - input.Delta.Y * 0.005, -0.45, 0.75)
	elseif input.UserInputType == Enum.UserInputType.Touch and input.UserInputState == Enum.UserInputState.Change then
		specYaw = specYaw - input.Delta.X * 0.006
		specPitch = math.clamp(specPitch - input.Delta.Y * 0.006, -0.45, 0.75)
	end
end)

Remotes:WaitForChild("Stats").OnClientEvent:Connect(function(s)
	if s then
		if s.Skin then currentSkin = s.Skin end
		activeOverride = (s.ActiveAbility and s.ActiveAbility ~= "") and s.ActiveAbility or nil
		resolveAbility()
	end
	refresh()
end)

local charConns = {}
local function bind(c)
	for _, cn in ipairs(charConns) do cn:Disconnect() end
	table.clear(charConns)
	table.insert(charConns, c:GetAttributeChangedSignal("HP"):Connect(refresh))
	table.insert(charConns, c:GetAttributeChangedSignal("Flying"):Connect(function()
		if c:GetAttribute("Flying") == true and plr:GetAttribute("Spectating") then
			plr:SetAttribute("Spectating", false)
		end
		refresh()
	end))
	refresh()
end
plr.CharacterAdded:Connect(bind)
if plr.Character then bind(plr.Character) end

dashBtn.Activated:Connect(function()
	if plr.Character and plr.Character:GetAttribute("Flying") == true then
		UIAction:Fire("Dash", true)
	end
end)
brakeBtn.InputBegan:Connect(function(i)
	if plr.Character and plr.Character:GetAttribute("Flying") == true then
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			UIAction:Fire("Brake", true)
		end
	end
end)
brakeBtn.InputEnded:Connect(function(i)
	if plr.Character and plr.Character:GetAttribute("Flying") == true then
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			UIAction:Fire("Brake", false)
		end
	end
end)
abBtn.Activated:Connect(function()
	if plr.Character and plr.Character:GetAttribute("Flying") == true then
		UIAction:Fire("Ability", true)
		UIAction:Fire(activeAbility, true)
	end
end)

CooldownEvent.Event:Connect(function(name, dur)
	local targetBtn = (name == "Dash" and dashBtn) or (name == "Brake" and brakeBtn) or abBtn
	local keyName = (name == "Dash" or name == "Brake") and name or "Ability"
	ends[keyName] = os.clock() + dur
	local cd, cdText = targetBtn.CD, targetBtn.CDText
	if dur <= 0 then
		cd.Visible = false
		cdText.Text = ""
		return
	end
	cd.Visible = true
	cd.Size = UDim2.fromScale(1, 1)
	TS:Create(cd, TweenInfo.new(dur, Enum.EasingStyle.Linear), { Size = UDim2.fromScale(1, 0) }):Play()
end)

-- Live Track Progress Pins + Spectate Camera + Cooldowns
local pinCache = {}

RunService.RenderStepped:Connect(function(dt)
	local char = plr.Character
	local flying = char and char:GetAttribute("Flying") == true
	local spectating = (not flying) and (plr:GetAttribute("Spectating") == true)
	if not flying and not spectating then
		if speedoFrame then speedoFrame.Visible = false end
		if draftBadge then draftBadge.Visible = false end
		return
	end

	-- Update Digital Speedometer
	local myHrp = char and char:FindFirstChild("HumanoidRootPart")
	if flying and myHrp then
		speedoFrame.Visible = true
		if lastSpeedHrpPos and dt > 0 then
			local deltaDist = (myHrp.Position - lastSpeedHrpPos).Magnitude
			local instSpd = deltaDist / dt
			measuredSpeedSPS = measuredSpeedSPS + (instSpd - measuredSpeedSPS) * math.min(1, dt * 10)
		end
		lastSpeedHrpPos = myHrp.Position

		local baseSpeed = (workspace:GetAttribute("Speed") or (Config and (Config.FlightSpeed or 100)) or 100)
			* (plr:GetAttribute("PrestigeSpeedMult") or 1)
			* (plr:GetAttribute("TrainingSpeedMult") or 1)
		local topCapSPS = baseSpeed * 1.45
		local isDrafting = (char:GetAttribute("Slipstream") == true)

		local displaySpd = math.max(0, math.floor(measuredSpeedSPS + 0.5))
		speedValLbl.Text = tostring(displaySpd)
		if isDrafting then
			speedValLbl.TextColor3 = Color3.fromRGB(90, 255, 195)
			speedCapLbl.Text = string.format("TOP CAP: %d STUDS/S (+45%% DRAFT CAP)", math.floor(topCapSPS + 0.5))
			speedCapLbl.TextColor3 = Color3.fromRGB(90, 255, 195)
		else
			speedValLbl.TextColor3 = Color3.fromRGB(255, 235, 90)
			speedCapLbl.Text = string.format("TOP CAP: %d STUDS/S (+45%% DRAFT CAP)", math.floor(topCapSPS + 0.5))
			speedCapLbl.TextColor3 = Color3.fromRGB(160, 215, 255)
		end
	else
		lastSpeedHrpPos = nil
		if speedoFrame then speedoFrame.Visible = false end
	end

	-- Update Draft Status Badge (Pulsating glow when Slipstream active)
	local isSlipstream = flying and (char:GetAttribute("Slipstream") == true)
	if isSlipstream then
		draftBadge.Visible = true
		local pulse = (math.sin(os.clock() * 8) + 1) * 0.5
		draftGlowStroke.Color = Color3.fromRGB(0, 225, 255):Lerp(Color3.fromRGB(255, 235, 100), pulse)
		draftGlowStroke.Thickness = 2.5 + pulse * 2.0
		draftGlowStroke.Transparency = 0.05 + pulse * 0.25
		draftLbl.TextColor3 = Color3.new(1, 1, 1):Lerp(Color3.fromRGB(255, 245, 175), pulse)
	else
		draftBadge.Visible = false
	end

	local flyers = getActiveFlyers()
	local viewedModel = char

	if spectating then
		if #flyers == 0 then
			plr:SetAttribute("Spectating", false)
			return
		end
		local found = false
		for i, entry in ipairs(flyers) do
			if entry.model == specTargetModel then
				specIndex = i
				found = true
				break
			end
		end
		if not found then
			specIndex = math.clamp(specIndex, 1, #flyers)
			specTargetModel = flyers[specIndex].model
		end
		viewedModel = specTargetModel
		local targetEntry = flyers[specIndex]
		specTargetLbl.Text = string.format("🎥 %s (#%d/%d)", string.upper(targetEntry.name), specIndex, #flyers)
		updateViewedHPAndAbility(viewedModel, targetEntry.prestige)

		-- Spectate Camera Follow
		local hrp = viewedModel and viewedModel:FindFirstChild("HumanoidRootPart")
		if hrp then
			cam.CameraType = Enum.CameraType.Scriptable
			local lookDir = (hrp.CFrame * CFrame.Angles(0, specYaw, 0) * CFrame.Angles(-specPitch, 0, 0)).LookVector
			local desiredPos = hrp.Position - lookDir * 24 + Vector3.new(0, 6, 0)
			local desiredCF = CFrame.lookAt(desiredPos, hrp.Position + hrp.CFrame.LookVector * 10 + Vector3.new(0, 2, 0))
			cam.CFrame = cam.CFrame:Lerp(desiredCF, math.min(1, dt * 12))
		end

		-- Show spectated flyer's Dash & Ability cooldowns
		local srvNow = workspace:GetServerTimeNow()
		local dStamp = viewedModel:GetAttribute("LastDashStamp") or 0
		local dCD = viewedModel:GetAttribute("LastDashCD") or 0
		local dLeft = math.max(0, (dStamp + dCD) - srvNow)
		dashBtn.CD.Visible = dLeft > 0
		dashBtn.CD.Size = (dCD > 0 and dLeft > 0) and UDim2.fromScale(1, math.clamp(dLeft / dCD, 0, 1)) or UDim2.fromScale(1, 0)
		dashBtn.CDText.Text = dLeft > 0 and string.format("%.1f", dLeft) or ""

		local aStamp = viewedModel:GetAttribute("LastAbilityStamp") or 0
		local aCD = viewedModel:GetAttribute("LastAbilityCD") or 0
		local aLeft = math.max(0, (aStamp + aCD) - srvNow)
		abBtn.CD.Visible = aLeft > 0
		abBtn.CD.Size = (aCD > 0 and aLeft > 0) and UDim2.fromScale(1, math.clamp(aLeft / aCD, 0, 1)) or UDim2.fromScale(1, 0)
		abBtn.CDText.Text = aLeft > 0 and string.format("%.1f", aLeft) or ""
	else
		-- Local player cooldowns
		local now = os.clock()
		for name, e in pairs(ends) do
			local b = (name == "Dash" and dashBtn) or (name == "Brake" and brakeBtn) or abBtn
			local left = e - now
			if left > 0 then
				b.CDText.Text = string.format("%.1f", left)
			else
				b.CDText.Text = ""
				b.CD.Visible = false
				ends[name] = nil
			end
		end
	end

	-- Update All-Players Track Progress Bar (with Avatar Profile Portraits)
	local seen = {}
	local viewedProg = (viewedModel and viewedModel:GetAttribute("TrackProgress")) or 0
	railFill.Size = UDim2.fromScale(math.clamp(viewedProg, 0, 1), 1)
	finishLbl.Text = string.format("%d%%", math.floor(math.clamp(viewedProg, 0, 1) * 100 + 0.5))

	local placedX = {}
	for idx, entry in ipairs(flyers) do
		local m = entry.model
		seen[m] = true
		local pin = pinCache[m]
		if not pin then
			pin = Instance.new("Frame")
			pin.Name = "Pin_" .. entry.name
			pin.AnchorPoint = Vector2.new(0.5, 0.5)
			pin.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
			pin.BorderSizePixel = 0
			pin.Parent = pinsFolder

			local pc = Instance.new("UICorner")
			pc.CornerRadius = UDim.new(1, 0)
			pc.Parent = pin

			local ps = Instance.new("UIStroke")
			ps.Name = "RingStroke"
			ps.Thickness = 2.5
			ps.Color = Color3.fromRGB(90, 215, 255)
			ps.Parent = pin

			if entry.isPlayer then
				local img = Instance.new("ImageLabel")
				img.Name = "AvatarImg"
				img.Size = UDim2.fromScale(1, 1)
				img.BackgroundTransparency = 1
				img.ScaleType = Enum.ScaleType.Crop
				img.Parent = pin
				local ic = Instance.new("UICorner")
				ic.CornerRadius = UDim.new(1, 0)
				ic.Parent = img
				local pObj = Players:GetPlayerFromCharacter(m)
				if pObj then
					local url = getPlayerThumb(pObj.UserId)
					if url and url ~= "" then img.Image = url end
				end
			else
				local vp = Instance.new("ViewportFrame")
				vp.Name = "BotVP"
				vp.Size = UDim2.fromScale(1, 1)
				vp.BackgroundTransparency = 1
				vp.LightColor = Color3.fromRGB(255, 255, 255)
				vp.Ambient = Color3.fromRGB(210, 215, 230)
				vp.Parent = pin
				local vc = Instance.new("UICorner")
				vc.CornerRadius = UDim.new(1, 0)
				vc.Parent = vp
				populateBotHeadViewport(vp, m)
			end

			local tag = Instance.new("TextLabel")
			tag.Name = "Tag"
			tag.Size = UDim2.fromOffset(58, 13)
			tag.Position = UDim2.new(0.5, 0, 0, -2)
			tag.AnchorPoint = Vector2.new(0.5, 1)
			tag.BackgroundTransparency = 1
			tag.Font = Enum.Font.FredokaOne
			tag.TextSize = 11
			tag.TextStrokeTransparency = 0.25
			tag.Parent = pin
			pinCache[m] = pin
		end

		if entry.isPlayer then
			local img = pin:FindFirstChild("AvatarImg")
			local pObj = Players:GetPlayerFromCharacter(m)
			if img and pObj and img.Image == "" then
				local url = getPlayerThumb(pObj.UserId)
				if url and url ~= "" then img.Image = url end
			end
		end

		local baseProg = math.clamp(m:GetAttribute("TrackProgress") or 0, 0, 1)
		local packOff = math.clamp(m:GetAttribute("PackOffset") or 0, -1, 1)
		local visX = math.clamp(baseProg + packOff * 0.055, 0.03, 0.97)

		-- Lightly stagger Y if two portraits overlap horizontally so every face is visible
		local yOff = 0
		for _, px in ipairs(placedX) do
			if math.abs(px - visX) < 0.032 then
				yOff = (yOff == 0) and -6 or ((yOff < 0) and 6 or 0)
			end
		end
		table.insert(placedX, visX)

		local isViewed = (m == viewedModel)
		pin.Position = UDim2.new(visX, 0, 0.5, yOff)
		pin.Size = isViewed and UDim2.fromOffset(32, 32) or (entry.isPlayer and UDim2.fromOffset(26, 26) or UDim2.fromOffset(24, 24))
		pin.ZIndex = isViewed and 24 or (entry.isPlayer and 16 or (12 - math.min(idx, 6)))

		local ps = pin:FindFirstChild("RingStroke")
		if ps then
			ps.Thickness = isViewed and 3 or 2
			ps.Color = isViewed and Color3.fromRGB(255, 225, 65)
				or (entry.isPlayer and Color3.fromRGB(90, 215, 255) or Color3.fromRGB(165, 180, 215))
		end

		local tag = pin:FindFirstChild("Tag")
		if tag then
			tag.ZIndex = pin.ZIndex + 2
			if isViewed then
				tag.Text = entry.isMe and "YOU" or string.sub(string.upper(entry.name), 1, 7)
				tag.TextColor3 = Color3.fromRGB(255, 235, 85)
				tag.Visible = true
			elseif idx == 1 or entry.isPlayer then
				tag.Text = "#" .. tostring(idx)
				tag.TextColor3 = Color3.fromRGB(185, 230, 255)
				tag.Visible = true
			else
				tag.Visible = false
			end
		end
	end

	for m, pin in pairs(pinCache) do
		if not seen[m] then
			pin:Destroy()
			pinCache[m] = nil
		end
	end
end)

refresh()

-- Ring Chain Combo, Air Dodge Indicator & Nemesis Marker (Light Vibrant Theme)
task.spawn(function()
	local RS2 = game:GetService("ReplicatedStorage")
	local Players2 = game:GetService("Players")
	local Remotes2 = RS2:WaitForChild("Remotes")
	local plr2 = Players2.LocalPlayer
	local fh = script.Parent
	local mh = plr2:WaitForChild("PlayerGui"):WaitForChild("MainHUD")
	local lw = mh:WaitForChild("LeftMenu"):WaitForChild("LuckyWheelButton")

	local comboBadge = lw:Clone()
	comboBadge.Name = "RingComboBadge"
	comboBadge.Size = UDim2.fromOffset(220, 46)
	comboBadge.Position = UDim2.new(0.5, 0, 0, 174)
	comboBadge.AnchorPoint = Vector2.new(0.5, 0)
	comboBadge.Visible = false
	local cbg = comboBadge:FindFirstChild("ButtonBackground")
	if cbg and cbg:FindFirstChild("BackgroundGradient") then
		cbg.BackgroundGradient.Color = ColorSequence.new(Color3.fromRGB(255, 245, 140), Color3.fromRGB(130, 245, 255))
	end
	local cic = comboBadge:FindFirstChild("Icon"); if cic then cic.Visible = false end
	local chit = comboBadge:FindFirstChild("HitTarget"); if chit then chit:Destroy() end
	comboBadge.Label.Position = UDim2.fromScale(0.5, 0.5)
	comboBadge.Label.Size = UDim2.fromScale(0.92, 0.8)
	comboBadge.Label.Text = "RING CHAIN x2"
	comboBadge.Parent = fh

	local airBadge = lw:Clone()
	airBadge.Name = "AirDodgeBadge"
	airBadge.Size = UDim2.fromOffset(170, 38)
	airBadge.Position = UDim2.new(0.5, 0, 1, -135)
	airBadge.AnchorPoint = Vector2.new(0.5, 1)
	airBadge.Visible = false
	local abg = airBadge:FindFirstChild("ButtonBackground")
	if abg and abg:FindFirstChild("BackgroundGradient") then
		abg.BackgroundGradient.Color = ColorSequence.new(Color3.fromRGB(160, 245, 255), Color3.fromRGB(115, 210, 255))
	end
	local aic = airBadge:FindFirstChild("Icon"); if aic then aic.Visible = false end
	local ahit = airBadge:FindFirstChild("HitTarget"); if ahit then ahit:Destroy() end
	airBadge.Label.Position = UDim2.fromScale(0.5, 0.5)
	airBadge.Label.Size = UDim2.fromScale(0.9, 0.78)
	airBadge.Label.Text = "[Q] AIR DODGE"
	airBadge.Parent = fh

	local rc = Remotes2:FindFirstChild("RingCombo")
	if rc then
		rc.OnClientEvent:Connect(function(combo, mult)
			if (combo or 0) >= 2 then
				comboBadge.Label.Text = string.format("RING CHAIN %d  (%dx)", combo, mult or 1)
				comboBadge.Visible = true
			else
				comboBadge.Visible = false
			end
		end)
	end

	local nemesisGui
	local nem = Remotes2:FindFirstChild("NemesisUpdate")
	if nem then
		nem.OnClientEvent:Connect(function(modelName, displayName, active)
			if nemesisGui then nemesisGui:Destroy(); nemesisGui = nil end
			if not active or not modelName or modelName == "" then return end
			local target = workspace:FindFirstChild(modelName)
			local head = target and (target:FindFirstChild("Head") or target:FindFirstChild("HumanoidRootPart"))
			if head then
				local bb = Instance.new("BillboardGui")
				bb.Name = "NemesisTag"
				bb.Size = UDim2.fromOffset(160, 44)
				bb.StudsOffset = Vector3.new(0, 4.5, 0)
				bb.AlwaysOnTop = true
				local lbl = Instance.new("TextLabel", bb)
				lbl.Size = UDim2.fromScale(1, 1)
				lbl.BackgroundColor3 = Color3.fromRGB(255, 85, 105)
				lbl.BackgroundTransparency = 0.15
				lbl.FontFace = lw.Label.FontFace
				lbl.Text = "NEMESIS: " .. tostring(displayName or modelName)
				lbl.TextColor3 = Color3.new(1, 1, 1)
				lbl.TextScaled = true
				Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 10)
				local st = Instance.new("UIStroke", lbl); st.Thickness = 2; st.Color = Color3.fromRGB(140, 20, 35)
				bb.Parent = head
				nemesisGui = bb
			end
		end)
	end

	game:GetService("RunService").RenderStepped:Connect(function()
		local ch = plr2.Character
		local flying = ch and ch:GetAttribute("Flying") == true
		airBadge.Visible = flying
		if not flying then comboBadge.Visible = false end
	end)
end)
