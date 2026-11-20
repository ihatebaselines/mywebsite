local Config={}
Config.MaxFlyers=8
Config.MaxLevel=100
Config.MaxPrestige=10
Config.PrestigeXPBonus=0.10
Config.Intermission=30
Config.RoundTime=120
Config.Countdown=4
Config.ResultsTime=9
Config.FlightSpeed=34
Config.TrackOrigin=Vector3.new(0,300,0)
Config.TrackLength=4600
Config.Box={HalfWidth=56,MinY=6,MaxY=56,Front=-180,Back=180}
Config.TestModeHP = false -- Set false for balanced 2,000 HP gameplay!
Config.LiveMaxHP = 2000
Config.TestMaxHP = 100000
Config.MaxHP = Config.TestModeHP and Config.TestMaxHP or Config.LiveMaxHP
Config.ObstacleDamage = 180
Config.BumpDamage = 35
Config.CrashDamage = 175
Config.CrashSpeedThreshold = 58
Config.CrashStunTime = 1.6
Config.HealOrbAmount = 350
Config.Maps={
 {Id=1,Name='Sunny Studs',Difficulty='EASY',Sky=Color3.fromRGB(80,255,100),Spacing=95,Kinds={'pillar','float'}},
 {Id=2,Name='Gate Garden',Difficulty='MEDIUM',Sky=Color3.fromRGB(255,225,60),Spacing=75,Kinds={'pillar','float','gate'}},
 {Id=3,Name='Hammer Lava',Difficulty='HARD',Sky=Color3.fromRGB(255,80,70),Spacing=62,Kinds={'pillar','gate','hammer','lava'}},
}
Config.Skins={
 Cardboard={Name='Cardboard',Rarity='Common',Color=Color3.fromRGB(185,140,90),Material='Cardboard'},
 Bat={Name='Bat',Rarity='Uncommon',Color=Color3.fromRGB(45,40,60),Material='SmoothPlastic'},
 Fairy={Name='Fairy',Rarity='Rare',Color=Color3.fromRGB(120,255,160),Material='Glass'},
 GoldenStud={Name='Golden Stud',Rarity='Rare',Color=Color3.fromRGB(255,200,30),Material='Metal'},
 Demon={Name='Demon',Rarity='Epic',Color=Color3.fromRGB(180,30,40),Material='SmoothPlastic'},
 Mecha={Name='Mecha',Rarity='Epic',Color=Color3.fromRGB(80,180,255),Material='Metal'},
 Glitch={Name='Glitch',Rarity='Epic',Color=Color3.fromRGB(0,255,200),Material='Neon'},
 Galaxy={Name='Galaxy',Rarity='Legendary',Color=Color3.fromRGB(110,50,200),Material='Neon'},
 Phoenix={Name='Phoenix',Rarity='Legendary',Color=Color3.fromRGB(255,90,20),Material='Neon'},
 Cartoon={Name='Cartoon',Rarity='Rare',Color=Color3.fromRGB(255,235,90),Material='SmoothPlastic'},
 Lava={Name='Lava',Rarity='Epic',Color=Color3.fromRGB(255,70,10),Material='Neon'},
 OneWing={Name='One Wing Angel',Rarity='Legendary',Color=Color3.fromRGB(245,245,255),Material='Neon'},
}
Config.SkinOrder={'Cardboard','Cartoon','Bat','Fairy','GoldenStud','Demon','Lava','Mecha','Glitch','Galaxy','Phoenix','OneWing'}
-- Material tiers: a skin can be owned in a tier that recolours the wing and buffs its ability (server-applied).
-- DmgMult scales ability damage, CdMult scales cooldown (lower = faster), Coins = extra coins on ability use.
Config.Tiers={
 Normal={Name='Normal',Color=nil,Material=nil,DmgMult=1.0,CdMult=1.0,Coins=0},
 Bronze={Name='Bronze',Color=Color3.fromRGB(176,110,55),Material='Metal',DmgMult=1.1,CdMult=0.95,Coins=0},
 Silver={Name='Silver',Color=Color3.fromRGB(205,210,220),Material='Metal',DmgMult=1.2,CdMult=0.9,Coins=0},
 Golden={Name='Golden',Color=Color3.fromRGB(255,205,40),Material='Neon',DmgMult=1.35,CdMult=0.85,Coins=10},
 Galaxy={Name='Galaxy',Color=Color3.fromRGB(95,40,190),Material='Neon',DmgMult=1.5,CdMult=0.8,Coins=25},
}
Config.TierOrder={'Normal','Bronze','Silver','Golden','Galaxy'}
-- Odds of the tier a NEW wing skin is unlocked in. Duplicates upgrade the owned skin one tier instead.
Config.TierWeights={Normal=70,Bronze=18,Silver=8,Golden=3.5,Galaxy=0.5}
Config.RarityColor={Common=Color3.fromRGB(200,200,200),Uncommon=Color3.fromRGB(90,200,255),Rare=Color3.fromRGB(255,210,60),Epic=Color3.fromRGB(0,255,200),Legendary=Color3.fromRGB(190,100,255)}
Config.Crates={
 Cardboard={Cost=100,Weights={Cardboard=60,Bat=25,Fairy=10,GoldenStud=5}},
 Bat={Cost=250,Weights={Cardboard=30,Bat=35,Fairy=20,Demon=10,GoldenStud=5}},
 GoldenStud={Cost=600,Weights={Bat=25,Fairy=25,GoldenStud=30,Mecha=15,Glitch=5}},
 Glitch={Cost=1200,Weights={GoldenStud=25,Mecha=25,Glitch=22,FrostSeraph=14,ReactorX=10,Galaxy=4}},
 Galaxy={Cost=2500,Weights={Glitch=28,Galaxy=22,Phoenix=18,SkyPhoenix=14,HyperionCore=12,FrostSeraph=6}},
}
Config.CrateOrder={'Cardboard','Bat','GoldenStud','Glitch','Galaxy'}
Config.DupeRefund=0.4
Config.Abilities={
 WindSlash={Name='Getsuga Tensho',Currency='Coins',UnlockCost=450,MaxLevel=5,Cooldown=4.5,Damage=240,Range=68,Knock=65,Desc='Unleashes twin Valkyrie wind blades slashing all rivals in 68 studs.',Color=Color3.fromRGB(110,245,200),Icon='WS'},
 ThunderStrike={Name='Kirin Bolt',Currency='Coins',UnlockCost=750,MaxLevel=5,Cooldown=7.5,Damage=290,Range=95,Duration=2.0,Desc='Zeus chains 6700V lightning across up to 4 rivals ahead, stunning them.',Color=Color3.fromRGB(255,230,70),Icon='TB'},
 MagnetPulse={Name='Shinra Tensei',Currency='Coins',UnlockCost=600,MaxLevel=5,Cooldown=8,Duration=5.0,Range=75,Desc='5s magnetic aura + 2.2s shield + forward dash +35 Bonus Coins!',Color=Color3.fromRGB(185,100,255),Icon='MG'},
 PhantomBlink={Name='Flying Raijin',Currency='Coins',UnlockCost=900,MaxLevel=5,Cooldown=6,Duration=1.8,Desc='Stealth ninja phase dash forward with 1.8s invulnerability.',Color=Color3.fromRGB(90,200,255),Icon='PB'},
 Slap={Name='Gear 5 Impact',Key='Q',Cooldown=3.5,Damage=math.floor(Config.ObstacleDamage*1.8),Knock=95,Range=22,Gems=0,Desc='Massive Sahur bat slam knocking nearby rivals sideways into hazards.',Color=Color3.fromRGB(255,170,40)},
 Divebomb={Name='Bajrang Crash',Currency='Gems',Key='E',Cooldown=5.5,Damage=math.floor(Config.ObstacleDamage*2.4),Knock=80,Range=48,Gems=50,Desc='Carpet-bomb dive slam blasting all rivals within 48 studs.',Color=Color3.fromRGB(255,80,80)},
 Shield={Name='Susanoo Armor',Currency='Gems',Key='F',Cooldown=9,Duration=3.2,Range=32,Knock=65,Gems=80,Desc='3.2s invincible Aegis dome that deflects hits & shoves attackers back.',Color=Color3.fromRGB(90,200,255)},
 Surge={Name='Ultra Instinct Surge',Currency='Gems',Key='R',Cooldown=7.5,Duration=2.8,Damage=math.floor(Config.ObstacleDamage*1.8),Knock=70,Range=48,Gems=120,Desc='2.8s invincible Mach 67 surge zapping rivals as you fly past.',Color=Color3.fromRGB(255,120,220)},
}
Config.AbilityOrder={'Slap','Divebomb','Shield','Surge','WindSlash','ThunderStrike','MagnetPulse','PhantomBlink','FrostBite','NatureVortex','MidasBurst','AbyssalGrasp','RailgunSurge','QuantumWarp','CosmicSingularity','InfernoBlaze','AcmeAnvil','MagmaWake','AngelAscend','CardBarrage','ChaosPulse','NorthStarBeam','SolarEclipse','VoidRift','AtomicNova','KuramaRoar','TimeFreeze','BinaryOverload','SaiyanOverdrive','CorvusSwarm'}

