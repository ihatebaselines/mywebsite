--!nocheck
-- STUD WINGS FLIGHT v3 (revamp)
--  v3: acceleration-based strafing with snappy counter-steer, soft lane walls, energy BOOST (hold Shift / R2),
--      speed rings (combo), near-miss bonus, hit stagger + tumble, lane-aware chase camera, spline-correct collisions.
--  (v2 notes below still apply)
--  * momentum + inertia, wind gusts (telegraphed), damped springs for banking / pitch / yaw
--  * barrel roll (double-tap A/D or Space), loop / dive flip (double-tap W/S), all with server i-frames via 'Dash'
--  * chase camera in course-space with independent lag per axis, look-ahead, FOV kick, free look + auto-recenter, 3 camera modes (V)
--  * spline control points are cached per map (the old script rebuilt them every frame)
-- Server contract is unchanged: hrp position is course-relative (x right, y up, z back), orientation is cosmetic.
local Players = game:GetService('Players')
local RS = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local CAS = game:GetService('ContextActionService')
local UIS = game:GetService('UserInputService')
local TS = game:GetService('TweenService')
local Debris = game:GetService('Debris')
local Lighting = game:GetService('Lighting')
local SplineUtils = require(RS:WaitForChild('Shared'):WaitForChild('SplineUtils'))
local Config = require(RS:WaitForChild('Shared'):WaitForChild('Config'))
local UIFx = require(RS.Shared.UIFx)
local IrisTransition = require(RS.Shared.IrisTransition)
local AbilityVFX = require(RS.Shared.AbilityVFX)
local EffectBurst = require(RS.Shared:WaitForChild('EffectBurst'))
local Remotes = RS:WaitForChild('Remotes')
local UIAction = RS.Shared.UIAction
local CooldownEvent = RS.Shared.CooldownEvent

local plr = Players.LocalPlayer
local cam = workspace.CurrentCamera
local O, Box = Config.TrackOrigin, Config.Box
local controls = nil
local rad, clamp, exp = math.rad, math.clamp, math.exp
local TAU = math.pi * 2

task.spawn(function()
	local ps = plr:FindFirstChild('PlayerScripts') or plr:WaitForChild('PlayerScripts', 5)
	local pm = ps and (ps:FindFirstChild('PlayerModule') or ps:WaitForChild('PlayerModule', 3))
	if pm then pcall(function() controls = require(pm):GetControls() end) end
end)

local function newSpring(x) return { x = x or 0, v = 0 } end
local function spring(s, target, k, c, dt)
	local a = k * (target - s.x) - c * s.v
	s.v += a * dt
	s.x += s.v * dt
end
local function easeInOut(p) return p < 0.5 and 4 * p * p * p or 1 - ((-2 * p + 2) ^ 3) / 2 end

-- scale = multiplier on the wheel distance, h = height above the flyer, fov = FOV offset
local CAM_MODES = {
	{ name = 'Chase', scale = 1.0, h = 7.5, fov = 0 },
	{ name = 'Close', scale = 0.55, h = 3.5, fov = 4 },
	{ name = 'Wide', scale = 1.6, h = 18, fov = -4 },
}

local state = {
	flying = false, x = 0, y = 22, z = 0, vx = 0, vy = 0, vz = 0, knock = Vector3.zero,
	dashEnd = 0, dashDir = 1, dashY = nil, lastDir = 1, man = nil,
	braking = false, brakeLeft = Config.BrakeMax, brakeCd = 0, boostEnd = 0, lockEnd = 0,
	shake = 0, push = false, stats = nil, cds = {}, fov = 74, fovKick = 0,
	camYawOffset = 0, camPitchOffset = 0, camDistance = 24, camMode = 1, lastLook = 0, stick = Vector2.zero,
	camLocal = nil, sp = nil, camRoll = newSpring(0),
	gust = nil, nextGust = 0, currentChunkIdx = 1,
	crashing = false, crashT0 = 0, crashSpinDir = 1, recoverFromCF = nil, recoverStart = 0, recoverDur = 0.55,
	kDraft = 0, effectiveDrag = 6.2, dynamicMaxSpeed = 0,
}state.sp = { yaw = newSpring(0), bank = newSpring(0), pitch = newSpring(0) }

local F = Config.Flight
local function lerp(a, b, t) return a + (b - a) * t end
state.energy, state.boostHeld, state.boosting, state.lastDrain = F.EnergyMax * 0.6, false, false, 0
state.staggerEnd, state.lastHitT, state.tumble = 0, 0, newSpring(0)
state.combo, state.comboT, state.cand, state.nextScan, state.edge = 0, 0, {}, 0, 0
-- v4 camera springs: distance (boost pull-back / hit punch), look-ahead yaw, FOV warp, vertical lag
state.camDist, state.camPunch, state.camLead, state.camVLag = newSpring(24), newSpring(0), newSpring(0), newSpring(0)
state.speedPulse = 0

-- ===== HUD: energy bar + combo text =====
local hud, energyFill, comboLabel, comboToken = nil, nil, nil, 0
local paceMarker, paceStreakLabel = nil, nil
local buildPace, destroyPace -- forward declarations (defined below, called from setFlying)
local PACE_COL_AHEAD, PACE_COL_MID, PACE_COL_BACK = Color3.fromRGB(90, 255, 140), Color3.fromRGB(255, 235, 110), Color3.fromRGB(255, 80, 70)
-- Anime Speed Lines + Camera Shake on Boost / Heavy Casts
local speedGui, speedLines = nil, {}
local function ensureSpeedLines()
	if speedGui and speedGui.Parent then return end
	local pg = plr:FindFirstChild("PlayerGui")
	if not pg then return end
	speedGui = Instance.new("ScreenGui")
	speedGui.Name = "SW_SpeedLinesGui"
	speedGui.IgnoreGuiInset = true
	speedGui.ResetOnSpawn = false
	speedGui.DisplayOrder = 5
	speedGui.Parent = pg
	table.clear(speedLines)
	for i = 1, 20 do
		local line = Instance.new("Frame")
		line.BorderSizePixel = 0
		line.BackgroundColor3 = Color3.fromRGB(220, 245, 255)
		line.BackgroundTransparency = 1
		line.AnchorPoint = Vector2.new(0.5, 0.5)
		local ang = (i / 20) * math.pi * 2
		local radDist = 0.56
		line.Position = UDim2.fromScale(0.5 + math.cos(ang) * radDist, 0.5 + math.sin(ang) * radDist)
		line.Size = UDim2.new(0.22, 0, 0, 3)
		line.Rotation = math.deg(ang)
		line.Parent = speedGui
		table.insert(speedLines, line)
	end
end

local function updateSpeedLines(alpha)
	if alpha <= 0.02 then
		if speedGui then speedGui.Enabled = false end
		return
	end
	ensureSpeedLines()
	if not speedGui then return end
	speedGui.Enabled = true
	local t = os.clock()
	for i, line in ipairs(speedLines) do
		local pulse = 0.5 + 0.5 * math.sin(t * 24 + i * 1.7)
		line.BackgroundTransparency = math.clamp(1 - alpha * (0.25 + 0.55 * pulse), 0.15, 1)
	end
end

-- ============================================================================
-- SLIPSTREAM VFX & FLIGHT AUDIO POLISH (R5)
-- ============================================================================
local SoundService = game:GetService('SoundService')

local slipstreamBeam = nil
local slipstreamAtt0 = nil
local slipstreamAtt1 = nil
local slipstreamLeaderModel = nil
local slipstreamParticles = nil

local flightWhooshSound = nil
local draftHumSound = nil
local lastAudioPos = nil
local lastBoostingActive = false
local flapAudioCooldown = 0

local function initFlightAudio()
	if not flightWhooshSound or not flightWhooshSound.Parent then
		flightWhooshSound = SoundService:FindFirstChild("FlightWhooshLoop")
		if not flightWhooshSound then
			flightWhooshSound = Instance.new("Sound")
			flightWhooshSound.Name = "FlightWhooshLoop"
			flightWhooshSound.SoundId = "rbxassetid://127183292018512"
			flightWhooshSound.Looped = true
			flightWhooshSound.Volume = 0
			flightWhooshSound.PlaybackSpeed = 1.0
			flightWhooshSound.RollOffMaxDistance = 250
			flightWhooshSound.Parent = SoundService
		end
	end

	if not draftHumSound or not draftHumSound.Parent then
		draftHumSound = SoundService:FindFirstChild("DraftThrusterHum")
		if not draftHumSound then
			draftHumSound = Instance.new("Sound")
			draftHumSound.Name = "DraftThrusterHum"
			draftHumSound.SoundId = "rbxassetid://2852749304"
			draftHumSound.Looped = true
			draftHumSound.Volume = 0
			draftHumSound.PlaybackSpeed = 1.0
			draftHumSound.RollOffMaxDistance = 250
			draftHumSound.Parent = SoundService
		end
	end
end

local function playOneShotSfx(soundId, vol, speed)
	pcall(function()
		local s = Instance.new("Sound")
		s.SoundId = soundId
		s.Volume = vol or 0.7
		s.PlaybackSpeed = speed or 1.0
		s.Parent = SoundService
		s:Play()
		Debris:AddItem(s, 4.5)
	end)
end

local function updateSlipstreamBeam(hrpPart, charModel, leaderModel, kDraft)
	if not hrpPart or not charModel or not leaderModel or kDraft <= 0.15 then
		if slipstreamBeam then
			slipstreamBeam.Enabled = false
		end
		if slipstreamParticles then
			slipstreamParticles.Enabled = false
		end
		if slipstreamAtt1 and slipstreamAtt1.Parent then
			slipstreamAtt1:Destroy()
			slipstreamAtt1 = nil
		end
		slipstreamLeaderModel = nil
		return
	end

	-- Resolve Attachment0 on drafting player (Torso.WINGS or hrp)
	if not slipstreamAtt0 or not slipstreamAtt0.Parent then
		local torso = charModel:FindFirstChild("Torso")
		slipstreamAtt0 = (torso and torso:FindFirstChild("WINGS")) or hrpPart:FindFirstChild("SlipstreamSelfAtt")
		if not slipstreamAtt0 then
			slipstreamAtt0 = Instance.new("Attachment")
			slipstreamAtt0.Name = "SlipstreamSelfAtt"
			slipstreamAtt0.Position = Vector3.new(0, 0.4, -0.8)
			slipstreamAtt0.Parent = hrpPart
		end
	end

	-- Resolve Attachment1 on leader model (wake/torso/hrp)
	local leaderHrp = leaderModel:FindFirstChild("HumanoidRootPart")
	local leaderTorso = leaderModel:FindFirstChild("Torso")
	if not leaderHrp and not leaderTorso then return end

	if slipstreamLeaderModel ~= leaderModel or not slipstreamAtt1 or not slipstreamAtt1.Parent then
		if slipstreamAtt1 and slipstreamAtt1.Parent then slipstreamAtt1:Destroy() end
		slipstreamLeaderModel = leaderModel
		local parentPart = leaderTorso or leaderHrp
		slipstreamAtt1 = parentPart:FindFirstChild("SlipstreamWakeAtt")
		if not slipstreamAtt1 then
			slipstreamAtt1 = Instance.new("Attachment")
			slipstreamAtt1.Name = "SlipstreamWakeAtt"
			slipstreamAtt1.Position = Vector3.new(0, -0.2, 1.8)
			slipstreamAtt1.Parent = parentPart
		end
	end

	-- Create Slipstream Beam if needed
	if not slipstreamBeam or not slipstreamBeam.Parent then
		slipstreamBeam = Instance.new("Beam")
		slipstreamBeam.Name = "SlipstreamDraftBeam"
		slipstreamBeam.FaceCamera = true
		slipstreamBeam.Segments = 12
		slipstreamBeam.Texture = "rbxassetid://446111271"
		slipstreamBeam.TextureMode = Enum.TextureMode.Wrap
		slipstreamBeam.TextureLength = 12
		slipstreamBeam.LightEmission = 0.85
		slipstreamBeam.LightInfluence = 0
		slipstreamBeam.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(110, 240, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 220, 255)),
		})
		slipstreamBeam.Parent = hrpPart
	end

	-- Create Slipstream Wind Particles on player if needed
	if not slipstreamParticles or not slipstreamParticles.Parent then
		slipstreamParticles = Instance.new("ParticleEmitter")
		slipstreamParticles.Name = "SlipstreamWindParticles"
		slipstreamParticles.Texture = "rbxassetid://243098098"
		slipstreamParticles.Color = ColorSequence.new(Color3.fromRGB(130, 240, 255))
		slipstreamParticles.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.4),
			NumberSequenceKeypoint.new(1, 1.6)
		})
		slipstreamParticles.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(1, 1.0)
		})
		slipstreamParticles.Lifetime = NumberRange.new(0.25, 0.5)
		slipstreamParticles.Speed = NumberRange.new(18, 35)
		slipstreamParticles.SpreadAngle = Vector2.new(10, 10)
		slipstreamParticles.LightEmission = 0.75
		slipstreamParticles.Parent = slipstreamAtt0
	end

	slipstreamBeam.Attachment0 = slipstreamAtt0
	slipstreamBeam.Attachment1 = slipstreamAtt1
	slipstreamBeam.Enabled = true
	slipstreamParticles.Enabled = true

	local draftNorm = math.clamp((kDraft - 0.15) / 0.85, 0, 1)
	local beamTrans = math.clamp(0.85 - draftNorm * 0.65, 0.15, 0.85)
	slipstreamBeam.Transparency = NumberSequence.new(beamTrans)
	slipstreamBeam.Width0 = 0.8 + draftNorm * 1.4
	slipstreamBeam.Width1 = 2.2 + draftNorm * 3.5
	slipstreamBeam.TextureSpeed = 3.5 + draftNorm * 4.0
	slipstreamParticles.Rate = math.floor(15 + draftNorm * 30)
