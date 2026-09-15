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
    Distance = 4
}

-- ==========================================
-- 🎨 สร้าง Premium GUI (ระบบ Dropdown กางออกได้)
-- ==========================================
local UI_Name = "PremiumRaidGUI_V4"
local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer.PlayerGui
if parentUI:FindFirstChild(UI_Name) then parentUI[UI_Name]:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = UI_Name
ScreenGui.Parent = parentUI

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 480, 0, 300)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
local MainCorner = Instance.new("UICorner") MainCorner.CornerRadius = UDim.new(0, 8) MainCorner.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
local TopCorner = Instance.new("UICorner") TopCorner.CornerRadius = UDim.new(0, 8) TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Premium Raid Auto V4"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 20)
CloseBtn.Position = UDim2.new(1, -35, 0, 7)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar
local CloseCorner = Instance.new("UICorner") CloseCorner.CornerRadius = UDim.new(0, 4) CloseCorner.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 120, 1, -35)
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local TabMain = Instance.new("TextButton")
TabMain.Size = UDim2.new(1, 0, 0, 30)
TabMain.BackgroundTransparency = 1
TabMain.Text = "  ◇ Main"
TabMain.TextColor3 = Color3.fromRGB(255, 255, 255)
TabMain.Font = Enum.Font.GothamBold
TabMain.TextSize = 13
TabMain.TextXAlignment = Enum.TextXAlignment.Left
TabMain.Parent = Sidebar

local TabTeleport = Instance.new("TextButton")
TabTeleport.Size = UDim2.new(1, 0, 0, 30)
TabTeleport.Position = UDim2.new(0, 0, 0, 30)
TabTeleport.BackgroundTransparency = 1
TabTeleport.Text = "  ◇ Teleport"
TabTeleport.TextColor3 = Color3.fromRGB(150, 150, 150)
TabTeleport.Font = Enum.Font.GothamBold
TabTeleport.TextSize = 13
TabTeleport.TextXAlignment = Enum.TextXAlignment.Left
TabTeleport.Parent = Sidebar

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -130, 1, -45)
ContentArea.Position = UDim2.new(0, 125, 0, 40)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

-- ใช้ AutomaticCanvasSize เพื่อให้หน้าต่างขยายเองเวลากาง Dropdown
local PageMain = Instance.new("ScrollingFrame")
PageMain.Size = UDim2.new(1, 0, 1, 0)
PageMain.BackgroundTransparency = 1
PageMain.BorderSizePixel = 0
PageMain.ScrollBarThickness = 4
PageMain.AutomaticCanvasSize = Enum.AutomaticSize.Y 
PageMain.Parent = ContentArea
local UIList1 = Instance.new("UIListLayout") UIList1.Padding = UDim.new(0, 5) UIList1.Parent = PageMain

local PageTP = Instance.new("ScrollingFrame")
PageTP.Size = UDim2.new(1, 0, 1, 0)
PageTP.BackgroundTransparency = 1
PageTP.BorderSizePixel = 0
PageTP.ScrollBarThickness = 4
PageTP.AutomaticCanvasSize = Enum.AutomaticSize.Y
PageTP.Visible = false
PageTP.Parent = ContentArea
local UIList2 = Instance.new("UIListLayout") UIList2.Padding = UDim.new(0, 5) UIList2.Parent = PageTP

-- ==========================================
-- 🛠️ ฟังก์ชันสร้าง UI 
-- ==========================================
local function CreateToggle(parent, text, flag)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 35)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Frame.Parent = parent
    local Corner = Instance.new("UICorner") Corner.CornerRadius = UDim.new(0, 6) Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local CheckboxBg = Instance.new("TextButton")
    CheckboxBg.Size = UDim2.new(0, 20, 0, 20)
    CheckboxBg.Position = UDim2.new(1, -30, 0.5, -10)
    CheckboxBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    CheckboxBg.Text = ""
    CheckboxBg.Parent = Frame
    local CCorner = Instance.new("UICorner") CCorner.CornerRadius = UDim.new(0, 4) CCorner.Parent = CheckboxBg

    local CheckboxFill = Instance.new("Frame")
    CheckboxFill.Size = UDim2.new(1, -4, 1, -4)
    CheckboxFill.Position = UDim2.new(0, 2, 0, 2)
    CheckboxFill.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    CheckboxFill.Visible = false
    CheckboxFill.Parent = CheckboxBg
    local FCorner = Instance.new("UICorner") FCorner.CornerRadius = UDim.new(0, 3) FCorner.Parent = CheckboxFill

    CheckboxBg.MouseButton1Click:Connect(function()
        Settings[flag] = not Settings[flag]
        CheckboxFill.Visible = Settings[flag]
    end)
end

