if game.PlaceId ~= 17265691026 and game.GameId ~= 6010086202 then 
    return 
end

local Venyx = loadstring(game:HttpGet("https://githubusercontent.com"))()
local UI = Venyx.new("Unnamed Enhancements | Rivals")

local CombatTab = UI:addPage("Combat", "rbxassetid://4483345998")
local VisualsTab = UI:addPage("Visuals", "rbxassetid://4483345998")
local SettingsTab = UI:addPage("Settings", "rbxassetid://4483345998")

local CombatSection = CombatTab:addSection("Main Rules")
local VisualsSection = VisualsTab:addSection("Rendering Engines")
local SettingsSection = SettingsTab:addSection("Performance Systems")

local AimbotEnabled = true
local SilentAimEnabled = false
local AntiFlashbangEnabled = true
local RemoveMuzzleEffects = false
local OptimizeSmokeVisibility = false
local TeamCheckEnabled = true
local HeadShotChance = 40 
local Smoothness = 4 
local MaxFOVDistance = 1000 
local FpsOptimizationEnabled = true
local SilentAimHitChance = 100
local AimbotHitChance = 100
local EspBoxesEnabled = false
local EspWeaponEnabled = false
local EspRankEnabled = false
local DeflectKatanaEnabled = false

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

CombatSection:addToggle("Right-Click Smooth Aimbot", true, function(Value)
    AimbotEnabled = Value
end)

CombatSection:addSlider("Aimbot Hit Chance (%)", 100, 0, 100, function(Value)
    AimbotHitChance = Value
end)

CombatSection:addToggle("Silent Aim [Toggle: Q]", false, function(Value)
    SilentAimEnabled = Value
end)

CombatSection:addSlider("Silent Aim Hit Chance (%)", 100, 0, 100, function(Value)
    SilentAimHitChance = Value
end)

CombatSection:addSlider("Headshot Distribution (%)", 40, 0, 100, function(Value)
    HeadShotChance = Value
end)

CombatSection:addSlider("Aimbot Smoothness Delay", 4, 1, 10, function(Value)
    Smoothness = Value
end)

CombatSection:addToggle("Auto Deflect Katana Projectiles", false, function(Value)
    DeflectKatanaEnabled = Value
end)

VisualsSection:addToggle("Box ESP", false, function(Value)
    EspBoxesEnabled = Value
end)

VisualsSection:addToggle("Show Held Weapons", false, function(Value)
    EspWeaponEnabled = Value
end)

VisualsSection:addToggle("Show Ranks", false, function(Value)
    EspRankEnabled = Value
end)

VisualsSection:addToggle("Anti-Flashbang Bypass", true, function(Value)
    AntiFlashbangEnabled = Value
end)

VisualsSection:addToggle("Remove Muzzle Flashes", false, function(Value)
    RemoveMuzzleEffects = Value
end)

VisualsSection:addToggle("See-Through Smoke Tweaks", false, function(Value)
    OptimizeSmokeVisibility = Value
end)

SettingsSection:addToggle("Team Check", true, function(Value)
    TeamCheckEnabled = Value
end)

SettingsSection:addToggle("Aggressive FPS Boost", true, function(Value)
    FpsOptimizationEnabled = Value
end)

SettingsSection:addKeybind("Minimize Menu Keybind", Enum.KeyCode.RightShift, function()
    UI:toggle()
end)

local BodyParts = {"HumanoidRootPart", "UpperTorso", "LowerTorso"}
local CurrentAimbotTarget = nil
local CurrentAimbotPart = nil
local IsAimbotTrackingThisTurn = false
local ActiveEspObjects = {}

local function CreateEspContainer(Player)
    if ActiveEspObjects[Player] then return end
    
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.fromRGB(0, 242, 254)
    Box.Thickness = 1
    Box.Filled = false
    
    local TextLabel = Drawing.new("Text")
    TextLabel.Visible = false
    TextLabel.Color = Color3.fromRGB(255, 255, 255)
    TextLabel.Size = 13
    TextLabel.Center = true
    TextLabel.Outline = true
    
    ActiveEspObjects[Player] = {Box = Box, TextLabel = TextLabel}
end

local function RemoveEspContainer(Player)
    if ActiveEspObjects[Player] then
        ActiveEspObjects[Player].Box:Remove()
        ActiveEspObjects[Player].TextLabel:Remove()
        ActiveEspObjects[Player] = nil
    end
end

local function GetPlayerHeldWeapon(Player)
    if Player.Character then
        local Tool = Player.Character:FindFirstChildOfClass("Tool")
        if Tool then return Tool.Name end
    end
    return "None"
end

