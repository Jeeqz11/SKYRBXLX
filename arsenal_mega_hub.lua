--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// VARIABLES
local AimbotEnabled, ESPEnabled = false, false
local Smoothness, FOVSize = 0.2, 120
local TeamCheck = true
local AimPart = "Head"
local Holding = false

--// GET CLOSEST FUNCTION
local function IsEnemy(player)
    return player.Team ~= LocalPlayer.Team
end

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

--// AIMBOT
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
    if AimbotEnabled and Holding then
        local target = GetClosest()
        if target and target.Character and target.Character:FindFirstChild(AimPart) then
            local targetPos = target.Character[AimPart].Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), Smoothness)
        end
    end
end)

--// ESP
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

--// BASIC GUI
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 300)
Frame.Position = UDim2.new(0, 50, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.Active = true
Frame.Draggable = true

local ESPButton = Instance.new("TextButton", Frame)
ESPButton.Size = UDim2.new(0, 200, 0, 50)
ESPButton.Position = UDim2.new(0, 25, 0, 20)
ESPButton.Text = "Toggle ESP (OFF)"
ESPButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ESPButton.TextColor3 = Color3.new(1, 1, 1)

ESPButton.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    ESPButton.Text = "Toggle ESP (" .. (ESPEnabled and "ON" or "OFF") .. ")"
end)

local AimbotButton = Instance.new("TextButton", Frame)
AimbotButton.Size = UDim2.new(0, 200, 0, 50)
AimbotButton.Position = UDim2.new(0, 25, 0, 90)
AimbotButton.Text = "Toggle Aimbot (OFF)"
AimbotButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
AimbotButton.TextColor3 = Color3.new(1, 1, 1)

AimbotButton.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    AimbotButton.Text = "Toggle Aimbot (" .. (AimbotEnabled and "ON" or "OFF") .. ")"
end)

local SmoothLabel = Instance.new("TextLabel", Frame)
SmoothLabel.Size = UDim2.new(0, 200, 0, 30)
SmoothLabel.Position = UDim2.new(0, 25, 0, 160)
SmoothLabel.Text = "Smoothness: " .. tostring(Smoothness)
SmoothLabel.BackgroundTransparency = 1
SmoothLabel.TextColor3 = Color3.new(1, 1, 1)

local SmoothSlider = Instance.new("TextButton", Frame)
SmoothSlider.Size = UDim2.new(0, 200, 0, 30)
SmoothSlider.Position = UDim2.new(0, 25, 0, 200)
SmoothSlider.Text = "Increase Smoothness"
SmoothSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SmoothSlider.TextColor3 = Color3.new(1, 1, 1)

SmoothSlider.MouseButton1Click:Connect(function()
    Smoothness = Smoothness + 0.05
    if Smoothness > 1 then Smoothness = 0 end
    SmoothLabel.Text = "Smoothness: " .. string.format("%.2f", Smoothness)
end)

local CloseButton = Instance.new("TextButton", Frame)
CloseButton.Size = UDim2.new(0, 200, 0, 30)
CloseButton.Position = UDim2.new(0, 25, 0, 250)
CloseButton.Text = "Close UI"
CloseButton.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
CloseButton.TextColor3 = Color3.new(1, 1, 1)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
end)
