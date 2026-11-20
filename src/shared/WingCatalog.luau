local M = {}

M.Categories = { 'All', 'Angelic', 'Butterfly', 'Demon', 'Dragon', 'Creature', 'Prestige', 'Classic', 'Elemental', 'Cosmic', 'Divine & Dark', 'Fusion' }

M.ExtraAbilities = {
    NorthStarBeam = { Name = 'North Star', Key = 'E', Cooldown = 8, Damage = 26, Range = 75, Duration = 1.6, Desc = 'Blasts an icy star beam that freezes nearby rivals!', Color = Color3.fromRGB(140, 235, 255) },
    ChaosPulse = { Name = 'Chaos Pulse', Key = 'E', Cooldown = 9, Damage = 30, Range = 60, Knock = 60, Desc = 'Unleashes chaotic shockwaves that scatter nearby flyers.', Color = Color3.fromRGB(255, 85, 190) },
    CardBarrage = { Name = 'Card Barrage', Key = 'E', Cooldown = 8, Damage = 24, Range = 65, Knock = 45, Desc = 'Deals razor cards & grants +12 bonus Coins!', Color = Color3.fromRGB(255, 210, 75) },
    SolarEclipse = { Name = 'Solar Eclipse', Key = 'E', Cooldown = 10, Damage = 28, Range = 70, Duration = 1.5, Desc = 'Eclipses rivals, freezing them while surging ahead.', Color = Color3.fromRGB(255, 145, 50) },
    VoidRift = { Name = 'Void Rift', Key = 'E', Cooldown = 9, Damage = 32, Range = 65, Knock = 55, Desc = 'Tears open a dark rift that pulls & damages rivals.', Color = Color3.fromRGB(150, 70, 255) },
}