end

local function cleanupSlipstreamVFX()
	if slipstreamBeam then
		slipstreamBeam.Enabled = false
		slipstreamBeam:Destroy()
		slipstreamBeam = nil
	end
	if slipstreamParticles then
		slipstreamParticles.Enabled = false
		slipstreamParticles:Destroy()
		slipstreamParticles = nil
	end
	if slipstreamAtt1 and slipstreamAtt1.Parent then
		slipstreamAtt1:Destroy()
		slipstreamAtt1 = nil
	end
	slipstreamLeaderModel = nil
end

local function stopFlightAudio()
	if flightWhooshSound and flightWhooshSound.IsPlaying then
		flightWhooshSound.Volume = 0
		flightWhooshSound:Stop()
	end
	if draftHumSound and draftHumSound.IsPlaying then
		draftHumSound.Volume = 0
		draftHumSound:Stop()
	end
end

local function buildHud()
	local pg = plr:FindFirstChildOfClass('PlayerGui') or plr:WaitForChild('PlayerGui', 5)
	hud = pg and pg:FindFirstChild('FlightHud') or (pg and pg:WaitForChild('FlightHud', 5))
	if not hud then return end
	local back = hud:WaitForChild('EnergyBack')
	energyFill = back:WaitForChild('EnergyFill')
	local lbl = back:FindFirstChild('BoostLabel')
	if lbl then lbl.Text = UIS.GamepadEnabled and 'BOOST  ·  R2' or 'BOOST  ·  SHIFT' end
	comboLabel = hud:WaitForChild('ComboLabel')
	comboLabel.TextTransparency = 1
	comboLabel.TextStrokeTransparency = 1
	local pm = hud:WaitForChild('PaceMeter')
	paceMarker = pm:WaitForChild('PaceMarker')
	paceStreakLabel = pm:WaitForChild('PaceStreak')
	paceStreakLabel.Text = ''
	hud.Enabled = true