-- ===== Wing abilities (v2) =====
local OD = Config.ObstacleDamage
Config.Abilities.FrostBite = {Name='Ice Age Nova', Key='E', Cooldown=8, Damage=OD*2.4, Knock=60, Range=46, Duration=2.0, Gems=0, Desc='Boreas blizzard freezes every rival in 46 studs for 2.0s.', Color=Color3.fromRGB(130,225,255)}
Config.Abilities.NatureVortex = {Name='Senjutsu Bloom', Key='E', Cooldown=9, Damage=OD*2.3, Heal=120, Range=40, Knock=65, Duration=2.0, Gems=0, Desc='Heal +120 HP and unleash a tidal vortex knocking rivals away.', Color=Color3.fromRGB(120,255,140)}
Config.Abilities.MidasBurst = {Name='Gate of Babylon', Key='E', Cooldown=10, Damage=OD*1.6, Knock=85, Range=45, Coins=100, MaxCoinUses=4, Gems=0, Desc='Golden shockwave + 2.2s shield + rains +100 Bonus Coins!', Color=Color3.fromRGB(255,215,0)}
Config.Abilities.AbyssalGrasp = {Name='Black Vortex', Key='E', Cooldown=9, Damage=OD*2.4, Knock=75, Range=48, Gems=0, Desc='Underworld chains drag rivals down & steal +30 HP per hit.', Color=Color3.fromRGB(190,25,60)}
Config.Abilities.RailgunSurge = {Name='Kamehameha Rush', Key='E', Cooldown=9.5, Duration=2.5, Damage=OD*2.5, Knock=70, Range=75, Width=14, Gems=0, Desc='2.5s invincible spear rush piercing rivals in front.', Color=Color3.fromRGB(90,190,255)}
Config.Abilities.QuantumWarp = {Name='Kamui Warp', Key='E', Cooldown=6.5, Duration=1.4, Gems=0, Desc='Warp forward 90 studs with 1.4s phase invulnerability.', Color=Color3.fromRGB(0,255,200)}
Config.Abilities.CosmicSingularity = {Name='Hollow Purple', Key='E', Cooldown=11, Damage=OD*2.6, Knock=90, Range=55, Duration=1.2, Gems=0, Desc='Cosmic black hole drags rivals in 55 studs then blasts them.', Color=Color3.fromRGB(150,70,255)}
Config.Abilities.InfernoBlaze = {Name='Amaterasu Flame', Key='E', Cooldown=9, Damage=OD*2.5, Knock=70, Range=48, Gems=0, Desc='Solar firestorm scorches chasers in 48 studs + speed boost.', Color=Color3.fromRGB(255,110,30)}
Config.Abilities.AcmeAnvil = {Name='Tengai Shinsei', Key='E', Cooldown=7.5, Damage=OD*3.5, Knock=60, Range=65, Gems=0, Desc='Drops giant cursed anvils on up to 2 rivals ahead.', Color=Color3.fromRGB(255,235,90)}
Config.Abilities.MagmaWake = {Name='Magma Wake', Key='E', Cooldown=9, Damage=OD*1.4, Knock=45, Range=60, Duration=4.0, Ticks=5, Gems=0, Desc='4s molten lava wake burning & knocking rivals behind you.', Color=Color3.fromRGB(255,80,15)}
Config.Abilities.AngelAscend = {Name='Divine Departure', Key='E', Cooldown=10, Damage=OD*2.6, Knock=75, Range=45, Duration=1.6, Gems=0, Desc='Rise untouchable in chariot light, then smite rivals in 45 studs.', Color=Color3.fromRGB(235,240,255)}
Config.Abilities.ReflectShield = {Name='Reflect Shield', Key='E', Cooldown=14, Duration=3.0, Gems=0, Cost=1800, Desc='3s radiant barrier that reflects any rival attack back at them!', Color=Color3.fromRGB(110,245,255)}
Config.WingAbilities = {
 Cartoon='AcmeAnvil', Lava='MagmaWake', OneWing='AngelAscend',
 Cardboard='Slap', Bat='FrostBite', Fairy='NatureVortex', GoldenStud='MidasBurst', Demon='AbyssalGrasp',
 Mecha='RailgunSurge', Glitch='QuantumWarp', Galaxy='CosmicSingularity', Phoenix='InfernoBlaze',
}
Config.DashCooldown=1.5
Config.BrakeMax=1.4
Config.BrakeCooldown=3
Config.WheelCooldown=600
Config.WheelSlots={
 {Kind='Coins',Amount=100,Weight=30,Text='100 Coins'},
 {Kind='Gems',Amount=10,Weight=14,Text='10 Gems'},
 {Kind='Coins',Amount=250,Weight=14,Text='250 Coins'},
 {Kind='Gems',Amount=25,Weight=7,Text='25 Gems'},
 {Kind='Skin',Skin='Bat',Weight=5,Text='Bat Wings!'},
 {Kind='Coins',Amount=50,Weight=22,Text='50 Coins'},
 {Kind='Gems',Amount=5,Weight=7,Text='5 Gems'},
 {Kind='Skin',Skin='GoldenStud',Weight=1,Text='Golden Stud Wings!!'},
}
-- Flight v3 tuning (client feel). Everything here is safe to tweak.
Config.Flight={
 MoveSpeed = 68,        -- max strafe speed (studs/s)
 BoostMoveSpeed = 94,   -- strafe speed while boosting
 Accel = 11.5,             -- how fast velocity follows the stick
 CounterAccel = 18,     -- extra response when reversing direction (snappy dodges)
 Drag = 6.2,              -- how fast you glide to a stop
 EdgeSoft=6,          -- studs of soft wall before the lane edge
 EnergyMax=100,
 EnergyDrain=34,      -- per second while holding Boost (Shift / R2)
 EnergyRegen=8,
 EnergyRegenDelay=1.0,
 RingEnergy=16,
 NearMissEnergy=9,
 NearMissDist=7.6,
 BoostPickupTime=1.5, -- seconds of boost from a speed ring
 StaggerTime=0.5,     -- control loss after hitting an obstacle
 RingCoins=1,         -- coins per speed ring collected
}
function Config.XpNeeded(level) return 100+level*50 end
function Config.Slots(level) return 1+(level>=3 and 1 or 0)+(level>=6 and 1 or 0) end
local WingCatalog = require(game:GetService('ReplicatedStorage'):WaitForChild('Shared'):WaitForChild('WingCatalog'))
WingCatalog.Inject(Config)

