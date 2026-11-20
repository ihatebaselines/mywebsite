-- WingsWindowController: Drives MainHUD.Windows.WingsWindow & LeftMenu WingsButton/EmotesButton
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local plr = Players.LocalPlayer
local mainHUD = script.Parent
local ww = mainHUD:WaitForChild("Windows"):WaitForChild("WingsWindow")
local body = ww:WaitForChild("Body")
local tabs = body:WaitForChild("Tabs")
local scroll = body:WaitForChild("Scroll")
local grid = scroll:WaitForChild("UIGridLayout")
local header = ww:WaitForChild("Header")
local closeBtn = header:WaitForChild("CloseButton")
local closeHit = closeBtn:FindFirstChild("HitTarget") or closeBtn:FindFirstChildWhichIsA("TextButton")
local popScale = ww:FindFirstChild("PopScale")
local openTabEvt = ww:WaitForChild("OpenTab")

local CATEGORIES = { "All", "Angelic", "Butterfly", "Demon", "Dragon", "Creature" }
local selectedCategory = "All"

local oldCatTabs = body:FindFirstChild("CategoryTabs")
if oldCatTabs then oldCatTabs:Destroy() end

local catTabsFrame = Instance.new("Frame")
catTabsFrame.Name = "CategoryTabs"
catTabsFrame.Size = UDim2.new(1, -36, 0, 30)
catTabsFrame.Position = UDim2.new(0, 18, 0, 58)
catTabsFrame.BackgroundTransparency = 1
catTabsFrame.Visible = false
catTabsFrame.ZIndex = 5
catTabsFrame.Parent = body

local catLayout = Instance.new("UIListLayout")
catLayout.FillDirection = Enum.FillDirection.Horizontal
catLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
catLayout.VerticalAlignment = Enum.VerticalAlignment.Center
catLayout.SortOrder = Enum.SortOrder.LayoutOrder
catLayout.Padding = UDim.new(0, 8)
catLayout.Parent = catTabsFrame

local catButtons = {}

local function matchesCategory(id, s, targetCat)
    if not s then return false end
    if targetCat == "All" or targetCat == nil or targetCat == "" then
        return true
    end

    local skinCat = tostring(s.Category or "")
    local skinSubCat = tostring(s.SubCategory or "")
    local name = tostring(s.Name or id)
    local lowerId = string.lower(id)
    local lowerName = string.lower(name)
    local lowerCat = string.lower(skinCat)
    local lowerSubCat = string.lower(skinSubCat)
    local targetLower = string.lower(targetCat)

    if lowerCat == targetLower or lowerSubCat == targetLower then
        return true
    end

    if targetCat == "Angelic" then
        return lowerCat:find("angel") ~= nil
            or lowerSubCat:find("angel") ~= nil
            or lowerId:find("seraph") ~= nil
            or lowerId:find("angel") ~= nil
            or lowerId:find("celestial") ~= nil
            or lowerId:find("radiant") ~= nil
            or lowerId:find("valkyrie") ~= nil
            or lowerId:find("dove") ~= nil
            or lowerName:find("seraph") ~= nil
            or lowerName:find("angel") ~= nil
            or lowerName:find("celestial") ~= nil
            or lowerName:find("dove") ~= nil
            or lowerName:find("valkyrie") ~= nil
    elseif targetCat == "Butterfly" then
        return lowerCat:find("butterfly") ~= nil
            or lowerSubCat:find("butterfly") ~= nil
            or lowerId:find("butterfly") ~= nil
            or lowerId:find("monarch") ~= nil
            or lowerId:find("moth") ~= nil
            or lowerId:find("fairy") ~= nil
            or lowerName:find("butterfly") ~= nil
            or lowerName:find("monarch") ~= nil
    elseif targetCat == "Demon" then
        return lowerCat:find("demon") ~= nil
            or lowerSubCat:find("demon") ~= nil
            or lowerId:find("demon") ~= nil
            or lowerId:find("abyssal") ~= nil
            or lowerId:find("hellfire") ~= nil
            or lowerId:find("insan") ~= nil
            or lowerId:find("void") ~= nil
            or lowerId:find("corvus") ~= nil
            or lowerId:find("daemon") ~= nil
            or lowerName:find("demon") ~= nil
            or lowerName:find("abyssal") ~= nil
            or lowerName:find("hellfire") ~= nil
    elseif targetCat == "Dragon" then
        return lowerCat:find("dragon") ~= nil
            or lowerSubCat:find("dragon") ~= nil
            or lowerId:find("dragon") ~= nil
            or lowerId:find("drake") ~= nil
            or lowerId:find("wyvern") ~= nil
            or lowerName:find("dragon") ~= nil
    elseif targetCat == "Creature" then
        return lowerCat:find("creature") ~= nil
            or lowerSubCat:find("creature") ~= nil
            or lowerId:find("bee") ~= nil
            or lowerId:find("owl") ~= nil
            or lowerId:find("griffin") ~= nil
            or lowerId:find("bat") ~= nil
            or lowerId:find("wisp") ~= nil
            or lowerId:find("phoenix") ~= nil
            or lowerId:find("animal") ~= nil
            or lowerId:find("feather") ~= nil
            or lowerName:find("bee") ~= nil
            or lowerName:find("owl") ~= nil
            or lowerName:find("griffin") ~= nil
            or lowerName:find("bat") ~= nil
    end

    return false
