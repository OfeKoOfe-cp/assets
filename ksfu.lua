if getgenv().KSFUSac and getgenv().KSFUSac.destroy then pcall(getgenv().KSFUSac.destroy) end
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local S = {
    enabled = false,
    sword = "APOTHESIS",
    scale = 200, width = 100, length = 500,
    killed = false, entering = false, busy = false,
    startKills = 0,
}
local conns = {}
local function on(sig, fn) table.insert(conns, sig:Connect(fn)) end
local function char()
    local c = LP.Character
    return c, c and c:FindFirstChildOfClass("Humanoid"), c and c:FindFirstChild("HumanoidRootPart")
end
local function fmt(n)
    if type(n) ~= "number" then return tostring(n) end
    if n >= 1e12 then return string.format("%.2ft", n / 1e12) end
    if n >= 1e9 then return string.format("%.2fb", n / 1e9) end
    if n >= 1e6 then return string.format("%.2fm", n / 1e6) end
    if n >= 1e3 then return string.format("%.1fk", n / 1e3) end
    return tostring(math.floor(n))
end
local PHASES = {
    APOTHESIS = {
        { 0, "Magmatics", "Magmatic Monster" },
        { 1e3, "Magmatics", "Magmatic Lord" },
        { 1e4, "Voids", "Void King" },
        { 1e6, "Dimensional Beings", "Existential" },
        { 5e7, "Dimensional Beings", "Realmshatter" },
    },
    DARKSTAR = {
        { 0, "Zombies", "Zombie" },
        { 1, "Magmatics", "Magmatic Monster" },
        { 250, "Magmatics", "Magmatic Lord" },
        { 1500, "Guests", "Guest 666" },
        { 5e4, "Voids", "Void King" },
        { 175000, "Abyssals", "Abyssal King" },
        { 5e6, "Castle Dummies", "God of Dummies" },
        { 5e8, "Dimensional Beings", "Godverse" },
    },
    CURSE = {
        { 0, "Bacons", "Bacon" },
        { 25, "Magmatics", "Magmatic Monster" },
        { 3500, "Voids", "Void King" },
        { 5.25e6, "Castle Dummies", "God of Dummies" },
        { 1e9, "Dimensional Beings", "Godverse" },
    },
}
local SHARD_RULES = { APOTHESIS = 5e7, DARKSTAR = 9e8, CURSE = 5e10 }
local function folderOf(name)
    local map = workspace:FindFirstChild("Map")
    local h = map and map:FindFirstChild("Humanoids")
    return h and h:FindFirstChild(name) or nil
end
local function swordKills()
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
    local ls = LP:FindFirstChild("leaderstats")
    local v = ls and ls:FindFirstChild("Kills")
    return v and tonumber(v.Value) or 0
end
local function voidShards()
    local ls = LP:FindFirstChild("leaderstats")
    local v = ls and ls:FindFirstChild("VoidShards")
    return v and tonumber(v.Value) or 0
end
local function clearProtection()
    local ch = LP.Character
    if ch then
        for _, d in ipairs(ch:GetChildren()) do
            if d:IsA("ForceField") then pcall(function() d:Destroy() end) end
            if d:IsA("BoolValue") and d.Name == "CanBeKilled?" then pcall(function() d.Value = true end) end
        end
    end
end
local function protect()
    local ch = LP.Character
    if not ch then return end
    for _, d in ipairs(ch:GetChildren()) do
        if d:IsA("BoolValue") and d.Name == "CanBeKilled?" then pcall(function() d.Value = false end) end
    end
    if not ch:FindFirstChildOfClass("ForceField") then
        local ff = Instance.new("ForceField")
        ff.Visible = false
        ff.Parent = ch
    end
end
local function equipSword()
    local map = workspace:FindFirstChild("Map")
    local f = map and map:FindFirstChild("Sword Stands")
    if not f then return false end
    local models = { APOTHESIS = "Apothesis", DARKSTAR = "DarkStar", CURSE = "CURSE" }
    local m = f:FindFirstChild(models[S.sword] or "Apothesis")
    if not m then return false end
    local hb = m:FindFirstChild("Hitbox")
    if hb and hb:IsA("BasePart") then
        local _, _, hrp = char()
        if hrp then hrp.CFrame = CFrame.new(hb.Position + Vector3.new(0, 3, 0)) end
        task.wait(0.4)
        local cd = hb:FindFirstChildOfClass("ClickDetector") or (m:FindFirstChild("Part") and m.Part:FindFirstChildOfClass("ClickDetector"))
        if cd then pcall(fireclickdetector, cd, 0, "MouseClick") end
        return true
    end
    return false
