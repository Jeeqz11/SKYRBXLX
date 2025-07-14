-- SkyWare V2 - Arsenal with Kavo UI

if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- States
local ESPEnabled, TeamCheckESP = false, true
local ESPColor = Color3.fromRGB(0, 255, 0)

local AimbotEnabled, TeamCheckAimbot, FOVCircleEnabled = false, true, true
local Smoothness, FOVRadius = 0.2, 120
local AimPart = "Head"
local AimbotKey = Enum.UserInputType.MouseButton2
local Holding = false

local Highlights = {}
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Visible = FOVCircleEnabled
FOVCircle.Radius = FOVRadius

-- Functions
local function IsEnemy(player)
    return player.Team ~= LocalPlayer.Team
end

local function CreateHighlight(player)
    if Highlights[player] then return end
    local highlight = Instance.new("Highlight")
    highlight.FillColor = ESPColor
    highlight.FillTransparency = 0.4
    highlight.OutlineTransparency = 0
    highlight.Adornee = player.Character
    highlight.Parent = player.Character
    Highlights[player] = highlight
end

local function RemoveHighlight(player)
    if Highlights[player] then
        Highlights[player]:Destroy()
        Highlights[player] = nil
    end
end

local function UpdateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and (not TeamCheckESP or IsEnemy(player)) then
            if ESPEnabled then
                CreateHighlight(player)
            else
                RemoveHighlight(player)
            end
        else
            RemoveHighlight(player)
        end
    end
end

-- FPS & Watermark
local TextLabel = Drawing.new("Text")
TextLabel.Visible = true
TextLabel.Center = false
TextLabel.Outline = true
TextLabel.Font = 2
TextLabel.Size = 18
TextLabel.Color = Color3.fromRGB(255, 255, 255)

local fps = 0
local lastTick = tick()
local frameCount = 0

-- Aimbot logic
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == AimbotKey then
        Holding = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == AimbotKey then
        Holding = false
    end
end)

RunService.RenderStepped:Connect(function()
    -- Aimbot
    if AimbotEnabled and Holding then
        local closest, dist = nil, math.huge
        local mouse = UserInputService:GetMouseLocation()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(AimPart) and (not TeamCheckAimbot or IsEnemy(player)) then
                local pos, visible = Camera:WorldToViewportPoint(player.Character[AimPart].Position)
                if visible then
                    local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                    if mag < dist and mag < FOVRadius then
                        closest, dist = player, mag
                    end
                end
            end
        end
        if closest then
            local pos = closest.Character[AimPart].Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, pos), Smoothness)
        end
    end

    -- FOV Circle
    local mouse = UserInputService:GetMouseLocation()
    FOVCircle.Position = Vector2.new(mouse.X, mouse.Y)
    FOVCircle.Visible = FOVCircleEnabled
    FOVCircle.Radius = FOVRadius

    UpdateESP()

    -- FPS & watermark
    frameCount = frameCount + 1
    if tick() - lastTick >= 1 then
        fps = frameCount
        frameCount = 0
        lastTick = tick()
    end
    TextLabel.Text = string.format("SkyWare V2 - Arsenal | FPS: %d", fps)
    TextLabel.Position = Vector2.new(10, 10)
end)

-- Kavo UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("SkyWare V2 - Arsenal", "Sentinel")

-- Visuals
local VisualTab = Window:NewTab("Visuals")
local VisualSection = VisualTab:NewSection("ESP Settings")

VisualSection:NewToggle("Enable ESP", "Toggle ESP", function(state)
    ESPEnabled = state
end)

VisualSection:NewToggle("Team Check", "Only highlight enemies", function(state)
    TeamCheckESP = state
end)

VisualSection:NewColorPicker("ESP Color", "Pick ESP Color", Color3.fromRGB(0, 255, 0), function(color)
    ESPColor = color
    for _, h in pairs(Highlights) do
        h.FillColor = color
    end
end)

-- Aimbot
local AimbotTab = Window:NewTab("Aimbot")
local AimbotSection = AimbotTab:NewSection("Aimbot Settings")

AimbotSection:NewToggle("Enable Aimbot", "Toggle Aimbot", function(state)
    AimbotEnabled = state
end)

AimbotSection:NewToggle("Team Check", "Only target enemies", function(state)
    TeamCheckAimbot = state
end)

AimbotSection:NewSlider("Smoothness", "Aimbot Smoothness", 1, 0, function(val)
    Smoothness = val
end)

AimbotSection:NewSlider("FOV Radius", "FOV Radius", 300, 50, function(val)
    FOVRadius = val
end)

AimbotSection:NewKeybind("Aimbot Key", "Key to hold for aimbot", Enum.KeyCode.MouseButton2, function()
    -- No extra action needed since using UserInputService logic
end)

AimbotSection:NewDropdown("Aim Part", "Part to aim at", {"Head", "Torso"}, function(val)
    AimPart = val
end)

AimbotSection:NewToggle("Show FOV Circle", "Display FOV Circle", function(state)
    FOVCircleEnabled = state
end)

-- Misc
local MiscTab = Window:NewTab("Misc")
local MiscSection = MiscTab:NewSection("Misc Settings")

MiscSection:NewButton("Unload UI", "Unload script", function()
    Library:Destroy()
    FOVCircle:Remove()
    TextLabel:Remove()
    for _, h in pairs(Highlights) do
        h:Destroy()
    end
end)

print("✅ SkyWare V2 Loaded!")