Config.GameModes = {
    { Id = 'SkyRoyale',   Name = 'Sky Royale',   Desc = 'Survive the skies & knock rivals into hazards!' },
    { Id = 'RingRush',    Name = 'Ring Rush',    Desc = 'Speed Rings grant 2x Score & Coins!' },
    { Id = 'ChaosBounty', Name = 'Chaos Bounty', Desc = 'Eliminate the Golden Bounty for huge Coins!' },
}

Config.Mutators = {
    { Id = 'Standard',   Name = 'Clear Skies',  Desc = 'Classic flight physics & rewards.' },
    { Id = 'GoldenFever',Name = 'Golden Fever', Desc = '2x Coins from all rings & placements!' },
    { Id = 'TurboWind',  Name = 'Turbo Wind',   Desc = '+22% faster course speed & intense drafts!' },
    { Id = 'HeavyCrash', Name = 'Heavy Crash',  Desc = '+25% knockback & crash impacts!' },
}

Config.CaseTiers = {
    SkyCase = {
        Key = 'SkyCase',
        Name = 'Sky Case',
        Color = Color3.fromRGB(64, 196, 255),
        Currency = 'Coins',
        UnitCoinCost = 250,
        Desc = 'Starter & Rare Wings (Bat, Fairy, Cartoon, Golden Stud).',
        Weights = { Cardboard = 35, Bat = 28, Cartoon = 18, Fairy = 12, GoldenStud = 6, Mecha = 1 },
        Pity10 = 'GoldenStud',
        Icon = 'rbxassetid://109242429518850',
    },
    CyberCase = {
        Key = 'CyberCase',
        Name = 'Cyber Case',
        Color = Color3.fromRGB(165, 85, 255),
        Currency = 'Coins',
        UnitCoinCost = 900,
        Desc = 'Tech & Elemental Wings (Mecha, Glitch, Demon, Lava).',
        Weights = { Fairy = 18, GoldenStud = 22, Mecha = 20, Demon = 12, Glitch = 10, ReactorX = 10, FrostSeraph = 8 },
        Pity10 = 'Glitch',
        Icon = 'rbxassetid://85571982669133',
    },
    CelestialCase = {
        Key = 'CelestialCase',
        Name = 'Celestial Mythic Case',
        Color = Color3.fromRGB(255, 195, 45),
        Currency = 'Gems',
        UnitCoinCost = 150,
        Desc = 'High-odds Galaxy, Phoenix & One Wing Angel!',
        Weights = { Mecha = 16, Glitch = 18, FrostSeraph = 16, ReactorX = 14, Galaxy = 14, SkyPhoenix = 10, HyperionCore = 8, OneWing = 4 },
        Pity10 = 'Galaxy',
        Icon = 'rbxassetid://87983404238666',
    },
}
Config.CaseOrder = { 'SkyCase', 'CyberCase', 'CelestialCase' }

-- ===== WING RARITY STATS & SYNERGY PASSIVES (Wings are now real gear, not just cosmetics!) =====
Config.RarityStats = {
    Common    = { SpeedMult = 1.00, BonusHP = 0,   CdMult = 1.00, CoinMult = 1.00, XpMult = 1.00, Label = "Starter" },
    Uncommon  = { SpeedMult = 1.04, BonusHP = 40,  CdMult = 0.97, CoinMult = 1.05, XpMult = 1.05, Label = "+4% Spd · +40 HP · -3% CD" },
    Rare      = { SpeedMult = 1.07, BonusHP = 80,  CdMult = 0.94, CoinMult = 1.10, XpMult = 1.10, Label = "+7% Spd · +80 HP · -6% CD" },
    Epic      = { SpeedMult = 1.10, BonusHP = 140, CdMult = 0.90, CoinMult = 1.15, XpMult = 1.15, Label = "+10% Spd · +140 HP · -10% CD" },
    Legendary = { SpeedMult = 1.14, BonusHP = 220, CdMult = 0.85, CoinMult = 1.20, XpMult = 1.20, Label = "+14% Spd · +220 HP · -15% CD" },
    Mythic    = { SpeedMult = 1.18, BonusHP = 320, CdMult = 0.80, CoinMult = 1.30, XpMult = 1.30, Label = "+18% Spd · +320 HP · -20% CD" },
}
Config.SynergyDmgMult = 1.20
Config.SynergyCdMult = 0.85

