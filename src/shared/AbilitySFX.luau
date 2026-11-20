-- AbilitySFX: 30+ unique multi-layered composed sound effects using verified Place SoundIds
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local M = {}

local function getSfxGroup()
	local g = SoundService:FindFirstChild("SFX")
	if not g then
		g = Instance.new("SoundGroup")
		g.Name = "SFX"
		g.Parent = SoundService
	end
	return g
end

-- Verified SoundIds from ReplicatedStorage / StarterGui / SoundService
local S = {
	Boom       = "rbxassetid://9125484511",
	Explosion  = "rbxassetid://7491190247",
	Impact     = "rbxassetid://967702054",
	Thunder    = "rbxassetid://139319051979882",
	Fire       = "rbxassetid://9068935533",
	Flash      = "rbxassetid://9126073001",
	Launch     = "rbxassetid://5801273676",
	PortalAmb  = "rbxassetid://2162238374",
	Portal1    = "rbxassetid://9069251224",
	Portal2    = "rbxassetid://1837829231",
	PortalCls  = "rbxassetid://2162238854",
	PreLaunch  = "rbxassetid://132456187",
	PreThrust  = "rbxassetid://5652831542",
	Thruster   = "rbxassetid://2852749304",
	Thruster2  = "rbxassetid://8175700177",
	Riser      = "rbxassetid://9117297289",
	Twinkle    = "rbxassetid://9125644775",
	Wind       = "rbxassetid://9114223023",
	Whoosh1    = "rbxassetid://127183292018512",
	Whoosh2    = "rbxassetid://967702503",
	Shield     = "rbxassetid://113813942754476",
	Hit        = "rbxassetid://115797572751931",
	KO         = "rbxassetid://88494822059299",
	Coin       = "rbxassetid://135483737426662",
	Jackpot    = "rbxassetid://139651791574775",
	Chime      = "rbxassetid://7231519809",
	Tick       = "rbxassetid://117649901456711",
	Pop        = "rbxassetid://15675055424",
	Open       = "rbxassetid://9125646252",
	Close      = "rbxassetid://9125635667",
	HeavyCrash = "rbxassetid://9114223171",
}

M.Sounds = S