end

local function updateCategoryButtonsUI()
    for catName, btn in pairs(catButtons) do
        local isSel = (catName == selectedCategory)
        btn.BackgroundColor3 = isSel and Color3.fromRGB(60, 165, 255) or Color3.fromRGB(24, 30, 48)
        btn.TextColor3 = isSel and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 180, 215)
        local st = btn:FindFirstChildOfClass("UIStroke")
        if st then
            st.Color = isSel and Color3.fromRGB(150, 225, 255) or Color3.fromRGB(48, 60, 85)
            st.Thickness = isSel and 2 or 1
        end
    end
end

local Config = require(RS:WaitForChild("Shared"):WaitForChild("Config"))
local WingPreview3D = require(RS:WaitForChild("Shared"):WaitForChild("WingPreview3D"))
local Remotes = RS:WaitForChild("Remotes")
local ShopAction = Remotes:WaitForChild("ShopAction")

local TRAILS = {
	{ id = "RainbowNeon", name = "Rainbow Neon", desc = "Vibrant prism jet trail", cost = 400, cur = "Coins", col = Color3.fromRGB(255, 110, 220) },
	{ id = "SakuraPetals", name = "Sakura Petals", desc = "Floating pink blossom petals", cost = 750, cur = "Coins", col = Color3.fromRGB(255, 155, 205) },
	{ id = "ElectricLightning", name = "Electric Bolt", desc = "Crackling cyan thunder arc", cost = 1200, cur = "Coins", col = Color3.fromRGB(80, 225, 255) },
	{ id = "VoidDark", name = "Void Dark", desc = "Abyssal purple shadow wake", cost = 20, cur = "Gems", col = Color3.fromRGB(155, 65, 255) },
	{ id = "GoldenSparkle", name = "Golden Sparkle", desc = "Radiant starlight gold trail", cost = 35, cur = "Gems", col = Color3.fromRGB(255, 215, 55) },
}

local currentTab = "Wings"
local snap = {
    OwnedSkins = {}, Cases = {}, EquippedSkin = plr:GetAttribute("EquippedSkin") or "Cardboard",
    OwnedAbilities = { Slap = true }, ActiveAbility = nil,
    Coins = 0, Gems = 0, Level = 1, XP = 0, XpNeeded = 150, MaxLevel = 100, Prestige = 0, MaxPrestige = 10, XpBoostPct = 0,
}