end
local function showCombo(text, color)
	if not comboLabel then return end
	comboToken += 1
	local tok = comboToken
	comboLabel.Text = text comboLabel.TextColor3 = color comboLabel.TextTransparency = 0 comboLabel.TextStrokeTransparency = 0.2 comboLabel.TextSize = 40
	TS:Create(comboLabel, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { TextSize = 30 }):Play()
	task.delay(0.9, function()
		if tok == comboToken and comboLabel then
			TS:Create(comboLabel, TweenInfo.new(0.5), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
		end
	end)
end

-- velocity follows the stick: gentle accel, hard counter-steer, glide when released
local function follow(v, tv, fast, dt, dragOverride)
	local resp
	if fast then resp = 18
	elseif tv == 0 then resp = dragOverride or (state and state.effectiveDrag) or F.Drag
	elseif v * tv < 0 and math.abs(v) > 6 then resp = F.CounterAccel
	else resp = F.Accel end
	return v + (tv - v) * (1 - exp(-resp * dt))
end

-- obstacle queries (collision stop + near-miss bonus)
local obsParams = OverlapParams.new()
obsParams.FilterType = Enum.RaycastFilterType.Include
local obsFolderCached = nil
local function getObsFolder()
	if obsFolderCached and obsFolderCached.Parent then return obsFolderCached end
	local trk = workspace:FindFirstChild('Track')
	local f = trk and trk:FindFirstChild('Obstacles')
	if f then obsFolderCached = f obsParams.FilterDescendantsInstances = { f } end
	return f
end

local char, hrp, hum
local trailL, trailR, attL1, attL2, attR1, attR2, windEmitter, windE

-- cached course control points (one table per map instead of one per frame)
local cpCache = {}
local function getCourse(mapId)
	local diff = workspace:GetAttribute('Difficulty') or 'Medium'
	local seed = workspace:GetAttribute('CourseSeed') or 0
	local style = workspace:GetAttribute('RouteStyle') or 'Sweeping'
	local key = tostring(mapId) .. '_' .. tostring(diff) .. '_' .. tostring(seed) .. '_' .. tostring(style)
	local c = cpCache[key]
	if not c then
		c = SplineUtils.GenerateCourseControlPoints(O, Config.TrackLength, mapId, diff, seed, style)
		cpCache[key] = c
	end
	return c
end

local function floatText(model, text, col)
	local head = model and model:FindFirstChild('Head') if not head then return end
	local g = Instance.new('BillboardGui') g.Size = UDim2.fromOffset(160, 42) g.StudsOffsetWorldSpace = Vector3.new(0, 5, 0) g.AlwaysOnTop = true g.Adornee = head g.Parent = head
	local l = Instance.new('TextLabel') l.Size = UDim2.fromScale(1, 1) l.BackgroundTransparency = 1 l.Font = Enum.Font.FredokaOne l.TextSize = 28 l.Text = text l.TextColor3 = col l.TextStrokeTransparency = 0 l.Parent = g
	TS:Create(g, TweenInfo.new(0.95, Enum.EasingStyle.Quad), { StudsOffsetWorldSpace = Vector3.new(0, 9.5, 0) }):Play()
	TS:Create(l, TweenInfo.new(0.95, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	Debris:AddItem(g, 1.05)
end

local function startBrake()
	if os.clock() < state.brakeCd or state.brakeLeft <= 0.05 then return end
	state.braking = true
end
local function stopBrake()
	if not state.braking then return end
	state.braking = false
	state.brakeCd = os.clock() + Config.BrakeCooldown
	CooldownEvent:Fire('Brake', Config.BrakeCooldown)
end

local function getInput()
	local mx, my = 0, 0
	if UIS:IsKeyDown(Enum.KeyCode.D) or UIS:IsKeyDown(Enum.KeyCode.Right) then mx += 1 end
	if UIS:IsKeyDown(Enum.KeyCode.A) or UIS:IsKeyDown(Enum.KeyCode.Left) then mx -= 1 end
	if UIS:IsKeyDown(Enum.KeyCode.W) or UIS:IsKeyDown(Enum.KeyCode.Up) then my += 1 end
	if UIS:IsKeyDown(Enum.KeyCode.S) or UIS:IsKeyDown(Enum.KeyCode.Down) then my -= 1 end
	if UIS.GamepadEnabled then
		local pads = UIS:GetConnectedGamepads()
		if #pads > 0 then
			pcall(function()
				for _, st in ipairs(UIS:GetGamepadState(pads[1])) do
					if st.KeyCode == Enum.KeyCode.Thumbstick1 then
						if math.abs(st.Position.X) > 0.12 then mx += st.Position.X end
						if math.abs(st.Position.Y) > 0.12 then my += st.Position.Y end
					end
				end
			end)
		end
	end
	if mx == 0 and my == 0 and controls then
		pcall(function()
			local mv = controls:GetMoveVector()
			if mv then mx += mv.X; my += -mv.Z end
		end)
	end
	local mag = math.sqrt(mx * mx + my * my)
	if mag > 1 then mx /= mag; my /= mag end
	return mx, my
end

-- ===== maneuvers: barrel roll (sideways) and loop/dive flip (vertical). Share the Dash cooldown + server i-frames =====
local function startManeuver(kind, dir)
	local t = os.clock()
	if not state.flying or t < (state.cds.Dash or 0) then return false end
	state.cds.Dash = t + Config.DashCooldown
	CooldownEvent:Fire('Dash', Config.DashCooldown)
	if kind == 'roll' then
		state.man = { kind = 'roll', dir = dir, t0 = t, dur = 0.62 }
		state.dashDir = dir; state.dashY = nil; state.dashEnd = t + 0.38
		state.vx = dir * 105
	else
		state.man = { kind = 'loop', dir = dir, t0 = t, dur = 0.85 }
		state.dashY = dir; state.dashEnd = t + 0.32
		state.vy = dir * 85
	end
	state.fovKick = 14
	state.shake = math.min(6, state.shake + 1.2)
	playOneShotSfx("rbxassetid://5801273676", 0.75, 1.3)
	Remotes.Ability:FireServer('Dash') -- server broadcasts the Dash FX itself
	if kind == 'roll' then
		local ad = Remotes:FindFirstChild('AirDodge')
		if ad then ad:FireServer() end
	end
	return true
end

local function useDash()
	local mx = getInput()
	local dir = (math.abs(mx) > 0.2) and math.sign(mx) or state.lastDir
	startManeuver('roll', dir)
end

-- double-tap detection + camera mode switch
local lastTap = {}
local TAP_KEYS = {
	[Enum.KeyCode.A] = 'L', [Enum.KeyCode.Left] = 'L', [Enum.KeyCode.D] = 'R', [Enum.KeyCode.Right] = 'R',
	[Enum.KeyCode.W] = 'U', [Enum.KeyCode.Up] = 'U', [Enum.KeyCode.S] = 'S', [Enum.KeyCode.Down] = 'S',
}
UIS.InputBegan:Connect(function(input, gp)
	if not state.flying or gp then return end
	local kc = input.KeyCode
	if kc == Enum.KeyCode.Q then
		local mx = getInput()
		local dir = (math.abs(mx) > 0.2) and math.sign(mx) or state.lastDir
		startManeuver('roll', dir)
		return
	elseif kc == Enum.KeyCode.V then
		state.camMode = state.camMode % #CAM_MODES + 1
		state.camLocal = nil
		state.camDist.x = state.camDistance * CAM_MODES[state.camMode].scale
		return
	elseif kc == Enum.KeyCode.M or kc == Enum.KeyCode.Tab then
		state.mouseUnlocked = not state.mouseUnlocked
		plr:SetAttribute('MouseUnlocked', state.mouseUnlocked)
		UIS.MouseBehavior = state.mouseUnlocked and Enum.MouseBehavior.Default or Enum.MouseBehavior.LockCenter
		UIS.MouseIconEnabled = true
		return
	end
	local name = TAP_KEYS[kc]
	if not name then return end
	local now = os.clock()
	if now - (lastTap[name] or 0) < 0.3 then
		lastTap[name] = 0
		if name == 'L' then startManeuver('roll', -1)
		elseif name == 'R' then startManeuver('roll', 1)
		elseif name == 'U' then startManeuver('loop', 1)
		else startManeuver('loop', -1) end
	else
		lastTap[name] = now
	end
end)

-- free look: mouse, touch drag, right stick, wheel zoom
UIS.InputChanged:Connect(function(input, gp)
	if not state.flying then return end
	local ut = input.UserInputType
	if ut == Enum.UserInputType.MouseMovement then
		if state.mouseUnlocked and not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
		local d = input.Delta
		state.camYawOffset = clamp(state.camYawOffset - d.X * 0.0045, -2.6, 2.6)
		state.camPitchOffset = clamp(state.camPitchOffset - d.Y * 0.0045, -rad(75), rad(75))
		state.lastLook = os.clock()
	elseif ut == Enum.UserInputType.Touch and input.UserInputState == Enum.UserInputState.Change then
		local d = input.Delta
		state.camYawOffset = clamp(state.camYawOffset - d.X * 0.0055, -2.6, 2.6)
		state.camPitchOffset = clamp(state.camPitchOffset - d.Y * 0.0055, -rad(75), rad(75))
		state.lastLook = os.clock()
	elseif ut == Enum.UserInputType.MouseWheel then
		state.camDistance = clamp(state.camDistance - input.Position.Z * 3.0, 10, 48)
	elseif input.KeyCode == Enum.KeyCode.Thumbstick2 then
		local p = Vector2.new(input.Position.X, input.Position.Y)
		state.stick = (p.Magnitude > 0.18) and p or Vector2.zero
	end
end)

local function getActiveAbilityName()
	local ov = state.stats and state.stats.ActiveAbility
	if ov and ov ~= '' and Config.Abilities and Config.Abilities[ov] then return ov end
	local skin = (state.stats and state.stats.Skin) or 'Cardboard'
	if Config.WingAbilities and Config.WingAbilities[skin] then return Config.WingAbilities[skin] end
	return 'Slap'
end

local function triggerActiveAbility()
	if not state.flying then return end
	local name = getActiveAbilityName()
	local def = Config.Abilities[name] or Config.Abilities.Slap
	local t = os.clock()
	if t < (state.cds[name] or 0) then return end
	local skin = (state.stats and state.stats.Skin) or 'Cardboard'
	local wb = Config.GetWingBonus and Config.GetWingBonus(skin, name)
	local cd = math.max(1.5, def.Cooldown * ((wb and wb.CdMult) or 1.0))
	state.cds[name] = t + cd
	CooldownEvent:Fire('Ability', cd)
	CooldownEvent:Fire(name, cd)
	if name == 'Shield' then state.lockEnd = t + def.Duration end
	if name == 'Divebomb' then state.fovKick = 12; state.vy = -60 end
	if name == 'Surge' or name == 'RailgunSurge' then state.boostEnd = t + def.Duration; state.fovKick = 20 end
	Remotes.Ability:FireServer(name)
end

Remotes.Stats.OnClientEvent:Connect(function(s) state.stats = s end)

UIAction.Event:Connect(function(name, down)
	if name == 'Dash' then useDash()
	elseif name == 'Brake' then if down then startBrake() else stopBrake() end
	elseif name == 'ToggleMouse' then
		state.mouseUnlocked = not state.mouseUnlocked
		plr:SetAttribute('MouseUnlocked', state.mouseUnlocked)
		if state.flying then
			UIS.MouseBehavior = state.mouseUnlocked and Enum.MouseBehavior.Default or Enum.MouseBehavior.LockCenter
			UIS.MouseIconEnabled = true
		end
	else triggerActiveAbility() end
end)

local Sink = Enum.ContextActionResult.Sink
local HP = Enum.ContextActionPriority.High.Value

local function bindAll()
	CAS:BindActionAtPriority('SW_Dash', function(_, st)
		if st == Enum.UserInputState.Begin then useDash() end
		return Sink
	end, false, HP, Enum.KeyCode.Space, Enum.KeyCode.ButtonA)
	CAS:BindActionAtPriority('SW_Brake', function(_, st)
		if st == Enum.UserInputState.Begin then startBrake() elseif st == Enum.UserInputState.End then stopBrake() end
		return Sink
	end, false, HP, Enum.KeyCode.LeftAlt, Enum.KeyCode.RightAlt, Enum.KeyCode.ButtonL2)
	CAS:BindActionAtPriority('SW_UniversalAbility', function(_, st)
		if st == Enum.UserInputState.Begin then triggerActiveAbility() end
		return Sink
	end, false, HP, Enum.KeyCode.Q, Enum.KeyCode.E, Enum.KeyCode.F, Enum.KeyCode.ButtonX, Enum.KeyCode.ButtonY, Enum.KeyCode.ButtonR1)
	-- gamepad: B = loop up, L1 = loop down
	CAS:BindActionAtPriority('SW_Loop', function(_, st)
		if st == Enum.UserInputState.Begin then startManeuver('loop', 1) end
		return Sink
	end, false, HP, Enum.KeyCode.ButtonB)
	CAS:BindActionAtPriority('SW_Dive', function(_, st)
		if st == Enum.UserInputState.Begin then startManeuver('loop', -1) end
		return Sink
	end, false, HP, Enum.KeyCode.ButtonL1)
	CAS:BindActionAtPriority('SW_Boost', function(_, st)
		if st == Enum.UserInputState.Begin then state.boostHeld = true
		elseif st == Enum.UserInputState.End or st == Enum.UserInputState.Cancel then state.boostHeld = false end
		return Sink
	end, true, HP, Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift, Enum.KeyCode.ButtonR2)
	CAS:SetTitle('SW_Boost', 'BOOST')
	CAS:SetPosition('SW_Boost', UDim2.new(1, -150, 1, -190))
end
local function unbindAll()
	for _, n in ipairs({ 'SW_Dash', 'SW_Brake', 'SW_UniversalAbility', 'SW_Loop', 'SW_Dive', 'SW_Boost' }) do CAS:UnbindAction(n) end
end

local function createTrails(root)
	local color = ColorSequence.new(Color3.fromRGB(100, 210, 255), Color3.fromRGB(255, 255, 255))
	if state.stats and state.stats.Skin and Config.Skins[state.stats.Skin] then
		color = ColorSequence.new(Config.Skins[state.stats.Skin].Color, Color3.fromRGB(255, 255, 255))
	end
	local function trail(x)
		local a1 = Instance.new('Attachment') a1.Position = Vector3.new(x, 0.6, 0.2) a1.Parent = root
		local a2 = Instance.new('Attachment') a2.Position = Vector3.new(x, 0.6, 0.8) a2.Parent = root
		local tr = Instance.new('Trail') tr.Attachment0 = a1 tr.Attachment1 = a2
		tr.Lifetime = 0.45 tr.MinLength = 0.08 tr.LightEmission = 1
		tr.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 1) })
		tr.WidthScale = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1.3), NumberSequenceKeypoint.new(1, 0) })
		tr.Color = color tr.Parent = root
		return tr, a1, a2
	end
	trailL, attL1, attL2 = trail(-3.6)
	trailR, attR1, attR2 = trail(3.6)

	local camPart = Instance.new('Part') camPart.Name = 'WindEmitterPart' camPart.Size = Vector3.one
	camPart.Transparency = 1 camPart.CanCollide = false camPart.CanQuery = false camPart.CanTouch = false camPart.Anchored = true camPart.Parent = cam
	local e = Instance.new('ParticleEmitter') e.Texture = 'rbxasset://textures/particles/sparkles_main.dds'
	e.Rate = 35 e.Speed = NumberRange.new(50, 90) e.Lifetime = NumberRange.new(0.3, 0.5)
	e.SpreadAngle = Vector2.new(16, 16) e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 0) })
	e.LightEmission = 1 e.Color = ColorSequence.new(Color3.fromRGB(210, 240, 255)) e.Parent = camPart
	windEmitter, windE = camPart, e

	-- Rain / Snow weather emitters bound to camera
	local rainE = Instance.new('ParticleEmitter') rainE.Name = 'SW_RainE'
	rainE.Texture = 'rbxasset://textures/particles/sparkles_main.dds'
	rainE.Rate = 0 rainE.Speed = NumberRange.new(110, 160) rainE.Lifetime = NumberRange.new(0.2, 0.4)
	rainE.SpreadAngle = Vector2.new(12, 12) rainE.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 0.05) })
	rainE.LightEmission = 0.8 rainE.Color = ColorSequence.new(Color3.fromRGB(180, 225, 255))
	rainE.Acceleration = Vector3.new(0, -180, -90) rainE.Parent = camPart

	local snowE = Instance.new('ParticleEmitter') snowE.Name = 'SW_SnowE'
	snowE.Texture = 'rbxasset://textures/particles/snow_main.dds'
	snowE.Rate = 0 snowE.Speed = NumberRange.new(35, 75) snowE.Lifetime = NumberRange.new(0.6, 1.2)
	snowE.SpreadAngle = Vector2.new(30, 30) snowE.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.7), NumberSequenceKeypoint.new(1, 0.1) })
	snowE.LightEmission = 0.95 snowE.Color = ColorSequence.new(Color3.fromRGB(240, 248, 255))
	snowE.Acceleration = Vector3.new(0, -60, -40) snowE.Parent = camPart

	-- v4 wing aura: check Workspace.MOREAURAS first, fall back to procedural
	local skin = state.stats and state.stats.Skin or 'Cardboard'
	local fxLib = RS:FindFirstChild('FXLibrary') local moreAuras = workspace:FindFirstChild('MOREAURAS') or (fxLib and fxLib:FindFirstChild('MoreAuras'))
	local boundCustomAura = false

	if moreAuras then
		if skin == 'OneWing' then
			local tpl = moreAuras:FindFirstChild('one winged angel')
			if tpl then
				local wingPart = tpl:FindFirstChild('Wing') or tpl:FindFirstChildWhichIsA('BasePart')
				if wingPart then
					for _, em in ipairs(wingPart:GetChildren()) do
						if em:IsA('ParticleEmitter') then
							local cl = em:Clone() cl.Name = 'SW_SkinAura'
							cl:SetAttribute('Base', cl.Rate > 0 and cl.Rate or 18)
							cl.Parent = root
							boundCustomAura = true
						end
					end
					local pl = Instance.new('PointLight') pl.Name = 'SW_SkinLight' pl.Color = Color3.fromRGB(240, 240, 255) pl.Range = 16 pl.Brightness = 1.4 pl.Parent = root
				end
			end
		elseif skin == 'Lava' then
			local tpl = moreAuras:FindFirstChild('Manifestation of Chaos') or moreAuras:FindFirstChild('POF:RE AURA CORVUS')
			if tpl then
				for _, em in ipairs(tpl:GetDescendants()) do
					if em:IsA('ParticleEmitter') and (em.Name:lower():find('fire') or em.Name:lower():find('flame') or em.Name:lower():find('burn') or em.Name:lower():find('smoke')) then
						local cl = em:Clone() cl.Name = 'SW_SkinAura'
						cl:SetAttribute('Base', math.min(26, cl.Rate > 0 and cl.Rate or 20))
						cl.Rate = cl:GetAttribute('Base')
						cl.Parent = root
						boundCustomAura = true
					end
				end
				local pl = Instance.new('PointLight') pl.Name = 'SW_SkinLight' pl.Color = Color3.fromRGB(255, 75, 10) pl.Range = 16 pl.Brightness = 1.6 pl.Parent = root
			end
		end
	end

	if not boundCustomAura then
		local AURA = {
			Phoenix   = { col = Color3.fromRGB(255, 110, 30), rate = 26, rise = 6,  speed = 4, size = 1.1, tex = 'rbxasset://textures/particles/fire_main.dds' },
			Demon     = { col = Color3.fromRGB(190, 20, 60),  rate = 18, rise = 3,  speed = 3, size = 1.0, tex = 'rbxasset://textures/particles/smoke_main.dds' },
			Galaxy    = { col = Color3.fromRGB(150, 70, 255), rate = 30, rise = 0,  speed = 8, size = 0.5, tex = 'rbxasset://textures/particles/sparkles_main.dds' },
			Fairy     = { col = Color3.fromRGB(130, 255, 160), rate = 22, rise = -2, speed = 3, size = 0.6, tex = 'rbxasset://textures/particles/sparkles_main.dds' },
			GoldenStud= { col = Color3.fromRGB(255, 215, 0),  rate = 24, rise = -4, speed = 5, size = 0.7, tex = 'rbxasset://textures/particles/sparkles_main.dds' },
			Bat       = { col = Color3.fromRGB(140, 225, 255),rate = 20, rise = -3, speed = 4, size = 0.8, tex = 'rbxasset://textures/particles/snow_main.dds' },
			Glitch    = { col = Color3.fromRGB(0, 255, 200),  rate = 28, rise = 0,  speed = 10, size = 0.5, tex = 'rbxasset://textures/particles/sparkles_main.dds' },
			Mecha     = { col = Color3.fromRGB(90, 180, 255), rate = 16, rise = 0,  speed = 12, size = 0.4, tex = 'rbxasset://textures/particles/sparkles_main.dds' },
			Cartoon   = { col = Color3.fromRGB(255, 235, 90), rate = 20, rise = 2,  speed = 5, size = 0.8, tex = 'rbxasset://textures/particles/sparkles_main.dds' },
			Cardboard = { col = Color3.fromRGB(195, 150, 100),rate = 14, rise = -1, speed = 3, size = 0.6, tex = 'rbxasset://textures/particles/smoke_main.dds' },
			Lava      = { col = Color3.fromRGB(255, 75, 10),  rate = 28, rise = 5,  speed = 6, size = 1.0, tex = 'rbxasset://textures/particles/fire_main.dds' },
			OneWing   = { col = Color3.fromRGB(240, 245, 255),rate = 25, rise = 3,  speed = 4, size = 0.9, tex = 'rbxasset://textures/particles/sparkles_main.dds' },
		}
		local A = AURA[skin]
		if A then
			local em = Instance.new('ParticleEmitter') em.Name = 'SW_SkinAura'
			em.Texture = A.tex em.Rate = A.rate em.Lifetime = NumberRange.new(0.5, 1.1) em.Speed = NumberRange.new(A.speed * 0.5, A.speed)
			em.Acceleration = Vector3.new(0, A.rise, 0) em.SpreadAngle = Vector2.new(180, 180) em.LightEmission = 0.9
			em.Color = ColorSequence.new(A.col, A.col:Lerp(Color3.new(1, 1, 1), 0.5))
			em.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, A.size), NumberSequenceKeypoint.new(1, 0) })
			em.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1) })
			em.Rotation = NumberRange.new(0, 360) em.RotSpeed = NumberRange.new(-90, 90) em:SetAttribute('Base', A.rate) em.Parent = root
			local pl = Instance.new('PointLight') pl.Name = 'SW_SkinLight' pl.Color = A.col pl.Range = 14 pl.Brightness = 1.2 pl.Parent = root
		end
	end
