-- SkyWare V2 - Arsenal Premium (FINAL)

if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Linoria Setup
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Global States
local ESPEnabled, RainbowESP, TracersEnabled, BoxESPEnabled, ChamsEnabled, OutlineEnabled, TeamCheckESP = false, false, false, false, false, false, true
local ESPColor = Color3.fromRGB(0, 255, 0)

local AimbotEnabled, TeamCheckAimbot, FOVCircleEnabled, RainbowFOV = false, true, true, false
local Smoothness, FOVRadius = 0.2, 120
local AimPart = "Head"
local AimbotKey = Enum.UserInputType.MouseButton2
local Holding = false
local Highlights, Tracers = {}, {}
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Radius = FOVRadius

-- Watermark & FPS Counter
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

-- Utility Functions
local function IsEnemy(player)
    return player.Team ~= LocalPlayer.Team
end

local function CreateHighlight(player)
    if Highlights[player] then return end
    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = ChamsEnabled and 0.4 or 1
    highlight.OutlineTransparency = OutlineEnabled and 0 or 1
    highlight.FillColor = ESPColor
    highlight.Adornee = player.Character
    highlight.Parent = player.Character
    Highlights[player] = highlight
end

local function RemoveHighlight(player)
    if Highlights[player] then
        Highlights[player]:Destroy()
        Highlights[player] = nil
    end
    if Tracers[player] then
        Tracers[player]:Remove()
        Tracers[player] = nil
    end
end

local function UpdateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and (not TeamCheckESP or IsEnemy(player)) then
            if ESPEnabled then
                CreateHighlight(player)
                if BoxESPEnabled or TracersEnabled then
                    if not Tracers[player] and TracersEnabled then
                        local tracer = Drawing.new("Line")
                        tracer.Color = ESPColor
                        tracer.Thickness = 1
                        tracer.Transparency = 1
                        Tracers[player] = tracer
                    end
                end
            else
                RemoveHighlight(player)
            end
        else
            RemoveHighlight(player)
        end
    end
end

local function UpdateDrawings()
    for player, tracer in pairs(Tracers) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart.Position
            local screenPos, visible = Camera:WorldToViewportPoint(hrp)
            if visible and ESPEnabled and TracersEnabled then
                tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                tracer.Visible = true
                tracer.Color = RainbowESP and Color3.fromHSV(tick() % 5 / 5, 1, 1) or ESPColor
            else
                tracer.Visible = false
            end
        else
            tracer.Visible = false
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
            Library:Notify("Target Locked!", 0.2)
        end
    end

    -- FOV Circle
    local mouse = UserInputService:GetMouseLocation()
    FOVCircle.Position = Vector2.new(mouse.X, mouse.Y)
    FOVCircle.Visible = FOVCircleEnabled
    FOVCircle.Radius = FOVRadius
    FOVCircle.Color = RainbowFOV and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Color3.fromRGB(255, 255, 255)

    UpdateESP()
    UpdateDrawings()

    -- FPS & Watermark
    frameCount = frameCount + 1
    if tick() - lastTick >= 1 then
        fps = frameCount
        frameCount = 0
        lastTick = tick()
    end
    TextLabel.Text = string.format("SkyWare V2 - Arsenal | FPS: %d", fps)
    TextLabel.Position = Vector2.new(10, 10)
end)

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

-- UI Setup
local Window = Library:CreateWindow({ Title = "SkyWare V2 - Arsenal", Center = true, AutoShow = true })

local Tabs = {
    Visuals = Window:AddTab("Visuals"),
    Aimbot = Window:AddTab("Aimbot"),
    Misc = Window:AddTab("Misc"),
}

-- Visuals
do
    Tabs.Visuals:AddToggle("ESPEnabled", { Text = "Enable ESP", Default = false }):OnChanged(function(v)
        ESPEnabled = v
        Library:Notify("ESP " .. (v and "Enabled!" or "Disabled!"))
    end)

    Tabs.Visuals:AddToggle("TeamCheckESP", { Text = "Team Check", Default = true }):OnChanged(function(v)
        TeamCheckESP = v
    end)

    Tabs.Visuals:AddColorPicker("ESPColor", { Text = "ESP Color", Default = Color3.fromRGB(0, 255, 0) }):OnChanged(function(v)
        ESPColor = v
        for _, h in pairs(Highlights) do
            h.FillColor = v
        end
    end)

    Tabs.Visuals:AddToggle("RainbowESP", { Text = "Rainbow ESP", Default = false }):OnChanged(function(v)
        RainbowESP = v
    end)

    Tabs.Visuals:AddToggle("TracersEnabled", { Text = "Tracers", Default = false }):OnChanged(function(v)
        TracersEnabled = v
    end)

    Tabs.Visuals:AddToggle("BoxESPEnabled", { Text = "Box ESP", Default = false }):OnChanged(function(v)
        BoxESPEnabled = v
    end)

    Tabs.Visuals:AddToggle("ChamsEnabled", { Text = "Chams", Default = false }):OnChanged(function(v)
        ChamsEnabled = v
        for _, h in pairs(Highlights) do
            h.FillTransparency = v and 0.4 or 1
        end
    end)

    Tabs.Visuals:AddToggle("OutlineEnabled", { Text = "Outline", Default = false }):OnChanged(function(v)
        OutlineEnabled = v
        for _, h in pairs(Highlights) do
            h.OutlineTransparency = v and 0 or 1
        end
    end)
end

-- Aimbot
do
    Tabs.Aimbot:AddToggle("AimbotEnabled", { Text = "Enable Aimbot", Default = false }):OnChanged(function(v)
        AimbotEnabled = v
    end)

    Tabs.Aimbot:AddToggle("TeamCheckAimbot", { Text = "Team Check", Default = true }):OnChanged(function(v)
        TeamCheckAimbot = v
    end)

    Tabs.Aimbot:AddDropdown("AimPart", {
        Values = { "Head", "Torso" },
        Default = "Head",
        Multi = false,
        Text = "Aim Part",
    }):OnChanged(function(v)
        AimPart = v
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

    Tabs.Aimbot:AddToggle("RainbowFOV", { Text = "Rainbow FOV", Default = false }):OnChanged(function(v)
        RainbowFOV = v
    end)

    Tabs.Aimbot:AddKeyPicker("AimbotKey", {
        Default = "MouseButton2",
        Text = "Aimbot Key",
        NoUI = false,
    }):OnChanged(function(v)
        AimbotKey = Enum.UserInputType[v]
    end)
end

-- Misc
do
    Tabs.Misc:AddButton("Unload UI", function()
        Library:Unload()
        FOVCircle:Remove()
        TextLabel:Remove()
        for _, h in pairs(Highlights) do
            h:Destroy()
        end
        for _, t in pairs(Tracers) do
            t:Remove()
        end
    end)

    ThemeManager:SetLibrary(Library)
    SaveManager:SetLibrary(Library)
    SaveManager:BuildConfigSection(Tabs.Misc)
    ThemeManager:ApplyToTab(Tabs.Misc)
end

Library:Notify("SkyWare V2 Loaded!", 5)
Window:SetFocusedTab(Tabs.Visuals)
