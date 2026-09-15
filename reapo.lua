local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

getgenv().ToggleUpdates = {} -- ระบบซิงค์ปุ่ม UI กับ Keybind

-- ==========================================
-- ⚙️ การตั้งค่าระบบ
-- ==========================================
local Settings = {
    AutoFarm = false,
    AutoClick = false,
    GoldenHeist = false,
    TargetMob = "None",
    TargetIsland = "None",
    Distance = 4,
    
    -- โหมด Player
    EnableSpeedMode = false,
    SpeedMultiplier = 50,
    SpeedKeybind = nil, -- เก็บปุ่มลัด Speed
    
    EnableFlyMode = false,
    FlySpeed = 200,
    FlyKeybind = nil    -- เก็บปุ่มลัด Fly
}

-- ==========================================
-- 🎮 ระบบรับปุ่มลัด (Keybind Listener)
-- ==========================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if Settings.SpeedKeybind and input.KeyCode == Settings.SpeedKeybind then
            Settings.EnableSpeedMode = not Settings.EnableSpeedMode
            if getgenv().ToggleUpdates["EnableSpeedMode"] then getgenv().ToggleUpdates["EnableSpeedMode"](Settings.EnableSpeedMode) end
        elseif Settings.FlyKeybind and input.KeyCode == Settings.FlyKeybind then
            Settings.EnableFlyMode = not Settings.EnableFlyMode
            if getgenv().ToggleUpdates["EnableFlyMode"] then getgenv().ToggleUpdates["EnableFlyMode"](Settings.EnableFlyMode) end
        end
    end
end)

-- ==========================================
-- 🎨 สร้าง Premium GUI V9
-- ==========================================
local UI_Name = "PremiumRaidGUI_V9"
local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer.PlayerGui
if parentUI:FindFirstChild(UI_Name) then parentUI[UI_Name]:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = UI_Name
ScreenGui.Parent = parentUI

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 750, 0, 500) 
MainFrame.Position = UDim2.new(0.5, -375, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
local MainCorner = Instance.new("UICorner") MainCorner.CornerRadius = UDim.new(0, 10) MainCorner.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
local TopCorner = Instance.new("UICorner") TopCorner.CornerRadius = UDim.new(0, 10) TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 400, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Premium Raid Auto V9 (+Keybinds)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 40, 0, 30)
MinBtn.Position = UDim2.new(1, -95, 0, 7)
MinBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 18
MinBtn.Parent = TopBar
local MinCorner = Instance.new("UICorner") MinCorner.CornerRadius = UDim.new(0, 6) MinCorner.Parent = MinBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 30)
CloseBtn.Position = UDim2.new(1, -50, 0, 7)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = TopBar
local CloseCorner = Instance.new("UICorner") CloseCorner.CornerRadius = UDim.new(0, 6) CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local fbv = hrp:FindFirstChild("FlyBV") if fbv then fbv:Destroy() end
            local fbg = hrp:FindFirstChild("FlyBG") if fbg then fbg:Destroy() end
        end
        for _, p in ipairs(char:GetChildren()) do if p:IsA("BasePart") then p.CanCollide = true end end
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = 16 hum.PlatformStand = false end
    end
    ScreenGui:Destroy()
end)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 160, 1, -45)
Sidebar.Position = UDim2.new(0, 0, 0, 45)
Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local function createTabButton(text, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 45)
    btn.Position = UDim2.new(0, 0, 0, yPos)
    btn.BackgroundTransparency = 1
    btn.Text = "  ◇ " .. text
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = Sidebar
    return btn
end

local TabMain = createTabButton("Main", 0)
local TabHeist = createTabButton("ดันทองคำ", 45)
local TabPlayer = createTabButton("Player", 90)
local TabTeleport = createTabButton("Teleport", 135)
TabMain.TextColor3 = Color3.fromRGB(255, 255, 255)

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -170, 1, -55)
ContentArea.Position = UDim2.new(0, 165, 0, 50)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

local function createPage()
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 6
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Parent = ContentArea
    local list = Instance.new("UIListLayout") list.Padding = UDim.new(0, 8) list.Parent = page
    return page
end

local PageMain = createPage()
local PageHeist = createPage(); PageHeist.Visible = false
local PagePlayer = createPage(); PagePlayer.Visible = false
local PageTP = createPage(); PageTP.Visible = false