end

local function removeTrails()
	for _, o in ipairs({ trailL, trailR, attL1, attL2, attR1, attR2, windEmitter }) do if o then o:Destroy() end end
	if hrp then
		local a = hrp:FindFirstChild('SW_SkinAura') if a then a:Destroy() end
		local l = hrp:FindFirstChild('SW_SkinLight') if l then l:Destroy() end
	end
	trailL, trailR, attL1, attL2, attR1, attR2, windEmitter, windE = nil, nil, nil, nil, nil, nil, nil, nil
	cleanupSlipstreamVFX()
	stopFlightAudio()
end

local function setFlying(on)
	if on == state.flying then return end
	state.flying = on
	if on then
		char = plr.Character hrp = char and char:FindFirstChild('HumanoidRootPart') hum = char and char:FindFirstChildOfClass('Humanoid')
		if not hrp then state.flying = false return end
		state.x, state.y, state.z, state.vx, state.vy, state.vz, state.knock = 0, 22, 0, 0, 0, 0, Vector3.zero
		state.braking = false state.brakeLeft = Config.BrakeMax state.brakeCd = 0 state.lockEnd = 0 state.boostEnd = 0 state.cds = {}
		state.camYawOffset, state.camPitchOffset, state.camDistance, state.camMode = 0, 0, 24, 1
		state.man, state.dashY, state.dashEnd, state.gust, state.fovKick, state.camLocal = nil, nil, 0, nil, 0, nil
		state.crashing, state.crashT0, state.recoverStart, state.recoverFromCF = false, 0, 0, nil
		state.nextGust = os.clock() + 9
		state.stick = Vector2.zero
		state.sp = { yaw = newSpring(0), bank = newSpring(0), pitch = newSpring(0) }
		state.camRoll = newSpring(0)
		state.camDist, state.camPunch, state.camLead, state.camVLag = newSpring(24), newSpring(0), newSpring(0), newSpring(0)
		state.speedPulse = 0
		state.energy, state.boostHeld, state.boosting, state.lastDrain = F.EnergyMax * 0.6, false, false, 0
		-- ResetLingeringBlur: ensure RollBlur / UIPackBlur never blind the player in flight
		for _, fx in ipairs(Lighting:GetChildren()) do
			if fx:IsA("BlurEffect") then fx.Size = 0 end
		end
		state.staggerEnd, state.lastHitT, state.tumble = 0, 0, newSpring(0)
		state.combo, state.comboT, state.cand, state.nextScan = 0, 0, {}, 0
		buildHud()
		state.paceStreak, state.paceMult = 0, 1
		buildPace()
		hum.PlatformStand = true hum.AutoRotate = false
		cam.CameraType = Enum.CameraType.Scriptable
		if state.mouseUnlocked == nil then state.mouseUnlocked = true end
		plr:SetAttribute('MouseUnlocked', state.mouseUnlocked)
		UIS.MouseBehavior = state.mouseUnlocked and Enum.MouseBehavior.Default or Enum.MouseBehavior.LockCenter
		UIS.MouseIconEnabled = true
		bindAll()
		createTrails(hrp)
		if IrisTransition then
			task.spawn(function() IrisTransition.Play(nil, 0.06, 0.25, 0.35) end)
		end
	else
		unbindAll()
		removeTrails()
		cleanupSlipstreamVFX()
		stopFlightAudio()
		state.boostHeld, state.boosting = false, false
		destroyPace() paceMarker, paceStreakLabel = nil, nil
		if hud then hud.Enabled = false end
		updateSpeedLines(0)
		UIS.MouseBehavior = Enum.MouseBehavior.Default
		UIS.MouseIconEnabled = true
		state.braking = false state.push = false state.man = nil
		if not plr:GetAttribute('InPodiumCutscene') and not plr:GetAttribute('Spectating') then
			cam.CameraType = Enum.CameraType.Custom
		end
		cam.FieldOfView = 70
		if hum and hum.Parent then hum.PlatformStand = false hum.AutoRotate = true end
		if workspace:GetAttribute('Phase') == 'Flight' and IrisTransition then
			task.spawn(function() IrisTransition.Play(nil, 0.06, 0.25, 0.35) end)
		end
	end
end

local conn, diedConn
local function watch(c)
	if conn then conn:Disconnect() end
	if diedConn then diedConn:Disconnect() end
	conn = c:GetAttributeChangedSignal('Flying'):Connect(function() setFlying(c:GetAttribute('Flying') == true) end)
	local h = c:FindFirstChildOfClass('Humanoid')
	if h then
		diedConn = h.Died:Connect(function()
			setFlying(false)
		end)
	end
	setFlying(c:GetAttribute('Flying') == true)
end
plr.CharacterAdded:Connect(function(c)
	setFlying(false)
	hrp = nil
	watch(c)
end)
if plr.Character then watch(plr.Character) end

-- biome atmosphere (only if Config.Chunks exists)
local function updateChunkAtmosphere(progress)
	if not Config.Chunks then return end
	local idx = 1
	for i, chk in ipairs(Config.Chunks) do
		if progress >= chk.Range[1] and progress <= chk.Range[2] then idx = i break end
	end
	if idx ~= state.currentChunkIdx then
		state.currentChunkIdx = idx
	end
end

-- ===== PACE CYLINDER: Massive 3D holographic slipstream tunnel (R=75, Length=60).
--  Frames the entire 140-stud highway and extends along the track as a volumetric flight cylinder.
--  Outer ring (R=75), Inner counter-rotating ring (R=62), Front Gateway Ring (Z=-28),
--  Rear Slipstream Ring (Z=+28), 8 longitudinal slipstream rails, holographic compass reticle,
--  and dynamic reactive lighting with generous forward/backward sprint distance.
local PACE_R_OUTER = 75
local PACE_SEGS_OUTER = 48
local PACE_R_INNER = 62
local PACE_SEGS_INNER = 36
local PACE_R_CORE = 48
local PACE_SEGS_CORE = 24
local PACE_SPOKES = 12
local PACE_CYL_RAILS = 8
local PACE_CYL_DEPTH = 90 -- distance of front and rear tunnel rings along Z

local paceFolder = nil
local paceOuterSegs = nil
local paceInnerSegs = nil
local paceCoreSegs = nil
local paceFrontSegs = nil
local paceRearSegs = nil
local paceCylRails = nil
local paceSpokes = nil
local paceCardinals = nil
local paceReticle = nil
local paceLight = nil
local paceColor = PACE_COL_MID

function buildPace()
	if paceFolder then paceFolder:Destroy() end
	paceFolder = Instance.new('Folder')
	paceFolder.Name = 'PaceRing'

	-- 1. Main Center Ring (Z=0, R=75)
	paceOuterSegs = {}
	local segLenOuter = 2 * PACE_R_OUTER * math.tan(math.pi / PACE_SEGS_OUTER) + 0.4
	for i = 1, PACE_SEGS_OUTER do
		local p = Instance.new('Part')
		p.Name = 'PaceOuter_' .. i
		p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.CastShadow = false
		p.Material = Enum.Material.Neon; p.Size = Vector3.new(segLenOuter, 1.5, 1.5)
		p.Color = PACE_COL_MID; p.Transparency = 0.2; p.Parent = paceFolder
		paceOuterSegs[i] = p
	end

	-- 2. Inner Gyroscopic Counter-Rotating Ring (Z=0, R=62)
	paceInnerSegs = {}
	local segLenInner = 2 * PACE_R_INNER * math.tan(math.pi / PACE_SEGS_INNER) + 0.3
	for i = 1, PACE_SEGS_INNER do
		local p = Instance.new('Part')
		p.Name = 'PaceInner_' .. i
		p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.CastShadow = false
		p.Material = Enum.Material.Neon; p.Size = Vector3.new(segLenInner, 1.2, 1.2)
		p.Color = PACE_COL_MID; p.Transparency = 0.28; p.Parent = paceFolder
		paceInnerSegs[i] = p
	end

	-- 3. Core Ring (Z=0, R=48)
	paceCoreSegs = {}
	local segLenCore = 2 * PACE_R_CORE * math.tan(math.pi / PACE_SEGS_CORE) + 0.3
	for i = 1, PACE_SEGS_CORE do
		local p = Instance.new('Part')
		p.Name = 'PaceCore_' .. i
		p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.CastShadow = false
		p.Material = Enum.Material.Neon; p.Size = Vector3.new(segLenCore, 0.9, 0.9)
		p.Color = PACE_COL_MID; p.Transparency = 0.45; p.Parent = paceFolder
		paceCoreSegs[i] = p
	end

	-- 4. Front Tunnel Ring (Z = -PACE_CYL_DEPTH, R=75)
	paceFrontSegs = {}
	local segLenFront = 2 * PACE_R_OUTER * math.tan(math.pi / 24) + 0.5
	for i = 1, 24 do
		local p = Instance.new('Part')
		p.Name = 'PaceFront_' .. i
		p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.CastShadow = false
		p.Material = Enum.Material.Neon; p.Size = Vector3.new(segLenFront, 1.1, 1.1)
		p.Color = PACE_COL_MID; p.Transparency = 0.45; p.Parent = paceFolder
		paceFrontSegs[i] = p
	end

	-- 5. Rear Tunnel Ring (Z = +PACE_CYL_DEPTH, R=75)
	paceRearSegs = {}
	for i = 1, 24 do
		local p = Instance.new('Part')
		p.Name = 'PaceRear_' .. i
		p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.CastShadow = false
		p.Material = Enum.Material.Neon; p.Size = Vector3.new(segLenFront, 1.1, 1.1)
		p.Color = PACE_COL_MID; p.Transparency = 0.55; p.Parent = paceFolder
		paceRearSegs[i] = p
	end

	-- 6. Longitudinal Slipstream Rails (connect front, center, rear along cylinder length)
	paceCylRails = {}
	local railLen = PACE_CYL_DEPTH * 2 + 6
	for i = 1, PACE_CYL_RAILS do
		local p = Instance.new('Part')
		p.Name = 'PaceRail_' .. i
		p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.CastShadow = false
		p.Material = Enum.Material.Neon; p.Size = Vector3.new(0.9, 0.9, railLen)
		p.Color = PACE_COL_MID; p.Transparency = 0.4; p.Parent = paceFolder
		paceCylRails[i] = p
	end

	-- 7. Radial Struts (Connecting Inner & Outer rings)
	paceSpokes = {}
	local spokeLen = PACE_R_OUTER - PACE_R_INNER
	for i = 1, PACE_SPOKES do
		local p = Instance.new('Part')
		p.Name = 'PaceSpoke_' .. i
		p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.CastShadow = false
		p.Material = Enum.Material.Neon; p.Size = Vector3.new(1.1, spokeLen, 1.1)
		p.Color = PACE_COL_MID; p.Transparency = 0.35; p.Parent = paceFolder
		paceSpokes[i] = p
	end

	-- 8. 4 Cardinal directional chevron nodes
	paceCardinals = {}
	for i = 1, 4 do
		local p = Instance.new('Part')
		p.Name = 'PaceCardinal_' .. i
		p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.CastShadow = false
		p.Material = Enum.Material.Neon; p.Size = Vector3.new(3.8, 3.8, 1.4)
		p.Color = PACE_COL_MID; p.Transparency = 0.15; p.Parent = paceFolder
		paceCardinals[i] = p
	end

	-- 9. Central Holographic Reticle Diamond
	paceReticle = {}
	local RETICLE_R = 12
	local retLen = 2 * RETICLE_R * math.tan(math.pi / 4) + 0.2
	for i = 1, 4 do
		local p = Instance.new('Part')
		p.Name = 'PaceReticle_' .. i
		p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.CastShadow = false
		p.Material = Enum.Material.Neon; p.Size = Vector3.new(retLen, 0.8, 0.8)
		p.Color = PACE_COL_MID; p.Transparency = 0.4; p.Parent = paceFolder
		paceReticle[i] = p
	end

	-- 10. Dynamic PointLight
	local lightAnchor = Instance.new('Part')
	lightAnchor.Name = 'PaceLightAnchor'
	lightAnchor.Anchored = true; lightAnchor.CanCollide = false; lightAnchor.CanQuery = false; lightAnchor.CanTouch = false
	lightAnchor.Transparency = 1; lightAnchor.Size = Vector3.new(1, 1, 1)
	local pl = Instance.new('PointLight')
	pl.Range = 95; pl.Brightness = 2.6; pl.Color = PACE_COL_MID; pl.Shadows = false; pl.Parent = lightAnchor
	lightAnchor.Parent = paceFolder
	paceLight = pl

	paceFolder.Parent = cam
	paceColor = PACE_COL_MID
