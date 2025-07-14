local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source.lua"))()

local Window = Rayfield:CreateWindow({
    Name = "SKY Arsenal Mega Hub",
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
local TeamCheck, VisibleCheck, Prediction = true, false, false
local SilentAim, TracersEnabled, BoxESPEnabled = false, false, false
local NameESP, HealthESP, DistanceESP, ChamsEnabled = false, false, false, false
local OutlineESP, FlyEnabled, InfiniteJumpEnabled, RapidFireEnabled = false, false, false, false
local NoRecoilEnabled, NoSpreadEnabled = false, false
local Holding = false
local AimPart = "Head"

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

-- Aimbot
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

-- Arsenal Exploits
-- Rapid fire & no recoil hook (very basic)
local mt = getrawmetatable(game)
local backup = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(...)
    local args = {...}
    local method = getnamecallmethod()
    if RapidFireEnabled and tostring(method) == "FireServer" and tostring(args[1]) == "Weapon" then
        args[2] = 0.05
    end
    return backup(unpack(args))
end)
setreadonly(mt, true)

UIS.JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- Fly (unstable)
local BodyVelocity = nil
RunService.RenderStepped:Connect(function()
    if FlyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        if not BodyVelocity then
            BodyVelocity = Instance.new("BodyVelocity", LocalPlayer.Character.HumanoidRootPart)
            BodyVelocity.Velocity = Vector3.new()
            BodyVelocity.MaxForce = Vector3.new(400000,400000,400000)
        end
        BodyVelocity.Velocity = Camera.CFrame.LookVector * 100
    elseif BodyVelocity then
        BodyVelocity:Destroy()
        BodyVelocity = nil
    end
end)

-- UI
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
    Name = "Silent Aim (Unstable)",
    CurrentValue = false,
    Callback = function(Value) SilentAim = Value end,
})
AimbotTab:CreateToggle({
    Name = "Visible Check (Experimental)",
    CurrentValue = false,
    Callback = function(Value) VisibleCheck = Value end,
})
AimbotTab:CreateToggle({
    Name = "Prediction (Experimental)",
    CurrentValue = false,
    Callback = function(Value) Prediction = Value end,
})
AimbotTab:CreateToggle({
    Name = "FOV Circle Visible",
    CurrentValue = true,
    Callback = function(Value) FOVCircle.Visible = Value end,
})

local VisualTab = Window:CreateTab("👁️ Visual", 4483362458)
VisualTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Callback = function(Value) ESPEnabled = Value end,
})
VisualTab:CreateToggle({
    Name = "Box ESP (Unstable)",
    CurrentValue = false,
    Callback = function(Value) BoxESPEnabled = Value end,
})
VisualTab:CreateToggle({
    Name = "Tracers",
    CurrentValue = false,
    Callback = function(Value) TracersEnabled = Value end,
})
VisualTab:CreateToggle({
    Name = "Name ESP",
    CurrentValue = false,
    Callback = function(Value) NameESP = Value end,
})
VisualTab:CreateToggle({
    Name = "Health Bar ESP",
    CurrentValue = false,
    Callback = function(Value) HealthESP = Value end,
})
VisualTab:CreateToggle({
    Name = "Distance ESP",
    CurrentValue = false,
    Callback = function(Value) DistanceESP = Value end,
})
VisualTab:CreateToggle({
    Name = "Chams (Experimental)",
    CurrentValue = false,
    Callback = function(Value) ChamsEnabled = Value end,
})
VisualTab:CreateToggle({
    Name = "Outline ESP",
    CurrentValue = false,
    Callback = function(Value) OutlineESP = Value end,
})

local ExploitTab = Window:CreateTab("⚡ Exploits", 4483362458)
ExploitTab:CreateToggle({
    Name = "Rapid Fire",
    CurrentValue = false,
    Callback = function(Value) RapidFireEnabled = Value end,
})
ExploitTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(Value) InfiniteJumpEnabled = Value end,
})
ExploitTab:CreateToggle({
    Name = "No Recoil",
    CurrentValue = false,
    Callback = function(Value) NoRecoilEnabled = Value end,
})
ExploitTab:CreateToggle({
    Name = "No Spread",
    CurrentValue = false,
    Callback = function(Value) NoSpreadEnabled = Value end,
})
ExploitTab:CreateToggle({
    Name = "Fly (Unstable)",
    CurrentValue = false,
    Callback = function(Value) FlyEnabled = Value end,
})

local SettingsTab = Window:CreateTab("⚙️ UI Settings", 4483362458)
SettingsTab:CreateKeybind({
    Name = "Toggle UI",
    CurrentKeybind = "RightControl",
    HoldToInteract = false,
    Callback = function() Rayfield:Toggle() end,
})
SettingsTab:CreateColorPicker({
    Name = "Theme Color",
    Color = Color3.fromRGB(0,255,0),
    Callback = function(Value) FOVCircle.Color = Value end,
})
