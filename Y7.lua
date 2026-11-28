for _, k in ipairs({ "Y7Hub", "KSFU", "KSFUSac" }) do
    local h = getgenv()[k]
    if h and h.destroy then pcall(h.destroy) end
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer

getgenv().Config = {
    Invite = "Y7Hub",
    Version = "2.2",
}
getgenv().luaguardvars = getgenv().luaguardvars or {
    DiscordName = LP.Name,
}

local _sigImpl = [[(function()
    local Sig = {}
    Sig.__index = Sig
    function Sig.new()
        return setmetatable({ _conns = {} }, Sig)
    end
    function Sig:Connect(fn)
        local c = { _fn = fn, Connected = true }
        function c:Disconnect()
            self.Connected = false
        end
        self._conns[#self._conns + 1] = c
        return c
    end
    function Sig:Fire(...)
        local list = self._conns
        for i = #list, 1, -1 do
            local c = list[i]
            if not c.Connected then
                table.remove(list, i)
            else
                task.spawn(c._fn, ...)
            end
        end
    end
    function Sig:Wait()
        local co = coroutine.running()
        local cn
        cn = self:Connect(function(...)
            cn:Disconnect()
            task.spawn(co, ...)
        end)
        return coroutine.yield()
    end
    return Sig
end)()]]

local _libSrc = game:HttpGet("https://raw.githubusercontent.com/ro0ti/Roblox-Scripting-UI/main/2%20Informant.wtf%20Lib%20(FIXED)/informant.wtf%20Lib%20Source.lua")
_libSrc = _libSrc:gsub("loadstring%(game:HttpGet%('https://raw%.githubusercontent%.com/drillygzzly/Other/main/1414'%)%)%(%)", _sigImpl)
_libSrc = _libSrc:gsub("Data%s*=%s*[%w_]+%.images%.[%w_]+%s*;?", "")
_libSrc = _libSrc:gsub("proxy%[i%]%s*=%s*v", "pcall(function() proxy[i] = v end)")
local library = loadstring(_libSrc)()
library:init()
library.toggleKey = nil
local _uiReady = false

local _vp = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
local isMobile = (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled) or (_vp.X < 900)
local winW = isMobile and math.min(460, math.floor(_vp.X * 0.92)) or 580
local winH = isMobile and math.min(360, math.floor(_vp.Y * 0.82)) or 580
local winPos = isMobile and UDim2.new(0, math.floor((_vp.X - winW) * 0.5), 0, math.floor((_vp.Y - winH) * 0.5)) or nil

local Window = library.NewWindow({
    title = "Y7 HUB  |  KSFU",
    size = UDim2.new(0, winW, 0, winH),
    position = winPos,
})
pcall(function() Window:SetOpen(true) end)

local S = {
    unloaded = false,
    enabled = false,
    sword = "CURSE",
    tpSword = "CURSE",
    armed = false,
    busy = false,
    autoMine = false,
    killFarm = false,
    killAura = false,
    auraMode = "All in Range",
    auraRange = 90,
    auraPlayers = false,
    autoSwing = true,
    attackCooldown = 0.10,
    sweepRefreshRate = 0.50,
    reduceToolCd = false,
    npcHitbox = false,
    npcHitboxSize = 25,
    plrHitbox = false,
    plrHitboxSize = 18,
    swordHitbox = false,
    swordHitboxSize = 25,
    hitboxTrans = 0.7,
    mineAstral = false,
    astralOnly = false,
    mineOffset = -6,
    orePriority = {},
    antiAfk = true,
    resetOnSacrifice = true,
    stripEffects = false,
    walkSpeedOn = false,
    walkSpeed = 50,
    jumpPowerOn = false,
    jumpPower = 100,
    infJump = false,
    noclip = false,
    fly = false,
    flySpeed = 85,
    clickTp = false,
    antiVoid = false,
    noBarriers = false,
    maxZoom = false,
    fullbright = false,
    espEditCat = "Enemies",
    espProfiles = {
        Enemies = { enabled = false, boxes = true, health = true, hpSide = "Left", dist = true, font = 2, thick = 1, textSize = 13, maxDist = 1500, color = Color3.fromRGB(204, 45, 45) },
        Players = { enabled = false, boxes = true, health = true, hpSide = "Left", dist = true, font = 2, thick = 1, textSize = 13, maxDist = 1500, color = Color3.fromRGB(103, 89, 179) },
        Ores    = { enabled = false, boxes = false, health = false, hpSide = "Left", dist = true, font = 2, thick = 1, textSize = 13, maxDist = 1500, color = Color3.fromRGB(130, 190, 255) },
    },
    playerChams = false,
    chamFillTrans = 0.65,
    chamOutTrans = 0.1,
    oreEspAstral = false,
    tracerOn = false,
    tracerOrigin = "Bottom",
    tracerThick = 1.5,
    tracerCol = Color3.fromRGB(204, 45, 45),
    waypointEsp = true,
    landmarkEsp = false,
    wpIconScale = 1.0,
    wpMaxDist = 5000,
    hudEnabled = true,
    hudMining = true,
    hudShowLb = true,
    hudWidth = 252,
    hudAlpha = 1.0,
    matchTheme = true,
    hudX = isMobile and 8 or 18,
    hudY = isMobile and 44 or 60,
    colAstral = Color3.fromRGB(255, 200, 75),
    wpInputName = "Spot 1",
    wpIcon = "Diamond",
    wpColor = Color3.fromRGB(204, 45, 45),
    wpSelected = nil,
    selectedArea = nil,
    selectedPlayer = nil,
    lastSwordStand = nil,
    autoReEquip = false,
    autoPickaxePhase = false,
    pickaxePhaseState = "idle",
    swordSearch = "",
    menuKey = Enum.KeyCode.RightShift,
    riftNotify = true,
    eventAlerts = true,
    noShake = false,
    startKills = 0,
    startShards = nil,
    startLbKills = nil,
    sessionStart = os.clock(),
    mineState = "idle",
}

local function notify(msg, dur, col)
    pcall(function()
        library:SendNotification(tostring(msg), dur or 3, col or (library.theme and library.theme["Accent"]) or Color3.fromRGB(204, 45, 45))
    end)
end

local function themeCol(key, fallback)
    local t = library and library.theme
    if t and t[key] then return t[key] end
    return fallback
end

local miningChar = nil
local conns = {}
local function addConn(c)
    if c then conns[#conns + 1] = c end
    return c
end

local afkConn
local function startAntiAfk()
    if afkConn then return end
    local ok, vu = pcall(function() return game:GetService("VirtualUser") end)
    if not ok or not vu then return end
    afkConn = LP.Idled:Connect(function()
        if not S.antiAfk then return end
        pcall(function()
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end)
    end)
end
task.spawn(startAntiAfk)

local lastKillAdvance = os.clock()
local lastMineActivity = os.clock()
local cutsceneAt = 0
pcall(function()
    addConn(ReplicatedStorage.VoidShrineCutscene.OnClientEvent:Connect(function()
        cutsceneAt = os.clock()
    end))
end)

local SHARD_RULES = { APOTHESIS = 5e7, DARKSTAR = 1e9, CURSE = 5e10 }
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

local killRefCache = { char = nil, ref = nil }

local function killReference()
    local ch = LP.Character
    if not ch then
        killRefCache = { char = nil, ref = nil }
        return nil
    end
    if killRefCache.char == ch then return killRefCache.ref end
    local ref
    local tool = ch:FindFirstChildOfClass("Tool")
    if tool then
        for _, d in ipairs(tool:GetDescendants()) do
            if d:IsA("ObjectValue") and d.Name == "KillReference" then ref = d; break end
        end
    end
    killRefCache = { char = ch, ref = ref }
    return ref
end

local function sacKills()
    local ch = LP.Character
    if ch then
        local ref = killReference()
        local nm = ref and ref.Value and tostring(ref.Value) or "Kills"
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

local function sessionShards()
    local cur = voidShards()
    if S.startShards == nil then S.startShards = cur end
    local earned = math.max(0, cur - S.startShards)
    local elapsedHrs = math.max(1 / 60, (os.clock() - S.sessionStart) / 3600)
    local rate = earned / elapsedHrs
    return cur, earned, rate
end

local function sessionLbKills()
    local ls = LP:FindFirstChild("leaderstats")
    local v = ls and ls:FindFirstChild("Kills")
    local cur = v and tonumber(v.Value) or 0
    if S.startLbKills == nil then S.startLbKills = cur end
    local earned = math.max(0, cur - S.startLbKills)
    local elapsedHrs = math.max(1 / 60, (os.clock() - S.sessionStart) / 3600)
    local rate = earned / elapsedHrs
    return cur, earned, rate
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
    if weaponCache.char == ch and weaponCache.tool == tool and weaponCache.parts and #weaponCache.parts > 0 then
        for i = 1, #weaponCache.parts do
            if weaponCache.parts[i].Parent then return weaponCache.parts, tool end
        end
        weaponCache = { char = nil, tool = nil, parts = nil }
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

local function toolMatches(t)
    local n = t.Name:lower()
    local want = (LB_SWORD[S.sword] or S.sword):lower()
    local stand = (STAND_MODEL[S.sword] or S.sword):lower()
    return n == want or n == stand or n:find(want, 1, true) ~= nil or n:find(stand, 1, true) ~= nil
end

local function hasTool()
    local ch = LP.Character
    if not ch then return false end
    return ch:FindFirstChildOfClass("Tool") ~= nil
end

local function isPickaxe(t)
    return t.Name:lower():find("pickaxe", 1, true) ~= nil
end

local function ensureTool(strict)
    local ch = LP.Character
    if not ch then return end
    local bp = LP:FindFirstChild("Backpack")
    if strict then
        for _, t in ipairs(ch:GetChildren()) do
            if t:IsA("Tool") and toolMatches(t) then
                local humEq = ch:FindFirstChildOfClass("Humanoid")
                if humEq then pcall(function() humEq:EquipTool(t) end) end
                return
            end
        end
    else
        if ch:FindFirstChildOfClass("Tool") then return end
    end
    if not bp then return end
    local pick
    for _, t in ipairs(bp:GetChildren()) do
        if t:IsA("Tool") and not isPickaxe(t) then
            if toolMatches(t) then pick = t; break end
            pick = pick or t
        end
    end
    if not pick then
        for _, t in ipairs(ch:GetChildren()) do
            if t:IsA("Tool") and not isPickaxe(t) then pick = t; break end
        end
    end
    if pick then
        if pick.Parent ~= ch then pcall(function() pick.Parent = ch end) end
        local humEq = ch:FindFirstChildOfClass("Humanoid")
        if humEq then pcall(function() humEq:EquipTool(pick) end) end
    end
end

local function untilTrue(delay, fn)
    while not S.unloaded do
        local ok, res = pcall(fn)
        if ok and res then return true end
        task.wait(delay or 0.1)
    end
    return false
end

local function equipStandExact(standName)
    local cd = standCdMap and standCdMap[standName]
    if not (cd and cd.Parent) then
        local map = Workspace:FindFirstChild("Map")
        local f = map and map:FindFirstChild("Sword Stands")
        local model = f and f:FindFirstChild(standName)
        local hitbox = model and (model:FindFirstChild("Hitbox") or model:FindFirstChildWhichIsA("BasePart", true))
        cd = hitbox and hitbox:FindFirstChildOfClass("ClickDetector") or (model and model:FindFirstChildWhichIsA("ClickDetector", true))
    end
    if not (cd and cd.Parent) then return false end
    pcall(fireclickdetector, cd, 0, "MouseClick")
    return true
end

local function equipSword(swordKey)
    local key = swordKey or S.sword
    local map = Workspace:FindFirstChild("Map")
    local f = map and map:FindFirstChild("Sword Stands")
    if not f then return false end
    local model = f:FindFirstChild(STAND_MODEL[key] or key or "CURSE")
    local hitbox = model and (model:FindFirstChild("Hitbox") or model:FindFirstChildWhichIsA("BasePart", true))
    if not (hitbox and hitbox:IsA("BasePart")) then return false end
    local cd = hitbox:FindFirstChildOfClass("ClickDetector") or model:FindFirstChildWhichIsA("ClickDetector", true)
    if not cd then return false end
    pcall(fireclickdetector, cd, 0, "MouseClick")
    for _ = 1, 30 do
        task.wait(0.03)
        ensureTool(true)
        if hasTool() then return true end
    end
    if isEquipped() then return true end
    local _, _, hrp = char()
    if hrp then
        pcall(function() hrp.Anchored = false end)
        hrp.CFrame = CFrame.new(hitbox.Position + Vector3.new(0, 3, 0))
        task.wait(0.1)
        pcall(fireclickdetector, cd, 0, "MouseClick")
        for _ = 1, 30 do
            task.wait(0.03)
            ensureTool(true)
            if hasTool() then return true end
        end
    end
    return isEquipped()
end

local function portalTrigger(bp)
    local tel = bp:FindFirstChild("Teleporter")
    if not tel then
        local portal = bp:FindFirstChild("Portal")
        tel = portal and portal:FindFirstChild("Teleporter")
    end
    if tel and tel:IsA("BasePart") then return tel end
    return nil
end

local function touchPortal(bp, releaseToo)
    local _, _, hrp = char()
    if not hrp or not firetouchinterest then return false end
    local tel = portalTrigger(bp)
    local list = {}
    if tel then
        list[1] = tel
        local rng = tel:FindFirstChild("Range")
        if rng and rng:IsA("BasePart") then list[#list + 1] = rng end
    else
        for _, d in ipairs(bp:GetDescendants()) do
            if d:IsA("BasePart") then list[#list + 1] = d end
        end
    end
    for _, part in ipairs(list) do
        pcall(firetouchinterest, part, hrp, 0)
        if releaseToo then pcall(firetouchinterest, part, hrp, 1) end
    end
    return #list > 0
end

local function tpPos(pos)
    local _, _, hrp = char()
    if not hrp or not pos then return false end
    pcall(function() hrp.Anchored = false end)
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 4, 0))
    return true
end

local function goArena()
    local map = Workspace:FindFirstChild("Map")
    local bp = map and map:FindFirstChild("BattleArenaPortal")
    if not bp then return false end
    local tel = portalTrigger(bp)
    local target
    if tel then
        target = tel.Position + Vector3.new(0, 3, 0)
    else
        local sum, n = Vector3.zero, 0
        for _, d in ipairs(bp:GetDescendants()) do
            if d:IsA("BasePart") then sum += d.Position; n += 1 end
        end
        if n == 0 then return false end
        target = sum / n
    end
    local _, _, hrp = char()
    if not hrp then return false end
    pcall(function() hrp.Anchored = false end)
    hrp.CFrame = CFrame.new(target)
    task.wait(0.05)
    touchPortal(bp, true)
    return true
end

local function goStand(key)
    local map = Workspace:FindFirstChild("Map")
    local f = map and map:FindFirstChild("Sword Stands")
    if not f then return false end
    local model = f:FindFirstChild(STAND_MODEL[key] or key)
    local hb = model and (model:FindFirstChild("Hitbox") or model:FindFirstChildWhichIsA("BasePart", true))
    return hb and tpPos(hb.Position) or false
end

local function goShrine()
    local shrine = Workspace:FindFirstChild("VO!D $HR1NE")
    local part = shrine and shrine:FindFirstChild("VoidShrinePrompt")
    return part and tpPos(part.Position) or false
end

local function destinyShards()
    local sh = LP:FindFirstChild("Shards")
    local v = sh and sh:FindFirstChild("DestinyShards")
    return v and tonumber(v.Value) or 0
end

local function tpDestinyShard()
    for _, child in ipairs(Workspace:GetChildren()) do
        if child.Name == "ShardModel" or child:FindFirstChild("DestinyShard") then
            local p = child:FindFirstChild("DestinyShard") or (child:IsA("BasePart") and child or child:FindFirstChildWhichIsA("BasePart", true))
            if p and p:IsA("BasePart") and tpPos(p.Position) then
                return true, "Spawned Destiny Shard"
            end
        end
    end
    local spawners = Workspace:FindFirstChild("ShardSpawners")
    if spawners then
        for _, child in ipairs(spawners:GetChildren()) do
            if not child.Name:match("^ShardSpawn%d*$") then
                local p = child:IsA("BasePart") and child or child:FindFirstChildWhichIsA("BasePart", true)
                if p and tpPos(p.Position) then return true, "Spawned Destiny Shard" end
            end
        end
    end
    return false, "Destiny Shard is not spawned right now!"
end

-- Enemy-only Area Teleports (deduplicated, accurate KSFU zones)
local WIKI_ZONE_NAMES = {
    ["Dummies"] = "Dummy Kingdom",
    ["Castle Dummies"] = "Dummy Castle",
    ["Noobs"] = "Noob Kingdom",
    ["Empowered Noobs"] = "Empowered Noob Kingdom",
    ["Classics"] = "Classic Kingdom",
    ["Guests"] = "Guest Kingdom",
    ["Sand"] = "Desert Castle",
    ["Zombies"] = "Zombie Kingdom",
    ["Magmatics"] = "Volcano / Lava Area",
    ["CORRUPTED"] = "Corrupted Kingdom",
    ["Bacons"] = "Bacon Kingdom",
    ["Voids"] = "Void Kingdom",
    ["Abyssals"] = "Abyssal Area",
    ["ETERNALISTS"] = "Eternalists Area",
    ["Souls"] = "Souls Area",
    ["Astrals"] = "Astral Pink Island",
}

local areaMap = {}
local areaNames = {}
local areaPositions = {}

local function registerArea(dispName, pos, fn)
    for _, prev in ipairs(areaPositions) do
        if (prev - pos).Magnitude < 60 then return end
    end
    if areaMap[dispName] then return end
    areaPositions[#areaPositions + 1] = pos
    areaMap[dispName] = fn
    areaNames[#areaNames + 1] = dispName
end

local function addEnemyFolder(folder, customName)
    if not folder then return end
    local sum, cnt = Vector3.zero, 0
    for _, m in ipairs(folder:GetChildren()) do
        local r = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChildWhichIsA("BasePart")
        local hm = m:FindFirstChildOfClass("Humanoid")
        if r and hm and hm.Health > 0 then
            sum += r.Position
            cnt += 1
        end
    end
    if cnt > 0 then
        local dispName = customName or WIKI_ZONE_NAMES[folder.Name] or folder.Name
        local pos = sum / cnt
        registerArea(dispName, pos, function()
            if folder.Parent then
                for _, m in ipairs(folder:GetChildren()) do
                    local r = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChildWhichIsA("BasePart")
                    local hm = m:FindFirstChildOfClass("Humanoid")
                    if r and hm and hm.Health > 0 then return tpPos(r.Position) end
                end
            end
            return tpPos(pos)
        end)
    end
end

local function buildAreaList()
    table.clear(areaMap)
    table.clear(areaNames)
    table.clear(areaPositions)
    local map = Workspace:FindFirstChild("Map")
    local hf = map and map:FindFirstChild("Humanoids")
    if hf then
        for _, folder in ipairs(hf:GetChildren()) do
            if folder:IsA("Folder") then
                if folder.Name == "Dimensional Beings" then
                    for _, m in ipairs(folder:GetChildren()) do
                        local r = m:FindFirstChild("HumanoidRootPart")
                        local hm = m:FindFirstChildOfClass("Humanoid")
                        if r and hm and hm.Health > 0 then
                            local clean = m.Name:gsub("\n.*", ""):gsub("%s+$", "")
                            local pos = r.Position
                            registerArea(clean, pos, function()
                                return tpPos(r.Parent and r.Position or pos)
                            end)
                        end
                    end
                else
                    addEnemyFolder(folder)
                end
            end
        end
    end
    if map then
        local main = map:FindFirstChild("Main")
        local realms = main and main:FindFirstChild("Realms")
        local astral = realms and realms:FindFirstChild("Astral")
        local pink = astral and astral:FindFirstChild("Pink Island")
        addEnemyFolder(pink and pink:FindFirstChild("Astrals"), "Astral Pink Island")
    end
    table.sort(areaNames)
    if #areaNames == 0 then
        areaNames[1] = "none"
    end
    S.selectedArea = areaNames[1]
end
buildAreaList()

-- All Swords List from Sword Stands + Extra Map Stands
local allStandNames = {}
local standCdMap = {}
local function addStandRef(dispName, node)
    if not node then return end
    local hb = node:FindFirstChild("Hitbox")
    local cd = (hb and hb:FindFirstChildOfClass("ClickDetector"))
        or (node:IsA("ClickDetector") and node)
        or node:FindFirstChildWhichIsA("ClickDetector", true)
    if cd and not standCdMap[dispName] then
        standCdMap[dispName] = cd
        allStandNames[#allStandNames + 1] = dispName
    end
end

local function buildSwordStandList()
    table.clear(allStandNames)
    table.clear(standCdMap)
    local map = Workspace:FindFirstChild("Map")
    local stands = map and map:FindFirstChild("Sword Stands")
    if stands then
        for _, m in ipairs(stands:GetChildren()) do
            addStandRef(m.Name, m)
        end
    end
    if map then
        local lobby = map:FindFirstChild("The Lobby")
        addStandRef("Hiemal", lobby and lobby:FindFirstChild("Hiemal (The sword that lets you access frigid when you max it)"))
        local rag = map:FindFirstChild("RAGNAROKROOM")
        addStandRef("Ragnarok", rag and rag:FindFirstChild("Ragnarok(DONT DELETE TIS)"))
    end
    local cyber = Workspace:FindFirstChild("CYBER LABORATORY")
    if cyber then
        addStandRef("EXOVOID", cyber:FindFirstChild("EXOVOID"))
        addStandRef("EXOCALAMITY", cyber:FindFirstChild("EXOCALAMITY"))
    end
    local dr = Workspace:FindFirstChild("DestinyRealm")
    local dStand = dr and dr:FindFirstChild("Map") and dr.Map:FindFirstChild("DestinyStand")
    addStandRef("Destiny", dStand and dStand:FindFirstChild("Destiny"))
    local doom = Workspace:FindFirstChild("DOOM")
    addStandRef("doom sword", doom and doom:FindFirstChild("doom sword"))
    local voidF = Workspace:FindFirstChild("Void")
    addStandRef("Void", voidF and voidF:FindFirstChild("Sword"))
    addStandRef("Instant Star", Workspace:FindFirstChild("Instant Star"))
    addStandRef("Monarchy", Workspace:FindFirstChild("Monarchy"))
    addStandRef("Instant Star CS", Workspace:FindFirstChild("Instant Star CS"))
    do
        local temModel = stands and stands:FindFirstChild("THE EXISTENTIAL MASSACRE")
        if temModel then
            local temPos = temModel:GetPivot().Position
            local bestCd, bestDist
            for _, c in ipairs(Workspace:GetChildren()) do
                if c.Name == "Hitbox" and c:IsA("BasePart") then
                    local cd = c:FindFirstChildOfClass("ClickDetector")
                    if cd then
                        local d = (c.Position - temPos).Magnitude
                        if d < 100 and (not bestDist or d < bestDist) then
                            bestDist = d
                            bestCd = cd
                        end
                    end
                end
            end
            if bestCd then
                addStandRef("THE EXISTENTIAL MASSACRE", bestCd)
            end
        end
    end

    table.sort(allStandNames, function(a, b) return a:lower() < b:lower() end)
    if #allStandNames == 0 then allStandNames[1] = "CURSE" end
end
buildSwordStandList()

local pickaxePhases = nil
pcall(function()
    local m = ReplicatedStorage:FindFirstChild("CelestialPickaxePhases")
    if m then pickaxePhases = require(m) end
end)

local function totalInventoryOres()
    local inv = LP:FindFirstChild("Inventory")
    if not inv then return 0 end
    local sum = 0
    for _, v in ipairs(inv:GetChildren()) do
        if v:IsA("ValueBase") and v.Name:sub(1, 3) == "Ore" then
            sum += (tonumber(v.Value) or 0)
        end
    end
    return sum
end

local function matchStandForEquipped(eq)
    if not eq or eq == "" then return nil end
    local low = eq:lower()
    for _, nm in ipairs(allStandNames) do
        if nm:lower() == low then return nm end
    end
    if low == "apotheosis" then
        for _, nm in ipairs(allStandNames) do
            if nm:lower() == "apothesis" then return nm end
        end
    end
    for _, nm in ipairs(allStandNames) do
        if nm:lower():find(low, 1, true) or low:find(nm:lower(), 1, true) then
            return nm
        end
    end
    return nil
end

local function hopShrine()
    local shrine = Workspace:FindFirstChild("VO!D $HR1NE")
    local part = shrine and shrine:FindFirstChild("VoidShrinePrompt")
    if not part then return false end
    return untilTrue(0.03, function()
        local _, _, hrp = char()
        if not hrp then return false end
        if (hrp.Position - part.Position).Magnitude <= 15 then return true end
        pcall(function() hrp.Anchored = false end)
        hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
        return false
    end)
end

local function doSacrifice()
    local shrine = Workspace:FindFirstChild("VO!D $HR1NE")
    local part = shrine and shrine:FindFirstChild("VoidShrinePrompt")
    if not part then return false, "shrine not found" end
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
    if hrp and (hrp.Position - part.Position).Magnitude > 12 then
        pcall(function() hrp.Anchored = false; hrp.AssemblyLinearVelocity = Vector3.zero end)
        hrp.CFrame = part.CFrame
        task.wait(0.1)
    end

    local livePart, livePrompt
    while not S.unloaded do
        livePart = shrine and shrine:FindFirstChild("VoidShrinePrompt")
        livePrompt = livePart and livePart:FindFirstChildOfClass("ProximityPrompt")
        if livePrompt then break end
        local _, _, r = char()
        if r and part then
            pcall(function() r.Anchored = false end)
            r.CFrame = CFrame.new(part.Position + Vector3.new(0, 40, 0))
        end
        task.wait(0.2)
    end
    local cutStart = 0
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
            task.wait(0.1)
            pcall(function() r.Anchored = false end)
        end
        pcall(function()
            livePrompt.Enabled = true
            livePrompt.RequiresLineOfSight = false
            livePrompt.MaxActivationDistance = 100
            livePrompt.HoldDuration = 0
        end)
        pcall(fireproximityprompt, livePrompt)

        cutStart = os.clock()
        local waitEnd = os.clock() + 1.0
        while os.clock() < waitEnd and not S.unloaded do
            if cutsceneAt > cutStart or voidShards() > before then break end
            local _, humNow = char()
            if not humNow or humNow.Health <= 0 then break end
            task.wait()
        end
        while not S.unloaded do
            if cutsceneAt > cutStart or voidShards() > before then break end
            local _, humNow = char()
            if not humNow or humNow.Health <= 0 then break end
            local _, _, r2 = char()
            if not r2 then break end
            pcall(function() r2.Anchored = false; r2.AssemblyLinearVelocity = Vector3.zero end)
            r2.CFrame = CFrame.new(part.Position + Vector3.new(0, 40, 0))
            task.wait(0.4)
            local chNow = LP.Character
            if chNow then
                for _, p in ipairs(chNow:GetChildren()) do
                    if p:IsA("ForceField") then pcall(function() p:Destroy() end) end
                    if p:IsA("BoolValue") and p.Name == "CanBeKilled?" then pcall(function() p.Value = true end) end
                end
            end
            local freshPart = shrine and shrine:FindFirstChild("VoidShrinePrompt")
            local freshPrompt = freshPart and freshPart:FindFirstChildOfClass("ProximityPrompt")
            if freshPart and freshPrompt then
                pcall(function() r2.AssemblyLinearVelocity = Vector3.zero end)
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
            local retryEnd = os.clock() + 1.0
            while os.clock() < retryEnd and not S.unloaded do
                if cutsceneAt > cutStart or voidShards() > before then break end
                local _, h2 = char()
                if not h2 or h2.Health <= 0 then break end
                task.wait(0.1)
            end
        end
    end

    local after = voidShards()
    if after > before then
        return true, string.format("%s -> %s", tostring(before), tostring(after))
    end
    if cutStart > 0 and cutsceneAt > cutStart then
        return true, "cutscene fired"
    end
    return false, string.format("%s -> %s", tostring(before), tostring(after))
end

local ARENA_MIN_Y = 1000
local ARENA_MAX_Y = 1700
local NPC_AGE = 0.4

local npcCache = { at = 0, list = {}, containers = nil }

local function findContainers()
    local map = Workspace:FindFirstChild("Map")
    local out, seen = {}, {}
    if not map then return out end
    local function consider(node)
        if seen[node] then return end
        for _, m in ipairs(node:GetChildren()) do
            if m:FindFirstChildOfClass("Humanoid") then
                seen[node] = true
                out[#out + 1] = node
                return
            end
        end
    end
    for _, a in ipairs(map:GetChildren()) do
        consider(a)
        for _, b in ipairs(a:GetChildren()) do
            consider(b)
            for _, c in ipairs(b:GetChildren()) do consider(c) end
        end
    end
    return out
end

local function npcList(maxAge)
    local now = os.clock()
    if maxAge and (now - npcCache.at) < maxAge then return npcCache.list end
    if not npcCache.containers or #npcCache.containers == 0 then
        npcCache.containers = findContainers()
    end
    local t = {}
    local live = 0
    for _, c in ipairs(npcCache.containers) do
        if c.Parent then
            live += 1
            for _, m in ipairs(c:GetChildren()) do
                local hm = m:FindFirstChildOfClass("Humanoid")
                if hm and hm.Health > 0 then
                    local r = m:FindFirstChild("HumanoidRootPart")
                    if r then
                        t[#t + 1] = {
                            model = m,
                            name = m.Name:gsub("\n", " "),
                            hum = hm,
                            root = r,
                            torso = m:FindFirstChild("UpperTorso") or m:FindFirstChild("Torso"),
                        }
                    end
                end
            end
        end
    end
    if live == 0 then npcCache.containers = findContainers() end
    npcCache.at = now
    npcCache.list = t
    return t
end

local sweep = { at = 0, fireAt = 0, parts = {} }

local function sweepCollect(model, out)
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    local r = model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("UpperTorso")
        or model:FindFirstChild("Torso")
        or model:FindFirstChildWhichIsA("BasePart")
    if r then out[#out + 1] = r end
end

local function sweepRefresh()
    local out = {}
    local map = Workspace:FindFirstChild("Map")
    local root = (map and map:FindFirstChild("Humanoids")) or map
    if root then
        for _, hm in ipairs(root:GetDescendants()) do
            if hm:IsA("Humanoid") and hm.Health > 0 and hm.Parent then
                sweepCollect(hm.Parent, out)
            end
        end
    end
    sweep.parts = out
    sweep.at = os.clock()
end

local function sweepFire(parts)
    local list = sweep.parts
    local wpn = #parts
    if #list == 0 or not firetouchinterest or wpn == 0 then return 0 end
    local n = 0
    pcall(function()
        for i = 1, #list do
            local p = list[i]
            if p.Parent then
                for w = 1, wpn do
                    firetouchinterest(parts[w], p, 0)
                    firetouchinterest(parts[w], p, 1)
                end
                n += 1
            end
        end
    end)
    return n
end

local function applyToolCd(tool)
    if not S.reduceToolCd or not tool then return end
    pcall(function() tool.Enabled = true end)
    for _, d in ipairs(tool:GetDescendants()) do
        if d:IsA("NumberValue") or d:IsA("IntValue") then
            local nl = d.Name:lower()
            if nl:find("cooldown") or nl:find("debounce") or nl == "cd" then
                pcall(function() d.Value = math.min(d.Value, S.attackCooldown) end)
            end
        end
    end
end

local function hitAll()
    local parts, tool = weaponParts()
    if not parts or #parts == 0 then return 0 end
    local now = os.clock()
    if now - sweep.at > (S.sweepRefreshRate or 0.5) then
        sweepRefresh()
    end
    local cd = math.max(0.01, S.attackCooldown or 0.10)
    if now - sweep.fireAt >= cd then
        sweep.fireAt = now
        applyToolCd(tool)
        if S.autoSwing and tool then
            pcall(function() tool:Activate() end)
        end
        return sweepFire(parts)
    end
    return #sweep.parts
end

local function hitNearby(range)
    local parts, tool = weaponParts()
    local _, _, hrp = char()
    if not parts or #parts == 0 or not hrp or not firetouchinterest then return 0 end
    local now = os.clock()
    local cd = math.max(0.01, S.attackCooldown or 0.10)
    if now - sweep.fireAt < cd then return 0 end
    sweep.fireAt = now
    applyToolCd(tool)
    if S.autoSwing and tool then
        pcall(function() tool:Activate() end)
    end
    local pos = hrp.Position
    local candidates = {}
    local list = npcList(0.25)
    for i = 1, #list do
        local item = list[i]
        if item.root.Parent then
            local d = (item.root.Position - pos).Magnitude
            if d <= range then
                candidates[#candidates + 1] = { part = item.torso or item.root, dist = d, hp = item.hum.Health }
            end
        end
    end
    if S.auraPlayers then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character then
                local r = plr.Character:FindFirstChild("HumanoidRootPart")
                local hm = plr.Character:FindFirstChildOfClass("Humanoid")
                if r and hm and hm.Health > 0 then
                    local d = (r.Position - pos).Magnitude
                    if d <= range then
                        candidates[#candidates + 1] = { part = r, dist = d, hp = hm.Health }
                    end
                end
            end
        end
    end
    if #candidates == 0 then return 0 end
    if S.auraMode == "Nearest Only" then
        table.sort(candidates, function(a, b) return a.dist < b.dist end)
        for w = 1, #parts do
            pcall(firetouchinterest, parts[w], candidates[1].part, 0)
            pcall(firetouchinterest, parts[w], candidates[1].part, 1)
        end
        return 1
    elseif S.auraMode == "Lowest HP" then
        table.sort(candidates, function(a, b) return a.hp < b.hp end)
        for w = 1, #parts do
            pcall(firetouchinterest, parts[w], candidates[1].part, 0)
            pcall(firetouchinterest, parts[w], candidates[1].part, 1)
        end
        return 1
    else
        for i = 1, #candidates do
            for w = 1, #parts do
                pcall(firetouchinterest, parts[w], candidates[i].part, 0)
                pcall(firetouchinterest, parts[w], candidates[i].part, 1)
            end
        end
        return #candidates
    end
end

local function arenaOk()
    local _, hum, hrp = char()
    if not hum or not hrp or hum.Health <= 0 then return false, 0 end
    local y = hrp.Position.Y
    local inBand = y >= ARENA_MIN_Y and y <= ARENA_MAX_Y
    local p = hrp.Position
    local list = npcList(NPC_AGE)
    local n = 0
    for i = 1, #list do
        local r = list[i].root
        if r.Parent and (r.Position - p).Magnitude <= 600 then n += 1 end
    end
    return inBand, n
end

local function hasAnyTool()
    local ch = LP.Character
    if ch and ch:FindFirstChildOfClass("Tool") then return true end
    local bp = LP:FindFirstChild("Backpack")
    if bp and bp:FindFirstChildOfClass("Tool") then return true end
    return false
end

local function enterArenaOnce(requireTool)
    local function ready()
        if requireTool == false then return arenaOk() end
        return arenaOk() and hasAnyTool()
    end
    if ready() then return true end
    if not arenaOk() then
        goArena()
    end
    local waitEnd = os.clock() + 3.0
    while os.clock() < waitEnd and not S.unloaded do
        if ready() then return true end
        task.wait(0.05)
    end
    return ready()
end

local function ensurePickaxe()
    local ch = LP.Character
    if not ch then return false end
    if ch:FindFirstChild("Celestial Pickaxe") then return true end
    local bp = LP:FindFirstChild("Backpack")
    local pick = bp and bp:FindFirstChild("Celestial Pickaxe")
    if pick then
        local humEq = ch:FindFirstChildOfClass("Humanoid")
        if humEq then
            pcall(function() humEq:EquipTool(pick) end)
        else
            pcall(function() pick.Parent = ch end)
        end
        return ch:FindFirstChild("Celestial Pickaxe") ~= nil
    end
    return false
end

local function equipPickaxe()
    if ensurePickaxe() then return true end
    local map = Workspace:FindFirstChild("Map")
    local f = map and map:FindFirstChild("Sword Stands")
    local m = f and f:FindFirstChild("Celestial Pickaxe")
    local hb = m and (m:FindFirstChild("Hitbox") or m:FindFirstChildWhichIsA("BasePart", true))
    local cd = hb and (hb:FindFirstChildOfClass("ClickDetector") or m:FindFirstChildWhichIsA("ClickDetector", true))
    if cd then
        pcall(fireclickdetector, cd, 0, "MouseClick")
    end
    local deadline = os.clock() + 0.8
    while os.clock() < deadline and not S.unloaded do
        if ensurePickaxe() then return true end
        task.wait(0.08)
    end
    return ensurePickaxe()
end

local function isAstralStone(st)
    local oreName = tostring(st:GetAttribute("Ore") or "")
    local oreMax = tonumber(st:GetAttribute("MaxHealth")) or 0
    return oreMax >= 1000 or oreName:find("Astral") ~= nil or oreName:find("Cosmaline") ~= nil or oreName:find("Starsteel") ~= nil or oreName:find("Galaxine") ~= nil
end

local function stoneStats()
    local cm = ReplicatedStorage:FindFirstChild("CelestialMining")
    local stones = cm and cm:FindFirstChild("Stones")
    if not stones then return 0, 0 end
    local alive, astral = 0, 0
    for _, st in ipairs(stones:GetChildren()) do
        if st:GetAttribute("Alive") == true then
            alive += 1
            if isAstralStone(st) then astral += 1 end
        end
    end
    return alive, astral
end

local function getAllOreNames()
    local seen, list = {}, {}
    local function addOre(nm)
        if not nm or nm == "" then return end
        local clean = tostring(nm):gsub("^Ore", "")
        if clean ~= "" and not seen[clean] then
            seen[clean] = true
            list[#list + 1] = clean
        end
    end
    local cm = ReplicatedStorage:FindFirstChild("CelestialMining")
    local ores = cm and cm:FindFirstChild("Ores")
    if ores then
        for _, o in ipairs(ores:GetChildren()) do addOre(o.Name) end
    end
    local stones = cm and cm:FindFirstChild("Stones")
    if stones then
        for _, st in ipairs(stones:GetChildren()) do addOre(st:GetAttribute("Ore")) end
    end
    if #list == 0 then
        for _, nm in ipairs({ "Astralyte", "Cosmaline", "Starsteel", "Galaxine", "Reailite", "VoidShard", "Diamond", "Ruby", "Emerald", "Titanium", "Platinum", "Garnet", "Malachite", "Amethyst", "Tungsten", "Sapphire", "Gold", "Opal", "Topaz", "Iron", "Coal" }) do
            addOre(nm)
        end
    end
    table.sort(list)
    return list
end

local function isPriorityOre(oreName)
    if not S.orePriority or not next(S.orePriority) then return false end
    local low = tostring(oreName or ""):lower()
    if low == "" then return false end
    for k, v in pairs(S.orePriority) do
        local nm = type(k) == "number" and v or (v == true and k or nil)
        if nm and nm ~= "none" and low:find(tostring(nm):lower(), 1, true) then
            return true
        end
    end
    return false
end

local stoneSkipUntil = {}

local function pickNextStone(stones)
    local now = os.clock()
    local fallback = nil
    local anyAlive = false
    for _, st in ipairs(stones:GetChildren()) do
        if st:GetAttribute("Alive") == true and typeof(st:GetAttribute("CFrame")) == "CFrame" then
            local astral = isAstralStone(st)
            if (not S.astralOnly or astral) and (not astral or S.mineAstral or S.astralOnly) then
                anyAlive = true
                if (stoneSkipUntil[st] or 0) <= now then
                    local oreName = tostring(st:GetAttribute("Ore") or "")
                    if isPriorityOre(oreName) then
                        return st
                    end
                    if not fallback then fallback = st end
                end
            end
        end
    end
    if not fallback and anyAlive then
        table.clear(stoneSkipUntil)
        for _, st in ipairs(stones:GetChildren()) do
            if st:GetAttribute("Alive") == true and typeof(st:GetAttribute("CFrame")) == "CFrame" then
                local astral = isAstralStone(st)
                if (not S.astralOnly or astral) and (not astral or S.mineAstral or S.astralOnly) then
                    return st
                end
            end
        end
    end
    return fallback
end

local function mineAll()
    local cm = ReplicatedStorage:FindFirstChild("CelestialMining")
    local remote = cm and cm:FindFirstChild("MineHit")
    local stones = cm and cm:FindFirstChild("Stones")
    if not remote or not stones then return 0 end
    ensurePickaxe()
    local mined = 0
    while S.autoMine and not S.unloaded do
        local st = pickNextStone(stones)
        if not st then break end
        local cf = st:GetAttribute("CFrame")
        local chNow, _, hrp = char()
        if not hrp then break end
        if not chNow:FindFirstChild("Celestial Pickaxe") then ensurePickaxe() end
        S.mineState = tostring(st:GetAttribute("Ore") or st.Name)
        local anchor = cf.Position + Vector3.new(0, S.mineOffset or -6, 0)
        pcall(function() hrp.Anchored = false end)
        hrp.CFrame = CFrame.new(anchor)
        task.wait(0.06)
        pcall(function() hrp.Anchored = true end)
        local maxHp = tonumber(st:GetAttribute("MaxHealth")) or 100
        local lastHp = tonumber(st:GetAttribute("Health")) or maxHp
        local lastDrop = os.clock()
        local lastSync = os.clock()
        local started = os.clock()
        local fired = 0
        local timedOut = false
        while S.autoMine and not S.unloaded and st:GetAttribute("Alive") == true do
            if os.clock() - started > 30 then timedOut = true; break end
            local c2, h2, r2 = char()
            if not c2 or not h2 or h2.Health <= 0 or not r2 then break end
            if not c2:FindFirstChild("Celestial Pickaxe") then ensurePickaxe() end
            local hp = tonumber(st:GetAttribute("Health")) or 0
            if hp < lastHp then
                lastHp = hp
                lastDrop = os.clock()
            end
            if hp <= 0 then break end
            if os.clock() - lastDrop > 5.0 then timedOut = true; break end
            if os.clock() - lastSync > 1.5 then
                r2.CFrame = CFrame.new(anchor)
                lastSync = os.clock()
            end
            pcall(function() remote:FireServer(st.Name) end)
            mined += 1
            lastMineActivity = os.clock()
            fired += 1
            if fired % 3 == 0 then
                r2.CFrame = CFrame.new(anchor)
                task.wait()
            end
        end
        if timedOut and st:GetAttribute("Alive") == true then
            stoneSkipUntil[st] = os.clock() + 8
        end
        pcall(function()
            local _, _, r3 = char()
            if r3 then r3.Anchored = false end
        end)
    end
    if not S.autoMine then S.mineState = "idle" end
    return mined
end

-- Hitbox Expander tracking (NPC, Player, Sword)
local origHitboxes = {}
local function restoreHitboxes(kind)
    for part, info in pairs(origHitboxes) do
        if not kind or info.kind == kind then
            if part and part.Parent then
                pcall(function()
                    part.Size = info.size
                    part.Transparency = info.trans
                    part.CanCollide = info.collide
                end)
            end
            origHitboxes[part] = nil
        end
    end
end

local function applyHitbox(part, sizeVal, kind)
    if not part or not part.Parent then return end
    if not origHitboxes[part] then
        origHitboxes[part] = {
            kind = kind,
            size = part.Size,
            trans = part.Transparency,
            collide = part.CanCollide,
        }
    end
    pcall(function()
        part.Size = Vector3.new(sizeVal, sizeVal, sizeVal)
        part.Transparency = S.hitboxTrans
        part.CanCollide = false
        part.Massless = true
    end)
end

-- Tabs
local CombatTab = Window:AddTab("Combat")
local FarmTab = Window:AddTab("Farming")
local MoveTab = Window:AddTab("Movement")
local TpTab = Window:AddTab("Teleports")
local VisTab = Window:AddTab("Visuals")
local WpTab = Window:AddTab("Waypoints")
local SetTab = Window:AddTab("Settings")

-- COMBAT TAB
do
local CmbOff = CombatTab:AddSection("Offensive & Aura", 1)
local CmbHbx = CombatTab:AddSection("Hitbox & Protection", 2)

CmbOff:AddToggle({
    enabled = true, text = "Kill All Enemies", flag = "KillFarm",
    tooltip = "Sweeps all NPCs in Workspace.Map",
    callback = function(v)
        S.killFarm = v
        if not v and protect.active and not S.enabled then clearProtection() end
    end,
})

CmbOff:AddToggle({ enabled = true, text = "Kill Aura (Nearby)", flag = "KillAura", callback = function(v) S.killAura = v end })

CmbOff:AddList({
    enabled = true, text = "Aura Target Mode", flag = "AuraMode",
    value = "All in Range", values = { "All in Range", "Nearest Only", "Lowest HP" },
    callback = function(v) S.auraMode = v end,
})

CmbOff:AddSlider({
    text = "Aura Range", flag = "AuraRange", suffix = " st",
    value = 90, min = 20, max = 1000, increment = 10,
    callback = function(v) S.auraRange = v end,
})

CmbOff:AddToggle({ enabled = true, text = "Aura Include Players", flag = "AuraPlayers", callback = function(v) S.auraPlayers = v end })
CmbOff:AddToggle({ enabled = true, text = "Auto-Activate Tool", flag = "AutoSwing", callback = function(v) S.autoSwing = v end }):SetState(true, true)

CmbOff:AddToggle({
    enabled = true, text = "Reduce Tool Cooldown", flag = "ReduceToolCd",
    tooltip = "Forces Tool.Enabled and lowers tool cooldown/debounce values",
    callback = function(v) S.reduceToolCd = v end,
})

CmbOff:AddSlider({
    text = "Attack Cooldown", flag = "AttackCd", suffix = "s",
    value = 0.10, min = 0.01, max = 1.00, increment = 0.01,
    callback = function(v) S.attackCooldown = v end,
})

CmbOff:AddSlider({
    text = "NPC Scan Refresh", flag = "SweepRefresh", suffix = "s",
    value = 0.50, min = 0.15, max = 2.00, increment = 0.05,
    callback = function(v) S.sweepRefreshRate = v end,
})

CmbOff:AddSeparator({ text = "Performance" })

CmbOff:AddToggle({
    enabled = true, text = "Strip Kill Effects", flag = "StripEffects",
    tooltip = "Removes character KillEffect particles (skips tool handles)",
    callback = function(v) S.stripEffects = v end,
})

CmbHbx:AddToggle({
    enabled = true, text = "NPC Hitbox Expander", flag = "NpcHitbox",
    callback = function(v)
        S.npcHitbox = v
        if not v then restoreHitboxes("npc") end
    end,
})

CmbHbx:AddSlider({ text = "NPC Hitbox Size", flag = "NpcHitboxSize", suffix = " st", value = 25, min = 2, max = 1000, increment = 5, callback = function(v) S.npcHitboxSize = v end })

CmbHbx:AddToggle({
    enabled = true, text = "Player Hitbox Expander", flag = "PlrHitbox",
    callback = function(v)
        S.plrHitbox = v
        if not v then restoreHitboxes("plr") end
    end,
})

CmbHbx:AddSlider({ text = "Player Hitbox Size", flag = "PlrHitboxSize", suffix = " st", value = 18, min = 2, max = 1000, increment = 5, callback = function(v) S.plrHitboxSize = v end })

CmbHbx:AddToggle({
    enabled = true, text = "Sword Hitbox Expander", flag = "SwordHitbox",
    tooltip = "Expands equipped tool blade/hitbox parts",
    callback = function(v)
        S.swordHitbox = v
        if not v then restoreHitboxes("sword") end
    end,
})

CmbHbx:AddSlider({ text = "Sword Hitbox Size", flag = "SwordHitboxSize", suffix = " st", value = 25, min = 2, max = 1000, increment = 5, callback = function(v) S.swordHitboxSize = v end })
CmbHbx:AddSlider({ text = "Hitbox Transparency", flag = "HitboxTrans", suffix = "", value = 0.7, min = 0, max = 1, increment = 0.05, callback = function(v) S.hitboxTrans = v end })

CmbHbx:AddSeparator({ text = "Tool" })
CmbHbx:AddButton({
    enabled = true, text = "Unequip Tool", flag = "UnequipBtn",
    callback = function()
        local ch, hum = char()
        if ch and hum then pcall(function() hum:UnequipTools() end) end
    end,
})
end

-- FARMING TAB
local SacSec = FarmTab:AddSection("Void Sacrifice", 1)
local MineSec = FarmTab:AddSection("Celestial Mining", 2)

local progressText, statusText, shardsText, lbKillsText

SacSec:AddToggle({
    enabled = true, text = "Auto Sacrifice", flag = "AutoSac",
    callback = function(v)
        S.enabled = v
        if not v then
            S.armed, S.busy = false, false
            if protect.active and not S.killFarm then clearProtection() end
            weaponCache = { char = nil, tool = nil, parts = nil }
        else
            S.autoMine = false
            notify("Auto Sacrifice enabled (" .. S.sword .. ")", 2.5)
        end
    end,
})

SacSec:AddToggle({
    enabled = true, text = "Reset on Sacrifice Cutscene", flag = "ResetOnSac",
    callback = function(v) S.resetOnSacrifice = v end,
}):SetState(true, true)

SacSec:AddList({
    enabled = true, text = "Sacrifice Sword", flag = "Sword",
    value = "CURSE", values = { "CURSE", "DARKSTAR", "APOTHESIS" },
    callback = function(v) S.sword = v; S.armed = false end,
})

progressText = SacSec:AddText({ enabled = true, text = "Kills: 0 / 50.00b", flag = "SacProgressText" })
shardsText = SacSec:AddText({ enabled = true, text = "Session Shards: +0 (0/hr)", flag = "SacShardsText" })
lbKillsText = SacSec:AddText({ enabled = true, text = "LB Kills: +0 (0/hr)", flag = "SacLbKillsText" })
statusText = SacSec:AddText({ enabled = true, text = "Status: idle", flag = "SacStatusText" })

SacSec:AddButton({
    enabled = true, text = "Reset Cycle", flag = "ResetCycleBtn",
    callback = function()
        S.armed = false; S.startKills = 0
        pcall(function() progressText:SetText("Kills: 0 / " .. fmt(SHARD_RULES[S.sword] or 5e10)) end)
        notify("Sacrifice cycle reset", 2)
    end,
})

SacSec:AddButton({
    enabled = true, text = "Trigger Sacrifice Now", flag = "ForceSacBtn",
    confirm = true, risky = true,
    callback = function()
        task.spawn(function()
            local ok, detail = doSacrifice()
            notify(ok and ("Sacrifice complete: " .. detail) or ("Sacrifice failed: " .. detail), 3)
        end)
    end,
})

MineSec:AddToggle({
    enabled = true, text = "Auto Mine Ores", flag = "AutoMine",
    callback = function(v)
        S.autoMine = v
        if not v then
            S.mineState = "idle"
            local _, _, hrp = char()
            if hrp then pcall(function() hrp.Anchored = false end) end
        end
    end,
})

MineSec:AddSlider({
    text = "Under-Ore Offset", flag = "MineOffset", suffix = " st",
    value = -6, min = -20, max = 10, increment = 1,
    callback = function(v) S.mineOffset = v end,
})

MineSec:AddToggle({ enabled = true, text = "Mine Astral Ores", flag = "MineAstral", callback = function(v) S.mineAstral = v end })
MineSec:AddToggle({ enabled = true, text = "Astral Only Mode", flag = "AstralOnly", callback = function(v) S.astralOnly = v end })

MineSec:AddList({
    enabled = true, text = "Ore Priority (Multi)", flag = "OrePrioMulti",
    multi = true, values = getAllOreNames(),
    tooltip = "Selected ores are always mined first before other ores",
    callback = function(v)
        S.orePriority = (type(v) == "table") and v or {}
    end,
})

MineSec:AddToggle({
    enabled = true, text = "Auto Fulfill Pickaxe Phase", flag = "AutoPickPhase",
    tooltip = "Priority: Ores -> Kills -> PickaxeUnlock check for Phases 3 & 4",
    callback = function(v)
        S.autoPickaxePhase = v
        if not v then
            S.pickaxePhaseState = "idle"
            local _, _, hrp = char()
            if hrp then pcall(function() hrp.Anchored = false end) end
        end
    end,
})

MineSec:AddButton({
    enabled = true, text = "Check Pickaxe Phase Unlocks", flag = "CheckPickUnlockBtn",
    callback = function()
        task.spawn(function()
            local cm = ReplicatedStorage:FindFirstChild("CelestialMining")
            local pu = cm and cm:FindFirstChild("PickaxeUnlock")
            if not pu then notify("PickaxeUnlock remote not found", 2.5); return end
            for _, ph in ipairs({ 3, 4 }) do
                local ok, res = pcall(function() return pu:InvokeServer(ph) end)
                notify(string.format("Phase %d unlock: %s", ph, tostring(ok and res or "locked/missing items")), 2.5)
            end
        end)
    end,
})

MineSec:AddButton({
    enabled = true, text = "Equip Celestial Pickaxe", flag = "EquipPickBtn",
    callback = function()
        task.spawn(function()
            local ok = equipPickaxe()
            notify(ok and "Celestial Pickaxe equipped" or "Pickaxe stand not found", 2.5)
        end)
    end,
})

MineSec:AddSeparator({ text = "Phase & Telemetry" })
local mineAliveText = MineSec:AddText({ enabled = true, text = "Alive Stones: 0", flag = "MineAliveText" })
local mineAstralText = MineSec:AddText({ enabled = true, text = "Astral Ready: 0", flag = "MineAstralText" })
local mineStatusText = MineSec:AddText({ enabled = true, text = "Target: idle", flag = "MineStatusText" })
local pickPhaseText = MineSec:AddText({ enabled = true, text = "Phase Goal: idle", flag = "PickPhaseText" })

-- MOVEMENT TAB
local LocoSec = MoveTab:AddSection("Locomotion", 1)
local UtilSec = MoveTab:AddSection("Utility & Environment", 2)

LocoSec:AddToggle({
    enabled = true, text = "WalkSpeed Override", flag = "WalkSpeedOn",
    callback = function(v)
        S.walkSpeedOn = v
        if not v then
            local _, hum = char()
            if hum then pcall(function() hum.WalkSpeed = 16 end) end
        end
    end,
})

LocoSec:AddSlider({ text = "WalkSpeed", flag = "WalkSpeedVal", suffix = " ws", value = 50, min = 16, max = 1000, increment = 5, callback = function(v) S.walkSpeed = v end })

LocoSec:AddToggle({
    enabled = true, text = "JumpPower Override", flag = "JumpPowerOn",
    callback = function(v)
        S.jumpPowerOn = v
        if not v then
            local _, hum = char()
            if hum then pcall(function() hum.JumpPower = 50 end) end
        end
    end,
})

LocoSec:AddSlider({ text = "JumpPower", flag = "JumpPowerVal", suffix = " jp", value = 100, min = 50, max = 1000, increment = 5, callback = function(v) S.jumpPower = v end })
LocoSec:AddToggle({ enabled = true, text = "Infinite Jump", flag = "InfJump", callback = function(v) S.infJump = v end })
LocoSec:AddToggle({ enabled = true, text = "Noclip", flag = "Noclip", callback = function(v) S.noclip = v end })
LocoSec:AddSeparator({ text = "Flight" })

local flyBV, flyBG
local function stopFly()
    if flyBV then pcall(function() flyBV:Destroy() end); flyBV = nil end
    if flyBG then pcall(function() flyBG:Destroy() end); flyBG = nil end
    local _, hum = char()
    if hum then pcall(function() hum.PlatformStand = false end) end
end

LocoSec:AddToggle({
    enabled = true, text = "Fly (WASD + Space/Ctrl)", flag = "FlyOn",
    callback = function(v) S.fly = v; if not v then stopFly() end end,
})
LocoSec:AddSlider({ text = "Fly Speed", flag = "FlySpeed", suffix = " spd", value = 85, min = 20, max = 1000, increment = 5, callback = function(v) S.flySpeed = v end })

UtilSec:AddToggle({ enabled = true, text = "Ctrl + Click TP", flag = "ClickTp", callback = function(v) S.clickTp = v end })
UtilSec:AddToggle({ enabled = true, text = "Anti-Void", flag = "AntiVoid", tooltip = "Prevents falling below Y=900", callback = function(v) S.antiVoid = v end })
UtilSec:AddToggle({ enabled = true, text = "Anti-AFK", flag = "AntiAfk", callback = function(v) S.antiAfk = v end }):SetState(true, true)

local savedLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
}

UtilSec:AddToggle({
    enabled = true, text = "Fullbright & No Fog", flag = "Fullbright",
    callback = function(v)
        S.fullbright = v
        if v then
            savedLighting.Brightness = Lighting.Brightness
            savedLighting.ClockTime = Lighting.ClockTime
            savedLighting.FogEnd = Lighting.FogEnd
            savedLighting.GlobalShadows = Lighting.GlobalShadows
            pcall(function()
                Lighting.Brightness = 2
                Lighting.ClockTime = 14
                Lighting.FogEnd = 1e5
                Lighting.GlobalShadows = false
            end)
        else
            pcall(function()
                Lighting.Brightness = savedLighting.Brightness
                Lighting.ClockTime = savedLighting.ClockTime
                Lighting.FogEnd = savedLighting.FogEnd
                Lighting.GlobalShadows = savedLighting.GlobalShadows
            end)
        end
    end,
})

UtilSec:AddToggle({
    enabled = true, text = "Disable Map Barriers", flag = "NoBarriers",
    callback = function(v)
        S.noBarriers = v
        local lb = Workspace:FindFirstChild("LobbyBarrier")
        if lb then
            for _, p in ipairs(lb:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = not v end end
            if lb:IsA("BasePart") then lb.CanCollide = not v end
        end
        local map = Workspace:FindFirstChild("Map")
        local br = map and map:FindFirstChild("Barriers")
        if br then
            for _, p in ipairs(br:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = not v end end
        end
    end,
})

UtilSec:AddToggle({
    enabled = true, text = "Unlock Camera MaxZoom", flag = "MaxZoom",
    callback = function(v)
        S.maxZoom = v
        pcall(function() LP.CameraMaxZoomDistance = v and 1000 or 128 end)
    end,
})

UtilSec:AddToggle({
    enabled = true, text = "Astral Rift Notifier", flag = "RiftNotify",
    callback = function(v) S.riftNotify = v end,
}):SetState(true, true)

UtilSec:AddToggle({
    enabled = true, text = "Event Alerts (TimeStop / Rock)", flag = "EventAlerts",
    callback = function(v) S.eventAlerts = v end,
}):SetState(true, true)

UtilSec:AddToggle({
    enabled = true, text = "Disable Screen Shake", flag = "NoShake",
    callback = function(v)
        S.noShake = v
        local ps = LP:FindFirstChild("PlayerScripts")
        if ps then
            for _, d in ipairs(ps:GetDescendants()) do
                if d:IsA("LocalScript") then
                    local nl = d.Name:lower()
                    if nl == "shake" or nl == "camerashake" or nl == "screenshake" or nl:find("glitchsshake") or nl:find("shake") then
                        pcall(function() d.Disabled = v end)
                    end
                end
            end
        end
        for _, nm in ipairs({ "CameraShake", "GLITCHSHAKE", "ScreenShakeEvent" }) do
            local ev = ReplicatedStorage:FindFirstChild(nm)
            if ev and ev:IsA("RemoteEvent") and getconnections then
                for _, c in ipairs(getconnections(ev.OnClientEvent)) do
                    if v then pcall(function() c:Disable() end)
                    else pcall(function() c:Enable() end) end
                end
            end
        end
    end,
})

UtilSec:AddButton({
    enabled = true, text = "Instant Respawn", flag = "RespawnBtn",
    callback = function()
        local lc = ReplicatedStorage:FindFirstChild("LoadCharacter")
        if lc and lc:IsA("RemoteEvent") then pcall(function() lc:FireServer() end) end
    end,
})

-- TELEPORTS & SWORDS TAB
do
local AreaSec = TpTab:AddSection("Enemy Area Teleports", 1)
local SwordSec = TpTab:AddSection("Swords & Players", 2)

local areaListObj = AreaSec:AddList({
    enabled = true, text = "Enemy Zone", flag = "AreaList",
    value = areaNames[1], values = areaNames,
    callback = function(v) S.selectedArea = v end,
})

AreaSec:AddButton({
    enabled = true, text = "Teleport to Enemy Zone", flag = "TpAreaBtn",
    callback = function()
        task.spawn(function()
            local fn = areaMap[S.selectedArea]
            local ok = fn and fn()
            notify(ok and ("TP -> " .. tostring(S.selectedArea)) or ("Zone not found: " .. tostring(S.selectedArea)), 2.5)
        end)
    end,
})

AreaSec:AddButton({
    enabled = true, text = "Refresh Enemy Zones", flag = "RefAreaBtn",
    callback = function()
        buildAreaList()
        pcall(function()
            areaListObj:ClearValues()
            for _, nm in ipairs(areaNames) do areaListObj:AddValue(nm) end
            areaListObj:Select(areaNames[1], true)
        end)
        notify("Found " .. #areaNames .. " active enemy zones", 2)
    end,
})

AreaSec:AddSeparator({ text = "Quick Teleports" })

local destinyCountText = AreaSec:AddText({
    enabled = true,
    text = string.format("Destiny Shards: %d / 7", destinyShards()),
    flag = "DestinyShardsTxt",
})
task.spawn(function()
    local sh = LP:WaitForChild("Shards", 10)
    local ds = sh and sh:WaitForChild("DestinyShards", 10)
    if ds then
        local function upd()
            pcall(function() destinyCountText:SetText(string.format("Destiny Shards: %d / 7", tonumber(ds.Value) or 0)) end)
        end
        upd()
        addConn(ds.Changed:Connect(upd))
    end
end)

AreaSec:AddButton({
    enabled = true, text = "TP to Destiny Shard", flag = "TpDestinyBtn",
    callback = function()
        local ok, where = tpDestinyShard()
        notify(ok and ("TP -> " .. where) or where, 3)
    end,
})

AreaSec:AddButton({
    enabled = true, text = "TP to Void Shrine", flag = "TpShrineBtn",
    callback = function()
        if not goShrine() then notify("Void Shrine not found", 2.5) end
    end,
})

AreaSec:AddButton({
    enabled = true, text = "TP to Battle Arena", flag = "TpArenaBtn",
    callback = function()
        task.spawn(function()
            if not goArena() then notify("BattleArenaPortal not found", 2.5) end
        end)
    end,
})

-- All Swords Dropdown + Search + Leaderboard Sync
local swordListObj
local ignoreSwordSelect = true

local function filterSwordList(query)
    if not swordListObj then return end
    local q = (query or ""):lower()
    pcall(function()
        swordListObj:ClearValues()
        local added = 0
        for _, nm in ipairs(allStandNames) do
            if q == "" or nm:lower():find(q, 1, true) then
                swordListObj:AddValue(nm)
                added += 1
            end
        end
        if added == 0 then swordListObj:AddValue("none") end
    end)
end

SwordSec:AddBox({
    enabled = true, focused = false, text = "Search Swords", input = "", flag = "SwordSearchBox",
    callback = function(v)
        S.swordSearch = tostring(v or "")
        filterSwordList(S.swordSearch)
    end,
})

local function copyList(src)
    local out = {}
    for i = 1, #src do out[i] = src[i] end
    return out
end

local initSword = matchStandForEquipped(equippedName()) or allStandNames[1]
swordListObj = SwordSec:AddList({
    enabled = true, text = "Equip Sword (Instant)", flag = "AllSwordsList",
    value = initSword, values = copyList(allStandNames),
    callback = function(v)
        if ignoreSwordSelect or not v or v == "none" then return end
        S.lastSwordStand = v
        task.spawn(function()
            local ok = equipStandExact(v)
            notify(ok and ("Equipped " .. v) or ("Failed: " .. v), 2)
        end)
    end,
})
ignoreSwordSelect = false

local function syncLeaderboardSword()
    local cur = equippedName()
    local matched = matchStandForEquipped(cur)
    if matched and swordListObj then
        S.lastSwordStand = matched
        ignoreSwordSelect = true
        pcall(function() swordListObj:Select(matched, true) end)
        ignoreSwordSelect = false
    end
end
syncLeaderboardSword()

task.spawn(function()
    local ls = LP:WaitForChild("leaderstats", 10)
    local sw = ls and ls:WaitForChild("Sword", 10)
    if sw then
        addConn(sw.Changed:Connect(syncLeaderboardSword))
    end
end)

SwordSec:AddToggle({
    enabled = true, text = "Auto Re-Equip on Respawn", flag = "AutoReEquip",
    callback = function(v) S.autoReEquip = v end,
})

SwordSec:AddSeparator({ text = "Player Teleport" })

local function getPlayerNames()
    local t = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then t[#t + 1] = p.Name end
    end
    if #t == 0 then t[1] = "none" end
    return t
end

local plrListObj = SwordSec:AddList({
    enabled = true, text = "Target Player", flag = "TpPlrList",
    value = getPlayerNames()[1], values = getPlayerNames(),
    callback = function(v) S.selectedPlayer = v end,
})

SwordSec:AddButton({
    enabled = true, text = "TP to Player", flag = "TpPlrBtn",
    callback = function()
        local tgt = S.selectedPlayer and Players:FindFirstChild(S.selectedPlayer)
        local r = tgt and tgt.Character and tgt.Character:FindFirstChild("HumanoidRootPart")
        if r and tpPos(r.Position) then notify("TP -> " .. tgt.Name, 2)
        else notify("Player not found", 2) end
    end,
})

SwordSec:AddButton({
    enabled = true, text = "Refresh Players", flag = "RefPlrBtn",
    callback = function()
        pcall(function()
            plrListObj:ClearValues()
            for _, nm in ipairs(getPlayerNames()) do plrListObj:AddValue(nm) end
        end)
    end,
})
end

-- VISUALS & WAYPOINTS TABS
local customWaypoints = {}
do
local EspSec = VisTab:AddSection("Per-Category ESP Profiles", 1)
local HudSec = VisTab:AddSection("Tracer, HUD & Theme", 2)
local WpSec = WpTab:AddSection("Custom Waypoints", 1)
local WpStyleSec = WpTab:AddSection("Style & Landmarks", 2)

local FONT_MAP = { UI = 0, System = 1, Plex = 2, Monospace = 3 }
local FONT_REV = { [0] = "UI", [1] = "System", [2] = "Plex", [3] = "Monospace" }
local ignoreProfSync = false
local profTglEn, profTglBox, profTglHp, profListHp, profTglDist, profListFont, profSldThick, profSldTxt, profSldMax, profColPick

local function curProf()
    return S.espProfiles[S.espEditCat] or S.espProfiles.Enemies
end

local function loadProfileToUi()
    local p = curProf()
    ignoreProfSync = true
    if profTglEn then pcall(function() profTglEn:SetState(p.enabled, false) end) end
    if profTglBox then pcall(function() profTglBox:SetState(p.boxes, false) end) end
    if profTglHp then pcall(function() profTglHp:SetState(p.health, false) end) end
    if profListHp then pcall(function() profListHp:Select(p.hpSide, true) end) end
    if profTglDist then pcall(function() profTglDist:SetState(p.dist, false) end) end
    if profListFont then pcall(function() profListFont:Select(FONT_REV[p.font] or "Plex", true) end) end
    if profSldThick then pcall(function() profSldThick:SetValue(p.thick, false) end) end
    if profSldTxt then pcall(function() profSldTxt:SetValue(p.textSize, false) end) end
    if profSldMax then pcall(function() profSldMax:SetValue(p.maxDist, false) end) end
    if profColPick then pcall(function() profColPick:SetColor(p.color, true) end) end
    ignoreProfSync = false
end

EspSec:AddList({
    enabled = true, text = "ESP Category", flag = "EspCatList",
    value = "Enemies", values = { "Enemies", "Players", "Ores" },
    callback = function(v)
        S.espEditCat = v
        loadProfileToUi()
    end,
})

profTglEn = EspSec:AddToggle({ enabled = true, text = "Category Enabled", flag = "ProfEnabled", callback = function(v) if not ignoreProfSync then curProf().enabled = v end end })
profTglBox = EspSec:AddToggle({ enabled = true, text = "Show Boxes", flag = "ProfBoxes", callback = function(v) if not ignoreProfSync then curProf().boxes = v end end })
profTglHp = EspSec:AddToggle({ enabled = true, text = "Show Healthbars", flag = "ProfHealth", callback = function(v) if not ignoreProfSync then curProf().health = v end end })
profListHp = EspSec:AddList({ enabled = true, text = "Healthbar Side", flag = "ProfHpSide", value = "Left", values = { "Left", "Right", "Bottom" }, callback = function(v) if not ignoreProfSync then curProf().hpSide = v end end })
profTglDist = EspSec:AddToggle({ enabled = true, text = "Show Distance", flag = "ProfDist", callback = function(v) if not ignoreProfSync then curProf().dist = v end end })
profListFont = EspSec:AddList({ enabled = true, text = "ESP Font", flag = "ProfFont", value = "Plex", values = { "UI", "System", "Plex", "Monospace" }, callback = function(v) if not ignoreProfSync then curProf().font = FONT_MAP[v] or 2 end end })
profSldThick = EspSec:AddSlider({ text = "Box Thickness", flag = "ProfThick", suffix = "px", value = 1, min = 1, max = 3, increment = 1, callback = function(v) if not ignoreProfSync then curProf().thick = v end end })
profSldTxt = EspSec:AddSlider({ text = "ESP Text Size", flag = "ProfTextSz", suffix = "px", value = 13, min = 10, max = 18, increment = 1, callback = function(v) if not ignoreProfSync then curProf().textSize = v end end })
profSldMax = EspSec:AddSlider({ text = "Max Distance", flag = "ProfMaxDist", suffix = "m", value = 1500, min = 100, max = 5000, increment = 50, callback = function(v) if not ignoreProfSync then curProf().maxDist = v end end })
profColPick = EspSec:AddColor({ enabled = true, text = "Category Color", flag = "ProfCol", color = S.espProfiles.Enemies.color, trans = 0, callback = function(c) if not ignoreProfSync then curProf().color = c end end })
loadProfileToUi()

EspSec:AddSeparator({ text = "Chams & Filters" })
EspSec:AddToggle({ enabled = true, text = "Player Chams", flag = "PlayerChams", callback = function(v) S.playerChams = v end })
EspSec:AddSlider({ text = "Cham Fill Trans", flag = "ChamFill", suffix = "", value = 0.65, min = 0, max = 1, increment = 0.05, callback = function(v) S.chamFillTrans = v end })
EspSec:AddSlider({ text = "Cham Outline Trans", flag = "ChamOut", suffix = "", value = 0.1, min = 0, max = 1, increment = 0.05, callback = function(v) S.chamOutTrans = v end })
EspSec:AddToggle({ enabled = true, text = "Astral Ores Only (ESP)", flag = "OreEspAstral", callback = function(v) S.oreEspAstral = v end })

HudSec:AddToggle({ enabled = true, text = "Nearest Enemy Tracer", flag = "TracerOn", callback = function(v) S.tracerOn = v end })
HudSec:AddList({ enabled = true, text = "Tracer Origin", flag = "TracerOrg", value = "Bottom", values = { "Bottom", "Center", "Top" }, callback = function(v) S.tracerOrigin = v end })
HudSec:AddSlider({ text = "Tracer Thickness", flag = "TracerThick", suffix = "px", value = 1.5, min = 1, max = 4, increment = 0.5, callback = function(v) S.tracerThick = v end })
HudSec:AddColor({ enabled = true, text = "Tracer Color", flag = "TracerCol", color = S.tracerCol, trans = 0, callback = function(c) S.tracerCol = c end })
HudSec:AddToggle({ enabled = true, text = "Informant Telemetry HUD", flag = "HudEnabled", callback = function(v) S.hudEnabled = v end }):SetState(true, true)
HudSec:AddToggle({ enabled = true, text = "HUD Show Mining", flag = "HudMining", callback = function(v) S.hudMining = v end }):SetState(true, true)
HudSec:AddToggle({ enabled = true, text = "HUD Show LB Kills", flag = "HudLb", callback = function(v) S.hudShowLb = v end }):SetState(true, true)
HudSec:AddSlider({ text = "HUD Width", flag = "HudWidth", suffix = "px", value = 252, min = 210, max = 360, increment = 4, callback = function(v) S.hudWidth = v end })
HudSec:AddSlider({ text = "HUD Opacity", flag = "HudAlpha", suffix = "", value = 1.0, min = 0.2, max = 1.0, increment = 0.05, callback = function(v) S.hudAlpha = v end })
HudSec:AddSeparator({ text = "Accent Overrides" })
HudSec:AddToggle({ enabled = true, text = "Match Theme Accent", flag = "VisualMatchTheme", callback = function(v) S.matchTheme = v end }):SetState(true, true)
HudSec:AddColor({ enabled = true, text = "Astral Ore Color", flag = "ColAstral", color = S.colAstral, trans = 0, callback = function(c) S.colAstral = c end })

-- Custom Waypoints Manager
local wpListObj

local function refreshWaypointList()
    if not wpListObj then return end
    pcall(function()
        wpListObj:ClearValues()
        if #customWaypoints == 0 then
            wpListObj:AddValue("none")
            S.wpSelected = nil
        else
            for _, wp in ipairs(customWaypoints) do wpListObj:AddValue(wp.name) end
            if not S.wpSelected then S.wpSelected = customWaypoints[1].name end
        end
    end)
end

WpStyleSec:AddToggle({ enabled = true, text = "Show Custom Waypoints", flag = "WaypointEsp", callback = function(v) S.waypointEsp = v end }):SetState(true, true)
WpStyleSec:AddToggle({ enabled = true, text = "Show Built-in Landmarks", flag = "LandmarkEsp", callback = function(v) S.landmarkEsp = v end })
WpStyleSec:AddSlider({ text = "Icon Scale", flag = "WpScale", suffix = "x", value = 1.0, min = 0.6, max = 2.0, increment = 0.1, callback = function(v) S.wpIconScale = v end })
WpStyleSec:AddSlider({ text = "Waypoint Max Dist", flag = "WpMaxDist", suffix = "m", value = 5000, min = 200, max = 15000, increment = 200, callback = function(v) S.wpMaxDist = v end })

WpSec:AddBox({ enabled = true, focused = false, text = "Waypoint Name", input = "Spot 1", flag = "WpNameBox", callback = function(v) S.wpInputName = tostring(v or "") end })
WpSec:AddList({ enabled = true, text = "Waypoint Icon", flag = "WpIconList", value = "Diamond", values = { "Diamond", "Cross", "Square", "Triangle", "Circle", "Star" }, callback = function(v) S.wpIcon = v end })
WpSec:AddColor({ enabled = true, text = "Waypoint Color", flag = "WpColorPick", color = S.wpColor, trans = 0, callback = function(c) S.wpColor = c end })

WpSec:AddButton({
    enabled = true, text = "Create Waypoint at Pos", flag = "WpAddBtn",
    callback = function()
        local _, _, hrp = char()
        if not hrp then notify("No character root", 2); return end
        local baseName = (S.wpInputName ~= "" and S.wpInputName) or ("WP_" .. (#customWaypoints + 1))
        local finalName, idx = baseName, 1
        while true do
            local dup = false
            for _, w in ipairs(customWaypoints) do if w.name == finalName then dup = true; break end end
            if not dup then break end
            idx += 1
            finalName = baseName .. " #" .. idx
        end
        customWaypoints[#customWaypoints + 1] = {
            name = finalName,
            pos = hrp.Position,
            icon = S.wpIcon or "Diamond",
            color = S.wpColor or themeCol("Accent", Color3.fromRGB(204, 45, 45)),
        }
        S.wpSelected = finalName
        refreshWaypointList()
        notify("Created waypoint: " .. finalName, 2)
    end,
})

wpListObj = WpSec:AddList({ enabled = true, text = "Saved Waypoints", flag = "WpSavedList", value = "none", values = { "none" }, callback = function(v) S.wpSelected = v end })

WpSec:AddButton({
    enabled = true, text = "TP to Waypoint", flag = "WpTpBtn",
    callback = function()
        for _, w in ipairs(customWaypoints) do
            if w.name == S.wpSelected then tpPos(w.pos); notify("TP -> " .. w.name, 2); return end
        end
        notify("Select a valid waypoint", 2)
    end,
})

WpSec:AddButton({
    enabled = true, text = "Delete Waypoint", flag = "WpDelBtn",
    callback = function()
        for i, w in ipairs(customWaypoints) do
            if w.name == S.wpSelected then
                table.remove(customWaypoints, i)
                S.wpSelected = customWaypoints[1] and customWaypoints[1].name or nil
                refreshWaypointList()
                notify("Deleted " .. w.name, 2)
                return
            end
        end
    end,
})

WpSec:AddButton({
    enabled = true, text = "Clear All Waypoints", flag = "WpClearBtn", confirm = true,
    callback = function()
        table.clear(customWaypoints); S.wpSelected = nil; refreshWaypointList()
        notify("Cleared all waypoints", 2)
    end,
})
end

-- SETTINGS TAB
do
local SetMain = SetTab:AddSection("Menu & Theme", 1)
local SetCfg = SetTab:AddSection("Config & Session", 2)

SetMain:AddBind({
    text = "Open / Close Menu", flag = "MenuToggleBind",
    nomouse = true, noindicator = true, bind = Enum.KeyCode.RightShift,
    keycallback = function(k)
        if typeof(k) == "EnumItem" and k.EnumType == Enum.KeyCode then
            S.menuKey = k
        end
    end,
})

SetMain:AddToggle({
    enabled = true, text = "Disable Movement If Open", flag = "disablemenumovement",
    callback = function(v)
        if v and library.open then
            local _, hum = char()
            if hum then pcall(function() hum.WalkSpeed = 0 end) end
        elseif not v and not S.walkSpeedOn then
            local _, hum = char()
            if hum then pcall(function() hum.WalkSpeed = 16 end) end
        end
    end,
})

SetMain:AddToggle({
    enabled = true, text = "Watermark", flag = "WatermarkToggle",
    callback = function(v)
        pcall(function()
            if library.watermark then library.watermark.Visible = v end
        end)
    end,
})

local themeNames = {}
if library.themes then
    for _, th in ipairs(library.themes) do themeNames[#themeNames + 1] = th.name end
end
if #themeNames == 0 then themeNames[1] = "Default" end

SetMain:AddList({
    enabled = true, text = "Theme Preset", flag = "PresetTheme",
    value = themeNames[1], values = themeNames,
    callback = function(name)
        if not library.themes then return end
        for _, v in ipairs(library.themes) do
            if v.name == name then
                pcall(function() library:SetTheme(v.theme) end)
                break
            end
        end
    end,
})

SetMain:AddColor({
    enabled = true, text = "Custom Accent", flag = "CustomAccent",
    color = themeCol("Accent", Color3.fromRGB(204, 45, 45)), trans = 0,
    callback = function(c)
        if not _uiReady then return end
        pcall(function()
            if library.theme then
                local copy = {}
                for k, v in pairs(library.theme) do copy[k] = v end
                copy["Accent"] = c
                library:SetTheme(copy)
            end
        end)
    end,
})

SetMain:AddColor({
    enabled = true, text = "Custom Background", flag = "CustomBg",
    color = themeCol("Background", Color3.fromRGB(18, 18, 18)), trans = 0,
    callback = function(c)
        if not _uiReady then return end
        pcall(function()
            if library.theme then
                local copy = {}
                for k, v in pairs(library.theme) do copy[k] = v end
                copy["Background"] = c
                copy["Group Background"] = c
                copy["Section Background"] = c
                library:SetTheme(copy)
            end
        end)
    end,
})

SetMain:AddColor({
    enabled = true, text = "Custom Border", flag = "CustomBorder",
    color = themeCol("Border 1", Color3.fromRGB(60, 60, 60)), trans = 0,
    callback = function(c)
        if not _uiReady then return end
        pcall(function()
            if library.theme then
                local copy = {}
                for k, v in pairs(library.theme) do copy[k] = v end
                copy["Border 1"] = c
                copy["Option Border 1"] = c
                library:SetTheme(copy)
            end
        end)
    end,
})

SetMain:AddColor({
    enabled = true, text = "Custom Text", flag = "CustomText",
    color = themeCol("Primary Text", Color3.fromRGB(255, 255, 255)), trans = 0,
    callback = function(c)
        if not _uiReady then return end
        pcall(function()
            if library.theme then
                local copy = {}
                for k, v in pairs(library.theme) do copy[k] = v end
                copy["Primary Text"] = c
                copy["Option Text 1"] = c
                library:SetTheme(copy)
            end
        end)
    end,
})

SetMain:AddSlider({ text = "HUD X Offset", flag = "HudX", suffix = "px", value = 18, min = 4, max = 600, increment = 2, callback = function(v) S.hudX = v end })
SetMain:AddSlider({ text = "HUD Y Offset", flag = "HudY", suffix = "px", value = 60, min = 4, max = 600, increment = 2, callback = function(v) S.hudY = v end })

SetCfg:AddBox({ enabled = true, focused = false, text = "Config Name", input = "default", flag = "cfgInput" })
local cfgListObj = SetCfg:AddList({ enabled = true, text = "Saved Config", flag = "cfgSelected", value = "none", values = { "none" } })

local function refreshCfgs()
    pcall(function()
        cfgListObj:ClearValues()
        local dir = library.cheatname .. "/" .. library.gamename .. "/configs"
        if isfolder and isfolder(dir) and listfiles then
            for _, f in ipairs(listfiles(dir)) do
                local nm = f:match("([^/\\]+)" .. library.fileext .. "$")
                if nm then cfgListObj:AddValue(nm) end
            end
        end
    end)
end
refreshCfgs()

SetCfg:AddButton({
    enabled = true, text = "Load Config", flag = "CfgLoad",
    callback = function()
        if library.flags.cfgSelected and library.flags.cfgSelected ~= "none" then
            pcall(function() library:LoadConfig(library.flags.cfgSelected) end)
        end
    end,
}):AddButton({
    enabled = true, text = "Save Config", flag = "CfgSave", confirm = true,
    callback = function()
        local nm = (library.flags.cfgInput and library.flags.cfgInput ~= "") and library.flags.cfgInput or library.flags.cfgSelected
        if nm and nm ~= "none" then
            pcall(function() library:SaveConfig(nm) end)
            refreshCfgs()
        end
    end,
})

SetCfg:AddButton({
    enabled = true, text = "Copy Join Script", flag = "CopyJoinBtn",
    callback = function()
        if setclipboard then
            setclipboard(string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game.Players.LocalPlayer)', game.PlaceId, game.JobId))
            notify("Copied join script", 2)
        end
    end,
})

SetCfg:AddButton({
    enabled = true, text = "Rejoin Server", flag = "RejoinBtn", confirm = true,
    callback = function()
        pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP) end)
    end,
})

SetCfg:AddButton({
    enabled = true, text = "Unload Y7 Hub", flag = "UnloadBtn", confirm = true, risky = true,
    callback = function()
        if getgenv().Y7Hub and getgenv().Y7Hub.destroy then getgenv().Y7Hub.destroy() end
    end,
})

SetCfg:AddSeparator({ text = "Credits" })
SetCfg:AddText({ enabled = true, text = "Y7 Hub  |  Made by OfeKoOfe", flag = "Cred1" })
end

if library.themes and library.themes[1] then
    pcall(function() library:SetTheme(library.themes[1].theme) end)
end
_uiReady = true

-- Mobile-friendly Informant-styled Logo Toggle Button
local logoGui, logoFrame, logoAccent, logoStroke, logoBtn
do
    local okGui = pcall(function()
        logoGui = Instance.new("ScreenGui")
        logoGui.Name = "Y7LogoToggle"
        logoGui.ResetOnSpawn = false
        logoGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        local parent = (gethui and gethui()) or game:GetService("CoreGui")
        logoGui.Parent = parent
    end)
    if not okGui or not logoGui then
        pcall(function()
            logoGui = Instance.new("ScreenGui")
            logoGui.Name = "Y7LogoToggle"
            logoGui.ResetOnSpawn = false
            logoGui.Parent = LP:WaitForChild("PlayerGui")
        end)
    end
    if logoGui then
        local assetOk, assetId = pcall(function()
            if getcustomasset and isfile then
                if isfile("Y7Hub-logo-tint.png") then return getcustomasset("Y7Hub-logo-tint.png") end
                if isfile("Y7Hub-logo.png") then return getcustomasset("Y7Hub-logo.png") end
            end
            return nil
        end)

        logoFrame = Instance.new("Frame")
        logoFrame.Name = "Y7Btn"
        logoFrame.Size = UDim2.fromOffset(56, 56)
        logoFrame.Position = isMobile and UDim2.new(1, -70, 0, 12) or UDim2.new(0, 18, 0.5, -28)
        logoFrame.BackgroundColor3 = themeCol("Background", Color3.fromRGB(18, 18, 18))
        logoFrame.BorderColor3 = Color3.new(0, 0, 0)
        logoFrame.BorderSizePixel = 1
        logoFrame.Visible = isMobile or (not library.open)
        logoFrame.Parent = logoGui

        logoStroke = Instance.new("UIStroke")
        logoStroke.Color = themeCol("Border 1", Color3.fromRGB(60, 60, 60))
        logoStroke.Thickness = 1
        logoStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        logoStroke.Parent = logoFrame

        logoAccent = Instance.new("Frame")
        logoAccent.Size = UDim2.new(1, 0, 0, 2)
        logoAccent.Position = UDim2.new(0, 0, 0, 0)
        logoAccent.BackgroundColor3 = themeCol("Accent", Color3.fromRGB(204, 45, 45))
        logoAccent.BorderSizePixel = 0
        logoAccent.Parent = logoFrame

        if assetOk and assetId then
            logoBtn = Instance.new("ImageButton")
            logoBtn.Image = assetId
            logoBtn.ImageColor3 = themeCol("Accent", Color3.fromRGB(204, 45, 45))
            logoBtn.ScaleType = Enum.ScaleType.Fit
            logoBtn.BackgroundTransparency = 1
            logoBtn.Size = UDim2.new(1, -10, 1, -12)
            logoBtn.Position = UDim2.new(0, 5, 0, 7)
        else
            logoBtn = Instance.new("TextButton")
            logoBtn.Text = "Y7"
            logoBtn.Font = Enum.Font.Code
            logoBtn.TextSize = 22
            logoBtn.TextColor3 = themeCol("Accent", Color3.fromRGB(204, 45, 45))
            logoBtn.BackgroundTransparency = 1
            logoBtn.Size = UDim2.new(1, 0, 1, -2)
            logoBtn.Position = UDim2.new(0, 0, 0, 2)
        end
        logoBtn.AutoButtonColor = false
        logoBtn.Parent = logoFrame

        local dragging, moved, dragStart, startPos = false, false, nil, nil
        addConn(logoBtn.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                moved = false
                dragStart = inp.Position
                startPos = logoFrame.Position
            end
        end))
        addConn(UserInputService.InputChanged:Connect(function(inp)
            if not dragging then return end
            if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                local delta = inp.Position - dragStart
                if delta.Magnitude > 5 then moved = true end
                logoFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end))
        addConn(UserInputService.InputEnded:Connect(function(inp)
            if dragging and (inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch) then
                dragging = false
                if not moved and not S.unloaded then
                    pcall(function() library:SetOpen(not library.open) end)
                end
            end
        end))
    end
end

-- Informant-styled Drawing Visuals Engine
local allDrawings = {}
local function newDraw(kind, props)
    local ok, obj = pcall(Drawing.new, kind)
    if not ok or not obj then return nil end
    for k, v in pairs(props) do pcall(function() obj[k] = v end) end
    allDrawings[#allDrawings + 1] = obj
    return obj
end

local function makeBoxEsp()
    return {
        boxOut = newDraw("Square", { Visible = false, Filled = false, Thickness = 3, Color = Color3.new(0, 0, 0) }),
        box = newDraw("Square", { Visible = false, Filled = false, Thickness = 1 }),
        hpOut = newDraw("Square", { Visible = false, Filled = true, Color = Color3.new(0, 0, 0) }),
        hpFill = newDraw("Square", { Visible = false, Filled = true }),
        name = newDraw("Text", { Visible = false, Center = true, Outline = true, Size = 13, Font = 2, Color = Color3.new(1, 1, 1) }),
        sub = newDraw("Text", { Visible = false, Center = true, Outline = true, Size = 12, Font = 2, Color = Color3.fromRGB(190, 190, 190) }),
    }
end

local function hideBoxEsp(e)
    for _, d in pairs(e) do if d then d.Visible = false end end
end

local function makeIconWp()
    return {
        sqOut = newDraw("Square", { Visible = false, Filled = true, Size = Vector2.new(8, 8), Color = Color3.new(0, 0, 0) }),
        sq = newDraw("Square", { Visible = false, Filled = true, Size = Vector2.new(6, 6) }),
        circOut = newDraw("Circle", { Visible = false, Filled = true, Radius = 5, NumSides = 16, Color = Color3.new(0, 0, 0) }),
        circ = newDraw("Circle", { Visible = false, Filled = true, Radius = 3.5, NumSides = 16 }),
        l1Out = newDraw("Line", { Visible = false, Thickness = 3, Color = Color3.new(0, 0, 0) }),
        l2Out = newDraw("Line", { Visible = false, Thickness = 3, Color = Color3.new(0, 0, 0) }),
        l3Out = newDraw("Line", { Visible = false, Thickness = 3, Color = Color3.new(0, 0, 0) }),
        l4Out = newDraw("Line", { Visible = false, Thickness = 3, Color = Color3.new(0, 0, 0) }),
        l1 = newDraw("Line", { Visible = false, Thickness = 1.5 }),
        l2 = newDraw("Line", { Visible = false, Thickness = 1.5 }),
        l3 = newDraw("Line", { Visible = false, Thickness = 1.5 }),
        l4 = newDraw("Line", { Visible = false, Thickness = 1.5 }),
        text = newDraw("Text", { Visible = false, Center = true, Outline = true, Size = 13, Font = 2 }),
    }
end

local function hideIconWp(e)
    for _, d in pairs(e) do if d then d.Visible = false end end
end

local function setLinePair(lo, li, a, b, col)
    lo.From = a; lo.To = b; lo.Visible = true
    li.From = a; li.To = b; li.Color = col; li.Visible = true
end

local function drawIconWp(e, sx, sy, icon, col, label)
    hideIconWp(e)
    local sc = S.wpIconScale or 1
    if icon == "Square" then
        local osz, isz = math.floor(8 * sc), math.floor(6 * sc)
        e.sqOut.Size = Vector2.new(osz, osz); e.sqOut.Position = Vector2.new(sx - osz / 2, sy - osz / 2); e.sqOut.Visible = true
        e.sq.Size = Vector2.new(isz, isz); e.sq.Position = Vector2.new(sx - isz / 2, sy - isz / 2); e.sq.Color = col; e.sq.Visible = true
    elseif icon == "Circle" then
        e.circOut.Radius = 5 * sc; e.circOut.Position = Vector2.new(sx, sy); e.circOut.Visible = true
        e.circ.Radius = 3.5 * sc; e.circ.Position = Vector2.new(sx, sy); e.circ.Color = col; e.circ.Visible = true
    elseif icon == "Triangle" then
        local a = Vector2.new(sx, sy - 6 * sc)
        local b = Vector2.new(sx - 6 * sc, sy + 5 * sc)
        local c = Vector2.new(sx + 6 * sc, sy + 5 * sc)
        setLinePair(e.l1Out, e.l1, a, b, col)
        setLinePair(e.l2Out, e.l2, b, c, col)
        setLinePair(e.l3Out, e.l3, c, a, col)
    elseif icon == "Star" then
        local r = 6 * sc
        local d = 4.2 * sc
        setLinePair(e.l1Out, e.l1, Vector2.new(sx - r, sy), Vector2.new(sx + r, sy), col)
        setLinePair(e.l2Out, e.l2, Vector2.new(sx, sy - r), Vector2.new(sx, sy + r), col)
        setLinePair(e.l3Out, e.l3, Vector2.new(sx - d, sy - d), Vector2.new(sx + d, sy + d), col)
        setLinePair(e.l4Out, e.l4, Vector2.new(sx - d, sy + d), Vector2.new(sx + d, sy - d), col)
    elseif icon == "Cross" then
        local r = 5.5 * sc
        setLinePair(e.l1Out, e.l1, Vector2.new(sx - r, sy), Vector2.new(sx + r, sy), col)
        setLinePair(e.l2Out, e.l2, Vector2.new(sx, sy - r), Vector2.new(sx, sy + r), col)
    else -- Diamond
        local r = 6 * sc
        local t = Vector2.new(sx, sy - r)
        local ri = Vector2.new(sx + r, sy)
        local bo = Vector2.new(sx, sy + r)
        local le = Vector2.new(sx - r, sy)
        setLinePair(e.l1Out, e.l1, t, ri, col)
        setLinePair(e.l2Out, e.l2, ri, bo, col)
        setLinePair(e.l3Out, e.l3, bo, le, col)
        setLinePair(e.l4Out, e.l4, le, t, col)
    end
    e.text.Position = Vector2.new(sx, sy + 9 * sc)
    e.text.Font = (S.espProfiles.Ores and S.espProfiles.Ores.font) or 2
    e.text.Size = (S.espProfiles.Ores and S.espProfiles.Ores.textSize) or 13
    e.text.Text = label
    e.text.Color = col
    e.text.Visible = true
end

local tracerOut = newDraw("Line", { Visible = false, Thickness = 3, Color = Color3.new(0, 0, 0), ZIndex = 190 })
local tracerLine = newDraw("Line", { Visible = false, Thickness = 1.5, ZIndex = 191 })
local closeBtnDraw = newDraw("Text", { Visible = false, Text = "X", Font = 2, Size = 14, Outline = true, ZIndex = 1350 })
local closeHitRect = nil

local function syncCloseBtn(accent)
    if not closeBtnDraw then return end
    local bgObj = Window and Window.objects and Window.objects.background and Window.objects.background.Object
    local titleObj = Window and Window.objects and Window.objects.title and Window.objects.title.Object
    if library.open and not S.unloaded and bgObj then
        local cx = bgObj.Position.X + bgObj.Size.X - 18
        local cy = titleObj and titleObj.Position.Y or (bgObj.Position.Y - 18)
        closeBtnDraw.Position = Vector2.new(cx, cy)
        if accent then closeBtnDraw.Color = accent end
        closeBtnDraw.Visible = true
        closeHitRect = { x1 = cx - 6, y1 = cy - 4, x2 = cx + 18, y2 = cy + 18 }
    else
        closeBtnDraw.Visible = false
        closeHitRect = nil
    end
end

local npcPool, playerPool, orePool, wayPool = {}, {}, {}, {}
local chamMap = {}

local function getPool(pool, idx, factory)
    if not pool[idx] then pool[idx] = factory() end
    return pool[idx]
end

local hud = {
    borderOut = newDraw("Square", { Visible = false, Filled = true, Color = Color3.new(0, 0, 0), ZIndex = 200 }),
    borderIn = newDraw("Square", { Visible = false, Filled = true, Color = Color3.fromRGB(55, 55, 55), ZIndex = 201 }),
    bg = newDraw("Square", { Visible = false, Filled = true, Color = Color3.fromRGB(18, 18, 18), ZIndex = 202 }),
    accent = newDraw("Square", { Visible = false, Filled = true, ZIndex = 203 }),
    title = newDraw("Text", { Visible = false, Outline = true, Size = 13, Font = 2, Color = Color3.new(1, 1, 1), ZIndex = 204 }),
    line1 = newDraw("Text", { Visible = false, Outline = true, Size = 12, Font = 2, Color = Color3.fromRGB(220, 220, 220), ZIndex = 204 }),
    line2 = newDraw("Text", { Visible = false, Outline = true, Size = 12, Font = 2, Color = Color3.fromRGB(200, 200, 200), ZIndex = 204 }),
    barOut = newDraw("Square", { Visible = false, Filled = true, Color = Color3.new(0, 0, 0), ZIndex = 203 }),
    barBg = newDraw("Square", { Visible = false, Filled = true, Color = Color3.fromRGB(28, 28, 34), ZIndex = 204 }),
    barFill = newDraw("Square", { Visible = false, Filled = true, ZIndex = 205 }),
    line3 = newDraw("Text", { Visible = false, Outline = true, Size = 12, Font = 2, Color = Color3.fromRGB(175, 175, 185), ZIndex = 204 }),
}

local function hideHud()
    for _, d in pairs(hud) do if d then d.Visible = false end end
end

local function updateChams()
    local accent = S.matchTheme and themeCol("Accent", S.espProfiles.Players.color) or S.espProfiles.Players.color
    for plr, hl in pairs(chamMap) do
        if not S.playerChams or not plr.Parent or not plr.Character or hl.Parent ~= plr.Character then
            pcall(function() hl:Destroy() end)
            chamMap[plr] = nil
        else
            hl.FillColor = accent
            hl.FillTransparency = S.chamFillTrans
            hl.OutlineTransparency = S.chamOutTrans
            hl.OutlineColor = Color3.new(1, 1, 1)
        end
    end
    if not S.playerChams then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character and not chamMap[plr] then
            local ok, hl = pcall(function()
                local h = Instance.new("Highlight")
                h.Name = "Y7Cham"
                h.FillColor = accent
                h.OutlineColor = Color3.new(1, 1, 1)
                h.FillTransparency = S.chamFillTrans
                h.OutlineTransparency = S.chamOutTrans
                h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                h.Parent = plr.Character
                return h
            end)
            if ok and hl then chamMap[plr] = hl end
        end
    end
end

local lastHudAt, lastHudTextAt, lastStoneStatAt, lastOreScan, cachedOres = 0, 0, 0, 0, {}
local cachedAliveStones, cachedAstralStones = 0, 0

addConn(UserInputService.InputChanged:Connect(function(inp)
    if S.unloaded or not library.open then return end
    if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
        task.defer(syncCloseBtn)
    end
end))

addConn(RunService.RenderStepped:Connect(function()
    if S.unloaded then return end
    local now = os.clock()
    local cam = Workspace.CurrentCamera
    if not cam then return end
    local camPos = cam.CFrame.Position
    local vp = cam.ViewportSize
    local accent = themeCol("Accent", Color3.fromRGB(204, 45, 45))
    local bgCol = themeCol("Background", Color3.fromRGB(18, 18, 18))
    local b1Col = themeCol("Border 1", Color3.fromRGB(60, 60, 60))
    local txtCol = themeCol("Primary Text", Color3.fromRGB(245, 245, 245))

    if logoFrame then
        logoFrame.Visible = (isMobile or not library.open) and (not S.unloaded)
        logoFrame.BackgroundColor3 = bgCol
        if logoStroke then logoStroke.Color = b1Col end
        if logoAccent then logoAccent.BackgroundColor3 = accent end
        if logoBtn then
            if logoBtn:IsA("ImageButton") then logoBtn.ImageColor3 = accent
            else logoBtn.TextColor3 = accent end
        end
    end
    syncCloseBtn(accent)

    if S.hudEnabled and hud.bg then
        local w, h = S.hudWidth or 252, S.hudMining and 84 or 68
        local x, y = S.hudX, S.hudY
        local alpha = S.hudAlpha or 1
        hud.borderOut.Position = Vector2.new(x - 2, y - 2); hud.borderOut.Size = Vector2.new(w + 4, h + 4); hud.borderOut.Transparency = alpha; hud.borderOut.Visible = true
        hud.borderIn.Position = Vector2.new(x - 1, y - 1); hud.borderIn.Size = Vector2.new(w + 2, h + 2); hud.borderIn.Color = b1Col; hud.borderIn.Transparency = alpha; hud.borderIn.Visible = true
        hud.bg.Position = Vector2.new(x, y); hud.bg.Size = Vector2.new(w, h); hud.bg.Color = bgCol; hud.bg.Transparency = alpha; hud.bg.Visible = true
        hud.accent.Position = Vector2.new(x, y); hud.accent.Size = Vector2.new(w, 2); hud.accent.Color = accent; hud.accent.Transparency = alpha; hud.accent.Visible = true
        hud.title.Position = Vector2.new(x + 7, y + 6); hud.title.Color = txtCol; hud.title.Font = S.espFont or 2; hud.title.Visible = true
        hud.line1.Position = Vector2.new(x + 7, y + 22); hud.line1.Font = S.espFont or 2; hud.line1.Visible = true
        hud.barOut.Position = Vector2.new(x + 6, y + 38); hud.barOut.Size = Vector2.new(w - 12, 8); hud.barOut.Transparency = alpha; hud.barOut.Visible = true
        hud.barBg.Position = Vector2.new(x + 7, y + 39); hud.barBg.Size = Vector2.new(w - 14, 6); hud.barBg.Transparency = alpha; hud.barBg.Visible = true
        hud.barFill.Position = Vector2.new(x + 7, y + 39); hud.barFill.Color = accent; hud.barFill.Transparency = alpha; hud.barFill.Visible = true
        hud.line2.Position = Vector2.new(x + 7, y + 50); hud.line2.Font = S.espFont or 2; hud.line2.Visible = true
        if S.hudMining then
            hud.line3.Position = Vector2.new(x + 7, y + 65); hud.line3.Font = S.espFont or 2; hud.line3.Visible = true
        else
            hud.line3.Visible = false
        end

        if now - lastHudTextAt > 0.2 then
            lastHudTextAt = now
            local mode = S.enabled and ("AUTO SAC [" .. S.sword .. "]") or (S.autoPickaxePhase and "PICKAXE PHASE" or (S.killFarm and "KILL ALL" or (S.killAura and "KILL AURA" or (S.autoMine and "MINING" or "IDLE"))))
            hud.title.Text = "Y7 HUB  |  " .. mode
            local target = SHARD_RULES[S.sword] or 5e10
            local gained = sacKills()
            local pct = math.clamp(gained / target, 0, 1)
            local curSh, earnedSh, rateSh = sessionShards()
            hud.line1.Text = string.format("Shards: %s (+%s | %.1f/hr)", tostring(curSh), tostring(earnedSh), rateSh)
            hud.barFill.Size = Vector2.new(math.max(0, math.floor((w - 14) * pct)), 6)
            local eq = equippedName() or "None"
            if S.hudShowLb then
                local _, lbEarned, lbRate = sessionLbKills()
                hud.line2.Text = string.format("%s (%.0f%%) | LB +%s (%s/hr)", eq, pct * 100, fmt(lbEarned), fmt(lbRate))
            else
                hud.line2.Text = string.format("Sword: %s  (%.1f%%)", eq, pct * 100)
            end
            if S.hudMining then
                if now - lastStoneStatAt > 1.0 then
                    lastStoneStatAt = now
                    cachedAliveStones, cachedAstralStones = stoneStats()
                end
                hud.line3.Text = string.format("Ores: %d (%d Astral)  |  %s", cachedAliveStones, cachedAstralStones, S.mineState)
            end
        end
    else
        hideHud()
    end

    -- NPC ESP + Nearest Tracer
    local usedNpc = 0
    local nearestDist, nearestScreen = math.huge, nil
    local npcP = S.espProfiles.Enemies
    if npcP.enabled or S.tracerOn then
        local npcs = npcList(0.2)
        local col = S.matchTheme and accent or npcP.color
        for i = 1, #npcs do
            local item = npcs[i]
            local root = item.root
            if root and root.Parent then
                local dist = (root.Position - camPos).Magnitude
                if dist <= npcP.maxDist then
                    local topPos, onTop = cam:WorldToViewportPoint(root.Position + Vector3.new(0, 3.2, 0))
                    local botPos, onBot = cam:WorldToViewportPoint(root.Position - Vector3.new(0, 3.2, 0))
                    if (onTop or onBot) and topPos.Z > 0 then
                        if S.tracerOn and dist < nearestDist then
                            nearestDist = dist
                            nearestScreen = Vector2.new(topPos.X, (topPos.Y + botPos.Y) * 0.5)
                        end
                        if npcP.enabled then
                            usedNpc += 1
                            local e = getPool(npcPool, usedNpc, makeBoxEsp)
                            local bh = math.max(14, math.abs(botPos.Y - topPos.Y))
                            local bw = math.max(10, bh * 0.62)
                            local bx, by = topPos.X - bw * 0.5, topPos.Y

                            e.boxOut.Thickness = npcP.thick + 2
                            e.boxOut.Position = Vector2.new(bx, by); e.boxOut.Size = Vector2.new(bw, bh); e.boxOut.Visible = npcP.boxes
                            e.box.Thickness = npcP.thick
                            e.box.Position = Vector2.new(bx, by); e.box.Size = Vector2.new(bw, bh); e.box.Color = col; e.box.Visible = npcP.boxes

                            local hpPct = math.clamp(item.hum.Health / math.max(1, item.hum.MaxHealth), 0, 1)
                            local hpCol = Color3.fromRGB(math.floor(255 * (1 - hpPct)), math.floor(255 * hpPct), 45)
                            if npcP.hpSide == "Bottom" then
                                local hpW = math.floor(bw * hpPct)
                                e.hpOut.Position = Vector2.new(bx - 1, by + bh + 2); e.hpOut.Size = Vector2.new(bw + 2, 4); e.hpOut.Visible = npcP.health
                                e.hpFill.Position = Vector2.new(bx, by + bh + 3); e.hpFill.Size = Vector2.new(hpW, 2); e.hpFill.Color = hpCol; e.hpFill.Visible = npcP.health
                            else
                                local hpH = math.floor(bh * hpPct)
                                local hx = npcP.hpSide == "Right" and (bx + bw + 2) or (bx - 5)
                                e.hpOut.Position = Vector2.new(hx, by - 1); e.hpOut.Size = Vector2.new(4, bh + 2); e.hpOut.Visible = npcP.health
                                e.hpFill.Position = Vector2.new(hx + 1, by + (bh - hpH)); e.hpFill.Size = Vector2.new(2, hpH); e.hpFill.Color = hpCol; e.hpFill.Visible = npcP.health
                            end

                            e.name.Font = npcP.font
                            e.name.Size = npcP.textSize
                            e.name.Position = Vector2.new(topPos.X, by - npcP.textSize - 2); e.name.Text = item.name; e.name.Color = txtCol; e.name.Visible = true
                            e.sub.Font = npcP.font
                            e.sub.Size = math.max(10, npcP.textSize - 1)
                            e.sub.Position = Vector2.new(topPos.X, by + bh + (npcP.hpSide == "Bottom" and 7 or 2))
                            e.sub.Text = npcP.dist and string.format("%dm | %s HP", math.floor(dist), fmt(item.hum.Health)) or (fmt(item.hum.Health) .. " HP")
                            e.sub.Visible = true
                        end
                    end
                end
            end
        end
    end
    for i = usedNpc + 1, #npcPool do hideBoxEsp(npcPool[i]) end

    if S.tracerOn and nearestScreen and tracerLine then
        local oy = S.tracerOrigin == "Top" and 0 or (S.tracerOrigin == "Center" and vp.Y * 0.5 or vp.Y)
        local fromPt = Vector2.new(vp.X * 0.5, oy)
        local tt = S.tracerThick or 1.5
        tracerOut.Thickness = tt + 2; tracerOut.From = fromPt; tracerOut.To = nearestScreen; tracerOut.Visible = true
        tracerLine.Thickness = tt; tracerLine.From = fromPt; tracerLine.To = nearestScreen
        tracerLine.Color = S.matchTheme and accent or S.tracerCol
        tracerLine.Visible = true
    else
        if tracerOut then tracerOut.Visible = false end
        if tracerLine then tracerLine.Visible = false end
    end

    -- Player ESP
    local usedPlr = 0
    local plrP = S.espProfiles.Players
    if plrP.enabled then
        local col = S.matchTheme and accent or plrP.color
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character then
                local ch = plr.Character
                local hrp = ch:FindFirstChild("HumanoidRootPart")
                local hum = ch:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local dist = (hrp.Position - camPos).Magnitude
                    if dist <= plrP.maxDist then
                        local topPos, onTop = cam:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3.2, 0))
                        local botPos, onBot = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.2, 0))
                        if (onTop or onBot) and topPos.Z > 0 then
                            usedPlr += 1
                            local e = getPool(playerPool, usedPlr, makeBoxEsp)
                            local bh = math.max(14, math.abs(botPos.Y - topPos.Y))
                            local bw = math.max(10, bh * 0.62)
                            local bx, by = topPos.X - bw * 0.5, topPos.Y

                            e.boxOut.Thickness = plrP.thick + 2
                            e.boxOut.Position = Vector2.new(bx, by); e.boxOut.Size = Vector2.new(bw, bh); e.boxOut.Visible = plrP.boxes
                            e.box.Thickness = plrP.thick
                            e.box.Position = Vector2.new(bx, by); e.box.Size = Vector2.new(bw, bh); e.box.Color = col; e.box.Visible = plrP.boxes

                            local hpPct = math.clamp(hum.Health / math.max(1, hum.MaxHealth), 0, 1)
                            local hpCol = Color3.fromRGB(math.floor(255 * (1 - hpPct)), math.floor(255 * hpPct), 45)
                            if plrP.hpSide == "Bottom" then
                                local hpW = math.floor(bw * hpPct)
                                e.hpOut.Position = Vector2.new(bx - 1, by + bh + 2); e.hpOut.Size = Vector2.new(bw + 2, 4); e.hpOut.Visible = plrP.health
                                e.hpFill.Position = Vector2.new(bx, by + bh + 3); e.hpFill.Size = Vector2.new(hpW, 2); e.hpFill.Color = hpCol; e.hpFill.Visible = plrP.health
                            else
                                local hpH = math.floor(bh * hpPct)
                                local hx = plrP.hpSide == "Right" and (bx + bw + 2) or (bx - 5)
                                e.hpOut.Position = Vector2.new(hx, by - 1); e.hpOut.Size = Vector2.new(4, bh + 2); e.hpOut.Visible = plrP.health
                                e.hpFill.Position = Vector2.new(hx + 1, by + (bh - hpH)); e.hpFill.Size = Vector2.new(2, hpH); e.hpFill.Color = hpCol; e.hpFill.Visible = plrP.health
                            end

                            local ls = plr:FindFirstChild("leaderstats")
                            local sw = ls and ls:FindFirstChild("Sword")
                            local swStr = sw and tostring(sw.Value) or "?"
                            e.name.Font = plrP.font
                            e.name.Size = plrP.textSize
                            e.name.Position = Vector2.new(topPos.X, by - plrP.textSize - 2); e.name.Text = plr.Name; e.name.Color = txtCol; e.name.Visible = true
                            e.sub.Font = plrP.font
                            e.sub.Size = math.max(10, plrP.textSize - 1)
                            e.sub.Position = Vector2.new(topPos.X, by + bh + (plrP.hpSide == "Bottom" and 7 or 2))
                            e.sub.Text = plrP.dist and string.format("[%s] %dm", swStr, math.floor(dist)) or ("[" .. swStr .. "]")
                            e.sub.Visible = true
                        end
                    end
                end
            end
        end
    end
    for i = usedPlr + 1, #playerPool do hideBoxEsp(playerPool[i]) end

    -- Ore ESP
    local usedOre = 0
    local oreP = S.espProfiles.Ores
    if oreP.enabled then
        if os.clock() - lastOreScan > 0.35 then
            lastOreScan = os.clock()
            local cm = ReplicatedStorage:FindFirstChild("CelestialMining")
            local stones = cm and cm:FindFirstChild("Stones")
            cachedOres = stones and stones:GetChildren() or {}
        end
        for i = 1, #cachedOres do
            local st = cachedOres[i]
            if st.Parent and st:GetAttribute("Alive") == true then
                local astral = isAstralStone(st)
                if not S.oreEspAstral or astral then
                    local cf = st:GetAttribute("CFrame")
                    if typeof(cf) == "CFrame" then
                        local dist = (cf.Position - camPos).Magnitude
                        if dist <= oreP.maxDist then
                            local sp, onScr = cam:WorldToViewportPoint(cf.Position)
                            if onScr and sp.Z > 0 then
                                usedOre += 1
                                local e = getPool(orePool, usedOre, makeIconWp)
                                local col = astral and S.colAstral or oreP.color
                                local hp = tonumber(st:GetAttribute("Health")) or 0
                                local mhp = tonumber(st:GetAttribute("MaxHealth")) or 100
                                local lbl = oreP.dist and string.format("%s [%d/%d] %dm", tostring(st:GetAttribute("Ore") or st.Name), hp, mhp, math.floor(dist)) or string.format("%s [%d/%d]", tostring(st:GetAttribute("Ore") or st.Name), hp, mhp)
                                drawIconWp(e, sp.X, sp.Y, astral and "Star" or "Square", col, lbl)
                            end
                        end
                    end
                end
            end
        end
    end
    for i = usedOre + 1, #orePool do hideIconWp(orePool[i]) end

    -- Waypoints
    local usedWay = 0
    if S.waypointEsp then
        for i = 1, #customWaypoints do
            local wp = customWaypoints[i]
            local dist = (wp.pos - camPos).Magnitude
            if dist <= S.wpMaxDist then
                local sp, onScr = cam:WorldToViewportPoint(wp.pos)
                if onScr and sp.Z > 0 then
                    usedWay += 1
                    local e = getPool(wayPool, usedWay, makeIconWp)
                    drawIconWp(e, sp.X, sp.Y, wp.icon, wp.color, string.format("%s [%dm]", wp.name, math.floor(dist)))
                end
            end
        end
    end
    if S.landmarkEsp then
        local shrine = Workspace:FindFirstChild("VO!D $HR1NE")
        local spPart = shrine and shrine:FindFirstChild("VoidShrinePrompt")
        if spPart and spPart:IsA("BasePart") then
            local dist = (spPart.Position - camPos).Magnitude
            if dist <= S.wpMaxDist then
                local sp, onScr = cam:WorldToViewportPoint(spPart.Position)
                if onScr and sp.Z > 0 then
                    usedWay += 1
                    local e = getPool(wayPool, usedWay, makeIconWp)
                    drawIconWp(e, sp.X, sp.Y, "Diamond", accent, string.format("VOID SHRINE [%dm]", math.floor(dist)))
                end
            end
        end
        local map = Workspace:FindFirstChild("Map")
        local arena = map and map:FindFirstChild("BattleArenaPortal")
        local tel = arena and portalTrigger(arena)
        if tel then
            local dist = (tel.Position - camPos).Magnitude
            if dist <= S.wpMaxDist then
                local sp, onScr = cam:WorldToViewportPoint(tel.Position)
                if onScr and sp.Z > 0 then
                    usedWay += 1
                    local e = getPool(wayPool, usedWay, makeIconWp)
                    drawIconWp(e, sp.X, sp.Y, "Triangle", Color3.fromRGB(110, 210, 255), string.format("BATTLE ARENA [%dm]", math.floor(dist)))
                end
            end
        end
    end
    for i = usedWay + 1, #wayPool do hideIconWp(wayPool[i]) end

    if os.clock() - lastHudAt > 0.5 then
        lastHudAt = os.clock()
        updateChams()
    end
end))

-- Input: Infinite Jump & Ctrl+Click TP
addConn(UserInputService.JumpRequest:Connect(function()
    if S.unloaded or not S.infJump then return end
    local _, hum = char()
    if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end) end
end))

addConn(UserInputService.InputBegan:Connect(function(inp, gpe)
    if S.unloaded then return end
    if (inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch) and library.open and closeHitRect then
        local p = (inp.UserInputType == Enum.UserInputType.MouseButton1) and UserInputService:GetMouseLocation() or inp.Position
        if p.X >= closeHitRect.x1 and p.X <= closeHitRect.x2 and p.Y >= closeHitRect.y1 and p.Y <= closeHitRect.y2 then
            pcall(function() library:SetOpen(false) end)
            return
        end
    end
    if gpe then return end
    if S.menuKey and inp.KeyCode == S.menuKey then
        pcall(function() library:SetOpen(not library.open) end)
        return
    end
    if not S.clickTp then return end
    if inp.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        local m = LP:GetMouse()
        if m and m.Hit then tpPos(m.Hit.Position) end
    end
end))

-- Astral Rift & Event Alerts
pcall(function()
    local ar = ReplicatedStorage:FindFirstChild("AstralRealm")
    local ro = ar and ar:FindFirstChild("RiftOpened")
    if ro and ro:IsA("RemoteEvent") then
        addConn(ro.OnClientEvent:Connect(function()
            if S.riftNotify and not S.unloaded then notify("Astral Rift opened!", 5) end
        end))
    end
end)
for _, evInfo in ipairs({
    { "TimeStop", "TimeStop activated!" },
    { "AwkTsAlert", "Awakened TimeStop alert!" },
    { "RockWarningEvent", "Rock / Meteor warning!" },
}) do
    pcall(function()
        local ev = ReplicatedStorage:FindFirstChild(evInfo[1])
        if ev and ev:IsA("RemoteEvent") then
            addConn(ev.OnClientEvent:Connect(function()
                if S.eventAlerts and not S.unloaded then notify(evInfo[2], 3.5) end
            end))
        end
    end)
end

addConn(LP.CharacterAdded:Connect(function()
    if S.unloaded or not S.autoReEquip then return end
    task.wait(0.8)
    if S.unloaded or not S.autoReEquip then return end
    if S.lastSwordStand and S.lastSwordStand ~= "" and S.lastSwordStand ~= "none" then
        pcall(function() equipStandExact(S.lastSwordStand) end)
    end
end))

-- Stepped: Movement, Fly, Noclip, Anti-Void, Hitbox Expander (NPC, Player, Sword)
local lastSafeCF = nil
addConn(RunService.Stepped:Connect(function()
    if S.unloaded then return end
    local ch, hum, hrp = char()
    if ch and hum then
        if hrp then
            if hrp.Position.Y >= 980 then
                lastSafeCF = hrp.CFrame
            elseif S.antiVoid and hrp.Position.Y < 900 then
                pcall(function()
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.CFrame = lastSafeCF or CFrame.new(hrp.Position.X, 1110, hrp.Position.Z)
                end)
            end
        end
        if library.flags.disablemenumovement and library.open then
            pcall(function() hum.WalkSpeed = 0 end)
        elseif S.walkSpeedOn then
            pcall(function() hum.WalkSpeed = S.walkSpeed end)
        end
        if S.jumpPowerOn then
            pcall(function()
                hum.UseJumpPower = true
                hum.JumpPower = S.jumpPower
            end)
        end
        if S.noclip then
            for _, p in ipairs(ch:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
            end
        end
        if S.fly and hrp then
            if not flyBV or flyBV.Parent ~= hrp then
                stopFly()
                flyBV = Instance.new("BodyVelocity")
                flyBV.MaxForce = Vector3.new(1e6, 1e6, 1e6)
                flyBV.Parent = hrp
                flyBG = Instance.new("BodyGyro")
                flyBG.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
                flyBG.P = 9e4
                flyBG.Parent = hrp
            end
            hum.PlatformStand = true
            local cam = Workspace.CurrentCamera
            local dir = Vector3.zero
            if cam then
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0, 1, 0) end
                flyBG.CFrame = cam.CFrame
            end
            flyBV.Velocity = (dir.Magnitude > 0 and dir.Unit or Vector3.zero) * S.flySpeed
        elseif flyBV then
            stopFly()
        end

        if S.swordHitbox then
            local tool = ch:FindFirstChildOfClass("Tool")
            if tool then
                local expanded = false
                for _, d in ipairs(tool:GetDescendants()) do
                    if d:IsA("BasePart") and d:FindFirstChildWhichIsA("TouchTransmitter") then
                        applyHitbox(d, S.swordHitboxSize, "sword")
                        expanded = true
                    end
                end
                if not expanded then
                    local h = tool:FindFirstChild("Handle")
                    if h and h:IsA("BasePart") then applyHitbox(h, S.swordHitboxSize, "sword") end
                end
            end
        end
    end

    if S.npcHitbox then
        local npcs = npcList(0.35)
        for i = 1, #npcs do
            applyHitbox(npcs[i].root, S.npcHitboxSize, "npc")
        end
    end
    if S.plrHitbox then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character then
                local r = plr.Character:FindFirstChild("HumanoidRootPart")
                if r then applyHitbox(r, S.plrHitboxSize, "plr") end
            end
        end
    end
end))

-- Strip Kill Effects (safe: skips Tool descendants)
task.spawn(function()
    while not S.unloaded do
        task.wait(0.5)
        if not S.stripEffects then continue end
        local ch = LP.Character
        if ch then
            for _, d in ipairs(ch:GetDescendants()) do
                if (d.Name == "KillEffect" or d.Name == "KillEffectAttachment") and not d:FindFirstAncestorOfClass("Tool") then
                    pcall(function() d:Destroy() end)
                end
            end
        end
    end
end)

-- Mining + Auto Pickaxe Phase loop + telemetry
task.spawn(function()
    local telAt = 0
    local unlockAt = 0
    while not S.unloaded do
        task.wait(0.25)
        if os.clock() - telAt > 1.0 then
            telAt = os.clock()
            local a, as = stoneStats()
            pcall(function()
                mineAliveText:SetText("Alive Stones: " .. tostring(a))
                mineAstralText:SetText("Astral Ready: " .. tostring(as))
                mineStatusText:SetText("Target: " .. tostring(S.mineState))
                pickPhaseText:SetText("Phase Goal: " .. tostring(S.pickaxePhaseState))
            end)
        end
        if S.enabled or S.busy then continue end

        if S.autoPickaxePhase then
            local ch, hum = char()
            if not ch or not hum or hum.Health <= 0 then
                miningChar = nil
                continue
            end
            if not arenaOk() then
                enterArenaOnce(false)
            end
            if miningChar ~= ch or not ensurePickaxe() then
                miningChar = ch
                equipPickaxe()
            end
            local phases = pickaxePhases and pickaxePhases.Phases
            local curPhase = tonumber(ch:GetAttribute("PickaxePhase")) or 0
            local targetPhase = math.min(4, curPhase + 1)
            local targetData = phases and phases[targetPhase] or nil
            local curOres = tonumber(ch:GetAttribute("Ores")) or tonumber(ch:FindFirstChild("Ores") and ch.Ores.Value) or 0
            local curKills = sacKills()
            if targetData and curPhase < 4 then
                if targetData.Unlock and os.clock() - unlockAt > 4 then
                    unlockAt = os.clock()
                    local cm = ReplicatedStorage:FindFirstChild("CelestialMining")
                    local pu = cm and cm:FindFirstChild("PickaxeUnlock")
                    if pu then pcall(function() pu:InvokeServer(targetPhase) end) end
                end
                if curOres < (targetData.Ores or 0) then
                    S.pickaxePhaseState = string.format("P%d Ores %d/%d", targetPhase, curOres, targetData.Ores or 0)
                    local prevAuto = S.autoMine
                    S.autoMine = true
                    mineAll()
                    S.autoMine = prevAuto
                elseif curKills < (targetData.Kills or 0) then
                    S.pickaxePhaseState = string.format("P%d Kills %s/%s", targetPhase, fmt(curKills), fmt(targetData.Kills or 0))
                    applyProtection()
                    ensurePickaxe()
                    while S.autoPickaxePhase and not S.unloaded do
                        local cNow, hNow = char()
                        if not cNow or not hNow or hNow.Health <= 0 then break end
                        if sacKills() >= (targetData.Kills or 0) then break end
                        if (tonumber(cNow:GetAttribute("PickaxePhase")) or 0) >= targetPhase then break end
                        ensurePickaxe()
                        hitAll()
                        task.wait()
                    end
                else
                    S.pickaxePhaseState = string.format("P%d Ready (Unlock)", targetPhase)
                end
            else
                S.pickaxePhaseState = "Phase 4 / Maxed"
            end
            continue
        end

        if not S.autoMine then continue end
        local ch, hum = char()
        if not ch or not hum or hum.Health <= 0 then
            miningChar = nil
            continue
        end
        if not arenaOk() then
            enterArenaOnce(false)
        end
        if miningChar ~= ch or not ensurePickaxe() then
            miningChar = ch
            equipPickaxe()
        end
        mineAll()
    end
end)

-- Auto Sacrifice loop
task.spawn(function()
    local uiAt = 0
    local healAt = 0
    local armedChar = nil
    local arenaLostAt = os.clock()
    local relaySoftAt = os.clock()
    local relayHardAt = os.clock()
    while not S.unloaded do
        task.wait()
        if not S.enabled then
            armedChar = nil
            if os.clock() - uiAt > 0.25 then
                uiAt = os.clock()
                local _, earnedSh, rateSh = sessionShards()
                local _, lbEarned, lbRate = sessionLbKills()
                pcall(function()
                    shardsText:SetText(string.format("Session Shards: +%s (%.1f/hr)", tostring(earnedSh), rateSh))
                    lbKillsText:SetText(string.format("LB Kills: +%s (%s/hr)", fmt(lbEarned), fmt(lbRate)))
                    statusText:SetText("Status: idle")
                end)
            end
            continue
        end
        if S.busy then continue end

        local ch, hum = char()
        if not ch or not hum or hum.Health <= 0 then
            S.armed = false
            armedChar = nil
            arenaLostAt = os.clock()
            if os.clock() - uiAt > 0.25 then
                uiAt = os.clock()
                pcall(function() statusText:SetText("Status: respawning") end)
            end
            continue
        end

        if S.armed and armedChar ~= ch then
            S.armed = false
            armedChar = nil
            weaponCache = { char = nil, tool = nil, parts = nil }
            continue
        end

        applyProtection()
        if os.clock() - healAt > 0.1 then
            healAt = os.clock()
            if hum.Health < hum.MaxHealth then pcall(function() hum.Health = hum.MaxHealth end) end
        end

        if not S.armed then
            if not isEquipped() and not hasTool() then
                S.busy = true
                pcall(function() statusText:SetText("Status: equipping " .. S.sword) end)
                local ok = equipSword()
                S.busy = false
                if not ok then
                    pcall(function() statusText:SetText("Status: equip failed, retrying") end)
                    task.wait(0.2)
                end
                continue
            end
            S.busy = true
            pcall(function() statusText:SetText("Status: entering arena") end)
            if not arenaOk() then untilTrue(0.1, function() if not S.enabled and not S.killFarm then return true end return enterArenaOnce() end) end
            local toolAt = os.clock()
            untilTrue(0.05, function()
                if not S.enabled then return true end
                ensureTool(true)
                if hasTool() then return true end
                if os.clock() - toolAt > 2 then
                    toolAt = os.clock()
                    if not arenaOk() then goArena() end
                end
                return false
            end)
            if hasTool() then
                hopShrine()
                armedChar = LP.Character
                S.startKills = sacKills()
                S.armed = true
                arenaLostAt = os.clock()
                relaySoftAt = os.clock()
                relayHardAt = os.clock()
                lastKillAdvance = os.clock()
            else
                pcall(function() statusText:SetText("Status: waiting for sword") end)
            end
            S.busy = false
            continue
        end

        local inArena, near = arenaOk()
        if inArena then
            arenaLostAt = os.clock()
        elseif os.clock() - arenaLostAt > 3 then
            S.armed = false
            arenaLostAt = os.clock()
            weaponCache = { char = nil, tool = nil, parts = nil }
            npcCache.containers = nil
            pcall(function() statusText:SetText("Status: re-entering arena") end)
            untilTrue(0.1, function() if not S.enabled and not S.killFarm then return true end return enterArenaOnce() end)
            continue
        end

        if not weaponParts() or #weaponParts() == 0 then
            weaponCache = { char = nil, tool = nil, parts = nil }
            ensureTool(true)
        end

        local swept = hitAll()

        local target = SHARD_RULES[S.sword] or 5e10
        local gained = sacKills()
        if gained > 0 then
            lastKillAdvance = os.clock()
            relaySoftAt = os.clock()
            relayHardAt = os.clock()
        else
            local gap = os.clock() - relaySoftAt
            if inArena and (swept == 0 or gap > 4) and gap > 0.75 then
                relaySoftAt = os.clock()
                local c2 = LP.Character
                local t2 = c2 and c2:FindFirstChildOfClass("Tool")
                if t2 then pcall(function() t2.Enabled = true end) end
                weaponCache = { char = nil, tool = nil, parts = nil }
                npcCache.containers = nil
                ensureTool(true)
                if not hasTool() then pcall(equipSword) end
            end
            if os.clock() - relayHardAt > 20 then
                relayHardAt = os.clock()
                relaySoftAt = os.clock()
                S.armed = false
                armedChar = nil
                weaponCache = { char = nil, tool = nil, parts = nil }
                npcCache.containers = nil
                untilTrue(0.1, function() if not S.enabled and not S.killFarm then return true end return enterArenaOnce() end)
                continue
            end
        end

        if os.clock() - uiAt > 0.25 then
            uiAt = os.clock()
            local wp = weaponParts()
            local relay = (wp and #wp > 0) and "relay ok" or "no part"
            local _, earnedSh, rateSh = sessionShards()
            local _, lbEarned, lbRate = sessionLbKills()
            pcall(function()
                progressText:SetText(string.format("Kills: %s / %s", fmt(math.clamp(gained, 0, target)), fmt(target)))
                shardsText:SetText(string.format("Session Shards: +%s (%.1f/hr)", tostring(earnedSh), rateSh))
                lbKillsText:SetText(string.format("LB Kills: +%s (%s/hr)", fmt(lbEarned), fmt(lbRate)))
                statusText:SetText(string.format("Status: %s | npc %d | %s", S.sword, near or 0, relay))
            end)
        end

        if gained >= target then
            S.busy = true
            pcall(function() statusText:SetText("Status: sacrificing") end)
            local changed = false
            local cn = LP.CharacterAdded:Once(function() changed = true end)
            local ok = doSacrifice()
            if ok and S.resetOnSacrifice and not changed then
                local lc = ReplicatedStorage:FindFirstChild("LoadCharacter")
                if lc and lc:IsA("RemoteEvent") then pcall(function() lc:FireServer() end) end
                local chNow, humNow = char()
                if humNow and humNow.Health > 0 then pcall(function() humNow.Health = 0 end) end
                if chNow then pcall(function() chNow:BreakJoints() end) end
            end
            while not changed and not S.unloaded do task.wait() end
            pcall(function() cn:Disconnect() end)
            S.armed = false
            S.startKills = 0
            weaponCache = { char = nil, tool = nil, parts = nil }
            npcCache.containers = nil
            pcall(function() progressText:SetText("Kills: 0 / " .. fmt(target)) end)
            if not (ok or changed) then
                pcall(function() statusText:SetText("Status: sacrifice failed, retrying") end)
                task.wait(0.2)
            end
            S.busy = false
            arenaLostAt = os.clock()
        end
    end
end)

-- Kill All & Kill Aura loop
task.spawn(function()
    local arenaAt = os.clock()
    local healAt = 0
    while not S.unloaded do
        task.wait()
        if S.enabled or S.busy then continue end
        if not S.killFarm and not S.killAura then continue end
        local ch, hum = char()
        if not ch or not hum or hum.Health <= 0 then continue end
        if S.killFarm then
            applyProtection()
            if os.clock() - healAt > 0.1 then
                healAt = os.clock()
                if hum.Health < hum.MaxHealth then pcall(function() hum.Health = hum.MaxHealth end) end
            end
            local inArena = arenaOk()
            if not inArena then
                if os.clock() - arenaAt > 3 then
                    arenaAt = os.clock()
                    weaponCache = { char = nil, tool = nil, parts = nil }
                    npcCache.containers = nil
                    untilTrue(0.4, function() if not S.killFarm or S.enabled then return true end return enterArenaOnce(false) end)
                end
                continue
            end
            arenaAt = os.clock()
            if not weaponParts() or #weaponParts() == 0 then
                weaponCache = { char = nil, tool = nil, parts = nil }
                ensureTool(true)
            end
            hitAll()
        elseif S.killAura then
            if not weaponParts() or #weaponParts() == 0 then
                weaponCache = { char = nil, tool = nil, parts = nil }
                ensureTool(false)
            end
            hitNearby(S.auraRange)
        end
    end
end)

addConn(library.unloaded:Connect(function()
    if not S.unloaded and getgenv().Y7Hub and getgenv().Y7Hub.destroy then
        getgenv().Y7Hub.destroy()
    end
end))

getgenv().Y7Hub = {
    S = S,
    ui = "informant.wtf",
    library = library,
    destroy = function()
        if S.unloaded then return end
        S.unloaded = true
        if afkConn then pcall(function() afkConn:Disconnect() end); afkConn = nil end
        for i = 1, #conns do pcall(function() conns[i]:Disconnect() end) end
        table.clear(conns)
        S.enabled = false
        S.autoMine = false
        S.killFarm = false
        S.killAura = false
        S.mineAstral = false
        S.noclip = false
        S.fly = false
        S.npcHitbox = false
        S.plrHitbox = false
        S.swordHitbox = false
        stopFly()
        restoreHitboxes()
        local _, _, hr = char()
        if hr then pcall(function() hr.Anchored = false end) end
        if protect.active then clearProtection() end
        weaponCache = { char = nil, tool = nil, parts = nil }
        for _, hl in pairs(chamMap) do pcall(function() hl:Destroy() end) end
        table.clear(chamMap)
        for i = 1, #allDrawings do pcall(function() allDrawings[i]:Remove() end) end
        table.clear(allDrawings)
        if logoGui then pcall(function() logoGui:Destroy() end); logoGui = nil end
        pcall(function() library:Unload() end)
        getgenv().Y7Hub = nil
    end,
}

notify("Y7 Hub v2.2 loaded", 3)