local function applyStatsTable(s)
    if type(s) ~= "table" then return end
    snap.OwnedSkins = s.OwnedSkins or snap.OwnedSkins
    snap.Cases = s.Cases or snap.Cases
    snap.EquippedSkin = s.Skin or snap.EquippedSkin
    snap.OwnedAbilities = s.OwnedAbilities or snap.OwnedAbilities
    snap.ActiveAbility = (s.ActiveAbility and s.ActiveAbility ~= "") and s.ActiveAbility or nil
    snap.Coins = s.Coins or snap.Coins
    snap.Gems = s.Gems or snap.Gems
    snap.Level = s.Level or snap.Level
    snap.XP = s.XP or snap.XP
    snap.XpNeeded = s.XpNeeded or snap.XpNeeded
    snap.MaxLevel = s.MaxLevel or snap.MaxLevel or 100
    snap.Prestige = s.Prestige or snap.Prestige or 0
    snap.MaxPrestige = s.MaxPrestige or snap.MaxPrestige or 10
    snap.XpBoostPct = s.XpBoostPct or snap.XpBoostPct or (snap.Prestige * 10)
end

Remotes:WaitForChild("Stats").OnClientEvent:Connect(function(s)
    if type(s) == "table" then
        applyStatsTable(s)
    end
end)

local function refreshSnap()
    local ok, okRes, data = pcall(function() return ShopAction:InvokeServer("GetStats", "") end)
    if ok and okRes and type(data) == "table" then
        applyStatsTable(data)
    else
        snap.EquippedSkin = plr:GetAttribute("EquippedSkin") or snap.EquippedSkin or "Cardboard"
    end
end

local function closeWin()
    if not ww.Visible then return end
    if popScale then
        local tw = TS:Create(popScale, TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Scale = 0.85 })
        tw:Play()
        tw.Completed:Wait()
    end
    ww.Visible = false
end

local shopCardTemplate = (function()
    local sm = mainHUD:FindFirstChild("ShopMenu")
    local sf = sm and sm:FindFirstChild("Frame") and sm.Frame:FindFirstChild("ScrollingFrame")
    local mon = sf and sf:FindFirstChild("Money")
    return mon and mon:FindFirstChild("c1")
end)()

local function clearCards()
    for _, c in ipairs(scroll:GetChildren()) do
        if c:IsA("GuiObject") then c:Destroy() end
    end
end

