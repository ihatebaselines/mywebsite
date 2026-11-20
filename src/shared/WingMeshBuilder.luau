local AS = game:GetService("AssetService")
local RS = game:GetService("ReplicatedStorage")

local M = {}
local cache = {}

local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local DEC = {}
for i = 1, 64 do DEC[string.byte(B64, i)] = i - 1 end

local function decodeB64(str)
	local len = #str
	local out = table.create(math.ceil(len * 0.75))
	local n, acc, bits = 0, 0, 0
	for i = 1, len do
		local c = DEC[string.byte(str, i)]
		if c ~= nil then
			acc = bit32.bor(bit32.lshift(acc, 6), c)
			bits += 6
			if bits >= 8 then
				bits -= 8
				n += 1
				out[n] = string.char(bit32.band(bit32.rshift(acc, bits), 0xFF))
			end
		end
	end
	return buffer.fromstring(table.concat(out))
end

local function buildHalf(buf, nv, nt, mirrorX)
	local em = AS:CreateEditableMesh()
	local vids = table.create(nv)
	local off = 4
	local sx = mirrorX and -1 or 1
	for i = 1, nv do
		local x = (buffer.readi16(buf, off) * 0.001) * sx
		local y = buffer.readi16(buf, off + 2) * 0.001
		local z = buffer.readi16(buf, off + 4) * 0.001
		off += 6
		vids[i] = em:AddVertex(Vector3.new(x, y, z))
	end
	for i = 1, nt do
		local a = vids[buffer.readu16(buf, off) + 1]
		local b = vids[buffer.readu16(buf, off + 2) + 1]
		local c = vids[buffer.readu16(buf, off + 4) + 1]
		off += 6
		if a and b and c then
			if mirrorX then
				em:AddTriangle(a, c, b)
			else
				em:AddTriangle(a, b, c)
			end
		end
	end
	local mp = AS:CreateMeshPartAsync(Content.fromObject(em), { CollisionFidelity = Enum.CollisionFidelity.Box })
	mp.Anchored = false
	mp.CanCollide = false
	mp.CanQuery = false
	mp.CanTouch = false
	mp.Massless = true
	mp.CastShadow = false
	mp.Material = Enum.Material.SmoothPlastic
	mp.TopSurface = Enum.SurfaceType.Studs
	mp.BottomSurface = Enum.SurfaceType.Studs
	return mp
end

function M.BuildModel(name)
	if cache[name] then
		return cache[name]:Clone()
	end
	local folder = RS:FindFirstChild("Shared") and RS.Shared:FindFirstChild("WingMeshes")
	local mod = folder and folder:FindFirstChild(name)
	if not (mod and mod:IsA("ModuleScript")) then return nil end
	local ok, b64Str = pcall(require, mod)
	if not (ok and type(b64Str) == "string") then return nil end

	local buf = decodeB64(b64Str)
	local nv = buffer.readu16(buf, 0)
	local nt = buffer.readu16(buf, 2)

	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("RootPart", "WingRoot")
	model:SetAttribute("BaseScale", 1.0)
	model:SetAttribute("WeldOffsetC0", CFrame.new(0, 0.35, 0.72))

	local root = Instance.new("Part")
	root.Name = "WingRoot"
	root.Size = Vector3.new(0.8, 0.8, 0.4)
	root.Transparency = 1
	root.Anchored = false
	root.CanCollide = false
	root.CanQuery = false
	root.CanTouch = false
	root.Massless = true
	root.Parent = model
	model.PrimaryPart = root

	local rw = buildHalf(buf, nv, nt, false)
	rw.Name = "RightWing"
	local rHalfX = rw.Size.X * 0.5
	rw.CFrame = CFrame.new(rHalfX + 0.25, 0, 0)
	rw.Parent = model
	local mR = Instance.new("Motor6D")
	mR.Name = "RightWing"
	mR.Part0 = root
	mR.Part1 = rw
	mR.C0 = CFrame.new(0.25, 0, 0)
	mR.C1 = CFrame.new(-rHalfX, 0, 0)
	mR.Parent = root

	local lw = buildHalf(buf, nv, nt, true)
	lw.Name = "LeftWing"
	local lHalfX = lw.Size.X * 0.5
	lw.CFrame = CFrame.new(-(lHalfX + 0.25), 0, 0)
	lw.Parent = model
	local mL = Instance.new("Motor6D")
	mL.Name = "LeftWing"
	mL.Part0 = root
	mL.Part1 = lw
	mL.C0 = CFrame.new(-0.25, 0, 0)
	mL.C1 = CFrame.new(lHalfX, 0, 0)
	mL.Parent = root

	cache[name] = model
	return model:Clone()
