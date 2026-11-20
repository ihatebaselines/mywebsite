-- Decor: biome-aware, ground-snapped scenery for the spline highway, streamed in chunks.
-- Chunks spawn ahead of the flyers and despawn behind them, so the world never carries the whole track.
-- Every chunk is deterministic (seeded by round seed + chunk index), so a chunk always looks the same.
local BiomeFX = require(script.Parent.BiomeFX)
local Studifier = require(game:GetService('ReplicatedStorage'):WaitForChild('Shared'):WaitForChild('Studifier'))

local Decor = {}

local CHUNKS = 46 -- ~100 studs of track per chunk (Config.TrackLength / CHUNKS)
local AHEAD = 22 -- 22 chunks ahead (~2,200 studs lookahead buffer)
local BEHIND = 6 -- 6 chunks kept behind (~600 studs)
local CS = game:GetService('CollectionService')
local SS = game:GetService('ServerStorage')

-- Global orientation cache for rigged animal models (67 skinned mesh models from workspace.Animals)
local ANIMAL_ROT_CACHE = {}
local ORTHO_AXES = {
	Vector3.xAxis, -Vector3.xAxis,
	Vector3.yAxis, -Vector3.yAxis,
	Vector3.zAxis, -Vector3.zAxis
}

local function getAnimalBaseRot(model)
	local name = model.Name
	if ANIMAL_ROT_CACHE[name] then
		return ANIMAL_ROT_CACHE[name]
	end

	-- Search the 24 standard orthonormal rotation matrices to find
	-- the exact orientation where Head is highest and LookVector points forward
	local h = model:FindFirstChild("HEAD", true)
	local f = model:FindFirstChild("FOOT_BL", true) 
		or model:FindFirstChild("FOOT_L", true) 
		or model:FindFirstChild("FOOT_R", true) 
		or model:FindFirstChild("LEG_BL_L", true)
		or model:FindFirstChild("LEG_L_L", true)
		or model:FindFirstChild("LEG_BL_U", true)
		or model:FindFirstChild("LEG_L_U", true)
		or model:FindFirstChild("TAIL_01", true)
	local r = model:FindFirstChild("ROOT", true) or model:FindFirstChild("BODY", true)

	local clone = model:Clone()
	clone.Parent = workspace
	local bestRot = CFrame.identity
	local bestScore = -999999

	for _, right in ipairs(ORTHO_AXES) do
		for _, up in ipairs(ORTHO_AXES) do
			if math.abs(right:Dot(up)) < 0.001 then
				local fwd = right:Cross(up)
				local rot = CFrame.fromMatrix(Vector3.zero, right, up, -fwd)
				clone:PivotTo(rot)
				local hp = h and h.WorldCFrame.Position or Vector3.yAxis
				local fp = f and f.WorldCFrame.Position or -Vector3.yAxis
				local rp = r and r.WorldCFrame.Position or Vector3.zero
				local headAboveFeet = hp.Y - fp.Y
				local headFwd = (hp - rp):Dot(rot.LookVector)
				local score = headAboveFeet * 10 + headFwd * 5
				if score > bestScore then
					bestScore = score
					bestRot = rot
				end
			end
		end
	end
	clone:Destroy()

	ANIMAL_ROT_CACHE[name] = bestRot
	return bestRot
end

local function bboxOf(inst)
	if inst:IsA("Model") then
		return inst:GetBoundingBox()
	end
	return inst.CFrame, inst.Size
end

-- lowest point of an instance's bounding box, measured along `up` from `origin`
local function lowestAlong(inst, origin, up)
	local bb, size = bboxOf(inst)
	local low = math.huge
	for _, sx in ipairs({ -0.5, 0.5 }) do
		for _, sy in ipairs({ -0.5, 0.5 }) do
			for _, sz in ipairs({ -0.5, 0.5 }) do
				local corner = bb * Vector3.new(sx * size.X, sy * size.Y, sz * size.Z)
				low = math.min(low, (corner - origin):Dot(up))
			end
		end
	end
	return low
end

-- Put `inst` on the road: the lowest point of its box touches the road plane at (x, z) of the course frame `cf`.
-- upright = true keeps it vertical in the world (trees, lamps, animals); false follows the road slope (houses, rugs).
local function plant(inst, cf, x, z, yaw, upright, lift)
	local ground = cf:PointToWorldSpace(Vector3.new(x, 0, z))
	local rot, up
	if upright then
		local f = cf.LookVector
		rot = CFrame.Angles(0, math.atan2(-f.X, -f.Z), 0) * CFrame.Angles(0, yaw, 0)
		up = Vector3.yAxis
	else
		rot = cf.Rotation * CFrame.Angles(0, yaw, 0)
		up = cf.UpVector
	end
	inst:PivotTo(CFrame.new(ground) * rot)
	local low = lowestAlong(inst, ground, up)
	inst:PivotTo(inst:GetPivot() + up * (lift - low))
	return ground
end