end
local function enterArena()
    local map = workspace:FindFirstChild("Map")
    local bp = map and map:FindFirstChild("BattleArenaPortal")
    if not bp then return end
    local sum, n = Vector3.zero, 0
    for _, d in ipairs(bp:GetDescendants()) do
        if d:IsA("BasePart") then sum += d.Position; n += 1 end
    end
    if n == 0 then return end
    local _, _, hrp = char()
    if hrp then
        hrp.CFrame = CFrame.new(sum / n)
        task.wait(0.25)
        if firetouchinterest then
            for _, d in ipairs(bp:GetDescendants()) do
                if d:IsA("BasePart") then
                    pcall(firetouchinterest, d, hrp, 0)
                    pcall(firetouchinterest, d, hrp, 1)
                end
            end
        end
    end
end
local function sacrifice()
    local shrine = workspace:FindFirstChild("VO!D $HR1NE")
    local part = shrine and shrine:FindFirstChild("VoidShrinePrompt")
    if not part then return false end
    local prompt = part:FindFirstChildOfClass("ProximityPrompt")
    local before = voidShards()
    clearProtection()
    local _, _, hrp = char()
    if hrp then
        pcall(function() hrp.Anchored = false end)
        hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 2, 0))
    end
    task.wait(0.4)
    if prompt then
        local original = prompt.HoldDuration
        pcall(function() prompt.HoldDuration = 0 end)
        pcall(fireproximityprompt, prompt)
        pcall(function() prompt.HoldDuration = original end)
    end
    pcall(function() game:GetService("ReplicatedStorage").Sacrifice:FireServer() end)
    task.wait(0.8)
    local after = voidShards()
    print("[sac] void shards " .. tostring(before) .. " -> " .. tostring(after))
    return after > before
end
local reachTool, orig = nil, {}
local function applyReach()
    local c = LP.Character
    local t = c and c:FindFirstChildOfClass("Tool")
    if not t then return end
    if reachTool ~= t then reachTool = t; orig = {} end
    for _, d in ipairs(t:GetDescendants()) do
        local handle = d.Name == "Handle"
        if d:IsA("BasePart") then
            if not orig[d] then orig[d] = d.Size end
            local o = orig[d]
            if handle then
                local w = math.max(S.width, 0.5) * 2
                d.Size = Vector3.new(w, w, w)
            else
                d.Size = Vector3.new(o.X * S.scale, o.Y * S.scale, o.Z * S.scale)
            end
            d.CanCollide = false
            d.CanTouch = true
            d.Massless = true
        end
    end
end
local function clearReach()
    for d, sz in pairs(orig) do if d.Parent then pcall(function() d.Size = sz end) end end
    orig = {}
    reachTool = nil
end
local ext
local function updateExt()
    local c = LP.Character
    local t = c and c:FindFirstChildOfClass("Tool")
    if not t then return end
    local blade
    for _, d in ipairs(t:GetDescendants()) do if d:IsA("BasePart") and d.Name ~= "Handle" then blade = d; break end end
    if not blade then return end
    if not ext then
        ext = Instance.new("Part")
        ext.Name = "ksfu_reach"
        ext.Transparency = 1
        ext.CanCollide = false
        ext.CanTouch = true
        ext.Massless = true
        ext.Anchored = true
        ext.Parent = t
    end
    ext.Size = Vector3.new(math.max(S.width, 0.5), math.max(S.width, 0.5), S.length)
    ext.CFrame = blade.CFrame * CFrame.new(0, 0, S.length / 2)
