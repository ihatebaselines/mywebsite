local SS = game:GetService('ServerStorage')
local CS = game:GetService('CollectionService')
local RS = game:GetService('ReplicatedStorage')
local InsertService = game:GetService('InsertService')

local Config = require(RS.Shared.Config)
local Studifier = require(RS.Shared:WaitForChild('Studifier'))
local BlenderWingMeshes = require(RS.Shared:WaitForChild('BlenderWingMeshes'))
local WingMeshBuilder = require(RS.Shared:WaitForChild('WingMeshBuilder'))
if not WingMeshBuilder.buildWing then
    pcall(function()
        WingMeshBuilder = require(RS.Shared:WaitForChild('WingMeshBuilder'):Clone())
    end)
end
local WingCatalog = require(RS.Shared:WaitForChild('WingCatalog'))
if not WingCatalog.CreatorStoreWings then
    pcall(function()
        WingCatalog = require(RS.Shared:WaitForChild('WingCatalog'):Clone())
    end)
end
local Wing3DAttachments = require((script.Parent or game:GetService('ServerScriptService').Modules):WaitForChild('Wing3DAttachments'))

local W = {}

-- Standard dual attachment CFrames matching Workspace["Wings Aura"]
local WINGS_CF_LEFT = CFrame.new(
    -1.35753632, -0.313943386, 1.01230621,
    0.871593058, 0.258819193, 0.41633898,
    -0.23354277, 0.965925872, -0.111557774,
    -0.431025803, 2.93955864e-08, 0.902339637
)
local WINGS_CF_RIGHT = CFrame.new(
    1.64477539, -0.374972343, 1.14712524,
    -0.933012784, 0.258819073, 0.25000006,
    0.25000006, 0.965925813, -0.0669872761,
    -0.258819103, 4.61423362e-08, -0.965925932
)

-- Color and Material palette for every skin
local SKIN_PROPERTIES = {
    Cardboard = {Color = Color3.fromRGB(180, 140, 95), Material = Enum.Material.Cardboard},
    Bat = {Color = Color3.fromRGB(35, 30, 45), Material = Enum.Material.Plastic},
    GoldenStud = {Color = Color3.fromRGB(255, 215, 0), Material = Enum.Material.Neon},
    Phoenix = {Color = Color3.fromRGB(255, 105, 30), Material = Enum.Material.Neon},
    Fairy = {Color = Color3.fromRGB(255, 150, 230), Material = Enum.Material.Glass},
    Demon = {Color = Color3.fromRGB(180, 20, 30), Material = Enum.Material.Neon},
    Mecha = {Color = Color3.fromRGB(80, 190, 255), Material = Enum.Material.Metal},
    Glitch = {Color = Color3.fromRGB(140, 60, 255), Material = Enum.Material.Neon},
    Galaxy = {Color = Color3.fromRGB(30, 10, 65), Material = Enum.Material.Neon},
    Cartoon = {Color = Color3.fromRGB(255, 235, 90), Material = Enum.Material.SmoothPlastic},
    Lava = {Color = Color3.fromRGB(255, 70, 10), Material = Enum.Material.Neon},
    OneWing = {Color = Color3.fromRGB(245, 245, 255), Material = Enum.Material.Neon},
}

local function safeMat(matName, fallback)
    if typeof(matName) == 'EnumItem' then return matName end
    if type(matName) == 'string' then
        local ok, m = pcall(function() return Enum.Material[matName] end)
        if ok and m then return m end
    end
    return fallback or Enum.Material.Neon
end

local function attachSingleWing(wings, alas, skinId, def)
    local existing = wings:FindFirstChild('SingleWingMesh')
    if existing then existing:Destroy() end

    local ma = RS:FindFirstChild('FXLibrary') and RS.FXLibrary:FindFirstChild('MoreAuras')
    local owa = ma and ma:FindFirstChild('one winged angel')
    local tpl = owa and owa:FindFirstChild('Wing')
    if not (tpl and tpl:IsA('BasePart')) then return end

    alas.Transparency = 1
    local mesh = tpl:Clone()
    mesh.Name = 'SingleWingMesh'
    for _, c in ipairs(mesh:GetChildren()) do
        if c:IsA('Script') or c:IsA('LocalScript') then c:Destroy() end
    end
    mesh.Anchored = false
    mesh.CanCollide = false
    mesh.CanQuery = false
    mesh.CanTouch = false
    mesh.Massless = true

    local sc = (wings:GetAttribute('Scale') or 0.45) / 0.45
    mesh.Size = tpl.Size * (0.78 * sc)
    if skinId ~= 'OneWing' then
        mesh.Color = def.Color or Color3.fromRGB(220, 220, 255)
        mesh.Material = safeMat(def.Material, Enum.Material.Neon)
    else
        mesh.Color = Color3.fromRGB(22, 22, 28)
        mesh.Material = Enum.Material.SmoothPlastic
    end

    local baseCF = CFrame.new(3.15 * sc, 0.45 * sc, 0.12 * sc) * CFrame.Angles(math.rad(-180), 0, math.rad(165))
    mesh.CFrame = alas.CFrame * baseCF
    local w = Instance.new('Weld')
    w.Name = 'SingleWingWeld'
    w.Part0 = alas
    w.Part1 = mesh
    w.C0 = baseCF
    w.Parent = mesh
    mesh.Parent = wings