-- ctx: SplineUtils, cp (spline control points), getBiomeForT, findAsset, applyStuds, animalsFolder,
--      deco / fauna (parent folders), movers (the round's per-frame mover list), seed
function Decor.Create(ctx)
	local SplineUtils, cp = ctx.SplineUtils, ctx.cp
	local getBiome, findAsset, applyStuds = ctx.getBiomeForT, ctx.findAsset, ctx.applyStuds
	local animals = ctx.animalsFolder
	local decoRoot, faunaRoot, movers = ctx.deco, ctx.fauna, ctx.movers
	local seed = ctx.seed or 1
	local highwayRoot = ctx.highway
	local obsRoot = ctx.obs
	local ringsRoot = ctx.rings
	local orbsList = ctx.orbs
	local obstaclesModule = ctx.Obstacles
	local obsPlan = ctx.obstaclePlan
	local len = ctx.len or 4600

	local chunks = {}
	local failed = {}
	local S = {}

	local function frameAt(t)
		return SplineUtils.GetCourseFrame(cp, math.clamp(t, 0, 1))
	end

	local function pick(...)
		for _, n in ipairs({ ... }) do
			if findAsset(n) then
				return n
			end
		end
		return nil
	end

		-- anchor, strip scripts, stud-ify and size a cloned asset (cached on template for zero lag spikes)
	local function prepTemplateOnce(tpl)
		if tpl:GetAttribute("SW_Prepped") then return end
		tpl:SetAttribute("SW_Prepped", true)
		for _, d in ipairs(tpl:GetDescendants()) do
			if d:IsA("BaseScript") then
				d:Destroy()
			elseif d:IsA("BasePart") then
				d.Anchored = true
				d.CanCollide = false
				d.CanTouch = false
				d.CanQuery = false
				d.CastShadow = false
				applyStuds(d)
			end
		end
		if tpl:IsA("BasePart") then
			tpl.Anchored = true
			tpl.CanCollide = false
			tpl.CanTouch = false
			tpl.CanQuery = false
			tpl.CastShadow = false
			applyStuds(tpl)
		end
	end
	local function prep(inst, cap, name, rng)
		local lname = string.lower(name or inst.Name)
		local conifer = lname:find("pine") or lname:find("conifer") or lname:find("wintertree") or lname:find("tree 3") or lname:find("tree 4")
		local _, size = bboxOf(inst)
		local maxDim = math.max(size.X, size.Y, size.Z)
		if maxDim <= 0.01 then
			return
		end
		local target = nil
		if conifer then
			target = cap * rng:NextNumber(0.75, 1.1) -- conifers vary in height but stay predictable
		elseif maxDim > cap then
			target = cap
		end
		if target then
			local k = target / maxDim
			if inst:IsA("Model") then
				inst:ScaleTo(inst:GetScale() * k)
			else
				inst.Size = inst.Size * k
			end
		end
	end

	local function build(ci)
		local t0, t1 = (ci - 1) / CHUNKS, ci / CHUNKS
		local rng = Random.new(seed + ci * 7919)
		local chunk = { movers = {} }
		local folder = Instance.new("Folder")
		folder.Name = "Chunk" .. ci
		local ffolder = Instance.new("Folder")
		ffolder.Name = "Chunk" .. ci
		chunk.folder, chunk.ffolder = folder, ffolder
		local occ = {} -- footprints already used in this chunk (world XZ), so nothing overlaps
		local alt = (ci % 2 == 0)

		local function tAt(f)
			return t0 + (t1 - t0) * f
		end

		local function isFree(pos, r)
			for _, o in ipairs(occ) do
				local dx, dz = o.x - pos.X, o.z - pos.Z
				local rr = o.r + r
				if dx * dx + dz * dz < rr * rr then
					return false
				end
			end
			return true
		end

		local function addMover(fn)
			table.insert(movers, fn)
			table.insert(chunk.movers, fn)
		end

		-- clone, size and plant an asset. opts: upright, lift, sink (fraction of height sunk), check (skip if overlapping), parent
		local function put(name, cap, cf, x, z, yaw, opts)
			opts = opts or {}
			local tpl = name and findAsset(name)
			if not tpl then
				return nil
			end
			-- Safety: if tpl is a catalog board or container model, resolve a random individual child
			if tpl.Name:match("^%d%d_") or (tpl.Parent and tpl.Parent.Name == "ROBLOX_NATURE_480_ASSET_PACK") or (tpl:IsA("Model") and not tpl:FindFirstChildOfClass("Humanoid") and not tpl.PrimaryPart and #tpl:GetChildren() >= 8 and tpl:FindFirstChildWhichIsA("MeshPart")) then
				local ch = {}
				for _, c in ipairs(tpl:GetChildren()) do
					if c:IsA("Model") or c:IsA("MeshPart") or c:IsA("BasePart") then
						table.insert(ch, c)
					end
				end
				if #ch > 0 then
					tpl = ch[rng:NextInteger(1, #ch)]
				end
			end
			prepTemplateOnce(tpl)
			local m = tpl:Clone()
			prep(m, cap, name, rng)
			local _, sz0 = bboxOf(m)
			local lift = (opts.lift or 0) - (opts.sink or 0) * sz0.Y
			local ground = plant(m, cf, x, z, yaw or 0, opts.upright, lift)
			local r = math.max(sz0.X, sz0.Z) * 0.35
			if opts.check and not isFree(ground, r) then
				m:Destroy()
				return nil
			end
			table.insert(occ, { x = ground.X, z = ground.Z, r = r })
			m.Parent = opts.parent or folder
			return m, ground
		end

		local function putAnimal(name, cap, cf, x, z, yaw, sink)
			local uaPacks = SS:FindFirstChild("UserAssetPacks")
			local uaAnimals = uaPacks and uaPacks:FindFirstChild("Animals")
			local wsAnimals = workspace:FindFirstChild("Animals")
			local studCreatures = SS:FindFirstChild("StudCreatures")
			local tpl = (uaAnimals and uaAnimals:FindFirstChild(name))
				or (animals and animals:FindFirstChild(name))
				or (wsAnimals and wsAnimals:FindFirstChild(name))
				or (studCreatures and studCreatures:FindFirstChild(name))
			if not tpl then
				return nil
			end
			prepTemplateOnce(tpl)
			local m = tpl:Clone()
			prep(m, cap, name, rng)

			local isSkinned = m:FindFirstChildWhichIsA("Bone", true) ~= nil
			local baseRot = isSkinned and getAnimalBaseRot(tpl) or CFrame.identity

			-- Natural course alignment along the road shoulder tangent
			local f = cf.LookVector
			local roadYaw = math.atan2(-f.X, -f.Z)
			local totalYaw = roadYaw + (yaw or 0)

			-- Ground planting with exact foot snapping
			local groundPos = cf:PointToWorldSpace(Vector3.new(x, 0, z))
			local initialCf = CFrame.new(groundPos) * CFrame.Angles(0, totalYaw, 0) * baseRot
			m:PivotTo(initialCf)
			local low = lowestAlong(m, groundPos, Vector3.yAxis)
			local heightSink = (sink or 0) * (bboxOf(m).Y or 4)
			local finalPos = groundPos + Vector3.yAxis * (-heightSink - low)
			local placedPivot = CFrame.new(finalPos) * CFrame.Angles(0, totalYaw, 0) * baseRot
			m:PivotTo(placedPivot)

			-- Animate on client (ClientWorldAnim) to avoid per-frame server CFrame/Bone replication lag
			m:SetAttribute("AnimKind", m:GetAttribute("CreatureAnim") or (sink and sink > 0.1 and "Swim") or "Quad")
			m:SetAttribute("AnimOrigin", finalPos)
			m:SetAttribute("AnimFwd", f)
			m:SetAttribute("AnimYaw", totalYaw)
			m:SetAttribute("AnimBaseRot", baseRot)
			m:SetAttribute("AnimPhase", rng:NextNumber(0, 6.28))
			m:SetAttribute("AnimPatrol", rng:NextNumber(5, 11))
			CS:AddTag(m, "SW_ClientAnim")
			m.Parent = ffolder
			return m
		end

				----------------------------------------------------------------- highway road slices (Catmull-Rom sampled)
		local function buildRoad()
			if not highwayRoot then return end
			local roadFolder = Instance.new("Folder")
			roadFolder.Name = "RoadChunk" .. ci
			roadFolder.Parent = highwayRoot
			chunk.roadFolder = roadFolder

			local tMid = (t0 + t1) * 0.5
			if ci % 5 == 0 and ci < 46 then
				local archCF = frameAt(tMid)
				local bArch = getBiome(tMid)
				local archModel = Instance.new("Model")
				archModel.Name = "CheckpointArch_" .. ci
				for _, side in ipairs({-73, 73}) do
					local col = Instance.new("Part")
					col.Size = Vector3.new(6, 62, 6)
					col.CFrame = archCF * CFrame.new(side, 29, 0)
					col.Color = bArch.FloorCol:Lerp(Color3.new(0.15, 0.18, 0.28), 0.45)
					col.Material = Enum.Material.Plastic
					col.TopSurface = Enum.SurfaceType.Studs
					col.Anchored = true
					col.CanCollide = false
					col.Parent = archModel
				end
				local top = Instance.new("Part")
				top.Size = Vector3.new(152, 6, 8)
				top.CFrame = archCF * CFrame.new(0, 60, 0)
				top.Color = bArch.BarrierCol
				top.Material = Enum.Material.Neon
				top.TopSurface = Enum.SurfaceType.Studs
				top.Anchored = true
				top.CanCollide = false
				top.Parent = archModel
				archModel.Parent = roadFolder
			end

			local skyCF = frameAt(tMid)
			local bSky = getBiome(tMid)
			for side = -1, 1, 2 do
				if (ci + (side > 0 and 1 or 0)) % 2 == 0 then
					local distOut = side * rng:NextNumber(145, 235)
					local yOff = rng:NextNumber(-20, 48)
					local isl = Instance.new("Part")
					isl.Name = "SkyIsland"
					isl.Size = Vector3.new(rng:NextNumber(28, 52), rng:NextNumber(8, 16), rng:NextNumber(28, 52))
					isl.CFrame = skyCF * CFrame.new(distOut, yOff, rng:NextNumber(-30, 30))
					isl.Color = bSky.FloorCol
					isl.Material = Enum.Material.Plastic
					isl.TopSurface = Enum.SurfaceType.Studs
					isl.BottomSurface = Enum.SurfaceType.Studs
					isl.Anchored = true
					isl.CanCollide = false
					isl.Parent = roadFolder

					local cld = Instance.new("Part")
					cld.Name = "StudCloud"
					cld.Size = Vector3.new(rng:NextNumber(30, 56), rng:NextNumber(8, 14), rng:NextNumber(22, 40))
					cld.CFrame = skyCF * CFrame.new(-distOut * 0.9, rng:NextNumber(45, 95), rng:NextNumber(-35, 35))
					cld.Color = Color3.fromRGB(245, 250, 255)
					cld.Material = Enum.Material.SmoothPlastic
					cld.Transparency = 0.12
					cld.TopSurface = Enum.SurfaceType.Studs
					cld.Anchored = true
					cld.CanCollide = false
					cld.Parent = roadFolder
				end
			end

			local SLICES_PER_CHUNK = 14
			local stepT = (t1 - t0) / SLICES_PER_CHUNK
			local prevDir = nil
			for s = 1, SLICES_PER_CHUNK do
				local st0 = t0 + (s - 1) * stepT
				local st1 = t0 + s * stepT
				local stMid = (st0 + st1) * 0.5

				local p0 = SplineUtils.GetPoint(cp, st0)
				local p1 = SplineUtils.GetPoint(cp, st1)
				local mid = (p0 + p1) * 0.5
				local chord = p1 - p0
				local dist = chord.Magnitude
				local dir = (dist > 0.001) and (chord / dist) or Vector3.new(0, 0, -1)

				-- Outer-edge arc compensation: a 140-stud wide slab needs extra length proportional to 70 * turnAngle
				local tPrev = SplineUtils.GetTangent(cp, math.max(0, st0 - stepT * 0.5))
				local tNext = SplineUtils.GetTangent(cp, math.min(1, st1 + stepT * 0.5))
				local turnA = math.acos(math.clamp((prevDir or tPrev):Dot(dir), -1, 1))
				local turnB = math.acos(math.clamp(dir:Dot(tNext), -1, 1))
				local turnAngle = math.max(turnA, turnB)
				prevDir = dir

				local right = dir:Cross(Vector3.new(0, 1, 0))
				if right.Magnitude < 0.001 then right = Vector3.new(1, 0, 0) else right = right.Unit end
				local up = right:Cross(dir).Unit
				local bank = (SplineUtils.GetBankAngle(cp, st0) + SplineUtils.GetBankAngle(cp, st1)) * 0.5
				local cf = CFrame.fromMatrix(mid, right, up, -dir) * CFrame.Angles(0, 0, bank)

				local biome = getBiome(stMid)
				local segLen = dist + 76 * turnAngle + 2.4

				-- Highway Floor (140 studs wide, zero outer-edge gaps, pure Studs)
				local fl = Instance.new("Part")
				fl.Name = "HighwayFloor"
				fl.Size = Vector3.new(140, 4, segLen)
				fl.CFrame = cf * CFrame.new(0, -2, 0)
				fl.Color = biome.FloorCol
				fl.Material = (biome.Type == "WaterBay") and Enum.Material.Glass or Enum.Material.Plastic
				fl.TopSurface = Enum.SurfaceType.Studs
				fl.BottomSurface = Enum.SurfaceType.Studs
				fl.LeftSurface = Enum.SurfaceType.Studs
				fl.RightSurface = Enum.SurfaceType.Studs
				fl.FrontSurface = Enum.SurfaceType.Studs
				fl.BackSurface = Enum.SurfaceType.Studs
				fl.Anchored = true
				fl.CanCollide = true
				fl.CanTouch = false
				fl.Parent = roadFolder

				-- Center Lane Dashed Neon Speed Stripes (every other slice)
				if s % 2 == 1 then
					local dash = Instance.new("Part")
					dash.Name = "LaneDash"
					dash.Size = Vector3.new(2.6, 0.3, dist * 0.58)
					dash.CFrame = cf * CFrame.new(0, 0.16, 0)
					dash.Color = biome.BarrierCol
					dash.Material = Enum.Material.Neon
					dash.Anchored = true
					dash.CanCollide = false
					dash.CanTouch = false
					dash.CastShadow = false
					dash.Parent = roadFolder
				end

				-- Side Stud Guardrails (Neon)
				local railL = Instance.new("Part")
				railL.Name = "GuardRailL"
				railL.Size = Vector3.new(3, 8, segLen)
				railL.CFrame = cf * CFrame.new(-70, 4, 0)
				railL.Color = biome.BarrierCol
				railL.Material = Enum.Material.Neon
				railL.TopSurface = Enum.SurfaceType.Studs
				railL.BottomSurface = Enum.SurfaceType.Studs
				railL.Anchored = true
				railL.CanCollide = false
				railL.CanTouch = false
				railL.Parent = roadFolder

				local railR = Instance.new("Part")
				railR.Name = "GuardRailR"
				railR.Size = Vector3.new(3, 8, segLen)
				railR.CFrame = cf * CFrame.new(70, 4, 0)
				railR.Color = biome.BarrierCol
				railR.Material = Enum.Material.Neon
				railR.TopSurface = Enum.SurfaceType.Studs
				railR.BottomSurface = Enum.SurfaceType.Studs
				railR.Anchored = true
				railR.CanCollide = false
				railR.CanTouch = false
				railR.Parent = roadFolder

				-- GuideNet (Visual neon guide beams every 3rd slice)
				if s % 3 == 1 then
					local netL = Instance.new("Part")
					netL.Name = "GuideNetL"
					netL.Size = Vector3.new(0.8, 34, 0.8)
					netL.CFrame = cf * CFrame.new(-70, 21, 0)
					netL.Color = biome.BarrierCol
					netL.Material = Enum.Material.Neon
					netL.Transparency = 0.5
					netL.Anchored = true
					netL.CanCollide = false
					netL.CanTouch = false
					netL.Parent = roadFolder

					local netR = Instance.new("Part")
					netR.Name = "GuideNetR"
					netR.Size = Vector3.new(0.8, 34, 0.8)
					netR.CFrame = cf * CFrame.new(70, 21, 0)
					netR.Color = biome.BarrierCol
					netR.Material = Enum.Material.Neon
					netR.Transparency = 0.5
					netR.Anchored = true
					netR.CanCollide = false
					netR.CanTouch = false
					netR.Parent = roadFolder
				end
			end
		end

		local function buildObstaclesAndRings()
			if not obsPlan or not obstaclesModule then return end
			local d0 = t0 * len
			local d1 = t1 * len

			-- Spawn obstacle waves falling in this chunk
			if obsRoot and obsPlan.waves then
				local obsFolder = Instance.new("Folder")
				obsFolder.Name = "ObsChunk" .. ci
				obsFolder.Parent = obsRoot
				chunk.obsFolder = obsFolder

				for _, w in ipairs(obsPlan.waves) do
					if w.d0 >= d0 and w.d0 < d1 then
						obstaclesModule.SpawnWave({
							obs = obsFolder,
							deco = folder,
							cp = cp,
							len = len,
							rng = rng,
							theme = obsPlan.theme,
							register = function(dist, fn)
								addMover(fn)
							end
						}, w)
					end
				end
			end

			-- Spawn speed rings & orbs falling in this chunk
			if ringsRoot and obsPlan.rings then
				local ringsFolder = Instance.new("Folder")
				ringsFolder.Name = "RingsChunk" .. ci
				ringsFolder.Parent = ringsRoot
				chunk.ringsFolder = ringsFolder

				for _, r in ipairs(obsPlan.rings) do
					if r.dist >= d0 and r.dist < d1 then
						local m, pos = obstaclesModule.SpawnRing({
							deco = ringsFolder,
							cp = cp,
							len = len,
							theme = obsPlan.theme,
							CS = ctx.CS
						}, r)
						if m and pos and orbsList then
							local orbEntry = { model = m, pos = pos, kind = r.kind or "Ring", radius = (r.kind == "Ring" and 7.4 or 6.5), persist = (r.kind == "Ring"), chunk = ci }
							table.insert(orbsList, orbEntry)
						end
					end
				end
			end
		end

		----------------------------------------------------------------- grass scatter (dense ground carpets along track shoulders)
		local function grassScatter()
			local bt = getBiome(tAt(0.5)).Type
			local grassCount = rng:NextInteger(3, 5) -- tuned grass & flower patches per chunk for steady FPS
			local grassOpts = { upright = true, check = false } -- no check: allows natural clustering and dense overlapping cover!

			for _ = 1, grassCount do
				local fT = tAt(rng:NextNumber(0.02, 0.98))
				local cf = frameAt(fT)
				local sd = (rng:NextInteger(0, 1) == 1) and 1 or -1
				-- Track width is 140 studs. Shoulders extend X in [18, 66] and [-66, -18]
				local x = sd * rng:NextNumber(18, 66)
				local z = rng:NextNumber(-9, 9)
				local yaw = rng:NextNumber(0, 6.28)

				local assetName = nil
				local cap = rng:NextNumber(5.0, 8.5)

				if bt == "Valley" then
					local pool = {
						"GRASS_PATCH_01", "GRASS_PATCH_02", "GRASS_MEDIUM_01", "GRASS_MEDIUM_02", "GRASS_TALL_01", "GRASS_SMALL_01",
						"08_GRASS", "Stud Grass", "CLUSTER_GRASS_01", "FLOWER_PATCH_MIXED_01", "FLOWER_PATCH_MIXED_02",
						"FLOWER_PATCH_BLUE_01", "FLOWER_PATCH_PURPLE_01", "FLOWER_PATCH_YELLOW_01", "FlowerPurple", "FlowerOrange",
						"2 Blue Flower", "2 Pink Flower", "09_FLOWERS"
					}
					local candidate = pool[rng:NextInteger(1, #pool)]
				assetName = findAsset(candidate) and candidate or pick(table.unpack(pool))
				elseif bt == "Park" then
					local pool = {
						"GRASS_PATCH_01", "GRASS_PATCH_02", "GRASS_MEDIUM_02", "GRASS_MEDIUM_01", "08_GRASS", "Stud Grass",
						"Flowers", "FlowerBlue", "FlowerRed", "09_FLOWERS", "FLOWER_PATCH_MIXED_01", "FLOWER_PATCH_PURPLE_01"
					}
					local candidate = pool[rng:NextInteger(1, #pool)]
				assetName = findAsset(candidate) and candidate or pick(table.unpack(pool))
				elseif bt == "WaterBay" then
					local pool = {
						"CATTAIL_04", "REED_04", "BEACH_GRASS_01", "SWAMP_PLANT_01", "15_WETLAND_PLANTS", "BEACH_PLANT_01", "20_RIVER_NATURE", "GRASS_MEDIUM_01"
					}
					local candidate = pool[rng:NextInteger(1, #pool)]
				assetName = findAsset(candidate) and candidate or pick(table.unpack(pool))
					cap = rng:NextNumber(5.5, 9.5)
				elseif bt == "Forest" then
					local pool = {
						"GRASS_TALL_01", "GRASS_TALL_02", "GRASS_TALL_03", "GRASS_TALL_04", "08_GRASS", "10_FERNS", "11_FOLIAGE",
						"19_MUSHROOMS", "Blue Mushroom 1", "04_LOGS"
					}
					local candidate = pool[rng:NextInteger(1, #pool)]
				assetName = findAsset(candidate) and candidate or pick(table.unpack(pool))
					cap = rng:NextNumber(5.5, 9.0)
				elseif bt == "Winter" then
					local pool = {
						"GRASS_FROST_01", "GRASS_FROST_02", "GRASS_SMALL_01", "08_GRASS", "BUSH_SNOW_01", "BUSH_SNOW_02", "Pebble 1"
					}
					local candidate = pool[rng:NextInteger(1, #pool)]
				assetName = findAsset(candidate) and candidate or pick(table.unpack(pool))
				else -- Jungle
					local pool = {
						"13_JUNGLE_PLANTS", "10_FERNS", "18_VINES", "GRASS_TALL_01", "GRASS_MEDIUM_01", "08_GRASS", "11_FOLIAGE", "FLOWER_PURPLE_01"
					}
					local candidate = pool[rng:NextInteger(1, #pool)]
				assetName = findAsset(candidate) and candidate or pick(table.unpack(pool))
					cap = rng:NextNumber(6.0, 9.5)
				end

				if assetName then
					put(assetName, cap, cf, x, z, yaw, grassOpts)
				end
			end
		end

		----------------------------------------------------------------- flora scatter (rich flowers, shrubs, mushrooms, rocks)
		local function floraScatter()
			local bt = getBiome(tAt(0.5)).Type
			local up = { upright = true, check = true }
			local count = rng:NextInteger(2, 3)

			for _ = 1, count do
				local fT = tAt(rng:NextNumber(0.05, 0.95))
				local cf = frameAt(fT)
				local sd = (rng:NextInteger(0, 1) == 1) and 1 or -1
				local x = sd * rng:NextNumber(22, 60)
				local z = rng:NextNumber(-8, 8)
				local yaw = rng:NextNumber(0, 6.28)

				local assetName = nil
				local cap = 6

				if bt == "Valley" then
					local pool = {"09_FLOWERS", "2 Blue Flower", "2 Pink Flower", "2 Purple Flower", "3 Blue Flower", "3 Pink Flower", "3 Purple Flower", "Blue Flower", "BUSH_FLOWERING_01", "BUSH_FLOWERING_02", "BUSH_BERRY_01", "BUSH_GREEN_01", "08_GRASS", "CLUSTER_GRASS_01", "12_SMALL_PLANTS", "05_STUMPS"}
					assetName = pick(table.unpack(pool))
					cap = rng:NextNumber(4.5, 7.5)
				elseif bt == "Park" then
					local pool = {"Flowers", "FlowerBlue", "FlowerRed", "09_FLOWERS", "BUSH_FLOWERING_01", "BUSH_GREEN_02", "BUSH_GREEN_03", "2 Pink Flower", "3 Purple Flower", "08_GRASS", "Bush 2"}
					assetName = pick(table.unpack(pool))
					cap = rng:NextNumber(4, 7)
				elseif bt == "WaterBay" then
					local pool = {"15_WETLAND_PLANTS", "CATTAIL_04", "REED_04", "SWAMP_PLANT_01", "BEACH_GRASS_01", "BEACH_PLANT_01", "BEACH_ROCK_01", "BEACH_ROCK_02", "20_RIVER_NATURE", "06_ROCKS"}
					assetName = pick(table.unpack(pool))
					cap = rng:NextNumber(5, 9)
				elseif bt == "Forest" then
					local pool = {"19_MUSHROOMS", "Blue Mushroom 1", "Blue Mushroom 2", "BUSH_BERRY_01", "BUSH_BERRY_02", "BUSH_GREEN_04", "BUSH_GREEN_05", "06_ROCKS", "Big Rock", "StudRock", "04_LOGS", "03_BRANCHES"}
					assetName = pick(table.unpack(pool))
					cap = rng:NextNumber(5, 8.5)
				elseif bt == "Winter" then
					local pool = {"BUSH_SNOW_01", "BUSH_SNOW_02", "06_ROCKS", "Pebble 1", "Pebble 2", "Big Rock 3", "StudRock", "Lanterns 1"}
					assetName = pick(table.unpack(pool))
					cap = rng:NextNumber(5, 8)
				else -- Jungle
					local pool = {"13_JUNGLE_PLANTS", "18_VINES", "10_FERNS", "19_MUSHROOMS", "BUSH_GREEN_06", "BUSH_GREEN_07", "StudRock", "06_ROCKS"}
					assetName = pick(table.unpack(pool))
					cap = rng:NextNumber(5.5, 9)
				end

				if assetName then
					put(assetName, cap, cf, x, z, yaw, up)
				end
			end
		end

		----------------------------------------------------------------- settlement (houses, rooms, markets, camps)
		local function settlement()
			if ci % 4 ~= 1 then return end
			local tS = tAt(0.2)
			local cf = frameAt(tS)
			local bt = getBiome(tS).Type
			local sd = alt and 1 or -1
			local face = sd > 0 and math.rad(90) or math.rad(-90)
			local function pl(name, cap, x, z, yaw, lift)
				return put(name, cap, cf, sd * x, z, yaw, { lift = lift })
			end
			if bt == "Valley" then
				pl("House", 30, 42, 0, face)
				pl("Table", 7, 28, -6, 0)
				pl("Chair", 5, 28, -12, face)
				pl("Wardrobe", 9, 30, 10, face)
				pl("Fence 1", 9, 22, 16, face)
			elseif bt == "Park" then
				pl("Sofa", 10, 30, 0, face)
				pl("Coffee Table", 7, 22, 0, 0)
				local stand = pl("Tv Stand", 8, 40, 0, face)
				local standH = 0
				if stand then
					local _, ssz = bboxOf(stand)
					standH = ssz.Y
				end
				pl("Old TV", 6, 40, 6, face, standH) -- the TV sits on the stand, not inside it
				pl("Bed", 10, 30, -14, face)
			elseif bt == "WaterBay" then
				-- harbour on a wooden pier: stalls and crates never stand on the water itself
				local pier = Instance.new("Part")
				pier.Name = "Pier"
				pier.Size = Vector3.new(34, 1.2, 56)
				pier.Anchored = true
				pier.CanCollide = false
				pier.CanTouch = false
				pier.Material = Enum.Material.WoodPlanks
				pier.Color = Color3.fromRGB(139, 94, 60)
				applyStuds(pier)
				pier.CFrame = cf * CFrame.new(sd * 40, 0.6, 4)
				pier.Parent = folder
				table.insert(occ, { x = pier.Position.X, z = pier.Position.Z, r = 26 })
				pl("Stall Big", 16, 40, 0, face, 1.2)
				pl("Brown Barrel", 5, 32, 8, 0, 1.2)
				pl("Yellow Crate", 5, 32, -8, 0, 1.2)
				pl("Small Wagon", 12, 44, 16, face, 1.2)
			elseif bt == "Forest" then
				pl("Tent", 14, 38, 0, face)
				pl("Campfire", 6, 28, 0, 0)
				pl("Log with seat", 7, 28, 8, face)
				pl("Log with seat", 7, 28, -8, face)
				pl("Pickaxe", 5, 22, 4, 0)
			elseif bt == "Winter" then
				pl("House", 30, 44, 0, face)
				pl("Lanterns 1", 8, 30, 8, 0)
				pl("Bath", 9, 30, -8, face)
				pl("Small Wagon", 12, 24, 18, face)
			else
				pl("Stall Small", 12, 38, 0, face)
				pl("Shop", 16, 46, 14, face)
				pl("Brown Crate", 6, 30, -6, 0)
				pl("Mushromm", 7, 26, 8, 0)
			end
		end

		----------------------------------------------------------------- feature (road-centre island + animals)
		local function feature()
			local tF = tAt(0.5)
			local cf = frameAt(tF)
			local bt = getBiome(tF).Type
			local up = { upright = true }
			local sd = alt and 1 or -1
			local roadWalkYaw = (rng:NextInteger(0, 1) == 1) and 0 or math.pi

			if bt == "Valley" then
				local flowers = pick("09_FLOWERS", "Flowers")
				for k = -1, 1 do
					put(flowers, 7, cf, k * 18, rng:NextNumber(-3, 3), 0, up)
				end
				local valleyFauna = { "DEER", "RABBIT", "WILD_HORSE", "BISON", "MOUNTAIN_GOAT" }
				local an = valleyFauna[rng:NextInteger(1, #valleyFauna)]
				for _, a in ipairs({ -1, 1 }) do
					putAnimal(an, 7, cf, a * 26, rng:NextNumber(-4, 4), roadWalkYaw)
				end
				put("05_STUMPS", 6, cf, 0, 0, 0, up)
			elseif bt == "Park" then
				if alt then
					put(pick("Fountain", "ClassicFountain"), 14, cf, 0, 0, 0, up)
					for _, lx in ipairs({ -22, 22 }) do
						put("Street Light 2", 12, cf, lx, 0, 0, up)
					end
					putAnimal("DUCK", 4, cf, sd * 24, 0, roadWalkYaw)
				else
					local mat = Instance.new("Part")
					mat.Name = "PicnicMat"
					mat.Size = Vector3.new(14, 0.2, 14)
					mat.Color = Color3.fromRGB(200, 60, 60)
					mat.Material = Enum.Material.Fabric
					mat.Anchored = true
					mat.CanCollide = false
					mat.TopSurface = Enum.SurfaceType.Studs
					local groundPos = cf:PointToWorldSpace(Vector3.new(0, 0, 0))
					mat.CFrame = CFrame.new(groundPos + Vector3.new(0, 0.1, 0))
					mat.Parent = folder
					for _, bx in ipairs({ -18, 18 }) do
						put(pick("Park Bench", "Bench"), 9, cf, bx, 0, bx > 0 and math.rad(-90) or math.rad(90), {})
					end
					putAnimal("PIGEON", 4, cf, rng:NextNumber(-6, 6), rng:NextNumber(-4, 4), roadWalkYaw)
					putAnimal("SQUIRREL", 4, cf, sd * 26, 4, roadWalkYaw)
				end
			elseif bt == "WaterBay" then
				if alt then
					local sx = (ci % 4 == 0) and 24 or -24
					local ship = put("Stud Pirate Ship", 38, cf, sx, 0, math.rad(90), { sink = 0.22 })
					if ship then -- ships rock gently on the water (client-animated)
						ship:SetAttribute("AnimKind", "ShipRock")
						ship:SetAttribute("AnimOriginCF", ship:GetPivot())
						ship:SetAttribute("AnimPhase", rng:NextNumber(0, 6.28))
						CS:AddTag(ship, "SW_ClientAnim")
					end
				else
					put(pick("Bridge", "Bridge Rail"), 22, cf, 0, 0, 0, {})
				end
				local critterList = { "CROCODILE", "HIPPO", "TURTLE", "SEAL", "SEA_LION" }
				local critter = critterList[((ci + (alt and 1 or 0)) % #critterList) + 1]
				putAnimal(critter, 11, cf, alt and -22 or 22, 0, roadWalkYaw, 0.22) -- half submerged in water
				local reeds = pick("15_WETLAND_PLANTS", "CATTAIL_04")
				for _, cx in ipairs({ -26, 26 }) do
					put(reeds, 6, cf, cx, 0, 0, up)
				end
			elseif bt == "Forest" then
				local pine = pick("Pine Tree", "WinterTree4", "Tree 3")
				for _, tx in ipairs({ -44, -32, 32, 44 }) do -- outside the flight lane (+/-22)
					put(pine, 25, cf, tx, rng:NextNumber(-6, 6), rng:NextNumber(0, 6.28), { upright = true, check = true })
				end
				put("Campfire", 8, cf, 0, 0, 0, up)
				local seat = pick("Log with seat", "04_LOGS")
				for _, lx in ipairs({ -14, 14 }) do
					put(seat, 7, cf, lx, 0, math.rad(90), {})
				end
				local forestFauna = { "BEAR", "WOLF", "BOAR", "FOX", "DEER" }
				local an = forestFauna[((ci + (alt and 2 or 0)) % #forestFauna) + 1]
				putAnimal(an, 10, cf, alt and 26 or -26, 0, roadWalkYaw)
			elseif bt == "Winter" then
				local pine = pick("WinterTree4", "WinterTree1", "WinterTree3", "Pine Tree")
				for _, tx in ipairs({ -44, -32, 32, 44 }) do
					put(pine, 25, cf, tx, rng:NextNumber(-6, 6), rng:NextNumber(0, 6.28), { upright = true, check = true })
				end
				put(pick("Lanterns 1", "Lanterns 2"), 8, cf, 0, 0, 0, up)
				for _, lx in ipairs({ -20, 20 }) do
					put(pick("Lanterns 1", "Lanterns 2"), 8, cf, lx, 0, 0, up)
				end
				local winterFauna = { "POLAR_BEAR", "PENGUIN", "REINDEER", "ARCTIC_FOX", "ARCTIC_HARE" }
				local wa = winterFauna[((ci + (alt and 1 or 0)) % #winterFauna) + 1]
				putAnimal(wa, wa == "PENGUIN" and 5 or 11, cf, alt and 24 or -24, 0, roadWalkYaw)
			else -- Jungle
				put(pick("Stud Torch", "LANDMARK_ROOT_ARCH_01"), 13, cf, 0, 0, 0, up)
				local jungleFauna = { "GORILLA", "MONKEY", "JAGUAR", "CHEETAH", "ELEPHANT" }
				local ja = jungleFauna[((ci + (alt and 1 or 0)) % #jungleFauna) + 1]
				putAnimal(ja, 9, cf, alt and 24 or -24, 0, roadWalkYaw)
			end
		end

		----------------------------------------------------------------- border trees (outside the road centre)
		local function sideTrees()
			-- Per-tree biome + density: forests/jungle/tundra get thick, tall tree lines (two rows), while meadows stay open.
			-- Picking the biome per tree (not per chunk) makes forests thin out / thicken gradually across biome borders.
			local TREE_DENSITY = { Valley = 1, Park = 0.8, WaterBay = 0.45, Forest = 2.8, Winter = 2.1, Jungle = 2.4 }
			for _ = 1, 5 do
				local tT = tAt(rng:NextNumber(0.04, 0.96))
				local b = getBiome(tT)
				local density = (TREE_DENSITY[b.Type] or 1) / 2.8
				if rng:NextNumber() >= density then
					continue
				end
				local dense = density > 0.6
				local cf = frameAt(tT)
				local sd = (rng:NextInteger(0, 1) == 1) and 1 or -1
				local x = sd * rng:NextNumber(dense and 24 or 44, 66)
				local z = rng:NextNumber(-8, 8)
				local yaw = rng:NextNumber(0, 6.28)
				if b.Trees and #b.Trees > 0 then
					local nm = b.Trees[rng:NextInteger(1, #b.Trees)]
					put(nm, rng:NextNumber(26, 40) * (dense and 1.3 or 1), cf, x, z, yaw, { upright = true, check = true })
				end
			end
		end

		----------------------------------------------------------------- forest floor INSIDE the flight lane (forest / tundra / jungle zones are filled edge to edge)
		-- Tall trunks stay out of the +/-22 lane (flyers can't collide with scenery, so trunks there would look like clipping),
		-- but the whole lane floor is covered with undergrowth, logs, rocks and mushrooms so the zone reads as one continuous forest.
		local function laneFloor()
			local LANE_FILL = { Forest = 17, Winter = 10, Jungle = 15 }
			for _ = 1, 5 do
				local tT = tAt(rng:NextNumber(0.02, 0.98))
				local b = getBiome(tT)
				local want = LANE_FILL[b.Type]
				if want and b.Flora and #b.Flora > 0 and rng:NextNumber() < want / 20 then
					local nm = b.Flora[rng:NextInteger(1, #b.Flora)]
					if not findAsset(nm) then
						nm = pick(table.unpack(b.Flora))
					end
					if nm then
						put(nm, rng:NextNumber(3, 5.5), frameAt(tT), rng:NextNumber(-24, 24), rng:NextNumber(-6, 6), rng:NextNumber(0, 6.28), { upright = true, check = true })
					end
				end
			end
		end

		----------------------------------------------------------------- patrol car (land biomes only, never leaves its chunk)
		local function patrolCar()
			local tC = tAt(0.5)
			local bt = getBiome(tC).Type
			if not (bt == "Valley" or bt == "Park" or bt == "Forest") or ci % 6 ~= 1 then
				return
			end
			if getBiome(tAt(0.1)).Type ~= bt or getBiome(tAt(0.9)).Type ~= bt then
				return -- the patrol range would touch another biome (e.g. the water)
			end
			local tpl = findAsset("Car")
			if not tpl then
				return
			end
			prepTemplateOnce(tpl)
			local m = tpl:Clone()
			prep(m, 13, "Car", rng)
			m:PivotTo(CFrame.new(0, 100, 0))
			local lift = -lowestAlong(m, Vector3.new(0, 100, 0), Vector3.yAxis) -- pivot height above the wheels
			local laneX = (rng:NextInteger(0, 1) == 1) and 26 or -26
			local speed = rng:NextNumber(0.05, 0.08)
			local range = (t1 - t0) * 0.4
			local ph = rng:NextNumber(0, 6.28)
			m.Parent = folder
			addMover(function(t)
				if not m.Parent then
					return
				end
				local ang = t * speed * 6.28 + ph
				local cfa = frameAt(tC + math.sin(ang) * range)
				local yawDir = (math.cos(ang) >= 0) and 0 or math.pi
				m:PivotTo(cfa * CFrame.new(laneX, lift, 0) * CFrame.Angles(0, yawDir, 0))
			end)
		end

		----------------------------------------------------------------- ambient particle zone from the aura packs
				----------------------------------------------------------------- finish gate (Chunk 46 / t = 1)
		local function buildFinishGate()
			if ci ~= CHUNKS then return end
			local cf = frameAt(0.985)
			local gate = Instance.new("Model")
			gate.Name = "FinishGate"

			local gold = Color3.fromRGB(255, 215, 40)
			local cyan = Color3.fromRGB(80, 230, 255)

			local function part(name, size, relCf, col, mat)
				local p = Instance.new("Part")
				p.Name = name
				p.Size = size
				p.CFrame = cf * relCf
				p.Color = col
				p.Material = mat or Enum.Material.Neon
				p.Anchored = true
				p.CanCollide = false
				p.CanTouch = false
				p.CanQuery = false
				applyStuds(p)
				p.Parent = gate
				return p
			end

			-- Two grand pillars
			part("PillarL", Vector3.new(8, 72, 8), CFrame.new(-70, 36, 0), gold, Enum.Material.Neon)
			part("PillarR", Vector3.new(8, 72, 8), CFrame.new(70, 36, 0), gold, Enum.Material.Neon)

			-- Overhead arch beam + FINISH banner
			local beam = part("ArchBeam", Vector3.new(148, 12, 8), CFrame.new(0, 72, 0), Color3.fromRGB(30, 35, 55), Enum.Material.Plastic)
			part("ArchTrim", Vector3.new(150, 2.5, 9), CFrame.new(0, 65.5, 0), cyan, Enum.Material.Neon)

			local sg = Instance.new("SurfaceGui")
			sg.Face = Enum.NormalId.Back
			sg.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
			sg.PixelsPerStud = 12
			local lbl = Instance.new("TextLabel")
			lbl.Size = UDim2.fromScale(1, 1)
			lbl.BackgroundTransparency = 1
			lbl.Font = Enum.Font.FredokaOne
			lbl.Text = "FINISH"
			lbl.TextScaled = true
			lbl.TextColor3 = gold
			local st = Instance.new("UIStroke") st.Thickness = 4 st.Color = Color3.new(0,0,0) st.Parent = lbl
			lbl.Parent = sg
			sg.Parent = beam

			-- Checkered stud strip across the road
			for k = -6, 6 do
				local col = (k % 2 == 0) and Color3.new(1, 1, 1) or Color3.fromRGB(25, 25, 30)
				part("Check_" .. k, Vector3.new(10.5, 0.4, 8), CFrame.new(k * 10.5, 0.25, 0), col, Enum.Material.Plastic)
			end

			-- Celebratory sparkles on pillars
			for _, sx in ipairs({ -70, 70 }) do
				local emHost = part("Fx_" .. sx, Vector3.one, CFrame.new(sx, 74, 0), gold, Enum.Material.Neon)
				emHost.Transparency = 1
				local pe = Instance.new("ParticleEmitter")
				pe.Rate = 24
				pe.Lifetime = NumberRange.new(1.2, 2.2)
				pe.Speed = NumberRange.new(18, 35)
				pe.SpreadAngle = Vector2.new(50, 50)
				pe.LightEmission = 1
				pe.Color = ColorSequence.new(gold, cyan)
				pe.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1.8), NumberSequenceKeypoint.new(1, 0) })
				pe.Parent = emHost
			end

			gate.Parent = folder
		end

		local function ambientFx()
			local tM = tAt(0.5)
			local template = BiomeFX.Get(getBiome(tM).Type)
			if not template then
				return
			end
			local z = template:Clone()
			z.CFrame = frameAt(tM) * CFrame.new(0, template:GetAttribute("Lift") or 18, 0)
			z.Parent = folder
		end

		local function buildPremadeChunk()
			local pcFolder = SS:FindFirstChild("PremadeChunks")
			if not pcFolder then return end
			local tMid = tAt(0.5)
			local cf = frameAt(tMid)
			local templateName = nil
			local yOff = 0
			if ci == 14 or ci == 34 then
				templateName = "MountainWaterfall"
			elseif ci == 8 or ci == 26 then
				templateName = "CrystalArch"
			elseif ctx.multiverseChunk and ci == ctx.multiverseChunk then
				templateName = "MultiversePortal"
				yOff = 0
			end
			if not templateName then return end
			local tpl = pcFolder:FindFirstChild(templateName)
			if not tpl then return end
			prepTemplateOnce(tpl)
			local m = tpl:Clone()
			for _, d in ipairs(m:GetDescendants()) do
				if d:IsA("BasePart") then
					d.Anchored = true
					d.CanCollide = false
					d.CanTouch = false
					d.CanQuery = false
					d.CastShadow = false
					applyStuds(d)
				end
			end
			m:PivotTo(cf * CFrame.new(0, yOff, 0))
			if templateName == "MultiversePortal" then
				m:SetAttribute("AnimKind", "PortalSpin")
				m:SetAttribute("AnimOriginCF", m:GetPivot())
				CS:AddTag(m, "SW_ClientAnim")
				if ctx.onMultiversePortal then
					ctx.onMultiversePortal((cf * CFrame.new(0, 24, 0)).Position, m)
				end
			end
			m.Parent = folder
		end

		for _, step in ipairs({ buildRoad, buildObstaclesAndRings, grassScatter, floraScatter, settlement, feature, sideTrees, laneFloor, patrolCar, buildPremadeChunk, buildFinishGate, ambientFx }) do
			local ok, err = pcall(step)
			if not ok then
				warn(("[Decor] chunk %d step failed: %s"):format(ci, tostring(err)))
			end
		end

		folder.Parent = decoRoot
		ffolder.Parent = faunaRoot
		return chunk
	end

	local function destroyChunk(i)
		local c = chunks[i]
		if not c then
			return
		end
		chunks[i] = nil
		for _, fn in ipairs(c.movers) do
			local midx = table.find(movers, fn)
			if midx then
				table.remove(movers, midx)
			end
		end
		table.clear(c.movers)
		if c.folder then
			c.folder:Destroy()
		end
		if c.ffolder then
			c.ffolder:Destroy()
		end
		if c.roadFolder then
			c.roadFolder:Destroy()
		end
		if c.obsFolder then
			c.obsFolder:Destroy()
		end
		if c.ringsFolder then
			c.ringsFolder:Destroy()
		end
		if orbsList then
			for k = #orbsList, 1, -1 do
				if orbsList[k].chunk == i then
					table.remove(orbsList, k)
				end
			end
		end
	end

	-- tProg: flight progress 0..1. Builds chunks ahead (at most `maxBuild` per call), destroys chunks left behind.
	-- Strict invariant: Never allows more than 8 active chunks total to avoid memory bloat and physics lag.
	function S.Update(...)
		local args = { ... }
		local tProg = type(args[1]) == "table" and args[2] or args[1]
		local maxBuild = type(args[1]) == "table" and args[3] or args[2]
		if not tProg then return end

		local cur = math.clamp(math.floor(tProg * CHUNKS) + 1, 1, CHUNKS)
		local lo = math.max(1, cur - BEHIND)
		local hi = math.min(CHUNKS, cur + AHEAD)

		-- 1. Strictly prune any chunk outside the [lo, hi] window:
		-- Chunks left behind (i < lo) AND chunks far ahead (i > hi) are destroyed!
		for i in pairs(chunks) do
			if i < lo or i > hi then
				destroyChunk(i)
			end
		end

		-- 2. Build up to maxBuild chunks ahead within [cur, hi]
		local built, budget = 0, math.max(6, maxBuild or 6)
		for i = cur, hi do
			if not chunks[i] and not failed[i] then
				local ok, res = pcall(build, i)
				if ok then
					chunks[i] = res
				else
					failed[i] = true
					warn(("[Decor] chunk %d failed: %s"):format(i, tostring(res)))
				end
				built += 1
				if built >= budget then
					break
				end
			end
		end

		-- 3. Hard cap enforcement: strictly destroy chunks BEHIND (i < cur, lowest i first)
		while S.Active() > 30 do
			local oldestBehind = nil
			for i in pairs(chunks) do
				if i < cur then
					if not oldestBehind or i < oldestBehind then
						oldestBehind = i
					end
				end
			end
			if oldestBehind then
				destroyChunk(oldestBehind)
			else
				break
			end
		end
	end

	function S.Active()
		local n = 0
		for _ in pairs(chunks) do
			n += 1
		end
		return n
	end

	function S.Destroy()
		for i in pairs(chunks) do
			destroyChunk(i)
		end
	end

	return S
end

Decor.CHUNKS = CHUNKS
return Decor