end
on(RunService.RenderStepped, function()
    if not S.enabled then return end
    applyProtection()
    local _, hum = char()
    if hum and hum.Health < hum.MaxHealth then pcall(function() hum.Health = hum.MaxHealth end) end
    applyReach()
    updateExt()
end)
task.spawn(function()
    while true do
        task.wait(0.3)
        if not S.enabled then continue end
        if S.busy then continue end
        if S.entering then
            local _, _, r = char()
            if r and r.Position.Y < 2000 then
                S.entering = false
                print("[sac] in arena, resuming")
            else
                enterArena()
                task.wait(0.5)
            end
            continue
        end
        if not S.killed then
            S.busy = true
            if equipSword() then
                enterArena()
                task.wait(0.6)
                S.killed = true
                S.startKills = swordKills()
                print("[sac] equipped " .. S.sword .. ", kills=" .. fmt(S.startKills))
            end
            S.busy = false
            continue
        end
        local gained = swordKills() - S.startKills
        if gained < 0 then S.startKills = swordKills(); gained = 0 end
        if gained >= (SHARD_RULES[S.sword] or 5e7) then
            S.busy = true
            local ok = sacrifice()
            local changed = false
            local cn = LP.CharacterAdded:Once(function() changed = true end)
            local t0 = os.clock()
            while not changed and os.clock() - t0 < 12 do task.wait(0.2) end
            pcall(function() cn:Disconnect() end)
            if ok or changed then
                enterArena()
                S.entering = true
                S.startKills = 0
                print("[sac] success, entering arena")
            else
                print("[sac] failed, retrying")
                task.wait(2)
            end
            S.busy = false
            continue
        end
        local stages = PHASES[S.sword] or PHASES.APOTHESIS
        local chosen = stages[1]
        for _, st in ipairs(stages) do if gained >= st[1] then chosen = st end end
        local folder = folderOf(chosen[2])
        if folder then
            local best, bestName = nil, nil
            for _, m in ipairs(folder:GetChildren()) do
                if m:IsA("Model") then
                    local hum = m:FindFirstChildOfClass("Humanoid")
                    local root = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("Torso")
                    if hum and root and hum.Health > 0 then
                        if chosen[3] and m.Name:lower():find(chosen[3]:lower(), 1, true) then
                            best, bestName = root, m.Name
                        elseif not bestName then
                            best, bestName = root, m.Name
                        end
                    end
                end
            end
            if best then
                local _, _, hrp = char()
                if hrp then
                    pcall(function() hrp.Anchored = false end)
                    hrp.CFrame = CFrame.new(best.Position + Vector3.new(0, -6, 0))
                    task.wait(0.15)
                    pcall(function() hrp.Anchored = true end)
                    for _, p in ipairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
                    local tool = LP.Character:FindFirstChildOfClass("Tool")
                    if tool then pcall(function() tool:Activate() end) end
                end
            end
        end
    end
end)
getgenv().KSFUCleanup = function()
	for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
	clearProtection(); clearReach()
	if ext then pcall(function() ext:Destroy() end) end
	if getgenv().KSFUSacUI then pcall(function() getgenv().KSFUSacUI:Destroy() end) end
	getgenv().KSFUSac = nil
	getgenv().KSFUCleanup = nil
end
if getgenv().KSFUSacUI then pcall(function() getgenv().KSFUSacUI:Destroy() end) end
local PlayerGui = LP:WaitForChild("PlayerGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KSFUSacUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui
getgenv().KSFUSacUI = ScreenGui
local Window = Instance.new("Frame")
Window.Size = UDim2.fromOffset(200, 158)
Window.Position = UDim2.new(0, 30, 0, 90)
Window.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Window.BorderSizePixel = 0
Window.Active = true
Window.Draggable = true
Window.Parent = ScreenGui
Instance.new("UICorner", Window).CornerRadius = UDim.new(0, 6)
local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 22)
top.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
top.BorderSizePixel = 0
top.Parent = Window
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -14, 1, 0)
title.Position = UDim2.fromOffset(9, 0)
title.BackgroundTransparency = 1
title.Text = "sacrifice"
title.Font = Enum.Font.Gotham
title.TextSize = 11
title.TextColor3 = Color3.fromRGB(190, 190, 200)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top
local body = Instance.new("Frame")
body.Size = UDim2.new(1, -16, 1, -30)
body.Position = UDim2.fromOffset(8, 26)
body.BackgroundTransparency = 1
body.Parent = Window
local bl = Instance.new("UIListLayout", body)
bl.Padding = UDim.new(0, 4)
local function row(height)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, height or 20)
    f.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    f.BorderSizePixel = 0
    f.Parent = body
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
    return f