-- Each ability has a list of layers: { id, vol, speed, delay, pitch, echo, reverb, distort, maxDur }
local RECIPES = {
	Dash              = { { id = S.Whoosh1, vol = 0.45, speed = 1.35 } },
	Slap              = { { id = S.Impact, vol = 0.75, speed = 0.85, distort = 0.25 }, { id = S.Boom, vol = 0.60, speed = 1.15, delay = 0.05 } },
	Divebomb          = { { id = S.Whoosh2, vol = 0.60, speed = 0.75 }, { id = S.Explosion, vol = 0.80, speed = 0.85, delay = 0.14, reverb = 0.5 } },
	Shield            = { { id = S.Shield, vol = 0.70, speed = 1.0 }, { id = S.Chime, vol = 0.45, speed = 1.25, delay = 0.06, maxDur = 1.1 } },
	Surge             = { { id = S.Launch, vol = 0.70, speed = 1.25 }, { id = S.Thruster2, vol = 0.55, speed = 1.3, delay = 0.05, maxDur = 1.2 } },
	WindSlash         = { { id = S.Whoosh1, vol = 0.75, speed = 1.55 }, { id = S.Whoosh2, vol = 0.65, speed = 1.85, delay = 0.12, echo = 0.25 } },
	ThunderStrike     = { { id = S.Thunder, vol = 0.85, speed = 1.15 }, { id = S.Flash, vol = 0.65, speed = 1.3, delay = 0.04 } },
	MagnetPulse       = { { id = S.Portal1, vol = 0.60, speed = 1.35, maxDur = 1.0 }, { id = S.Coin, vol = 0.65, speed = 1.15, delay = 0.10 } },
	PhantomBlink      = { { id = S.Flash, vol = 0.65, speed = 1.65 }, { id = S.PortalCls, vol = 0.60, speed = 1.4, delay = 0.06 } },
	FrostBite         = { { id = S.Twinkle, vol = 0.70, speed = 1.45, echo = 0.35 }, { id = S.Impact, vol = 0.65, speed = 1.35, delay = 0.08 } },
	NatureVortex      = { { id = S.Wind, vol = 0.65, speed = 1.2, maxDur = 1.3 }, { id = S.Twinkle, vol = 0.55, speed = 1.1, delay = 0.10 } },
	MidasBurst        = { { id = S.Jackpot, vol = 0.75, speed = 1.1 }, { id = S.Coin, vol = 0.70, speed = 1.35, delay = 0.12 }, { id = S.Boom, vol = 0.50, speed = 1.2, delay = 0.04 } },
	AbyssalGrasp      = { { id = S.PortalAmb, vol = 0.70, speed = 0.72, maxDur = 1.2 }, { id = S.Hit, vol = 0.65, speed = 0.75, delay = 0.12, reverb = 0.6 } },
	RailgunSurge      = { { id = S.PreThrust, vol = 0.65, speed = 1.4, maxDur = 0.5 }, { id = S.Thruster2, vol = 0.75, speed = 1.15, delay = 0.12, maxDur = 1.3 } },
	QuantumWarp       = { { id = S.Portal2, vol = 0.70, speed = 1.5, maxDur = 0.9 }, { id = S.Flash, vol = 0.60, speed = 1.8, delay = 0.06 } },
	CosmicSingularity = { { id = S.Portal1, vol = 0.75, speed = 0.78, maxDur = 1.2 }, { id = S.Explosion, vol = 0.85, speed = 0.72, delay = 0.28, reverb = 0.7 } },
	InfernoBlaze      = { { id = S.Fire, vol = 0.80, speed = 1.1, maxDur = 1.4 }, { id = S.Explosion, vol = 0.65, speed = 1.05, delay = 0.08 } },
	AcmeAnvil         = { { id = S.Whoosh2, vol = 0.60, speed = 0.65 }, { id = S.Boom, vol = 0.90, speed = 0.70, delay = 0.22, distort = 0.2 }, { id = S.Hit, vol = 0.65, speed = 0.8, delay = 0.25 } },
	MagmaWake         = { { id = S.Fire, vol = 0.70, speed = 0.85, maxDur = 1.4 }, { id = S.Boom, vol = 0.65, speed = 0.9, delay = 0.10 } },
	AngelAscend       = { { id = S.Chime, vol = 0.65, speed = 1.2, maxDur = 1.2 }, { id = S.Flash, vol = 0.70, speed = 0.95, delay = 0.20, reverb = 0.6 } },
	AngelBurst        = { { id = S.Explosion, vol = 0.80, speed = 1.1, reverb = 0.6 }, { id = S.Twinkle, vol = 0.65, speed = 1.0, delay = 0.05 } },
	CardBarrage       = { { id = S.Pop, vol = 0.70, speed = 1.4 }, { id = S.Whoosh1, vol = 0.60, speed = 1.7, delay = 0.07 }, { id = S.Hit, vol = 0.65, speed = 1.45, delay = 0.16 } },
	ChaosPulse        = { { id = S.KO, vol = 0.75, speed = 1.15, echo = 0.35 }, { id = S.Portal2, vol = 0.60, speed = 1.3, delay = 0.08, maxDur = 1.0 } },
	NorthStarBeam     = { { id = S.PreLaunch, vol = 0.65, speed = 1.5, maxDur = 0.45 }, { id = S.Launch, vol = 0.75, speed = 1.4, delay = 0.10, echo = 0.25 } },
	SolarEclipse      = { { id = S.Riser, vol = 0.65, speed = 1.1, maxDur = 0.8 }, { id = S.Fire, vol = 0.70, speed = 1.2, delay = 0.12, maxDur = 1.2 } },
	VoidRift          = { { id = S.PortalCls, vol = 0.75, speed = 0.78 }, { id = S.PortalAmb, vol = 0.60, speed = 0.8, delay = 0.08, maxDur = 1.2 } },
	AtomicNova        = { { id = S.PreLaunch, vol = 0.75, speed = 1.15, maxDur = 0.6 }, { id = S.Explosion, vol = 0.95, speed = 0.68, delay = 0.24, reverb = 0.75 }, { id = S.Boom, vol = 0.85, speed = 0.65, delay = 0.26 } },
	KuramaRoar        = { { id = S.Boom, vol = 0.85, speed = 0.68, distort = 0.35 }, { id = S.Explosion, vol = 0.75, speed = 0.85, delay = 0.08 }, { id = S.Wind, vol = 0.65, speed = 0.75, delay = 0.04, maxDur = 1.3 } },
	TimeFreeze        = { { id = S.Riser, vol = 0.70, speed = 0.85, maxDur = 0.6 }, { id = S.Boom, vol = 0.90, speed = 0.58, delay = 0.14, echo = 0.45 }, { id = S.Tick, vol = 0.55, speed = 0.9, delay = 0.35 } },
	BinaryOverload    = { { id = S.Thunder, vol = 0.65, speed = 1.65 }, { id = S.Open, vol = 0.60, speed = 1.8, delay = 0.06 }, { id = S.Close, vol = 0.60, speed = 1.8, delay = 0.14 } },
	SaiyanOverdrive   = { { id = S.Thruster, vol = 0.75, speed = 1.2, maxDur = 1.3 }, { id = S.Thunder, vol = 0.70, speed = 1.35, delay = 0.08 }, { id = S.Launch, vol = 0.65, speed = 1.2, delay = 0.16 } },
	CorvusSwarm       = { { id = S.Wind, vol = 0.70, speed = 1.55, maxDur = 1.1 }, { id = S.Whoosh1, vol = 0.65, speed = 1.75, delay = 0.08 }, { id = S.Whoosh2, vol = 0.60, speed = 1.9, delay = 0.18 } },
	HeavyCrash        = { { id = S.HeavyCrash, vol = 0.90, speed = 1.0 }, { id = S.Boom, vol = 0.70, speed = 0.85, delay = 0.05, distort = 0.25 } },
	CheckpointChime   = { { id = S.Chime, vol = 0.80, speed = 1.0, reverb = 0.4 } },
}