end

local TEMPLATE_BY_SKIN = {
    Demon = 'Skeleton',
    Corvus = 'Skeleton',
    Bat = 'Skeleton',
    VoidPhantom = 'Skeleton',
    ShadowTitan = 'Skeleton',
    Insanity = 'Skeleton',
    InsaneVoid = 'Skeleton',
    AbyssalDemon = 'Skeleton',
    HellfireDemon = 'Skeleton',
    EmeraldDragon = 'Skeleton',
    ObsidianDragon = 'Skeleton',
    Glitch = 'Crystal',
    Mecha = 'Crystal',
    FrostSeraph = 'Crystal',
    ReactorX = 'Crystal',
    HyperionCore = 'Crystal',
    CyberPrism = 'Crystal',
    AeroPrism = 'Crystal',
    AzureStorm = 'Crystal',
    OmegaCore = 'Crystal',
    FrostPrism = 'Crystal',
    PrismTitan = 'Crystal',
    CrystalButterfly = 'Moth',
    MonarchButterfly = 'Moth',
    BeeSwarmWing = 'Moth',
    Fairy = 'Moth',
    NatureVortex = 'Moth',
    VerdantGale = 'Moth',
    SpiritWisp = 'Moth',
    EmeraldWisp = 'Moth',
    WispHalo = 'Moth',
    SeraphimAngel = 'Angel',
    CelestialDove = 'Angel',
    OwlFeather = 'Angel',
    GriffinWing = 'Angel',
}

local INVISIBLE_RIG_PARTS = {
    CrystalWings = true,
    RightWing = true,
    LeftWing = true,
}

local function getWingDef(skinId)
    local def = Config.Skins and Config.Skins[skinId]
    if not def and WingCatalog then
        if WingCatalog.Catalog and WingCatalog.Catalog[skinId] then
            def = WingCatalog.Catalog[skinId]
        elseif WingCatalog.CreatorStoreWings then
            for _, w in ipairs(WingCatalog.CreatorStoreWings) do
                if w.Id == skinId or w.Name == skinId then
                    def = w
                    break
                end
            end
        end
    end
    return def
end

function W.TemplateForSkin(skinId)
    local def = getWingDef(skinId)
    if def and def.SingleWing then return 'Angel' end
    if def and def.BoneRig then return def.BoneRig end
    if def and def.WingStyle then return def.WingStyle end
    return TEMPLATE_BY_SKIN[skinId] or 'Angel'
end

local function isSecondaryPart(name)
    if name:find('Hindwing') then return true end
    return false
end