-- 🔥 ระบบ Dropdown ของแท้ (ขยายกางลงมาได้)
local function CreateRealDropdown(parent, text, flag, getOptionsFunc)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -10, 0, 35) -- ขนาดตอนหด
    Container.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Container.ClipsDescendants = true
    Container.Parent = parent
    local Corner = Instance.new("UICorner") Corner.CornerRadius = UDim.new(0, 6) Corner.Parent = Container

    local TopFrame = Instance.new("Frame")
    TopFrame.Size = UDim2.new(1, 0, 0, 35)
    TopFrame.BackgroundTransparency = 1
    TopFrame.Parent = Container

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.4, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = TopFrame

    local DropBtn = Instance.new("TextButton")
    DropBtn.Size = UDim2.new(0.5, 0, 0, 25)
    DropBtn.Position = UDim2.new(1, -10, 0.5, -12.5)
    DropBtn.AnchorPoint = Vector2.new(1, 0)
    DropBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    DropBtn.Text = Settings[flag] .. " ▼"
    DropBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropBtn.Font = Enum.Font.Gotham
    DropBtn.TextSize = 12
    DropBtn.TextTruncate = Enum.TextTruncate.AtEnd
    DropBtn.Parent = TopFrame
    local DCorner = Instance.new("UICorner") DCorner.CornerRadius = UDim.new(0, 4) DCorner.Parent = DropBtn

    -- พื้นที่แสดงรายชื่อ
    local ListFrame = Instance.new("ScrollingFrame")
    ListFrame.Size = UDim2.new(1, 0, 1, -40)
    ListFrame.Position = UDim2.new(0, 0, 0, 40)
    ListFrame.BackgroundTransparency = 1
    ListFrame.BorderSizePixel = 0
    ListFrame.ScrollBarThickness = 3
    ListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ListFrame.Parent = Container
    local ListLayout = Instance.new("UIListLayout") ListLayout.Padding = UDim.new(0, 2) ListLayout.Parent = ListFrame

    local isOpen = false

    DropBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            -- ลบของเก่าออกก่อน
            for _, child in ipairs(ListFrame:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            
            -- ดึงรายชื่อใหม่
            local options = getOptionsFunc()
            
            -- สร้างปุ่มรายชื่อ
            for _, opt in ipairs(options) do
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, -15, 0, 25)
                Btn.Position = UDim2.new(0, 5, 0, 0)
                Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                Btn.Text = "  " .. opt
                Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
                Btn.Font = Enum.Font.Gotham
                Btn.TextSize = 12
                Btn.TextXAlignment = Enum.TextXAlignment.Left
                Btn.Parent = ListFrame
                local BCorner = Instance.new("UICorner") BCorner.CornerRadius = UDim.new(0, 4) BCorner.Parent = Btn
                
                Btn.MouseButton1Click:Connect(function()
                    Settings[flag] = opt
                    DropBtn.Text = opt .. " ▼"
                    isOpen = false
                    Container.Size = UDim2.new(1, -10, 0, 35) -- หดกลับ
                end)
            end
            
            -- ขยายขนาด Container ให้เห็น List (โชว์สูงสุด 4 ไอเทมแล้วที่เหลือให้ไถสกอร์)
            local expandedHeight = 35 + math.min(#options * 27, 110)
            Container.Size = UDim2.new(1, -10, 0, expandedHeight)
        else
            Container.Size = UDim2.new(1, -10, 0, 35) -- หดกลับ
        end
    end)
end

local function CreateButton(parent, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 13
    Btn.Parent = parent
    local Corner = Instance.new("UICorner") Corner.CornerRadius = UDim.new(0, 6) Corner.Parent = Btn
    Btn.MouseButton1Click:Connect(callback)
end

-- ==========================================
-- 📝 ใส่เนื้อหาลงหน้าต่าง
-- ==========================================
-- แท็บ Main
CreateToggle(PageMain, "Auto Farm", "AutoFarm")
CreateToggle(PageMain, "Auto Click (MB1)", "AutoClick")

CreateRealDropdown(PageMain, "Target Monster", "TargetMob", function()
    local mobs = {"None"}
    local entities = workspace:FindFirstChild("Entities")
    if entities then
        local found = {}
        for _, obj in ipairs(entities:GetChildren()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
                local cleanName = string.gsub(obj.Name, "%d+$", "") -- ตัดเลขท้ายชื่อออก
                cleanName = cleanName:match("^%s*(.-)%s*$") -- ตัดช่องว่างซ้ายขวา
                if not found[cleanName] then
                    found[cleanName] = true
                    table.insert(mobs, cleanName)
                end
            end
        end
    end
    return mobs
end)

-- แท็บ Teleport
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

CreateButton(PageTP, "🚀 Teleport to Spawner", function()
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
        -- 🔥 อัปเกรดระบบค้นหา Spawner: ค้นหาแบบทะลวงลึกทุกโฟลเดอร์ย่อย (true)
        local spawner = targetIsland:FindFirstChild("Spawner", true) 
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if spawner and hrp then
            -- ปิดการทำงานของฟิสิกส์ชั่วคราวกันเด้ง
            hrp.Velocity = Vector3.new(0,0,0)
            -- วาร์ปไปจุดสุ่มมอนสเตอร์ (ลอยเหนือพื้น 5 เมตรกันตัวติดดิน)
            hrp.CFrame = spawner.CFrame * CFrame.new(0, 5, 0)
            print("วาร์ปไป Spawner สำเร็จ!")
        else
            print("ไม่พบ Spawner บนเกาะนี้!")
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
-- 🧠 AI ฟาร์มตามเป้าหมายที่เลือก
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
    if Settings.AutoFarm then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
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