end

function destroyPace()
	if paceFolder then paceFolder:Destroy() end
	paceFolder = nil
	paceOuterSegs = nil
	paceInnerSegs = nil
	paceCoreSegs = nil
	paceFrontSegs = nil
	paceRearSegs = nil
	paceCylRails = nil
	paceSpokes = nil
	paceCardinals = nil
	paceReticle = nil
	paceLight = nil
end

local function updatePace(courseCF, laneMid, dt, now)
	state.paceStreak = state.paceStreak or 0
	local z = state.z
	local target = PACE_COL_MID
	if z < -10 then
		target = PACE_COL_AHEAD
		state.paceStreak += dt
	elseif z > 25 then
		target = PACE_COL_BACK
		state.paceStreak = math.max(0, state.paceStreak - dt * 2)
	end
	local streak = state.paceStreak
	local mult = 1 + math.min(2, math.floor(streak / 8) * 0.5)
	paceColor = paceColor:Lerp(target, math.min(1, dt * 8))

	if paceFolder and paceOuterSegs then
		local ringCF = courseCF * CFrame.new(0, laneMid, 0)
		local spinMult = (z < -10) and 1.8 or (z > 25 and 0.65 or 1.0)
		local rotOuter = now * 0.40 * spinMult
		local rotInner = -now * 0.60 * spinMult
		local rotCore = now * 0.80 * spinMult
		local pulse = 0.5 + 0.5 * math.sin(now * 5 * spinMult)

		-- 1. Main Center Ring (Z=0, R=75)
		for i, p in ipairs(paceOuterSegs) do
			local a = (i - 1) * 2 * math.pi / PACE_SEGS_OUTER + rotOuter
			p.CFrame = ringCF * CFrame.new(PACE_R_OUTER * math.cos(a), PACE_R_OUTER * math.sin(a), 0) * CFrame.Angles(0, 0, a + math.pi / 2)
			p.Color = paceColor
			p.Transparency = 0.12 + 0.45 * (0.5 + 0.5 * math.sin(i * 0.75 - now * 7 * spinMult))
		end

		-- 2. Inner Counter-Rotating Ring (Z=0, R=62)
		if paceInnerSegs then
			for i, p in ipairs(paceInnerSegs) do
				local a = (i - 1) * 2 * math.pi / PACE_SEGS_INNER + rotInner
				p.CFrame = ringCF * CFrame.new(PACE_R_INNER * math.cos(a), PACE_R_INNER * math.sin(a), 0) * CFrame.Angles(0, 0, a + math.pi / 2)
				p.Color = paceColor
				p.Transparency = (i % 2 == 0) and (0.2 + 0.3 * pulse) or 0.55
			end
		end

		-- 3. Core Ring (Z=0, R=48)
		if paceCoreSegs then
			for i, p in ipairs(paceCoreSegs) do
				local a = (i - 1) * 2 * math.pi / PACE_SEGS_CORE + rotCore
				p.CFrame = ringCF * CFrame.new(PACE_R_CORE * math.cos(a), PACE_R_CORE * math.sin(a), 0) * CFrame.Angles(0, 0, a + math.pi / 2)
				p.Color = paceColor
				p.Transparency = 0.35 + 0.35 * (0.5 + 0.5 * math.cos(i * 1.1 + now * 5))
			end
		end

		-- 4. Front Tunnel Ring (Z = -PACE_CYL_DEPTH, R=75)
		if paceFrontSegs then
			for i, p in ipairs(paceFrontSegs) do
				local a = (i - 1) * 2 * math.pi / 24 + rotOuter * 0.8
				p.CFrame = ringCF * CFrame.new(PACE_R_OUTER * math.cos(a), PACE_R_OUTER * math.sin(a), -PACE_CYL_DEPTH) * CFrame.Angles(0, 0, a + math.pi / 2)
				p.Color = paceColor
				p.Transparency = 0.35 + 0.25 * pulse
			end
		end

		-- 5. Rear Tunnel Ring (Z = +PACE_CYL_DEPTH, R=75)
		if paceRearSegs then
			for i, p in ipairs(paceRearSegs) do
				local a = (i - 1) * 2 * math.pi / 24 + rotOuter * 0.8
				p.CFrame = ringCF * CFrame.new(PACE_R_OUTER * math.cos(a), PACE_R_OUTER * math.sin(a), PACE_CYL_DEPTH) * CFrame.Angles(0, 0, a + math.pi / 2)
				p.Color = paceColor
				p.Transparency = 0.45 + 0.25 * pulse
			end
		end

		-- 6. Longitudinal Slipstream Rails
		if paceCylRails then
			for i, p in ipairs(paceCylRails) do
				local a = (i - 1) * 2 * math.pi / PACE_CYL_RAILS + rotOuter
				p.CFrame = ringCF * CFrame.new(PACE_R_OUTER * math.cos(a), PACE_R_OUTER * math.sin(a), 0) * CFrame.Angles(0, 0, a)
				p.Color = paceColor
				p.Transparency = 0.3 + 0.3 * (0.5 + 0.5 * math.sin(now * 6 + i))
			end
		end

		-- 7. Radial Struts
		if paceSpokes then
			local midR = (PACE_R_OUTER + PACE_R_INNER) / 2
			for i, p in ipairs(paceSpokes) do
				local a = (i - 1) * 2 * math.pi / PACE_SPOKES + rotOuter
				p.CFrame = ringCF * CFrame.new(midR * math.cos(a), midR * math.sin(a), 0) * CFrame.Angles(0, 0, a + math.pi / 2)
				p.Color = paceColor
				p.Transparency = 0.25 + 0.3 * pulse
			end
		end

		-- 8. Cardinal Directional Brackets
		if paceCardinals then
			for i, p in ipairs(paceCardinals) do
				local a = (i - 1) * math.pi / 2 + rotOuter
				p.CFrame = ringCF * CFrame.new((PACE_R_OUTER + 1.2) * math.cos(a), (PACE_R_OUTER + 1.2) * math.sin(a), 0) * CFrame.Angles(0, 0, a + math.pi / 4)
				p.Color = paceColor
				p.Transparency = 0.1
			end
		end

		-- 9. Central Reticle Diamond
		if paceReticle then
			local retRot = -rotInner * 0.7
			local RETICLE_R = 12
			for i, p in ipairs(paceReticle) do
				local a = (i - 1) * 2 * math.pi / 4 + retRot
				p.CFrame = ringCF * CFrame.new(RETICLE_R * math.cos(a), RETICLE_R * math.sin(a), 0) * CFrame.Angles(0, 0, a + math.pi / 4)
				p.Color = paceColor
				p.Transparency = 0.3 + 0.3 * pulse
			end
		end

		-- 10. Central PointLight
		if paceLight and paceLight.Parent then
			paceLight.Parent.CFrame = ringCF
			paceLight.Color = paceColor
			paceLight.Brightness = 2.4 + 0.8 * pulse
		end
	end

	if paceMarker then
		paceMarker.Position = UDim2.new(0.5, 0, clamp((z - Box.Front) / (Box.Back - Box.Front), 0, 1), 0)
		paceMarker.BackgroundColor3 = paceColor
	end
	if paceStreakLabel then
		paceStreakLabel.Text = (streak >= 1) and string.format('x%.1f  %ds', mult, math.floor(streak)) or ''
		paceStreakLabel.TextColor3 = paceColor
	end
end