local function makeCard(order, titleText, subText, accent, btnText, btnC, onClick, previewSpec)
    local card
    if shopCardTemplate then
        card = shopCardTemplate:Clone()
        card.Name = "ShopStyledCard_" .. order
        card.LayoutOrder = order
        card.Visible = true
        local icon = card:FindFirstChild("Icon")
        if icon then icon.Visible = false end
        local cg = card:FindFirstChildOfClass("UIGradient")
        if cg then cg.Color = ColorSequence.new(accent:Lerp(Color3.new(1,1,1), 0.72), accent:Lerp(Color3.new(1,1,1), 0.35)) end
        local is = card:FindFirstChild("InnerStroke")
        if is then
            local ig = is:FindFirstChildOfClass("UIGradient")
            if ig then ig.Color = ColorSequence.new(accent, Color3.new(1,1,1)) end
        end
        local gc = card:FindFirstChild("GlowClip")
        local glowImg = gc and gc:FindFirstChild("Glow")
        if glowImg then glowImg.ImageColor3 = accent end

        local t = card:FindFirstChild("Title")
        if t then
            t.Text = titleText
            t.Position = UDim2.new(0.5, 0, 0, 14)
            t.Size = UDim2.new(0.92, 0, 0, 24)
            t.AnchorPoint = Vector2.new(0.5, 0)
            t.ZIndex = 5
        end

        local btns = card:FindFirstChild("Btns")
        if btns then
            local gift = btns:FindFirstChild("Gift")
            if gift then gift.Visible = false end
            local buy = btns:FindFirstChild("Buy")
            if buy then
                buy.Size = UDim2.new(0.92, 0, 1, 0)
                buy.Position = UDim2.fromScale(0.5, 0.5)
                buy.AnchorPoint = Vector2.new(0.5, 0.5)
                local pat = buy:FindFirstChild("Pattern")
                local pGrad = pat and pat:FindFirstChildOfClass("UIGradient")
                if pGrad then pGrad.Color = ColorSequence.new(btnC:Lerp(Color3.new(1,1,1), 0.25), btnC) end
                local pr = buy:FindFirstChild("Price")
                if pr then pr.Text = btnText end
                buy.Activated:Connect(onClick)
            end
        end

        if previewSpec then
            local vpHolder = Instance.new("TextButton")
            vpHolder.Name = "Preview3D"
            vpHolder.Text = ""
            vpHolder.AutoButtonColor = false
            vpHolder.Position = UDim2.new(0.5, 0, 0, 42)
            vpHolder.AnchorPoint = Vector2.new(0.5, 0)
            vpHolder.Size = UDim2.new(0.88, 0, 0, 74)
            vpHolder.BackgroundColor3 = Color3.fromRGB(20, 24, 38)
            vpHolder.ZIndex = 4
            vpHolder.Parent = card
            Instance.new("UICorner", vpHolder).CornerRadius = UDim.new(0, 10)
            local vst = Instance.new("UIStroke", vpHolder)
            vst.Thickness = 2
            vst.Color = accent
            vpHolder.Activated:Connect(function()
                local pv = Remotes:FindFirstChild("PreviewWing")
                if pv then pv:FireServer(previewSpec.kind, previewSpec.id) end
            end)
            task.defer(function()
                if not vpHolder.Parent then return end
                if previewSpec.kind == "Wing" then
                    pcall(function() WingPreview3D.RenderSkin(vpHolder, previewSpec.id) end)
                else
                    pcall(function() WingPreview3D.RenderReward(vpHolder, previewSpec.kind, previewSpec.id) end)
                end
            end)
        end

        local sub = Instance.new("TextLabel", card)
        sub.BackgroundTransparency = 1
        sub.Position = previewSpec and UDim2.new(0.5, 0, 0, 118) or UDim2.new(0.5, 0, 0, 46)
        sub.AnchorPoint = Vector2.new(0.5, 0)
        sub.Size = previewSpec and UDim2.new(0.9, 0, 0, 38) or UDim2.new(0.9, 0, 0, 56)
        sub.Font = Enum.Font.GothamBold
        sub.TextSize = 11
        sub.TextWrapped = true
        sub.TextColor3 = Color3.fromRGB(25, 30, 45)
        sub.Text = subText .. (previewSpec and "\n(Click preview for 5s Hub look)" or "")
        sub.ZIndex = 5
    else
        card = Instance.new("Frame")
        card.LayoutOrder = order
        card.BackgroundColor3 = Color3.new(1, 1, 1)
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)
        local t = Instance.new("TextLabel", card)
        t.Size = UDim2.new(1, -16, 0, 24); t.Text = titleText
        local btn = Instance.new("TextButton", card)
        btn.Position = UDim2.new(0, 12, 1, -40); btn.Size = UDim2.new(1, -24, 0, 32)
        btn.BackgroundColor3 = btnC; btn.Text = btnText
        btn.Activated:Connect(onClick)
    end
    card.Parent = scroll
end

