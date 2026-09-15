local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
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
    Distance = 4
}

-- ==========================================
-- 🎨 สร้าง Premium GUI (สไตล์ตามภาพอ้างอิง)
-- ==========================================
local UI_Name = "PremiumRaidGUI"
local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer.PlayerGui
if parentUI:FindFirstChild(UI_Name) then parentUI[UI_Name]:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = UI_Name
ScreenGui.Parent = parentUI

-- กรอบหลัก
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 280)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
local MainCorner = Instance.new("UICorner") MainCorner.CornerRadius = UDim.new(0, 8) MainCorner.Parent = MainFrame

-- แถบด้านบน
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
local TopCorner = Instance.new("UICorner") TopCorner.CornerRadius = UDim.new(0, 8) TopCorner.Parent = TopBar
local HideTop = Instance.new("Frame") HideTop.Size = UDim2.new(1, 0, 0, 10) HideTop.Position = UDim2.new(0, 0, 1, -10) HideTop.BackgroundColor3 = Color3.fromRGB(25, 25, 25) HideTop.BorderSizePixel = 0 HideTop.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Premium Raid Auto"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- ปุ่มปิด/ย่อ
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 20)
MinBtn.Position = UDim2.new(1, -70, 0, 7)
MinBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = TopBar
local MinCorner = Instance.new("UICorner") MinCorner.CornerRadius = UDim.new(0, 4) MinCorner.Parent = MinBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 20)
CloseBtn.Position = UDim2.new(1, -35, 0, 7)
CloseBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar
local CloseCorner = Instance.new("UICorner") CloseCorner.CornerRadius = UDim.new(0, 4) CloseCorner.Parent = CloseBtn

-- Sidebar (แถบเมนูด้านซ้าย)
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

-- คอนเทนเนอร์เนื้อหาด้านขวา
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -130, 1, -45)
ContentArea.Position = UDim2.new(0, 125, 0, 40)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

local PageMain = Instance.new("ScrollingFrame")
PageMain.Size = UDim2.new(1, 0, 1, 0)
PageMain.BackgroundTransparency = 1
PageMain.BorderSizePixel = 0
PageMain.ScrollBarThickness = 2
PageMain.Parent = ContentArea

local PageTP = Instance.new("ScrollingFrame")
PageTP.Size = UDim2.new(1, 0, 1, 0)
PageTP.BackgroundTransparency = 1
PageTP.BorderSizePixel = 0
PageTP.ScrollBarThickness = 2
PageTP.Visible = false
PageTP.Parent = ContentArea

local UIList1 = Instance.new("UIListLayout") UIList1.Padding = UDim.new(0, 5) UIList1.Parent = PageMain
local UIList2 = Instance.new("UIListLayout") UIList2.Padding = UDim.new(0, 5) UIList2.Parent = PageTP

-- ==========================================
-- 🛠️ ฟังก์ชันสร้าง UI Elements
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