local function switchTab(activePage, activeBtn)
    PageMain.Visible = (activePage == PageMain)
    PageHeist.Visible = (activePage == PageHeist)
    PagePlayer.Visible = (activePage == PagePlayer)
    PageTP.Visible = (activePage == PageTP)
    
    TabMain.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabHeist.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabPlayer.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabTeleport.TextColor3 = Color3.fromRGB(150, 150, 150)
    activeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
end

TabMain.MouseButton1Click:Connect(function() switchTab(PageMain, TabMain) end)
TabHeist.MouseButton1Click:Connect(function() switchTab(PageHeist, TabHeist) end)
TabPlayer.MouseButton1Click:Connect(function() switchTab(PagePlayer, TabPlayer) end)
TabTeleport.MouseButton1Click:Connect(function() switchTab(PageTP, TabTeleport) end)

local isMin = false
MinBtn.MouseButton1Click:Connect(function()
    isMin = not isMin
    Sidebar.Visible = not isMin
    ContentArea.Visible = not isMin
    MainFrame.Size = isMin and UDim2.new(0, 750, 0, 45) or UDim2.new(0, 750, 0, 500)
    MinBtn.Text = isMin and "+" or "-"
end)

-- ==========================================
-- 🛠️ UI Builder Functions
-- ==========================================
local function CreateSectionLabel(parent, text)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -20, 0, 35)
    Frame.BackgroundTransparency = 1
    Frame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.Position = UDim2.new(0, 5, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 60, 60)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 15
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local Line = Instance.new("Frame")
    Line.Size = UDim2.new(1, -5, 0, 1)
    Line.Position = UDim2.new(0, 5, 1, -5)
    Line.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Line.BorderSizePixel = 0
    Line.Parent = Frame
end

local function CreateToggle(parent, text, flag)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -20, 0, 50)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Frame.Parent = parent
    local Corner = Instance.new("UICorner") Corner.CornerRadius = UDim.new(0, 8) Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -70, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 16
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local CheckboxBg = Instance.new("TextButton")
    CheckboxBg.Size = UDim2.new(0, 30, 0, 30)
    CheckboxBg.Position = UDim2.new(1, -45, 0.5, -15)
    CheckboxBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    CheckboxBg.Text = ""
    CheckboxBg.Parent = Frame
    local CCorner = Instance.new("UICorner") CCorner.CornerRadius = UDim.new(0, 6) CCorner.Parent = CheckboxBg

    local CheckboxFill = Instance.new("Frame")
    CheckboxFill.Size = UDim2.new(1, -6, 1, -6)
    CheckboxFill.Position = UDim2.new(0, 3, 0, 3)
    CheckboxFill.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CheckboxFill.Visible = Settings[flag]
    CheckboxFill.Parent = CheckboxBg
    local FCorner = Instance.new("UICorner") FCorner.CornerRadius = UDim.new(0, 4) FCorner.Parent = CheckboxFill

    getgenv().ToggleUpdates[flag] = function(state)
        CheckboxFill.Visible = state
    end

    CheckboxBg.MouseButton1Click:Connect(function()
        Settings[flag] = not Settings[flag]
        getgenv().ToggleUpdates[flag](Settings[flag])
    end)
end

