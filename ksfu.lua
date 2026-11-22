for _, k in ipairs({ "Y7Hub", "KSFU", "KSFUSac" }) do
    local h = getgenv()[k]
    if h and h.destroy then pcall(h.destroy) end
end

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local S = {
    enabled = false,
    sword = "CURSE",
    armed = false,
    busy = false,
    autoMine = false,
    mineAstral = false,
    startKills = 0,
}

local miningChar = nil
local lastMineActivity = os.clock()
local cutsceneAt = 0
pcall(function()
    game:GetService("ReplicatedStorage").VoidShrineCutscene.OnClientEvent:Connect(function()
        cutsceneAt = os.clock()
    end)
end)

local SHARD_RULES = { APOTHESIS = 5e7, DARKSTAR = 9e8, CURSE = 5e10 }
local STAND_MODEL = { APOTHESIS = "Apothesis", DARKSTAR = "DarkStar", CURSE = "CURSE" }
local LB_SWORD = { APOTHESIS = "Apotheosis", DARKSTAR = "DarkStar", CURSE = "Curse" }

local function fmt(n)
    if type(n) ~= "number" then return tostring(n) end
    if n >= 1e12 then return string.format("%.2ft", n / 1e12) end
    if n >= 1e9 then return string.format("%.2fb", n / 1e9) end
    if n >= 1e6 then return string.format("%.2fm", n / 1e6) end
    if n >= 1e3 then return string.format("%.1fk", n / 1e3) end
    return tostring(math.floor(n))
end

local function char()
    local c = LP.Character
    return c, c and c:FindFirstChildOfClass("Humanoid"), c and c:FindFirstChild("HumanoidRootPart")
end

local function equippedName()
    local ls = LP:FindFirstChild("leaderstats")
    local v = ls and ls:FindFirstChild("Sword")
    return v and tostring(v.Value) or nil
end

local function isEquipped()
    local cur = equippedName()
    if not cur or cur == "" then return false end
    local want = LB_SWORD[S.sword] or S.sword
    if cur:lower() == want:lower() then return true end
    local stand = STAND_MODEL[S.sword] or S.sword
    return cur:lower() == stand:lower()
end

local function sacKills()
    local ch = LP.Character
    if ch then
        local tool = ch:FindFirstChildOfClass("Tool")
        local ref = tool and tool:FindFirstChild("SwordScript")
        ref = ref and ref:FindFirstChild("KillReference")
        local nm = ref and tostring(ref.Value) or "Kills"
        local v = ch:FindFirstChild(nm)
        if v and v:IsA("ValueBase") then return tonumber(v.Value) or 0 end
        v = ch:FindFirstChild("Kills")
        if v and v:IsA("ValueBase") then return tonumber(v.Value) or 0 end
    end
    return 0
end

local function voidShards()
    local ls = LP:FindFirstChild("leaderstats")
    local v = ls and ls:FindFirstChild("VoidShards")
    return v and tonumber(v.Value) or 0
end

local protect = { active = false, ff = nil, char = nil, saved = {} }

local function clearProtection()
    protect.active = false
    if protect.ff then pcall(function() protect.ff:Destroy() end) end
    protect.ff = nil
    local ch = protect.char
    if ch then
        for nm, val in pairs(protect.saved) do
            local v = ch:FindFirstChild(nm) or (ch:FindFirstChild("Immunities") and ch.Immunities:FindFirstChild(nm))
            if v and v:IsA("BoolValue") then pcall(function() v.Value = val end) end
        end
    end
    protect.saved = {}
    protect.char = nil
end