RunService:BindToRenderStep('SW_Flight', Enum.RenderPriority.Camera.Value + 1, function(dt)
	if not state.flying then
		state.crashing = false
		state.recoverStart = 0
		state.recoverFromCF = nil
		return
	end
	if not hrp or not hrp.Parent then return end
	dt = math.min(dt, 1 / 20)
	local now = os.clock()
	local t = workspace:GetServerTimeNow()
	local start = workspace:GetAttribute('FlightStart') or 0
	local speed = (workspace:GetAttribute('Speed') or Config.FlightSpeed) * (plr:GetAttribute('PrestigeSpeedMult') or 1) * (plr:GetAttribute('TrainingSpeedMult') or 1)
	local prog = clamp(speed * math.max(0, t - start) / Config.TrackLength, 0, 1)
	updateChunkAtmosphere(prog)
	local mvOffset = 0
	local courseCF = SplineUtils.GetCourseFrame(getCourse(workspace:GetAttribute('MapId') or 1), prog) + Vector3.new(0, mvOffset, 0)
	local cs = char and char:GetAttribute('CrashState')
	local isTumble = (cs == 'Tumble' or cs == 'KO')
	if isTumble then
		if not state.crashing then
			state.crashing = true
			state.crashT0 = now
			state.boostEnd = 0
			state.boostHeld = false
			state.boosting = false
			state.braking = false
			state.dashEnd = 0
			state.recoverStart = 0
			state.recoverFromCF = nil
			local dirAttr = char:GetAttribute('CrashDir')
			local dx = (typeof(dirAttr) == 'Vector3' and math.abs(dirAttr.X) > 0.05) and dirAttr.X or ((math.random() < 0.5) and -1 or 1)
			local dy = (typeof(dirAttr) == 'Vector3') and dirAttr.Y or 0.25
			state.vx = clamp(dx * 42, -50, 50)
			state.vy = clamp(dy * 24 + 22, 12, 34)
			state.vz = 26
			state.crashSpinDir = (state.vx >= 0) and 1 or -1
			state.camPunch.v += 30
			pcall(function()
				local s = Instance.new("Sound")
				s.Name = "HeavyCrashSound"
				s.SoundId = "rbxassetid://9114223171"
				s.Volume = (workspace:GetAttribute("Mutator") == "HeavyCrash") and 1.0 or 0.85
				s.PlaybackSpeed = (workspace:GetAttribute("Mutator") == "HeavyCrash") and 0.88 or 1.0
				s.Parent = SoundService
				s:Play()
				Debris:AddItem(s, 4.5)
			end)
			pcall(function() UIFx.Sfx('Hit', 0.7) end)
			if cs == 'Tumble' then
				showCombo('CRASHED!', Color3.fromRGB(255, 95, 70))
			end
		end
	elseif state.crashing then
		state.crashing = false
		state.recoverFromCF = hrp.CFrame
		state.recoverStart = now
		state.recoverDur = 0.55
		state.boostEnd = 0
		state.knock = Vector3.zero
		state.vx, state.vy, state.vz = 0, 0, 0
		state.tumble.x = 0
		state.tumble.v = 0
		pcall(function()
			EffectBurst.emitFrom('Ring', { position = hrp.Position, count = 16, color = Color3.fromRGB(160, 235, 255) })
			UIFx.Sfx('Whoosh', 0.45)
		end)
		showCombo('RECOVERED!', Color3.fromRGB(130, 235, 255))
	end
	local laneMid = (Box.MinY + Box.MaxY) / 2

	-- ===== spin-out crash integration OR normal flight steering =====
	local gustX, telegraph, boost = 0, 0, false
	if isTumble then
		state.vx *= exp(-1.8 * dt)
		state.vy -= 52 * dt
		state.vz = math.max(0, (state.vz or 0) * exp(-2.2 * dt))
		local nx = state.x + state.vx * dt
		if math.abs(nx) >= Box.HalfWidth then
			nx = clamp(nx, -Box.HalfWidth, Box.HalfWidth)
			state.vx = -state.vx * 0.55
		end
		state.x = nx
		local ny = state.y + state.vy * dt
		if ny <= Box.MinY + 2 and state.vy < 0 then
			ny = Box.MinY + 2
			state.vy = math.max(14, math.abs(state.vy) * 0.48)
		end
		state.y = clamp(ny, Box.MinY, Box.MaxY)
		state.z = clamp(state.z + state.vz * dt, Box.Front, Box.Back)
		state.knock = Vector3.zero
	else
		-- ===== flags: stagger, shield lock, boost (energy or ring/ability) =====
		local right, up = getInput()
		if math.abs(right) > 0.2 then state.lastDir = math.sign(right) end
		local staggered = now < state.staggerEnd
		local frozenLeft = math.max(0, (char:GetAttribute('FrozenUntil') or 0) - t)
		local frozen = frozenLeft > 0
		local locked = (now < state.lockEnd) or frozen
		if frozen then
			state.z = clamp(state.z + 26 * dt, Box.Front, Box.Back)
			if comboLabel then
				comboLabel.Text = string.format('FROZEN! %.1fs', frozenLeft)
				comboLabel.TextColor3 = Color3.fromRGB(130, 235, 255)
				comboLabel.TextTransparency = 0
				comboLabel.TextStrokeTransparency = 0.1
				comboLabel.TextSize = 36
			end
		end
		local abilityBoost = now < state.boostEnd
		if state.boostHeld and state.energy > 0 and not staggered and not locked then
			if not state.boosting then state.boosting = true state.fovKick += 6 UIFx.Sfx('Whoosh', 0.35) end
			state.energy = math.max(0, state.energy - F.EnergyDrain * dt)
			state.lastDrain = now
			if state.energy <= 0 then state.boostHeld = false end
		else
			state.boosting = false
		end
		if not state.boosting and now - state.lastDrain > F.EnergyRegenDelay then
			local diveBonus = (state.vy < -8) and 8 or 0
			local ev = workspace:GetAttribute('WeatherEvent')
			local flareMult = (ev == 'SolarFlare') and 1.35 or 1
			local passRegen = plr:GetAttribute('Pass_FastFlyer') and 1.2 or 1
			state.energy = math.min(F.EnergyMax, state.energy + (F.EnergyRegen * flareMult * passRegen + diveBonus) * dt)
		end
		boost = state.boosting or abilityBoost

		-- ===== wind gust: telegraphed (camera tilts + wind rises), then pushes sideways =====
		if not locked then
			if not state.gust and now > state.nextGust then
				local gDir = (math.random() < 0.5) and -1 or 1
				state.gust = { t0 = now + 0.9, dur = 1.6, dir = gDir }
				floatText(char, gDir > 0 and 'WIND >>>' or '<<< WIND', Color3.fromRGB(160, 230, 255))
				UIFx.Sfx('Whoosh', 0.45)
			end
			local g = state.gust
			if g then
				local p = (now - g.t0) / g.dur
				if p >= 1 then
					state.gust = nil state.nextGust = now + 15 + math.random() * 7
				elseif p >= 0 then
					gustX = g.dir * 22 * math.sin(p * math.pi) telegraph = 1
				else
					telegraph = clamp(1 + (now - g.t0) / 0.9, 0, 1) * 0.6
				end
			end
		end

		-- ===== strafing: acceleration based, soft lane walls =====
		local passSpd = plr:GetAttribute('Pass_FastFlyer') and 1.25 or 1.0
		local MOVE = (boost and F.BoostMoveSpeed or F.MoveSpeed) * passSpd
		local ctl = locked and 0 or (staggered and 0.25 or 1)
		local tvx, tvy = right * MOVE * ctl, up * MOVE * 0.88 * ctl
		local dashing = now < state.dashEnd
		if dashing then
			if state.dashY then tvy = state.dashY * 100 else tvx = state.dashDir * 115 end
		else
			state.dashY = nil
		end
		if locked then tvx, tvy, gustX = 0, 0, 0 end
		tvx += gustX
		local effDrag = (state and state.effectiveDrag) or (F.Drag * (1 - 0.40 * ((state and state.kDraft) or 0)))
		state.vx = follow(state.vx, tvx, dashing, dt, effDrag)
		state.vy = follow(state.vy, tvy, dashing, dt, effDrag)

		local soft, wall = F.EdgeSoft, 0
		local exX = math.abs(state.x) - (Box.HalfWidth - soft)
		if exX > 0 then
			local k = clamp(exX / soft, 0, 1)
			wall = math.max(wall, k)
			if state.vx * state.x > 0 then state.vx *= 1 - k * clamp(10 * dt, 0, 1) end
		end
		local exMax, exMin = state.y - (Box.MaxY - soft), (Box.MinY + soft) - state.y
		if exMax > 0 then
			local k = clamp(exMax / soft, 0, 1) wall = math.max(wall, k)
			if state.vy > 0 then state.vy *= 1 - k * clamp(10 * dt, 0, 1) end
		end
		if exMin > 0 then
			local k = clamp(exMin / soft, 0, 1) wall = math.max(wall, k)
			if state.vy < 0 then state.vy *= 1 - k * clamp(10 * dt, 0, 1) end
		end
		state.edge = wall
		state.knock *= exp(-4 * dt)
		state.x = clamp(state.x + (state.vx + state.knock.X) * dt, -Box.HalfWidth, Box.HalfWidth)
		state.y = clamp(state.y + (state.vy + state.knock.Y) * dt, Box.MinY, Box.MaxY)

		-- forward/back position inside the pack: persistent Z (no rubber-band back to 0!)
		local tvz = 0
		if state.braking then
			tvz = 44
			state.brakeLeft -= dt
			if state.brakeLeft <= 0 then stopBrake() end
		elseif boost then
			tvz = -48
		elseif up > 0.25 then
			tvz = -16
		elseif up < -0.25 then
			tvz = 12
		end
		if locked then tvz = 0 end
		if not state.braking and now >= state.brakeCd then
			state.brakeLeft = math.min(Config.BrakeMax, state.brakeLeft + dt * 0.8)
		end
		local vzResp = (tvz == 0) and 5.5 or 7.5
		state.vz = (state.vz or 0) + (tvz - (state.vz or 0)) * (1 - exp(-vzResp * dt))
		state.z = clamp(state.z + (state.vz + state.knock.Z) * dt, Box.Front, Box.Back)
	-- Path Slipstream Cone & Dynamic Max Speed Cap
	local maxKDraft = 0
	local myPos = hrp.Position
	local fwd = courseCF.LookVector
	local rgt = courseCF.RightVector
	local upVec = courseCF.UpVector

	local myDistAlong = myPos:Dot(fwd)
	local leaderDistAlong = myDistAlong
	local draftTargetLeader = nil

	for _, m in ipairs(workspace:GetChildren()) do
		if m:IsA("Model") and m:GetAttribute("Flying") == true then
			local oRoot = m:FindFirstChild("HumanoidRootPart")
			if oRoot then
				local oDist = oRoot.Position:Dot(fwd)
				if oDist > leaderDistAlong then
					leaderDistAlong = oDist
				end
				if m ~= char then
					local delta = oRoot.Position - myPos
					local deltaZ = delta:Dot(fwd)
					local deltaX = delta:Dot(rgt)
					local deltaY = delta:Dot(upVec)
					local deltaXY = math.sqrt(deltaX * deltaX + deltaY * deltaY)
					if deltaZ >= 8 and deltaZ <= 55 and deltaXY < 18 then
						local kZ = math.max(0, 1 - deltaZ / 55)
						local kXY = math.max(0, 1 - deltaXY / 18)
						local kCone = kZ * kXY
						if kCone > maxKDraft then
							maxKDraft = kCone
							draftTargetLeader = m
						end
					end
				end
			end
		end
	end

	state.kDraft = maxKDraft
	state.slipstream = maxKDraft
	char:SetAttribute("Slipstream", maxKDraft > 0.15)
	char:SetAttribute("DraftFactor", maxKDraft)
	updateSlipstreamBeam(hrp, char, draftTargetLeader, maxKDraft)

	-- 40% air drag reduction when drafting
	local F_drag_effective = F.Drag * (1 - 0.40 * maxKDraft)
	state.effectiveDrag = F_drag_effective

	-- Distance catch-up bonus based on distance behind leader
	local distBehind = math.max(0, leaderDistAlong - myDistAlong)
	local catchupBonus = clamp(distBehind * 0.00035, 0, 0.25)
	local draftBonus = 0.20 * maxKDraft

	-- DynamicMaxSpeed capped strictly at +45% over base max speed
	local speedMultBonus = clamp(catchupBonus + draftBonus, 0, 0.45)
	local baseMaxSpeed = workspace:GetAttribute("Speed") or Config.FlightSpeed
	local dynamicMaxSpeed = baseMaxSpeed * (1 + speedMultBonus)
	state.dynamicMaxSpeed = dynamicMaxSpeed
	char:SetAttribute("DynamicMaxSpeed", dynamicMaxSpeed)
	char:SetAttribute("SpeedMultBonus", speedMultBonus)

	-- Dynamic forward surge integrated into state.z
	if speedMultBonus > 0.001 then
		state.z = clamp(state.z - (baseMaxSpeed * speedMultBonus) * dt, Box.Front, Box.Back)
	end

	-- Updraft ring boost bounded by remaining headroom (strictly capped at +45%)
	local updraftUntil = char:GetAttribute("UpdraftUntil") or 0
	if workspace:GetServerTimeNow() < updraftUntil then
		local uBonus = math.min(0.40, 0.45 - speedMultBonus)
		if uBonus > 0 then
			state.z = clamp(state.z - (baseMaxSpeed * uBonus) * dt, Box.Front, Box.Back)
		end
	end
	local refillStamp = char:GetAttribute("RefillBoost")
	if refillStamp and refillStamp ~= state.lastRefillStamp then
		state.lastRefillStamp = refillStamp
		state.energy = F.EnergyMax
	end
	if plr:GetAttribute("Perk_BoostRegen") then
		state.energy = math.min(F.EnergyMax, state.energy + dt * 6)
	end

	end

	local function worldPos()
		return courseCF.Position + courseCF.RightVector * state.x + courseCF.UpVector * state.y - courseCF.LookVector * state.z
	end
	local forwardPos = worldPos()

	-- ===== obstacles: hard forward stop (box test aligned to the track) + near-miss bonus =====
	local obsFolder = not isTumble and getObsFolder() or nil
	if obsFolder then
		local diff = workspace:GetAttribute("Difficulty") or "Medium"
		local boxSz = (diff == "Easy" and Vector3.new(4.8, 4.2, 3.5)) or (diff == "Hard" and Vector3.new(8.0, 6.8, 5.5)) or Vector3.new(6.5, 5.5, 4.5)
		local knockZ = (diff == "Easy" and 20) or (diff == "Hard" and 50) or 34
		local pushZ = (diff == "Easy" and 18) or (diff == "Hard" and 42) or 30

		local hits = workspace:GetPartBoundsInBox(CFrame.new(forwardPos + courseCF.LookVector * 3.5) * courseCF.Rotation, boxSz, obsParams)
		if #hits > 0 then
			state.z = math.min(Box.Back, state.z + pushZ * dt)
			state.knock = Vector3.new(state.knock.X, state.knock.Y, math.max(state.knock.Z, knockZ))
			state.shake = math.min(10, state.shake + 2.5)
			forwardPos = worldPos()
		end		if now >= state.nextScan then
			state.nextScan = now + 0.07
			local seen = {}
			for _, p in ipairs(workspace:GetPartBoundsInRadius(forwardPos, F.NearMissDist + 3.4, obsParams)) do
				local key = p.Parent
				local ok, cp = pcall(function() return p:GetClosestPointOnSurface(forwardPos) end)
				if key and ok then
					local dd = (cp - forwardPos).Magnitude
					local c = state.cand[key]
					if not c then c = { min = dd } state.cand[key] = c end
					c.min = math.min(c.min, dd)
					seen[key] = true
				end
			end
			for key, c in pairs(state.cand) do
				if not seen[key] then
					state.cand[key] = nil
					if c.min > 4.4 and now - state.lastHitT > 1.0 and key.Parent then
						state.energy = math.min(F.EnergyMax, state.energy + F.NearMissEnergy)
						state.fovKick += 3
						floatText(char, 'CLOSE!', Color3.fromRGB(255, 235, 90))
						UIFx.Sfx('Whoosh', 0.45)
					end
				end
			end
		end
	end

	-- ===== body orientation: damped springs + maneuver angles + hit tumble =====
	local sp = state.sp
	spring(sp.yaw, clamp(-state.vx / 70, -0.45, 0.45) + clamp(state.camYawOffset * 0.3, -0.4, 0.4), 80, 13, dt)
	spring(sp.bank, clamp(state.vx / 22, -1, 1) * rad(55), 70, 11, dt)
	spring(sp.pitch, clamp(state.vy / 24, -0.6, 0.6) - (boost and 0.12 or 0), 70, 11, dt)
	spring(state.tumble, 0, 45, 5, dt)
	local rollExtra, pitchExtra, camManRoll = state.tumble.x, 0, 0
	local man = state.man
	if man then
		local p = (now - man.t0) / man.dur
		if p >= 1 then
			state.man = nil
		else
			local e = easeInOut(p)
			if man.kind == 'roll' then
				rollExtra += man.dir * TAU * e
				camManRoll = -man.dir * math.sin(p * math.pi) * 0.35
			else
				pitchExtra = man.dir * TAU * e
			end
		end
	end
	local bob = isTumble and 0 or (math.sin(now * 2.3) * 0.3)
	local bodyRot
	if isTumble then
		local u = now - state.crashT0
		local env = math.sin(math.min(1, u / 1.35) * math.pi)
		local spinRoll = state.crashSpinDir * u * math.rad(540)
		local spinPitch = math.sin(u * 9.5) * math.rad(34) * env
		local spinYaw = state.crashSpinDir * math.sin(u * 6.0) * math.rad(26) * env
		bodyRot = courseCF.Rotation
			* CFrame.Angles(0, spinYaw, 0)
			* CFrame.Angles(rad(-80) + spinPitch, 0, 0)
			* CFrame.Angles(0, spinRoll, 0)
	else
		bodyRot = courseCF.Rotation
			* CFrame.Angles(0, sp.yaw.x, 0)
			* CFrame.Angles(rad(-80) + sp.pitch.x + pitchExtra, 0, 0)
			* CFrame.Angles(0, sp.bank.x + rollExtra, 0)
	end
	local targetFlightCF = CFrame.new(forwardPos + courseCF.UpVector * bob) * bodyRot
	local recoverAlpha = nil
	if state.recoverStart > 0 and state.recoverFromCF then
		local ra = clamp((now - state.recoverStart) / state.recoverDur, 0, 1)
		if ra >= 1 then
			state.recoverStart = 0
			state.recoverFromCF = nil
		else
			recoverAlpha = ra * ra * (3 - 2 * ra)
			-- Smoothly unroll orientation while riding track position seamlessly (zero world-space lag)
			local rotLerp = state.recoverFromCF.Rotation:Lerp(targetFlightCF.Rotation, recoverAlpha)
			targetFlightCF = CFrame.new(targetFlightCF.Position) * rotLerp
		end
	end
	hrp.CFrame = targetFlightCF
	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.AssemblyAngularVelocity = Vector3.zero

	-- ===== camera: follows the lane (flyer drifts toward screen edges), lag per axis, look-ahead =====
	local mode = CAM_MODES[state.camMode]
	local stick = state.stick
	if stick.Magnitude > 0.18 then
		state.camYawOffset = clamp(state.camYawOffset - stick.X * 2.4 * dt, -2.6, 2.6)
		state.camPitchOffset = clamp(state.camPitchOffset + stick.Y * 1.6 * dt, -rad(75), rad(75))
		state.lastLook = now
	elseif now - state.lastLook > 1.6 then
		local d = exp(-2.2 * dt)
		state.camYawOffset *= d
		state.camPitchOffset *= d
	end

	-- v4: distance is a spring (soft pull-back on boost, rubber punch on hit, tighter when braking, loops widen the frame)
	local distTarget = state.camDistance * mode.scale + (boost and 6 or 0) + (isTumble and 7 or 0) - (state.braking and 3.5 or 0) + (state.man and state.man.kind == 'loop' and 4 or 0)
	spring(state.camDist, distTarget, 38, 9, dt)
	spring(state.camPunch, 0, 120, 10, dt)
	local dist = state.camDist.x + state.camPunch.x
	-- look-ahead into upcoming curves: the camera yaws toward where the spline is going, plus a bit toward the strafe direction
	local aheadCF = SplineUtils.GetCourseFrame(getCourse(workspace:GetAttribute('MapId') or 1), clamp(prog + 0.018, 0, 1))
	local curve = clamp(courseCF.RightVector:Dot(aheadCF.LookVector) * 3.2, -0.6, 0.6)
	spring(state.camLead, -curve * 0.62 - clamp(state.vx / 160, -0.22, 0.22), 34, 10, dt)
	spring(state.camVLag, clamp(-state.vy / 70, -0.35, 0.35), 24, 8, dt)
	local camRotation = courseCF.Rotation * CFrame.Angles(0, state.camYawOffset + state.camLead.x, 0) * CFrame.Angles(state.camPitchOffset + state.camVLag.x, 0, 0)
	local laneAnchor = courseCF.Position + courseCF.RightVector * (state.x * 0.62) + courseCF.UpVector * lerp(laneMid, state.y, 0.72) - courseCF.LookVector * state.z
	local anchor = laneAnchor + courseCF.UpVector * 2
	local desired = anchor - camRotation.LookVector * dist + courseCF.UpVector * mode.h
	local loc = courseCF:PointToObjectSpace(desired)
	local cl = state.camLocal or loc
	state.camLocal = Vector3.new(
		cl.X + (loc.X - cl.X) * (1 - exp(-9 * dt)),
		cl.Y + (loc.Y - cl.Y) * (1 - exp(-11 * dt)),
		cl.Z + (loc.Z - cl.Z) * (1 - exp(-15 * dt))
	)
	local camPos = courseCF:PointToWorldSpace(state.camLocal)
	local lookAhead = (boost and 22 or 14) + (state.braking and -4 or 0)
	local focus = anchor + courseCF.LookVector * lookAhead + courseCF.RightVector * (state.vx * 0.07) + courseCF.UpVector * (state.vy * 0.05)
	focus = focus:Lerp(aheadCF.Position + courseCF.UpVector * state.y * 0.5, 0.18) -- bend the gaze toward the curve
	-- breathing: slow figure-8 drift that grows with speed so the camera never feels pasted on
	local breathe = (boost and 0.18 or 0.08)
	camPos = camPos + courseCF.RightVector * (math.sin(now * 1.3) * breathe) + courseCF.UpVector * (math.sin(now * 2.6) * breathe * 0.6)

	local sh = Vector3.zero -- SCREEN SHAKE REMOVED (was random camera jitter on hits / boost / gusts / walls)
	local gustDir = state.gust and state.gust.dir or 0
	spring(state.camRoll, -sp.bank.x * 0.34 + camManRoll - gustDir * telegraph * 0.12 - clamp(state.camLead.x, -0.4, 0.4) * 0.35, 90, 14, dt)
	local targetCamCF = CFrame.lookAt(camPos + sh, focus + sh, courseCF.UpVector) * CFrame.Angles(0, 0, state.camRoll.x)
	if recoverAlpha and state.recoverCamCF then
		cam.CFrame = state.recoverCamCF:Lerp(targetCamCF, recoverAlpha)
	else
		state.recoverCamCF = nil
		cam.CFrame = targetCamCF
	end
	state.shake *= exp(-6 * dt)

	state.fovKick *= exp(-5 * dt)
	state.speedPulse += ((boost and 1 or 0) - state.speedPulse) * math.min(1, dt * 3)
	local ft = 72 + mode.fov + clamp((math.abs(state.vx) + math.abs(state.vy)) * 0.05, 0, 6) + state.speedPulse * 16 + (state.braking and -5 or 0) + state.fovKick
	state.fov += (ft - state.fov) * math.min(1, dt * 6)
	cam.FieldOfView = state.fov

	if windEmitter then
		windEmitter.CFrame = cam.CFrame * CFrame.new(0, 0, -8)
		windE.Rate = 30 + state.speedPulse * 110 + telegraph * 50 + (state.man and 40 or 0)
		windE.Speed = NumberRange.new(50 + state.speedPulse * 70, 90 + state.speedPulse * 90)

		-- Dynamic weather rates based on current biome zone
		local currentZone = workspace:GetAttribute("Zone") or ""
		local rainE = windEmitter:FindFirstChild("SW_RainE")
		local snowE = windEmitter:FindFirstChild("SW_SnowE")
		-- WeatherController handles smooth baseline weather interpolation; boost adds a light, readable streak
		if rainE and rainE.Rate > 0 and boost then
			rainE.Rate = math.min(55, math.max(rainE.Rate, 45))
		end
		if snowE and snowE.Rate > 0 and boost then
			snowE.Rate = math.min(50, math.max(snowE.Rate, 42))
		end
	end
	if trailL then
		local life = boost and 0.75 or 0.45
		trailL.Lifetime = life trailR.Lifetime = life
		local sa = hrp:FindFirstChild('SW_SkinAura')
		if sa then sa.Rate = sa.Rate + (((boost and 2.2 or 1) * (sa:GetAttribute('Base') or sa.Rate)) - sa.Rate) * math.min(1, dt * 4) end
	end

	updatePace(courseCF, laneMid, dt, now)

	-- HUD
	if energyFill then
		local pct = state.energy / F.EnergyMax
		energyFill.Size = UDim2.fromScale(pct, 1)
		energyFill.BackgroundColor3 = state.boosting and Color3.fromRGB(190, 240, 255) or (pct < 0.25 and Color3.fromRGB(255, 160, 70) or Color3.fromRGB(90, 200, 255))
	end

	-- Dynamic Flight & Drafting Audio (Whoosh loop, Drafting Thruster Hum loop, Boost audio, Flap audio)
	initFlightAudio()
	if state.flying and not isTumble then
		local curSpd = (hrp and lastAudioPos and dt > 0) and ((hrp.Position - lastAudioPos).Magnitude / dt) or (state.dynamicMaxSpeed or 100)
		lastAudioPos = hrp and hrp.Position or lastAudioPos
		local speedRatio = math.clamp(curSpd / 140, 0, 1.25)
		local targetWhooshVol = 0.15 + 0.60 * math.min(1, speedRatio)
		local targetWhooshPitch = 0.85 + 0.45 * math.min(1, speedRatio)
		if boost then
			targetWhooshVol = targetWhooshVol * 1.25
			targetWhooshPitch = targetWhooshPitch * 1.15
		end
		flightWhooshSound.Volume = flightWhooshSound.Volume + (targetWhooshVol - flightWhooshSound.Volume) * math.min(1, dt * 7)
		flightWhooshSound.PlaybackSpeed = flightWhooshSound.PlaybackSpeed + (targetWhooshPitch - flightWhooshSound.PlaybackSpeed) * math.min(1, dt * 7)
		if not flightWhooshSound.IsPlaying and flightWhooshSound.Volume > 0.02 then
			flightWhooshSound:Play()
		end

		local currentKDraft = state.kDraft or 0
		if currentKDraft > 0.10 then
			local draftRatio = math.clamp((currentKDraft - 0.10) / 0.90, 0, 1)
			local targetDraftVol = 0.18 + 0.55 * draftRatio
			local targetDraftPitch = 0.95 + 0.45 * draftRatio
			draftHumSound.Volume = draftHumSound.Volume + (targetDraftVol - draftHumSound.Volume) * math.min(1, dt * 9)
			draftHumSound.PlaybackSpeed = draftHumSound.PlaybackSpeed + (targetDraftPitch - draftHumSound.PlaybackSpeed) * math.min(1, dt * 9)
			if not draftHumSound.IsPlaying and draftHumSound.Volume > 0.04 then
				draftHumSound:Play()
			end
		else
			draftHumSound.Volume = math.max(0, draftHumSound.Volume - dt * 3.5)
			if draftHumSound.Volume <= 0.01 and draftHumSound.IsPlaying then
				draftHumSound:Stop()
			end
		end

		if boost and not lastBoostingActive then
			playOneShotSfx("rbxassetid://8175700177", 0.75, 1.2)
		end
		lastBoostingActive = boost

		flapAudioCooldown = flapAudioCooldown - dt
		if flapAudioCooldown <= 0 then
			flapAudioCooldown = 0.50 + math.random() * 0.06
			playOneShotSfx("rbxassetid://967702503", 0.22, 1.45 + math.random() * 0.15)
		end
	else
		lastBoostingActive = false
		if flightWhooshSound then
			flightWhooshSound.Volume = math.max(0, flightWhooshSound.Volume - dt * 2.5)
			if flightWhooshSound.Volume <= 0.01 and flightWhooshSound.IsPlaying then
				flightWhooshSound:Stop()
			end
		end
		if draftHumSound then
			draftHumSound.Volume = math.max(0, draftHumSound.Volume - dt * 3.5)
			if draftHumSound.Volume <= 0.01 and draftHumSound.IsPlaying then
				draftHumSound:Stop()
			end
		end
	end
end)

