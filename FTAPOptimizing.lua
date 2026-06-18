--if not _G.Isalreadythere then return end
_G.Isalreadythere = true

-- global vars
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local lplr = Players.LocalPlayer
local t = 3600

local hrptoys = {
    CreatureBlobman = true,
    NpcRobloxianMascot = true,
    PetSnowman = true,
    PetTurkeyLeg = true,
    YouDecoy = true,
    YouLittle = true,
}

local nonetoys = {
    BombDarkMatter = true,
    BombBalloon = true,
}

local pourtoys = {
    BathroomShower = true,
    BathroomSink = true,
    BucketPaint = true,
    ToiletGold = true,
    ToiletWhite = true,
}

local stickytoys = {
    NinjaKatana = true,
    NinjaKunai = true,
    NinjaShuriken = true,
    ToolCleaver = true,
    ToolDiggingForkRusty = true,
    ToolPencil = true,
    ToolPickaxe = true,
}

function hasSoundpart(m)
    return (not hrptoys[m.Name] and not nonetoys[m.Name])
end

local scripts = lplr.PlayerScripts -- get these rinky dink ass scripts out of here
scripts.HRPSounds.Disabled = true
scripts.PartHitSound.Disabled = true
scripts.CreatureClientAnimationPlayer.Disabled = true
scripts.PourStreams.Disabled = true
scripts.StickyPartsTouchDetection.Disabled = true

-- localplayer.HRPSounds
function HRPSound(m)
    if not (hrptoys[m.Name] or m.Parent == workspace or m.Parent == workspace.Robloxians) then return end
    local hrp = m:WaitForChild("HumanoidRootPart", t)
    hrp:WaitForChild("Running", t).Volume = 0.081
    hrp:WaitForChild("Climbing", t).Volume = 0.162
    hrp:WaitForChild("Died", t).Volume = 0.162
    hrp:WaitForChild("FreeFalling", t).Volume = 0.25
    hrp:WaitForChild("Jumping", t).Volume = 0.162
end

workspace.Robloxians.ChildAdded:Connect(HRPSound)


-- localplayer.PartHitSound
local Hit = ReplicatedFirst:WaitForChild("HitSounds"):WaitForChild("Hit")
local Rock = Hit.Rock
local Metal = Hit.Metal
local Electric = Hit.Electric
local Glass = Hit.Glass
local HardPlastic = Hit.HardPlastic
local SoftBrush = Hit.SoftBrush
local Wood = Hit.Wood
local t = {}

local waittime = 1/8

local function connectHit(prt)
    local sound = (prt.Material == Enum.Material.CorrodedMetal
    or prt.Material == Enum.Material.DiamondPlate
    or prt.Material == Enum.Material.Foil
    or prt.Material == Enum.Material.Metal) and Metal:Clone()

    or (prt.Material == Enum.Material.Fabric
    or prt.Material == Enum.Material.Grass
    or prt.Material == Enum.Material.Sand) and SoftBrush:Clone()

    or (prt.Material == Enum.Material.Glass
    or prt.Material == Enum.Material.Ice) and Glass:Clone()

    or (prt.Material == Enum.Material.Wood
    or prt.Material == Enum.Material.WoodPlanks) and Wood:Clone()

    or (prt.Material == Enum.Material.ForceField
    or prt.Material == Enum.Material.Neon) and Electric:Clone()

    or (prt.Material == Enum.Material.SmoothPlastic
    or prt.Material == Enum.Material.Plastic) and HardPlastic:Clone()

    or Rock:Clone()

    sound.Parent = prt
    local Debounce = false
    local vol = sound.Volume / 50
    prt.Touched:Connect(function(CPart) -- colliding part bro what do you mean
        if Debounce then return end
        local HitSound = prt:FindFirstChild("HitSound")
        if HitSound then
            sound:Destroy()
            sound = HitSound
            if HitSound.Looped == true then
                HitSound.Looped = false
            end
        end
        if CPart.Parent:FindFirstChildOfClass("Humanoid") or CPart.Parent:IsA("Accessory") or CPart.Parent.Name == "HumanoidRootPart" then return end
        Debounce = true
        local Magnitude = (prt.AssemblyLinearVelocity - CPart.AssemblyLinearVelocity).Magnitude
        local playinsound = sound:Clone()
        if Magnitude > 0.25 then
            if Magnitude > 50 then
                playinsound.Volume = vol * 50
            else
                playinsound.Volume = vol * Magnitude
            end
            playinsound.Parent = sound.Parent
            playinsound:Play()
            Debris:AddItem(playinsound, 3)
        end
        wait(waittime)
        Debounce = false
    end)