-- Ensure dual Torso.WINGS attachments and Torso.AURA attachment
local function setupTorsoAttachments(torso)
    local leftAtt, rightAtt
    for _, child in ipairs(torso:GetChildren()) do
        if child:IsA('Attachment') and child.Name == 'WINGS' then
            if child.Position.X < 0 then
                leftAtt = child
            else
                rightAtt = child
            end
        end
    end

    if not leftAtt then
        leftAtt = Instance.new('Attachment')
        leftAtt.Name = 'WINGS'
        leftAtt.CFrame = WINGS_CF_LEFT
        leftAtt:SetAttribute('Side', 'Left')
        leftAtt.Parent = torso

        local p1 = Instance.new('ParticleEmitter')
        p1.Name = 'Plume'
        p1.Texture = 'http://www.roblox.com/asset/?id=7511321694'
        p1.Rate = 2
        p1.Size = NumberSequence.new(0.4)
        p1.Parent = leftAtt

        local p2 = Instance.new('ParticleEmitter')
        p2.Name = 'Flare'
        p2.Texture = 'rbxassetid://8710671751'
        p2.Rate = 2
        p2.Size = NumberSequence.new(4.2)
        p2.Parent = leftAtt
    end

    if not rightAtt then
        rightAtt = Instance.new('Attachment')
        rightAtt.Name = 'WINGS'
        rightAtt.CFrame = WINGS_CF_RIGHT
        rightAtt:SetAttribute('Side', 'Right')
        rightAtt.Parent = torso

        local p1 = Instance.new('ParticleEmitter')
        p1.Name = 'Plume'
        p1.Texture = 'http://www.roblox.com/asset/?id=7511321694'
        p1.Rate = 2
        p1.Size = NumberSequence.new(0.4)
        p1.Parent = rightAtt

        local p2 = Instance.new('ParticleEmitter')
        p2.Name = 'Flare'
        p2.Texture = 'rbxassetid://8710671751'
        p2.Rate = 2
        p2.Size = NumberSequence.new(4.2)
        p2.Parent = rightAtt
    end

    local auraAtt = torso:FindFirstChild('AURA')
    if not auraAtt or not auraAtt:IsA('Attachment') then
        auraAtt = Instance.new('Attachment')
        auraAtt.Name = 'AURA'
        auraAtt.CFrame = CFrame.new(0, 0, 0)
        auraAtt.Parent = torso
    end

    return leftAtt, rightAtt, auraAtt
end

-- Resolve nested aura path (e.g. "Pack8/POF:RE AURA ANGEL")
local function resolveAuraModel(moreFolder, auraPath)
    if not moreFolder or not auraPath then return nil end
    if string.find(auraPath, "/") then
        local parts = string.split(auraPath, "/")
        local cur = moreFolder
        for _, part in ipairs(parts) do
            cur = cur and cur:FindFirstChild(part)
        end
        return cur
    else
        return moreFolder:FindFirstChild(auraPath)
    end
end

-- Mount paired aura particle emitters onto Torso.AURA
function W.MountAura(torso, wingDef)
    local auraAtt = torso:FindFirstChild('AURA')
    if not auraAtt or not auraAtt:IsA('Attachment') then
        auraAtt = Instance.new('Attachment')
        auraAtt.Name = 'AURA'
        auraAtt.CFrame = CFrame.new(0, 0, 0)
        auraAtt.Parent = torso
    end

    for _, child in ipairs(auraAtt:GetChildren()) do
        if child:IsA('ParticleEmitter') or child:GetAttribute('AuraFx') then
            child:Destroy()
        end
    end

    if not wingDef then return end

    local sources = {}
    if type(wingDef.AuraSrc) == "string" then
        table.insert(sources, wingDef.AuraSrc)
    elseif type(wingDef.AuraSrc) == "table" then
        for _, s in ipairs(wingDef.AuraSrc) do
            table.insert(sources, s)
        end
    end
    if wingDef.AuraSrcRaw and type(wingDef.AuraSrcRaw) == "string" and not table.find(sources, wingDef.AuraSrcRaw) then
        table.insert(sources, wingDef.AuraSrcRaw)
    end

    local moreFolder = RS:FindFirstChild('FXLibrary') and RS.FXLibrary:FindFirstChild('MoreAuras')
    if not moreFolder or #sources == 0 then return end

    for _, src in ipairs(sources) do
        local auraModel = resolveAuraModel(moreFolder, src)
        if auraModel then
            for _, d in ipairs(auraModel:GetDescendants()) do
                if d:IsA('ParticleEmitter') then
                    local e = d:Clone()
                    e.Name = 'Aura_' .. string.gsub(auraModel.Name, "%s+", "") .. '_' .. d.Name
                    e:SetAttribute('AuraFx', true)
                    e:SetAttribute('SkinFx', true)
                    e.Enabled = true
                    e.Rate = math.clamp(e.Rate, 4, 30)
                    e.Parent = auraAtt
                end
            end
        end
    end
end