local function applyProtection()
    local ch = LP.Character
    if not ch then return end
    if protect.active and protect.char ~= ch then clearProtection() end
    if not protect.active then
        protect.char = ch
        for _, nm in ipairs({ "CanBeKilled?", "HealthBypass", "nuhuh" }) do
            local v = ch:FindFirstChild(nm) or (ch:FindFirstChild("Immunities") and ch.Immunities:FindFirstChild(nm))
            if v and v:IsA("BoolValue") then
                protect.saved[nm] = v.Value
                v.Value = (nm == "CanBeKilled?") and false or true
            end
        end
        protect.active = true
    end
    if not protect.ff or protect.ff.Parent ~= ch then
        if protect.ff then pcall(function() protect.ff:Destroy() end) end
        protect.ff = Instance.new("ForceField")
        protect.ff.Name = "Y7FF"
        protect.ff.Visible = false
        protect.ff.Parent = ch
    end
end

local BODY = {
    ["Head"] = true, ["Torso"] = true, ["UpperTorso"] = true, ["LowerTorso"] = true,
    ["Left Arm"] = true, ["Right Arm"] = true, ["Left Leg"] = true, ["Right Leg"] = true,
    ["LeftUpperArm"] = true, ["RightUpperArm"] = true, ["LeftLowerArm"] = true, ["RightLowerArm"] = true,
    ["LeftUpperLeg"] = true, ["RightUpperLeg"] = true, ["LeftLowerLeg"] = true, ["RightLowerLeg"] = true,
    ["HumanoidRootPart"] = true,
}

local weaponCache = { char = nil, tool = nil, parts = nil }

