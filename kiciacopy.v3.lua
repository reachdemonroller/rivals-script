if game.PlaceId ~= 17625359962 then 
    return 
end

local Rayfield = loadstring(game:HttpGet('https://githubusercontent.com'))()
local Window = Rayfield:CreateWindow({
   Name = "Unnamed Enhancements | Rivals",
   LoadingTitle = "kicia copy v3",
   LoadingSubtitle = "by ClosetTech",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local CombatTab = Window:CreateTab("Combat", 4483345998)
local VisualsTab = Window:CreateTab("Visuals", 4483345998)
local SettingsTab = Window:CreateTab("Settings", 4483345998)

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

CombatTab:CreateToggle({
   Name = "Right-Click Smooth Aimbot",
   CurrentValue = true,
   Callback = function(Value) AimbotEnabled = Value end,
})

CombatTab:CreateSlider({
   Name = "Aimbot Hit Chance (%)",
   Min = 0,
   Max = 100,
   CurrentValue = 100,
   Increment = 1,
   Callback = function(Value) AimbotHitChance = Value end,
})

CombatTab:CreateToggle({
   Name = "Silent Aim [Toggle: Q]",
   CurrentValue = false,
   Callback = function(Value) SilentAimEnabled = Value end,
})

CombatTab:CreateSlider({
   Name = "Silent Aim Hit Chance (%)",
   Min = 0,
   Max = 100,
   CurrentValue = 100,
   Increment = 1,
   Callback = function(Value) SilentAimHitChance = Value end,
})

CombatTab:CreateSlider({
   Name = "Headshot Distribution (%)",
   Min = 0,
   Max = 100,
   CurrentValue = 40,
   Increment = 1,
   Callback = function(Value) HeadShotChance = Value end,
})

CombatTab:CreateSlider({
   Name = "Aimbot Smoothness Delay",
   Min = 1,
   Max = 10,
   CurrentValue = 4,
   Increment = 1,
   Callback = function(Value) Smoothness = Value end,
})

CombatTab:CreateToggle({
   Name = "Auto Deflect Katana Projectiles",
   CurrentValue = false,
   Callback = function(Value) DeflectKatanaEnabled = Value end,
})

VisualsTab:CreateToggle({
   Name = "Box ESP",
   CurrentValue = false,
   Callback = function(Value) EspBoxesEnabled = Value end,
})

VisualsTab:CreateToggle({
   Name = "Show Held Weapons",
   CurrentValue = false,
   Callback = function(Value) EspWeaponEnabled = Value end,
})

VisualsTab:CreateToggle({
   Name = "Show Ranks",
   CurrentValue = false,
   Callback = function(Value) EspRankEnabled = Value end,
})

VisualsTab:CreateToggle({
   Name = "Anti-Flashbang Bypass",
   CurrentValue = true,
   Callback = function(Value) AntiFlashbangEnabled = Value end,
})

VisualsTab:CreateToggle({
   Name = "Remove Muzzle Flashes",
   CurrentValue = false,
   Callback = function(Value) RemoveMuzzleEffects = Value end,
})

VisualsTab:CreateToggle({
   Name = "See-Through Smoke Tweaks",
   CurrentValue = false,
   Callback = function(Value) OptimizeSmokeVisibility = Value end,
})

SettingsTab:CreateToggle({
   Name = "Team Check",
   CurrentValue = true,
   Callback = function(Value) TeamCheckEnabled = Value end,
})

SettingsTab:CreateToggle({
   Name = "Aggressive FPS Boost",
   CurrentValue = true,
   Callback = function(Value) FpsOptimizationEnabled = Value end,
})

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

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
                    if EspRankEnabled then DisplayString = DisplayString .. "[" .. GetPlayerRank(Player) .. "] " end
                    if EspWeaponEnabled then DisplayString = DisplayString .. "Weapon: " .. GetPlayerHeldWeapon(Player) end
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
                    task.wait(0.05)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    ProcessEspVisuals()
    MonitorProjectiles()
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then CreateEspContainer(player) end
end
Players.PlayerAdded:Connect(CreateEspContainer)
Players.PlayerRemoving:Connect(RemoveEspContainer)