function Config.GetWingBonus(skinName, activeAbility)
    local sk = Config.Skins and Config.Skins[skinName or "Cardboard"]
    local rarity = (sk and sk.Rarity) or "Common"
    local st = Config.RarityStats[rarity] or Config.RarityStats.Common
    local sig = Config.WingAbilities and Config.WingAbilities[skinName or "Cardboard"]
    local hasSynergy = (sig ~= nil and (activeAbility == nil or activeAbility == "" or activeAbility == sig))
    return {
        Rarity = rarity,
        SpeedMult = st.SpeedMult,
        BonusHP = st.BonusHP,
        CdMult = st.CdMult * (hasSynergy and Config.SynergyCdMult or 1.0),
        DmgMult = hasSynergy and Config.SynergyDmgMult or 1.0,
        CoinMult = st.CoinMult,
        XpMult = st.XpMult,
        Signature = sig,
        HasSynergy = hasSynergy,
        Label = st.Label,
    }
end

-- ===== REBALANCED EXISTING ABILITIES (No more 24-dmg weak abilities!) =====
local rebalances = {
    CardBarrage   = { Name = "Cleave & Dismantle", Desc = "Trickster cards strike up to 4 rivals & grant +25 Bonus Coins.", Damage = 280, Range = 75, Knock = 62, Cooldown = 7.0 },
    ChaosPulse    = { Name = "Conqueror's Haki", Desc = "Psychedelic shockwave scrambles & blasts all rivals in 65 studs.", Damage = 330, Range = 65, Knock = 78, Cooldown = 8.0 },
    NorthStarBeam = { Name = "Final Flash", Desc = "Freezing northern starlight beam piercing rivals in 80 studs.", Damage = 320, Range = 80, Duration = 2.0, Cooldown = 7.5 },
    SolarEclipse  = { Name = "Cruel Sun", Desc = "2.2s shield +80 HP heal & freezes all rivals in 70 studs.", Damage = 350, Range = 70, Duration = 2.0, Cooldown = 9.0 },
    VoidRift      = { Name = "Infinite Void", Desc = "Shadow rift drags nearby rivals backward & down into hazards.", Damage = 340, Range = 68, Knock = 72, Cooldown = 8.5 },
}
for k, patch in pairs(rebalances) do
    if Config.Abilities[k] then
        for pk, pv in pairs(patch) do
            Config.Abilities[k][pk] = pv
        end
    end
end

-- ===== 6 NEW PEAK ABILITIES (Powered by FXLibrary.MoreAuras / Auras + 3D VFX) =====
Config.Abilities.AtomicNova = {
    Name = "I Am Atomic",
    Desc = "Implodes rivals in 58 studs then detonates a massive 460-dmg nova!",
    Cooldown = 10, Damage = 460, Range = 58, Knock = 85,
    Color = Color3.fromRGB(95, 255, 175), Key = "E",
    Currency = "Gems", Gems = 140,
}
Config.Abilities.KuramaRoar = {
    Name = "Kurama Tailed Roar",
    Desc = "3-headed Cerberus roar blasting rivals in 65 studs!",
    Cooldown = 8.5, Damage = 400, Range = 65, Knock = 85,
    Color = Color3.fromRGB(255, 85, 45), Key = "E",
    Currency = "Gems", Gems = 110,
}
Config.Abilities.TimeFreeze = {
    Name = "Za Warudo",
    Desc = "Stops time for 2.6s in 62 studs + 1.8s shield + speed burst!",
    Cooldown = 11, Damage = 340, Range = 62, Duration = 2.6,
    Color = Color3.fromRGB(145, 220, 255), Key = "E",
    Currency = "Gems", Gems = 130,
}
Config.Abilities.BinaryOverload = {
    Name = "Bankai Overload",
    Desc = "Glitch-warps ahead with 1.6s shield & fries rivals in 50 studs!",
    Cooldown = 7.5, Damage = 320, Range = 50, Duration = 1.6, Knock = 65,
    Color = Color3.fromRGB(0, 255, 210), Key = "E",
    Currency = "Coins", UnlockCost = 1400, MaxLevel = 5,
}
Config.Abilities.SaiyanOverdrive = {
    Name = "Saiyan Overdrive",
    Desc = "3.2s invincible godmode rush + massive 52-stud shockwave!",
    Cooldown = 9.5, Damage = 380, Range = 52, Duration = 3.2, Knock = 80,
    Color = Color3.fromRGB(255, 225, 55), Key = "E",
    Currency = "Gems", Gems = 150,
}
Config.Abilities.CorvusSwarm = {
    Name = "Itachi Crow Swarm",
    Desc = "Shadow raven swarm seeks & shreds up to 4 rivals ahead!",
    Cooldown = 7.5, Damage = 350, Range = 90, Knock = 68,
    Color = Color3.fromRGB(165, 95, 255), Key = "E",
    Currency = "Coins", UnlockCost = 1200, MaxLevel = 5,
}

-- Map thematic wings to the new Peak Abilities
if Config.WingAbilities then
    Config.WingAbilities.OmegaCore     = "AtomicNova"
    Config.WingAbilities.OmegaNova     = "AtomicNova"
    Config.WingAbilities.ChaosOmega    = "KuramaRoar"
    Config.WingAbilities.EgoChaos      = "KuramaRoar"
    Config.WingAbilities.EgoHalo       = "TimeFreeze"
    Config.WingAbilities.SolarStorm    = "TimeFreeze"
    Config.WingAbilities.CyberNebula   = "BinaryOverload"
    Config.WingAbilities.UltraEgo      = "SaiyanOverdrive"
    Config.WingAbilities.EgoAvatar     = "SaiyanOverdrive"
    Config.WingAbilities.Corvus        = "CorvusSwarm"
    Config.WingAbilities.CorvusStorm   = "CorvusSwarm"
end


