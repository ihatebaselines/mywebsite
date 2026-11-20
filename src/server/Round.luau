local Players=game:GetService('Players')
local RS=game:GetService('ReplicatedStorage')
local RunService=game:GetService('RunService')
local CS=game:GetService('CollectionService')
local Config=require(RS.Shared.Config)
local WeatherConfig=require(RS.Shared.WeatherConfig)
local AbilitySFX=require(RS.Shared:WaitForChild('AbilitySFX'))
local Remotes=RS.Remotes
local Data=require(script.Parent.Data)
local Wings=require(script.Parent.Wings)
local Avatars=require(script.Parent.Avatars)
local Obstacles=require(script.Parent.Obstacles)
local Decor=require(script.Parent.Decor)
local SplineUtils=require(RS.Shared.SplineUtils)
local Studifier=require(RS.Shared:WaitForChild('Studifier'))
local RagdollService=require(script.Parent:WaitForChild('RagdollService'))
local R={}
local readyPlayers={}

local O=Config.TrackOrigin
local HUB_SPAWN = CFrame.new(-798.255, 3.2, 105.645)
local phase='Intermission'
local flyers={}
local flyerOf={}
local bots={}
local votes={}
local passMarks={}
local movers={}
local orbs={}
local multiverseOrbs={}
local multiversePortalPos=nil
local multiverseActive=false
local multiverseChunkIdx=nil
local trackFolder=nil
local decorStreamer=nil -- Decor stream for the current track (nil between rounds)
local hazParams=OverlapParams.new()
hazParams.FilterType=Enum.RaycastFilterType.Include
local flightStart=0
local currentCourseCP=nil
local rng=Random.new()
local botFolder=Instance.new('Folder') botFolder.Name='Bots' botFolder.Parent=workspace

local function setPhase(p,dur)
 workspace:SetAttribute('PhaseEnds',dur and (workspace:GetServerTimeNow()+dur) or 0)
 workspace:SetAttribute('Phase',p)
 phase=p
end
local function now() return workspace:GetServerTimeNow() end

-- ===== votes =====
local function refreshVotes()
 local counts = {0, 0, 0}
 for _, m in pairs(votes) do
  if counts[m] then counts[m] += 1 end
 end
 local mapFolder = workspace:FindFirstChild('Map')
 for i = 1, 3 do
  local pad = mapFolder and mapFolder:FindFirstChild('Pad' .. i)
  local vg = pad and pad:FindFirstChild('VoteGui')
  if vg and vg:FindFirstChild('Votes') then
   vg.Votes.Text = counts[i] .. (counts[i] == 1 and ' vote' or ' votes')
  end
 end
 return counts
end
local function charOf(hit)
 local m=hit:FindFirstAncestorWhichIsA('Model')
 while m do
  if m:FindFirstChildOfClass('Humanoid') then return m end
  m=m:FindFirstAncestorWhichIsA('Model')
 end
 return nil
end
local function castVote(model,mapId)
 if phase~='Intermission' then return end
 local plr=Players:GetPlayerFromCharacter(model)
 local key=plr or (model:GetAttribute('BotId') and model)
 if not key then return end
 if votes[key]==mapId then return end
 votes[key]=mapId
 refreshVotes()
end

-- ===== overhead tag =====
local function attachTag(model)
 local head=model:FindFirstChild('Head') if not head then return end
 local old=head:FindFirstChild('OverheadTag') if old then old:Destroy() end
 local tpl=RS:WaitForChild('UI'):WaitForChild('OverheadTag')
 local t=tpl:Clone() t.Adornee=head t.Parent=head
 local isRealPlayer = Players:GetPlayerFromCharacter(model) ~= nil
 local root=t.Root
 if isRealPlayer then
  if root:FindFirstChild('PlayerName') then root.PlayerName.Visible = false end
  if root:FindFirstChild('Level') then root.Level.Visible = false end
  if root:FindFirstChild('Badge') then root.Badge.Visible = false end
 end
 root.PlayerName.Text=model.Name
 local function upd()
  if not root.Parent then return end -- stale connection from a previous (destroyed) tag
  local lvl=model:GetAttribute('Level') or 1
  root.Level.Text=tostring(lvl)
  local hp=model:GetAttribute('HP') or Config.MaxHP
  root.HPBack.HPFill.Size=UDim2.fromScale(math.clamp(hp/Config.MaxHP,0,1),1)
  local flying = model:GetAttribute('Flying')==true
  root.HPBack.Visible = flying
  if isRealPlayer then t.Enabled = flying end
 end
 for _,a in {'Level','HP','Flying'} do model:GetAttributeChangedSignal(a):Connect(upd) end
 upd()
end
R.AttachTag=attachTag

-- ===== bots =====
local WALK='rbxassetid://507777826'
local IDLE='rbxassetid://507766666'
local FALL='rbxassetid://507767968'
local function loadAnim(animator,id)
 local a=Instance.new('Animation') a.AnimationId=id
 return animator:LoadAnimation(a)
end
local function hubPoint(kind)
 local mapFolder = workspace:FindFirstChild('Map')
 if kind == 'pad' then
  local i = rng:NextInteger(1, 3)
  local pad = mapFolder and mapFolder:FindFirstChild('Pad' .. i)
  local pPos = (pad and pad:GetPivot().Position) or Vector3.new(-805, 3.2, -45)
  return pPos + Vector3.new(rng:NextNumber(-4, 4), 0, rng:NextNumber(-4, 4))
 elseif kind == 'wheel' then
  local wheel = mapFolder and mapFolder:FindFirstChild('SpiningWheel')
  local wPos = (wheel and wheel:GetPivot().Position) or Vector3.new(-758, 3.2, 29)
  return wPos + Vector3.new(rng:NextNumber(-8, 8), 0, rng:NextNumber(6, 14))
 elseif kind == 'crates' then
  return Vector3.new(-774 + rng:NextNumber(-15, 15), 3.2, 52 + rng:NextNumber(4, 10))
 elseif kind == 'benches' then
  return Vector3.new(-820 + rng:NextNumber(-10, 10), 3.2, 20 + rng:NextNumber(-15, 15))
 end
 -- Random stroll in main plaza between spawn (-798, 105) and pads (-805, -45)
 return Vector3.new(-798 + rng:NextNumber(-30, 30), 3.2, rng:NextNumber(-25, 90))
end

local AI_ARCHETYPES = {
 {
  Id = 'Ace',
  ThinkMin = 0.16, ThinkMax = 0.24,
  SloppyMin = 0.01, SloppyMax = 0.04,
  RingWeight = 340, BoostWeight = 380, HealWeight = 180, RechargeWeight = 160,
  AggroRange = 28, DodgeDashChance = 0.88,
  RiskTolerance = 0.40, BoostBias = 0.50,
  OffenseStyle = 'Speed',
  LobbyBias = { pad = 0.55, wheel = 0.20, crates = 0.10, free = 0.15 },
  LobbyLines = {
   "Locking in! Nobody beats my line.",
   "Voting Map 1, let's set a record!",
   "Double-tap Dash through the tight gates!",
   "Watch my slipstream this round!",
  },
  HitLines = { "Hey! Watch the wings!", "That won't slow me down!", "Rude!!" },
  AttackLines = { "Out of my way!", "See ya!", "Clean overtake!" },
 },
 {
  Id = 'Brawler',
  ThinkMin = 0.20, ThinkMax = 0.30,
  SloppyMin = 0.04, SloppyMax = 0.09,
  RingWeight = 160, BoostWeight = 240, HealWeight = 220, RechargeWeight = 260,
  AggroRange = 42, DodgeDashChance = 0.65,
  RiskTolerance = 0.55, BoostBias = 0.35,
  OffenseStyle = 'Hunter',
  LobbyBias = { pad = 0.30, wheel = 0.15, crates = 0.30, free = 0.25 },
  LobbyLines = {
   "Who wants to get slapped mid-air?",
   "I'm hunting the leader this match!",
   "Better equip Shield if you fly near me!",
   "1v1 me in the sky!",
  },
  HitLines = { "Oh, you're ON my list now!", "Nice try, my turn!", "Wait till I catch you!" },
  AttackLines = { "BONK!", "Gotcha!!", "Stay down!", "Target eliminated!" },
 },
 {
  Id = 'Collector',
  ThinkMin = 0.22, ThinkMax = 0.32,
  SloppyMin = 0.03, SloppyMax = 0.08,
  RingWeight = 460, BoostWeight = 420, HealWeight = 340, RechargeWeight = 320,
  AggroRange = 22, DodgeDashChance = 0.72,
  RiskTolerance = 0.30, BoostBias = 0.45,
  OffenseStyle = 'Greedy',
  LobbyBias = { pad = 0.20, wheel = 0.35, crates = 0.35, free = 0.10 },
  LobbyLines = {
   "Saving up for Mythic wings!",
   "Meet me at the Spinning Wheel!",
   "All the Rings and Coins are mine!",
   "Those new wings look so clean!",
  },
  HitLines = { "Hey, I was grabbing that orb!", "Leave my coins alone!" },
  AttackLines = { "Yoink!", "Mine now!", "Magnet time!" },
 },
 {
  Id = 'Survivor',
  ThinkMin = 0.18, ThinkMax = 0.28,
  SloppyMin = 0.01, SloppyMax = 0.05,
  RingWeight = 220, BoostWeight = 200, HealWeight = 520, RechargeWeight = 240,
  AggroRange = 18, DodgeDashChance = 0.92,
  RiskTolerance = 0.15, BoostBias = 0.25,
  OffenseStyle = 'Tank',
  LobbyBias = { pad = 0.35, wheel = 0.15, crates = 0.15, free = 0.35 },
  LobbyLines = {
   "Stay safe when the storm hits!",
   "Shield timing wins races!",
   "Good luck everyone, fly smart!",
   "Watch out for the spinning hammers!",
  },
  HitLines = { "Shield up!", "Too close! Backing off!", "Whoa, careful!" },
  AttackLines = { "Back off!", "Keeping my space!", "Blocked!" },
 },
 {
  Id = 'Chaotic',
  ThinkMin = 0.20, ThinkMax = 0.35,
  SloppyMin = 0.06, SloppyMax = 0.13,
  RingWeight = 260, BoostWeight = 340, HealWeight = 240, RechargeWeight = 300,
  AggroRange = 36, DodgeDashChance = 0.78,
  RiskTolerance = 0.60, BoostBias = 0.45,
  OffenseStyle = 'Chaos',
  LobbyBias = { pad = 0.25, wheel = 0.25, crates = 0.20, free = 0.30 },
  LobbyLines = {
   "360 barrel roll incoming!!",
   "Wait, which button is Brake again?!",
   "Dropping anvils from orbit haha!",
   "Chaos mode is the BEST mode!",
  },
  HitLines = { "MY FEATHERS!!", "Worth it!!", "Hahaha okay fair!" },
  AttackLines = { "SURPRISE!!", "ANVIL INCOMING!", "Weeeee!" },
 },
}
do
 local extra = {
  { Id='Strategist', Style='Speed', Ring=360, Boost=410, Heal=260, Rech=280, Aggro=32, Dodge=0.90, Risk=0.35, BoostBias=0.42 },
  { Id='Tactician', Style='Hunter', Ring=280, Boost=340, Heal=290, Rech=310, Aggro=36, Dodge=0.86, Risk=0.45, BoostBias=0.35 },
  { Id='Slipstreamer', Style='Speed', Ring=390, Boost=460, Heal=210, Rech=240, Aggro=24, Dodge=0.85, Risk=0.30, BoostBias=0.55 },
  { Id='Guardian', Style='Tank', Ring=240, Boost=250, Heal=480, Rech=320, Aggro=22, Dodge=0.94, Risk=0.20, BoostBias=0.25 },
  { Id='Trickster', Style='Chaos', Ring=310, Boost=370, Heal=230, Rech=340, Aggro=38, Dodge=0.84, Risk=0.60, BoostBias=0.40 },
  { Id='Speedster', Style='Speed', Ring=350, Boost=500, Heal=180, Rech=220, Aggro=26, Dodge=0.89, Risk=0.40, BoostBias=0.62 },
  { Id='Sniper', Style='Hunter', Ring=250, Boost=310, Heal=240, Rech=360, Aggro=48, Dodge=0.82, Risk=0.50, BoostBias=0.30 },
  { Id='CounterAttacker', Style='Tank', Ring=270, Boost=300, Heal=360, Rech=340, Aggro=30, Dodge=0.91, Risk=0.28, BoostBias=0.32 },
  { Id='Opportunist', Style='Greedy', Ring=420, Boost=390, Heal=280, Rech=300, Aggro=34, Dodge=0.80, Risk=0.48, BoostBias=0.44 },
  { Id='NemesisHunter', Style='Hunter', Ring=210, Boost=350, Heal=250, Rech=330, Aggro=46, Dodge=0.78, Risk=0.65, BoostBias=0.38 },
  { Id='RingMaster', Style='Greedy', Ring=520, Boost=400, Heal=260, Rech=270, Aggro=20, Dodge=0.86, Risk=0.25, BoostBias=0.45 },
  { Id='Duelist', Style='Hunter', Ring=260, Boost=330, Heal=290, Rech=320, Aggro=40, Dodge=0.88, Risk=0.52, BoostBias=0.36 },
  { Id='Phantom', Style='Speed', Ring=330, Boost=430, Heal=220, Rech=290, Aggro=30, Dodge=0.95, Risk=0.33, BoostBias=0.50 },
  { Id='GuardianAngel', Style='Tank', Ring=290, Boost=280, Heal=510, Rech=310, Aggro=24, Dodge=0.93, Risk=0.18, BoostBias=0.28 },
  { Id='Grandmaster', Style='Speed', Ring=410, Boost=470, Heal=340, Rech=360, Aggro=38, Dodge=0.96, Risk=0.42, BoostBias=0.58 },
 }
 for _, e in ipairs(extra) do
  table.insert(AI_ARCHETYPES, {
   Id = e.Id,
   ThinkMin = 0.14, ThinkMax = 0.24,
   SloppyMin = 0.01, SloppyMax = 0.05,
   RingWeight = e.Ring, BoostWeight = e.Boost, HealWeight = e.Heal, RechargeWeight = e.Rech,
   AggroRange = e.Aggro, DodgeDashChance = e.Dodge,
   RiskTolerance = e.Risk, BoostBias = e.BoostBias,
   OffenseStyle = e.Style,
   LobbyBias = { pad = 0.40, wheel = 0.20, crates = 0.20, free = 0.20 },
   LobbyLines = { "Calculating optimal flight lines!", "Minimax mode ready.", "Watch the speed boost!" },
   HitLines = { "Calculated risk!", "Adapting strategy!", "Counter-play incoming!" },
   AttackLines = { "Optimal strike!", "High-EV play!", "Outsmarted!" },
  })
 end
end