end

-- Procedural robust wing generator for Creator Store fallbacks (R4)
function M.buildWing(wingDef)
	if type(wingDef) == "string" then
		local ok, Config = pcall(require, RS.Shared:WaitForChild("Config"))
		if ok and Config.Skins and Config.Skins[wingDef] then
			wingDef = Config.Skins[wingDef]
		else
			local okCat, WingCat = pcall(require, RS.Shared:WaitForChild("WingCatalog"))
			if okCat and WingCat.Catalog and WingCat.Catalog[wingDef] then
				wingDef = WingCat.Catalog[wingDef]
			else
				wingDef = { Name = wingDef, Category = "Angelic" }
			end
		end
	end
	wingDef = wingDef or {}

	local name = wingDef.Name or "ProceduralWing"
	local cat = wingDef.Category or "Angelic"
	local c1 = wingDef.Color1 or wingDef.Color or Color3.fromRGB(240, 240, 255)
	local c2 = wingDef.Color2 or c1:Lerp(Color3.new(1, 1, 1), 0.35)
	local mat = wingDef.Material
	if typeof(mat) == "string" then
		local ok, m = pcall(function() return Enum.Material[mat] end)
		mat = (ok and m) or Enum.Material.Neon
	elseif typeof(mat) ~= "EnumItem" then
		mat = Enum.Material.Neon
	end

	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("RootPart", "WingRoot")
	model:SetAttribute("BaseScale", 1.0)
	model:SetAttribute("WeldOffsetC0", CFrame.new(0, 0.35, 0.72))
	model:SetAttribute("Procedural", true)
	model:SetAttribute("Category", cat)

	local root = Instance.new("Part")
	root.Name = "WingRoot"
	root.Size = Vector3.new(0.6, 0.6, 0.4)
	root.Transparency = 1
	root.Anchored = false
	root.CanCollide = false
	root.CanQuery = false
	root.CanTouch = false
	root.Massless = true
	root.Parent = model
	model.PrimaryPart = root

	local function makePart(pName, size, cf, col, pMat, parentTo)
		local p = Instance.new("Part")
		p.Name = pName
		p.Size = size
		p.CFrame = cf
		p.Color = col
		p.Material = pMat or mat
		p.Anchored = false
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.Massless = true
		p.CastShadow = false
		p.TopSurface = Enum.SurfaceType.Smooth
		p.BottomSurface = Enum.SurfaceType.Smooth
		p.Parent = model

		local w = Instance.new("WeldConstraint")
		w.Part0 = parentTo
		w.Part1 = p
		w.Parent = p
		return p
	end

	local function makeWedge(pName, size, cf, col, pMat, parentTo)
		local p = Instance.new("WedgePart")
		p.Name = pName
		p.Size = size
		p.CFrame = cf
		p.Color = col
		p.Material = pMat or mat
		p.Anchored = false
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.Massless = true
		p.CastShadow = false
		p.TopSurface = Enum.SurfaceType.Smooth
		p.BottomSurface = Enum.SurfaceType.Smooth
		p.Parent = model

		local w = Instance.new("WeldConstraint")
		w.Part0 = parentTo
		w.Part1 = p
		w.Parent = p
		return p
	end

	-- Left and Right wing primary anchor parts
	local leftWing = Instance.new("Part")
	leftWing.Name = "LeftWing"
	leftWing.Size = Vector3.new(0.4, 0.4, 0.4)
	leftWing.Transparency = 1
	leftWing.Anchored = false
	leftWing.CanCollide = false
	leftWing.CanQuery = false
	leftWing.CanTouch = false
	leftWing.Massless = true
	leftWing.CFrame = root.CFrame * CFrame.new(-1.358, -0.314, 1.012)
	leftWing.Parent = model

	local rightWing = Instance.new("Part")
	rightWing.Name = "RightWing"
	rightWing.Size = Vector3.new(0.4, 0.4, 0.4)
	rightWing.Transparency = 1
	rightWing.Anchored = false
	rightWing.CanCollide = false
	rightWing.CanQuery = false
	rightWing.CanTouch = false
	rightWing.Massless = true
	rightWing.CFrame = root.CFrame * CFrame.new(1.645, -0.375, 1.147)
	rightWing.Parent = model

	local mLeft = Instance.new("Motor6D")
	mLeft.Name = "LeftWing"
	mLeft.Part0 = root
	mLeft.Part1 = leftWing
	mLeft.C0 = CFrame.new(-1.358, -0.314, 1.012)
	mLeft.Parent = root

	local mRight = Instance.new("Motor6D")
	mRight.Name = "RightWing"
	mRight.Part0 = root
	mRight.Part1 = rightWing
	mRight.C0 = CFrame.new(1.645, -0.375, 1.147)
	mRight.Parent = root

	-- Build category-specific geometric wings
	for _, side in ipairs({"Left", "Right"}) do
		local isLeft = (side == "Left")
		local anchor = isLeft and leftWing or rightWing
		local sx = isLeft and -1 or 1

		if cat == "Angelic" then
			local armCF = anchor.CFrame * CFrame.new(sx * 1.2, 0.6, 0.2) * CFrame.Angles(0, 0, sx * math.rad(-25))
			makePart(side .. "_Quill", Vector3.new(2.4, 0.3, 0.3), armCF, c1, Enum.Material.Neon, anchor)

			local featherConfigs = {
				{ len = 3.6, w = 0.6, th = 0.15, ox = 1.8, oy = 1.2, oz = 0.1, ang = -40, col = c1 },
				{ len = 3.2, w = 0.55, th = 0.15, ox = 2.4, oy = 0.8, oz = 0.05, ang = -25, col = c2 },
				{ len = 2.8, w = 0.5, th = 0.15, ox = 2.8, oy = 0.3, oz = 0.0, ang = -10, col = c1 },
				{ len = 2.2, w = 0.45, th = 0.15, ox = 3.0, oy = -0.2, oz = -0.05, ang = 5, col = c2 },
				{ len = 1.6, w = 0.4, th = 0.15, ox = 2.6, oy = -0.6, oz = -0.1, ang = 20, col = c1 },
			}
			for i, fc in ipairs(featherConfigs) do
				local fCF = anchor.CFrame * CFrame.new(sx * fc.ox, fc.oy, fc.oz) * CFrame.Angles(0, 0, sx * math.rad(fc.ang))
				makePart(side .. "_Feather" .. i, Vector3.new(fc.len, fc.w, fc.th), fCF, fc.col, mat, anchor)
				local tipCF = fCF * CFrame.new(sx * (fc.len * 0.5 + 0.3), 0, 0) * CFrame.Angles(0, 0, sx * math.rad(180))
				makeWedge(side .. "_Tip" .. i, Vector3.new(0.6, fc.w, fc.th), tipCF, fc.col, Enum.Material.Neon, anchor)
			end

			local ringCF = anchor.CFrame * CFrame.new(sx * 0.2, 0.8, 0.1) * CFrame.Angles(math.rad(90), 0, 0)
			makePart(side .. "_Halo", Vector3.new(0.8, 0.8, 0.1), ringCF, c2, Enum.Material.Neon, anchor)

		elseif cat == "Butterfly" then
			local foreCF = anchor.CFrame * CFrame.new(sx * 1.6, 1.4, 0.1) * CFrame.Angles(0, 0, sx * math.rad(-30))
			makePart(side .. "_Forewing", Vector3.new(3.0, 2.2, 0.08), foreCF, c1, Enum.Material.Glass, anchor)
			local trimCF = foreCF * CFrame.new(0, 1.1, 0)
			makePart(side .. "_ForeTrim", Vector3.new(3.1, 0.18, 0.12), trimCF, c2, Enum.Material.Neon, anchor)

			local hindCF = anchor.CFrame * CFrame.new(sx * 1.3, -0.6, 0.05) * CFrame.Angles(0, 0, sx * math.rad(15))
			makePart(side .. "_Hindwing", Vector3.new(2.4, 1.8, 0.08), hindCF, c2, Enum.Material.Glass, anchor)
			local hTrimCF = hindCF * CFrame.new(0, -0.9, 0)
			makePart(side .. "_HindTrim", Vector3.new(2.5, 0.16, 0.12), hTrimCF, c1, Enum.Material.Neon, anchor)

			local strutCF = anchor.CFrame * CFrame.new(sx * 0.8, 0.6, 0.15) * CFrame.Angles(0, 0, sx * math.rad(-45))
			makePart(side .. "_Strut", Vector3.new(1.8, 0.15, 0.15), strutCF, c2, Enum.Material.Neon, anchor)

		elseif cat == "Demon" then
			local bone1CF = anchor.CFrame * CFrame.new(sx * 1.0, 0.8, 0.15) * CFrame.Angles(0, 0, sx * math.rad(-45))
			makePart(side .. "_Bone1", Vector3.new(2.0, 0.35, 0.35), bone1CF, c2, Enum.Material.SmoothPlastic, anchor)

			local clawCF = anchor.CFrame * CFrame.new(sx * 1.8, 1.6, 0.2) * CFrame.Angles(0, 0, sx * math.rad(60))
			makeWedge(side .. "_Claw", Vector3.new(0.4, 0.9, 0.3), clawCF, c1, Enum.Material.Neon, anchor)

			local demonFingers = {
				{ ox = 2.5, oy = 1.2, ang = -20, len = 2.8 },
				{ ox = 2.8, oy = 0.2, ang = 5, len = 2.6 },
				{ ox = 2.4, oy = -0.9, ang = 35, len = 2.4 },
			}
			for i, df in ipairs(demonFingers) do
				local fCF = anchor.CFrame * CFrame.new(sx * df.ox, df.oy, 0.1) * CFrame.Angles(0, 0, sx * math.rad(df.ang))
				makePart(side .. "_Finger" .. i, Vector3.new(df.len, 0.22, 0.22), fCF, c2, Enum.Material.SmoothPlastic, anchor)

				local webCF = anchor.CFrame * CFrame.new(sx * (df.ox - 0.4), df.oy - 0.3, 0.05) * CFrame.Angles(0, 0, sx * math.rad(df.ang + 10))
				makePart(side .. "_Web" .. i, Vector3.new(df.len * 0.85, 0.9, 0.08), webCF, c1, Enum.Material.Neon, anchor)

				local pointCF = webCF * CFrame.new(0, -0.45, 0) * CFrame.Angles(0, 0, sx * math.rad(180))
				makeWedge(side .. "_Point" .. i, Vector3.new(df.len * 0.4, 0.5, 0.08), pointCF, c1, Enum.Material.Neon, anchor)
			end

		elseif cat == "Dragon" then
			local hornCF = anchor.CFrame * CFrame.new(sx * 0.6, 1.0, 0.2) * CFrame.Angles(0, 0, sx * math.rad(-60))
			makePart(side .. "_Horn", Vector3.new(1.4, 0.4, 0.4), hornCF, c2, Enum.Material.Slate, anchor)

			local armCF = anchor.CFrame * CFrame.new(sx * 1.6, 1.2, 0.15) * CFrame.Angles(0, 0, sx * math.rad(-35))
			makePart(side .. "_DragonArm", Vector3.new(2.8, 0.45, 0.45), armCF, c2, Enum.Material.SmoothPlastic, anchor)

			local dragonRibs = {
				{ ox = 3.2, oy = 1.4, ang = -15, len = 3.4, wSpan = 1.2 },
				{ ox = 3.4, oy = 0.3, ang = 10, len = 3.2, wSpan = 1.2 },
				{ ox = 3.0, oy = -0.8, ang = 30, len = 2.8, wSpan = 1.1 },
				{ ox = 2.2, oy = -1.6, ang = 50, len = 2.2, wSpan = 1.0 },
			}
			for i, rib in ipairs(dragonRibs) do
				local rCF = anchor.CFrame * CFrame.new(sx * rib.ox, rib.oy, 0.1) * CFrame.Angles(0, 0, sx * math.rad(rib.ang))
				makePart(side .. "_Rib" .. i, Vector3.new(rib.len, 0.28, 0.28), rCF, c2, Enum.Material.SmoothPlastic, anchor)

				local sailCF = anchor.CFrame * CFrame.new(sx * (rib.ox - 0.5), rib.oy - 0.4, 0.06) * CFrame.Angles(0, 0, sx * math.rad(rib.ang + 8))
				makePart(side .. "_Sail" .. i, Vector3.new(rib.len * 0.9, rib.wSpan, 0.1), sailCF, c1, Enum.Material.Neon, anchor)
			end

		else -- Creature or generic
			if string.find(name, "Bee") then
				local w1CF = anchor.CFrame * CFrame.new(sx * 1.5, 0.8, 0.1) * CFrame.Angles(0, 0, sx * math.rad(-25))
				makePart(side .. "_BeeWing1", Vector3.new(2.8, 1.2, 0.06), w1CF, c1, Enum.Material.Glass, anchor)
				local w2CF = anchor.CFrame * CFrame.new(sx * 1.3, -0.3, 0.05) * CFrame.Angles(0, 0, sx * math.rad(15))
				makePart(side .. "_BeeWing2", Vector3.new(2.2, 0.9, 0.06), w2CF, c2, Enum.Material.Glass, anchor)
				local spineCF = w1CF * CFrame.new(0, 0.3, 0.04)
				makePart(side .. "_Spine", Vector3.new(2.6, 0.12, 0.08), spineCF, Color3.fromRGB(35, 25, 10), Enum.Material.Neon, anchor)

			elseif string.find(name, "Owl") then
				local owlLayers = {
					{ ox = 1.5, oy = 0.7, len = 2.8, w = 1.4, col = c1 },
					{ ox = 2.2, oy = 0.3, len = 2.6, w = 1.3, col = c2 },
					{ ox = 2.5, oy = -0.3, len = 2.4, w = 1.2, col = c1 },
				}
				for i, ol in ipairs(owlLayers) do
					local oCF = anchor.CFrame * CFrame.new(sx * ol.ox, ol.oy, 0.08) * CFrame.Angles(0, 0, sx * math.rad(-15 * i))
					makePart(side .. "_OwlFeather" .. i, Vector3.new(ol.len, ol.w, 0.12), oCF, ol.col, Enum.Material.SmoothPlastic, anchor)
					local edgeCF = oCF * CFrame.new(0, -ol.w * 0.45, 0)
					makePart(side .. "_Comb" .. i, Vector3.new(ol.len, 0.15, 0.14), edgeCF, Color3.fromRGB(245, 250, 255), Enum.Material.Neon, anchor)
				end

			else -- Griffin or creature
				local baseBone = anchor.CFrame * CFrame.new(sx * 1.1, 0.5, 0.15) * CFrame.Angles(0, 0, sx * math.rad(-30))
				makePart(side .. "_BaseBone", Vector3.new(2.2, 0.35, 0.35), baseBone, c2, Enum.Material.SmoothPlastic, anchor)

				local grifFeathers = {
					{ ox = 2.0, oy = 0.9, ang = -35, len = 3.2, col = c1 },
					{ ox = 2.6, oy = 0.4, ang = -20, len = 3.0, col = c2 },
					{ ox = 2.8, oy = -0.2, ang = -5, len = 2.6, col = c1 },
					{ ox = 2.5, oy = -0.8, ang = 15, len = 2.2, col = c2 },
				}
				for i, gf in ipairs(grifFeathers) do
					local gCF = anchor.CFrame * CFrame.new(sx * gf.ox, gf.oy, 0.08) * CFrame.Angles(0, 0, sx * math.rad(gf.ang))
					makePart(side .. "_GriffinFeather" .. i, Vector3.new(gf.len, 0.5, 0.12), gCF, gf.col, Enum.Material.Neon, anchor)
				end
			end
		end
	end

	return model
end

M.BuildWing = M.buildWing

return M