local function renderTab(tabName)
    currentTab = tabName or "Wings"
    refreshSnap()
    clearCards()

    if header:FindFirstChild("Title") then
        header.Title.Text = (currentTab == "Wings" and "WINGS LOCKER")
            or (currentTab == "Trails" and "WING TRAILS")
            or (currentTab == "Cases" and "WING CASES")
            or (currentTab == "Abilities" and "SKILLS & ABILITIES")
            or (currentTab == "Prestige" and "PRESTIGE ASCENSION")
            or "ROBLOX PREMIUM"
        if header:FindFirstChild("TitleShadow") then header.TitleShadow.Text = header.Title.Text end
    end

    for _, tb in ipairs(tabs:GetChildren()) do
        if tb:IsA("TextButton") then
            tb.TextTransparency = (tb.Name == currentTab) and 0 or 0.25
        end
    end

    if currentTab == "Wings" then
        catTabsFrame.Visible = true
        updateCategoryButtonsUI()
        scroll.Position = UDim2.new(0, 18, 0, 94)
        scroll.Size = UDim2.new(1, -36, 1, -108)

        grid.CellSize = UDim2.new(0, 212, 0, 198)
        local owned = snap.OwnedSkins or {}
        local eq = snap.EquippedSkin or plr:GetAttribute("EquippedSkin") or "Cardboard"
        local orderList = Config.SkinOrder or {}
        local idx = 0
        for _, id in ipairs(orderList) do
            local s = Config.Skins[id]
            if s and matchesCategory(id, s, selectedCategory) then
                idx += 1
                local isOwned = owned[id] == true
                local isEq = (eq == id)
                local ab = Config.WingAbilities and Config.WingAbilities[id] or "Slap"
                local abName = (Config.Abilities and Config.Abilities[ab] and Config.Abilities[ab].Name) or ab
                local wb = Config.GetWingBonus and Config.GetWingBonus(id, ab)
                local statLine = (wb and wb.Label) or "Starter"
                local sub = string.format("%s (%s)\nSkill: %s (+20%% DMG / -15%% CD)", tostring(s.Rarity or "Common"), statLine, tostring(abName))
                local btnT = isEq and "EQUIPPED"
                    or (isOwned and "EQUIP")
                    or (s.RequiresPrestige and ("PRESTIGE " .. tostring(s.RequiresPrestige)))
                    or (s.Cost and ("BUY " .. tostring(s.Cost)))
                    or (s.Rarity == "Limited" and "LIMITED STORE" or "CRATE / PERK")
                local btnC = isEq and Color3.fromRGB(70, 165, 255)
                    or (isOwned and Color3.fromRGB(60, 200, 95))
                    or (s.RequiresPrestige and Color3.fromRGB(165, 115, 255))
                    or Color3.fromRGB(255, 165, 40)
                makeCard(idx, s.Name or id, sub, s.Color or Color3.fromRGB(90, 180, 255), btnT, btnC, function()
                    if isOwned then
                        pcall(function() ShopAction:InvokeServer("EquipSkin", id) end)
                    elseif s.RequiresPrestige then
                        renderTab("Prestige")
                        return
                    elseif s.Cost then
                        pcall(function() ShopAction:InvokeServer("BuySkin", id) end)
                    end
                    task.delay(0.15, function() if ww.Visible then renderTab("Wings") end end)
                end, { kind = "Wing", id = id })
            end
        end
    else
        catTabsFrame.Visible = false
        scroll.Position = UDim2.new(0, 18, 0, 62)
        scroll.Size = UDim2.new(1, -36, 1, -76)
    end

    if currentTab == "Trails" then
        local eqTrail = plr:GetAttribute("EquippedTrail") or ""
        local ownedTrails = {}
        local okT, tRes = pcall(function() return Remotes.TrailAction:InvokeServer("Get", "") end)
        if okT and type(tRes) == "table" then
            ownedTrails = tRes.Owned or {}
            eqTrail = tRes.Equipped or eqTrail
        end
        for idx, tr in ipairs(TRAILS) do
            local isOwned = ownedTrails[tr.id] == true
            local isEq = (eqTrail == tr.id)
            local btnT = isEq and "EQUIPPED" or (isOwned and "EQUIP" or string.format("%d %s", tr.cost, string.upper(tr.cur)))
            local btnC = isEq and Color3.fromRGB(80, 145, 235) or (isOwned and Color3.fromRGB(55, 195, 105) or Color3.fromRGB(240, 155, 35))
            makeCard(idx, tr.name, tr.desc, tr.col, btnT, btnC, function()
                local act = isOwned and "Equip" or "Buy"
                pcall(function() Remotes.TrailAction:InvokeServer(act, tr.id) end)
                renderTab("Trails")
            end, nil)
        end
    elseif currentTab == "Cases" then
        grid.CellSize = UDim2.new(0, 212, 0, 198)
        local cases = snap.Cases or {}
        local order = { "SkyCase", "CyberCase", "CelestialCase" }
        for i, key in ipairs(order) do
            local tier = Config.CaseTiers and Config.CaseTiers[key]
            if tier then
                local cnt = cases[key] or 0
                local sub = string.format("Owned: %d | %s\nCost: %d %s", cnt, tostring(tier.Desc or ""), tier.UnitCoinCost or 250, tostring(tier.Currency or "Coins"))
                makeCard(i, tier.Name or key, sub, tier.Color or Color3.fromRGB(165, 95, 255), cnt > 0 and "OPEN 1x" or "BUY 1x (" .. (tier.UnitCoinCost or 250) .. ")", Color3.fromRGB(65, 205, 100), function()
                    Remotes.OpenCases:FireServer(key, 1, cnt <= 0)
                    task.delay(0.25, function() if ww.Visible then renderTab("Cases") end end)
                end, { kind = "Case", id = tier.Color or Color3.fromRGB(165, 95, 255) })
            end
        end
    elseif currentTab == "Abilities" then
        grid.CellSize = UDim2.new(0, 212, 0, 162)
        local eq = snap.EquippedSkin or plr:GetAttribute("EquippedSkin") or "Cardboard"
        local wingSig = (Config.WingAbilities and Config.WingAbilities[eq]) or "Slap"
        local ownedAb = snap.OwnedAbilities or {}
        local overrideAb = snap.ActiveAbility

        local sigDef = Config.Abilities and Config.Abilities[wingSig]
        local useWingSig = (overrideAb == nil or overrideAb == "")
        makeCard(
            0,
            "Wing: " .. ((sigDef and sigDef.Name) or wingSig),
            "[EQUIPPED WING SKILL]\n" .. tostring(sigDef and sigDef.Desc or "Signature flight power!"),
            Color3.fromRGB(90, 195, 255),
            useWingSig and "ACTIVE [E]" or "USE WING SKILL",
            useWingSig and Color3.fromRGB(55, 190, 95) or Color3.fromRGB(70, 165, 255),
            function()
                pcall(function() ShopAction:InvokeServer("EquipAbility", "Wing") end)
                task.delay(0.12, function() if ww.Visible then renderTab("Abilities") end end)
            end
        )

        local orderedIds = {}
        local seen = {}
        for _, abId in ipairs(Config.AbilityOrder or {}) do
            if Config.Abilities and Config.Abilities[abId] and not seen[abId] then
                seen[abId] = true
                table.insert(orderedIds, abId)
            end
        end
        local extraIds = {}
        for abId in pairs(Config.Abilities or {}) do
            if not seen[abId] then
                seen[abId] = true
                table.insert(extraIds, abId)
            end
        end
        table.sort(extraIds)
        for _, abId in ipairs(extraIds) do
            table.insert(orderedIds, abId)
        end

        local idx = 1
        for _, abId in ipairs(orderedIds) do
            local abInfo = Config.Abilities and Config.Abilities[abId]
            if abInfo then
                idx += 1
                local isOwned = ownedAb[abId] == true
                local isActive = (overrideAb == abId)
                local costGems = abInfo.Gems or 0
                local costCoins = abInfo.UnlockCost or 0
                local synWings = {}
                for wId, wAb in pairs(Config.WingAbilities or {}) do
                    if wAb == abId then
                        local wName = (Config.Skins and Config.Skins[wId] and Config.Skins[wId].Name) or wId
                        table.insert(synWings, wName)
                    end
                end
                table.sort(synWings)
                local synTag = (#synWings > 0) and (" • " .. synWings[1]) or ""
                local kindLabel = (costGems > 0 and ("GEMS • " .. costGems .. " Gems" .. synTag))
                    or (costCoins > 0 and ("COINS • " .. costCoins .. " Coins" .. synTag))
                    or ((#synWings > 0) and ("Wing Skill: " .. table.concat(synWings, ", ")) or "Peak Skill")
                local sub = kindLabel .. "\n" .. tostring(abInfo.Desc or "")
                local btnT, btnC
                if isActive then
                    btnT = "ACTIVE [E]"
                    btnC = Color3.fromRGB(55, 190, 95)
                elseif isOwned then
                    btnT = "EQUIP [E]"
                    btnC = Color3.fromRGB(70, 165, 255)
                elseif costGems > 0 then
                    btnT = string.format("BUY %d GEMS", costGems)
                    btnC = Color3.fromRGB(45, 195, 240)
                elseif costCoins > 0 then
                    btnT = string.format("BUY %d COINS", costCoins)
                    btnC = Color3.fromRGB(245, 170, 40)
                else
                    btnT = "UNLOCK & EQUIP [E]"
                    btnC = Color3.fromRGB(70, 165, 255)
                end
                makeCard(idx, abInfo.Name or abId, sub, abInfo.Color or Color3.fromRGB(65, 195, 255), btnT, btnC, function()
                    if isOwned then
                        pcall(function() ShopAction:InvokeServer("EquipAbility", abId) end)
                    else
                        pcall(function() ShopAction:InvokeServer("BuyAbility", abId) end)
                    end
                    task.delay(0.15, function() if ww.Visible then renderTab("Abilities") end end)
                end)
            end
        end
    elseif currentTab == "Prestige" then
        grid.CellSize = UDim2.new(0, 212, 0, 198)
        local pres = snap.Prestige or 0
        local maxP = snap.MaxPrestige or 10
        local lvl = snap.Level or 1
        local maxL = snap.MaxLevel or 100
        local boostPct = snap.XpBoostPct or (pres * 10)
        local canPrestige = (lvl >= maxL and pres < maxP)

        local statusBtnText = (pres >= maxP and ("MAX PRESTIGE " .. maxP .. "/" .. maxP))
            or (canPrestige and ("PRESTIGE NOW! (P" .. (pres + 1) .. ")"))
            or string.format("NEED LV %d (%d/%d)", maxL, lvl, maxL)
        local statusBtnCol = canPrestige and Color3.fromRGB(245, 175, 35)
            or (pres >= maxP and Color3.fromRGB(165, 95, 255) or Color3.fromRGB(110, 125, 155))
        makeCard(
            0,
            string.format("PRESTIGE %d / %d", pres, maxP),
            string.format("Lv %d/%d • +%d%% Permanent XP\nResets Lv to 1 ONLY (keeps Wings, Skills, Coins & Gems!)", lvl, maxL, boostPct),
            Color3.fromRGB(255, 195, 45),
            statusBtnText,
            statusBtnCol,
            function()
                if canPrestige then
                    pcall(function() ShopAction:InvokeServer("Prestige", "") end)
                    task.delay(0.2, function() if ww.Visible then renderTab("Prestige") end end)
                end
            end,
            { kind = "Wing", id = "Prestige" .. tostring(math.clamp(pres + 1, 1, maxP)) }
        )

        for rank = 1, maxP do
            local pId = "Prestige" .. rank
            local s = Config.Skins and Config.Skins[pId]
            if s then
                local isUnlocked = (snap.OwnedSkins and snap.OwnedSkins[pId] == true) or (pres >= rank)
                local isEq = (snap.EquippedSkin == pId)
                local btnT = isEq and "EQUIPPED" or (isUnlocked and "EQUIP WINGS" or ("PRESTIGE " .. rank))
                local btnC = isEq and Color3.fromRGB(70, 165, 255)
                    or (isUnlocked and Color3.fromRGB(60, 200, 95) or Color3.fromRGB(115, 125, 145))
                local pAb = (Config.WingAbilities and Config.WingAbilities[pId]) or "AngelAscend"
                local pAbName = (Config.Abilities and Config.Abilities[pAb] and Config.Abilities[pAb].Name) or pAb
                local sub = string.format("+%d%% XP Milestone | x%.2f Spd\nSkill: %s", rank * 10, s.SpeedMult or 1.1, tostring(pAbName))
                makeCard(rank, s.Name or pId, sub, s.Color or Color3.fromRGB(255, 200, 50), btnT, btnC, function()
                    if isUnlocked then
                        pcall(function() ShopAction:InvokeServer("EquipSkin", pId) end)
                        task.delay(0.15, function() if ww.Visible then renderTab("Prestige") end end)
                    end
                end, { kind = "Wing", id = pId })
            end
        end
    elseif currentTab == "Premium" then
        grid.CellSize = UDim2.new(0, 440, 0, 290)
        local isPrem = plr.MembershipType == Enum.MembershipType.Premium
        local sub = isPrem
            and "ACTIVE! You enjoy:\n• +25% Coins & Gems Bonus\n• +10% Bonus XP & +1 Daily Spin\n• [PREMIUM] Overhead Badge & Exclusive Stud Wings!"
            or "Unlock Roblox Premium Perks:\n• +25% Coins & Gems Bonus\n• +10% Bonus XP & +1 Daily Spin\n• [PREMIUM] Overhead Badge & Exclusive Stud Wings!"
        makeCard(1, isPrem and "ROBLOX PREMIUM ACTIVE" or "UPGRADE TO ROBLOX PREMIUM", sub, Color3.fromRGB(255, 200, 40), isPrem and "EQUIP PREMIUM WINGS" or "GET ROBLOX PREMIUM", Color3.fromRGB(255, 175, 25), function()
            if isPrem then
                pcall(function() ShopAction:InvokeServer("EquipSkin", "PremiumStud") end)
                task.delay(0.15, function() if ww.Visible then renderTab("Wings") end end)
            else
                Remotes.PromptPremium:FireServer()
            end
        end, { kind = "Wing", id = "PremiumStud" })
    end
end

local function openWin(tabName)
    for _, w in ipairs(mainHUD.Windows:GetChildren()) do
        if w:IsA("Frame") and w ~= ww then w.Visible = false end
    end
    ww.Visible = true
    if popScale then
        popScale.Scale = 0.85
        TS:Create(popScale, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
    end
    renderTab(tabName or currentTab)
end

if closeHit then closeHit.Activated:Connect(closeWin) end
workspace:GetAttributeChangedSignal("Phase"):Connect(function()
    local ph = workspace:GetAttribute("Phase")
    if ph == "Countdown" or ph == "Flight" then
        task.spawn(closeWin)
    end
end)
for _, tb in ipairs(tabs:GetChildren()) do
    if tb:IsA("TextButton") then
        tb.Activated:Connect(function() renderTab(tb.Name) end)
    end
end
for order, catName in ipairs(CATEGORIES) do
    local btn = Instance.new("TextButton")
    btn.Name = "CatTab_" .. catName
    btn.LayoutOrder = order
    btn.Size = UDim2.new(0, 84, 0, 26)
    btn.BackgroundColor3 = Color3.fromRGB(24, 30, 48)
    btn.Font = Enum.Font.FredokaOne
    btn.Text = catName
    btn.TextSize = 13
    btn.TextColor3 = Color3.fromRGB(160, 180, 215)
    btn.AutoButtonColor = true
    btn.Parent = catTabsFrame

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 8)
    bc.Parent = btn

    local bs = Instance.new("UIStroke")
    bs.Thickness = 1
    bs.Color = Color3.fromRGB(48, 60, 85)
    bs.Parent = btn

    catButtons[catName] = btn

    btn.Activated:Connect(function()
        selectedCategory = catName
        updateCategoryButtonsUI()
        renderTab("Wings")
    end)
end

openTabEvt.Event:Connect(openWin)

local wingsBtn = mainHUD.LeftMenu:WaitForChild("WingsButton")
local wingsHit = wingsBtn:FindFirstChild("HitTarget")
if wingsHit then
    wingsHit.Activated:Connect(function()
        if ww.Visible then closeWin() else openWin("Wings") end
    end)
end

local emBtn = mainHUD.LeftMenu:WaitForChild("EmotesButton")
local emHit = emBtn:FindFirstChild("HitTarget")
if emHit then
    emHit.Activated:Connect(function()
        local pg = plr:FindFirstChildOfClass("PlayerGui")
        local eg = pg and pg:FindFirstChild("EmoteGui")
        local tl = eg and eg:FindFirstChild("ToggleLocker")
        if tl and tl:IsA("BindableEvent") then tl:Fire() end
    end)
end

if Remotes:FindFirstChild("OpenShop") then
    Remotes.OpenShop.OnClientEvent:Connect(function(tab)
        if tab == "Wings" or tab == "Cases" or tab == "Abilities" or tab == "Premium" or tab == "Prestige" then
            openWin(tab)
        end
    end)
end
if Remotes:FindFirstChild("OpenPremium") then
    Remotes.OpenPremium.OnClientEvent:Connect(function()
        openWin("Premium")
    end)
end