-- 11 Creator Store & Integrated Wings (R4)
M.CreatorStoreWings = {
    -- Angelic Category
    {
        Id = 'SeraphimAngel',
        Name = 'Seraphim Angel',
        Category = 'Angelic',
        Rarity = 'Mythic',
        Tier = 5,
        SpeedMult = 1.25,
        TurnMult = 1.20,
        LiftMult = 1.22,
        GlideRatio = 1.25,
        AssetId = '112607419744231',
        AuraSrc = 'Pack8/POF:RE AURA ANGEL',
        Color = Color3.fromRGB(255, 245, 215),
        Color1 = Color3.fromRGB(255, 245, 215),
        Color2 = Color3.fromRGB(255, 205, 75),
        Material = Enum.Material.Neon,
        WingStyle = 'Angel',
        BoneRig = 'Angel',
        Ability = 'AngelAscend',
        Cost = 8500,
        Desc = 'Six-winged seraphic divine wings with burning holy radiance.',
    },
    {
        Id = 'CelestialDove',
        Name = 'Celestial Dove',
        Category = 'Angelic',
        Rarity = 'Legendary',
        Tier = 4,
        SpeedMult = 1.18,
        TurnMult = 1.25,
        LiftMult = 1.20,
        GlideRatio = 1.22,
        AssetId = '12064263035',
        AuraSrc = 'Pack8/POF:RE AURA HEAVENLY',
        Color = Color3.fromRGB(240, 248, 255),
        Color1 = Color3.fromRGB(240, 248, 255),
        Color2 = Color3.fromRGB(175, 225, 255),
        Material = Enum.Material.SmoothPlastic,
        WingStyle = 'Angel',
        BoneRig = 'Angel',
        Ability = 'NorthStarBeam',
        Cost = 5500,
        Desc = 'Pure white feathered dove wings radiating peaceful celestial light.',
    },

    -- Butterfly Category
    {
        Id = 'MonarchButterfly',
        Name = 'Monarch Butterfly',
        Category = 'Butterfly',
        Rarity = 'Epic',
        Tier = 3,
        SpeedMult = 1.14,
        TurnMult = 1.30,
        LiftMult = 1.28,
        GlideRatio = 1.20,
        AssetId = '121429154401470',
        AuraSrc = 'Pack2/Aurora Borealis',
        Color = Color3.fromRGB(255, 130, 20),
        Color1 = Color3.fromRGB(255, 130, 20),
        Color2 = Color3.fromRGB(30, 25, 30),
        Material = Enum.Material.Neon,
        WingStyle = 'Moth',
        BoneRig = 'Moth',
        Ability = 'NatureVortex',
        Cost = 3800,
        Desc = 'Vibrant royal monarch wings capable of agile and elusive aerial maneuvers.',
    },
    {
        Id = 'CrystalButterfly',
        Name = 'Crystal Butterfly',
        Category = 'Butterfly',
        Rarity = 'Legendary',
        Tier = 4,
        SpeedMult = 1.17,
        TurnMult = 1.28,
        LiftMult = 1.24,
        GlideRatio = 1.24,
        AssetId = '14208327701',
        AuraSrc = 'Pack2/POF:RE AURA: Crystal determination',
        Color = Color3.fromRGB(215, 120, 255),
        Color1 = Color3.fromRGB(215, 120, 255),
        Color2 = Color3.fromRGB(120, 235, 255),
        Material = Enum.Material.Glass,
        WingStyle = 'Moth',
        BoneRig = 'Moth',
        Ability = 'FrostBite',
        Cost = 5800,
        Desc = 'Prismatic crystal butterfly wings shimmering with diamond determination.',
    },

    -- Demon Category
    {
        Id = 'AbyssalDemon',
        Name = 'Abyssal Demon',
        Category = 'Demon',
        Rarity = 'Epic',
        Tier = 4,
        SpeedMult = 1.19,
        TurnMult = 1.15,
        LiftMult = 1.16,
        GlideRatio = 1.18,
        AssetId = '14609819769',
        AuraSrc = 'Pack7/POF:RE AURA: Demonic Drive',
        Color = Color3.fromRGB(75, 20, 110),
        Color1 = Color3.fromRGB(75, 20, 110),
        Color2 = Color3.fromRGB(20, 15, 30),
        Material = Enum.Material.Neon,
        WingStyle = 'Skeleton',
        BoneRig = 'Skeleton',
        Ability = 'AbyssalGrasp',
        Cost = 5200,
        Desc = 'Spined demonic wings forged from the dark energies of the underworld.',
    },
    {
        Id = 'HellfireDemon',
        Name = 'Hellfire Demon',
        Category = 'Demon',
        Rarity = 'Mythic',
        Tier = 5,
        SpeedMult = 1.24,
        TurnMult = 1.18,
        LiftMult = 1.18,
        GlideRatio = 1.20,
        AssetId = '16542991280',
        AuraSrc = "Pack7/POF:RE AURA: Red King's Bash",
        Color = Color3.fromRGB(235, 35, 20),
        Color1 = Color3.fromRGB(235, 35, 20),
        Color2 = Color3.fromRGB(255, 140, 10),
        Material = Enum.Material.Neon,
        WingStyle = 'Skeleton',
        BoneRig = 'Skeleton',
        Ability = 'InfernoBlaze',
        Cost = 8200,
        Desc = 'Flaming infernal demon wings leaving trails of molten brimstone.',
    },

    -- Dragon Category
    {
        Id = 'EmeraldDragon',
        Name = 'Emerald Dragon',
        Category = 'Dragon',
        Rarity = 'Legendary',
        Tier = 4,
        SpeedMult = 1.20,
        TurnMult = 1.16,
        LiftMult = 1.25,
        GlideRatio = 1.26,
        AssetId = '14375073452',
        AuraSrc = 'Pack6/POF:RE AURA: Roar of The Jungle Dragon',
        Color = Color3.fromRGB(30, 200, 95),
        Color1 = Color3.fromRGB(30, 200, 95),
        Color2 = Color3.fromRGB(15, 75, 40),
        Material = Enum.Material.Neon,
        WingStyle = 'Skeleton',
        BoneRig = 'Skeleton',
        Ability = 'NatureVortex',
        Cost = 6200,
        Desc = 'Ancient reptilian dragon wings infused with primordial jungle power.',
    },
    {
        Id = 'ObsidianDragon',
        Name = 'Obsidian Dragon',
        Category = 'Dragon',
        Rarity = 'Mythic',
        Tier = 5,
        SpeedMult = 1.26,
        TurnMult = 1.16,
        LiftMult = 1.22,
        GlideRatio = 1.25,
        AssetId = '17337473570',
        AuraSrc = 'Pack8/POF:RE AURA SOLAR FLARE',
        Color = Color3.fromRGB(28, 28, 38),
        Color1 = Color3.fromRGB(28, 28, 38),
        Color2 = Color3.fromRGB(255, 90, 20),
        Material = Enum.Material.Neon,
        WingStyle = 'Skeleton',
        BoneRig = 'Skeleton',
        Ability = 'SolarEclipse',
        Cost = 9500,
        Desc = 'Volcanic obsidian dragon wings radiating explosive solar flare surges.',
    },

    -- Creature Category
    {
        Id = 'BeeSwarmWing',
        Name = 'Bee Swarm',
        Category = 'Creature',
        Rarity = 'Rare',
        Tier = 3,
        SpeedMult = 1.12,
        TurnMult = 1.35,
        LiftMult = 1.25,
        GlideRatio = 1.15,
        AssetId = nil,
        AuraSrc = 'Pack1/POF:RE AURA BEE SWARM',
        Color = Color3.fromRGB(255, 205, 20),
        Color1 = Color3.fromRGB(255, 205, 20),
        Color2 = Color3.fromRGB(40, 30, 10),
        Material = Enum.Material.Glass,
        WingStyle = 'Moth',
        BoneRig = 'Moth',
        Ability = 'WindSlash',
        Cost = 2800,
        Desc = 'Rapidly fluttering chitinous insect wings surrounded by buzzing swarm energy.',
    },
    {
        Id = 'OwlFeather',
        Name = 'Owl Feather',
        Category = 'Creature',
        Rarity = 'Epic',
        Tier = 3,
        SpeedMult = 1.15,
        TurnMult = 1.26,
        LiftMult = 1.30,
        GlideRatio = 1.32,
        AssetId = nil,
        AuraSrc = 'Pack5/POF:RE AURA CRYOGEN',
        Color = Color3.fromRGB(160, 215, 245),
        Color1 = Color3.fromRGB(160, 215, 245),
        Color2 = Color3.fromRGB(235, 245, 255),
        Material = Enum.Material.SmoothPlastic,
        WingStyle = 'Angel',
        BoneRig = 'Angel',
        Ability = 'FrostBite',
        Cost = 4200,
        Desc = 'Silent cryogenic owl plumage engineered for whisper-quiet soaring.',
    },
    {
        Id = 'GriffinWing',
        Name = 'Griffin Wing',
        Category = 'Creature',
        Rarity = 'Legendary',
        Tier = 4,
        SpeedMult = 1.21,
        TurnMult = 1.22,
        LiftMult = 1.24,
        GlideRatio = 1.26,
        AssetId = nil,
        AuraSrc = 'Pack1/POF:RE AURA SPEED STATE',
        Color = Color3.fromRGB(215, 165, 90),
        Color1 = Color3.fromRGB(215, 165, 90),
        Color2 = Color3.fromRGB(255, 235, 175),
        Material = Enum.Material.Neon,
        WingStyle = 'Angel',
        BoneRig = 'Angel',
        Ability = 'RailgunSurge',
        Cost = 6800,
        Desc = 'Majestic beast wings combining eagle swiftness and lion predatory power.',
    },
}