-- ===== ALL 27 AURAS FROM ReplicatedStorage.FXLibrary.LuismakakoAuras (R4) =====
Config.Auras = {
    ["Aura_SnowFlakes"]       = { Id = "Aura_SnowFlakes",       Name = "Frost Snowflakes",     Rarity = "Common",    Price = 150,  Currency = "Coins", Color = Color3.fromRGB(150, 230, 255) },
    ["safe aura"]             = { Id = "safe aura",             Name = "Sanctuary Halo",       Rarity = "Common",    Price = 180,  Currency = "Coins", Color = Color3.fromRGB(120, 255, 165) },
    ["Aura_WaterBubbleTrio"]  = { Id = "Aura_WaterBubbleTrio",  Name = "Tidal Bubble Trio",    Rarity = "Common",    Price = 200,  Currency = "Coins", Color = Color3.fromRGB(75, 195, 255) },
    ["Aura_pumpk"]            = { Id = "Aura_pumpk",            Name = "Haunted Pumpkin",      Rarity = "Common",    Price = 220,  Currency = "Coins", Color = Color3.fromRGB(255, 145, 35) },
    ["power drop aura"]       = { Id = "power drop aura",       Name = "Power Surge Drop",     Rarity = "Uncommon",  Price = 300,  Currency = "Coins", Color = Color3.fromRGB(255, 215, 65) },
    ["toxic aura"]            = { Id = "toxic aura",            Name = "Venomous Miasma",      Rarity = "Uncommon",  Price = 350,  Currency = "Coins", Color = Color3.fromRGB(95, 255, 85) },
    ["Aura_RomanticBloom"]    = { Id = "Aura_RomanticBloom",    Name = "Sakura Petal Bloom",   Rarity = "Uncommon",  Price = 400,  Currency = "Coins", Color = Color3.fromRGB(255, 150, 205) },
    ["Aura_FrozenBloom"]      = { Id = "Aura_FrozenBloom",      Name = "Glacial Lotus Bloom",  Rarity = "Uncommon",  Price = 450,  Currency = "Coins", Color = Color3.fromRGB(120, 220, 255) },
    ["Aura_Purp"]             = { Id = "Aura_Purp",             Name = "Phantom Raven Plume",  Rarity = "Rare",      Price = 600,  Currency = "Coins", Color = Color3.fromRGB(175, 95, 255) },
    ["Aura_Thund"]            = { Id = "Aura_Thund",            Name = "Raijin Thunder Spark", Rarity = "Rare",      Price = 680,  Currency = "Coins", Color = Color3.fromRGB(255, 235, 70) },
    ["Aura_RedHeartFire"]     = { Id = "Aura_RedHeartFire",     Name = "Crimson Heart Blaze",  Rarity = "Rare",      Price = 750,  Currency = "Coins", Color = Color3.fromRGB(255, 70, 95) },
    ["Aura_BlazingPinkHeart"] = { Id = "Aura_BlazingPinkHeart", Name = "Blazing Neon Heart",   Rarity = "Rare",      Price = 820,  Currency = "Coins", Color = Color3.fromRGB(255, 95, 195) },
    ["Aura_FireFist"]         = { Id = "Aura_FireFist",         Name = "Ace Flame Fist",       Rarity = "Rare",      Price = 900,  Currency = "Coins", Color = Color3.fromRGB(255, 105, 30) },
    ["Aura_FlameCrown"]       = { Id = "Aura_FlameCrown",       Name = "Sovereign Flame Crown",Rarity = "Epic",      Price = 1150, Currency = "Coins", Color = Color3.fromRGB(255, 160, 40) },
    ["Aura_WhiteWings"]       = { Id = "Aura_WhiteWings",       Name = "Seraphic Feather Aura",Rarity = "Epic",      Price = 1300, Currency = "Coins", Color = Color3.fromRGB(240, 248, 255) },
    ["Aura_RedWings"]         = { Id = "Aura_RedWings",         Name = "Crimson Valkyrie Aura",Rarity = "Epic",      Price = 1450, Currency = "Coins", Color = Color3.fromRGB(235, 45, 60) },
    ["Aura_Anon"]             = { Id = "Aura_Anon",             Name = "Joker Trickster Cards",Rarity = "Epic",      Price = 1600, Currency = "Coins", Color = Color3.fromRGB(195, 120, 255) },
    ["Aura_Binary404"]        = { Id = "Aura_Binary404",        Name = "Binary 404 Glitch",    Rarity = "Epic",      Price = 1800, Currency = "Coins", Color = Color3.fromRGB(0, 255, 195) },
    ["Aura_RainbFlame"]       = { Id = "Aura_RainbFlame",       Name = "Prismatic Rainbow",    Rarity = "Epic",      Price = 2000, Currency = "Coins", Color = Color3.fromRGB(255, 125, 245) },
    ["Aura_BlindObsession"]   = { Id = "Aura_BlindObsession",   Name = "Abyssal Obsession",    Rarity = "Legendary", Price = 2400, Currency = "Coins", Color = Color3.fromRGB(140, 50, 235) },
    ["Aura_Aether"]           = { Id = "Aura_Aether",           Name = "Celestial Aether",     Rarity = "Legendary", Price = 2800, Currency = "Coins", Color = Color3.fromRGB(115, 225, 255) },
    ["Aura_TimeKillingA"]     = { Id = "Aura_TimeKillingA",     Name = "Chronos Time Reaper",  Rarity = "Legendary", Price = 3200, Currency = "Coins", Color = Color3.fromRGB(145, 210, 255) },
    ["Aura_Saiyan"]           = { Id = "Aura_Saiyan",           Name = "Super Saiyan Ki",      Rarity = "Legendary", Price = 3600, Currency = "Coins", Color = Color3.fromRGB(255, 225, 55) },
    ["Aura Kurama"]           = { Id = "Aura Kurama",           Name = "Nine-Tails Chakra",    Rarity = "Mythic",    Price = 4200, Currency = "Coins", Color = Color3.fromRGB(255, 90, 35) },
    ["Aura_SusanooArms"]      = { Id = "Aura_SusanooArms",      Name = "Susanoo Spectral Arms",Rarity = "Mythic",    Price = 4800, Currency = "Coins", Color = Color3.fromRGB(135, 75, 255) },
    ["Aura_DarkRoger"]        = { Id = "Aura_DarkRoger",        Name = "Conqueror Haki Roger", Rarity = "Mythic",    Price = 5400, Currency = "Coins", Color = Color3.fromRGB(220, 25, 45) },
    ["Aura_Atomic"]           = { Id = "Aura_Atomic",           Name = "Atomic Overdrive",     Rarity = "Mythic",    Price = 6000, Currency = "Coins", Color = Color3.fromRGB(110, 255, 185) },
}