Remotes.Knock.OnClientEvent:Connect(function(v)
    if typeof(v) ~= 'Vector3' then return end
    state.knock += v
    if state.knock.Magnitude > 120 then state.knock = state.knock.Unit * 120 end
end)

Remotes.Hit.OnClientEvent:Connect(function(model, amount)
    if not model then return end
    floatText(model, '-' .. math.floor(amount), Color3.fromRGB(255, 90, 80))
    if model == plr.Character then
        local now = os.clock()
        state.shake = math.min(9, state.shake + amount * 0.35)
        UIFx.Sfx('Hit')
        -- stagger: brief loss of control, spin, FOV dip, combo + a little energy lost
        state.lastHitT = now
        state.camPunch.v += 38 -- camera gets shoved back and snaps in again
        state.staggerEnd = now + F.StaggerTime
        state.vx *= -0.35 state.vy *= -0.35
        state.tumble.v += (math.random() < 0.5 and -1 or 1) * 16
        state.fovKick = -5
        state.combo = 0
        state.paceStreak = 0
        state.energy = math.max(0, state.energy - 12)
    end
end)

Remotes.Pickup.OnClientEvent:Connect(function(kind)
    local c = plr.Character
    local r = c and c:FindFirstChild('HumanoidRootPart')
    UIFx.Sfx('Pickup')
    if r then
        EffectBurst.emitFrom('Ring', {
            position = r.Position,
            count = (kind == 'Ring') and 12 or 18,
            color = (kind == 'Heal') and Color3.fromRGB(100, 255, 130) or ((kind == 'Boost') and Color3.fromRGB(90, 200, 255) or nil),
        })
    end
    if kind == 'Heal' then
        floatText(c, '+' .. tostring(Config.HealOrbAmount or 180) .. ' HP', Color3.fromRGB(110, 255, 130))
    elseif kind == 'Boost' then
        floatText(c, 'SPEED BOOST!', Color3.fromRGB(100, 190, 255))
        state.boostEnd = os.clock() + 2.8
        state.fov = 92
        playOneShotSfx("rbxassetid://8175700177", 0.8, 1.2)
    elseif kind == 'Ring' then
        local now = os.clock()
        state.combo = (now - state.comboT < 3.2) and (state.combo + 1) or 1
        state.comboT = now
        state.boostEnd = math.max(state.boostEnd, now + F.BoostPickupTime)
        state.energy = math.min(F.EnergyMax, state.energy + F.RingEnergy)
        state.fovKick = math.min(22, state.fovKick + 7)
        showCombo(state.combo > 1 and ('RING  x' .. state.combo) or 'RING', Color3.fromRGB(255, 235, 110))
    else
        floatText(c, 'RECHARGED!', Color3.fromRGB(255, 230, 70))
        for k in pairs(state.cds) do state.cds[k] = 0 end
        CooldownEvent:Fire('Dash', 0)
        CooldownEvent:Fire('Ability', 0)
    end
end)