local function GetPlayerRank(Player)
    local Leaderstats = Player:FindFirstChild("leaderstats")
    if Leaderstats then
        local RankVal = Leaderstats:FindFirstChild("Rank") or Leaderstats:FindFirstChild("Tier")
        if RankVal then return tostring(RankVal.Value) end
    end
    return "Unknown"
end

local function ProcessEspVisuals()
    for Player, Objects in pairs(ActiveEspObjects) do
        local Box = Objects.Box
        local TextLabel = Objects.TextLabel
        
        if Player and Player.Parent and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character:FindFirstChildOfClass("Humanoid") and Player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            if TeamCheckEnabled and Player.Team == LocalPlayer.Team then
                Box.Visible = false
                TextLabel.Visible = false
            else
                local RootPart = Player.Character.HumanoidRootPart
                local Position, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)
                
                if OnScreen then
                    local SizeY = (Camera:WorldToViewportPoint(RootPart.Position + Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(RootPart.Position - Vector3.new(0, 3, 0)).Y)
                    local SizeX = SizeY * 0.6
                    
                    if EspBoxesEnabled then
                        Box.Size = Vector2.new(math.abs(SizeX), math.abs(SizeY))
                        Box.Position = Vector2.new(Position.X - math.abs(SizeX) / 2, Position.Y - math.abs(SizeY) / 2)
                        Box.Visible = true
                    else
                        Box.Visible = false
                    end
                    
                    local DisplayString = ""
                    if EspRankEnabled then
                        DisplayString = DisplayString .. "[" .. GetPlayerRank(Player) .. "] "
                    end
                    if EspWeaponEnabled then
                        DisplayString = DisplayString .. "Weapon: " .. GetPlayerHeldWeapon(Player)
                    end
                    
                    if DisplayString ~= "" then
                        TextLabel.Text = DisplayString
                        TextLabel.Position = Vector2.new(Position.X, Position.Y + (math.abs(SizeY) / 2) + 5)
                        TextLabel.Visible = true
                    else
                        TextLabel.Visible = false
                    end
                else
                    Box.Visible = false
                    TextLabel.Visible = false
                end
            end
        else
            Box.Visible = false
            TextLabel.Visible = false
        end
    end
end

local function MonitorProjectiles()
    if not DeflectKatanaEnabled then return end
    local Projectiles = workspace:FindFirstChild("Projectiles")
    if Projectiles then
        for _, Projectile in ipairs(Projectiles:GetChildren()) do
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local LocalRoot = LocalPlayer.Character.HumanoidRootPart
                local Distance = (Projectile.Position - LocalRoot.Position).Magnitude
                if Distance < 15 and LocalPlayer.Character:FindFirstChild("Katana") then
                    local VirtualInputManager = game:GetService("VirtualInputManager")
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    task.wait()
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                end
            end
        end
    end
end

local function HandleEnvironmentVisuals(Item)
    if RemoveMuzzleEffects and (string.find(string.lower(Item.Name), "muzzle") or string.find(string.lower(Item.Name), "flash")) then
        if Item:IsA("ParticleEmitter") or Item:IsA("Light") then
            Item.Enabled = false
        end
    end
    if OptimizeSmokeVisibility and (string.find(string.lower(Item.Name), "smoke") or string.find(string.lower(Item.Name), "gas")) then
        if Item:IsA("ParticleEmitter") or Item:IsA("Smoke") then
            Item.Enabled = false
        elseif Item:IsA("BasePart") then
            Item.Transparency = 1
        end
    end
end

workspace.DescendantAdded:Connect(HandleEnvironmentVisuals)

local function GetTargetPart(TargetCharacter)
    if math.random(1, 100) <= HeadShotChance then
        return TargetCharacter:FindFirstChild("Head")
    else
        local SelectedPartName = BodyParts[math.random(1, #BodyParts)]
        local TargetPart = TargetCharacter:FindFirstChild(SelectedPartName)
        if TargetPart then
            return TargetPart
        else
            return TargetCharacter:FindFirstChild("HumanoidRootPart") or TargetCharacter:FindFirstChild("Torso")
        end
    end
end

local function GetClosestPlayerToCrosshair()
    local ClosestTarget = nil
    local ShortestDistance = MaxFOVDistance 
    local MousePos = UserInputService:GetMouseLocation()
    local CurrentPlayers = Players:GetPlayers()

    for i = 1, #CurrentPlayers do
        local Player = CurrentPlayers[i]
        if Player ~= LocalPlayer and Player.Character then
            if not TeamCheckEnabled or Player.Team ~= LocalPlayer.Team then
                local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
                if Humanoid and Humanoid.Health > 0 then
                    local RootPart = Player.Character:FindFirstChild("HumanoidRootPart")
                    if RootPart then