end
local function label(parent, text, x, w)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.fromOffset(w or 100, 14)
    l.Position = UDim2.new(0, x or 8, 0.5, -7)
    l.BackgroundTransparency = 1
    l.Text = text
    l.Font = Enum.Font.Gotham
    l.TextSize = 10
    l.TextColor3 = Color3.fromRGB(165, 165, 175)
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end
local tr = row(22)
local toggleLabel = label(tr, "auto sacrifice", 8, 110)
local knobBg = Instance.new("TextButton")
knobBg.Size = UDim2.fromOffset(24, 12)
knobBg.Position = UDim2.new(1, -32, 0.5, -6)
knobBg.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
knobBg.BorderSizePixel = 0
knobBg.Text = ""
knobBg.Parent = tr
Instance.new("UICorner", knobBg).CornerRadius = UDim.new(1, 0)
local knob = Instance.new("Frame")
knob.Size = UDim2.fromOffset(8, 8)
knob.Position = UDim2.fromOffset(2, 2)
knob.BackgroundColor3 = Color3.fromRGB(220, 220, 230)
knob.BorderSizePixel = 0
knob.Parent = knobBg
Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
local sr = row(20)
local Status = label(sr, "idle", 8, 176)
Status.TextWrapped = false
local wr = row(20)
label(wr, "sword", 8, 40)
local swordBtn = Instance.new("TextButton")
swordBtn.Size = UDim2.fromOffset(100, 14)
swordBtn.Position = UDim2.new(1, -108, 0.5, -7)
swordBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 46)
swordBtn.BorderSizePixel = 0
swordBtn.Text = "APOTHESIS"
swordBtn.Font = Enum.Font.Gotham
swordBtn.TextSize = 10
swordBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
swordBtn.Parent = wr
Instance.new("UICorner", swordBtn).CornerRadius = UDim.new(0, 3)
local rr = row(20)
local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(1, -16, 0, 14)
resetBtn.Position = UDim2.fromOffset(8, 3)
resetBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 46)
resetBtn.BorderSizePixel = 0
resetBtn.Text = "reset cycle"
resetBtn.Font = Enum.Font.Gotham
resetBtn.TextSize = 10
resetBtn.TextColor3 = Color3.fromRGB(190, 190, 200)
resetBtn.Parent = rr
Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 3)
local function refreshKnob()
    knobBg.BackgroundColor3 = S.enabled and Color3.fromRGB(70, 110, 80) or Color3.fromRGB(45, 45, 52)
    knob.Position = UDim2.fromOffset(S.enabled and 14 or 2, 2)
end
local function updateStatus()
    local gained = S.killed and (swordKills() - S.startKills) or 0
    Status.Text = string.format("%s  %s/%s", S.sword, fmt(gained), fmt(SHARD_RULES[S.sword] or 5e7))
end
knobBg.MouseButton1Click:Connect(function()
    S.enabled = not S.enabled
    refreshKnob()
    if not S.enabled then
        S.busy, S.entering = false, false
        clearProtection(); clearReach()
        if ext then pcall(function() ext:Destroy() end); ext = nil end
    end
    updateStatus()
end)
local swordList = { "APOTHESIS", "DARKSTAR", "CURSE" }
local swordIndex = 1
swordBtn.MouseButton1Click:Connect(function()
    swordIndex = swordIndex % #swordList + 1
    S.sword = swordList[swordIndex]
    S.killed = false
    swordBtn.Text = S.sword
    updateStatus()
end)
resetBtn.MouseButton1Click:Connect(function()
    S.killed = false; S.startKills = 0; S.entering = false
    updateStatus()
end)
task.spawn(function()
    while ScreenGui.Parent do
        task.wait(0.5)
        updateStatus()
    end
end)
getgenv().KSFUSac = { S = S, destroy = function() pcall(function() ScreenGui:Destroy() end) end }
refreshKnob()
print("[ksfu] sacrifice standalone loaded")
