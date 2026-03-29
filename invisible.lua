-- [[ X-CLIENT: TRINITY-ULTRA V52 (SHERIFF & HIT-SYNC) ]] --
local LP = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local Enabled = false

-- --- НАСТРОЙКИ --- --
local Vertical_Power = 45      
local Speed_Multiplier = 43    
local Ghost_Transparency = 0.5 
local Shot_Window = 0.2 -- Увеличенное окно для выстрела шерифа (0.18 сек)
-- ----------------- --

local CameraAnchor = Instance.new("Part")
CameraAnchor.Transparency = 1
CameraAnchor.CanCollide = false
CameraAnchor.Anchored = true
CameraAnchor.Size = Vector3.new(1, 1, 1)
CameraAnchor.Parent = workspace

local Gyro = Instance.new("BodyGyro")
Gyro.MaxTorque = Vector3.new(0, 0, 0)
Gyro.P = 3000
Gyro.D = 50

local function setCharTrans(t)
    local char = LP.Character
    if char then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then v.Transparency = t
            elseif v:IsA("Decal") then v.Transparency = t end
        end
    end
end

-- Бесконечный прыжок
UIS.JumpRequest:Connect(function()
    if Enabled then
        local char = LP.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            root.Velocity = Vector3.new(root.Velocity.X, 55, root.Velocity.Z)
        end
    end
end)

local function toggle()
    Enabled = not Enabled
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if Enabled then 
        setCharTrans(Ghost_Transparency)
        if root then Gyro.Parent = root; Gyro.MaxTorque = Vector3.new(4e5, 4e5, 4e5) end
    else 
        setCharTrans(0)
        Gyro.Parent = nil
        if root then root.CanCollide = true; root.CFrame = CameraAnchor.CFrame * CFrame.new(0,-2,0) end
        if char:FindFirstChild("Humanoid") then Camera.CameraSubject = char.Humanoid end
    end
end

-- ЦИКЛ С ПРИОРИТЕТОМ ВЫСТРЕЛА
RS.Heartbeat:Connect(function()
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    
    if char and root and hum and Enabled then
        CameraAnchor.CFrame = root.CFrame * CFrame.new(0, 2, 0)
        Camera.CameraSubject = CameraAnchor
        
        -- ДЕТЕКТОР ВЫСТРЕЛА (Зажатие или клик)
        local isShooting = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or UIS:IsMouseButtonPressed(Enum.UserInputType.Touch)
        local startCF = root.CFrame
        
        -- Speedhack
        if hum.MoveDirection.Magnitude > 0 then
            root.Velocity = Vector3.new(hum.MoveDirection.X * Speed_Multiplier, root.Velocity.Y, hum.MoveDirection.Z * Speed_Multiplier)
        end

        -- Если мы стреляем — МЫ НЕ ТЕПАЕМСЯ ВНИЗ!
        if isShooting then
            root.CanCollide = true
            root.CFrame = startCF -- Держим на поверхности
            task.wait(Shot_Window) -- Ждем, пока пуля вылетит
        else
            -- Если не стреляем — работаем в режиме инвиза
            root.CanCollide = false
            Gyro.CFrame = startCF
            root.CFrame = startCF * CFrame.new(math.random(-1,1), -Vertical_Power, math.random(-1,1))
            RS.Stepped:Wait()
            
            if Enabled and root then
                root.CFrame = startCF
                root.CanCollide = true
                RS.Stepped:Wait()
            end
        end
    end
end)

-- Интерфейс
local Gui = Instance.new("ScreenGui", game.CoreGui)
local B = Instance.new("TextButton", Gui)
B.Size = UDim2.new(0, 200, 0, 50)
B.Position = UDim2.new(0.5, -100, 0.1, 0)
B.Text = "TRINITY V52 [SHERIFF]"
B.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
B.TextColor3 = Color3.new(1, 1, 1)
B.Font = Enum.Font.Code
Instance.new("UICorner", B)

spawn(function()
    while true do
        B.Text = Enabled and "SHERIFF MODE: ON" or "TRINITY V52 [CTRL]"
        B.BackgroundColor3 = Enabled and Color3.fromRGB(255, 170, 0) or Color3.fromRGB(20, 20, 20)
        task.wait(0.2)
    end
end)

UIS.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.LeftControl then toggle() end end)

-- Mobile Drag
local drag, dStart, sPos, tStart = false, nil, nil, 0
B.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        tStart = tick()
        local c1 = UIS.InputChanged:Connect(function(m)
            if (m.UserInputType == Enum.UserInputType.MouseMovement or m.UserInputType == Enum.UserInputType.Touch) and tick()-tStart > 0.3 then
                if not drag then drag, dStart, sPos = true, m.Position, B.Position else
                    local delta = m.Position - dStart
                    B.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y)
                end
            end
        end)
        local c2; c2 = i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then
                if tick()-tStart < 0.3 then toggle() end
                drag = false; c1:Disconnect(); c2:Disconnect()
            end
        end)
    end
end)

spawn(function() while true do for i=0,1,0.01 do if Enabled then B.TextColor3=Color3.fromHSV(i,0.7,1) end; task.wait(0.05) end end end)