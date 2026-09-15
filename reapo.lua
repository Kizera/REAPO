local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- ⚙️ การตั้งค่าระบบ
-- ==========================================
local Settings = {
    AutoFarm = false,
    AutoClick = false,
    TargetMob = "None",
    TargetIsland = "None",
    Distance = 4,
    WalkSpeed = 16 -- ค่าเริ่มต้น
}

-- ==========================================
-- 🎨 สร้าง Premium GUI (ไซส์ 3X ขยายใหญ่)
-- ==========================================
local UI_Name = "PremiumRaidGUI_V5"
local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer.PlayerGui
if parentUI:FindFirstChild(UI_Name) then parentUI[UI_Name]:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = UI_Name
ScreenGui.Parent = parentUI

-- ขยายขนาด MainFrame ให้ใหญ่จุใจ
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
TopBar.Size = UDim2.new(1, 0, 0, 45) -- ขยายแถบบน
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
local TopCorner = Instance.new("UICorner") TopCorner.CornerRadius = UDim.new(0, 10) TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 300, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Premium Raid Auto V5 (Titan Size)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20 -- ขยายฟอนต์
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

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
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 160, 1, -45)
Sidebar.Position = UDim2.new(0, 0, 0, 45)
Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local TabMain = Instance.new("TextButton")
TabMain.Size = UDim2.new(1, 0, 0, 45)
TabMain.BackgroundTransparency = 1
TabMain.Text = "  ◇ Main"
TabMain.TextColor3 = Color3.fromRGB(255, 255, 255)
TabMain.Font = Enum.Font.GothamBold
TabMain.TextSize = 18
TabMain.TextXAlignment = Enum.TextXAlignment.Left
TabMain.Parent = Sidebar

local TabTeleport = Instance.new("TextButton")
TabTeleport.Size = UDim2.new(1, 0, 0, 45)
TabTeleport.Position = UDim2.new(0, 0, 0, 45)
TabTeleport.BackgroundTransparency = 1
TabTeleport.Text = "  ◇ Teleport"
TabTeleport.TextColor3 = Color3.fromRGB(150, 150, 150)
TabTeleport.Font = Enum.Font.GothamBold
TabTeleport.TextSize = 18
TabTeleport.TextXAlignment = Enum.TextXAlignment.Left
TabTeleport.Parent = Sidebar

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -170, 1, -55)
ContentArea.Position = UDim2.new(0, 165, 0, 50)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

local PageMain = Instance.new("ScrollingFrame")
PageMain.Size = UDim2.new(1, 0, 1, 0)
PageMain.BackgroundTransparency = 1
PageMain.BorderSizePixel = 0
PageMain.ScrollBarThickness = 6
PageMain.AutomaticCanvasSize = Enum.AutomaticSize.Y 
PageMain.Parent = ContentArea
local UIList1 = Instance.new("UIListLayout") UIList1.Padding = UDim.new(0, 8) UIList1.Parent = PageMain

local PageTP = Instance.new("ScrollingFrame")
PageTP.Size = UDim2.new(1, 0, 1, 0)
PageTP.BackgroundTransparency = 1
PageTP.BorderSizePixel = 0
PageTP.ScrollBarThickness = 6
PageTP.AutomaticCanvasSize = Enum.AutomaticSize.Y
PageTP.Visible = false
PageTP.Parent = ContentArea
local UIList2 = Instance.new("UIListLayout") UIList2.Padding = UDim.new(0, 8) UIList2.Parent = PageTP

-- ==========================================
-- 🛠️ ฟังก์ชันสร้าง UI (แบบขยายสเกล)
-- ==========================================
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
    Label.TextSize = 18
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
    CheckboxFill.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    CheckboxFill.Visible = false
    CheckboxFill.Parent = CheckboxBg
    local FCorner = Instance.new("UICorner") FCorner.CornerRadius = UDim.new(0, 4) FCorner.Parent = CheckboxFill

    CheckboxBg.MouseButton1Click:Connect(function()
        Settings[flag] = not Settings[flag]
        CheckboxFill.Visible = Settings[flag]
    end)
end