local function disc(pos, col, size, time)
    -- Handled by Shared.AbilityVFX (Creator Store models + MoreAuras)
end

local function ringWave(pos, col, size, time)
    -- Handled by Shared.AbilityVFX (Creator Store models + MoreAuras)
end

Remotes.AbilityFx.OnClientEvent:Connect(function(kind, model, target)
    local h = typeof(model) == 'Instance' and model:FindFirstChild('HumanoidRootPart') if not h then return end
    local th = typeof(target) == 'Instance' and target:FindFirstChild('HumanoidRootPart') or nil
    pcall(AbilityVFX.Play, kind, h, target)
    pcall(UIFx.PlayAbilitySfx, kind)
    if model == char then
        state.fovKick += (kind == 'Dash' and 3 or 5)
        state.shake = math.max(state.shake or 0, kind == 'Dash' and 0.35 or 0.75)
        if kind == 'PhantomBlink' then
            state.z = clamp(state.z - 34, Box.Front, Box.Back)
            state.fovKick += 5
            showCombo('AIR BLINK!', Color3.fromRGB(90, 220, 255))
        elseif kind == 'MagnetPulse' then
            showCombo('RING MAGNET!', Color3.fromRGB(205, 130, 255))
        end
    end -- aura-pack particle burst on top of the discs / sparkles below

    if kind == 'Dash' then
        playOneShotSfx("rbxassetid://5801273676", 0.75, 1.3)
        disc(h.Position + Vector3.new(0, 0, 2), Color3.fromRGB(180, 240, 255), 18, 0.3)
        UIFx.Sparkle(h, 24, Color3.fromRGB(150, 225, 255))

    elseif kind == 'Slap' then
        disc(h.Position, Color3.fromRGB(255, 180, 40), 24, 0.35)
        UIFx.Sparkle(h, 28, Color3.fromRGB(255, 200, 60))

    elseif kind == 'NorthStarBeam' then
        ringWave(h.Position, Color3.fromRGB(140, 235, 255), 34, 0.6)
        floatText(model, 'NORTH STAR!', Color3.fromRGB(140, 235, 255))
        UIFx.Sparkle(h, 40, Color3.fromRGB(200, 245, 255))

    elseif kind == 'ChaosPulse' then
        ringWave(h.Position, Color3.fromRGB(255, 85, 190), 38, 0.55)
        floatText(model, 'CHAOS PULSE!', Color3.fromRGB(255, 85, 190))
        UIFx.Sparkle(h, 45, Color3.fromRGB(220, 90, 255))

    elseif kind == 'CardBarrage' then
        disc(h.Position, Color3.fromRGB(255, 210, 75), 30, 0.45)
        floatText(model, 'CARD BARRAGE!', Color3.fromRGB(255, 210, 75))
        UIFx.Sparkle(h, 40, Color3.fromRGB(255, 90, 110))

    elseif kind == 'SolarEclipse' then
        ringWave(h.Position, Color3.fromRGB(255, 145, 50), 36, 0.65)
        floatText(model, 'SOLAR ECLIPSE!', Color3.fromRGB(255, 165, 65))
        UIFx.Sparkle(h, 45, Color3.fromRGB(255, 180, 70))

    elseif kind == 'VoidRift' then
        ringWave(h.Position, Color3.fromRGB(150, 70, 255), 36, 0.6)
        floatText(model, 'VOID RIFT!', Color3.fromRGB(170, 95, 255))
        UIFx.Sparkle(h, 40, Color3.fromRGB(140, 60, 255))

    elseif kind == 'WindSlash' then
        disc(h.Position, Color3.fromRGB(110, 245, 200), 28, 0.45)
        floatText(model, 'WIND SLASH!', Color3.fromRGB(130, 255, 215))
        UIFx.Sparkle(h, 30, Color3.fromRGB(180, 255, 230))

    elseif kind == 'ThunderStrike' then
        ringWave(h.Position, Color3.fromRGB(255, 235, 70), 36, 0.5)
        floatText(model, 'THUNDER STRIKE!', Color3.fromRGB(255, 240, 90))
        UIFx.Sparkle(h, 45, Color3.fromRGB(150, 220, 255))

    elseif kind == 'Shield' then
        ringWave(h.Position, Color3.fromRGB(110, 220, 255), 24, 0.5)
        floatText(model, 'FEATHER SHIELD!', Color3.fromRGB(140, 230, 255))

    elseif kind == 'Divebomb' or kind == 'Surge' then
        disc(h.Position, Color3.fromRGB(255, 195, 90), 30, 0.4)
        floatText(model, kind == 'Divebomb' and 'DIVEBOMB!' or 'SUPERSONIC!', Color3.fromRGB(255, 210, 110))

    elseif kind == 'FrostBite' then
        -- Ice shards and freeze burst from Iceball
        ringWave(h.Position, Color3.fromRGB(130, 225, 255), 32, 0.6)
        floatText(model, 'ICE FREEZE!', Color3.fromRGB(140, 230, 255))
        UIFx.Sparkle(h, 45, Color3.fromRGB(170, 240, 255))
        local iceballTpl = game.Workspace:FindFirstChild("Iceball") or (game.ServerStorage:FindFirstChild("UserAssetPacks") and game.ServerStorage.UserAssetPacks:FindFirstChild("Iceball"))
        if iceballTpl then
            local cl = iceballTpl:Clone()
            cl.CFrame = h.CFrame
            cl.Parent = workspace
            Debris:AddItem(cl, 1.8)
        end

    elseif kind == 'NatureVortex' then
        ringWave(h.Position, Color3.fromRGB(120, 255, 140), 28, 0.6)
        floatText(model, 'POISON VORTEX!', Color3.fromRGB(140, 255, 160))
        UIFx.Sparkle(h, 35, Color3.fromRGB(90, 255, 110))

    elseif kind == 'MidasBurst' then
        ringWave(h.Position, Color3.fromRGB(255, 215, 0), 34, 0.6)
        floatText(model, 'MIDAS CONFETTI!', Color3.fromRGB(255, 225, 30))
        UIFx.Sparkle(h, 50, Color3.fromRGB(255, 215, 0))

    elseif kind == 'AbyssalGrasp' then
        ringWave(h.Position, Color3.fromRGB(180, 20, 60), 30, 0.5)
        floatText(model, 'ABYSSAL GRASP!', Color3.fromRGB(200, 30, 50))
        UIFx.Sparkle(h, 35, Color3.fromRGB(120, 10, 30))

    elseif kind == 'RailgunSurge' then
        disc(h.Position, Color3.fromRGB(80, 180, 255), 32, 0.6)
        ringWave(h.Position, Color3.fromRGB(255, 255, 255), 36, 0.5)
        floatText(model, 'RAILGUN SURGE!', Color3.fromRGB(100, 200, 255))

    elseif kind == 'QuantumWarp' then
        ringWave(h.Position, Color3.fromRGB(0, 255, 200), 26, 0.4)
        floatText(model, 'QUANTUM WARP!', Color3.fromRGB(0, 255, 220))
        UIFx.Sparkle(h, 30, Color3.fromRGB(0, 255, 200))

    elseif kind == 'CosmicSingularity' then
        ringWave(h.Position, Color3.fromRGB(140, 50, 240), 38, 0.7)
        floatText(model, 'BLACK HOLE!', Color3.fromRGB(180, 80, 255))
        UIFx.Sparkle(h, 45, Color3.fromRGB(150, 60, 255))

    elseif kind == 'InfernoBlaze' then
        ringWave(h.Position, Color3.fromRGB(255, 80, 20), 34, 0.6)
        floatText(model, 'INFERNO FIRESTORM!', Color3.fromRGB(255, 100, 20))
        UIFx.Sparkle(h, 40, Color3.fromRGB(255, 110, 30))

    elseif kind == 'AcmeAnvil' then
        floatText(model, 'ACME ANVIL!', Color3.fromRGB(255, 235, 90))

    elseif kind == 'MagmaWake' then
        floatText(model, 'MAGMA WAKE!', Color3.fromRGB(255, 90, 20))
        UIFx.Sparkle(h, 24, Color3.fromRGB(255, 110, 30))

    elseif kind == 'AngelAscend' then
        ringWave(h.Position, Color3.fromRGB(235, 240, 255), 26, 0.6)
        floatText(model, 'ASCENSION!', Color3.fromRGB(235, 240, 255))
        UIFx.Sparkle(h, 45, Color3.fromRGB(255, 255, 255))

    elseif kind == 'AngelBurst' then
        ringWave(h.Position, Color3.fromRGB(255, 245, 190), 44, 0.7)
        ringWave(h.Position, Color3.fromRGB(255, 255, 255), 28, 0.4)
        floatText(model, 'HOLY BURST!', Color3.fromRGB(255, 245, 190))
        UIFx.Sparkle(h, 60, Color3.fromRGB(255, 240, 170))
    end
end)