-- Multi-stage robust loader (R4)
-- 1. Check ServerStorage.WingTemplates[name] or ReplicatedStorage.WingMeshes[name]
-- 2. Attempt pcall(InsertService.LoadAsset, assetId)
-- 3. Fallback cleanly to WingMeshBuilder.buildWing(wingDef)
function W.LoadModel(skinId, wingDef)
    local tplFolder = SS:FindFirstChild('WingTemplates')
    local meshFolder = RS:FindFirstChild('WingMeshes') or (RS:FindFirstChild('Shared') and RS.Shared:FindFirstChild('WingMeshes'))
    local tplName = W.TemplateForSkin(skinId)

    -- Stage 1: Template or pre-existing mesh matching the wing name specifically
    local foundTpl = nil
    if tplFolder then
        foundTpl = tplFolder:FindFirstChild(skinId)
            or (wingDef and wingDef.Name and tplFolder:FindFirstChild(wingDef.Name))
    end
    if not foundTpl and meshFolder then
        foundTpl = meshFolder:FindFirstChild(skinId)
            or (wingDef and wingDef.Name and meshFolder:FindFirstChild(wingDef.Name))
    end
    if foundTpl then
        return foundTpl:Clone(), "Template", tplName
    end

    -- Stage 2: Attempt InsertService:LoadAsset for assetId
    local assetId = wingDef and (wingDef.AssetId or wingDef.assetId)
    if assetId then
        local idNum = tonumber(assetId)
        if idNum then
            local ok, asset = pcall(function()
                return InsertService:LoadAsset(idNum)
            end)
            if ok and asset then
                local model = asset:FindFirstChild('Wings') 
                    or asset:FindFirstChildWhichIsA('Model')
                    or asset
                if model == asset and #asset:GetChildren() == 1 and asset:GetChildren()[1]:IsA('Model') then
                    model = asset:GetChildren()[1]
                end
                for _, d in ipairs(model:GetDescendants()) do
                    if d:IsA('LuaSourceContainer') then d:Destroy() end
                end
                model.Parent = nil
                asset:Destroy()
                return model, "CreatorStore", tplName
            end
        end
    end

    -- Stage 3: Fallback cleanly to WingMeshBuilder.buildWing(wingDef)
    local buildFn = WingMeshBuilder.buildWing or WingMeshBuilder.BuildWing
    if not buildFn then
        pcall(function()
            WingMeshBuilder = require(RS.Shared:WaitForChild('WingMeshBuilder'):Clone())
            buildFn = WingMeshBuilder.buildWing or WingMeshBuilder.BuildWing
        end)
    end
    local procWing = buildFn and buildFn(wingDef or skinId)
    if procWing then
        return procWing, "Procedural", tplName
    end

    -- Stage 4 (Ultimate safety fallback): template by style or legacy Angel
    if tplFolder then
        local styleTpl = tplFolder:FindFirstChild(tplName) or tplFolder:FindFirstChild('Angel')
        if styleTpl then
            return styleTpl:Clone(), "FallbackTemplate", tplName
        end
    end
    local legacy = SS:FindFirstChild('WingsModel')
    if legacy and legacy:FindFirstChild('Wings') then
        return legacy.Wings:Clone(), "FallbackLegacy", "Angel"
    end
    return nil, "Failed", "Angel"
end

function W.SetSkin(wings, skinId, tierId)
    local def = getWingDef(skinId)
    local s = SKIN_PROPERTIES[skinId]
    local tier = tierId and Config.Tiers and Config.Tiers[tierId]
    local rootName = wings:GetAttribute('RootPart') or 'WingRoot'
    local alas = wings:FindFirstChild(rootName) or wings:FindFirstChild('ALAS') or wings:FindFirstChild('WingRoot') or wings.PrimaryPart or wings:FindFirstChildWhichIsA('BasePart')
    local col = (tier and tier.Color) or (s and s.Color) or (def and (def.Color1 or def.Color)) or SKIN_PROPERTIES.Cardboard.Color
    local col2 = (def and def.Color2) or col:Lerp(Color3.new(1, 1, 1), 0.35)
    local mat = (tier and tier.Material and safeMat(tier.Material)) or (s and s.Material) or (def and safeMat(def.Material)) or Enum.Material.Neon

    local oldSingle = wings:FindFirstChild('SingleWingMesh')
    if oldSingle then oldSingle:Destroy() end
    local oldAtt = wings:FindFirstChild('Attachments3D')
    if oldAtt then oldAtt:Destroy() end

    for _, d in ipairs(wings:GetDescendants()) do
        if d:IsA('BasePart') and not d:GetAttribute('SkinFx') and not d:GetAttribute('ProceduralPart') then
            if INVISIBLE_RIG_PARTS[d.Name] then
                d.Transparency = 1
            else
                if not wings:GetAttribute('Procedural') then
                    d.Color = isSecondaryPart(d.Name) and col2 or col
                    d.Material = mat
                    d.Reflectance = (mat == Enum.Material.Metal or mat == Enum.Material.Glass) and 0.22 or 0
                    d.Transparency = (def and def.SingleWing) and 1 or ((mat == Enum.Material.Glass or mat == Enum.Material.ForceField) and 0.18 or 0)
                    d.TopSurface = Enum.SurfaceType.Studs
                    d.BottomSurface = Enum.SurfaceType.Studs
                end
            end
        end
    end

    if alas and def and def.SingleWing then
        attachSingleWing(wings, alas, skinId, def)
    end
    wings:SetAttribute('Skin', skinId)
    wings:SetAttribute('Tier', tierId or 'Normal')
    Studifier.Apply(wings)
    pcall(function() Wing3DAttachments.Apply(wings, skinId, col, col2) end)