local function playLayer(layer, parent)
	local s = Instance.new("Sound")
	s.SoundId = layer.id
	s.Volume = layer.vol or 0.65
	s.PlaybackSpeed = layer.speed or 1.0
	s.SoundGroup = getSfxGroup()
	s.RollOffMaxDistance = 180
	s.RollOffMinDistance = 15

	if layer.pitch then
		local ps = Instance.new("PitchShiftSoundEffect", s)
		ps.Octave = layer.pitch
	end
	if layer.echo then
		local ec = Instance.new("EchoSoundEffect", s)
		ec.Delay = 0.14
		ec.Feedback = layer.echo
	end
	if layer.reverb then
		local rv = Instance.new("ReverbSoundEffect", s)
		rv.DecayTime = 1.4
		rv.WetLevel = -6 * (1 - layer.reverb)
	end
	if layer.distort then
		local dt = Instance.new("DistortionSoundEffect", s)
		dt.Level = layer.distort
	end

	s.Parent = parent or SoundService
	s:Play()
	if layer.maxDur then
		task.delay(layer.maxDur, function()
			if s.Parent then s:Stop(); s:Destroy() end
		end)
	end
	Debris:AddItem(s, (layer.maxDur or 2.5) + 0.5)
	return s
end

function M.Play(abilityName, parent)
	local animeFolder = ReplicatedStorage:FindFirstChild("AnimeSounds")
	local custom = animeFolder and animeFolder:FindFirstChild(abilityName)
	if custom and custom:IsA("Sound") and custom.SoundId ~= "" then
		local clone = custom:Clone()
		clone.SoundGroup = getSfxGroup()
		clone.Parent = parent or SoundService
		clone:Play()
		Debris:AddItem(clone, math.max(clone.TimeLength, 4) + 0.5)
		return
	end
	local recipe = RECIPES[abilityName]
	if not recipe then
		recipe = { { id = S.Whoosh1, vol = 0.55, speed = 1.2 } }
	end
	for _, layer in ipairs(recipe) do
		if layer.delay and layer.delay > 0 then
			task.delay(layer.delay, function()
				playLayer(layer, parent)
			end)
		else
			playLayer(layer, parent)
		end
	end
end

function M.PlaySound(soundIdOrName, vol, pitch, parent)
	local id = S[soundIdOrName] or soundIdOrName
	if not id or id == "" then return nil end
	local s = Instance.new("Sound")
	s.SoundId = id
	s.Volume = vol or 0.7
	s.PlaybackSpeed = pitch or 1.0
	s.SoundGroup = getSfxGroup()
	s.RollOffMaxDistance = 220
	s.RollOffMinDistance = 15
	s.Parent = parent or SoundService
	s:Play()
	Debris:AddItem(s, 5)
	return s
end

return M