-- 🔥 Dropdown แบบกว้างพิเศษ
local function CreateRealDropdown(parent, text, flag, getOptionsFunc)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -20, 0, 50) 
    Container.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Container.ClipsDescendants = true
    Container.Parent = parent
    local Corner = Instance.new("UICorner") Corner.CornerRadius = UDim.new(0, 8) Corner.Parent = Container

    local TopFrame = Instance.new("Frame")
    TopFrame.Size = UDim2.new(1, 0, 0, 50)
    TopFrame.BackgroundTransparency = 1
    TopFrame.Parent = Container

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.35, 0, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 18
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = TopFrame

    -- กล่อง Dropdown กว้างขึ้นมาก
    local DropBtn = Instance.new("TextButton")
    DropBtn.Size = UDim2.new(0.6, 0, 0, 35)
    DropBtn.Position = UDim2.new(1, -15, 0.5, -17.5)
    DropBtn.AnchorPoint = Vector2.new(1, 0)
    DropBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    DropBtn.Text = Settings[flag] .. " ▼"
    DropBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropBtn.Font = Enum.Font.Gotham
    DropBtn.TextSize = 16
    DropBtn.TextTruncate = Enum.TextTruncate.AtEnd
    DropBtn.Parent = TopFrame
    local DCorner = Instance.new("UICorner") DCorner.CornerRadius = UDim.new(0, 6) DCorner.Parent = DropBtn

    local ListFrame = Instance.new("ScrollingFrame")
    ListFrame.Size = UDim2.new(1, 0, 1, -55)
    ListFrame.Position = UDim2.new(0, 0, 0, 55)
    ListFrame.BackgroundTransparency = 1
    ListFrame.BorderSizePixel = 0
    ListFrame.ScrollBarThickness = 5
    ListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ListFrame.Parent = Container
    local ListLayout = Instance.new("UIListLayout") ListLayout.Padding = UDim.new(0, 4) ListLayout.Parent = ListFrame

    local isOpen = false

    DropBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            for _, child in ipairs(ListFrame:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            
            local options = getOptionsFunc()
            for _, opt in ipairs(options) do
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, -20, 0, 35)
                Btn.Position = UDim2.new(0, 10, 0, 0)
                Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                Btn.Text = "  " .. opt
                Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
                Btn.Font = Enum.Font.Gotham
                Btn.TextSize = 16
                Btn.TextXAlignment = Enum.TextXAlignment.Left
                Btn.Parent = ListFrame
                local BCorner = Instance.new("UICorner") BCorner.CornerRadius = UDim.new(0, 6) BCorner.Parent = Btn
                
                Btn.MouseButton1Click:Connect(function()
                    Settings[flag] = opt
                    DropBtn.Text = opt .. " ▼"
                    isOpen = false
                    Container.Size = UDim2.new(1, -20, 0, 50)
                end)
            end
            
            local expandedHeight = 50 + math.min(#options * 39, 200)
            Container.Size = UDim2.new(1, -20, 0, expandedHeight)
        else
            Container.Size = UDim2.new(1, -20, 0, 50)
        end
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
    Label.Text = text .. ": " .. Settings[flag]
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 18
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local SliderBg = Instance.new("Frame")
    SliderBg.Size = UDim2.new(1, -30, 0, 12)
    SliderBg.Position = UDim2.new(0, 15, 0, 45)
    SliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    SliderBg.Parent = Frame
    local SCorner = Instance.new("UICorner") SCorner.CornerRadius = UDim.new(1, 0) SCorner.Parent = SliderBg

    local defaultPercent = (Settings[flag] - minVal) / (maxVal - minVal)
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new(defaultPercent, 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(40, 200, 255)
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
            Label.Text = text .. ": " .. Settings[flag]
        end
    end)
end

local function CreateButton(parent, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -20, 0, 50)
    Btn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 18
    Btn.Parent = parent
    local Corner = Instance.new("UICorner") Corner.CornerRadius = UDim.new(0, 8) Corner.Parent = Btn
    Btn.MouseButton1Click:Connect(callback)
end

-- ==========================================
-- 📝 ใส่เนื้อหาลงหน้าต่าง
-- ==========================================
CreateToggle(PageMain, "Auto Farm", "AutoFarm")
CreateToggle(PageMain, "Auto Click (MB1)", "AutoClick")
CreateSlider(PageMain, "Warp Distance", "Distance", 0, 15)
CreateSlider(PageMain, "Walk Speed", "WalkSpeed", 16, 100) -- แถบปรับสปีด 16 ถึง 100

CreateRealDropdown(PageMain, "Target Monster", "TargetMob", function()
    local mobs = {"None"}
    local entities = workspace:FindFirstChild("Entities")
    if entities then
        local found = {}
        for _, obj in ipairs(entities:GetChildren()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
                local cleanName = string.gsub(obj.Name, "%d+$", "") 
                cleanName = cleanName:match("^%s*(.-)%s*$")
                if not found[cleanName] then found[cleanName] = true table.insert(mobs, cleanName) end
            end
        end
    end
    return mobs
end)

CreateRealDropdown(PageTP, "Select Island", "TargetIsland", function()
    local isls = {"None"}
    local map = workspace:FindFirstChild("Map")
    local islandsFolder = map and map:FindFirstChild("Islands")
    if islandsFolder then
        for i, island in ipairs(islandsFolder:GetChildren()) do
            local name = island.Name
            if name == "" or name == " " then name = "Island " .. tostring(i) end
            table.insert(isls, name)
        end
    end
    return isls
end)

CreateButton(PageTP, "🚀 Teleport to Island", function()
    local map = workspace:FindFirstChild("Map")
    local islandsFolder = map and map:FindFirstChild("Islands")
    if not islandsFolder or Settings.TargetIsland == "None" then return end
    
    local targetIsland
    for i, island in ipairs(islandsFolder:GetChildren()) do
        local name = island.Name
        if name == "" or name == " " then name = "Island " .. tostring(i) end
        if name == Settings.TargetIsland then targetIsland = island; break end
    end
    
    if targetIsland then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Velocity = Vector3.new(0,0,0)
            
            -- 🔥 [ลอจิกใหม่]: หา Spawner ก่อน ถ้าไม่มี ให้ดึงแกนกลาง (Pivot) ของเกาะแทน
            local spawner = targetIsland:FindFirstChild("Spawner", true)
            if spawner and spawner:IsA("BasePart") then
                hrp.CFrame = spawner.CFrame * CFrame.new(0, 5, 0)
            else
                -- ทะลวงจุดเกิด ถ้าเกมลบ Spawner ทิ้งไปแล้ว เราจะวาร์ปไปตรงกลางโมเดลเกาะเลย
                hrp.CFrame = targetIsland:GetPivot() * CFrame.new(0, 20, 0)
            end
            print("วาร์ปข้ามเกาะสำเร็จ!")
        end
    end
end)

-- ==========================================
-- ⚙️ ระบบสลับแท็บ
-- ==========================================
TabMain.MouseButton1Click:Connect(function()
    PageMain.Visible = true; PageTP.Visible = false
    TabMain.TextColor3 = Color3.fromRGB(255, 255, 255); TabTeleport.TextColor3 = Color3.fromRGB(150, 150, 150)
end)
TabTeleport.MouseButton1Click:Connect(function()
    PageMain.Visible = false; PageTP.Visible = true
    TabTeleport.TextColor3 = Color3.fromRGB(255, 255, 255); TabMain.TextColor3 = Color3.fromRGB(150, 150, 150)
end)

-- ==========================================
-- 🧠 Core Loop (วาร์ป & ล็อคสปีดแบบ Real-time)
-- ==========================================
local function getDropdownMonster()
    if Settings.TargetMob == "None" then return nil end
    local nearest, minDist = nil, math.huge
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local entities = workspace:FindFirstChild("Entities")
    
    if not entities or not hrp then return nil end
    
    for _, obj in ipairs(entities:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 and not Players:GetPlayerFromCharacter(obj) then
            if string.match(string.lower(obj.Name), string.lower(Settings.TargetMob)) then
                local mobRoot = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
                if mobRoot then
                    local dist = (hrp.Position - mobRoot.Position).Magnitude
                    if dist < minDist then minDist = dist; nearest = obj end
                end
            end
        end
    end
    return nearest
end

if getgenv().FarmLoop then getgenv().FarmLoop:Disconnect() end

getgenv().FarmLoop = RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    
    -- 🔥 ล็อคความเร็วแบบ Real-time (บังคับอัปเดตทุกเฟรม)
    if hum and hum.Health > 0 then
        hum.WalkSpeed = Settings.WalkSpeed
    end

    -- ระบบวาร์ปตีมอน
    if Settings.AutoFarm and hrp then
        for _, part in ipairs(char:GetChildren()) do if part:IsA("BasePart") then part.CanCollide = false end end
        hrp.Velocity = Vector3.new(0,0,0)
        
        local target = getDropdownMonster()
        if target then
            local tRoot = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Torso")
            if tRoot then 
                hrp.CFrame = CFrame.lookAt((tRoot.CFrame * CFrame.new(0, 0, Settings.Distance)).Position, tRoot.Position) 
            end
        end
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