end

function W.Apply(char, skinId, scale, tierId)
    local old = char:FindFirstChild('WingsRig')
    if old then old:Destroy() end

    local torso = char:FindFirstChild('UpperTorso') or char:FindFirstChild('Torso')
    if not torso then return nil end

    -- Setup dual Torso.WINGS attachments and Torso.AURA attachment matching Workspace["Wings Aura"]
    local leftAtt, rightAtt, auraAtt = setupTorsoAttachments(torso)

    local reqScale = scale or 0.45
    local def = getWingDef(skinId)
    local wings, loadOrigin, tplName = W.LoadModel(skinId, def)
    if not wings then return nil end

    wings.Name = 'WingsRig'
    wings:SetAttribute('Template', tplName)
    wings:SetAttribute('LoadOrigin', loadOrigin)

    local rootName = wings:GetAttribute('RootPart') or (wings:FindFirstChild('ALAS') and 'ALAS') or 'WingRoot'
    local baseScale = wings:GetAttribute('BaseScale') or 0.45
    local weldC0 = wings:GetAttribute('WeldOffsetC0') or CFrame.new(0, 0.3, 0.9)
    wings:SetAttribute('RootPart', rootName)

    for _, d in ipairs(wings:GetDescendants()) do
        if d:IsA('Script') or d:IsA('LocalScript') then
            d:Destroy()
        elseif d:IsA('Weld') and d.Name ~= 'SingleWingWeld' and d.Name ~= 'LeftWingMount' and d.Name ~= 'RightWingMount' then
            -- keep structural welds
        elseif d:IsA('BasePart') then
            d.Anchored = false
            d.CanCollide = false
            d.CanQuery = false
            d.CanTouch = false
            d.Massless = true
        end
    end

    local finalScale = reqScale * (baseScale / 0.45)
    wings:ScaleTo(finalScale)
    wings:SetAttribute('Scale', reqScale)

    local bVar = wings:GetAttribute('BlenderVariant') or (BlenderWingMeshes.VariantConfigs[tplName] and tplName)
    if bVar then
        wings:SetAttribute('BlenderVariant', bVar)
        pcall(function()
            BlenderWingMeshes.PopulateRigMeshes(wings, bVar)
        end)
    end

    local alas = wings:FindFirstChild(rootName) or wings:FindFirstChild('ALAS') or wings:FindFirstChild('WingRoot') or wings.PrimaryPart or wings:FindFirstChildWhichIsA('BasePart')
    if not alas then wings:Destroy() return nil end

    -- Dual Wing Mounting matching Torso.WINGS attachments
    local leftWing = wings:FindFirstChild('LeftWing')
    local rightWing = wings:FindFirstChild('RightWing')
    if leftWing and rightWing and not wings:GetAttribute('Procedural') then
        local wL = Instance.new('WeldConstraint')
        wL.Name = 'LeftWingMount'
        wL.Part0 = torso
        wL.Part1 = leftWing
        wL.Parent = leftWing

        local wR = Instance.new('WeldConstraint')
        wR.Name = 'RightWingMount'
        wR.Part0 = torso
        wR.Part1 = rightWing
        wR.Parent = rightWing
    end

    local scaleRatio = reqScale / 0.45
    local weldOffset = CFrame.new(weldC0.Position * scaleRatio) * (weldC0 - weldC0.Position)
    alas.CFrame = torso.CFrame * weldOffset
    local w = Instance.new('Weld')
    w.Name = 'WingWeld'
    w.Part0 = torso
    w.Part1 = alas
    w.C0 = weldOffset
    w.Parent = alas

    wings.Parent = char

    -- Apply skin appearance
    W.SetSkin(wings, skinId, tierId)

    -- Mount aura particle emitters from ReplicatedStorage.FXLibrary.MoreAuras to Torso.AURA
    W.MountAura(torso, def)

    CS:AddTag(wings, 'WingsFx')

    return wings
end

return W
