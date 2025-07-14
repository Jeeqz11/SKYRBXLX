-- SkyWare v2 - FINAL FIXED

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESPEnabled, TeamCheckESP = false, true
local AimbotEnabled, TeamCheckAimbot, FOVCircleEnabled = false, true, true
local Smoothness, FOVRadius = 0.2, 120
local ESPColor = Color3.fromRGB(0, 255, 0)
local AimPart = "Head"
local AimbotKey = Enum.UserInputType.MouseButton2
local Holding = false

local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Radius = FOVRadius

local Highlights = {}

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

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        wait(1)
        if ESPEnabled then
            CreateHighlight(p)
        end
    end)
end)

RunService.RenderStepped:Connect(function()
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
end)

RunService.RenderStepped:Connect(function()
    local mouse = UserInputService:GetMouseLocation()
    FOVCircle.Position = Vector2.new(mouse.X, mouse.Y)
    FOVCircle.Visible = FOVCircleEnabled
    FOVCircle.Radius = FOVRadius
end)

RunService.RenderStepped:Connect(UpdateESP)

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

-- UI
local Window = Library:CreateWindow({ Title = "SkyWare v2 - Arsenal", Center = true, AutoShow = true })

local Tabs = {
    Visuals = Window:AddTab("Visuals"),
    Aimbot = Window:AddTab("Aimbot"),
    Misc = Window:AddTab("Misc"),
}

-- Visuals tab
do
    Tabs.Visuals:AddToggle("ESPEnabled", { Text = "Enable ESP", Default = false }):OnChanged(function(v)
        ESPEnabled = v
    end)

    Tabs.Visuals:AddToggle("TeamCheckESP", { Text = "Team Check", Default = true }):OnChanged(function(v)
        TeamCheckESP = v
    end)

    Tabs.Visuals:AddColorPicker("ESPColor", { Text = "ESP Color", Default = Color3.fromRGB(0, 255, 0) }):OnChanged(function(v)
        ESPColor = v
        for _, highlight in pairs(Highlights) do
            highlight.FillColor = ESPColor
        end
    end)
end

-- Aimbot tab
do
    Tabs.Aimbot:AddToggle("AimbotEnabled", { Text = "Enable Aimbot", Default = false }):OnChanged(function(v)
        AimbotEnabled = v
    end)

    Tabs.Aimbot:AddToggle("TeamCheckAimbot", { Text = "Team Check", Default = true }):OnChanged(function(v)
        TeamCheckAimbot = v
    end)

    Tabs.Aimbot:AddSlider("Smoothness", {
        Text = "Smoothness",
        Default = 0.2,
        Min = 0,
        Max = 1,
        Rounding = 2,
    }):OnChanged(function(v)
        Smoothness = v
    end)

    Tabs.Aimbot:AddDropdown("AimPart", {
        Values = { "Head", "Torso" },
        Default = "Head",
        Multi = false,
        Text = "Aim Part",
    }):OnChanged(function(v)
        AimPart = v
    end)

    Tabs.Aimbot:AddToggle("FOVCircleEnabled", { Text = "Show FOV Circle", Default = true }):OnChanged(function(v)
        FOVCircleEnabled = v
    end)

    Tabs.Aimbot:AddSlider("FOVRadius", {
        Text = "FOV Radius",
        Default = 120,
        Min = 50,
        Max = 300,
    }):OnChanged(function(v)
        FOVRadius = v
    end)

    Tabs.Aimbot:AddKeyPicker("AimbotKey", {
        Default = "MouseButton2",
        Text = "Aimbot Key",
        NoUI = false,
    }):OnChanged(function(v)
        AimbotKey = Enum.UserInputType[v]
    end)
end

-- Misc tab
do
    Tabs.Misc:AddButton("Unload UI", function()
        Library:Unload()
        FOVCircle:Remove()
    end)

    ThemeManager:SetLibrary(Library)
    SaveManager:SetLibrary(Library)
    SaveManager:BuildConfigSection(Tabs.Misc)
    ThemeManager:ApplyToTab(Tabs.Misc)
end

Library:Notify("SkyWare v2 Loaded!", 5)
Window:SetFocusedTab(Tabs.Visuals)
