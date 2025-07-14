-- SkyWare v2 - By jeeqz11 for Arsenal

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// VARIABLES
local AimbotEnabled, ESPEnabled, BoxESPEnabled, TracerEnabled = false, false, false, false
local TeamCheckAimbot, TeamCheckESP = true, true
local Smoothness, FOVSize = 0.2, 120
local AimPart = "Head"
local ESPColor = Color3.fromRGB(0, 255, 0)
local AimbotKey = Enum.UserInputType.MouseButton2
local Holding = false
local FOVCircleEnabled = true
local FOVCircle

--// FOV Circle Setup
function CreateFOVCircle()
    if FOVCircle then
        FOVCircle:Remove()
    end
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Color = Color3.fromRGB(255, 255, 255)
    FOVCircle.Thickness = 1
    FOVCircle.Filled = false
    FOVCircle.Radius = FOVSize
    FOVCircle.Visible = FOVCircleEnabled
end

CreateFOVCircle()

--// GET CLOSEST FUNCTION
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
                if mag < dist and mag < FOVSize then
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
    if FOVCircle then
        local mouse = UserInputService:GetMouseLocation()
        FOVCircle.Position = Vector2.new(mouse.X, mouse.Y)
        FOVCircle.Visible = FOVCircleEnabled
        FOVCircle.Radius = FOVSize
    end
end)

--// ESP
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

--// UI
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "SkyWareV2"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Position = UDim2.new(0, 50, 0, 50)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Text = "SkyWare v2"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 24

local TabsFrame = Instance.new("Frame", MainFrame)
TabsFrame.Size = UDim2.new(0, 120, 1, -40)
TabsFrame.Position = UDim2.new(0, 0, 0, 40)
TabsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Size = UDim2.new(1, -120, 1, -40)
ContentFrame.Position = UDim2.new(0, 120, 0, 40)
ContentFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)

local function ClearContent()
    for _, v in pairs(ContentFrame:GetChildren()) do
        if v:IsA("GuiObject") then
            v:Destroy()
        end
    end
end

local function CreateTab(name, callback)
    local Button = Instance.new("TextButton", TabsFrame)
    Button.Size = UDim2.new(1, 0, 0, 50)
    Button.Text = name
    Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.MouseButton1Click:Connect(function()
        ClearContent()
        callback()
    end)
end

--// Visuals Tab
CreateTab("Visuals", function()
    local ToggleESP = Instance.new("TextButton", ContentFrame)
    ToggleESP.Size = UDim2.new(0, 300, 0, 40)
    ToggleESP.Position = UDim2.new(0, 20, 0, 20)
    ToggleESP.Text = "ESP: OFF"
    ToggleESP.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    ToggleESP.TextColor3 = Color3.new(1, 1, 1)

    ToggleESP.MouseButton1Click:Connect(function()
        ESPEnabled = not ESPEnabled
        ToggleESP.Text = "ESP: " .. (ESPEnabled and "ON" or "OFF")
    end)

    local ToggleTeam = Instance.new("TextButton", ContentFrame)
    ToggleTeam.Size = UDim2.new(0, 300, 0, 40)
    ToggleTeam.Position = UDim2.new(0, 20, 0, 80)
    ToggleTeam.Text = "Team Check: ON"
    ToggleTeam.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    ToggleTeam.TextColor3 = Color3.new(1, 1, 1)

    ToggleTeam.MouseButton1Click:Connect(function()
        TeamCheckESP = not TeamCheckESP
        ToggleTeam.Text = "Team Check: " .. (TeamCheckESP and "ON" or "OFF")
    end)
end)

--// Aimbot Tab
CreateTab("Aimbot", function()
    local ToggleAimbot = Instance.new("TextButton", ContentFrame)
    ToggleAimbot.Size = UDim2.new(0, 300, 0, 40)
    ToggleAimbot.Position = UDim2.new(0, 20, 0, 20)
    ToggleAimbot.Text = "Aimbot: OFF"
    ToggleAimbot.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    ToggleAimbot.TextColor3 = Color3.new(1, 1, 1)

    ToggleAimbot.MouseButton1Click:Connect(function()
        AimbotEnabled = not AimbotEnabled
        ToggleAimbot.Text = "Aimbot: " .. (AimbotEnabled and "ON" or "OFF")
    end)

    local ToggleFOV = Instance.new("TextButton", ContentFrame)
    ToggleFOV.Size = UDim2.new(0, 300, 0, 40)
    ToggleFOV.Position = UDim2.new(0, 20, 0, 80)
    ToggleFOV.Text = "FOV Circle: ON"
    ToggleFOV.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    ToggleFOV.TextColor3 = Color3.new(1, 1, 1)

    ToggleFOV.MouseButton1Click:Connect(function()
        FOVCircleEnabled = not FOVCircleEnabled
        ToggleFOV.Text = "FOV Circle: " .. (FOVCircleEnabled and "ON" or "OFF")
    end)
end)

--// Misc Tab
CreateTab("Misc", function()
    local CloseButton = Instance.new("TextButton", ContentFrame)
    CloseButton.Size = UDim2.new(0, 300, 0, 40)
    CloseButton.Position = UDim2.new(0, 20, 0, 20)
    CloseButton.Text = "Close UI"
    CloseButton.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
    CloseButton.TextColor3 = Color3.new(1, 1, 1)

    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui.Enabled = false
    end)
end)