end

-- localplayer.CreatureClientAnimationPlayer
local LoadCreatureAnimations = ReplicatedStorage:WaitForChild("CreatureEvents"):WaitForChild("LoadCreatureAnimations")
local PlayCreatureAnimation = ReplicatedStorage.CreatureEvents:WaitForChild("PlayCreatureAnimation")
local AdjustSpeedCreatureAnimation = ReplicatedStorage.CreatureEvents:WaitForChild("AdjustSpeedCreatureAnimation")
local AdjustTimeCreatureAnimation = ReplicatedStorage.CreatureEvents:WaitForChild("AdjustTimeCreatureAnimation")
local tabl = {}

local function loadInAllAnimations(prt, prt2)
    local Animator = prt:WaitForChild("Animator")
    local t2 = {}
    for k, v in pairs(prt2:GetChildren()) do
        if v:IsA("Animation") then
            table.insert(t2, Animator:LoadAnimation(v))
        end
    end
    tabl[prt] = t2
    prt.AncestryChanged:Connect(function()
        if prt:IsDescendantOf(game) then return end
        tabl[prt] = nil
    end)
end

LoadCreatureAnimations.OnClientEvent:Connect(function(prt, prt2)
    loadInAllAnimations(prt, prt2)
end)

PlayCreatureAnimation.OnClientEvent:Connect(function(prt, prt2, name, value)
    if prt == Players.LocalPlayer then
        return
    end
    if value == true then
        for k, v in pairs(tabl[prt2]) do
            if v.Name == name then
                v:Play()
                return
            end
        end
    else
        for k, v in pairs(tabl[prt2]) do
            if v.Name == name then
                v:Stop()
                return
            end
        end
    end
end)
AdjustSpeedCreatureAnimation.OnClientEvent:Connect(function(prt, prt2, name, value)
    if prt == Players.LocalPlayer then
        return
    end
    for k, v in pairs(tabl[prt2]) do
        if v.Name == name then
            v:AdjustSpeed(value)
            return
        end
    end
end)
AdjustTimeCreatureAnimation.OnClientEvent:Connect(function(prt, prt2, name, value) --[[ Line: 85 | Upvalues: Players (copy), t (copy) ]]
    if prt == Players.LocalPlayer then
        return
    end
    for k, v in pairs(tabl[prt2]) do
        if v.Name == name then
            v.TimePosition = value
            return
        end
    end
end)


-- localplayer.PourStreams
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PourCurveCalculations = require(ReplicatedStorage:WaitForChild("PourCurveCalculations"))
local Gravity = workspace.Gravity
local table2 = {}

RunService.Heartbeat:Connect(function()
    for k, v in pairs(table2) do
        v.pourPart.WorldPosition = v.beginAttach.WorldPosition + Vector3.new(v.speed * v.pourPart.CFrame.UpVector.X * v.seconds, v.speed * v.pourPart.CFrame.UpVector.Y * v.seconds + 0.5 * -Gravity * v.seconds ^ 2, v.speed * v.pourPart.CFrame.UpVector.Z * v.seconds)
    end
end)