M.Catalog = {}
for _, w in ipairs(M.CreatorStoreWings) do
    M.Catalog[w.Id] = w
end

-- Pure MoreAuras
local PURE = {
    { id = 'NorthStar', name = 'North Star', aura = 'POF:RE AURA NORTH STAR', cat = 'Cosmic', rar = 'Legendary', spd = 1.14, ab = 'NorthStarBeam', col = Color3.fromRGB(140, 235, 255), mat = 'Neon' },
    { id = 'Corvus', name = 'Corvus', aura = 'POF:RE AURA CORVUS', cat = 'Divine & Dark', rar = 'Epic', spd = 1.12, ab = 'AbyssalGrasp', col = Color3.fromRGB(90, 60, 120), mat = 'Neon' },
    { id = 'Insanity', name = 'Insanity', aura = 'POF:RE AURA  INSANITY', cat = 'Divine & Dark', rar = 'Mythic', spd = 1.16, ab = 'ChaosPulse', col = Color3.fromRGB(220, 40, 110), mat = 'Neon' },
    { id = 'AvatarAscended', name = 'Avatar', aura = 'Avatar', cat = 'Divine & Dark', rar = 'Mythic', spd = 1.18, ab = 'AngelAscend', col = Color3.fromRGB(170, 240, 255), mat = 'Neon' },
    { id = 'OmegaCore', name = 'Omega', aura = 'Omega', cat = 'Cosmic', rar = 'Legendary', spd = 1.15, ab = 'RailgunSurge', col = Color3.fromRGB(110, 180, 255), mat = 'Metal' },
    { id = 'DaemonCards', name = 'Daemon Cards', aura = 'POF:RE AURA: Daemon of Cards', cat = 'Divine & Dark', rar = 'Epic', spd = 1.12, ab = 'CardBarrage', col = Color3.fromRGB(210, 60, 80), mat = 'SmoothPlastic' },
    { id = 'ChaosManifest', name = 'Chaos', aura = 'Manifestation of Chaos', cat = 'Cosmic', rar = 'Mythic', spd = 1.18, ab = 'CosmicSingularity', col = Color3.fromRGB(255, 200, 50), mat = 'Neon' },
    { id = 'UltraEgo', name = 'Ultra Ego', aura = 'POF:RE AURA ULTRA EGO', cat = 'Divine & Dark', rar = 'Mythic', spd = 1.17, ab = 'InfernoBlaze', col = Color3.fromRGB(175, 65, 255), mat = 'Neon' },
    { id = 'SpiritWisp', name = 'Spirit Wisp', aura = 'POF:RE AURA  WISP', cat = 'Elemental', rar = 'Rare', spd = 1.10, ab = 'NatureVortex', col = Color3.fromRGB(115, 255, 195), mat = 'Glass' },
    { id = 'VoidPhantom', name = 'Void Phantom', aura = 'Model', cat = 'Divine & Dark', rar = 'Epic', spd = 1.12, ab = 'VoidRift', col = Color3.fromRGB(85, 80, 115), mat = 'Neon' },
    { id = 'AeroPrism', name = 'Aero Prism', aura = 'Pack1', cat = 'Elemental', rar = 'Rare', spd = 1.09, ab = 'WindSlash', col = Color3.fromRGB(190, 245, 255), mat = 'Glass' },
    { id = 'AzureStorm', name = 'Azure Storm', aura = 'Pack2', cat = 'Elemental', rar = 'Epic', spd = 1.12, ab = 'ThunderStrike', col = Color3.fromRGB(40, 145, 255), mat = 'Neon' },
    { id = 'IronTitan', name = 'Iron Titan', aura = 'Pack3', cat = 'Elemental', rar = 'Rare', spd = 1.09, ab = 'Shield', col = Color3.fromRGB(120, 130, 155), mat = 'Metal' },
    { id = 'CelestialMist', name = 'Celestial Mist', aura = 'Pack4', cat = 'Cosmic', rar = 'Epic', spd = 1.13, ab = 'MagnetPulse', col = Color3.fromRGB(215, 200, 255), mat = 'Glass' },
    { id = 'CrimsonNova', name = 'Crimson Nova', aura = 'Pack5', cat = 'Elemental', rar = 'Legendary', spd = 1.15, ab = 'SolarEclipse', col = Color3.fromRGB(255, 95, 65), mat = 'Neon' },
    { id = 'NebulaDrift', name = 'Nebula Drift', aura = 'Pack6', cat = 'Cosmic', rar = 'Epic', spd = 1.12, ab = 'PhantomBlink', col = Color3.fromRGB(165, 115, 255), mat = 'Neon' },
    { id = 'VerdantGale', name = 'Verdant Gale', aura = 'Pack7', cat = 'Elemental', rar = 'Rare', spd = 1.10, ab = 'NatureVortex', col = Color3.fromRGB(145, 225, 75), mat = 'Neon' },
    { id = 'RadiantHalo', name = 'Radiant Halo', aura = 'Pack8', cat = 'Divine & Dark', rar = 'Legendary', spd = 1.15, ab = 'MidasBurst', col = Color3.fromRGB(255, 235, 135), mat = 'Neon' },
}

