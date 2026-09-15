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
    GoldenHeist = false,
    TargetMob = "None",
    TargetIsland = "None",
    Distance = 4,
    WalkSpeed = 16
}

-- ==========================================
-- 🎨 สร้าง Premium GUI (เพิ่มเมนู "ดันทองคำ")
-- ==========================================
local UI_Name = "PremiumRaidGUI_GoldenHeist_Fix"
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
Title.Size = UDim2.new(0, 350, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Premium Raid Auto (Fixed Version)"
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

-- ปุ่มกากบาทกดเคลียร์ค่าฟิสิกส์ทั้งหมดก่อนปิด GUI ป้องกันตัวค้าง
CloseBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if char then
        for _, p in ipairs(char:GetChildren()) do if p:IsA("BasePart") then p.CanCollide = true end end
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = 16 end
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
local TabHeist = createTabButton("ดันทองคำ (Golden Heist)", 45)
local TabTeleport = createTabButton("Teleport", 90)
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
local PageTP = createPage(); PageTP.Visible = false

local function switchTab(activePage, activeBtn)
    PageMain.Visible = (activePage == PageMain)
    PageHeist.Visible = (activePage == PageHeist)
    PageTP.Visible = (activePage == PageTP)
    
    TabMain.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabHeist.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabTeleport.TextColor3 = Color3.fromRGB(150, 150, 150)
    activeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
end

TabMain.MouseButton1Click:Connect(function() switchTab(PageMain, TabMain) end)
TabHeist.MouseButton1Click:Connect(function() switchTab(PageHeist, TabHeist) end)
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
    CheckboxFill.Visible = Settings[flag]
    CheckboxFill.Parent = CheckboxBg
    local FCorner = Instance.new("UICorner") FCorner.CornerRadius = UDim.new(0, 4) FCorner.Parent = CheckboxFill

    CheckboxBg.MouseButton1Click:Connect(function()
        Settings[flag] = not Settings[flag]
        CheckboxFill.Visible = Settings[flag]
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
-- 📝 หน้าต่าง UI
-- ==========================================
CreateToggle(PageMain, "Auto Farm (ทั่วไป)", "AutoFarm")
CreateToggle(PageMain, "Auto Click (MB1)", "AutoClick")
CreateSlider(PageMain, "Warp Distance", "Distance", 0, 15)
CreateSlider(PageMain, "Walk Speed", "WalkSpeed", 16, 100)

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

CreateToggle(PageHeist, "ดันทองคำ (Golden Heist AI)", "GoldenHeist")
local HeistInfo = Instance.new("TextLabel")
HeistInfo.Size = UDim2.new(1, -20, 0, 80)
HeistInfo.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
HeistInfo.TextColor3 = Color3.fromRGB(150, 255, 150)
HeistInfo.Font = Enum.Font.Gotham
HeistInfo.TextSize = 15
HeistInfo.TextWrapped = true
HeistInfo.Text = "ℹ️ ลอจิกดันทองคำ (ระบบป้องกันตัวค้างเสถียร):\n1. วาร์ปเก็บของจากตู้ (Machines)\n2. โฟกัสตี Bankrupt Gamblers\n3. โฟกัสตี Golden Statue เป็นตัวสุดท้าย"
HeistInfo.Parent = PageHeist
local HCorner = Instance.new("UICorner") HCorner.CornerRadius = UDim.new(0, 8) HCorner.Parent = HeistInfo

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
            hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
            local spawner = targetIsland:FindFirstChild("Spawner", true)
            if spawner and spawner:IsA("BasePart") then
                hrp.CFrame = spawner.CFrame * CFrame.new(0, 5, 0)
            else
                hrp.CFrame = targetIsland:GetPivot() * CFrame.new(0, 20, 0)
            end
        end
    end
end)

TabMain.MouseButton1Click:Connect(function() switchTab(PageMain, TabMain) end)
TabHeist.MouseButton1Click:Connect(function() switchTab(PageHeist, TabHeist) end)
TabTeleport.MouseButton1Click:Connect(function() switchTab(PageTP, TabTeleport) end)

-- ==========================================
-- 🧠 Core Loop (แก้บัควาร์ปรัวค้าง / ขยับไม่ได้)
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

local function getHeistTarget()
    local entities = workspace:FindFirstChild("Entities")
    if not entities then return nil end
    local gamblers = {}
    local boss = nil
    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    for _, obj in ipairs(entities:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 and not Players:GetPlayerFromCharacter(obj) then
            local name = string.lower(obj.Name)
            if string.match(name, "bankrupt gamblers") then
                table.insert(gamblers, obj)
            elseif string.match(name, "golden statue") then
                boss = obj
            end
        end
    end
    
    if #gamblers > 0 and myHrp then
        local nearestGambler = nil
        local minDist = math.huge
        for _, g in ipairs(gamblers) do
            local gRoot = g:FindFirstChild("HumanoidRootPart") or g:FindFirstChild("Torso")
            if gRoot then
                local dist = (myHrp.Position - gRoot.Position).Magnitude
                if dist < minDist then minDist = dist; nearestGambler = g end
            end
        end
        if nearestGambler then return nearestGambler end
    end
    
    if boss then return boss end
    return nil
end

local function getRewardMachine()
    local raidMap = workspace:FindFirstChild("Raid Map")
    if not raidMap then return nil, nil end
    local machines = raidMap:FindFirstChild("Machines")
    if not machines then return nil, nil end

    for _, obj in ipairs(machines:GetChildren()) do
        local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt and prompt.Enabled then
            local targetPart = obj:FindFirstChildWhichIsA("BasePart") or obj.PrimaryPart
            if targetPart then return targetPart, prompt end
        end
    end
    return nil, nil
end

if getgenv().FarmLoop then getgenv().FarmLoop:Disconnect() end

getgenv().FarmLoop = RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    
    -- ล็อคสปีดแบบเรียลไทม์
    if hum and hum.Health > 0 then
        hum.WalkSpeed = Settings.WalkSpeed
    end

    if hrp then
        -- ถ้าเปิดระบบฟาร์มตัวใดตัวหนึ่ง ให้ปิดการชนเพื่อไม่ให้ติดมอน
        if Settings.GoldenHeist or Settings.AutoFarm then
            for _, part in ipairs(char:GetChildren()) do 
                if part:IsA("BasePart") then part.CanCollide = false end 
            end
        else
            -- ถ้าปิด Auto Farm ให้คืนค่าการชนเป๊ะๆ (แก้ปัญหาเดินไม่ได้หลังจากปิดสคริปต์)
            for _, part in ipairs(char:GetChildren()) do 
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.CanCollide = true end 
            end
        end

        -- โหมด 1: ดันทองคำ
        if Settings.GoldenHeist then
            local machinePart, prompt = getRewardMachine()
            if machinePart and prompt then
                hrp.CFrame = machinePart.CFrame * CFrame.new(0, 0, 3)
                if fireproximityprompt then
                    fireproximityprompt(prompt, 1, true)
                else
                    prompt:InputHoldBegin()
                    task.delay(prompt.HoldDuration + 0.1, function() prompt:InputHoldEnd() end)
                end
            else
                local target = getHeistTarget()
                if target then
                    local targetRoot = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Torso")
                    if targetRoot then
                        local backstabCFrame = targetRoot.CFrame * CFrame.new(0, 0, Settings.Distance)
                        hrp.CFrame = CFrame.lookAt(backstabCFrame.Position, targetRoot.Position)
                    end
                end
            end
        -- โหมด 2: ฟาร์มมอนทั่วไป
        elseif Settings.AutoFarm then
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