Config.AuraOrder = {
    "Aura_SnowFlakes", "safe aura", "Aura_WaterBubbleTrio", "Aura_pumpk",
    "power drop aura", "toxic aura", "Aura_RomanticBloom", "Aura_FrozenBloom",
    "Aura_Purp", "Aura_Thund", "Aura_RedHeartFire", "Aura_BlazingPinkHeart", "Aura_FireFist",
    "Aura_FlameCrown", "Aura_WhiteWings", "Aura_RedWings", "Aura_Anon", "Aura_Binary404", "Aura_RainbFlame",
    "Aura_BlindObsession", "Aura_Aether", "Aura_TimeKillingA", "Aura_Saiyan",
    "Aura Kurama", "Aura_SusanooArms", "Aura_DarkRoger", "Aura_Atomic",
}

-- ===== EMOTES TABLE IN CONFIG (Synced with EmoteCatalog + Dance1..Dance8 aliases) =====
local EmoteCatalog = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("EmoteCatalog"))
local emoteMap = {}
Config.EmoteOrder = {}
for idx, em in ipairs(EmoteCatalog.List) do
    emoteMap[em.Id] = em
    table.insert(Config.EmoteOrder, em.Id)
end
Config.Emotes = setmetatable(emoteMap, {
    __index = function(tbl, key)
        if type(key) == "string" and string.sub(key, 1, 5) == "Dance" then
            local num = tonumber(string.sub(key, 6))
            if num and num >= 1 and num <= 8 and EmoteCatalog.List[num] then
                return EmoteCatalog.List[num]
            end
        end
        return rawget(tbl, key)
    end
})
Config.HubDanceEmotes = {
    { StandId = "Dance1", EmoteId = "HighWave",    Name = "High Wave",      Clip = "HighWave",    Price = 0,  Currency = "Free" },
    { StandId = "Dance2", EmoteId = "Hello",       Name = "Friendly Hello", Clip = "Hello",       Price = 0,  Currency = "Free" },
    { StandId = "Dance3", EmoteId = "Applaud",     Name = "Victory Clap",   Clip = "Applaud",     Price = 0,  Currency = "Free" },
    { StandId = "Dance4", EmoteId = "Celebrate",   Name = "Celebrate!",     Clip = "Celebrate",   Price = 50, Currency = "Coins" },
    { StandId = "Dance5", EmoteId = "Happy",       Name = "Happy Dance",    Clip = "Happy",       Price = 50, Currency = "Coins" },
    { StandId = "Dance6", EmoteId = "Sturdy",      Name = "Get Sturdy",     Clip = "Sturdy",      Price = 50, Currency = "Coins" },
    { StandId = "Dance7", EmoteId = "Floss Dance", Name = "Sky Floss",      Clip = "Floss Dance", Price = 50, Currency = "Coins" },
    { StandId = "Dance8", EmoteId = "Robot",       Name = "Cyber Robot",    Clip = "Robot",       Price = 50, Currency = "Coins" },
}