-- 37 Fusion pairs
local FUSIONS = {
    { 'FallenSeraph', 'Fallen Seraph', 'one winged angel', 'POF:RE AURA CORVUS', 'Divine & Dark', 'Mythic', 1.20, 'VoidRift' },
    { 'FrostEgo', 'Frost Ego', 'POF:RE AURA NORTH STAR', 'POF:RE AURA ULTRA EGO', 'Elemental', 'Mythic', 1.19, 'NorthStarBeam' },
    { 'ChaosOmega', 'Chaos Omega', 'Manifestation of Chaos', 'Omega', 'Cosmic', 'Mythic', 1.20, 'CosmicSingularity' },
    { 'PhantomDeck', 'Phantom Deck', 'POF:RE AURA: Daemon of Cards', 'POF:RE AURA  WISP', 'Divine & Dark', 'Legendary', 1.15, 'CardBarrage' },
    { 'AstralSeraph', 'Astral Seraph', 'one winged angel', 'POF:RE AURA NORTH STAR', 'Divine & Dark', 'Mythic', 1.20, 'AngelAscend' },
    { 'MadnessAvatar', 'Madness Avatar', 'POF:RE AURA  INSANITY', 'Avatar', 'Divine & Dark', 'Mythic', 1.19, 'ChaosPulse' },
    { 'SolarStorm', 'Solar Storm', 'Pack5', 'Pack2', 'Elemental', 'Legendary', 1.16, 'SolarEclipse' },
    { 'EmeraldWisp', 'Emerald Wisp', 'Pack7', 'POF:RE AURA  WISP', 'Elemental', 'Epic', 1.13, 'NatureVortex' },
    { 'AetherPrism', 'Aether Prism', 'Pack1', 'Pack4', 'Cosmic', 'Epic', 1.13, 'WindSlash' },
    { 'TitaniumVolt', 'Titanium Volt', 'Pack3', 'Pack2', 'Elemental', 'Epic', 1.13, 'ThunderStrike' },
    { 'StarlightHalo', 'Starlight Halo', 'Pack8', 'POF:RE AURA NORTH STAR', 'Cosmic', 'Legendary', 1.16, 'MidasBurst' },
    { 'VoidNebula', 'Void Nebula', 'Model', 'Pack6', 'Cosmic', 'Legendary', 1.16, 'PhantomBlink' },
    { 'EgoChaos', 'Ego Chaos', 'POF:RE AURA ULTRA EGO', 'Manifestation of Chaos', 'Divine & Dark', 'Mythic', 1.20, 'InfernoBlaze' },
    { 'RavenCards', 'Raven Cards', 'POF:RE AURA CORVUS', 'POF:RE AURA: Daemon of Cards', 'Divine & Dark', 'Legendary', 1.15, 'CardBarrage' },
    { 'OmegaAvatar', 'Omega Avatar', 'Omega', 'Avatar', 'Divine & Dark', 'Mythic', 1.20, 'RailgunSurge' },
    { 'InsaneNova', 'Insane Nova', 'POF:RE AURA  INSANITY', 'Pack5', 'Elemental', 'Legendary', 1.17, 'ChaosPulse' },
    { 'WispHalo', 'Wisp Halo', 'POF:RE AURA  WISP', 'Pack8', 'Divine & Dark', 'Epic', 1.14, 'AngelAscend' },
    { 'FrostPrism', 'Frost Prism', 'POF:RE AURA NORTH STAR', 'Pack1', 'Elemental', 'Legendary', 1.15, 'FrostBite' },
    { 'CyberNebula', 'Cyber Nebula', 'Omega', 'Pack6', 'Cosmic', 'Legendary', 1.16, 'QuantumWarp' },
    { 'ShadowTitan', 'Shadow Titan', 'Model', 'Pack3', 'Divine & Dark', 'Epic', 1.13, 'AbyssalGrasp' },
    { 'BlazeDeck', 'Blaze Deck', 'Pack5', 'POF:RE AURA: Daemon of Cards', 'Elemental', 'Legendary', 1.15, 'InfernoBlaze' },
    { 'AuroraGale', 'Aurora Gale', 'Pack4', 'Pack7', 'Elemental', 'Epic', 1.13, 'WindSlash' },
    { 'CelestialWing', 'Celestial Wing', 'one winged angel', 'Avatar', 'Divine & Dark', 'Mythic', 1.21, 'AngelAscend' },
    { 'ChaosWisp', 'Chaos Wisp', 'Manifestation of Chaos', 'POF:RE AURA  WISP', 'Cosmic', 'Mythic', 1.18, 'CosmicSingularity' },
    { 'CorvusStorm', 'Corvus Storm', 'POF:RE AURA CORVUS', 'Pack2', 'Elemental', 'Legendary', 1.15, 'ThunderStrike' },
    { 'EgoHalo', 'Ego Halo', 'POF:RE AURA ULTRA EGO', 'Pack8', 'Divine & Dark', 'Mythic', 1.19, 'SolarEclipse' },
    { 'StarNebula', 'Star Nebula', 'POF:RE AURA NORTH STAR', 'Pack6', 'Cosmic', 'Legendary', 1.16, 'MagnetPulse' },
    { 'InsaneVoid', 'Insane Void', 'POF:RE AURA  INSANITY', 'Model', 'Divine & Dark', 'Legendary', 1.17, 'VoidRift' },
    { 'PrismTitan', 'Prism Titan', 'Pack1', 'Pack3', 'Elemental', 'Rare', 1.11, 'Shield' },
    { 'StormMist', 'Storm Mist', 'Pack2', 'Pack4', 'Elemental', 'Epic', 1.13, 'ThunderStrike' },
    { 'NovaVerdant', 'Nova Verdant', 'Pack5', 'Pack7', 'Elemental', 'Epic', 1.14, 'MagmaWake' },
    { 'MistHalo', 'Mist Halo', 'Pack4', 'Pack8', 'Cosmic', 'Legendary', 1.15, 'MidasBurst' },
    { 'NebulaAvatar', 'Nebula Avatar', 'Pack6', 'Avatar', 'Cosmic', 'Mythic', 1.19, 'PhantomBlink' },
    { 'OneWingChaos', 'One-Wing Chaos', 'one winged angel', 'Manifestation of Chaos', 'Divine & Dark', 'Mythic', 1.22, 'ChaosPulse' },
    { 'OmegaNova', 'Omega Nova', 'Omega', 'Pack5', 'Cosmic', 'Legendary', 1.17, 'RailgunSurge' },
    { 'GaleDeck', 'Gale Deck', 'Pack7', 'POF:RE AURA: Daemon of Cards', 'Elemental', 'Epic', 1.14, 'CardBarrage' },
    { 'EgoAvatar', 'Ego Avatar', 'POF:RE AURA ULTRA EGO', 'Avatar', 'Divine & Dark', 'Mythic', 1.22, 'SolarEclipse' },
}