-- 🔥 สร้าง Toggle พร้อมปุ่มตั้ง Keybind
local function CreateToggleWithKeybind(parent, text, flag, keybindFlag)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -20, 0, 50)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Frame.Parent = parent
    local Corner = Instance.new("UICorner") Corner.CornerRadius = UDim.new(0, 8) Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -130, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 16
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    -- ปุ่มตั้ง Keybind
    local KeyBtn = Instance.new("TextButton")
    KeyBtn.Size = UDim2.new(0, 60, 0, 30)
    KeyBtn.Position = UDim2.new(1, -115, 0.5, -15)
    KeyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    KeyBtn.Text = Settings[keybindFlag] and Settings[keybindFlag].Name or "NONE"
    KeyBtn.TextColor3 = Color3.fromRGB(200, 200, 255)
    KeyBtn.Font = Enum.Font.GothamBold
    KeyBtn.TextSize = 12
    KeyBtn.Parent = Frame
    local KCorner = Instance.new("UICorner") KCorner.CornerRadius = UDim.new(0, 6) KCorner.Parent = KeyBtn

    local isBinding = false
    KeyBtn.MouseButton1Click:Connect(function()
        isBinding = true
        KeyBtn.Text = "..."
    end)

    UserInputService.InputBegan:Connect(function(input)
        if isBinding and input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == Enum.KeyCode.Escape then
                Settings[keybindFlag] = nil
                KeyBtn.Text = "NONE"
            else
                Settings[keybindFlag] = input.KeyCode
                KeyBtn.Text = input.KeyCode.Name
            end
            isBinding = false
        end
    end)

    local CheckboxBg = Instance.new("TextButton")
    CheckboxBg.Size = UDim2.new(0, 30, 0, 30)
    CheckboxBg.Position = UDim2.new(1, -45, 0.5, -15)
    CheckboxBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    CheckboxBg.Text = ""
    CheckboxBg.Parent = Frame
    local CCorner = Instance.new("UICorner") CCorner.CornerRadius = UDim.new(0, 6) CCorner.Parent = CheckboxBg

    local CheckboxFill = Instance.new("Frame")
    CheckboxFill.Size = UDim2.new(1, -6, 1, -6)
    CheckboxFill.Position = UDim2.new(0, 3, 0, 3)
    CheckboxFill.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CheckboxFill.Visible = Settings[flag]
    CheckboxFill.Parent = CheckboxBg
    local FCorner = Instance.new("UICorner") FCorner.CornerRadius = UDim.new(0, 4) FCorner.Parent = CheckboxFill

    getgenv().ToggleUpdates[flag] = function(state)
        CheckboxFill.Visible = state
    end

    CheckboxBg.MouseButton1Click:Connect(function()
        Settings[flag] = not Settings[flag]
        getgenv().ToggleUpdates[flag](Settings[flag])
    end)
end

