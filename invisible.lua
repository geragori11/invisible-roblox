-- [[ X-CLIENT: TRINITY-ULTRA V48 (CTRL BIND + DRAGGABLE) ]] --
local LP = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local Enabled = false

local Vertical_Power = 15 

-- Якорь камеры
local CameraAnchor = Instance.new("Part")
CameraAnchor.Transparency = 1
CameraAnchor.CanCollide = false
CameraAnchor.Anchored = true
CameraAnchor.Size = Vector3.new(1, 1, 1)
CameraAnchor.Parent = workspace

local function isBusy()
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if char and hum then
        if char:FindFirstChildOfClass("Tool") then return true end
        local state = hum:GetState()
        if state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall then
            return true 
        end
    end
    return false
end

-- Основная логика
local function applyTrinity()
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    
    if char and root and hum and Enabled then
        local centerCF = root.CFrame
        CameraAnchor.CFrame = centerCF * CFrame.new(0, 2, 0)
        Camera.CameraSubject = CameraAnchor
        
        if isBusy() then
            root.CanCollide = true
            root.RotVelocity = Vector3.new(0, 0, 0)
            return 
        end
        
        local chance = math.random(1, 4)
        root.CanCollide = false
        root.CFrame = centerCF * CFrame.new(0, -Vertical_Power * chance, 0)
        
        RS.Stepped:Wait() 
        
        if root and Enabled then
            root.CFrame = centerCF
            root.CanCollide = true
        end
        root.RotVelocity = Vector3.new(0, 0, 0)
    end
end

RS.Heartbeat:Connect(applyTrinity)

-- ИНТЕРФЕЙС
local Gui = Instance.new("ScreenGui", game.CoreGui)
local B = Instance.new("TextButton", Gui)
B.Size = UDim2.new(0, 250, 0, 60)
B.Position = UDim2.new(0.5, -125, 0.05, 0)
B.Text = "TRINITY V48 [L-CTRL]"
B.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
B.TextColor3 = Color3.new(1, 1, 1)
B.Font = Enum.Font.Code
B.AutoButtonColor = false
Instance.new("UICorner", B)

-- ФУНКЦИЯ ПЕРЕКЛЮЧЕНИЯ (Toggle)
local function toggleEnabled()
    Enabled = not Enabled
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")

    if Enabled then
        B.Text = "STATUS: ACTIVE"
        B.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    else
        B.Text = "TRINITY V48 [L-CTRL]"
        B.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        if root then
            root.CFrame = CameraAnchor.CFrame * CFrame.new(0, -2, 0)
            root.Velocity = Vector3.new(0,0,0)
            root.RotVelocity = Vector3.new(0,0,0)
            root.CanCollide = true
        end
        if hum then Camera.CameraSubject = hum end
    end
end

-- БИНД НА LEFT CTRL
UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.LeftControl then
        toggleEnabled()
    end
end)

B.MouseButton1Click:Connect(toggleEnabled)

-- ЛОГИКА ПЕРЕМЕЩЕНИЯ (DRAG)
local dragging, dragInput, dragStart, startPos
B.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = B.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
B.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
RS.RenderStepped:Connect(function()
    if dragging and dragInput then
        local delta = dragInput.Position - dragStart
        B.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)