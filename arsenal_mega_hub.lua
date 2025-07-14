--// SkyWare - by jeeqz11

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local AimbotEnabled, ESPEnabled = false, false
local Smoothness, FOVSize = 0.2, 120
local TeamCheck = true
local AimPart = "Head"
local Holding = false

-- Aimbot logic
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

-- ESP logic
local Highlights = {}

local function CreateESP(player)
    if Highlights[player] then return end
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(0, 255, 0)
    highlight.FillTransparency = 0.4
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
        else
            RemoveESP(player)
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        wait(1)
        if ESPEnabled then
            CreateESP(player)
        end
    end)
end)

RunService.RenderStepped:Connect(UpdateESP)

-- UI
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "SkyWareUI"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 500, 0, 300)
MainFrame.Position = UDim2.new(0, 50, 0, 50)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.Active = true
MainFrame.Draggable = true

-- Tabs
local TabsFrame = Instance.new("Frame", MainFrame)
TabsFrame.Size = UDim2.new(0, 120, 1, 0)
TabsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Size = UDim2.new(1, -120, 1, 0)
ContentFrame.Position = UDim2.new(0, 120, 0, 0)
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

-- Aimbot tab
CreateTab("Aimbot", function()
    local Toggle = Instance.new("TextButton", ContentFrame)
    Toggle.Size = UDim2.new(0, 250, 0, 50)
    Toggle.Position = UDim2.new(0, 20, 0, 20)
    Toggle.Text = "Aimbot: OFF"
    Toggle.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    Toggle.TextColor3 = Color3.new(1, 1, 1)

    Toggle.MouseButton1Click:Connect(function()
        AimbotEnabled = not AimbotEnabled
        Toggle.Text = "Aimbot: " .. (AimbotEnabled and "ON" or "OFF")
    end)

    local Smooth = Instance.new("TextButton", ContentFrame)
    Smooth.Size = UDim2.new(0, 250, 0, 50)
    Smooth.Position = UDim2.new(0, 20, 0, 90)
    Smooth.Text = "Smoothness: " .. string.format("%.2f", Smoothness)
    Smooth.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    Smooth.TextColor3 = Color3.new(1, 1, 1)

    Smooth.MouseButton1Click:Connect(function()
        Smoothness = Smoothness + 0.05
        if Smoothness > 1 then Smoothness = 0
        end
        Smooth.Text = "Smoothness: " .. string.format("%.2f", Smoothness)
    end)
end)

-- ESP tab
CreateTab("ESP", function()
    local ToggleESP = Instance.new("TextButton", ContentFrame)
    ToggleESP.Size = UDim2.new(0, 250, 0, 50)
    ToggleESP.Position = UDim2.new(0, 20, 0, 20)
    ToggleESP.Text = "ESP: OFF"
    ToggleESP.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    ToggleESP.TextColor3 = Color3.new(1, 1, 1)

    ToggleESP.MouseButton1Click:Connect(function()
        ESPEnabled = not ESPEnabled
        ToggleESP.Text = "ESP: " .. (ESPEnabled and "ON" or "OFF")
    end)

    local TeamCheckToggle = Instance.new("TextButton", ContentFrame)
    TeamCheckToggle.Size = UDim2.new(0, 250, 0, 50)
    TeamCheckToggle.Position = UDim2.new(0, 20, 0, 90)
    TeamCheckToggle.Text = "Team Check: ON"
    TeamCheckToggle.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    TeamCheckToggle.TextColor3 = Color3.new(1, 1, 1)

    TeamCheckToggle.MouseButton1Click:Connect(function()
        TeamCheck = not TeamCheck
        TeamCheckToggle.Text = "Team Check: " .. (TeamCheck and "ON" or "OFF")
    end)
end)