local function makePourPartCurve(prt)
    local PourBeam = prt:WaitForChild("PourBeam")
    local t2 = {
        pourPart = prt,
        seconds = PourBeam:WaitForChild("TimeSeconds").Value,
        speed = PourBeam:WaitForChild("InitialSpeed").Value,
        beginAttach = prt:WaitForChild("BeginAttachment"),
        endAttach = prt:WaitForChild("EndAttachment")
    }
    table.insert(table2, t2)
    PourBeam.CurveSize0 = t2.speed * 0.56 * t2.seconds
    prt.AncestryChanged:Connect(function(CPart)
        if prt:IsDescendantOf(workspace) then return end
        for k, v in pairs(table2) do
            if v.pourPart == prt then
                table.remove(table2, k)
                return
            end
        end
    end)
end

-- localplayer.StickyPartsTouchDetection
local Players = game:GetService("Players")
local StickyPartEvent = game:GetService("ReplicatedStorage").PlayerEvents.StickyPartEvent
local LocalPlayer = Players.LocalPlayer
local v1 = OverlapParams.new()

local dosticky = true
local allsticky = false

function makeStickyPart(prt)
    prt.Touched:Connect(function(CPart)
        if not dosticky then return end
        if not CPart.Parent:FindFirstChildOfClass("Humanoid") and not allsticky then return end
        StickyPartEvent:FireServer(prt, CPart, CPart.CFrame:ToObjectSpace(prt.CFrame))
    end)
end

-- connecting all that stuff
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(HRPSound)
    workspace:WaitForChild(plr.Name.."SpawnedInToys", t).ChildAdded:Connect(function(m)
        HRPSound(m)
        task.spawn(function()
            if hasSoundpart(m) then
                connectHit(m:WaitForChild("SoundPart", t))
            end
        end)
        task.spawn(function()
            if pourtoys[m.Name] then
                makePourPartCurve(m:WaitForChild("PourPart", t))
            end
        end)
        task.spawn(function()
            if stickytoys[m.Name] then
                makeStickyPart(m:WaitForChild("StickyPart", t))
            end
        end)
        if m.Name == "CreatureBlobman" then
            local h = m:WaitForChild("HumanoidCreature", t)
            loadInAllAnimations(h, h.Parent:WaitForChild("ClientAnimations", t))
        end
    end)
end)

for _, plr in pairs(Players:GetPlayers()) do
    plr.CharacterAdded:Connect(HRPSound)
    workspace:WaitForChild(plr.Name.."SpawnedInToys", t).ChildAdded:Connect(function(m)
        HRPSound(m)
        task.spawn(function()
            if hasSoundpart(m) then
                connectHit(m:WaitForChild("SoundPart", t))
            end
        end)
        task.spawn(function()
            if pourtoys[m.Name] then
                makePourPartCurve(m:WaitForChild("PourPart", t))
            end
        end)
        task.spawn(function()
            if stickytoys[m.Name] then
                makeStickyPart(m:WaitForChild("StickyPart", t))
            end
        end)
        if m.Name == "CreatureBlobman" then
            local h = m:WaitForChild("HumanoidCreature", t)
            loadInAllAnimations(h, h.Parent:WaitForChild("ClientAnimations", t))
        end
    end)
    for _, m in pairs(workspace[plr.Name.."SpawnedInToys"]:GetChildren()) do
        task.spawn(function()
            if hasSoundpart(m) then
                connectHit(m:WaitForChild("SoundPart", t))
            end
        end)
        task.spawn(function()
            if pourtoys[m.Name] then
                makePourPartCurve(m:WaitForChild("PourPart", t))
            end
        end)
        task.spawn(function()
            if stickytoys[m.Name] then
                makeStickyPart(m:WaitForChild("StickyPart", t))
            end
        end)
        if m.Name == "CreatureBlobman" then
            local h = m:WaitForChild("HumanoidCreature", t)
            loadInAllAnimations(h, h.Parent:WaitForChild("ClientAnimations", t))
        end
    end
end

-- you can use these thingos like a modulescript to change the settings and stuff
return {
    ChangeWait = function(v) waittime = v end,
    DoSticky = function(v) dosticky = v end,
    AllSticky = function(v) allsticky = v end,
}