-- ===== DIFFERENTIATED CRATES & CASES (R1, R2, R4) =====
local differentiatedCases = {
    WingCase1 = {
        Key = "WingCase1",
        Name = "Starter Wing Crate",
        RewardType = "Wings",
        Currency = "Coins",
        Cost = 250,
        UnitCoinCost = 250,
        Desc = "Starter Wing Crate with balanced 5-tier drop rates.",
        Weights = {
            Cardboard = 50, Bat = 28, Cartoon = 3.5, GoldenStud = 3.5,
            FairyPetal = 3.5, DragonflyAero = 3.5, MonarchButterfly = 1, LunarMoth = 1,
            VenomMoth = 1, BeeSwarm = 1, BeeSwarmWing = 1, EmeraldMantis = 1,
            CrystalButterfly = 0.5, SakuraSpirit = 0.5, ForestDryad = 0.5, GriffinRoyal = 0.5,
        },
    },
    WingCase2 = {
        Key = "WingCase2",
        Name = "Elemental Wing Crate",
        RewardType = "Wings",
        Currency = "Coins",
        Cost = 900,
        UnitCoinCost = 900,
        Desc = "Elemental Wing Crate with balanced 5-tier drop rates.",
        Weights = {
            Fairy = 9, SpiritWisp = 9, AeroPrism = 9, IronTitan = 9,
            VerdantGale = 9, Lava = 5, AzureStorm = 5, SteampunkClockwork = 5,
            RavenFeather = 5, OwlSilent = 5, OwlFeather = 5, Phoenix = 2.5,
            CrimsonNova = 2.5, FrostSeraph = 2.5, EmeraldDragon = 2.5, ThunderRaijin = 2.5,
            FrostWyrm = 2.5, SkyPhoenix = 1.6, PhoenixFlame = 1.6, ObsidianDragon = 1.6,
            GriffinWing = 1.6, ThunderbirdStorm = 1.6, HyperionCore = 1, ChaosManifest = 1,
        },
    },
    WingCase3 = {
        Key = "WingCase3",
        Name = "Celestial Wing Crate",
        RewardType = "Wings",
        Currency = "Gems",
        Cost = 150,
        UnitCoinCost = 150,
        Desc = "Celestial Wing Crate with balanced 5-tier drop rates.",
        Weights = {
            Mecha = 8, Glitch = 8, CelestialMist = 8, NebulaDrift = 8,
            StylizedSeraph = 8, Galaxy = 5, NorthStar = 5, OmegaCore = 5,
            ReactorX = 5, CyberHoloWing = 5, MechaJetBooster = 5, ArchangelHigh = 3,
            ValkyrieSpread = 3, ArchangelValkyrie = 3, CelestialDove = 3, LunarAstral = 3,
            HeavenlyPegasus = 3, SeraphimSixWing = 2, SolarisAureole = 2, JudgmentBladeWing = 2,
            VoidSeraph = 2, GothicOrnate = 2, OneWing = 1, GundamZeroWing = 0.5,
            StarlightKitsune = 0.5,
        },
    },
    AetherCrate = {
        Key = "AetherCrate",
        Name = "Aether Wing Crate",
        RewardType = "Wings",
        Currency = "Coins",
        Cost = 1400,
        UnitCoinCost = 1400,
        RequiresSkillUnlock = true,
        Desc = "Aether Wing Crate with balanced 5-tier drop rates.",
        Weights = {
            StylizedSeraph = 11.25, RoyalFan = 11.25, CelestialGlide = 11.25, SacredCherub = 11.25,
            ArchangelHigh = 7.5, ValkyrieSpread = 7.5, CelestialDove = 7.5, LunarAstral = 7.5,
            ArchangelValkyrie = 5, HeavenlyPegasus = 5, RadiantHalo = 5, SeraphimSixWing = 2,
            SolarisAureole = 2, JudgmentBladeWing = 2, ObsidianValkyrie = 2, SeraphimAngel = 1,
            OneWing = 1,
        },
    },
    DemonCrate = {
        Key = "DemonCrate",
        Name = "Abyssal Demon Crate",
        RewardType = "Wings",
        Currency = "Coins",
        Cost = 2200,
        UnitCoinCost = 2200,
        RequiresSkillUnlock = true,
        Desc = "Abyssal Demon Crate with balanced 5-tier drop rates.",
        Weights = {
            Demon = 11.25, AbyssalDemon = 11.25, BoneNecro = 11.25, CrimsonVampire = 11.25,
            Corvus = 7.5, DaemonCards = 7.5, VoidPhantom = 7.5, ShadowReaper = 7.5,
            HellfireDemon = 5, HellfireBalrog = 5, CrimsonKagune = 5, ObsidianDragon = 2.66,
            Insanity = 2.67, UltraEgo = 2.67, AvatarAscended = 1, FallenSeraph = 1,
        },
    },
    MechaCrate = {
        Key = "MechaCrate",
        Name = "Quantum Fusion Crate",
        RewardType = "Wings",
        Currency = "Coins",
        Cost = 3800,
        UnitCoinCost = 3800,
        RequiresSkillUnlock = true,
        Desc = "Quantum Fusion Crate with balanced 5-tier drop rates.",
        Weights = {
            PrismTitan = 10, EmeraldWisp = 10, AetherPrism = 10, TitaniumVolt = 10,
            WispHalo = 5, ShadowTitan = 5, AuroraGale = 5, StormMist = 5,
            NovaVerdant = 5, GaleDeck = 5, PhantomDeck = 1.3, SolarStorm = 1.3,
            StarlightHalo = 1.3, VoidNebula = 1.3, RavenCards = 1.3, InsaneNova = 1.3,
            FrostPrism = 1.3, CyberNebula = 1.3, BlazeDeck = 1.3, CorvusStorm = 1.3,
            StarNebula = 1.3, InsaneVoid = 1.3, MistHalo = 1.3, OmegaNova = 1.1,
            FallenSeraph = 0.83, FrostEgo = 0.83, ChaosOmega = 0.83, AstralSeraph = 0.83,
            MadnessAvatar = 0.83, EgoChaos = 0.83, OmegaAvatar = 0.83, CelestialWing = 0.83,
            ChaosWisp = 0.83, EgoHalo = 0.83, NebulaAvatar = 0.83, OneWingChaos = 0.87,
            EgoAvatar = 2,
        },
    },
    PrestigeCrate = {
        Key = "PrestigeCrate",
        Name = "Ascension Collector Crate",
        RewardType = "Wings",
        Currency = "Gems",
        Cost = 250,
        UnitCoinCost = 250,
        RequiresSkillUnlock = true,
        Desc = "Ascension Collector Crate with balanced 5-tier drop rates.",
        Weights = {
            Prestige1 = 22.5, Prestige2 = 22.5, Prestige3 = 15, Prestige4 = 15,
            Prestige5 = 5, Prestige6 = 5, Prestige7 = 5, Prestige8 = 2.66,
            Prestige9 = 2.67, Prestige10 = 2.67, EclipseMonarch = 0.5, AetherSeraph = 0.5,
            CyberPrism = 0.5, PremiumStud = 0.5,
        },
    },
    CombatAbilityCrate = {
        Key = "CombatAbilityCrate",
        Name = "Combat Ability Crate",
        RewardType = "Abilities",
        Currency = "Coins",
        Cost = 350,
        UnitCoinCost = 350,
        RequiresSkillUnlock = true,
        Desc = "Combat Ability Crate with balanced 5-tier drop rates.",
        Weights = {
            Slap = 25, WindSlash = 25, Divebomb = 14, Shield = 14,
            MagnetPulse = 7, PhantomBlink = 7, ThunderStrike = 3, ReflectShield = 3,
            Surge = 2,
        },
    },
    ElementalAbilityCrate = {
        Key = "ElementalAbilityCrate",
        Name = "Elemental Ability Crate",
        RewardType = "Abilities",
        Currency = "Coins",
        Cost = 1100,
        UnitCoinCost = 1100,
        RequiresSkillUnlock = true,
        Desc = "Elemental Ability Crate with balanced 5-tier drop rates.",
        Weights = {
            FrostBite = 22.5, NatureVortex = 22.5, MidasBurst = 10, AcmeAnvil = 10,
            MagmaWake = 10, AbyssalGrasp = 5, RailgunSurge = 5, CardBarrage = 5,
            QuantumWarp = 2.66, NorthStarBeam = 2.67, ChaosPulse = 2.67, SolarEclipse = 1,
            VoidRift = 1,
        },
    },
    PeakAbilityCrate = {
        Key = "PeakAbilityCrate",
        Name = "Peak Godly Ability Crate",
        RewardType = "Abilities",
        Currency = "Gems",
        Cost = 100,
        UnitCoinCost = 100,
        RequiresSkillUnlock = true,
        Desc = "Peak Godly Ability Crate with balanced 5-tier drop rates.",
        Weights = {
            CosmicSingularity = 20, InfernoBlaze = 20, AngelAscend = 15, QuantumWarp = 15,
            CorvusSwarm = 9, BinaryOverload = 9, KuramaRoar = 5, TimeFreeze = 5,
            AtomicNova = 1, SaiyanOverdrive = 1,
        },
    },
    DanceCrate = {
        Key = "DanceCrate",
        Name = "Street Dance Crate",
        RewardType = "Emotes",
        Currency = "Coins",
        Cost = 300,
        UnitCoinCost = 300,
        RequiresSkillUnlock = true,
        Desc = "Street Dance Crate with balanced 5-tier drop rates.",
        Weights = {
            HighWave = 16.66, Hello = 16.67, Applaud = 16.67, Celebrate = 14,
            Happy = 14, Sturdy = 7, ["Floss Dance"] = 7, Robot = 3,
            Shuffle = 3, ["Hero Landing"] = 2,
        },
    },
    FestivalEmoteCrate = {
        Key = "FestivalEmoteCrate",
        Name = "Festival & Stunt Crate",
        RewardType = "Emotes",
        Currency = "Coins",
        Cost = 850,
        UnitCoinCost = 850,
        RequiresSkillUnlock = true,
        Desc = "Festival & Stunt Crate with balanced 5-tier drop rates.",
        Weights = {
            Shuffle = 22.5, Samba = 22.5, ["Rock Out"] = 15, ["Victory Dance"] = 15,
            ["Line Dance"] = 7.5, ["Hero Landing"] = 7.5, ["Dramatic Bow"] = 4, Levitate = 4,
            ["Swan Dance"] = 1, Cartwheel = 1,
        },
    },
    EmoteAuraCrate = {
        Key = "EmoteAuraCrate",
        Name = "Celestial Aura & Groove Crate",
        RewardType = "EmotesAndAuras",
        Currency = "Gems",
        Cost = 75,
        UnitCoinCost = 75,
        RequiresSkillUnlock = true,
        Desc = "Celestial Aura & Groove Crate with balanced 5-tier drop rates.",
        Weights = {
            ["Dolphin Dance"] = 20, Aura_SnowFlakes = 10, ["safe aura"] = 10, ["Power Blast | Kamehameha"] = 15,
            Aura_FlameCrown = 15, ["Super Charge | Super Saiyan"] = 10, Aura_Saiyan = 8, ["Aura Kurama"] = 5,
            Aura_SusanooArms = 5, Godlike = 1, Aura_Atomic = 1,
        },
    },
    PrismaticAuraCrate = {
        Key = "PrismaticAuraCrate",
        Name = "Prismatic Aura Crate",
        RewardType = "Auras",
        Currency = "Coins",
        Cost = 1200,
        UnitCoinCost = 1200,
        RequiresSkillUnlock = true,
        Desc = "Prismatic Aura Crate with balanced 5-tier drop rates.",
        Weights = {
            Aura_SnowFlakes = 11.25, ["safe aura"] = 11.25, Aura_WaterBubbleTrio = 11.25, Aura_pumpk = 11.25,
            ["power drop aura"] = 7.5, ["toxic aura"] = 7.5, Aura_RomanticBloom = 7.5, Aura_FrozenBloom = 7.5,
            Aura_Purp = 3, Aura_Thund = 3, Aura_RedHeartFire = 3, Aura_BlazingPinkHeart = 3,
            Aura_FireFist = 3, Aura_FlameCrown = 4, Aura_WhiteWings = 4, Aura_RedWings = 2,
        },
    },
    MythicAuraCrate = {
        Key = "MythicAuraCrate",
        Name = "Mythic Chakra Crate",
        RewardType = "Auras",
        Currency = "Coins",
        Cost = 3000,
        UnitCoinCost = 3000,
        RequiresSkillUnlock = true,
        Desc = "Mythic Chakra Crate with balanced 5-tier drop rates.",
        Weights = {
            Aura_Anon = 13.33, Aura_Binary404 = 13.33, Aura_RainbFlame = 13.34, Aura_BlindObsession = 7.5,
            Aura_Aether = 7.5, Aura_TimeKillingA = 7.5, Aura_Saiyan = 7.5, ["Aura Kurama"] = 6,
            Aura_SusanooArms = 6, Aura_DarkRoger = 7, Aura_Atomic = 11,
        },
    },
}