local function weaponParts()
    local ch = LP.Character
    if not ch then
        weaponCache = { char = nil, tool = nil, parts = nil }
        return nil, nil
    end
    local tool = ch:FindFirstChildOfClass("Tool")
    if weaponCache.char == ch and weaponCache.tool == tool and weaponCache.parts then
        return weaponCache.parts, tool
    end
    local src = tool or ch
    local parts = {}
    for _, d in ipairs(src:GetDescendants()) do
        if d:IsA("BasePart") and not BODY[d.Name] and d:FindFirstChildWhichIsA("TouchTransmitter") then
            parts[#parts + 1] = d
            if #parts >= 3 then break end
        end
    end
    weaponCache = { char = ch, tool = tool, parts = parts }
    return parts, tool
end

local function ensureTool()
    local ch = LP.Character
    if not ch then return end
    if ch:FindFirstChildOfClass("Tool") then return end
    local bp = LP:FindFirstChild("Backpack")
    if not bp then return end
    local want = (LB_SWORD[S.sword] or S.sword):lower()
    local stand = (STAND_MODEL[S.sword] or S.sword):lower()
    local pick
    for _, t in ipairs(bp:GetChildren()) do
        if t:IsA("Tool") then
            local n = t.Name:lower()
            if n == want or n == stand or n:find(want, 1, true) or n:find(stand, 1, true) then
                pick = t
                break
            end
            pick = pick or t
        end
    end
    if pick then pcall(function() pick.Parent = ch end) end
end

local function equipSword()
    local map = workspace:FindFirstChild("Map")
    local f = map and map:FindFirstChild("Sword Stands")
    if not f then return false end
    local model = f:FindFirstChild(STAND_MODEL[S.sword] or "CURSE")
    local hitbox = model and model:FindFirstChild("Hitbox")
    if not (hitbox and hitbox:IsA("BasePart")) then return false end
    local _, _, hrp = char()
    if hrp then
        pcall(function() hrp.Anchored = false end)
        hrp.CFrame = CFrame.new(hitbox.Position + Vector3.new(0, 3, 0))
    end
    task.wait(0.12)
    local cd = hitbox:FindFirstChildOfClass("ClickDetector")
        or (model:FindFirstChild("Part") and model.Part:FindFirstChildOfClass("ClickDetector"))
    if cd then pcall(fireclickdetector, cd, 0, "MouseClick") end
    for _ = 1, 15 do
        task.wait(0.03)
        ensureTool()
        local ch = LP.Character
        if ch and ch:FindFirstChildOfClass("Tool") then return true end
    end
    return isEquipped()
end

local function goArena()
    local map = workspace:FindFirstChild("Map")
    local bp = map and map:FindFirstChild("BattleArenaPortal")
    if not bp then return false end
    local sum, n = Vector3.zero, 0
    for _, d in ipairs(bp:GetDescendants()) do
        if d:IsA("BasePart") then sum += d.Position; n += 1 end
    end
    if n == 0 then return false end
    local target = sum / n
    local _, _, hrp = char()
    if hrp then
        pcall(function() hrp.Anchored = false end)
        hrp.CFrame = CFrame.new(target)
        task.wait(0.15)
        hrp.CFrame = CFrame.new(target)
        if firetouchinterest then
            for _, d in ipairs(bp:GetDescendants()) do
                if d:IsA("BasePart") then
                    pcall(firetouchinterest, d, hrp, 0)
                    pcall(firetouchinterest, d, hrp, 1)
                end
            end
        end
    end
    return true
end

local function doSacrifice()
    local shrine = workspace:FindFirstChild("VO!D $HR1NE")
    local part = shrine and shrine:FindFirstChild("VoidShrinePrompt")
    if not part then return false, "shrine not found" end
    local prompt = part:FindFirstChildOfClass("ProximityPrompt")
    local before = voidShards()

    if protect.active then clearProtection() end
    local ch = LP.Character
    if ch then
        for _, p in ipairs(ch:GetChildren()) do
            if p:IsA("ForceField") then pcall(function() p:Destroy() end) end
            if p:IsA("BoolValue") and p.Name == "CanBeKilled?" then pcall(function() p.Value = true end) end
        end
        local imm = ch:FindFirstChild("Immunities")
        if imm then
            for _, p in ipairs(imm:GetChildren()) do
                if p:IsA("BoolValue") then pcall(function() p.Value = true end) end
            end
        end
    end

    local _, _, hrp = char()
    if hrp then
        pcall(function() hrp.Anchored = false end)
        hrp.CFrame = part.CFrame
        task.wait(0.2)
    end

    local livePart, livePrompt
    for _ = 1, 3 do
        livePart = shrine and shrine:FindFirstChild("VoidShrinePrompt")
        livePrompt = livePart and livePart:FindFirstChildOfClass("ProximityPrompt")
        if livePrompt then break end
        local _, _, r = char()
        if r and part then
            pcall(function() r.Anchored = false end)
            r.CFrame = CFrame.new(part.Position + Vector3.new(0, 40, 0))
        end
        task.wait(0.4)
    end
    if livePrompt then
        livePart = livePart or part
        local _, _, r = char()
        local ch2 = LP.Character
        if ch2 then
            local hum2 = ch2:FindFirstChildOfClass("Humanoid")
            if hum2 then pcall(function() hum2.PlatformStand = false end) end
            for _, p in ipairs(ch2:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
        if r and livePart then
            pcall(function() r.Anchored = false end)
            r.CFrame = livePart.CFrame
            task.wait(0.15)
            pcall(function() r.Anchored = false end)
        end
        pcall(function()
            livePrompt.Enabled = true
            livePrompt.RequiresLineOfSight = false
            livePrompt.MaxActivationDistance = 100
            livePrompt.HoldDuration = 0
        end)
        pcall(fireproximityprompt, livePrompt)

        local cutStart = os.clock()
        for _ = 1, 4 do
            local hit = false
            local t0 = os.clock()
            while os.clock() - t0 < 0.7 do
                task.wait(0.05)
                if cutsceneAt > cutStart or voidShards() > before then hit = true; break end
            end
            if hit then break end
            local _, _, r2 = char()
            if not r2 then break end
            pcall(function() r2.Anchored = false end)
            r2.CFrame = CFrame.new(part.Position + Vector3.new(0, 40, 0))
            task.wait(0.35)
            local freshPart = shrine and shrine:FindFirstChild("VoidShrinePrompt")
            local freshPrompt = freshPart and freshPart:FindFirstChildOfClass("ProximityPrompt")
            if not (freshPart and freshPrompt) then continue end
            r2.CFrame = freshPart.CFrame
            task.wait(0.15)
            pcall(function()
                freshPrompt.Enabled = true
                freshPrompt.RequiresLineOfSight = false
                freshPrompt.MaxActivationDistance = 100
                freshPrompt.HoldDuration = 0
            end)
            pcall(fireproximityprompt, freshPrompt)
        end
    end

    local after = before
    for _ = 1, 10 do
        task.wait(0.1)
        after = voidShards()
        if after > before then break end
    end
    return after > before, string.format("%s -> %s", tostring(before), tostring(after))
end
local function hitAll()
    local parts, tool = weaponParts()
    if not parts or #parts == 0 then return end
    if tool then pcall(function() tool:Activate() end) end
    local map = workspace:FindFirstChild("Map")
    if not map then return end
    for _, hm in ipairs(map:GetDescendants()) do
        if hm:IsA("Humanoid") and hm.Health > 0 then
            for _, p in ipairs(hm.Parent:GetChildren()) do
                if p:IsA("BasePart") then
                    for _, wp in ipairs(parts) do
                        pcall(firetouchinterest, wp, p, 0)
                    end
                end
            end
        end
    end
end

local function ensurePickaxe()
    local ch = LP.Character
    if not ch then return end
    if ch:FindFirstChild("Celestial Pickaxe") then return end
    local bp = LP:FindFirstChild("Backpack")
    local pick = bp and bp:FindFirstChild("Celestial Pickaxe")
    if pick then pcall(function() pick.Parent = ch end) end
end

local function equipPickaxe()
    local ch = LP.Character
    if not ch then return false end
    if ch:FindFirstChild("Celestial Pickaxe") then return true end
    local map = workspace:FindFirstChild("Map")
    local f = map and map:FindFirstChild("Sword Stands")
    local m = f and f:FindFirstChild("Celestial Pickaxe")
    local hb = m and m:FindFirstChild("Hitbox")
    if hb and hb:IsA("BasePart") then
        local _, _, hrp = char()
        if hrp then
            pcall(function() hrp.Anchored = false end)
            hrp.CFrame = CFrame.new(hb.Position + Vector3.new(0, 3, 0))
        end
        task.wait(0.12)
        local cd = hb:FindFirstChildOfClass("ClickDetector")
        if cd then pcall(fireclickdetector, cd, 0, "MouseClick") end
    end
    for _ = 1, 30 do
        task.wait(0.03)
        ensurePickaxe()
        local c2 = LP.Character
        if c2 and c2:FindFirstChild("Celestial Pickaxe") then return true end
    end
    return false
end
local function mineAll()
    local cm = game:GetService("ReplicatedStorage"):FindFirstChild("CelestialMining")
    local remote = cm and cm:FindFirstChild("MineHit")
    local stones = cm and cm:FindFirstChild("Stones")
    if not remote or not stones then return 0 end
    ensurePickaxe()
    local mined = 0
    for _, st in ipairs(stones:GetChildren()) do
        if not S.autoMine then break end
        local oreName = tostring(st:GetAttribute("Ore") or "")
        local oreMax = tonumber(st:GetAttribute("MaxHealth")) or 0
        local astral = oreMax >= 1000 or oreName:find("Astral") ~= nil or oreName:find("Cosmaline") ~= nil or oreName:find("Starsteel") ~= nil or oreName:find("Galaxine") ~= nil
        if astral and not S.mineAstral then continue end
        if st:GetAttribute("Alive") == true then
            local cf = st:GetAttribute("CFrame")
            if typeof(cf) == "CFrame" then
                local _, _, hrp = char()
                if hrp then
                    local anchor = cf.Position + Vector3.new(0, -6, 0)
                    pcall(function() hrp.Anchored = false end)
                    hrp.CFrame = CFrame.new(anchor)
                    task.wait(0.12)
                    pcall(function() hrp.Anchored = true end)
                    local maxHp = tonumber(st:GetAttribute("MaxHealth")) or 100
                    local lastHp = tonumber(st:GetAttribute("Health")) or maxHp
                    local lastDrop = os.clock()
                    local lastSync = os.clock()
                    local started = os.clock()
                    local fired = 0
                    while S.autoMine and st:GetAttribute("Alive") == true and os.clock() - started < 90 do
                        local hp = tonumber(st:GetAttribute("Health")) or 0
                        if hp < lastHp then
                            lastHp = hp
                            lastDrop = os.clock()
                        end
                        if hp <= 0 then break end
                        if os.clock() - lastDrop > 15 then break end
                        if os.clock() - lastSync > 2 then
                            hrp.CFrame = CFrame.new(anchor)
                            lastSync = os.clock()
                        end
                        pcall(function() remote:FireServer(st.Name) end)
                        mined += 1
                        lastMineActivity = os.clock()
                        fired += 1
                        if fired % 8 == 0 then
                            hrp.CFrame = CFrame.new(anchor)
                            task.wait()
                        end
                    end
                    pcall(function() hrp.Anchored = false end)
                end
            end
        end
    end
    return mined
end


local Window = Rayfield:CreateWindow({
    name = "Y7 Hub",
    configuration = { autoSave = true, autoLoad = true, fileName = "Y7Hub" },
})

local Main = Window:CreateTab({ name = "Sacrifice" })

Main:CreateToggle({
    name = "auto sacrifice",
    flag = "AutoSac",
    value = false,
    callback = function(v)
        S.enabled = v
        if not v then
            S.armed, S.busy = false, false
            if protect.active then clearProtection() end
            weaponCache = { char = nil, tool = nil, parts = nil }
        end
    end,
})

local progress

Main:CreateDropdown({
    name = "sword",
    flag = "Sword",
    options = { "CURSE", "DARKSTAR", "APOTHESIS" },
    value = "CURSE",
    callback = function(v)
        S.sword = v
        S.armed = false
        if progress then
            pcall(function() progress:SetRange(0, SHARD_RULES[v] or 5e10) end)
        end
    end,
})

progress = Main:CreateProgress({
    name = "sword kills",
    range = { 0, 5e10 },
    value = 0,
    format = function(v, _, mx) return string.format("%s / %s", fmt(v), fmt(mx)) end,
})

local status = Main:CreateText({ name = "status", text = "idle" })

Main:CreateButton({
    name = "reset cycle",
    callback = function()
        S.armed = false
        S.startKills = 0
        pcall(function() progress:Set(0) end)
    end,
})

Main:CreateButton({
    name = "unload",
    callback = function()
        pcall(function() Window:Unload() end)
    end,
})

local Mining = Window:CreateTab({ name = "Mining" })

Mining:CreateToggle({
    name = "mine astral ores",
    flag = "MineAstral",
    value = false,
    callback = function(v)
        S.mineAstral = v
    end,
})
Mining:CreateToggle({
    name = "auto mine ores",
    flag = "AutoMine",
    value = false,
    callback = function(v)
        S.autoMine = v
        if v then
            task.spawn(equipPickaxe)
        else
            local _, _, hrp = char()
            if hrp then pcall(function() hrp.Anchored = false end) end
        end
    end,
})


task.spawn(function()
    local lastArena = 0
    while not Window.unloaded do
        task.wait(0.2)
        if not S.autoMine or S.enabled or S.busy then
            miningChar = nil
            continue
        end
        local ch, hum = char()
        if not ch or not hum or hum.Health <= 0 then
            miningChar = nil
            continue
        end
        if miningChar ~= ch or not ch:FindFirstChild("Celestial Pickaxe") then
            if os.clock() - lastArena > 2 then
                lastArena = os.clock()
                S.busy = true
                if not ch:FindFirstChild("Celestial Pickaxe") then equipPickaxe() end
                goArena()
                task.wait(0.5)
                ensurePickaxe()
                S.busy = false
            end
            miningChar = ch
            continue
        end
        applyProtection()
        if hum.Health < hum.MaxHealth then pcall(function() hum.Health = hum.MaxHealth end) end
        local ok = pcall(mineAll)
        if not ok then
            miningChar = nil
            S.busy = false
        end
        if os.clock() - lastMineActivity > 12 then
            miningChar = nil
            S.busy = false
            local _, _, hr = char()
            if hr then pcall(function() hr.Anchored = false end) end
            task.spawn(function()
                equipPickaxe()
                goArena()
                task.wait(0.4)
                ensurePickaxe()
            end)
            lastMineActivity = os.clock()
        end
    end
end)


task.spawn(function()
    while not Window.unloaded do
        task.wait(0.15)
        if not S.enabled then
            pcall(function() status:Set("idle") end)
            continue
        end
        if S.busy then continue end

        local ch, hum = char()
        if not ch or not hum or hum.Health <= 0 then
            S.armed = false
            pcall(function() status:Set("respawning") end)
            continue
        end

        applyProtection()
        if hum.Health < hum.MaxHealth then pcall(function() hum.Health = hum.MaxHealth end) end

        if not S.armed then
            if not isEquipped() then
                S.busy = true
                pcall(function() status:Set("equipping " .. S.sword) end)
                local ok = equipSword()
                S.busy = false
                if not ok then
                    pcall(function() status:Set("equip failed, retrying") end)
                    task.wait(0.3)
                end
                continue
            end
            S.busy = true
            pcall(function() status:Set("entering arena") end)
            goArena()
            ensureTool()
            for _ = 1, 20 do
                local c2 = LP.Character
                if c2 and c2:FindFirstChildOfClass("Tool") then break end
                task.wait(0.03)
                ensureTool()
            end
            task.wait(0.15)
            S.startKills = sacKills()
            S.armed = true
            S.busy = false
            continue
        end

        hitAll()

        local target = SHARD_RULES[S.sword] or 5e10
        local gained = sacKills() - S.startKills
        if gained < 0 then
            S.startKills = sacKills()
            gained = 0
        end
        local wp = weaponParts()
        local relay = (wp and #wp > 0) and "relay ok" or "no weapon part"
        pcall(function() progress:Set(math.clamp(gained, 0, target)) end)
        pcall(function() status:Set(string.format("%s  %s / %s  %s", S.sword, fmt(gained), fmt(target), relay)) end)

        if gained >= target then
            S.busy = true
            pcall(function() status:Set("sacrificing") end)
            local ok, detail = doSacrifice()
            local changed = false
            local cn = LP.CharacterAdded:Once(function() changed = true end)
            local t0 = os.clock()
            while not changed and os.clock() - t0 < 10 do task.wait(0.2) end
            pcall(function() cn:Disconnect() end)
            S.armed = false
            S.startKills = 0
            weaponCache = { char = nil, tool = nil, parts = nil }
            pcall(function() progress:Set(0) end)
            if not (ok or changed) then
                pcall(function() status:Set("sacrifice failed, retrying") end)
                task.wait(1)
            end
            S.busy = false
        end
    end
end)


getgenv().Y7Hub = {
    S = S,
    destroy = function()
        S.enabled = false
        S.autoMine = false
        S.mineAstral = false
        local _, _, hr = char()
        if hr then pcall(function() hr.Anchored = false end) end
        if protect.active then clearProtection() end
        weaponCache = { char = nil, tool = nil, parts = nil }
        pcall(function() Window:Unload() end)
        getgenv().Y7Hub = nil
    end,
}
