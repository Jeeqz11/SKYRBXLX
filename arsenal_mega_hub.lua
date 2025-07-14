-- SkyWare v2 - Final Full Script

-- Load Linoria UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Variables
local ESPEnabled, BoxESPEnabled, TracerESPEnabled, TeamCheckESP = false, false, false, true
local AimbotEnabled, TeamCheckAimbot, FOVCircleEnabled = false, true, true
local Smoothness, FOVRadius = 0.2, 120
local ESPColor = Color3.fromRGB(0, 255, 0)
local AimPart = "Head"
local AimbotKey = Enum.UserInputType.MouseButton2
local Holding = false

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Radius = FOVRadius
FOVCircle.Visible = FOVCircleEnabled

-- Aimbot functions
local function IsEnemy(player)
    return player.Team ~= LocalPlayer.Team
end

local function GetClosest()
    local closest, dist = nil, math.huge
    local mouseLocation = UserInputService:GetMouseLocation()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(AimPart) and (not TeamCheckAimbot or IsEnemy(player)) then
            local pos, visible = Camera:WorldToViewportPoint(player.Character[AimPart].Position)
            if visible then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouseLocation.X, mouseLocation.Y)).Magnitude
                if mag < dist and mag < FOVRadius then
                    closest, dist = player, mag
                end
            end
        end
    end
    return closest
end

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
    if AimbotEnabled and Holding then
        local target = GetClosest()
        if target and target.Character and target.Character:FindFirstChild(AimPart) then
            local targetPos = target.Character[AimPart].Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), Smoothness)
        end
    end
end)

RunService.RenderStepped:Connect(function()
    local mouse = UserInputService:GetMouseLocation()
    FOVCircle.Position = Vector2.new(mouse.X, mouse.Y)
    FOVCircle.Visible = FOVCircleEnabled
    FOVCircle.Radius = FOVRadius
end)

-- ESP
local Highlights = {}

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

RunService.RenderStepped:Connect(UpdateESP)

-- UI
local Window = Library:CreateWindow({
    Title = "SkyWare v2 - Arsenal",
    Center = true,
    AutoShow = true,
})

local Tabs = {
    Visuals = Window:AddTab("Visuals"),
    Aimbot = Window:AddTab("Aimbot"),
    Misc = Window:AddTab("Misc"),
}

-- Visuals
Tabs.Visuals:AddToggle("ESPEnabled", { Text = "Highlight ESP", Default = false }):OnChanged(function(Value)
    ESPEnabled = Value
end)

Tabs.Visuals:AddToggle("TeamCheckESP", { Text = "Team Check", Default = true }):OnChanged(function(Value)
    TeamCheckESP = Value
end)

Tabs.Visuals:AddColorPicker("ESPColor", { Text = "ESP Color", Default = Color3.fromRGB(0, 255, 0) }):OnChanged(function(Value)
    ESPColor = Value
end)

-- Aimbot
Tabs.Aimbot:AddToggle("AimbotEnabled", { Text = "Enable Aimbot", Default = false }):OnChanged(function(Value)
    AimbotEnabled = Value
end)

Tabs.Aimbot:AddToggle("TeamCheckAimbot", { Text = "Team Check", Default = true }):OnChanged(function(Value)
    TeamCheckAimbot = Value
end)

Tabs.Aimbot:AddSlider("Smoothness", {
    Text = "Smoothness",
    Default = 0.2,
    Min = 0,
    Max = 1,
    Rounding = 2,
}):OnChanged(function(Value)
    Smoothness = Value
end)

Tabs.Aimbot:AddDropdown("AimPart", {
    Values = { "Head", "Torso" },
    Default = "Head",
    Multi = false,
    Text = "Aim Part",
}):OnChanged(function(Value)
    AimPart = Value
end)

Tabs.Aimbot:AddToggle("FOVCircleEnabled", { Text = "Show FOV Circle", Default = true }):OnChanged(function(Value)
    FOVCircleEnabled = Value
end)

Tabs.Aimbot:AddSlider("FOVRadius", {
    Text = "FOV Radius",
    Default = 120,
    Min = 50,
    Max = 300,
}):OnChanged(function(Value)
    FOVRadius = Value
end)

Tabs.Aimbot:AddKeyPicker("AimbotKey", {
    Default = "MouseButton2",
    Text = "Aimbot Key",
    NoUI = false,
}):OnChanged(function(Value)
    AimbotKey = Enum.UserInputType[Value]
end)

-- Misc
Tabs.Misc:AddButton("Unload UI", function()
    Library:Unload()
    FOVCircle:Remove()
end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:BuildConfigSection(Tabs.Misc)
ThemeManager:ApplyToTab(Tabs.Misc)
