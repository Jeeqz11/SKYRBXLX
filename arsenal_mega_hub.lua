local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source.lua"))()

local Window = Rayfield:CreateWindow({
    Name = "SKY Arsenal Hub",
    LoadingTitle = "SKY Arsenal",
    LoadingSubtitle = "by jeeqz11",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "SKYArsenalConfigs",
        FileName = "Settings"
    },
    KeySystem = false
})

-- Variables
local AimbotEnabled, ESPEnabled = false, false
local Smoothness, FOVSize = 0.2, 120
local TeamCheck = true
local AimPart = "Head"
local Holding = false

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(0, 255, 0)
FOVCircle.Radius = FOVSize
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Visible = true

-- Arsenal enemy check
local function IsEnemy(player)
    return player.Team ~= LocalPlayer.Team
end

-- Get closest player
local function GetClosest()
    local closest, dist = nil, math.huge
    local mouseLocation = UIS:GetMouseLocation()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(AimPart) and (not TeamCheck or IsEnemy(player)) then
            local pos, visible = Camera:WorldToViewportPoint(player.Character[AimPart].Position)
            if visible then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouseLocation.X, mouseLocation.Y)).Magnitude
                if mag < dist and mag < FOVSize then
                    closest, dist = player, mag
                end
            end
        end
    end
    return closest
end

-- Aimbot logic
UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Holding = true
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Holding = false
    end
end)

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UIS:GetMouseLocation()
    FOVCircle.Radius = FOVSize
    FOVCircle.Visible = AimbotEnabled

    if AimbotEnabled and Holding then
        local target = GetClosest()
        if target and target.Character and target.Character:FindFirstChild(AimPart) then
            local targetPos = target.Character[AimPart].Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), Smoothness)
        end
    end
end)

-- ESP highlight
local Highlights = {}
local function CreateESP(player)
    if Highlights[player] then return end
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(0, 255, 0)
    highlight.FillTransparency = 0.3
    highlight.OutlineTransparency = 0
    highlight.Adornee = player.Character
    highlight.Parent = player.Character
    Highlights[player] = highlight
end

local function RemoveESP(player)
    if Highlights[player] then
        Highlights[player]:Destroy()
        Highlights[player] = nil
    end
end

local function UpdateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and (not TeamCheck or IsEnemy(player)) then
            if ESPEnabled then
                CreateESP(player)
            else
                RemoveESP(player)
            end
        end
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        if ESPEnabled then
            wait(1)
            CreateESP(p)
        end
    end)
end)

RunService.RenderStepped:Connect(UpdateESP)

-- Aimbot Tab
local AimbotTab = Window:CreateTab("🎯 Aimbot", 4483362458)
AimbotTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = false,
    Callback = function(Value) AimbotEnabled = Value end,
})
AimbotTab:CreateSlider({
    Name = "Smoothness",
    Range = {0, 1},
    Increment = 0.01,
    CurrentValue = Smoothness,
    Callback = function(Value) Smoothness = Value end,
})
AimbotTab:CreateSlider({
    Name = "FOV Size",
    Range = {50, 300},
    Increment = 1,
    CurrentValue = FOVSize,
    Callback = function(Value) FOVSize = Value end,
})
AimbotTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Callback = function(Value) TeamCheck = Value end,
})
AimbotTab:CreateDropdown({
    Name = "Aim Part",
    Options = {"Head", "Torso"},
    CurrentOption = "Head",
    Callback = function(Value) AimPart = Value end,
})
AimbotTab:CreateToggle({
    Name = "FOV Circle Visible",
    CurrentValue = true,
    Callback = function(Value) FOVCircle.Visible = Value end,
})

-- Visual Tab
local VisualTab = Window:CreateTab("👁️ Visual", 4483362458)
VisualTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Callback = function(Value) ESPEnabled = Value end,
})

-- UI Settings
local SettingsTab = Window:CreateTab("⚙️ UI Settings", 4483362458)
SettingsTab:CreateKeybind({
    Name = "Toggle UI",
    CurrentKeybind = "RightControl",
    HoldToInteract = false,
    Callback = function() Rayfield:Toggle() end,
})
SettingsTab:CreateColorPicker({
    Name = "FOV Circle Color",
    Color = Color3.fromRGB(0,255,0),
    Callback = function(Value) FOVCircle.Color = Value end,
})