local function spawnBot(idx)
 local preset = Avatars.Presets[rng:NextInteger(1, #Avatars.Presets)]
 local rig = Avatars.CreateRig(preset)
 local name = Avatars.Names[rng:NextInteger(1, #Avatars.Names)] .. (rng:NextInteger(0, 1) == 1 and tostring(rng:NextInteger(1, 99)) or '')
 rig.Name = name
 local hum = rig:FindFirstChildOfClass('Humanoid')
 hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
 hum.WalkSpeed = 14
 local arch = AI_ARCHETYPES[rng:NextInteger(1, #AI_ARCHETYPES)]
 rig:SetAttribute('BotId', idx)
 rig:SetAttribute('Personality', arch.Id)
 rig:SetAttribute('Level', rng:NextInteger(5, 55))
 rig:SetAttribute('HP', Config.MaxHP)
 rig.Parent = botFolder

 local spawnCenter = Vector3.new(-798, 3.5, 80)
 rig:PivotTo(CFrame.new(spawnCenter + Vector3.new(rng:NextNumber(-18, 18), 0, rng:NextNumber(-15, 15))))
 for _, p in ipairs(rig:GetDescendants()) do
  if p:IsA('BasePart') then
   p.CanCollide = true
   p.Anchored = false
  end
 end

 local skin = Config.SkinOrder[rng:NextInteger(1, #Config.SkinOrder)]
 Wings.Apply(rig, skin)
 attachTag(rig)
 local sigAb = (Config.WingAbilities and Config.WingAbilities[skin]) or 'Slap'
 local bot = {
  model = rig, hum = hum, name = name, flying = false, skin = skin, idx = idx,
  arch = arch, sigAbility = sigAb, lastSayT = 0, rival = nil,
 }
 local animator = hum:FindFirstChildOfClass('Animator')
 local walk, idle, fall = loadAnim(animator, WALK), loadAnim(animator, IDLE), loadAnim(animator, FALL)
 walk.Looped = true idle.Looped = true fall.Looped = true
 bot.tracks = {walk = walk, idle = idle, fall = fall}
 idle:Play()

 hum.Running:Connect(function(spd)
  if bot.flying then return end
  if spd > 0.5 then
   if not walk.IsPlaying then walk:Play() idle:Stop() end
  else
   if not idle.IsPlaying then idle:Play() walk:Stop() end
  end
 end)
 bot.sloppy = rng:NextNumber(arch.SloppyMin, arch.SloppyMax)

 local function botSay(text, force)
  local nowT = os.clock()
  if not force and (nowT - (bot.lastSayT or 0)) < 7.5 then return end
  bot.lastSayT = nowT
  local head = rig:FindFirstChild('Head')
  if head then
   local chatGui = head:FindFirstChild('BotChat')
   if not chatGui then
    chatGui = Instance.new('BillboardGui')
    chatGui.Name = 'BotChat'
    chatGui.Size = UDim2.fromOffset(175, 42)
    chatGui.StudsOffset = Vector3.new(0, 3.3, 0)
    chatGui.AlwaysOnTop = true
    chatGui.MaxDistance = 95
    chatGui.Adornee = head
    local lbl = Instance.new('TextLabel')
    lbl.Name = 'Text'
    lbl.Size = UDim2.fromScale(1, 1)
    lbl.BackgroundColor3 = Color3.fromRGB(22, 26, 38)
    lbl.BackgroundTransparency = 0.14
    lbl.TextWrapped = true
    local cr = Instance.new('UICorner') cr.CornerRadius = UDim.new(0, 10) cr.Parent = lbl
    local st = Instance.new('UIStroke') st.Thickness = 1.5 st.Color = Color3.fromRGB(100, 185, 255) st.Parent = lbl
    lbl.Font = Enum.Font.FredokaOne
    lbl.TextSize = 13
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.Parent = chatGui
    chatGui.Parent = head
   end
   chatGui.Text.Text = text
   chatGui.Enabled = true
   task.delay(3.2, function() if chatGui and chatGui.Parent then chatGui.Enabled = false end end)
  end
 end
 bot.say = botSay

 task.spawn(function()
  while rig.Parent do
   task.wait(rng:NextNumber(2.2, 4.8))
   if (phase == 'Intermission' or phase == 'Countdown') and not bot.flying then
    local roll = rng:NextNumber()
    local nearestPlrChar, nearestPlrName = nil, nil
    local nearestPlrDist = 30
    for _, pl in ipairs(Players:GetPlayers()) do
     if pl.Character and pl.Character:FindFirstChild('HumanoidRootPart') then
      local dist = (pl.Character.HumanoidRootPart.Position - rig:GetPivot().Position).Magnitude
      if dist < nearestPlrDist then
       nearestPlrDist = dist
       nearestPlrChar = pl.Character
       nearestPlrName = pl.DisplayName or pl.Name
      end
     end
    end

    if phase == 'Countdown' then
     hum:MoveTo(hubPoint('pad'))
     if roll < 0.45 then
      hum.Jump = true
      botSay("Round starting! GL!", false)
     end
    elseif nearestPlrChar and roll < 0.30 then
     local targetPos = nearestPlrChar.HumanoidRootPart.Position + Vector3.new(rng:NextNumber(-4.5, 4.5), 0, rng:NextNumber(-4.5, 4.5))
     hum:MoveTo(targetPos)
     if arch.Id == 'Chaotic' and rng:NextNumber() < 0.5 then hum.Jump = true end
     task.delay(1.2, function()
      if rig.Parent and not bot.flying then
       if rng:NextNumber() < 0.45 and nearestPlrName then
        botSay("Yo " .. nearestPlrName .. "! " .. arch.LobbyLines[rng:NextInteger(1, #arch.LobbyLines)], false)
       else
        botSay(arch.LobbyLines[rng:NextInteger(1, #arch.LobbyLines)], false)
       end
      end
     end)
    elseif roll < 0.52 and #bots > 1 then
     local partner = bots[rng:NextInteger(1, #bots)]
     if partner and partner.model ~= rig and partner.model.Parent then
      local groupPos = partner.model:GetPivot().Position + Vector3.new(rng:NextNumber(-5, 5), 0, rng:NextNumber(-5, 5))
      hum:MoveTo(groupPos)
      if rng:NextNumber() < 0.30 then
       task.delay(1.6, function()
        if rig.Parent and not bot.flying then
         botSay(arch.LobbyLines[rng:NextInteger(1, #arch.LobbyLines)], false)
        end
       end)
      end
     end
    else
     local b = arch.LobbyBias
     local r2 = rng:NextNumber()
     local kind = (r2 < b.pad and 'pad') or (r2 < b.pad + b.wheel and 'wheel') or (r2 < b.pad + b.wheel + b.crates and 'crates') or 'free'
     hum:MoveTo(hubPoint(kind))
     if arch.Id == 'Chaotic' and rng:NextNumber() < 0.35 then hum.Jump = true end
    end
   end
  end
 end)

 table.insert(bots, bot)
 return bot
end
local function ensureBots()
 for i=#bots,1,-1 do if not bots[i].model.Parent then table.remove(bots,i) end end
 local need=Config.MaxFlyers-1-#bots
 for i=1,need do task.spawn(spawnBot,#bots+i+rng:NextInteger(100,999)) task.wait(0.15) end
end
local function clearBots()
 for _,b in bots do if b.model then b.model:Destroy() end end
 table.clear(bots)
end

-- ===== flyers =====
local function getPos(f)
 if f.kind=='player' then
  local hrp=f.model:FindFirstChild('HumanoidRootPart')
  return hrp and hrp.Position or Vector3.zero
 end
 return f.pos
end
local function knock(f,v)
 if f.kind=='player' then Remotes.Knock:FireClient(f.plr,v)
 else f.kx+=v.X f.ky+=v.Y end
end
local function setBountyTarget(f)
 for _, fl in ipairs(flyers) do
  if fl.model then
   fl.model:SetAttribute('IsBounty', false)
   local oldH = fl.model:FindFirstChild('SW_BountyHighlight')
   local oldBA = fl.model:FindFirstChild('SW_BountyAura')
   if oldBA then oldBA:Destroy() end
   for _, d in ipairs(fl.model:GetDescendants()) do
    if d:GetAttribute('SW_BountyPart') then d:Destroy() end
   end
   if oldH then oldH:Destroy() end
  end
 end
 if not f or not f.alive or not f.model then
  workspace:SetAttribute('BountyTarget', '')
  return
 end
 f.model:SetAttribute('IsBounty', true)
 workspace:SetAttribute('BountyTarget', f.name)
 local hl = Instance.new('Highlight')
 hl.Name = 'SW_BountyHighlight'
 hl.Adornee = f.model
 hl.FillColor = Color3.fromRGB(255, 210, 40)
 hl.OutlineColor = Color3.fromRGB(255, 255, 255)
 hl.FillTransparency = 0.65
 hl.OutlineTransparency = 0
 hl.Parent = f.model
 Remotes.Toast:FireAllClients('GOLDEN BOUNTY: ' .. f.name .. '! Knock them out for +150 Coins!', 'level')
end

local function koFlyer(f)
 if not f.alive then return end
 f.alive=false
 f.finish=math.max(0,now()-flightStart)
 local killer=nil
 if f.lastHit and f.lastHit~=f and os.clock()-f.lastHitT<6 then killer=f.lastHit killer.kos+=1 end
 if f.model and f.model:GetAttribute('IsBounty')==true and killer then
  if killer.plr then
   Data.Add(killer.plr,'Coins',150)
   Data.Add(killer.plr,'Gems',5)
   Remotes.Toast:FireClient(killer.plr,'BOUNTY CLAIMED! +150 Coins & +5 Gems!','level')
  end
  setBountyTarget(killer)
 elseif killer and killer.alive and (killer.kos or 0) >= 2 and killer.model and killer.model:GetAttribute('IsBounty') ~= true then
  setBountyTarget(killer)
 end
 Remotes.KO:FireAllClients(f.name,killer and killer.name or nil)
 if killer and killer.plr then
  Data.Add(killer.plr,'Coins',50)
  Remotes.Toast:FireClient(killer.plr,'FINISHER! KO\'d '..tostring(f.name)..' (+50 Coins)','good')
 end
 if f.model and f.model.Parent then
  local ke = killer and killer.plr and killer.plr:GetAttribute('KillEffect')
  local fxName = (ke == 'BlackHoleKO' and 'CosmicSingularity') or 'ThunderStrike'
  Remotes.AbilityFx:FireAllClients(fxName, f.model, nil)
 end
 if killer and killer.nemesis == f then
  killer.nemesis = nil
  if killer.plr then
   Data.Add(killer.plr, 'Coins', 100)
   Data.Add(killer.plr, 'Gems', 3)
   Remotes.NemesisUpdate:FireClient(killer.plr, '', '', false)
   Remotes.Toast:FireClient(killer.plr, 'REVENGE KO! +100 Coins & +3 Gems!', 'level')
  end
 end
 f.model:SetAttribute('Flying',false)
 RagdollService.TriggerRagdoll(f.model, 1.75, Vector3.new(rng:NextNumber(-36,36), 40, 46), true)
 if f.kind=='player' then
  if f.plr then Remotes.Toast:FireClient(f.plr,'CRASHED OUT! Returning to Hub...','bad') end
  task.delay(1.75, function()
   if not f.model or not f.model.Parent then return end
   if f.plr and f.plr.Character ~= f.model then return end
   RagdollService.Recover(f.model)
   local hum=f.model:FindFirstChildOfClass('Humanoid')
   if hum then
    hum.EvaluateStateMachine = true
    hum.PlatformStand = false
    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
   end
   f.model:PivotTo(HUB_SPAWN * CFrame.new(rng:NextInteger(-8,8), 1.5, 0))
   local hrp=f.model:FindFirstChild('HumanoidRootPart')
   if hrp then hrp.AssemblyLinearVelocity=Vector3.zero; hrp.AssemblyAngularVelocity=Vector3.zero end
   local hl = Instance.new('Highlight')
   hl.FillColor = Color3.fromRGB(160, 230, 255)
   hl.FillTransparency = 0.45
   hl.OutlineTransparency = 0.2
   hl.Adornee = f.model
   hl.Parent = f.model
   game:GetService('TweenService'):Create(hl, TweenInfo.new(1.4), {FillTransparency=1, OutlineTransparency=1}):Play()
   game:GetService('Debris'):AddItem(hl, 1.5)
  end)
 else
  local hrp=f.model:FindFirstChild('HumanoidRootPart')
  if hrp then hrp.Anchored=false hrp.AssemblyLinearVelocity=Vector3.new(rng:NextNumber(-20,20),30,30) end
 end
end
local function damage(f,amount,src,isCrash,isReflected)
 if not f.alive then return end
 local tNow = os.clock()
 if not isCrash and f.airDodgeUntil and tNow < f.airDodgeUntil then
  if f.plr then Remotes.Toast:FireClient(f.plr, 'AIR DODGED!', 'good') end
  return 0
 end
 if not isCrash and not isReflected and f.reflectUntil and tNow < f.reflectUntil and src and src ~= f and src.alive then
  if f.plr then Remotes.Toast:FireClient(f.plr, 'REFLECTED ATTACK!', 'level') end
  if src.plr then Remotes.Toast:FireClient(src.plr, 'YOUR ATTACK WAS REFLECTED!', 'bad') end
  damage(src, amount, f, false, true)
  return 0
 end
 local mult = 1.0
 if workspace:GetAttribute('Mutator')=='HeavyCrash' and isCrash then mult *= 1.25 end
 if isCrash and f.plr and f.plr:GetAttribute('Pass_CrashShield') then mult *= 0.65 end
 local finalAmt = math.max(1, math.floor(amount * mult))
 f.hp=math.max(0,f.hp-finalAmt)
 if isCrash and f.model then
  local root = f.model:FindFirstChild('HumanoidRootPart')
  if root then
   pcall(function()
    AbilitySFX.PlaySound('HeavyCrash', 0.95, 1.0, root)
   end)
  end
 end
 if src then
  f.lastHit=src f.lastHitT=os.clock()
  if src ~= f and not isCrash then
   f.hitBy = f.hitBy or {}
   f.hitBy[src] = (f.hitBy[src] or 0) + 1
   if f.hitBy[src] == 2 and f.nemesis ~= src then
    f.nemesis = src
    if f.plr and src.model then
     Remotes.NemesisUpdate:FireClient(f.plr, src.model.Name, src.name, true)
     Remotes.Toast:FireClient(f.plr, 'NEMESIS: ' .. tostring(src.name) .. '! KO them for +100 Coins +3 Gems!', 'bad')
    end
   end
  end
  if f.bot and src ~= f then
   f.bot.rival = src
   if f.bot.say and f.bot.arch and rng:NextNumber() < 0.35 then
    local lines = f.bot.arch.HitLines
    f.bot.say(lines[rng:NextInteger(1, #lines)], false)
   end
  end
  if src.bot and src ~= f and src.bot.say and src.bot.arch and rng:NextNumber() < 0.35 then
   local lines = src.bot.arch.AttackLines
   src.bot.say(lines[rng:NextInteger(1, #lines)], false)
  end
  if workspace:GetAttribute('GameMode')=='ChaosBounty' and f.model and f.model:GetAttribute('IsBounty')==true and src~=f and src.plr then
   Data.Add(src.plr,'Coins',25)
  end
 end
 f.model:SetAttribute('HP',f.hp)
 Remotes.Hit:FireAllClients(f.model,finalAmt)
 if f.hp<=0 then koFlyer(f) end
 return finalAmt
end
local function newFlyer(kind,model,plr,bot)
 local f={kind=kind,model=model,plr=plr,bot=bot,name=model.Name,hp=Config.MaxHP,maxHP=Config.MaxHP,alive=true,kos=0,passes=0,invuln=0,dashUntil=0,shieldUntil=0,cd={},lastHit=nil,lastHitT=0,finish=0,passIdx=1}
 local prof = (kind=='player' and plr) and Data.Get(plr) or nil
 if kind=='player' then
  f.level = (prof and prof.Level) or 1
  f.skin = (prof and prof.Skin) or plr:GetAttribute('EquippedSkin') or 'Cardboard'
  local sig = (Config.WingAbilities and Config.WingAbilities[f.skin]) or 'Slap'
  local profAb = (prof and type(prof.ActiveAbility) == 'string' and prof.ActiveAbility ~= '') and prof.ActiveAbility or nil
  f.activeAbility = profAb or (type(sig) == 'string' and sig ~= '' and sig) or 'Slap'
  f.emote = (prof and type(prof.EquippedEmote) == 'string' and prof.EquippedEmote ~= '' and prof.EquippedEmote) or 'Pose1'
 else
  f.level = model:GetAttribute('Level') or 1
  f.skin = (bot and type(bot.skin) == 'string' and bot.skin) or 'Cardboard'
  local wAb = Config.WingAbilities and Config.WingAbilities[f.skin]
  f.activeAbility = (type(wAb) == 'string' and wAb ~= '') and wAb or 'Slap'
  local emPool = {'Pose1', 'Pose2', 'Pose3', 'Pose4'}
  f.emote = emPool[rng:NextInteger(1, #emPool)]
 end
 if type(f.skin) ~= 'string' then f.skin = 'Cardboard' end
 if type(f.activeAbility) ~= 'string' then f.activeAbility = 'Slap' end
 local wb = Config.GetWingBonus and Config.GetWingBonus(f.skin, f.activeAbility)
 if wb and wb.BonusHP and wb.BonusHP > 0 then
  f.maxHP = Config.MaxHP + wb.BonusHP
  f.hp = f.maxHP
 end
 model:SetAttribute('MaxHP', f.maxHP)
 model:SetAttribute('Skin', f.skin)
 model:SetAttribute('ActiveAbility', f.activeAbility)
 model:SetAttribute('FlyerName', f.name)
 model:SetAttribute('TrackProgress', 0)
 if bot then f.kx=0 f.ky=0 f.pos=Vector3.zero end
 return f
end

-- ===== abilities =====
local function nearest(f,filter)
 local pf=getPos(f) local best,bd=nil,nil
 for _,o in flyers do
  if o~=f and o.alive then
   local ok,d=filter(getPos(o)-pf)
   if ok and (not bd or d<bd) then best,bd=o,d end
  end
 end
 return best
end
local function useAbility(f, name)
 if phase ~= 'Flight' or not f.alive then return end
 local t0 = os.clock()
 local function freezeTarget(target, dur, attacker)
  if not target or not target.alive then return end
  if target.shieldUntil and t0 < target.shieldUntil then
   if target.plr then Remotes.Toast:FireClient(target.plr, 'Blocked!', 'good') end
   return
  end
  target.frozenUntil = t0 + dur
  target.model:SetAttribute('FrozenUntil', workspace:GetServerTimeNow() + dur)
  knock(target, Vector3.new(0, 0, 34))
  Remotes.AbilityFx:FireAllClients('FreezeCube', target.model, dur)
  if target.plr then
   Remotes.Toast:FireClient(target.plr, string.format('FROZEN IN ICE! (%.1fs)', dur), 'bad')
  end
 end
 if name == 'Dash' then
  if t0 < (f.cd.Dash or 0) - 0.1 then return end
  f.cd.Dash = t0 + Config.DashCooldown
  f.dashUntil = t0 + 0.4
  f.model:SetAttribute('LastDashCD', Config.DashCooldown)
  f.model:SetAttribute('LastDashStamp', workspace:GetServerTimeNow())
  Remotes.AbilityFx:FireAllClients('Dash', f.model)
  return
 end

 local base = Config.Abilities[name]
 if not base then return end
 if t0 < (f.cd[name] or 0) - 0.1 then return end
 -- Wing tier buffs (server-side): stronger damage, faster cooldown, bonus coins
 local tier = Config.Tiers.Normal
 local prof = f.plr and Data.Get(f.plr)
 if prof and prof.SkinTiers then tier = Config.Tiers[prof.SkinTiers[prof.Skin] or 'Normal'] or tier end
 local wb = Config.GetWingBonus and Config.GetWingBonus(f.skin, name)
 local wingDmgMult = (wb and wb.DmgMult) or 1.0
 local wingCdMult = (wb and wb.CdMult) or 1.0
 local def = setmetatable({
  Damage = base.Damage and math.floor(base.Damage * tier.DmgMult * wingDmgMult) or nil,
  Cooldown = math.max(1.5, base.Cooldown * tier.CdMult * wingCdMult),
 }, {__index = base})
 if tier.Coins > 0 and f.plr then Data.Add(f.plr, 'Coins', tier.Coins) end
 f.cd[name] = t0 + def.Cooldown
 f.model:SetAttribute('ActiveAbility', name)
 f.model:SetAttribute('LastAbilityCD', def.Cooldown)
 f.model:SetAttribute('LastAbilityStamp', workspace:GetServerTimeNow())

 -- Broadcast Ability FX to all clients
 Remotes.AbilityFx:FireAllClients(name, f.model)
 if name == 'ReflectShield' then
  f.reflectUntil = t0 + (def.Duration or 3.0)
  f.model:SetAttribute('ReflectShieldUntil', workspace:GetServerTimeNow() + (def.Duration or 3.0))
  local hrp = f.model:FindFirstChild('HumanoidRootPart')
  if hrp then
   local oldSph = f.model:FindFirstChild('ReflectShieldSphere')
   if oldSph then oldSph:Destroy() end
   local sph = Instance.new('Part')
   sph.Name = 'ReflectShieldSphere'
   sph.Shape = Enum.PartType.Ball
   sph.Size = Vector3.new(11, 11, 11)
   sph.Material = Enum.Material.ForceField
   sph.Color = Color3.fromRGB(110, 245, 255)
   sph.Transparency = 0.25
   sph.CanCollide = false
   sph.CanQuery = false
   sph.CanTouch = false
   sph.Massless = true
   sph.CFrame = hrp.CFrame
   sph.Parent = f.model
   local w = Instance.new('WeldConstraint')
   w.Part0 = hrp; w.Part1 = sph; w.Parent = sph
   game:GetService('Debris'):AddItem(sph, def.Duration or 3.0)
  end
  if f.plr then Remotes.Toast:FireClient(f.plr, 'REFLECT SHIELD ACTIVE (3s)!', 'good') end
  return
 end

 if name == 'NorthStarBeam' then
  for _, other in ipairs(flyers) do
   if other ~= f and (getPos(other) - getPos(f)).Magnitude < def.Range then
    damage(other, def.Damage, f)
    freezeTarget(other, def.Duration or 1.6, f)
   end
  end

 elseif name == 'ChaosPulse' then
  for _, other in ipairs(flyers) do
   if other ~= f and (getPos(other) - getPos(f)).Magnitude < def.Range then
    damage(other, def.Damage, f)
    knock(other, Vector3.new(rng:NextNumber(-def.Knock, def.Knock), 18, 25))
   end
  end

 elseif name == 'CardBarrage' then
  if f.plr then Data.Add(f.plr, 'Coins', 25) end
  local hits = 0
  for _, other in ipairs(flyers) do
   if other ~= f and other.alive and (getPos(other) - getPos(f)).Magnitude < def.Range then
    damage(other, def.Damage, f)
    knock(other, Vector3.new(rng:NextNumber(-def.Knock, def.Knock), 12, 24))
    hits += 1
    if hits >= 4 then break end
   end
  end

 elseif name == 'SolarEclipse' then
  f.shieldUntil = t0 + 2.2
  f.model:SetAttribute('ShieldUntil', now() + 2.2)
  if f.hp then
   f.hp = math.min(Config.MaxHP, f.hp + 80)
   f.model:SetAttribute('HP', f.hp)
  end
  for _, other in ipairs(flyers) do
   if other ~= f and (getPos(other) - getPos(f)).Magnitude < def.Range then
    damage(other, def.Damage, f)
    freezeTarget(other, def.Duration or 2.0, f)
   end
  end

 elseif name == 'VoidRift' then
  for _, other in ipairs(flyers) do
   if other ~= f and (getPos(other) - getPos(f)).Magnitude < def.Range then
    damage(other, def.Damage, f)
    knock(other, Vector3.new(0, -25, 38))
   end
  end

 elseif name == 'WindSlash' then
  for _, other in ipairs(flyers) do
   if other ~= f and other.alive and (getPos(other) - getPos(f)).Magnitude < def.Range then
    if t0 < other.dashUntil then
     if other.plr then Remotes.Toast:FireClient(other.plr, 'Dodged!', 'good') end
    else
     local sign = (getPos(other).X >= getPos(f).X) and 1 or -1
     damage(other, def.Damage, f)
     knock(other, Vector3.new(sign * def.Knock, 14, -20))
    end
   end
  end

 elseif name == 'ThunderStrike' then
  local hits = 0
  for _, other in ipairs(flyers) do
   if other ~= f and other.alive and (getPos(other) - getPos(f)).Magnitude < def.Range then
    damage(other, def.Damage, f)
    freezeTarget(other, def.Duration or 2.0, f)
    hits += 1
    if hits >= 4 then break end
   end
  end
  if f.plr then Remotes.AbilityFx:FireClient(f.plr, 'Surge', f.model) end

 elseif name == 'MagnetPulse' then
  f.shieldUntil = t0 + 2.2
  f.model:SetAttribute('ShieldUntil', now() + 2.2)
  knock(f, Vector3.new(0, 0, -55))
  if f.plr then
   Data.Add(f.plr, 'Coins', 35)
   Remotes.Toast:FireClient(f.plr, 'SHINRA TENSEI! +35 Coins & Shield!', 'good')
  end

 elseif name == 'PhantomBlink' then
  f.dashUntil = t0 + def.Duration
  f.shieldUntil = t0 + def.Duration
  f.model:SetAttribute('ShieldUntil', now() + def.Duration)
  knock(f, Vector3.new(0, 0, -65))
  if f.plr then Remotes.Toast:FireClient(f.plr, 'FLYING RAIJIN!', 'info') end

 elseif name == 'Slap' then
  local t = nearest(f, function(d) return (math.abs(d.Y) < 7 and math.abs(d.Z) < 12 and d.Magnitude < def.Range), d.Magnitude end)
  if t then
   if t0 < t.dashUntil then
    if t.plr then Remotes.Toast:FireClient(t.plr, 'Dodged!', 'good') end
   else
    local sign = (getPos(t).X >= getPos(f).X) and 1 or -1
    damage(t, def.Damage, f)
    knock(t, Vector3.new(sign * def.Knock, 0, 0))
   end
  end

 elseif name == 'FrostBite' then
  -- Bat wing: Slam down and freeze opponents in ice shards
  knock(f, Vector3.new(0, -65, 0))
  for _, other in ipairs(flyers) do
   if other ~= f and (getPos(other) - getPos(f)).Magnitude < def.Range then
    damage(other, def.Damage, f)
    knock(other, Vector3.new(0, -def.Knock, 0))
    freezeTarget(other, def.Duration or 1.8, f)
   end
  end

 elseif name == 'NatureVortex' then
  -- Poseidon Vortex: +120 HP heal + tidal vortex knocking nearby rivals
  if f.hp then
   f.hp = math.min(Config.MaxHP, f.hp + (def.Heal or 120))
   f.model:SetAttribute('HP', f.hp)
   if f.plr then Remotes.Toast:FireClient(f.plr, '+120 HP Senjutsu Heal!', 'good') end
  end
  for _, other in ipairs(flyers) do
   if other ~= f and (getPos(other) - getPos(f)).Magnitude < (def.Range or 40) then
    damage(other, def.Damage, f)
    knock(other, Vector3.new(rng:NextNumber(-def.Knock, def.Knock), 15, -25))
    if other.plr then Remotes.Toast:FireClient(other.plr, 'Swept by Senjutsu Vortex!', 'bad') end
   end
  end

 elseif name == 'MidasBurst' then
  -- Midas 67: Golden shockwave, +100 bonus coins, 2.2s gold shield
  f.shieldUntil = t0 + 2.2
  f.model:SetAttribute('ShieldUntil', now() + 2.2)
  if f.plr then
   Data.Add(f.plr, 'Coins', def.Coins or 100)
   Remotes.Toast:FireClient(f.plr, '+100 Gate of Babylon Coins!', 'good')
  end
  for _, other in ipairs(flyers) do
   if other ~= f and (getPos(other) - getPos(f)).Magnitude < (def.Range or 45) then
    damage(other, def.Damage, f)
    local dir = (getPos(other) - getPos(f))
    if dir.Magnitude > 0.1 then knock(other, dir.Unit * def.Knock) end
   end
  end

 elseif name == 'AbyssalGrasp' then
  -- Hades Grasp: Drag rivals down & steal +30 HP per hit
  for _, other in ipairs(flyers) do
   if other ~= f and (getPos(other) - getPos(f)).Magnitude < (def.Range or 48) then
    damage(other, def.Damage, f)
    local dir = (getPos(f) - getPos(other))
    if dir.Magnitude > 0.1 then knock(other, dir.Unit * def.Knock + Vector3.new(0, -40, 0)) end
    if f.hp then
     f.hp = math.min(Config.MaxHP, f.hp + 30)
     f.model:SetAttribute('HP', f.hp)
    end
    if other.plr then Remotes.Toast:FireClient(other.plr, 'Pulled by Black Vortex!', 'bad') end
   end
  end

 elseif name == 'RailgunSurge' then
  -- Mecha wing: Piercing supersonic laser rush forward with invincibility
  f.dashUntil = t0 + def.Duration
  f.shieldUntil = t0 + def.Duration
  f.model:SetAttribute('ShieldUntil', now() + def.Duration)
  if f.kind == 'player' and f.plr then
   Remotes.Knock:FireClient(f.plr, Vector3.new(0, 0, -95))
  end

 elseif name == 'QuantumWarp' then
  -- Glitch wing: Phase-shift forward 45 studs
  if f.kind == 'player' and f.plr then
   Remotes.Knock:FireClient(f.plr, Vector3.new(0, 0, -75))
   Remotes.Toast:FireClient(f.plr, 'Quantum Phase Warp!', 'good')
  end

 elseif name == 'CosmicSingularity' then
  -- Galaxy wing: Black hole pulls all rivals into epicenter
  for _, other in ipairs(flyers) do
   if other ~= f and (getPos(other) - getPos(f)).Magnitude < 42 then
    damage(other, def.Damage, f)
    local dir = (getPos(f) - getPos(other)).Unit
    knock(other, dir * def.Knock)
   end
  end

 elseif name == 'InfernoBlaze' then
  -- Phoenix wing: Firestorm scorches chasers behind
  for _, other in ipairs(flyers) do
   if other ~= f then
    local d = getPos(other) - getPos(f)
    if d.Z > 0 and d.Magnitude < 38 then
     damage(other, def.Damage, f)
     knock(other, Vector3.new(rng:NextNumber(-35, 35), -20, 50))
     if other.plr then Remotes.Toast:FireClient(other.plr, 'Scorched by Inferno Firestorm!', 'bad') end
    end
   end
  end

 elseif name == 'AcmeAnvil' then
  -- Cartoon wing: giant anvil drops on the nearest rival ahead
  local t = nearest(f, function(d) return (d.Z < 0 and d.Magnitude < def.Range), d.Magnitude end)
  if t then
   if t0 < t.dashUntil then
    if t.plr then Remotes.Toast:FireClient(t.plr, 'Dodged the anvil!', 'good') end
   else
    damage(t, def.Damage, f)
    knock(t, Vector3.new(0, -def.Knock, 0))
    if t.plr then Remotes.Toast:FireClient(t.plr, 'ACME ANVIL!', 'bad') end
   end
  end

 elseif name == 'MagmaWake' then
  -- Lava wing: lava trail burns rivals behind you for several ticks
  local ticks = def.Ticks or 4
  task.spawn(function()
   for _ = 1, ticks do
    task.wait(def.Duration / ticks)
    if phase ~= 'Flight' or not f.alive then return end
    for _, other in ipairs(flyers) do
     if other ~= f and other.alive then
      local d = getPos(other) - getPos(f)
      if d.Z > 0 and d.Magnitude < def.Range then
       damage(other, def.Damage, f)
       knock(other, Vector3.new(rng:NextNumber(-def.Knock, def.Knock), 0, 20))
      end
     end
    end
   end
  end)

 elseif name == 'AngelAscend' then
  -- One Wing Angel: rise untouchable, then holy burst smites nearby rivals
  f.shieldUntil = t0 + def.Duration
  f.model:SetAttribute('ShieldUntil', now() + def.Duration)
  knock(f, Vector3.new(0, 45, 0))
  task.delay(def.Duration, function()
   if phase ~= 'Flight' or not f.alive then return end
   Remotes.AbilityFx:FireAllClients('AngelBurst', f.model)
   for _, other in ipairs(flyers) do
    if other ~= f and other.alive and (getPos(other) - getPos(f)).Magnitude < def.Range then
     damage(other, def.Damage, f)
     local dir = getPos(other) - getPos(f)
     if dir.Magnitude > 0.1 then knock(other, dir.Unit * def.Knock) end
    end
   end
  end)

 elseif name == 'Divebomb' then
  knock(f, Vector3.new(0, -55, 0))
  for _, other in ipairs(flyers) do
   if other ~= f and (getPos(other) - getPos(f)).Magnitude < (def.Range or 38) then
    damage(other, def.Damage or 300, f)
    knock(other, Vector3.new(rng:NextNumber(-20, 20), -(def.Knock or 65), 18))
   end
  end

 elseif name == 'Shield' then
  local dur = def.Duration or 3.2
  f.shieldUntil = t0 + dur
  f.model:SetAttribute('ShieldUntil', now() + dur)
  for _, other in ipairs(flyers) do
   if other ~= f and (getPos(other) - getPos(f)).Magnitude < (def.Range or 32) then
    local dir = getPos(other) - getPos(f)
    if dir.Magnitude > 0.1 then knock(other, dir.Unit * (def.Knock or 65)) end
   end
  end
  if f.plr then Remotes.Toast:FireClient(f.plr, 'SUSANOO ARMOR ACTIVE!', 'good') end

 elseif name == 'Surge' then
  local dur = def.Duration or 2.2
  f.dashUntil = t0 + dur
  f.shieldUntil = t0 + dur
  f.model:SetAttribute('ShieldUntil', now() + dur)
  if f.kind == 'player' and f.plr then
   Remotes.Knock:FireClient(f.plr, Vector3.new(0, 0, -90))
  end
 elseif name == 'AtomicNova' then
  for _, other in ipairs(flyers) do
   if other ~= f and (getPos(other) - getPos(f)).Magnitude < def.Range then
    local dir = (getPos(other) - getPos(f))
    local unit = dir.Magnitude > 0.1 and dir.Unit or Vector3.new(1, 0, 0)
    knock(other, -unit * 38)
    task.delay(0.28, function()
     if phase ~= 'Flight' or not other.alive then return end
     damage(other, def.Damage, f)
     knock(other, unit * def.Knock + Vector3.new(0, 18, 20))
    end)
   end
  end

 elseif name == 'KuramaRoar' then
  for _, other in ipairs(flyers) do
   if other ~= f and (getPos(other) - getPos(f)).Magnitude < def.Range then
    damage(other, def.Damage, f)
    local dir = getPos(other) - getPos(f)
    local unit = dir.Magnitude > 0.1 and dir.Unit or Vector3.new(0, 0, -1)
    knock(other, unit * def.Knock + Vector3.new(0, 15, 0))
   end
  end

 elseif name == 'TimeFreeze' then
  f.shieldUntil = t0 + 1.8
  f.model:SetAttribute('ShieldUntil', now() + 1.8)
  knock(f, Vector3.new(0, 0, -55))
  for _, other in ipairs(flyers) do
   if other ~= f and (getPos(other) - getPos(f)).Magnitude < def.Range then
    damage(other, def.Damage, f)
    freezeTarget(other, def.Duration or 2.6, f)
   end
  end

 elseif name == 'BinaryOverload' then
  f.dashUntil = t0 + (def.Duration or 1.2)
  f.shieldUntil = t0 + (def.Duration or 1.2)
  if f.kind == 'player' and f.plr then
   Remotes.Knock:FireClient(f.plr, Vector3.new(0, 0, -70))
  end
  for _, other in ipairs(flyers) do
   if other ~= f and (getPos(other) - getPos(f)).Magnitude < def.Range then
    damage(other, def.Damage, f)
    knock(other, Vector3.new(rng:NextNumber(-def.Knock, def.Knock), 12, 22))
   end
  end

 elseif name == 'SaiyanOverdrive' then
  local dur = def.Duration or 2.5
  f.dashUntil = t0 + dur
  f.shieldUntil = t0 + dur
  f.model:SetAttribute('ShieldUntil', now() + dur)
  if f.kind == 'player' and f.plr then
   Remotes.Knock:FireClient(f.plr, Vector3.new(0, 0, -95))
  end
  for _, other in ipairs(flyers) do
   if other ~= f and (getPos(other) - getPos(f)).Magnitude < def.Range then
    damage(other, def.Damage, f)
    local dir = getPos(other) - getPos(f)
    if dir.Magnitude > 0.1 then knock(other, dir.Unit * def.Knock) end
   end
  end

 elseif name == 'CorvusSwarm' then
  local hits = 0
  for _, other in ipairs(flyers) do
   if other ~= f and other.alive and (getPos(other) - getPos(f)).Magnitude < def.Range then
    damage(other, def.Damage, f)
    knock(other, Vector3.new(rng:NextNumber(-def.Knock, def.Knock), -18, 28))
    hits += 1
    if hits >= 4 then break end
   end
  end
 end
end

-- ===== track =====
local function applyStuds(p)
 Studifier.Apply(p)
end
local function attachHazardVFX(part, effectKind)
 if not part then return end
 local pl = Instance.new("PointLight")
 pl.Brightness = 2.5
 pl.Range = 16
 pl.Color = part.Color
 pl.Parent = part

 local pe = Instance.new("ParticleEmitter")
 pe.Rate = 18
 pe.Lifetime = NumberRange.new(0.3, 0.7)
 pe.Speed = NumberRange.new(4, 12)
 pe.SpreadAngle = Vector2.new(45, 45)
 pe.LightEmission = 0.8
 pe.Color = ColorSequence.new(part.Color)
 pe.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 1)})
 pe.Size = NumberSequence.new({
  NumberSequenceKeypoint.new(0, 1.4),
  NumberSequenceKeypoint.new(1, 0.1)
 })
 if effectKind == "Electric" or part.Material == Enum.Material.Neon then
  pe.Rate = 28
  pe.Speed = NumberRange.new(6, 18)
  pe.LightEmission = 1.0
  pe.SpreadAngle = Vector2.new(180, 180)
 end
 pe:SetAttribute("BaseRate", pe.Rate)
 CS:AddTag(pe, "SW_AmbientVFX")
 pe.Parent = part
end

local function P(par,name,size,cf,col,mat,effectKind)
 local p=Instance.new('Part') p.Name=name p.Size=size p.CFrame=cf p.Color=col p.Material=mat or Enum.Material.Plastic
 p.Anchored=true
 applyStuds(p)
 p.CanCollide=false p.Parent=par
 if not name:find('GuardRail') and (mat == Enum.Material.Neon or effectKind or name:find('Laser') or name:find('Blade') or name:find('Spike') or name:find('Head') or name:find('Mace')) then
  attachHazardVFX(p, effectKind)
 end
 return p
end
local PAL={Color3.fromRGB(255,89,89),Color3.fromRGB(255,200,40),Color3.fromRGB(80,200,255),Color3.fromRGB(150,255,120),Color3.fromRGB(255,140,220)}
local function pal() return PAL[rng:NextInteger(1,#PAL)] end

local function buildTrack(map)
 local folder = Instance.new('Folder') folder.Name = 'Track'
 local obs = Instance.new('Folder') obs.Name = 'Obstacles' obs.Parent = folder
 local highway = Instance.new('Folder') highway.Name = 'Highway' highway.Parent = folder
 local deco = Instance.new('Folder') deco.Name = 'Deco' deco.Parent = folder
 local rings = Instance.new('Folder') rings.Name = 'Rings' rings.Parent = folder
 local fauna = Instance.new('Folder') fauna.Name = 'Animals' fauna.Parent = folder
 table.clear(movers) table.clear(orbs) table.clear(passMarks)
 local len = Config.TrackLength

 -- Generate spline course
 local diff = map.Difficulty or workspace:GetAttribute('Difficulty') or 'Medium'
 workspace:SetAttribute('Difficulty', diff)
 -- Weather is now decided per zone while flying (see zone loop); start every round clear
 local styles = { 'Sweeping', 'Chicane', 'Rollercoaster', 'Helix' }
 local rSeed = math.random(1000, 999999)
 local rStyle = styles[math.random(1, #styles)]
 workspace:SetAttribute('CourseSeed', rSeed)
 workspace:SetAttribute('RouteStyle', rStyle)
 local evList = { 'Standard', 'SolarFlare', 'CoinRain', 'ElectricStorm', 'BlizzardGale', 'CosmicAurora' }
 local chosenEv = evList[math.random(1, #evList)]
 workspace:SetAttribute('WeatherEvent', chosenEv)
 Remotes.Toast:FireAllClients('Route: ' .. rStyle .. '  |  Event: ' .. chosenEv, 'info')
 workspace:SetAttribute('CurrentBiome', 'Valley')
 local controlPoints = SplineUtils.GenerateCourseControlPoints(O, len, map.Id, diff, rSeed, rStyle)
 currentCourseCP = controlPoints

 local ss = game:GetService('ServerStorage')
 local archivePacks = ss:FindFirstChild('WorkspacePackArchive')
 local userPacks = ss:FindFirstChild('UserAssetPacks') or Instance.new('Folder')
 local assets = ss:FindFirstChild('Assets') or Instance.new('Folder')
 -- (no early return: the floor + obstacles must still build even if the asset packs are missing)

 local animalsFolder = userPacks:FindFirstChild('Animals') or (archivePacks and archivePacks:FindFirstChild('Animals')) or ss:FindFirstChild('StudCreatures')
 local studPack = userPacks:FindFirstChild('Stud Pack')
 local studPack2 = userPacks:FindFirstChild('StudPack2')
 local studPackV1 = userPacks:FindFirstChild('Stud pack V1')
 local studPackFolder = userPacks:FindFirstChild('StudPack')
 local studPack3 = (archivePacks and archivePacks:FindFirstChild('🧩Luke\'s Studs Pack [V2]')) or userPacks:FindFirstChild('StudPack3')
 local anotherOne = (archivePacks and archivePacks:FindFirstChild('StudPackAnotherOne')) or userPacks:FindFirstChild('StudPackAnotherOne')
 local naturePack = userPacks:FindFirstChild('NaturePack') or (userPacks:FindFirstChild('600+ ASSESTS STUD') and userPacks['600+ ASSESTS STUD']:FindFirstChild('ROBLOX_NATURE_480_ASSET_PACK'))

 -- Helper to query asset across all user packs
 local assetCache = {}
	local findAssetRaw

	local function isCatalogContainer(inst)
		if not inst then return false end
		if inst.Name:match("^%d%d_") then return true end
		if inst.Parent and inst.Parent.Name == "ROBLOX_NATURE_480_ASSET_PACK" then return true end
		if inst.Name == "ROBLOX_NATURE_480_ASSET_PACK" then return true end
		if inst:IsA("Folder") then return true end
		if inst:IsA("Model") and not inst:FindFirstChildOfClass("Humanoid") and not inst.PrimaryPart and #inst:GetChildren() >= 8 and inst:FindFirstChildWhichIsA("MeshPart") then
			return true
		end
		return false
	end

	local function resolveChild(inst)
		if not inst or not isCatalogContainer(inst) then return inst end
		local ch = {}
		for _, c in ipairs(inst:GetChildren()) do
			if c:IsA("Model") or c:IsA("MeshPart") or c:IsA("BasePart") then
				table.insert(ch, c)
			end
		end
		if #ch > 0 then
			local picked = ch[rng:NextInteger(1, #ch)]
			if isCatalogContainer(picked) then
				return resolveChild(picked)
			end
			return picked
		end
		return inst
	end

	local function findAsset(name)
		if not name then return nil end
		local r = findAssetRaw(name)
		if not r then return nil end
		if isCatalogContainer(r) then
			return resolveChild(r)
		end
		local c = assetCache[name]
		if c ~= nil then return c or nil end
		assetCache[name] = r
		return r
	end

	function findAssetRaw(name)
		if not name then return nil end
		local sources = {}
		for _, src in pairs({anotherOne, studPack3, studPack, studPack2, studPackV1, studPackFolder, naturePack, archivePacks, userPacks, assets}) do table.insert(sources, src) end
		for _, s in ipairs(sources) do
			if s then
				local target = s:FindFirstChild(name, true)
				if target then return target end
			end
		end
		return nil
	end

	local function spawnModel(name, cf, parentFolder)
  local tpl = findAsset(name)
  if not tpl then return nil end
  local cl = tpl:Clone()
  for _, p in ipairs(cl:GetDescendants()) do
   if p:IsA('BasePart') then
    p.Anchored = true
    p.CanCollide = false
   end
  end
  if cl:IsA('BasePart') then
   cl.Anchored = true
   cl.CanCollide = false
   cl.CFrame = cf
  else
   cl:PivotTo(cf)
  end
  cl.Parent = parentFolder or deco
  return cl
 end

 local function spawnAnimal(animName, cf)
  local tpl = (workspace:FindFirstChild("Animals") and workspace.Animals:FindFirstChild(animName))
             or (animalsFolder and animalsFolder:FindFirstChild(animName))
  if not tpl then return end
  local cl = tpl:Clone()
  for _, p in ipairs(cl:GetDescendants()) do
   if p:IsA('BasePart') then
    p.Anchored = true
    p.CanCollide = false
   end
  end
  if cl:IsA('BasePart') then
   cl.Anchored = true
   cl.CanCollide = false
   cl.CFrame = cf
  else
   cl:PivotTo(cf)
  end
  cl.Parent = fauna

  -- Procedural Bone Walking Animation for rigged animals
  local legBL = cl:FindFirstChild("LEG_BL_U", true)
  local legBR = cl:FindFirstChild("LEG_BR_U", true)
  local legFL = cl:FindFirstChild("LEG_FL_U", true)
  local legFR = cl:FindFirstChild("LEG_FR_U", true)
  local head = cl:FindFirstChild("HEAD", true)
  if legBL and legBR and legFL and legFR then
   local blOrig = legBL.CFrame
   local brOrig = legBR.CFrame
   local flOrig = legFL.CFrame
   local frOrig = legFR.CFrame
   local headOrig = head and head.CFrame
   local ph = rng:NextNumber(0, 6.28)
   table.insert(movers, function(t)
    local ang = math.sin(t * 6.5 + ph) * 0.38
    legBL.CFrame = blOrig * CFrame.Angles(ang, 0, 0)
    legBR.CFrame = brOrig * CFrame.Angles(-ang, 0, 0)
    legFL.CFrame = flOrig * CFrame.Angles(-ang, 0, 0)
    legFR.CFrame = frOrig * CFrame.Angles(ang, 0, 0)
    if head and headOrig then
     head.CFrame = headOrig * CFrame.Angles(math.sin(t * 3.2 + ph) * 0.12, 0, 0)
    end
   end)
  end
  return cl
 end

 -- 5 Logically Clustered Biomes Along the Spline Track
 local biomes = {
  {
   Name = "Sunny Valley & Green Meadows",
   Range = {0.0, 0.16},
   FloorCol = Color3.fromRGB(86, 175, 75),
   WallCol = Color3.fromRGB(110, 210, 100),
   BarrierCol = Color3.fromRGB(245, 205, 45),
   Type = "Valley",
   Animals = {"DEER", "RABBIT", "FOX", "BISON", "ANTELOPE"},
   Flora = {"08_GRASS", "09_FLOWERS", "12_SMALL_PLANTS", "07_BUSHES", "05_STUMPS"},
   Trees = {"TREE_BROAD_01", "TREE_BROAD_02", "ClassicTree", "Basic_Tree1", "Basic_Tree2", "TREE_TALL_02"},
   Props = {"Fence 1", "Wood Sign", "Picnic Carpet", "Bench"}
  },
  {
   Name = "Stud Recreation Park",
   Range = {0.16, 0.32},
   FloorCol = Color3.fromRGB(98, 195, 88),
   WallCol = Color3.fromRGB(75, 160, 230),
   BarrierCol = Color3.fromRGB(255, 255, 255),
   Type = "Park",
   Animals = {"PIGEON", "SPARROW", "DUCK", "SQUIRREL"},
   Flora = {"Flowers", "FlowerBlue", "FlowerRed", "09_FLOWERS", "08_GRASS"},
   Trees = {"Tree 2", "Tree 3", "Tree1", "Basic_Tree3", "ClassicTree"},
   Props = {"Fountain", "ClassicFountain", "Park Bench", "Street Light 1", "Street Light 2", "Trash Bin", "Table", "Chair", "Picnic Carpet"}
  },
  {
   Name = "Pirate Water Bay & River",
   Range = {0.32, 0.48},
   FloorCol = Color3.fromRGB(50, 140, 215), -- Classic Blue Stud Water
   WallCol = Color3.fromRGB(40, 110, 180),
   BarrierCol = Color3.fromRGB(255, 215, 0),
   Type = "WaterBay",
   Animals = {"CROCODILE", "HIPPO", "TURTLE", "PELICAN", "SEAGULL", "FROG"},
   Flora = {"15_WETLAND_PLANTS", "CATTAIL_04", "REED_04", "SWAMP_PLANT_01", "20_RIVER_NATURE"},
   Trees = {"TREE_WILLOW_02", "DRIFTWOOD_01", "Tree 2", "TREE_BROAD_01"},
   Props = {"Stud Pirate Ship", "Stud Shark", "Bridge", "Bridge Rail", "Log Round Rope"}
  },
  {
   Name = "Deep Pine Forest & Highway",
   Range = {0.48, 0.64},
   FloorCol = Color3.fromRGB(48, 88, 52),
   WallCol = Color3.fromRGB(38, 70, 42),
   BarrierCol = Color3.fromRGB(180, 140, 75),
   Type = "Forest",
   Animals = {"BEAR", "WOLF", "BOAR", "OWL", "MOOSE"},
   Flora = {"Bush 1 Detail", "Bush 2 Detail", "19_MUSHROOMS", "04_LOGS", "06_ROCKS"},
   Trees = {"Pine Tree", "TREE_PINE_03", "WinterTree4", "TREE_SNOW_PINE_01", "ClassicTree"},
   Props = {"Campfire", "Log with seat", "Wood Sign", "Car", "Small Sign"}
  },
  {
   Name = "Winter Tundra & Snowy Pines",
   Range = {0.64, 0.80},
   FloorCol = Color3.fromRGB(225, 238, 248), -- Snowy White Stud Surface
   WallCol = Color3.fromRGB(175, 210, 235),
   BarrierCol = Color3.fromRGB(120, 200, 255),
   Type = "Winter",
   Animals = {"POLAR_BEAR", "SNOW_LEOPARD", "ARCTIC_HARE", "REINDEER", "PENGUIN", "SNOWY_OWL"},
   Flora = {"Candy Cane", "06_ROCKS", "Pebble 1", "Pebble 2"},
   Trees = {"WinterTree1", "WinterTree3", "WinterTree4", "Pine Tree"},
   Props = {"Lanterns 1", "Lanterns 2", "Campfire", "Fence Detail 1"}
  },
  {
   Name = "Midnight Jungle & Lost Ruins",
   Range = {0.80, 1.0},
   FloorCol = Color3.fromRGB(35, 68, 48),
   WallCol = Color3.fromRGB(65, 30, 85),
   BarrierCol = Color3.fromRGB(0, 255, 200),
   Type = "Jungle",
   Animals = {"GORILLA", "JAGUAR", "MONKEY", "TOUCAN", "PARROT", "SNAKE", "IGUANA"},
   Flora = {"18_VINES", "13_JUNGLE_PLANTS", "10_FERNS", "19_MUSHROOMS"},
   Trees = {"TREE_SAVANNA_01", "TREE_WILLOW_02", "Tree 2", "TREE_BROAD_02"},
   Props = {"Stud Torch", "LANDMARK_ROOT_ARCH_01", "StudRock", "22_LANDMARKS"}
  }
}
local function getBiomeForT(tProg)
  for _, b in ipairs(biomes) do
   if tProg >= b.Range[1] and tProg <= b.Range[2] then return b end
  end
  return biomes[#biomes]
 end

 -- 1. Build Spline Highway Roadway (140 studs wide) with Authentic Top-Surface Studs
 -- 1. Plan obstacle waves, speed rings and pass marks (pure math, 0 DataModel instances created)
 local obsPlan = Obstacles.Plan({
  cp = controlPoints, len = len, rng = rng, map = map, CS = CS, passMarks = passMarks
 })
 print(('[Round] Planned %s: %d waves, %d rings'):format(map.Name, #obsPlan.waves, #obsPlan.rings))

 -- 2. Complete Chunk Streamer (Catmull-Rom highway slices + obstacles + speed rings + decor):
 --    strictly maintains <= 8 active chunks total! Old chunks behind are destroyed, new chunks ahead are generated.
 multiverseActive = false -- Multiverse removed
 multiverseChunkIdx = multiverseActive and 18 or nil
 multiversePortalPos = nil
 table.clear(multiverseOrbs)
 workspace:SetAttribute('MultiverseActive', multiverseActive)

 decorStreamer = Decor.Create({
  SplineUtils = SplineUtils, cp = controlPoints, getBiomeForT = getBiomeForT,
  findAsset = findAsset, applyStuds = applyStuds, animalsFolder = animalsFolder,
  deco = deco, fauna = fauna, movers = movers, seed = rng:NextInteger(1, 1000000),
  highway = highway, obs = obs, rings = rings, orbs = orbs,
  obstaclePlan = obsPlan, Obstacles = Obstacles, len = len, CS = CS, map = map,
  multiverseChunk = multiverseChunkIdx,
  onMultiversePortal = function(pos)
   multiversePortalPos = pos
  end
 })
 for _ = 1, 4 do
  decorStreamer.Update(0, 6)
  task.wait()
 end

 if multiverseActive then
  local mvFolder = Instance.new('Folder')
  mvFolder.Name = 'MultiverseZone'
  local mvMatCols = { Color3.fromRGB(110, 45, 220), Color3.fromRGB(60, 210, 255), Color3.fromRGB(220, 65, 255) }
  for k = 0, 14 do
   local tM = 0.39 + k * (0.16 / 14)
   local cfM = SplineUtils.GetCourseFrame(controlPoints, tM) + Vector3.new(0, 600, 0)
   -- Cosmic runway rings + floating inverted 2022 Stud islands
   for _, sx in ipairs({ -48, 48 }) do
    local island = Instance.new('Part')
    island.Name = 'CosmicIsland_' .. k .. '_' .. sx
    island.Size = Vector3.new(rng:NextNumber(16, 26), rng:NextNumber(10, 18), rng:NextNumber(18, 28))
    island.CFrame = cfM * CFrame.new(sx, rng:NextNumber(-14, 24), 0) * CFrame.Angles(0, rng:NextNumber(0, 3), math.pi)
    island.Color = mvMatCols[(k % #mvMatCols) + 1]
    island.Material = Enum.Material.Plastic
    island.Anchored, island.CanCollide, island.CanTouch, island.CanQuery, island.CastShadow = true, false, false, false, false
    applyStuds(island)
    island.Parent = mvFolder
   end
   -- Neon archway every 3rd segment
   if k % 3 == 0 then
    local col = mvMatCols[(k % #mvMatCols) + 1]
    for _, sx in ipairs({ -36, 36 }) do
     local pil = Instance.new('Part')
     pil.Size = Vector3.new(3, 52, 3)
     pil.CFrame = cfM * CFrame.new(sx, 22, 0)
     pil.Color = col; pil.Material = Enum.Material.Neon
     pil.Anchored, pil.CanCollide, pil.CanTouch, pil.CanQuery, pil.CastShadow = true, false, false, false, false
     pil.Parent = mvFolder
    end
   end
   -- High-value 3x Coin/Gem Orbs in lane space
   local ox, oy = rng:NextNumber(-26, 26), rng:NextNumber(12, 34)
   local orbPos = (cfM * CFrame.new(ox, oy, 0)).Position
   local isGem = (k % 3 == 0)
   local orb = Instance.new('Part')
   orb.Name = isGem and 'MultiverseGem' or 'MultiverseCoin'
   orb.Shape = Enum.PartType.Ball
   orb.Size = Vector3.new(4.5, 4.5, 4.5)
   orb.CFrame = CFrame.new(orbPos)
   orb.Color = isGem and Color3.fromRGB(70, 235, 255) or Color3.fromRGB(255, 215, 45)
   orb.Material = Enum.Material.Neon
   orb.Anchored, orb.CanCollide, orb.CanTouch, orb.CanQuery, orb.CastShadow = true, false, false, false, false
   orb.Parent = mvFolder
   table.insert(multiverseOrbs, { model = orb, pos = orbPos, kind = isGem and 'MultiverseGem' or 'MultiverseCoin', radius = 9.5 })
  end
  -- Return Portal arch at end of Multiverse Pocket
  local pcFolder = ss:FindFirstChild('PremadeChunks')
  local pTpl = pcFolder and pcFolder:FindFirstChild('MultiversePortal')
  if pTpl then
   local retPortal = pTpl:Clone()
   retPortal.Name = 'MultiverseReturnPortal'
   for _, d in ipairs(retPortal:GetDescendants()) do
    if d:IsA('BasePart') then
     d.Anchored, d.CanCollide, d.CanTouch, d.CanQuery, d.CastShadow = true, false, false, false, false
     applyStuds(d)
    end
   end
   retPortal:PivotTo(SplineUtils.GetCourseFrame(controlPoints, 0.56) * CFrame.new(0, 600, 0))
   retPortal:SetAttribute('AnimKind', 'PortalSpin')
   retPortal:SetAttribute('AnimOriginCF', retPortal:GetPivot())
   CS:AddTag(retPortal, 'SW_ClientAnim')
   retPortal.Parent = mvFolder
  end
  mvFolder.Parent = folder
 end

 folder.Parent = workspace
 hazParams.FilterDescendantsInstances = {obs}
 trackFolder = folder
end

local function resetEnvironment()
 workspace:SetAttribute('CurrentBiome', nil)
 workspace:SetAttribute('WeatherEvent', nil)
 workspace:SetAttribute('Zone', nil)
 local L=game:GetService('Lighting')
 L.ClockTime=14.5 L.Brightness=2.5 L.OutdoorAmbient=Color3.fromRGB(128,128,128) L.FogEnd=100000
end

local function cleanTrack()
 if decorStreamer then decorStreamer.Destroy() decorStreamer=nil end
 if trackFolder then trackFolder:Destroy() trackFolder=nil end
 table.clear(movers) table.clear(orbs) table.clear(passMarks) table.clear(multiverseOrbs)
 multiversePortalPos = nil
 multiverseActive = false
 multiverseChunkIdx = nil
 resetEnvironment()
end

-- ===== flight sim =====

local function getSplineFrame(t)
    if not currentCourseCP then
        return CFrame.new(O.X, O.Y, O.Z - Config.FlightSpeed * math.max(0, t - flightStart))
    end
    local elapsed = math.max(0, t - flightStart)
    local totalDist = Config.FlightSpeed * elapsed
    local tProg = math.clamp(totalDist / Config.TrackLength, 0, 1)
    return SplineUtils.GetCourseFrame(currentCourseCP, tProg)
end

local function boxZ(t) return O.Z-Config.FlightSpeed*math.max(0,t-flightStart) end

local BOT_AHEAD={16,34,56}
local function frameAtDist(dist)
 if not currentCourseCP then return CFrame.new(O.X,O.Y,O.Z-dist) end
 return SplineUtils.GetCourseFrame(currentCourseCP,math.clamp(dist/Config.TrackLength,0,1))
end

local function updateBot(f,dt,t)
 local b=f.bot
 local arch=b.arch or AI_ARCHETYPES[1]
 local H=Config.Box
 if f.frozenUntil and os.clock() < f.frozenUntil then
  b.rz = math.min(H.Back, (b.rz or 0) + 26 * dt)
  local boxD = Config.FlightSpeed * math.max(0, now() - flightStart)
  local cf = frameAtDist(boxD)
  if b.lx then
   local p = (cf * CFrame.new(b.lx, b.ly, b.rz)).Position
   b.pos = p
   f.model:PivotTo(CFrame.lookAt(p, p + cf.LookVector))
  end
  return
 end
 local boxD=Config.FlightSpeed*math.max(0,now()-flightStart)
 local cf=frameAtDist(boxD)
 if not b.lx then b.lx=b.pos.X-O.X b.ly=22 end
 local px,py=b.lx,b.ly

 -- Track leader longitudinal position leaderZ across all alive flyers (players and bots)
 local leaderZ = 1e9
 for _, other in ipairs(flyers) do
  if other.alive then
   if other.bot and other.bot.rz then
    leaderZ = math.min(leaderZ, other.bot.rz)
   elseif other.kind == 'player' and other.model and other.model:FindFirstChild('HumanoidRootPart') then
    local pz = cf:PointToObjectSpace(other.model.HumanoidRootPart.Position).Z
    leaderZ = math.min(leaderZ, pz)
   end
  end
 end
 local distBehindLeader = math.max(0, (b.rz or 0) - leaderZ)
 b.distBehind = distBehindLeader

 b.think-=dt
 if b.think<=0 then
  b.think=rng:NextNumber(arch.ThinkMin, arch.ThinkMax)
  local botD=boxD-b.rz
  local hpFrac = f.hp / Config.MaxHP

  -- Scan nearby flyers for tactical awareness (hunting, dodging, rival, bounty)
  local nearestEnemy, nearestEnemyDist, nearestEnemyRel = nil, 1e9, nil
  local huntTarget, huntRel = nil, nil
  for _, other in ipairs(flyers) do
   if other ~= f and other.alive then
    local oPos = getPos(other)
    local d = (oPos - b.pos).Magnitude
    local rel = cf:PointToObjectSpace(oPos)
    if d < nearestEnemyDist then
     nearestEnemyDist = d
     nearestEnemy = other
     nearestEnemyRel = rel
    end
    if (other == b.rival or (other.model and other.model:GetAttribute('IsBounty') == true)) and d < 55 then
     huntTarget = other
     huntRel = rel
    end
   end
  end
  if not huntTarget and arch.OffenseStyle == 'Hunter' and nearestEnemy and nearestEnemyDist < 48 then
   huntTarget = nearestEnemy
   huntRel = nearestEnemyRel
  end

  -- Scan nearby orbs & differentiate kind for smart prioritization
  local nearbyOrbs = {}
  for _, o in ipairs(orbs) do
   if o.pos and o.model and o.model.Parent then
    local rel = cf:PointToObjectSpace(o.pos)
    if rel.Z < -8 and rel.Z > -105 then
     local w = 120
     if o.persist then
      w = arch.RingWeight
     elseif o.kind == 'Heal' then
      w = (hpFrac < 0.55) and (arch.HealWeight * 1.9) or ((hpFrac < 0.85) and arch.HealWeight or 40)
     elseif o.kind == 'Boost' then
      w = arch.BoostWeight
     elseif o.kind == 'Recharge' then
      local onCd = (t < (f.cd[b.sigAbility] or 0))
      w = onCd and (arch.RechargeWeight * 1.6) or 90
     end
     table.insert(nearbyOrbs, { rel = rel, weight = w })
    end
   end
  end

  if b.distracted > 0 then
   b.distracted -= 0.25
  else
   -- Evaluate 3x3 tactical grid (9 cells * up to 2 lookaheads = max 18 queries)
   local best, bs, bc = nil, -1, 1e9
   local centerClear = 4
   for xi=-2,2,2 do for yi=0,2 do
    local x=xi*11 local y=8+yi*13
    local free=#BOT_AHEAD+1
    for k=1,2 do
     local fr=frameAtDist(botD+BOT_AHEAD[k])
     if #workspace:GetPartBoundsInBox(fr*CFrame.new(x,y,0),Vector3.new(10,10,8),hazParams)>0 then free=k break end
    end
    if math.abs(x - px) < 7 and math.abs(y - py) < 8 then
     centerClear = math.min(centerClear, free)
    end

    local c = (x-px)^2 + (y-py)^2 + rng:NextNumber(0, 10)

    -- Orb attraction
    for _, orb in ipairs(nearbyOrbs) do
     if (x - orb.rel.X)^2 + (y - orb.rel.Y)^2 < 160 then
      c -= orb.weight
     end
    end

    -- Hunter / Rival steering OR Survivor spacing
    if huntRel and free >= 3 then
     local d2Target = (x - huntRel.X)^2 + (y - huntRel.Y)^2
     if d2Target < 260 then c -= 220 end
    elseif arch.OffenseStyle == 'Tank' and nearestEnemyRel and nearestEnemyDist < 16 then
     local d2Threat = (x - nearestEnemyRel.X)^2 + (y - nearestEnemyRel.Y)^2
     if d2Threat < 140 then c += 180 end
    end

    if free>bs or (free==bs and c<bc) then bs,bc,best=free,c,{x,y} end
   end end

   if best then b.tx,b.ty=best[1],best[2] else b.tx,b.ty=rng:NextNumber(-28,28),rng:NextNumber(12,42) end
   if bc>240 and rng:NextNumber()<b.sloppy*1.8 then b.distracted=rng:NextNumber(0.25,0.65) end

   -- Expectimax Decision-Making with Probabilistic Opponent Modeling
   f.bot.allowed = true
   local risk = arch.RiskTolerance or 0.40
   local boostBias = arch.BoostBias or 0.35
   local aggroRange = arch.AggroRange or 32
   local dodgeChance = arch.DodgeDashChance or 0.85

   -- 1. Estimate opponent action probabilities P(opp) = [Pref, Peva, Patk, Pspd, Phld]
   local pReflect, pEvade, pAttack, pSpeed, pHold
   if nearestEnemy then
    if nearestEnemy.reflectUntil and t < nearestEnemy.reflectUntil then
     pReflect = 0.95
    elseif nearestEnemy.shieldUntil and t < nearestEnemy.shieldUntil then
     pReflect = 0.85
    elseif nearestEnemyDist < 24 and hpFrac < 0.45 then
     pReflect = 0.22
    else
     pReflect = 0.08
    end

    if nearestEnemy.airDodgeUntil and t < nearestEnemy.airDodgeUntil then
     pEvade = 0.90
    elseif nearestEnemyDist < 18 then
     pEvade = 0.25
    else
     pEvade = 0.10
    end

    local oppCd = (nearestEnemy.cd and nearestEnemy.cd.Slap) or 0
    local oppCanAtk = (t >= oppCd)
    if nearestEnemyDist < aggroRange and oppCanAtk then
     pAttack = (nearestEnemyDist < 18) and (0.50 + (1 - risk) * 0.15) or 0.35
    else
     pAttack = 0.08
    end

    if centerClear >= 3 and nearestEnemyDist > 16 then
     pSpeed = 0.28
    elseif nearestEnemyDist > 30 then
     pSpeed = 0.20
    else
     pSpeed = 0.10
    end

    pHold = math.max(0.08, 1.0 - (pReflect + pEvade + pAttack + pSpeed) * 0.6)
   else
    pReflect = 0.02
    pEvade = 0.05
    pAttack = 0.02
    pSpeed = 0.45
    pHold = 0.46
   end

   -- Normalize probabilities so sum P(opp) = 1
   local sumP = pReflect + pEvade + pAttack + pSpeed + pHold
   pReflect = pReflect / sumP
   pEvade = pEvade / sumP
   pAttack = pAttack / sumP
   pSpeed = pSpeed / sumP
   pHold = pHold / sumP

   -- 2. Evaluate Expected Utility for candidate actions {Attack, Reflect/Shield, Evade, SpeedBoost, Hold}
   -- EU(action) = sum P(opp_j) * Utility(action, opp_j)

   -- Candidate Action A: Attack
   local ab = b.sigAbility or 'Slap'
   if t < (f.cd[ab] or 0) and t >= (f.cd.Slap or 0) and nearestEnemyDist < 22 then ab = 'Slap' end
   local canAtk = nearestEnemy and (nearestEnemyDist < aggroRange) and (t >= (f.cd[ab] or 0))
   local euAttack
   if canAtk then
    local uAtkRef = -1.85
    local uAtkEva = -0.45
    local uAtkAtk = 0.35 + risk * 0.50
    local uAtkSpd = 1.10 + (arch.OffenseStyle == 'Hunter' and 0.40 or 0.15)
    local uAtkHld = 1.50 + risk * 0.30
    euAttack = pReflect * uAtkRef + pEvade * uAtkEva + pAttack * uAtkAtk + pSpeed * uAtkSpd + pHold * uAtkHld
    if hpFrac < 0.35 then euAttack -= 0.40 end
   else
    euAttack = -2.0
   end

   -- Candidate Action B: Reflect / Shield (Defend)
   local canReflect = t >= (f.cd.ReflectShield or 0)
   local canShield = t >= (f.cd.Shield or 0)
   local canDefend = canReflect or canShield
   local euDefend
   if canDefend then
    local uDefRef = 0.0
    local uDefEva = 0.10
    local uDefAtk = canReflect and 2.20 or 1.95
    local uDefSpd = -0.30
    local uDefHld = -0.20
    local hpDefenseMult = (hpFrac < 0.55) and (1.45 - risk * 0.30) or (0.85 - risk * 0.20)
    if arch.OffenseStyle == 'Tank' then hpDefenseMult *= 1.25 end
    euDefend = (pReflect * uDefRef + pEvade * uDefEva + pAttack * uDefAtk + pSpeed * uDefSpd + pHold * uDefHld) * hpDefenseMult
   else
    euDefend = -2.0
   end

   -- Candidate Action C: Evade
   local canEvade = (t >= (f.cd.Dash or 0)) or (t >= (f.cd.Shield or 0))
   local euEvade
   if canEvade then
    local uHazard = (centerClear == 1) and (1.80 * dodgeChance) or 0.0
    local uEvaRef = 0.15
    local uEvaEva = 0.10
    local uEvaAtk = 1.40 * dodgeChance
    local uEvaSpd = 0.20
    local uEvaHld = 0.10
    euEvade = uHazard + (pReflect * uEvaRef + pEvade * uEvaEva + pAttack * uEvaAtk + pSpeed * uEvaSpd + pHold * uEvaHld)
   else
    euEvade = -2.0
   end

   -- Candidate Action D: SpeedBoost
   local canBoost = (t >= (f.cd.Dash or 0))
   local euBoost
   if canBoost and centerClear >= 2 then
    local uSpdRef = 1.05
    local uSpdEva = 0.85
    local uSpdAtk = 0.35 + risk * 0.35
    local uSpdSpd = 0.80
    local uSpdHld = 1.30
    local straightBonus = (centerClear >= 3) and 0.50 or 0.0
    local trailBonus = math.min(0.50, (b.distBehind or 0) * 0.015)
    local orbBonus = (#nearbyOrbs > 0) and 0.25 or 0.0
    local baseEuSpeed = (pReflect * uSpdRef + pEvade * uSpdEva + pAttack * uSpdAtk + pSpeed * uSpdSpd + pHold * uSpdHld)
    euBoost = boostBias * (baseEuSpeed + straightBonus + trailBonus + orbBonus)
   else
    euBoost = -2.0
   end

   -- Candidate Action E: Hold
   local euHold = 0.36 + (1 - risk) * 0.12

   -- 3. Select and execute optimal action with maximum expected utility
   local maxEU = math.max(euEvade, euDefend, euAttack, euBoost, euHold)
   if maxEU == euEvade and euEvade > euHold then
    b.dashDir = (b.tx >= px) and 1 or -1
    if t >= (f.cd.Dash or 0) then
     useAbility(f, 'Dash')
    elseif t >= (f.cd.Shield or 0) then
     useAbility(f, 'Shield')
    end
   elseif maxEU == euDefend and euDefend > euHold then
    if canReflect and (rng:NextNumber() < 0.65 or pReflect > 0.30) then
     useAbility(f, 'ReflectShield')
    elseif canShield then
     useAbility(f, 'Shield')
    end
   elseif maxEU == euAttack and euAttack > euHold then
    useAbility(f, ab)
   elseif maxEU == euBoost and euBoost > euHold then
    b.dashDir = (b.tx >= px) and 1 or -1
    useAbility(f, 'Dash')
    f.dashUntil = math.max(f.dashUntil or 0, t + 1.1) -- Tactical Speed Boost!
   end
  end
 end

 b.rzTimer-=dt
 if b.rzTimer<=0 then
  b.rzTimer=rng:NextNumber(1.4,3.0)
  if arch.OffenseStyle == 'Speed' then
   b.rzT = rng:NextNumber(H.Front+2, 2)
  elseif arch.OffenseStyle == 'Tank' then
   b.rzT = rng:NextNumber(0, H.Back-5)
  else
   b.rzT = rng:NextNumber(H.Front+3, H.Back-4)
  end
 end
 b.rz+=(b.rzT-b.rz)*math.min(1,dt*1.0)

 -- Competitive Bot Catch-Up (+40% Max Speed Bonus when behind leader)
 local botCatchupBonus = math.clamp(distBehindLeader * 0.0035, 0, 0.40)
 b.rz = math.clamp((b.rz or 0) - (Config.FlightSpeed * botCatchupBonus) * dt, H.Front, H.Back)

 -- Forward surge during active Dash / Tactical Speed Boost
 if t < f.dashUntilServer then
  b.rz = math.clamp((b.rz or 0) - (Config.FlightSpeed * 0.25) * dt, H.Front, H.Back)
 end
 local locked=t<f.shieldUntil
 local dvx=math.clamp((b.tx-px)*2.8,-36,36)
 local dvy=math.clamp((b.ty-py)*2.8,-28,28)
 if locked then dvx=0 dvy=0 end
 if t<f.dashUntilServer then dvx=dvx+b.dashDir*62 end
 b.vx+=(dvx-b.vx)*math.min(1,dt*4.5)
 b.vy+=(dvy-b.vy)*math.min(1,dt*4.5)
 b.kx*=math.max(0,1-3*dt) b.ky*=math.max(0,1-3*dt)
 b.lx=math.clamp(px+(b.vx+f.kx)*dt,-H.HalfWidth,H.HalfWidth)
 b.ly=math.clamp(py+(b.vy+f.ky)*dt,H.MinY,H.MaxY)
 f.kx*=math.max(0,1-3*dt) f.ky*=math.max(0,1-3*dt)
 b.pos=cf:PointToWorldSpace(Vector3.new(b.lx,b.ly,b.rz))
 f.pos=b.pos
 local roll=-(b.vx+f.kx)/45
 b.model:PivotTo(CFrame.new(b.pos)*cf.Rotation*CFrame.Angles(math.rad(-80),0,0)*CFrame.Angles(0,roll,0))
end

local function pairCheck(tt,cf)
 for i=1,#flyers-1 do
  for j=i+1,#flyers do
   local a,b=flyers[i],flyers[j]
   if a.alive and b.alive then
    local d=getPos(b)-getPos(a)
    if d.Magnitude<4.4 then
     local key=i*100+j
     if tt-(R._pairCd[key] or 0)>0.45 then
      R._pairCd[key]=tt
      local ld=cf:VectorToObjectSpace(d) local dir=Vector3.new(ld.X,ld.Y,0)
      if dir.Magnitude<0.1 then dir=Vector3.new(rng:NextNumber(-1,1),rng:NextNumber(-1,1),0) end
      dir=dir.Unit
      local sa,sb=tt<a.shieldUntil,tt<b.shieldUntil
      if sa and not sb then
       damage(b,Config.BumpDamage*2,a) knock(b,dir*70)
      elseif sb and not sa then
       damage(a,Config.BumpDamage*2,b) knock(a,-dir*70)
      elseif not sa and not sb then
       damage(a,Config.BumpDamage,b) damage(b,Config.BumpDamage,a)
       knock(a,-dir*34) knock(b,dir*34)
      end
     end
    end
   end
  end
 end
end

local function tick(tt,wt)
 local cf=getSplineFrame(wt)
 local H=Config.Box
 for _,f in flyers do
  if f.alive then
   local pos=getPos(f)
   local cfUse = f.inMultiverse and (cf + Vector3.new(0, 600, 0)) or cf
   local boxDistNow = Config.FlightSpeed * math.max(0, wt - flightStart)
   local relZProg = cfUse:PointToObjectSpace(pos).Z
   f.model:SetAttribute('TrackProgress', math.clamp((boxDistNow - relZProg) / Config.TrackLength, 0, 1))
   f.model:SetAttribute('PackOffset', math.clamp(-relZProg / 32, -1, 1))
   if f.kind=='player' then
    -- lane space: x right, y up from the spline point, z back (the client flies in the same space)
    local l=cfUse:PointToObjectSpace(pos)
    if f.model:GetAttribute('CrashState') ~= nil then
     -- Allow client spin-out crash arc freely inside box; only guard extreme escape
     if math.abs(l.X)>H.HalfWidth+25 or l.Y<H.MinY-15 or l.Y>H.MaxY+25 or l.Z<H.Front-30 or l.Z>H.Back+35 then
      local c=Vector3.new(math.clamp(l.X,-H.HalfWidth,H.HalfWidth),math.clamp(l.Y,H.MinY+2,H.MaxY),math.clamp(l.Z,H.Front,H.Back))
      local hrp=f.model:FindFirstChild('HumanoidRootPart')
      if hrp then hrp.Position=cfUse:PointToWorldSpace(c) end
     end
    elseif math.abs(l.X)>H.HalfWidth+15 or l.Y<H.MinY-8 or l.Y>H.MaxY+15 or l.Z<H.Front-25 or l.Z>H.Back+25 then
     local c=Vector3.new(math.clamp(l.X,-H.HalfWidth,H.HalfWidth),math.clamp(l.Y,H.MinY,H.MaxY),math.clamp(l.Z,H.Front,H.Back))
     pos=cfUse:PointToWorldSpace(c)
     f.model:PivotTo(CFrame.new(pos)*cfUse.Rotation*CFrame.Angles(math.rad(-80),0,0))
    end
   end
   -- Rare Multiverse Portal entry & pocket collection
   if false and multiverseActive then
    if not f.inMultiverse and not f.multiverseDone and multiversePortalPos then
     local pRel = cf:PointToObjectSpace(pos)
     local portalRel = cf:PointToObjectSpace(multiversePortalPos)
     if (pos - multiversePortalPos).Magnitude < 62 or (math.abs(pRel.Z - portalRel.Z) < 22 and math.abs(pRel.X - portalRel.X) < 58) then
      f.inMultiverse = true
      f.multiverseEnds = tt + 8.5
      f.model:SetAttribute('InMultiverse', true)
      if f.plr then
       Remotes.MultiverseWarp:FireClient(f.plr, true, 600)
       Remotes.Toast:FireClient(f.plr, 'MULTIVERSE RIFT! 3x Cosmic Coins!', 'level')
      end
     end
    elseif f.inMultiverse then
     for mi = #multiverseOrbs, 1, -1 do
      local mo = multiverseOrbs[mi]
      if mo and mo.pos and (mo.pos - pos).Magnitude < (mo.radius or 9.5) then
       table.remove(multiverseOrbs, mi)
       if mo.model and mo.model.Parent then mo.model:Destroy() end
       if f.plr then
        if mo.kind == 'MultiverseGem' then Data.Add(f.plr, 'Coins', 150) else Data.Add(f.plr, 'Coins', 60) end
        Remotes.Pickup:FireClient(f.plr, 'Ring')
       end
      end
     end
     if tt >= (f.multiverseEnds or 0) then
      f.inMultiverse = false
      f.multiverseDone = true
      f.invuln = tt + 2.0
      f.model:SetAttribute('InMultiverse', false)
      if f.plr then
       Data.Add(f.plr, 'Coins', 300)
       Remotes.MultiverseWarp:FireClient(f.plr, false, 0)
       Remotes.Toast:FireClient(f.plr, 'Multiverse Cleared! +300 Cosmic Coins!', 'good')
      end
     end
    end
   end
   if f.kind=='player' then
    -- PACE CIRCLE: ahead of the ring (z<-3) builds a streak that multiplies bonus coins; behind it (z>7) the streak decays; hitting a hazard resets it
    local lz=cf:PointToObjectSpace(pos).Z
    local pdt=math.clamp(tt-(f.paceT or tt),0,0.2) f.paceT=tt
    if lz<-10 then f.paceStreak=(f.paceStreak or 0)+pdt
    elseif lz>7 then f.paceStreak=math.max(0,(f.paceStreak or 0)-pdt*2) end
    local sk=f.paceStreak or 0
    f.paceMult=1+math.min(2,math.floor(sk/8)*0.5)
    if lz<-10 then f.paceScore=(f.paceScore or 0)+pdt*f.paceMult end
    local lvl=math.floor(sk/8)
    if lvl>(f.paceLvl or 0) and f.plr then Remotes.Toast:FireClient(f.plr,'PACE STREAK x'..string.format('%.1f',f.paceMult),'good') end
    f.paceLvl=lvl
   end
   -- hazards (skipped while soaring through the Multiverse Pocket Dimension)
   if tt>=f.invuln and trackFolder and not f.inMultiverse then
    local parts=workspace:GetPartBoundsInBox(CFrame.new(pos)*cf.Rotation,Vector3.new(6.8,6.8,6.8),hazParams)
    if #parts>0 then
     local part=parts[1]
     local lava=part:GetAttribute('Lava')
     if lava and pos.Y>O.Y+10 then
     else
      f.invuln=tt+(lava and 1.2 or 1.85)
      if tt<f.shieldUntil then
      else
       -- push away from the closest point of the thing we hit (lane space), plus a shove backwards
       local okc,near=pcall(function() return part:GetClosestPointOnSurface(pos) end)
       local lp=cf:PointToObjectSpace(pos)
       local lq=cf:PointToObjectSpace((okc and near and (near-pos).Magnitude>0.05) and near or part.Position)
       local away=Vector3.new(lp.X-lq.X,lp.Y-lq.Y,0)
       if lava then away=Vector3.new(0,1,0) end
       if away.Magnitude<0.1 then away=Vector3.new(0,1,0) end
       local curDiff = workspace:GetAttribute('Difficulty') or 'Medium'
       local diffDam = (curDiff == 'Easy' and 120) or (curDiff == 'Hard' and 260) or Config.ObstacleDamage
       local took = damage(f, lava and 60 or diffDam, nil, true)
       f.hitStamp=tt f.paceStreak=0
       if f.kind=='player' and f.alive and not f.model:GetAttribute('CrashState') then
        RagdollService.TriggerRagdoll(f.model, Config.CrashStunTime or 1.25, Vector3.new(away.Unit.X, away.Unit.Y, 1), false)
        if f.plr then Remotes.Toast:FireClient(f.plr, string.format('CRASHED! -%d HP', took or diffDam), 'bad') end
       end
      end
     end
    end
   end
   -- orbs + rings
   if f.alive then
    for i=#orbs,1,-1 do
     local o=orbs[i]
     if o.persist and f.kind=='player' and f.plr and pos.Z < o.pos.Z - 20 then
       f.ringSet = f.ringSet or {}
       if not f.ringSet[o] then
        f.ringSet[o] = 'missed'
        if (f.ringCombo or 0) > 0 then
         f.ringCombo = 0
         Remotes.RingCombo:FireClient(f.plr, 0, 1)
        end
       end
      end
      local magnetMult = (f.plr and f.plr:GetAttribute('Pass_RingMagnet')) and 1.6 or 1.0
     local rad=(o.radius or 5.5) * magnetMult
     if (o.pos-pos).Magnitude<rad then
      if o.persist then
       -- speed rings stay in the world; every flyer can collect each ring once
       f.ringSet=f.ringSet or {}
       if not f.ringSet[o] then
        local ringMult = (workspace:GetAttribute('GameMode')=='RingRush') and 2 or 1
        f.ringSet[o]=true f.rings=(f.rings or 0) + ringMult
        f.ringCombo = (f.ringCombo or 0) + 1
        local comboMult = (f.ringCombo >= 8 and 5) or (f.ringCombo >= 4 and 3) or (f.ringCombo >= 2 and 2) or 1
        if f.kind=='player' and f.plr then
         Data.Add(f.plr, 'Coins', 3 * comboMult)
         Data.AddXP(f.plr, 2 * comboMult)
         Remotes.RingCombo:FireClient(f.plr, f.ringCombo, comboMult)
         if o.kind == 'UpdraftRing' then
          f.updraftUntil = tt + 2.5
          f.model:SetAttribute('UpdraftUntil', workspace:GetServerTimeNow() + 2.5)
          f.model:SetAttribute('RefillBoost', workspace:GetServerTimeNow())
          Remotes.Pickup:FireClient(f.plr, 'UpdraftRing')
          Remotes.Toast:FireClient(f.plr, 'UPDRAFT WIND TUNNEL! +40% SPD & FULL BOOST!', 'good')
         else
          Remotes.Pickup:FireClient(f.plr, 'Ring')
         end
        end
        if f.bot then f.dashUntil=tt+0.5 end
       end
      else
       table.remove(orbs,i) o.model:Destroy()
       if o.kind=='Heal' then f.hp=math.min(Config.MaxHP,f.hp+(Config.HealOrbAmount or 180)) f.model:SetAttribute('HP',f.hp)
       elseif o.kind=='Recharge' then table.clear(f.cd)
       elseif o.kind=='Boost' then
        f.dashUntil=tt+0.8
        if f.kind=='player' and f.plr then Remotes.Knock:FireClient(f.plr,Vector3.new(0,0,-45)) end
       end
       if f.plr then Remotes.Pickup:FireClient(f.plr,o.kind) end
      end
     end
    end
    while f.passIdx<=#passMarks and pos.Z<passMarks[f.passIdx] do f.passIdx+=1 f.passes+=1 end
   end
  end
 end
 pairCheck(tt,cf)
end

local function updatePodium(list)
 local old = workspace:FindFirstChild('HubPodium')
 if old then old:Destroy() end
 if not list then list = {} end

 -- Update HubLeaderboard 3D Board SurfaceGuis with latest match standings
 local hl = workspace:FindFirstChild('Hub') and workspace.Hub:FindFirstChild('HubBuildings') and workspace.Hub.HubBuildings:FindFirstChild('HubLeaderboard')
 local boardScreen = hl and hl:FindFirstChild('BoardScreen', true)
 if boardScreen then
  for _, sg in ipairs(boardScreen:GetChildren()) do
   if sg:IsA('SurfaceGui') and sg:FindFirstChild('Board') and sg.Board:FindFirstChild('Rows') then
    local rows = sg.Board.Rows
    for i = 1, 8 do
     local row = rows:FindFirstChild('Row' .. i)
     local f = list[i]
     if row and row:FindFirstChild('Info') then
      row.Visible = (f ~= nil) or (i <= 3)
      if f then
       row.Info.Text = string.format('#%d   %s (Lv %d)   •   %d KOs   •   %ds', i, tostring(f.name), tonumber(f.level) or 1, tonumber(f.kos) or 0, math.floor(f.finish or 0))
      else
       row.Info.Text = string.format('#%d   ---', i)
      end
     end
    end
   end
  end
 end

 local rp = RaycastParams.new()
 rp.FilterType = Enum.RaycastFilterType.Include
 local mapF = workspace:FindFirstChild('Map')
 local hubF = workspace:FindFirstChild('Hub')
 local filterList = {}
 if mapF then table.insert(filterList, mapF) end
 if hubF then table.insert(filterList, hubF) end
 rp.FilterDescendantsInstances = filterList
 local hit = workspace:Raycast(Vector3.new(-846, 40, 53), Vector3.new(0, -80, 0), rp)
 local baseY = hit and hit.Position.Y or 2.0
 -- Placed right beside HubLeaderboard (-850, y, 74) and facing +X toward the Hub Plaza!
 local origin = CFrame.new(-846, baseY, 53) * CFrame.Angles(0, math.rad(-90), 0)
 workspace:SetAttribute('PodiumCamCF', CFrame.lookAt(Vector3.new(-814, baseY + 11.0, 61.5), Vector3.new(-848, baseY + 7.8, 61.5)))

 local podium = Instance.new('Model')
 podium.Name = 'HubPodium'

 local basePlat = Instance.new('Part')
 basePlat.Name = 'PodiumStage'
 basePlat.Size = Vector3.new(28, 1.2, 12)
 basePlat.CFrame = origin * CFrame.new(0, 0.6, 0)
 basePlat.Color = Color3.fromRGB(32, 38, 56)
 basePlat.Material = Enum.Material.Plastic
 -- Spotlights & Confetti Emitter on HubPodium
 local fxPart = Instance.new('Part')
 fxPart.Name = 'PodiumFX'
 fxPart.Size = Vector3.new(24, 1, 10)
 fxPart.Anchored = true; fxPart.CanCollide = false; fxPart.Transparency = 1
 fxPart.CFrame = origin * CFrame.new(0, 16, 0)
 fxPart.Parent = podium
 local sl = Instance.new('SpotLight')
 sl.Face = Enum.NormalId.Bottom; sl.Angle = 70; sl.Range = 45; sl.Brightness = 3.5; sl.Color = Color3.fromRGB(255, 240, 185)
 sl.Parent = fxPart
 local conf = Instance.new('ParticleEmitter')
 conf.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 55)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(85, 225, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 95, 185))})
 conf.Rate = 32; conf.Lifetime = NumberRange.new(2.2, 3.6); conf.Speed = NumberRange.new(6, 12); conf.SpreadAngle = Vector2.new(35, 35)
 conf.Size = NumberSequence.new(0.45); conf.RotSpeed = NumberRange.new(-180, 180)
 conf.Parent = fxPart
 basePlat.Anchored = true
 applyStuds(basePlat)
 basePlat.Parent = podium

 local specs = {
  { rank = 1, x = 0,    h = 6.2, col = Color3.fromRGB(255, 210, 45),  label = '🏆 #1 CHAMPION' },
  { rank = 2, x = -8.5, h = 4.4, col = Color3.fromRGB(210, 225, 245), label = '🥈 #2 RUNNER-UP' },
  { rank = 3, x = 8.5,  h = 3.0, col = Color3.fromRGB(215, 130, 65),  label = '🥉 #3 THIRD' },
 }

 for _, sp in ipairs(specs) do
  local ped = Instance.new('Part')
  ped.Name = 'Pedestal_' .. sp.rank
  ped.Size = Vector3.new(7.5, sp.h, 7.5)
  ped.CFrame = origin * CFrame.new(sp.x, 1.2 + sp.h * 0.5, 0)
  ped.Color = Color3.fromRGB(45, 52, 74)
  ped.Material = Enum.Material.Plastic
  ped.Anchored = true
  applyStuds(ped)
  ped.Parent = podium

  local trim = Instance.new('Part')
  trim.Name = 'Trim_' .. sp.rank
  trim.Size = Vector3.new(7.9, 0.75, 7.9)
  trim.CFrame = origin * CFrame.new(sp.x, 1.2 + sp.h - 0.3, 0)
  trim.Color = sp.col
  trim.Material = Enum.Material.Neon
  trim.Anchored = true
  trim.CanCollide = false
  applyStuds(trim)
  trim.Parent = podium

  local rankPlate = Instance.new('Part')
  rankPlate.Name = 'RankPlate_' .. sp.rank
  rankPlate.Size = Vector3.new(4.2, math.min(2.6, sp.h - 0.6), 0.3)
  rankPlate.CFrame = origin * CFrame.new(sp.x, 1.2 + sp.h * 0.45, -3.75)
  rankPlate.Color = Color3.fromRGB(24, 28, 42)
  rankPlate.Anchored = true
  rankPlate.CanCollide = false
  rankPlate.Parent = podium
  local rsg = Instance.new('SurfaceGui', rankPlate)
  rsg.Face = Enum.NormalId.Front
  local rlbl = Instance.new('TextLabel', rsg)
  rlbl.Size = UDim2.fromScale(1, 1)
  rlbl.BackgroundTransparency = 1
  rlbl.Font = Enum.Font.FredokaOne
  rlbl.TextScaled = true
  rlbl.TextColor3 = sp.col
  rlbl.Text = '#' .. tostring(sp.rank)

  local f = list[sp.rank]
  if f and f.model and f.model.Parent then
   local wasArch = f.model.Archivable
   f.model.Archivable = true
   local okC, statue = pcall(function() return f.model:Clone() end)
   f.model.Archivable = wasArch
   if okC and statue then
    statue.Name = 'Winner_' .. sp.rank
    statue:SetAttribute('Flying', false)
    statue:SetAttribute('PodiumRank', sp.rank)
    statue:SetAttribute('PodiumEmote', f.emote or 'Pose1')
    for _, d in ipairs(statue:GetDescendants()) do
     if d:IsA('BaseScript') or d.Name == 'OverheadTag' or d.Name == 'BotChat' then
      d:Destroy()
     elseif d:IsA('BasePart') then
      d.Anchored = true
      d.CanCollide = false
      d.CanTouch = false
     end
    end
    local hum = statue:FindFirstChildOfClass('Humanoid')
    if hum then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end
    local targetCf = origin * CFrame.new(sp.x, 1.2 + sp.h + 3.0, 0)
    statue:PivotTo(targetCf)
    statue:SetAttribute('PodiumBaseCF', targetCf)
    CS:AddTag(statue, 'SW_PodiumWinner')
    local wModel = statue:FindFirstChild('Wings')
    if wModel then CS:AddTag(wModel, 'WingsFx') end
    statue.Parent = podium
   end

   local signPart = Instance.new('Part')
   signPart.Name = 'Sign_' .. sp.rank
   signPart.Size = Vector3.new(1, 1, 1)
   signPart.Transparency = 1
   signPart.Anchored = true
   signPart.CanCollide = false
   signPart.CFrame = origin * CFrame.new(sp.x, 1.2 + sp.h + 7.6, 0)
   signPart.Parent = podium

   local bb = Instance.new('BillboardGui')
   bb.Size = UDim2.fromOffset(190, 58)
   bb.AlwaysOnTop = false
   bb.MaxDistance = 150
   bb.Adornee = signPart
   local txt = Instance.new('TextLabel')
   txt.Size = UDim2.fromScale(1, 1)
   txt.BackgroundColor3 = Color3.fromRGB(20, 24, 38)
   txt.BackgroundTransparency = 0.15
   txt.Font = Enum.Font.FredokaOne
   txt.TextScaled = true
   txt.TextColor3 = sp.col
   txt.Text = string.format('%s\n%s (%d KOs)', sp.label, f.name, f.kos or 0)
   Instance.new('UICorner', txt).CornerRadius = UDim.new(0, 8)
   local bst = Instance.new('UIStroke', txt)
   bst.Thickness = 2
   bst.Color = sp.col
   txt.Parent = bb
   bb.Parent = signPart
  end
 end

 podium.Parent = workspace
end

local function rankAndReward(startedAt)
 local list={}
 for _,f in flyers do table.insert(list,f) if f.alive then f.finish=math.max(0,now()-flightStart) end end
 table.sort(list,function(a,b)
  if a.alive~=b.alive then return a.alive end
  if a.alive and b.alive then if a.hp~=b.hp then return a.hp>b.hp end end
  if a.finish~=b.finish then return a.finish>b.finish end
  return a.kos>b.kos
 end)
 local ranks={}
 for i,f in list do table.insert(ranks,{Name=f.name,Kos=f.kos,Surv=math.floor(f.finish),Alive=f.alive,Level=f.level,Id=f.plr and f.plr.UserId or 0}) end
 local winner=list[1]
 for i,f in list do
  if f.plr and f.plr.Parent then
   local surv=math.floor(f.finish)
   local win=(f==winner)
   local coins=math.floor(surv*0.7)+f.kos*25+f.passes*2+(f.rings or 0)*((Config.Flight and Config.Flight.RingCoins) or 1)+math.floor((f.paceScore or 0)*0.8)+(win and 120 or 0)
   if workspace:GetAttribute('Mutator')=='GoldenFever' then coins = coins * 2 end
    if f.plr then coins = math.floor(coins * (f.plr:GetAttribute('PrestigeCoinMult') or 1)) end
   local xp=surv+f.kos*20+f.passes+(win and 60 or 0)
   local prof=Data.Get(f.plr)
   if prof then
    prof.KOs+=f.kos prof.Rounds+=1 if win then prof.Wins+=1 end
    Data.Add(f.plr,'Coins',coins) Data.AddXP(f.plr,xp)
   end
   Remotes.Results:FireClient(f.plr,{Ranks=ranks,Place=i,Coins=coins,XP=xp,Win=win,Kos=f.kos,Surv=surv,Passes=f.passes,Pace=math.floor(f.paceScore or 0)})
  end
 end
 pcall(updatePodium, list)
end

local function startFlight(map)
 table.clear(flyers) table.clear(flyerOf) R._pairCd={}
 local humans={}
 for _,p in Players:GetPlayers() do
  if p:GetAttribute('InAFK') == true then continue end
  local c=p.Character
  local hum=c and c:FindFirstChildOfClass('Humanoid')
  if (not c or not hum or hum.Health <= 0) then
   local okWait = p.CharacterAdded:Wait()
   c = p.Character
   hum = c and c:FindFirstChildOfClass('Humanoid')
  end
  if hum and hum.Health>0 and #humans<Config.MaxFlyers then table.insert(humans,p) end
 end
 local needBots=math.max(0,Config.MaxFlyers-#humans)
 for i=#bots,1,-1 do if i>needBots then bots[i].model:Destroy() table.remove(bots,i) end end
 local slots={} for i=1,Config.MaxFlyers do slots[i]=i end
 for i=#slots,2,-1 do local j=rng:NextInteger(1,i) slots[i],slots[j]=slots[j],slots[i] end
 local n=0
 local function startPos(i) return Vector3.new(O.X-19+(i-1)*(38/(Config.MaxFlyers-1)),O.Y+22,O.Z) end
 for _,p in humans do
  n+=1
  local c=p.Character
  local f=newFlyer('player',c,p,nil)
  c:SetAttribute('HP', f.maxHP or Config.MaxHP) c:SetAttribute('Flying',true) c:SetAttribute('ShieldUntil',0) c:SetAttribute('InMultiverse',false)
  local hum=c:FindFirstChildOfClass('Humanoid') hum.PlatformStand=true
  c:PivotTo(CFrame.new(startPos(slots[n]))*CFrame.Angles(math.rad(-80),0,0))
  local hrp=c:FindFirstChild('HumanoidRootPart') if hrp then hrp.AssemblyLinearVelocity=Vector3.zero end
  table.insert(flyers,f) flyerOf[p]=f
  hum.Died:Once(function() koFlyer(f) end)
 end
 for _,b in bots do
  if not b.model or not b.model.Parent then continue end
  local hrp=b.model:FindFirstChild('HumanoidRootPart')
  if not hrp then continue end
  n+=1
  local f=newFlyer('bot',b.model,nil,b)
  b.flying=true
  if b.tracks then pcall(function() b.tracks.walk:Stop() b.tracks.idle:Stop() b.tracks.fall:Play() end) end
  b.model:SetAttribute('HP', f.maxHP or Config.MaxHP) b.model:SetAttribute('Flying',true)
  hrp.Anchored=true
  b.hum.PlatformStand=true
  b.pos=startPos(slots[n]) b.vx=0 b.vy=0 b.kx=0 b.ky=0 b.rz=0 b.rzT=0 b.rzTimer=1 b.tx=0 b.ty=22 b.think=rng:NextNumber(0,0.25) b.distracted=0 b.dashDir=1 b.distBehind=0
  f.kx=0 f.ky=0 f.pos=b.pos f.dashUntilServer=0
  b.model:PivotTo(CFrame.new(b.pos)*CFrame.Angles(math.rad(-80),0,0))
  table.insert(flyers,f)
 end
 for _,f in flyers do f.dashUntilServer=0 end
 return #humans
end

 local function endFlight()
 for _,f in flyers do
  f.inMultiverse=false
  f.model:SetAttribute('Flying',false)
  f.model:SetAttribute('InMultiverse',false)
  if f.kind=='player' and f.model.Parent then
   local hum=f.model:FindFirstChildOfClass('Humanoid') if hum then hum.PlatformStand=false end
   f.model:PivotTo(HUB_SPAWN*CFrame.new(rng:NextInteger(-10,10),0,rng:NextInteger(-4,4)))
   local hrp=f.model:FindFirstChild('HumanoidRootPart') if hrp then hrp.AssemblyLinearVelocity=Vector3.zero end
  end
 end
 resetEnvironment()
 clearBots()
end

function R.Init()
 pcall(updatePodium, {})
 if not Remotes:FindFirstChild('MultiverseWarp') then
  local mw = Instance.new('RemoteEvent') mw.Name = 'MultiverseWarp' mw.Parent = Remotes
 end
 Remotes.AirDodge.OnServerEvent:Connect(function(plr)
  local f
  for _, x in ipairs(flyers) do if x.plr == plr then f = x break end end
  if not f or phase ~= 'Flight' or not f.alive then return end
  local t0 = os.clock()
  if t0 < (f.airDodgeCD or 0) then return end
  f.airDodgeCD = t0 + 3.5
  f.airDodgeUntil = t0 + 0.6
  f.model:SetAttribute('AirDodgeUntil', workspace:GetServerTimeNow() + 0.6)
  Remotes.AbilityFx:FireAllClients('Dash', f.model)
 end)
 Remotes.Ability.OnServerEvent:Connect(function(plr,name)
  if typeof(name)~='string' then return end
  local f=flyerOf[plr]
  if f then useAbility(f,name) end
 end)
 local mcRem = Remotes:FindFirstChild('ManualCrash')
 if mcRem then
  mcRem.OnServerEvent:Connect(function(plr)
   local c = plr.Character
   if not c or c:GetAttribute('CrashState') ~= nil then return end
   local f = flyerOf[plr]
   if f and f.alive and phase == 'Flight' then
    local selfDmg = math.floor((Config.CrashDamage or 175) * 0.5)
    local took = damage(f, selfDmg, nil, true)
    RagdollService.TriggerRagdoll(c, Config.CrashStunTime or 1.25, Vector3.new(rng:NextNumber(-1, 1), 0.3, 1), false)
    Remotes.Toast:FireClient(plr, string.format('CRASH DIVE! -%d HP', took or selfDmg), 'bad')
   else
    RagdollService.TriggerRagdoll(c, 0.95, Vector3.new(rng:NextNumber(-14, 14), 24, rng:NextNumber(-14, 14)), false)
   end
  end)
 end
 local ruRem = Remotes:FindFirstChild('ReadyUp')
 if ruRem then
  ruRem.OnServerEvent:Connect(function(plr)
   if phase ~= 'Intermission' then return end
   readyPlayers[plr] = not readyPlayers[plr]
   local rc, hc = 0, #Players:GetPlayers()
   for _, p in ipairs(Players:GetPlayers()) do
    if readyPlayers[p] then rc += 1 end
   end
   workspace:SetAttribute('ReadyCount', rc)
   workspace:SetAttribute('HumanCount', hc)
   Remotes.Toast:FireAllClients(plr.Name .. (readyPlayers[plr] and ' is READY! (' or ' unreadied (') .. rc .. '/' .. hc .. ')', readyPlayers[plr] and 'good' or 'info')
  end)
 end
  local mapFolder = workspace:FindFirstChild('Map')
 for i = 1, 3 do
  local pad = mapFolder and mapFolder:FindFirstChild('Pad' .. i)
  if pad then
   for _, p in ipairs(pad:GetDescendants()) do
    if p:IsA('BasePart') then
     p.Touched:Connect(function(hit)
      local c = charOf(hit)
      if c then castVote(c, i) end
     end)
    end
   end
  end
  end
 Players.PlayerRemoving:Connect(function(p)
  votes[p]=nil
  local f=flyerOf[p]
  if f then f.alive=false f.plr=nil end
  refreshVotes()
 end)
end

function R.Run()
 pcall(function() if not workspace:FindFirstChild('HubPodium') then updatePodium({}) end end)
 while true do
  votes={} readyPlayers={} refreshVotes()
  workspace:SetAttribute('ReadyCount', 0)
  workspace:SetAttribute('HumanCount', #Players:GetPlayers())
  cleanTrack()
  while #Players:GetPlayers()==0 do task.wait(1) end
  setPhase('Intermission',Config.Intermission)
  task.spawn(ensureBots)
  local t0=os.clock()
  local fastSkip=false
  while os.clock()-t0<Config.Intermission do
   task.wait(0.4)
   local ps = Players:GetPlayers()
   workspace:SetAttribute('HumanCount', #ps)
   if #ps==0 then t0=os.clock() fastSkip=false continue end
   local rc = 0
   for _, p in ipairs(ps) do if readyPlayers[p] then rc += 1 end end
   workspace:SetAttribute('ReadyCount', rc)
   if rc >= #ps and not fastSkip and (Config.Intermission - (os.clock() - t0)) > 4 then
    fastSkip = true
    t0 = os.clock() - (Config.Intermission - 3.5)
    workspace:SetAttribute('PhaseEnds', workspace:GetServerTimeNow() + 3.5)
    Remotes.Toast:FireAllClients('All Players Ready! Launching in 3.5s!', 'level')
   end
  end
  for _,b in bots do if not votes[b.model] then votes[b.model]=rng:NextInteger(1,3) end end
  local counts=refreshVotes()
  local top=0 for i=1,3 do top=math.max(top,counts[i]) end
  local choices={} for i=1,3 do if counts[i]==top then table.insert(choices,i) end end
  local map=Config.Maps[choices[rng:NextInteger(1,#choices)]]
  local modes = Config.GameModes or {{Id='SkyRoyale', Name='Sky Royale'}}
  local mode = modes[rng:NextInteger(1, #modes)]
  local muts = Config.Mutators or {{Id='Standard', Name='Clear Skies'}}
  local mut = muts[rng:NextInteger(1, #muts)]
  workspace:SetAttribute('GameMode', mode.Id)
  workspace:SetAttribute('GameModeName', mode.Name)
  workspace:SetAttribute('Mutator', mut.Id)
  workspace:SetAttribute('MutatorName', mut.Name)
  -- Lighting is now handled strictly client-side in WeatherController only for match flyers/spectators
  Remotes.Toast:FireAllClients(mode.Name .. ' | ' .. map.Name .. ' | Mutator: ' .. mut.Name, 'level')
  workspace:SetAttribute('MapId',map.Id)
  workspace:SetAttribute('MapName',map.Name) workspace:SetAttribute('MapDiff',map.Difficulty)
  buildTrack(map)
  local baseSpeed = Config.FlightSpeed * (mut.Id == 'TurboWind' and 1.22 or 1.0)
  workspace:SetAttribute('Speed', baseSpeed)
  flightStart=now()+5.4+Config.Countdown
  workspace:SetAttribute('FlightStart',flightStart)
  local humansIn=startFlight(map)
  if mode.Id == 'ChaosBounty' and #flyers > 0 then
   setBountyTarget(flyers[rng:NextInteger(1, #flyers)])
  else
   setBountyTarget(nil)
  end
  if humansIn==0 then endFlight() cleanTrack() continue end
  task.wait(0.6)
  local mutators = { "Normal", "Double Coins", "Turbo Wind", "Meteor Storm", "Low Gravity" }
  local roundMut = mutators[rng:NextInteger(1, #mutators)]
  workspace:SetAttribute('RoundMutator', roundMut)
  workspace:SetAttribute('MutatorRollSeq', (workspace:GetAttribute('MutatorRollSeq') or 0) + 1)
  setPhase('MutatorRoll', 5.4)
  task.wait(5.4)
  flightStart=now()+Config.Countdown
  workspace:SetAttribute('FlightStart',flightStart)
  setPhase('Countdown',Config.Countdown)
  task.wait(Config.Countdown)
  setPhase('Flight',Config.RoundTime)
  local last=0
  local zoneIdx=0
  local nextBolt=os.clock()+6
  local zones={
   {n='ZONE 1: Sunny Meadows & Village',c=14,br=2.4,fc=Color3.fromRGB(190,220,255),fe=3500,amb=Color3.fromRGB(140,190,240)},
   {n='ZONE 2: Stud Boulevard & Recreation',c=16.5,br=2.2,fc=Color3.fromRGB(240,210,180),fe=2800,amb=Color3.fromRGB(150,160,210)},
   {n='ZONE 3: Pirate Bay & River Waters',c=12,br=2.0,fc=Color3.fromRGB(100,180,240),fe=1800,amb=Color3.fromRGB(90,150,210)},
   {n='ZONE 4: Deep Pine Forest & Outposts',c=17.8,br=1.6,fc=Color3.fromRGB(35,65,45),fe=1200,amb=Color3.fromRGB(70,100,80)},
   {n='ZONE 5: Blizzard Tundra & Ice Camp',c=10,br=2.2,fc=Color3.fromRGB(215,235,250),fe=950,amb=Color3.fromRGB(170,200,230)},
   {n='ZONE 6: Midnight Jungle & Neon Ruins',c=18.8,br=2.0,fc=Color3.fromRGB(115,75,175),fe=2400,amb=Color3.fromRGB(150,110,210)},
  }
  local TweenService=game:GetService('TweenService')
  local LightingS=game:GetService('Lighting')
  local zoneConn=RunService.Heartbeat:Connect(function()
   local tp=math.clamp(((workspace:GetAttribute('Speed') or Config.FlightSpeed)*math.max(0,now()-flightStart))/Config.TrackLength,0,0.9999)
   local zi=math.min(6,math.floor(tp/0.16)+1)
   if zi~=zoneIdx then
    local oldZi = zoneIdx
    zoneIdx=zi
    local z=zones[zi]
    local bTypes = {'Valley', 'Park', 'WaterBay', 'Forest', 'Winter', 'Jungle'}
    workspace:SetAttribute('CurrentBiome', bTypes[zi])
    workspace:SetAttribute('Zone', z.n)
    if oldZi >= 1 and zi >= 2 and zi <= 6 then
     for _, f in ipairs(flyers) do
      if f.alive and f.hp then
       f.hp = math.min(f.maxHP or Config.MaxHP, f.hp + 250)
       if f.model then
        f.model:SetAttribute('HP', f.hp)
        local root = f.model:FindFirstChild('HumanoidRootPart')
        if root then
         pcall(function()
          AbilitySFX.PlaySound('CheckpointChime', 0.85, 1.0, root)
         end)
        end
       end
       if f.plr then Remotes.Toast:FireClient(f.plr, '+250 HP Checkpoint Heal!', 'good') end
      end
     end
    end
    -- Lighting/fog/sky are blended on the client (WeatherController); the server only picks this zone's weather event
    local pool=WeatherConfig.ZoneEvents[bTypes[zi]] or {'Standard'}
    local ev=pool[rng:NextInteger(1,#pool)]
    workspace:SetAttribute('WeatherEvent',ev)
    local evDef=WeatherConfig.Events[ev]
    if ev~='Standard' and evDef then
     for _,pl in ipairs(Players:GetPlayers()) do
  if pl:GetAttribute('InAFK') == true then continue end if (pl.Character and pl.Character:GetAttribute('Flying')==true) then Remotes.Toast:FireClient(pl,'Weather: '..evDef.Name,'info') end end
    end
    for _,pl in ipairs(Players:GetPlayers()) do if (pl.Character and pl.Character:GetAttribute('Flying')==true) then Remotes.Toast:FireClient(pl,z.n,'good') end end
   end
  end)
  local lastDecor=0
  local conn=RunService.Heartbeat:Connect(function(dt)
   local wt=now() local tt=os.clock()
   for _,mv in movers do mv(wt-flightStart) end
   if decorStreamer and tt-lastDecor>=0.25 then
    lastDecor=tt
    local okD,errD=pcall(decorStreamer.Update,math.clamp(((workspace:GetAttribute('Speed') or Config.FlightSpeed)*math.max(0,wt-flightStart))/Config.TrackLength,0,0.9999),6)
    if not okD then warn('[Round] decor stream: '..tostring(errD)) end
   end
   for _,f in flyers do
    if f.alive and f.bot then f.dashUntilServer=f.dashUntil updateBot(f,dt,tt) end
   end
   if tt-last>=0.05 then last=tt tick(tt,wt) end
  end)
  local endAt=now()+Config.RoundTime
  while true do
   task.wait(0.2)
   local alive,humanAlive=0,0
   for _,f in flyers do if f.alive then alive+=1 if f.kind=='player' and f.plr and f.plr.Parent then humanAlive+=1 end end end
   if now()>=endAt or (alive<=1 and #Players:GetPlayers()>1) then break end
  end
  conn:Disconnect() zoneConn:Disconnect()
  setPhase('Results',Config.ResultsTime)
  rankAndReward()
  endFlight()
  task.wait(Config.ResultsTime)
  table.clear(flyers) table.clear(flyerOf)
 end
end
return R