function M.Inject(Config)
    -- Merge ExtraAbilities
    for k, v in pairs(M.ExtraAbilities) do
        Config.Abilities[k] = v
    end

    -- Tag existing 12 Classic skins with Category, AuraSrc, Material
    local classicCats = {
        Cardboard = 'Classic', Bat = 'Classic', GoldenStud = 'Classic', Cartoon = 'Classic',
        Glitch = 'Cosmic', Galaxy = 'Cosmic', Mecha = 'Cosmic',
        Fairy = 'Elemental', Phoenix = 'Elemental', Lava = 'Elemental',
        Demon = 'Divine & Dark', OneWing = 'Divine & Dark',
    }
    for _, sk in ipairs(Config.SkinOrder) do
        local s = Config.Skins[sk]
        if s then
            s.Category = classicCats[sk] or 'Classic'
            s.Material = s.Material or 'Neon'
        end
    end
    if Config.Skins.OneWing then
        Config.Skins.OneWing.AuraSrc = { 'one winged angel' }
        Config.Skins.OneWing.SingleWing = true
        Config.Skins.OneWing.WingStyle = 'SingleWing'
        Config.Skins.OneWing.Color = Color3.fromRGB(28, 28, 36)
        Config.Skins.OneWing.Color2 = Color3.fromRGB(235, 240, 255)
        Config.Skins.OneWing.Material = 'SmoothPlastic'
    end

    local styleByAura = {
        ['one winged angel'] = 'SingleWing',
        ['Pack4'] = 'BlackholeHalo',
        ['Manifestation of Chaos'] = 'BlackholeHalo',
        ['Model'] = 'BlackholeHalo',
        ['POF:RE AURA  INSANITY'] = 'DemonHorns',
        ['POF:RE AURA CORVUS'] = 'DemonHorns',
        ['POF:RE AURA ULTRA EGO'] = 'DemonHorns',
        ['POF:RE AURA NORTH STAR'] = 'CelestialHalo',
        ['Pack8'] = 'CelestialHalo',
        ['Avatar'] = 'CelestialHalo',
        ['Omega'] = 'CyberCore',
        ['Pack3'] = 'CyberCore',
        ['Pack6'] = 'CyberCore',
        ['Pack5'] = 'FlameCrown',
        ['Pack2'] = 'FlameCrown',
    }

    -- Add 18 Pure MoreAuras wings
    for i, d in ipairs(PURE) do
        table.insert(Config.SkinOrder, d.id)
        Config.Skins[d.id] = {
            Name = d.name,
            Rarity = d.rar,
            Tier = 2 + (i % 3),
            SpeedMult = d.spd,
            Color = d.col,
            Color1 = d.col,
            Color2 = d.col:Lerp(Color3.new(1, 1, 1), 0.45),
            Material = d.mat,
            Category = d.cat,
            AuraSrc = { d.aura },
            AuraSrcRaw = d.aura,
            WingStyle = styleByAura[d.aura] or 'Default',
            Cost = 1500 + i * 250,
        }
        Config.WingAbilities[d.id] = d.ab
    end

    -- Add 37 Fusion wings -> Total 67 wings!
    local pureCol = {}
    for _, d in ipairs(PURE) do pureCol[d.aura] = d.col end
    pureCol['one winged angel'] = Color3.fromRGB(245, 245, 255)

    local fusionMats = { 'Neon', 'Glass', 'ForceField', 'Metal', 'Foil', 'Ice' }
    for i, f in ipairs(FUSIONS) do
        local id, name, a1, a2, cat, rar, spd, ab = f[1], f[2], f[3], f[4], f[5], f[6], f[7], f[8]
        local c1 = pureCol[a1] or Color3.fromRGB(180, 200, 255)
        local c2 = pureCol[a2] or Color3.fromRGB(255, 180, 220)
        local isSingle = (a1 == 'one winged angel' or a2 == 'one winged angel')
        table.insert(Config.SkinOrder, id)
        Config.Skins[id] = {
            Name = name,
            Rarity = rar,
            Tier = (rar == 'Mythic' and 5) or (rar == 'Legendary' and 4) or 3,
            SpeedMult = spd,
            Color = c1:Lerp(c2, 0.5),
            Color1 = c1,
            Color2 = c2,
            Material = fusionMats[((i - 1) % #fusionMats) + 1],
            Category = 'Fusion',
            SubCategory = cat,
            AuraSrc = { a1, a2 },
            SingleWing = isSingle,
            WingStyle = (isSingle and 'SingleWing') or styleByAura[a1] or styleByAura[a2] or 'Default',
            Cost = 3500 + i * 200,
        }
        Config.WingAbilities[id] = ab
    end

    -- 8 New 3D Stud Wings
    local NEW_3D_WINGS = {
        { id = 'PremiumStud',    name = 'Premium Stud',    cat = 'Divine & Dark', rar = 'Exclusive', spd = 1.18, ab = 'MidasBurst',        col = Color3.fromRGB(255, 200, 48),  col2 = Color3.fromRGB(255, 248, 185), mat = 'Neon',  cost = nil,  style = 'PremiumCrown' },
        { id = 'EclipseMonarch', name = 'Eclipse Monarch', cat = 'Divine & Dark', rar = 'Limited',   spd = 1.22, ab = 'SolarEclipse',      col = Color3.fromRGB(70, 160, 255),  col2 = Color3.fromRGB(20, 24, 48),    mat = 'Neon',  cost = nil,  style = 'EclipseCrescent' },
        { id = 'AetherSeraph',   name = 'Aether Seraph',   cat = 'Divine & Dark', rar = 'Limited',   spd = 1.23, ab = 'AngelAscend',       col = Color3.fromRGB(255, 175, 50),  col2 = Color3.fromRGB(255, 250, 215), mat = 'Neon',  cost = nil,  style = 'SeraphBlades' },
        { id = 'CyberPrism',     name = 'Cyber Prism',     cat = 'Cosmic',        rar = 'Limited',   spd = 1.24, ab = 'QuantumWarp',       col = Color3.fromRGB(200, 60, 255),  col2 = Color3.fromRGB(75, 245, 255),  mat = 'Glass', cost = nil,  style = 'PrismShards' },
        { id = 'SkyPhoenix',     name = 'Sky Phoenix',     cat = 'Elemental',     rar = 'Mythic',    spd = 1.20, ab = 'InfernoBlaze',      col = Color3.fromRGB(255, 105, 30),  col2 = Color3.fromRGB(255, 225, 80),  mat = 'Neon',  cost = 7500, style = 'PhoenixPlumes' },
        { id = 'ReactorX',       name = 'Reactor-X',       cat = 'Cosmic',        rar = 'Legendary', spd = 1.18, ab = 'RailgunSurge',      col = Color3.fromRGB(50, 220, 255),  col2 = Color3.fromRGB(40, 48, 68),    mat = 'Metal', cost = 5500, style = 'ReactorThrusters' },
        { id = 'HyperionCore',   name = 'Hyperion Core',   cat = 'Cosmic',        rar = 'Mythic',    spd = 1.21, ab = 'CosmicSingularity', col = Color3.fromRGB(150, 75, 255),  col2 = Color3.fromRGB(255, 110, 235), mat = 'Neon',  cost = 8500, style = 'HyperionRing' },
        { id = 'FrostSeraph',    name = 'Frost Seraph',    cat = 'Elemental',     rar = 'Legendary', spd = 1.17, ab = 'FrostBite',         col = Color3.fromRGB(130, 235, 255), col2 = Color3.fromRGB(235, 250, 255), mat = 'Glass', cost = 4800, style = 'FrostSpires' },
    }
    for _, nw in ipairs(NEW_3D_WINGS) do
        if not Config.Skins[nw.id] then
            table.insert(Config.SkinOrder, nw.id)
        end
        Config.Skins[nw.id] = {
            Name = nw.name,
            Rarity = nw.rar,
            Tier = (nw.rar == 'Limited' or nw.rar == 'Mythic') and 5 or 4,
            SpeedMult = nw.spd,
            Color = nw.col,
            Color1 = nw.col,
            Color2 = nw.col2,
            Material = nw.mat,
            Category = nw.cat,
            WingStyle = nw.style,
            Attach3D = nw.style,
            Cost = nw.cost,
        }
        Config.WingAbilities[nw.id] = nw.ab
    end

    -- 10 Special Prestige Wings
    local PRESTIGE_WINGS = {
        { rank = 1,  id = 'Prestige1',  name = 'Prestige I: Bronze Dawn',        col = Color3.fromRGB(205, 125, 55),  col2 = Color3.fromRGB(255, 215, 130), mat = 'Metal',        spd = 1.08, ab = 'InfernoBlaze',      style = 'FlameCrown',       rig = 'Angel' },
        { rank = 2,  id = 'Prestige2',  name = 'Prestige II: Emerald Gale',      col = Color3.fromRGB(65, 225, 135),  col2 = Color3.fromRGB(185, 255, 215), mat = 'Glass',        spd = 1.10, ab = 'NatureVortex',      style = 'FrostSpires',      rig = 'Moth' },
        { rank = 3,  id = 'Prestige3',  name = 'Prestige III: Cobalt Tempest',   col = Color3.fromRGB(45, 155, 255),  col2 = Color3.fromRGB(165, 235, 255), mat = 'Neon',         spd = 1.12, ab = 'ThunderStrike',     style = 'ReactorThrusters', rig = 'Crystal' },
        { rank = 4,  id = 'Prestige4',  name = 'Prestige IV: Crimson Valkyrie',  col = Color3.fromRGB(235, 45, 70),   col2 = Color3.fromRGB(255, 165, 120), mat = 'Neon',         spd = 1.14, ab = 'AbyssalGrasp',      style = 'SeraphBlades',     rig = 'Skeleton' },
        { rank = 5,  id = 'Prestige5',  name = 'Prestige V: Amethyst Void',      col = Color3.fromRGB(160, 65, 255),  col2 = Color3.fromRGB(245, 145, 255), mat = 'ForceField',   spd = 1.16, ab = 'VoidRift',          style = 'HyperionRing',     rig = 'Angel' },
        { rank = 6,  id = 'Prestige6',  name = 'Prestige VI: Solar Sovereign',   col = Color3.fromRGB(255, 185, 25),  col2 = Color3.fromRGB(255, 250, 175), mat = 'Neon',         spd = 1.18, ab = 'MidasBurst',        style = 'PhoenixPlumes',    rig = 'Crystal' },
        { rank = 7,  id = 'Prestige7',  name = 'Prestige VII: Obsidian Eclipse', col = Color3.fromRGB(24, 26, 44),    col2 = Color3.fromRGB(70, 230, 255),  mat = 'SmoothPlastic',spd = 1.20, ab = 'SolarEclipse',      style = 'EclipseCrescent',  rig = 'Skeleton' },
        { rank = 8,  id = 'Prestige8',  name = 'Prestige VIII: Prism Celestial', col = Color3.fromRGB(120, 245, 255), col2 = Color3.fromRGB(255, 175, 245), mat = 'Glass',        spd = 1.22, ab = 'CosmicSingularity', style = 'CelestialHalo',    rig = 'Moth' },
        { rank = 9,  id = 'Prestige9',  name = 'Prestige IX: Cyber Overlord',    col = Color3.fromRGB(255, 55, 145),  col2 = Color3.fromRGB(60, 255, 235),  mat = 'Neon',         spd = 1.24, ab = 'RailgunSurge',      style = 'CyberCore',        rig = 'Crystal' },
        { rank = 10, id = 'Prestige10', name = 'Prestige X: Transcendent Seraph',col = Color3.fromRGB(255, 245, 200), col2 = Color3.fromRGB(255, 200, 50),  mat = 'Neon',         spd = 1.26, ab = 'AngelAscend',       style = 'PremiumCrown',     rig = 'Angel' },
    }
    for _, pw in ipairs(PRESTIGE_WINGS) do
        if not Config.Skins[pw.id] then
            table.insert(Config.SkinOrder, pw.id)
        end
        Config.Skins[pw.id] = {
            Name = pw.name,
            Rarity = 'Prestige',
            Tier = 5,
            SpeedMult = pw.spd,
            Color = pw.col,
            Color1 = pw.col,
            Color2 = pw.col2,
            Material = pw.mat,
            Category = 'Prestige',
            WingStyle = pw.style,
            Attach3D = pw.style,
            BoneRig = pw.rig,
            RequiresPrestige = pw.rank,
            Cost = nil,
        }
        Config.WingAbilities[pw.id] = pw.ab
    end

    -- Blender Wings
    local BLENDER_WINGS = {
        { id = 'StylizedSeraph', name = 'Stylized White Wings', rar = 'Epic', cost = 1800, curr = 'Coins', col1 = Color3.fromRGB(245, 250, 255), col2 = Color3.fromRGB(190, 225, 255), mat = Enum.Material.Plastic, rig = 'StylizedSeraph', ab = { Name = 'Seraphic Lift', BoostMult = 1.25, Cooldown = 8, Duration = 3.2, Color = Color3.fromRGB(210, 235, 255), Desc = 'Clean stylized white wings imported from Blender with Studs finish' } },
        { id = 'GothicOrnate', name = 'Gothic Ornate Wings', rar = 'Mythic', cost = 120, curr = 'Gems', col1 = Color3.fromRGB(45, 35, 65), col2 = Color3.fromRGB(170, 95, 255), mat = Enum.Material.Plastic, rig = 'GothicOrnate', ab = { Name = 'Gothic Ascent', BoostMult = 1.38, Cooldown = 7.5, Duration = 3.5, Color = Color3.fromRGB(170, 95, 255), Desc = 'Ornate gothic wings imported from Blender with Studs finish' } },
        { id = 'ArchangelHigh', name = 'Archangel Swept Wings', rar = 'Legendary', cost = 4500, curr = 'Coins', col1 = Color3.fromRGB(255, 235, 145), col2 = Color3.fromRGB(255, 255, 240), mat = Enum.Material.Plastic, rig = 'ArchangelHigh', ab = { Name = 'Archangel Surge', BoostMult = 1.32, Cooldown = 8, Duration = 3.4, Color = Color3.fromRGB(255, 225, 120), Desc = 'High-swept archangel Blender wings' } },
        { id = 'ValkyrieSpread', name = 'Valkyrie Stud Wings', rar = 'Legendary', cost = 85, curr = 'Gems', col1 = Color3.fromRGB(115, 215, 255), col2 = Color3.fromRGB(240, 250, 255), mat = Enum.Material.Plastic, rig = 'ValkyrieSpread', ab = { Name = 'Valkyrie Dash', BoostMult = 1.34, Cooldown = 7.8, Duration = 3.4, Color = Color3.fromRGB(115, 215, 255), Desc = 'Wide-spread Valkyrie Blender wings' } },
        { id = 'RoyalFan', name = 'Royal Fan Wings', rar = 'Epic', cost = 2400, curr = 'Coins', col1 = Color3.fromRGB(255, 195, 65), col2 = Color3.fromRGB(255, 110, 45), mat = Enum.Material.Plastic, rig = 'RoyalFan', ab = { Name = 'Royal Glide', BoostMult = 1.26, Cooldown = 8.2, Duration = 3.2, Color = Color3.fromRGB(255, 185, 60), Desc = 'Royal fan-shaped Blender stud wings' } },
        { id = 'CelestialGlide', name = 'Celestial Glide Wings', rar = 'Epic', cost = 60, curr = 'Gems', col1 = Color3.fromRGB(150, 255, 220), col2 = Color3.fromRGB(80, 195, 255), mat = Enum.Material.Plastic, rig = 'CelestialGlide', ab = { Name = 'Celestial Breeze', BoostMult = 1.28, Cooldown = 8.0, Duration = 3.3, Color = Color3.fromRGB(130, 245, 220), Desc = 'Sleek glider Blender wings' } },
        { id = 'ObsidianValkyrie', name = 'Obsidian Ornate Wings', rar = 'Mythic', cost = 160, curr = 'Gems', col1 = Color3.fromRGB(28, 24, 38), col2 = Color3.fromRGB(255, 65, 95), mat = Enum.Material.Plastic, rig = 'ObsidianValkyrie', ab = { Name = 'Obsidian Rift', BoostMult = 1.42, Cooldown = 7.2, Duration = 3.6, Color = Color3.fromRGB(255, 65, 95), Desc = 'High-Swept Gothic Obsidian Blender wings' } },
    }
    for _, bw in ipairs(BLENDER_WINGS) do
        if not Config.Skins[bw.id] then
            table.insert(Config.SkinOrder, bw.id)
        end
        Config.Skins[bw.id] = {
            Name = bw.name,
            Rarity = bw.rar,
            Cost = bw.cost,
            Currency = bw.curr,
            Color = bw.col1,
            Color1 = bw.col1,
            Color2 = bw.col2,
            Material = bw.mat,
            Category = 'Standard',
            WingStyle = bw.rig,
            BoneRig = bw.rig,
        }
        Config.WingAbilities[bw.id] = bw.ab
    end

    -- Register 11 Creator Store Wings into Config
    for _, cw in ipairs(M.CreatorStoreWings) do
        if not Config.Skins[cw.Id] then
            table.insert(Config.SkinOrder, cw.Id)
        end
        Config.Skins[cw.Id] = {
            Name = cw.Name,
            Rarity = cw.Rarity,
            Tier = cw.Tier,
            SpeedMult = cw.SpeedMult,
            TurnMult = cw.TurnMult,
            LiftMult = cw.LiftMult,
            GlideRatio = cw.GlideRatio,
            Color = cw.Color,
            Color1 = cw.Color1,
            Color2 = cw.Color2,
            Material = cw.Material,
            Category = cw.Category,
            AuraSrc = { cw.AuraSrc },
            AuraSrcRaw = cw.AuraSrc,
            AssetId = cw.AssetId,
            WingStyle = cw.WingStyle,
            BoneRig = cw.BoneRig,
            Cost = cw.Cost,
            Desc = cw.Desc,
        }
        Config.WingAbilities[cw.Id] = cw.Ability
        M.Catalog[cw.Id] = Config.Skins[cw.Id]
    end
end

function M.GetWing(id)
    return M.Catalog[id]
end

function M.GetByCategory(cat)
    local list = {}
    for _, w in ipairs(M.CreatorStoreWings) do
        if cat == 'All' or w.Category == cat then
            table.insert(list, w)
        end
    end
    return list
end

return M