Config.Cases = Config.Cases or {}
for k, v in pairs(Config.CaseTiers) do
    v.RewardType = v.RewardType or "Wings"
    Config.Cases[k] = v
end
for k, v in pairs(differentiatedCases) do
    Config.CaseTiers[k] = v
    Config.Cases[k] = v
    Config.Crates[k] = {
        Name = v.Name,
        Cost = v.Cost,
        Currency = v.Currency,
        RewardType = v.RewardType,
        Weights = v.Weights,
        RequiresSkillUnlock = v.RequiresSkillUnlock,
    }
end

-- Aliases for cross-compatibility
Config.CaseTiers.SkyCase = Config.CaseTiers.WingCase1
Config.Cases.SkyCase = Config.Cases.WingCase1
Config.Crates.SkyCase = Config.Crates.WingCase1
Config.CaseTiers.CyberCase = Config.CaseTiers.WingCase2
Config.Cases.CyberCase = Config.Cases.WingCase2
Config.Crates.CyberCase = Config.Crates.WingCase2
Config.CaseTiers.CelestialCase = Config.CaseTiers.WingCase3
Config.Cases.CelestialCase = Config.Cases.WingCase3
Config.Crates.CelestialCase = Config.Crates.WingCase3
Config.CaseTiers.StarterAbilityCrate = Config.CaseTiers.CombatAbilityCrate
Config.Cases.StarterAbilityCrate = Config.Cases.CombatAbilityCrate
Config.Crates.StarterAbilityCrate = Config.Crates.CombatAbilityCrate
Config.CaseTiers.MysticAbilityCrate = Config.CaseTiers.ElementalAbilityCrate
Config.Cases.MysticAbilityCrate = Config.Cases.ElementalAbilityCrate
Config.Crates.MysticAbilityCrate = Config.Crates.ElementalAbilityCrate
Config.CaseTiers.CosmicAbilityCrate = Config.CaseTiers.PeakAbilityCrate
Config.Cases.CosmicAbilityCrate = Config.Cases.PeakAbilityCrate
Config.Crates.CosmicAbilityCrate = Config.Crates.PeakAbilityCrate
Config.CaseTiers.PlazaEmoteCrate = Config.CaseTiers.DanceCrate
Config.Cases.PlazaEmoteCrate = Config.Cases.DanceCrate
Config.Crates.PlazaEmoteCrate = Config.Crates.DanceCrate
Config.CaseTiers.FusionCrate = Config.CaseTiers.MechaCrate
Config.Cases.FusionCrate = Config.Cases.MechaCrate
Config.Crates.FusionCrate = Config.Crates.MechaCrate

Config.CaseOrder = {
    "WingCase1", "WingCase2", "WingCase3", "AetherCrate", "DemonCrate", "MechaCrate", "PrestigeCrate",
    "CombatAbilityCrate", "ElementalAbilityCrate", "PeakAbilityCrate",
    "DanceCrate", "FestivalEmoteCrate", "EmoteAuraCrate", "PrismaticAuraCrate", "MythicAuraCrate",
}
Config.CrateOrder = Config.CaseOrder

return Config