local function CreateDropdown(parent, text, flag, getOptionsFunc)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 35)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Frame.Parent = parent
    local Corner = Instance.new("UICorner") Corner.CornerRadius = UDim.new(0, 6) Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local DropBtn = Instance.new("TextButton")
    DropBtn.Size = UDim2.new(0.45, 0, 0, 25)
    DropBtn.Position = UDim2.new(1, -10, 0.5, -12.5)
    DropBtn.AnchorPoint = Vector2.new(1, 0)
    DropBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    DropBtn.Text = Settings[flag]
    DropBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropBtn.Font = Enum.Font.Gotham
    DropBtn.TextSize = 12
    DropBtn.ClipsDescendants = true
    DropBtn.Parent = Frame
    local DCorner = Instance.new("UICorner") DCorner.CornerRadius = UDim.new(0, 4) DCorner.Parent = DropBtn

    DropBtn.MouseButton1Click:Connect(function()
        local options = getOptionsFunc()
        if #options == 0 then DropBtn.Text = "No targets found" task.wait(1) DropBtn.Text = Settings[flag] return end
        
        -- ค้นหาว่าตัวไหนถูกเลือกต่อไป
        local currentIndex = 1
        for i, v in ipairs(options) do if v == Settings[flag] then currentIndex = i break end end
        
        currentIndex = currentIndex + 1
        if currentIndex > #options then currentIndex = 1 end
        
        Settings[flag] = options[currentIndex]
        DropBtn.Text = Settings[flag]
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
-- หน้า Main
CreateToggle(PageMain, "Auto Farm", "AutoFarm")
CreateToggle(PageMain, "Auto Click (MB1)", "AutoClick")

-- ดึงชื่อมอนสเตอร์สดๆ (ไม่ซ้ำ)
CreateDropdown(PageMain, "Target Monster:", "TargetMob", function()
    local mobs = {"None"}
    local entities = workspace:FindFirstChild("Entities")
    if entities then
        local found = {}
        for _, obj in ipairs(entities:GetChildren()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
                local cleanName = string.gsub(obj.Name, "%d+$", "") -- ลบตัวเลขท้ายชื่อ
                cleanName = cleanName:match("^%s*(.-)%s*$") -- ตัดช่องว่าง
                if not found[cleanName] then
                    found[cleanName] = true
                    table.insert(mobs, cleanName)
                end
            end
        end
    end
    return mobs
end)

-- หน้า Teleport
local selectedIsland = "None"
CreateDropdown(PageTP, "Select Island:", "TargetIsland", function()
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
    
    -- ค้นหาเกาะที่เลือก
    local targetIsland
    for i, island in ipairs(islandsFolder:GetChildren()) do
        local name = island.Name
        if name == "" or name == " " then name = "Island " .. tostring(i) end
        if name == Settings.TargetIsland then targetIsland = island; break end
    end
    
    if targetIsland then
        -- หาจุด Spawner
        local spawner = targetIsland:FindFirstChild("Model") and targetIsland.Model:FindFirstChild("Spawner")
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if spawner and hrp then
            -- วาร์ปไปจุดเกิดมอนสเตอร์ (ลอยเหนือพื้น 5 เมตรกันติดบัค)
            hrp.CFrame = spawner.CFrame * CFrame.new(0, 5, 0)
        else
            print("ไม่พบ Spawner บนเกาะนี้!")
        end
    end
end)

-- ==========================================
-- ⚙️ ระบบปุ่มต่างๆ (ย่อ, ปิด, สลับแท็บ)
-- ==========================================
TabMain.MouseButton1Click:Connect(function()
    PageMain.Visible = true; PageTP.Visible = false
    TabMain.TextColor3 = Color3.fromRGB(255, 255, 255); TabTeleport.TextColor3 = Color3.fromRGB(150, 150, 150)
end)
TabTeleport.MouseButton1Click:Connect(function()
    PageMain.Visible = false; PageTP.Visible = true
    TabTeleport.TextColor3 = Color3.fromRGB(255, 255, 255); TabMain.TextColor3 = Color3.fromRGB(150, 150, 150)
end)

local isMin = false
MinBtn.MouseButton1Click:Connect(function()
    isMin = not isMin
    Sidebar.Visible = not isMin
    ContentArea.Visible = not isMin
    MainFrame.Size = isMin and UDim2.new(0, 450, 0, 35) or UDim2.new(0, 450, 0, 280)
end)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- ==========================================
-- 🧠 AI ฟาร์มตามเป้าหมาย Dropdown
-- ==========================================
local function getDropdownMonster()
    if Settings.TargetMob == "None" then return nil end
    local nearest, minDist = nil, math.huge
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local entities = workspace:FindFirstChild("Entities")
    
    if not entities or not hrp then return nil end
    
    for _, obj in ipairs(entities:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 and not Players:GetPlayerFromCharacter(obj) then
            -- เช็คว่าชื่อตรงกับที่เลือกใน Dropdown ไหม
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

-- ==========================================
-- 🚀 Core Loop
-- ==========================================
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
                if tRoot then hrp.CFrame = CFrame.lookAt((tRoot.CFrame * CFrame.new(0, 0, Settings.Distance)).Position, tRoot.Position) end
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