local function CreateSlider(parent, text, flag, minVal, maxVal)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -20, 0, 70)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Frame.Parent = parent
    local Corner = Instance.new("UICorner") Corner.CornerRadius = UDim.new(0, 8) Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -30, 0, 30)
    Label.Position = UDim2.new(0, 15, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 16
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 50, 0, 30)
    ValueLabel.Position = UDim2.new(1, -65, 0, 5)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = Settings[flag]
    ValueLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextSize = 16
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Frame

    local SliderBg = Instance.new("Frame")
    SliderBg.Size = UDim2.new(1, -30, 0, 10)
    SliderBg.Position = UDim2.new(0, 15, 0, 45)
    SliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    SliderBg.Parent = Frame
    local SCorner = Instance.new("UICorner") SCorner.CornerRadius = UDim.new(1, 0) SCorner.Parent = SliderBg

    local defaultPercent = (Settings[flag] - minVal) / (maxVal - minVal)
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new(defaultPercent, 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    SliderFill.Parent = SliderBg
    local FCorner = Instance.new("UICorner") FCorner.CornerRadius = UDim.new(1, 0) FCorner.Parent = SliderFill

    local SliderBtn = Instance.new("TextButton")
    SliderBtn.Size = UDim2.new(1, 0, 1, 20)
    SliderBtn.Position = UDim2.new(0, 0, 0, -10)
    SliderBtn.BackgroundTransparency = 1
    SliderBtn.Text = ""
    SliderBtn.Parent = SliderBg

    local isSliding = false
    SliderBtn.MouseButton1Down:Connect(function() isSliding = true end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then isSliding = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isSliding and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = math.clamp(UserInputService:GetMouseLocation().X - SliderBg.AbsolutePosition.X, 0, SliderBg.AbsoluteSize.X)
            local percent = relativeX / SliderBg.AbsoluteSize.X
            Settings[flag] = math.floor(minVal + ((maxVal - minVal) * percent))
            SliderFill.Size = UDim2.new(percent, 0, 1, 0)
            ValueLabel.Text = Settings[flag]
        end
    end)
end

-- ==========================================
-- 📝 หน้าต่าง UI - จัดวาง Layout
-- ==========================================
-- แท็บ Main
CreateToggle(PageMain, "Auto Farm (ทั่วไป)", "AutoFarm")
CreateToggle(PageMain, "Auto Click (MB1)", "AutoClick")
CreateSlider(PageMain, "Warp Distance", "Distance", 0, 15)

-- แท็บ ดันทองคำ
CreateToggle(PageHeist, "ดันทองคำ (Golden Heist AI)", "GoldenHeist")
local HeistInfo = Instance.new("TextLabel")
HeistInfo.Size = UDim2.new(1, -20, 0, 80)
HeistInfo.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
HeistInfo.TextColor3 = Color3.fromRGB(150, 255, 150)
HeistInfo.Font = Enum.Font.Gotham
HeistInfo.TextSize = 15
HeistInfo.TextWrapped = true
HeistInfo.Text = "ℹ️ ลอจิกดันทองคำ:\n1. วาร์ปเก็บของจากตู้ (Machines)\n2. โฟกัสตี Bankrupt Gamblers\n3. โฟกัสตี Golden Statue เป็นตัวสุดท้าย"
HeistInfo.Parent = PageHeist
local HCorner = Instance.new("UICorner") HCorner.CornerRadius = UDim.new(0, 8) HCorner.Parent = HeistInfo

-- 🔥 แท็บ Player (อัปเกรดระบบ Keybind & Speed/Fly)
CreateSectionLabel(PagePlayer, "Speed Controls")
CreateToggleWithKeybind(PagePlayer, "Enable Speed Mode", "EnableSpeedMode", "SpeedKeybind")
CreateSlider(PagePlayer, "Speed Multiplier", "SpeedMultiplier", 16, 250) -- สำหรับ CFrame สปีด 250 คือทะลุนรกแล้วครับ

CreateSectionLabel(PagePlayer, "Fly Controls")
CreateToggleWithKeybind(PagePlayer, "Enable Fly Mode", "EnableFlyMode", "FlyKeybind")
CreateSlider(PagePlayer, "Fly Speed", "FlySpeed", 16, 1000) -- 🔥 ปรับให้บินทะลุ 1000 ได้เลย!

-- ==========================================
-- 🧠 Core Loop & AI Logic
-- ==========================================
if getgenv().FarmLoop then getgenv().FarmLoop:Disconnect() end

getgenv().FarmLoop = RunService.Heartbeat:Connect(function(deltaTime)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    local cam = workspace.CurrentCamera

    if hrp and hum and hum.Health > 0 then

        -- 🔥 ลอจิกการบิน
        if Settings.EnableFlyMode then
            local flyBV = hrp:FindFirstChild("FlyBV")
            local flyBG = hrp:FindFirstChild("FlyBG")
            
            if not flyBV then
                flyBV = Instance.new("BodyVelocity")
                flyBV.Name = "FlyBV"
                flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                flyBV.Parent = hrp
            end
            if not flyBG then
                flyBG = Instance.new("BodyGyro")
                flyBG.Name = "FlyBG"
                flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                flyBG.P = 10000
                flyBG.Parent = hrp
            end
            
            hum.PlatformStand = true
            flyBG.CFrame = cam.CFrame
            
            local dir = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
            
            if dir.Magnitude == 0 and hum.MoveDirection.Magnitude > 0 then
                local localMove = cam.CFrame:VectorToObjectSpace(hum.MoveDirection)
                dir = cam.CFrame:VectorToWorldSpace(localMove)
            end
            
            if dir.Magnitude > 0 then
                flyBV.Velocity = dir.Unit * Settings.FlySpeed
            else
                flyBV.Velocity = Vector3.new(0, 0, 0)
            end
        else
            -- ปิดบิน คืนค่าฟิสิกส์
            local flyBV = hrp:FindFirstChild("FlyBV")
            local flyBG = hrp:FindFirstChild("FlyBG")
            if flyBV then flyBV:Destroy() end
            if flyBG then flyBG:Destroy() end
            if hum.PlatformStand then hum.PlatformStand = false end
            
            -- 🔥 ลอจิก CFrame Speed Mode (ใช้กรณีที่ไม่ได้บินอยู่เท่านั้น)
            if Settings.EnableSpeedMode then
                hum.WalkSpeed = 16 -- ล็อกอนิเมชันให้เดินปกติ
                if hum.MoveDirection.Magnitude > 0 then
                    -- สไลด์เป้าหมายไปข้างหน้าด้วยฟิสิกส์คูณเวลา (ทะลุตัวล็อกความเร็วของเกม)
                    hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (Settings.SpeedMultiplier * deltaTime))
                end
            end
        end

        -- ... (ส่วน AI AutoFarm ตัดออกเพื่อให้โฟกัสที่การเคลื่อนที่)
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if Settings.AutoClick then
            pcall(function()
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                task.wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
            end)
        end
    end
end)
