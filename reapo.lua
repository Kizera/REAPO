local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

getgenv().ToggleUpdates = {}
getgenv().IsAttacking = false 
getgenv().IsBuffing = false 
getgenv().JustRespawned = true 

LocalPlayer.CharacterAdded:Connect(function() getgenv().JustRespawned = true end)

-- ==========================================
-- 💾 ระบบบันทึกและโหลดการตั้งค่า
-- ==========================================
local ConfigName = "PremiumRaid_Config.json"
local Settings = {
    AutoFarm = false, AutoClick = false, GoldenHeist = false, AutoBuff = true, 
    TargetMob = "None", TargetIsland = "None", Distance = 4, ScanRadius = 2500,
    EnableSpeedMode = false, SpeedMultiplier = 150, SpeedKeybind = nil,
    EnableFlyMode = false, FlySpeed = 300, FlyKeybind = nil
}

local function LoadSettings()
    if isfile and readfile and isfile(ConfigName) then
        pcall(function()
            local decoded = HttpService:JSONDecode(readfile(ConfigName))
            for k, v in pairs(decoded) do
                if type(v) == "string" and string.match(v, "^Enum%.KeyCode%.") then
                    Settings[k] = Enum.KeyCode[string.gsub(v, "Enum%.KeyCode%.", "")]
                else Settings[k] = v end
            end
        end)
    end
end
LoadSettings()

local function SaveSettings()
    if writefile then
        pcall(function()
            local toSave = {}
            for k, v in pairs(Settings) do
                if typeof(v) == "EnumItem" then toSave[k] = "Enum.KeyCode." .. v.Name else toSave[k] = v end
            end
            writefile(ConfigName, HttpService:JSONEncode(toSave))
        end)
    end
end

-- ==========================================
-- 🪙 1. Tracker Golden Chips
-- ==========================================
local TRK_Name = "GoldenChipsTracker_V18"
local pUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer.PlayerGui
if pUI:FindFirstChild(TRK_Name) then pUI[TRK_Name]:Destroy() end

local TrkGui = Instance.new("ScreenGui"); TrkGui.Name = TRK_Name; TrkGui.Parent = pUI
local TrkFrame = Instance.new("Frame"); TrkFrame.Size = UDim2.new(0, 220, 0, 45); TrkFrame.Position = UDim2.new(0, 15, 0.5, 0); TrkFrame.AnchorPoint = Vector2.new(0, 0.5); TrkFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30); TrkFrame.BorderSizePixel = 0; TrkFrame.Active = true; TrkFrame.Draggable = true; TrkFrame.Parent = TrkGui
local TrkCorner = Instance.new("UICorner"); TrkCorner.CornerRadius = UDim.new(0, 8); TrkCorner.Parent = TrkFrame
local TrkStroke = Instance.new("UIStroke"); TrkStroke.Color = Color3.fromRGB(255, 215, 0); TrkStroke.Thickness = 1.5; TrkStroke.Parent = TrkFrame
local TrkLabel = Instance.new("TextLabel"); TrkLabel.Size = UDim2.new(1, 0, 1, 0); TrkLabel.BackgroundTransparency = 1; TrkLabel.Text = "🪙 Golden Chips: Loading..."; TrkLabel.TextColor3 = Color3.fromRGB(255, 220, 50); TrkLabel.Font = Enum.Font.GothamBold; TrkLabel.TextSize = 15; TrkLabel.Parent = TrkFrame

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local stats = LocalPlayer:FindFirstChild("Stats")
            local chips = stats and stats:FindFirstChild("Golden Chips")
            if chips then TrkLabel.Text = "🪙 Golden Chips: " .. tostring(chips.Value):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "") else TrkLabel.Text = "🪙 Golden Chips: 0" end
        end)
    end
end)

-- ==========================================
-- 🎮 ระบบรับปุ่มลัด
-- ==========================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if Settings.SpeedKeybind and input.KeyCode == Settings.SpeedKeybind then
            Settings.EnableSpeedMode = not Settings.EnableSpeedMode; SaveSettings(); if getgenv().ToggleUpdates["EnableSpeedMode"] then getgenv().ToggleUpdates["EnableSpeedMode"](Settings.EnableSpeedMode) end
        elseif Settings.FlyKeybind and input.KeyCode == Settings.FlyKeybind then
            Settings.EnableFlyMode = not Settings.EnableFlyMode; SaveSettings(); if getgenv().ToggleUpdates["EnableFlyMode"] then getgenv().ToggleUpdates["EnableFlyMode"](Settings.EnableFlyMode) end
        end
    end
end)

-- ==========================================
-- 🎨 2. Main GUI 
-- ==========================================
local UI_Name = "PremiumRaidGUI_V18"
if pUI:FindFirstChild(UI_Name) then pUI[UI_Name]:Destroy() end

local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = UI_Name; ScreenGui.Parent = pUI
local MainFrame = Instance.new("Frame"); MainFrame.Size = UDim2.new(0, 750, 0, 500); MainFrame.Position = UDim2.new(0.5, -375, 0.5, -250); MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); MainFrame.BorderSizePixel = 0; MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.Parent = ScreenGui
local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0, 10); MainCorner.Parent = MainFrame

local TopBar = Instance.new("Frame"); TopBar.Size = UDim2.new(1, 0, 0, 45); TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25); TopBar.Parent = MainFrame
local TopCorner = Instance.new("UICorner"); TopCorner.CornerRadius = UDim.new(0, 10); TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel"); Title.Size = UDim2.new(0, 450, 1, 0); Title.Position = UDim2.new(0, 20, 0, 0); Title.BackgroundTransparency = 1; Title.Text = "Premium Raid Auto V18 (No Dodge + Fast Heist)"; Title.TextColor3 = Color3.fromRGB(255, 255, 255); Title.Font = Enum.Font.GothamBold; Title.TextSize = 18; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.Parent = TopBar

local MinBtn = Instance.new("TextButton"); MinBtn.Size = UDim2.new(0, 40, 0, 30); MinBtn.Position = UDim2.new(1, -95, 0, 7); MinBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50); MinBtn.Text = "-"; MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255); MinBtn.Font = Enum.Font.GothamBold; MinBtn.TextSize = 18; MinBtn.Parent = TopBar
local MinCorner = Instance.new("UICorner"); MinCorner.CornerRadius = UDim.new(0, 6); MinCorner.Parent = MinBtn

local CloseBtn = Instance.new("TextButton"); CloseBtn.Size = UDim2.new(0, 40, 0, 30); CloseBtn.Position = UDim2.new(1, -50, 0, 7); CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); CloseBtn.Text = "X"; CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255); CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 18; CloseBtn.Parent = TopBar
local CloseCorner = Instance.new("UICorner"); CloseCorner.CornerRadius = UDim.new(0, 6); CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then local fbv = hrp:FindFirstChild("FlyBV") if fbv then fbv:Destroy() end local fbg = hrp:FindFirstChild("FlyBG") if fbg then fbg:Destroy() end end
        for _, p in ipairs(char:GetChildren()) do if p:IsA("BasePart") then p.CanCollide = true end end
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = 16 hum.PlatformStand = false end
    end
    ScreenGui:Destroy()
end)

local Sidebar = Instance.new("Frame"); Sidebar.Size = UDim2.new(0, 160, 1, -45); Sidebar.Position = UDim2.new(0, 0, 0, 45); Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Sidebar.Parent = MainFrame
local function createTabButton(text, yPos)
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1, 0, 0, 45); btn.Position = UDim2.new(0, 0, 0, yPos); btn.BackgroundTransparency = 1; btn.Text = "  ◇ " .. text; btn.TextColor3 = Color3.fromRGB(150, 150, 150); btn.Font = Enum.Font.GothamBold; btn.TextSize = 16; btn.TextXAlignment = Enum.TextXAlignment.Left; btn.Parent = Sidebar; return btn
end

local TabMain = createTabButton("Main", 0); local TabHeist = createTabButton("ดันทองคำ/Raid", 45); local TabPlayer = createTabButton("Player", 90); local TabTeleport = createTabButton("Teleport", 135)
TabMain.TextColor3 = Color3.fromRGB(255, 255, 255)

local ContentArea = Instance.new("Frame"); ContentArea.Size = UDim2.new(1, -170, 1, -55); ContentArea.Position = UDim2.new(0, 165, 0, 50); ContentArea.BackgroundTransparency = 1; ContentArea.Parent = MainFrame
local function createPage()
    local page = Instance.new("ScrollingFrame"); page.Size = UDim2.new(1, 0, 1, 0); page.BackgroundTransparency = 1; page.BorderSizePixel = 0; page.ScrollBarThickness = 6; page.AutomaticCanvasSize = Enum.AutomaticSize.Y; page.Parent = ContentArea
    local list = Instance.new("UIListLayout"); list.Padding = UDim.new(0, 8); list.Parent = page; return page
end

local PageMain = createPage(); local PageHeist = createPage(); PageHeist.Visible = false; local PagePlayer = createPage(); PagePlayer.Visible = false; local PageTP = createPage(); PageTP.Visible = false
local function switchTab(activePage, activeBtn)
    PageMain.Visible = (activePage == PageMain); PageHeist.Visible = (activePage == PageHeist); PagePlayer.Visible = (activePage == PagePlayer); PageTP.Visible = (activePage == PageTP)
    TabMain.TextColor3 = Color3.fromRGB(150, 150, 150); TabHeist.TextColor3 = Color3.fromRGB(150, 150, 150); TabPlayer.TextColor3 = Color3.fromRGB(150, 150, 150); TabTeleport.TextColor3 = Color3.fromRGB(150, 150, 150)
    activeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
end

TabMain.MouseButton1Click:Connect(function() switchTab(PageMain, TabMain) end)
TabHeist.MouseButton1Click:Connect(function() switchTab(PageHeist, TabHeist) end)
TabPlayer.MouseButton1Click:Connect(function() switchTab(PagePlayer, TabPlayer) end)
TabTeleport.MouseButton1Click:Connect(function() switchTab(PageTP, TabTeleport) end)

MinBtn.MouseButton1Click:Connect(function()
    local isMin = (MinBtn.Text == "-"); Sidebar.Visible = not isMin; ContentArea.Visible = not isMin
    MainFrame.Size = isMin and UDim2.new(0, 750, 0, 45) or UDim2.new(0, 750, 0, 500); MinBtn.Text = isMin and "+" or "-"
end)

local function CreateSectionLabel(parent, text)
    local Frame = Instance.new("Frame"); Frame.Size = UDim2.new(1, -20, 0, 35); Frame.BackgroundTransparency = 1; Frame.Parent = parent
    local Label = Instance.new("TextLabel"); Label.Size = UDim2.new(1, 0, 1, 0); Label.Position = UDim2.new(0, 5, 0, 0); Label.BackgroundTransparency = 1; Label.Text = text; Label.TextColor3 = Color3.fromRGB(255, 60, 60); Label.Font = Enum.Font.GothamBold; Label.TextSize = 15; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.Parent = Frame
    local Line = Instance.new("Frame"); Line.Size = UDim2.new(1, -5, 0, 1); Line.Position = UDim2.new(0, 5, 1, -5); Line.BackgroundColor3 = Color3.fromRGB(50, 50, 50); Line.BorderSizePixel = 0; Line.Parent = Frame
end

local function CreateToggle(parent, text, flag)
    local Frame = Instance.new("Frame"); Frame.Size = UDim2.new(1, -20, 0, 50); Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35); Frame.Parent = parent; local Corner = Instance.new("UICorner"); Corner.CornerRadius = UDim.new(0, 8); Corner.Parent = Frame
    local Label = Instance.new("TextLabel"); Label.Size = UDim2.new(1, -70, 1, 0); Label.Position = UDim2.new(0, 15, 0, 0); Label.BackgroundTransparency = 1; Label.Text = text; Label.TextColor3 = Color3.fromRGB(220, 220, 220); Label.Font = Enum.Font.GothamBold; Label.TextSize = 16; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.Parent = Frame
    local CheckboxBg = Instance.new("TextButton"); CheckboxBg.Size = UDim2.new(0, 30, 0, 30); CheckboxBg.Position = UDim2.new(1, -45, 0.5, -15); CheckboxBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50); CheckboxBg.Text = ""; CheckboxBg.Parent = Frame; local CCorner = Instance.new("UICorner"); CCorner.CornerRadius = UDim.new(0, 6); CCorner.Parent = CheckboxBg
    local CheckboxFill = Instance.new("Frame"); CheckboxFill.Size = UDim2.new(1, -6, 1, -6); CheckboxFill.Position = UDim2.new(0, 3, 0, 3); CheckboxFill.BackgroundColor3 = Color3.fromRGB(255, 60, 60); CheckboxFill.Visible = Settings[flag]; CheckboxFill.Parent = CheckboxBg; local FCorner = Instance.new("UICorner"); FCorner.CornerRadius = UDim.new(0, 4); FCorner.Parent = CheckboxFill
    CheckboxBg.MouseButton1Click:Connect(function() Settings[flag] = not Settings[flag]; CheckboxFill.Visible = Settings[flag]; SaveSettings() end)
end

local function CreateToggleWithKeybind(parent, text, flag, keybindFlag)
    local Frame = Instance.new("Frame"); Frame.Size = UDim2.new(1, -20, 0, 50); Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35); Frame.Parent = parent; local Corner = Instance.new("UICorner"); Corner.CornerRadius = UDim.new(0, 8); Corner.Parent = Frame
    local Label = Instance.new("TextLabel"); Label.Size = UDim2.new(1, -130, 1, 0); Label.Position = UDim2.new(0, 15, 0, 0); Label.BackgroundTransparency = 1; Label.Text = text; Label.TextColor3 = Color3.fromRGB(220, 220, 220); Label.Font = Enum.Font.GothamBold; Label.TextSize = 16; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.Parent = Frame
    local KeyBtn = Instance.new("TextButton"); KeyBtn.Size = UDim2.new(0, 60, 0, 30); KeyBtn.Position = UDim2.new(1, -115, 0.5, -15); KeyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70); KeyBtn.Text = Settings[keybindFlag] and Settings[keybindFlag].Name or "NONE"; KeyBtn.TextColor3 = Color3.fromRGB(200, 200, 255); KeyBtn.Font = Enum.Font.GothamBold; KeyBtn.TextSize = 12; KeyBtn.Parent = Frame; local KCorner = Instance.new("UICorner"); KCorner.CornerRadius = UDim.new(0, 6); KCorner.Parent = KeyBtn
    local isBinding = false
    KeyBtn.MouseButton1Click:Connect(function() isBinding = true; KeyBtn.Text = "..." end)
    UserInputService.InputBegan:Connect(function(input)
        if isBinding and input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == Enum.KeyCode.Escape then Settings[keybindFlag] = nil; KeyBtn.Text = "NONE" else Settings[keybindFlag] = input.KeyCode; KeyBtn.Text = input.KeyCode.Name end
            isBinding = false; SaveSettings()
        end
    end)
    local CheckboxBg = Instance.new("TextButton"); CheckboxBg.Size = UDim2.new(0, 30, 0, 30); CheckboxBg.Position = UDim2.new(1, -45, 0.5, -15); CheckboxBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50); CheckboxBg.Text = ""; CheckboxBg.Parent = Frame; local CCorner = Instance.new("UICorner"); CCorner.CornerRadius = UDim.new(0, 6); CCorner.Parent = CheckboxBg
    local CheckboxFill = Instance.new("Frame"); CheckboxFill.Size = UDim2.new(1, -6, 1, -6); CheckboxFill.Position = UDim2.new(0, 3, 0, 3); CheckboxFill.BackgroundColor3 = Color3.fromRGB(255, 60, 60); CheckboxFill.Visible = Settings[flag]; CheckboxFill.Parent = CheckboxBg; local FCorner = Instance.new("UICorner"); FCorner.CornerRadius = UDim.new(0, 4); FCorner.Parent = CheckboxFill
    getgenv().ToggleUpdates[flag] = function(state) CheckboxFill.Visible = state end
    CheckboxBg.MouseButton1Click:Connect(function() Settings[flag] = not Settings[flag]; getgenv().ToggleUpdates[flag](Settings[flag]); SaveSettings() end)
end

local function CreateSlider(parent, text, flag, minVal, maxVal)
    local Frame = Instance.new("Frame"); Frame.Size = UDim2.new(1, -20, 0, 70); Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35); Frame.Parent = parent; local Corner = Instance.new("UICorner"); Corner.CornerRadius = UDim.new(0, 8); Corner.Parent = Frame
    local Label = Instance.new("TextLabel"); Label.Size = UDim2.new(1, -30, 0, 30); Label.Position = UDim2.new(0, 15, 0, 5); Label.BackgroundTransparency = 1; Label.Text = text; Label.TextColor3 = Color3.fromRGB(220, 220, 220); Label.Font = Enum.Font.GothamBold; Label.TextSize = 16; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.Parent = Frame
    local ValueLabel = Instance.new("TextLabel"); ValueLabel.Size = UDim2.new(0, 50, 0, 30); ValueLabel.Position = UDim2.new(1, -65, 0, 5); ValueLabel.BackgroundTransparency = 1; ValueLabel.Text = Settings[flag]; ValueLabel.TextColor3 = Color3.fromRGB(255, 60, 60); ValueLabel.Font = Enum.Font.GothamBold; ValueLabel.TextSize = 16; ValueLabel.TextXAlignment = Enum.TextXAlignment.Right; ValueLabel.Parent = Frame
    local SliderBg = Instance.new("Frame"); SliderBg.Size = UDim2.new(1, -30, 0, 10); SliderBg.Position = UDim2.new(0, 15, 0, 45); SliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 65); SliderBg.Parent = Frame; local SCorner = Instance.new("UICorner"); SCorner.CornerRadius = UDim.new(1, 0); SCorner.Parent = SliderBg
    local defaultPercent = (Settings[flag] - minVal) / (maxVal - minVal)
    local SliderFill = Instance.new("Frame"); SliderFill.Size = UDim2.new(defaultPercent, 0, 1, 0); SliderFill.BackgroundColor3 = Color3.fromRGB(255, 60, 60); SliderFill.Parent = SliderBg; local FCorner = Instance.new("UICorner"); FCorner.CornerRadius = UDim.new(1, 0); FCorner.Parent = SliderFill
    local SliderBtn = Instance.new("TextButton"); SliderBtn.Size = UDim2.new(1, 0, 1, 20); SliderBtn.Position = UDim2.new(0, 0, 0, -10); SliderBtn.BackgroundTransparency = 1; SliderBtn.Text = ""; SliderBtn.Parent = SliderBg
    local isSliding = false
    SliderBtn.MouseButton1Down:Connect(function() isSliding = true end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then if isSliding then isSliding = false; SaveSettings() end end end)
    UserInputService.InputChanged:Connect(function(input)
        if isSliding and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = math.clamp(UserInputService:GetMouseLocation().X - SliderBg.AbsolutePosition.X, 0, SliderBg.AbsoluteSize.X)
            local percent = relativeX / SliderBg.AbsoluteSize.X
            Settings[flag] = math.floor(minVal + ((maxVal - minVal) * percent))
            SliderFill.Size = UDim2.new(percent, 0, 1, 0); ValueLabel.Text = Settings[flag]
        end
    end)
end

local function CreateLiveDropdown(parent, text, flag, getOptionsFunc)
    local Container = Instance.new("Frame"); Container.Size = UDim2.new(1, -20, 0, 50); Container.BackgroundColor3 = Color3.fromRGB(35, 35, 35); Container.ClipsDescendants = true; Container.Parent = parent; local Corner = Instance.new("UICorner"); Corner.CornerRadius = UDim.new(0, 8); Corner.Parent = Container
    local TopFrame = Instance.new("Frame"); TopFrame.Size = UDim2.new(1, 0, 0, 50); TopFrame.BackgroundTransparency = 1; TopFrame.Parent = Container
    local Label = Instance.new("TextLabel"); Label.Size = UDim2.new(0.35, 0, 1, 0); Label.Position = UDim2.new(0, 15, 0, 0); Label.BackgroundTransparency = 1; Label.Text = text; Label.TextColor3 = Color3.fromRGB(220, 220, 220); Label.Font = Enum.Font.GothamBold; Label.TextSize = 16; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.Parent = TopFrame
    local DropBtn = Instance.new("TextButton"); DropBtn.Size = UDim2.new(0.6, 0, 0, 35); DropBtn.Position = UDim2.new(1, -15, 0.5, -17.5); DropBtn.AnchorPoint = Vector2.new(1, 0); DropBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50); DropBtn.Text = Settings[flag] .. " ▼"; DropBtn.TextColor3 = Color3.fromRGB(255, 255, 255); DropBtn.Font = Enum.Font.Gotham; DropBtn.TextSize = 14; DropBtn.TextTruncate = Enum.TextTruncate.AtEnd; DropBtn.Parent = TopFrame; local DCorner = Instance.new("UICorner"); DCorner.CornerRadius = UDim.new(0, 6); DCorner.Parent = DropBtn
    local ListFrame = Instance.new("ScrollingFrame"); ListFrame.Size = UDim2.new(1, 0, 1, -55); ListFrame.Position = UDim2.new(0, 0, 0, 55); ListFrame.BackgroundTransparency = 1; ListFrame.BorderSizePixel = 0; ListFrame.ScrollBarThickness = 5; ListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y; ListFrame.Parent = Container
    local ListLayout = Instance.new("UIListLayout"); ListLayout.Padding = UDim.new(0, 4); ListLayout.Parent = ListFrame
    local isOpen = false

    DropBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            for _, child in ipairs(ListFrame:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
            local options = getOptionsFunc()
            for _, opt in ipairs(options) do
                local Btn = Instance.new("TextButton"); Btn.Size = UDim2.new(1, -20, 0, 35); Btn.Position = UDim2.new(0, 10, 0, 0); Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45); Btn.Text = "  " .. opt; Btn.TextColor3 = Color3.fromRGB(200, 200, 200); Btn.Font = Enum.Font.Gotham; Btn.TextSize = 14; Btn.TextXAlignment = Enum.TextXAlignment.Left; Btn.Parent = ListFrame; local BCorner = Instance.new("UICorner"); BCorner.CornerRadius = UDim.new(0, 6); BCorner.Parent = Btn
                Btn.MouseButton1Click:Connect(function() Settings[flag] = opt; DropBtn.Text = opt .. " ▼"; isOpen = false; Container.Size = UDim2.new(1, -20, 0, 50); SaveSettings() end)
            end
            local expandedHeight = 50 + math.min(#options * 39, 220); Container.Size = UDim2.new(1, -20, 0, expandedHeight)
        else Container.Size = UDim2.new(1, -20, 0, 50) end
    end)
end

local function CreateButton(parent, text, callback)
    local Btn = Instance.new("TextButton"); Btn.Size = UDim2.new(1, -20, 0, 50); Btn.BackgroundColor3 = Color3.fromRGB(50, 100, 200); Btn.Text = text; Btn.TextColor3 = Color3.fromRGB(255, 255, 255); Btn.Font = Enum.Font.GothamBold; Btn.TextSize = 16; Btn.Parent = parent; local Corner = Instance.new("UICorner"); Corner.CornerRadius = UDim.new(0, 8); Corner.Parent = Btn
    Btn.MouseButton1Click:Connect(callback)
end

-- ==========================================
-- 📝 หน้าต่าง UI - จัดวาง Layout
-- ==========================================
CreateToggle(PageMain, "Auto Farm (ทั่วไป)", "AutoFarm")
CreateToggle(PageMain, "Auto Click (MB1)", "AutoClick")
CreateSlider(PageMain, "Warp Distance", "Distance", 0, 15)
CreateSlider(PageMain, "Scan Radius (โหมดเกาะ)", "ScanRadius", 50, 5000)

CreateLiveDropdown(PageMain, "Target Monster", "TargetMob", function()
    local mobs = {"All (ตีทุกตัวใกล้สุด)"}
    local found = {}
    local entities = workspace:FindFirstChild("Entities")
    if entities then
        for _, obj in ipairs(entities:GetDescendants()) do
            if obj:IsA("Model") and obj ~= LocalPlayer.Character then
                local hum = obj:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 and not Players:GetPlayerFromCharacter(obj) then
                    local cleanName = string.gsub(obj.Name, "%d+$", ""); cleanName = cleanName:match("^%s*(.-)%s*$")
                    if cleanName ~= "" and not found[cleanName] then found[cleanName] = true; table.insert(mobs, cleanName) end
                end
            end
        end
    end
    return mobs
end)

CreateSectionLabel(PagePlayer, "Buff & Recovery")
CreateToggle(PagePlayer, "🔥 Auto Buff & Smart Haki", "AutoBuff")

CreateSectionLabel(PagePlayer, "Speed Controls")
CreateToggleWithKeybind(PagePlayer, "Enable Speed Mode", "EnableSpeedMode", "SpeedKeybind")
CreateSlider(PagePlayer, "Speed Multiplier", "SpeedMultiplier", 16, 300)

CreateSectionLabel(PagePlayer, "Fly Controls")
CreateToggleWithKeybind(PagePlayer, "Enable Fly Mode", "EnableFlyMode", "FlyKeybind")
CreateSlider(PagePlayer, "Fly Speed", "FlySpeed", 16, 1000)

CreateSectionLabel(PageHeist, "Raid Modes")
CreateToggle(PageHeist, "ดันทองคำ (Golden Heist AI)", "GoldenHeist")
local HeistInfo = Instance.new("TextLabel"); HeistInfo.Size = UDim2.new(1, -20, 0, 80); HeistInfo.BackgroundColor3 = Color3.fromRGB(30, 30, 35); HeistInfo.TextColor3 = Color3.fromRGB(150, 255, 150); HeistInfo.Font = Enum.Font.Gotham; HeistInfo.TextSize = 14; HeistInfo.TextWrapped = true; HeistInfo.Text = "ℹ️ ลอจิกดันทองคำ/Raid (ลบระบบหลบทิ้ง):\n1. โฟกัสตี Bankrupt Gamblers\n2. สับบอส (Golden Statue) ตัวสุดท้าย"; HeistInfo.Parent = PageHeist; local HCorner = Instance.new("UICorner"); HCorner.CornerRadius = UDim.new(0, 8); HCorner.Parent = HeistInfo

CreateLiveDropdown(PageTP, "Select Island", "TargetIsland", function()
    local isls = {"None"}
    local map = workspace:FindFirstChild("Map"); local islandsFolder = map and map:FindFirstChild("Islands")
    if islandsFolder then
        for i, island in ipairs(islandsFolder:GetChildren()) do
            local name = island.Name; if name == "" or name == " " then name = "Island " .. tostring(i) end
            table.insert(isls, name)
        end
    end
    return isls
end)
CreateButton(PageTP, "🚀 Teleport to Island", function()
    local map = workspace:FindFirstChild("Map"); local islandsFolder = map and map:FindFirstChild("Islands")
    if not islandsFolder or Settings.TargetIsland == "None" then return end
    local targetIsland
    for i, island in ipairs(islandsFolder:GetChildren()) do
        local name = island.Name; if name == "" or name == " " then name = "Island " .. tostring(i) end
        if name == Settings.TargetIsland then targetIsland = island; break end
    end
    if targetIsland then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
            local spawner = targetIsland:FindFirstChild("Spawner", true)
            if spawner and spawner:IsA("BasePart") then hrp.CFrame = spawner.CFrame * CFrame.new(0, 5, 0) else hrp.CFrame = targetIsland:GetPivot() * CFrame.new(0, 20, 0) end
        end
    end
end)

-- ==========================================
-- 🛡️ ระบบ AUTO BUFF & SMART HAKI
-- ==========================================
task.spawn(function()
    while task.wait(1) do
        if Settings.AutoBuff then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if char and hum and hum.Health > 0 then
                local myName = LocalPlayer.Name
                local entity = workspace:FindFirstChild("Entities") and (workspace.Entities:FindFirstChild(myName) or workspace.Entities:FindFirstChild("Miyuume"))
                if entity then
                    local boosts = entity:FindFirstChild("Boosts")
                    local b1 = entity:FindFirstChild("Godly Awakening")
                    local b2 = entity:FindFirstChild("SubZero")
                    local b3 = entity:FindFirstChild("BerserkArmorMode")
                    local b4 = boosts and boosts:FindFirstChild("SlimeMode")
                    
                    if not (b1 and b2 and b3 and b4) then
                        getgenv().IsBuffing = true 
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        if hrp then hrp.Velocity = Vector3.new(0,0,0) end
                        local function cast(obj, wName, keyStr)
                            if not obj then
                                local tool = LocalPlayer.Backpack:FindFirstChild(wName) or char:FindFirstChild(wName)
                                if tool then
                                    hum:EquipTool(tool); task.wait(0.6)
                                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[keyStr], false, game); task.wait(0.1); VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[keyStr], false, game); task.wait(1.5)
                                end
                            end
                        end
                        cast(b1, "God of Stands", "U")
                        cast(b2, "Frost Bazooka", "F")
                        cast(b3, "Dragon Slayer", "U")
                        cast(b4, "Reincarnated Slime", "U")
                        
                        local mainWep = LocalPlayer.Backpack:FindFirstChild("God of Stands") or char:FindFirstChild("God of Stands")
                        if mainWep then hum:EquipTool(mainWep); task.wait(0.5) end
                        getgenv().IsBuffing = false
                    end
                    
                    if getgenv().JustRespawned and not getgenv().IsBuffing then
                        getgenv().JustRespawned = false
                        task.wait(0.5); VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.J, false, game); task.wait(0.1); VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.J, false, game)
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- 🧠 Core Loop & AI Logic (ลบ Auto Dodge ทิ้งแล้ว!)
-- ==========================================
local function getRaidHeistTarget()
    local entities = workspace:FindFirstChild("Entities"); if not entities then return nil end
    local gamblers, boss = {}, nil
    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    for _, obj in ipairs(entities:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 and not Players:GetPlayerFromCharacter(obj) then
            local name = string.lower(obj.Name)
            if string.match(name, "bankrupt gamblers") then table.insert(gamblers, obj)
            elseif string.match(name, "golden statue") then boss = obj end
        end
    end
    
    if #gamblers > 0 and myHrp then
        local nearestGambler, minDist = nil, math.huge
        for _, g in ipairs(gamblers) do
            local gRoot = g:FindFirstChild("HumanoidRootPart") or g:FindFirstChild("Torso") or g.PrimaryPart
            if gRoot then local dist = (myHrp.Position - gRoot.Position).Magnitude if dist < minDist then minDist = dist; nearestGambler = g end end
        end
        if nearestGambler then return nearestGambler end
    end
    return boss
end

local function getLiveScannedMonster()
    local nearest, minDist = nil, math.huge
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local entities = workspace:FindFirstChild("Entities"); if not entities then return nil end
    local inRaid = workspace:FindFirstChild("Raid Map") ~= nil

    for _, obj in ipairs(entities:GetChildren()) do
        if obj:IsA("Model") and obj ~= LocalPlayer.Character then
            local hum = obj:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 and not Players:GetPlayerFromCharacter(obj) then
                local mobRoot = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj.PrimaryPart
                if mobRoot then
                    local dist = (hrp.Position - mobRoot.Position).Magnitude
                    if inRaid or dist <= Settings.ScanRadius then
                        local cleanName = string.gsub(obj.Name, "%d+$", ""); cleanName = cleanName:match("^%s*(.-)%s*$")
                        local isMatch = false
                        if Settings.TargetMob == "All (ตีทุกตัวใกล้สุด)" then isMatch = true 
                        elseif string.match(string.lower(cleanName), string.lower(Settings.TargetMob)) then isMatch = true end
                        if isMatch and dist < minDist then minDist = dist; nearest = obj end
                    end
                end
            end
        end
    end
    return nearest
end

if getgenv().FarmLoop then getgenv().FarmLoop:Disconnect() end
getgenv().FarmLoop = RunService.Heartbeat:Connect(function(deltaTime)
    if getgenv().IsBuffing then return end
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    local cam = workspace.CurrentCamera
    
    getgenv().IsAttacking = false 

    if hrp and hum and hum.Health > 0 then
        if Settings.EnableFlyMode then
            local flyBV = hrp:FindFirstChild("FlyBV"); local flyBG = hrp:FindFirstChild("FlyBG")
            if not flyBV then flyBV = Instance.new("BodyVelocity"); flyBV.Name = "FlyBV"; flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge); flyBV.Parent = hrp end
            if not flyBG then flyBG = Instance.new("BodyGyro"); flyBG.Name = "FlyBG"; flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge); flyBG.P = 10000; flyBG.Parent = hrp end
            hum.PlatformStand = true; flyBG.CFrame = cam.CFrame
            local dir = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
            if dir.Magnitude == 0 and hum.MoveDirection.Magnitude > 0 then dir = cam.CFrame:VectorToWorldSpace(cam.CFrame:VectorToObjectSpace(hum.MoveDirection)) end
            if dir.Magnitude > 0 then flyBV.Velocity = dir.Unit * Settings.FlySpeed else flyBV.Velocity = Vector3.new(0, 0, 0) end
        else
            local flyBV = hrp:FindFirstChild("FlyBV"); local flyBG = hrp:FindFirstChild("FlyBG")
            if flyBV then flyBV:Destroy() end; if flyBG then flyBG:Destroy() end
            if hum.PlatformStand then hum.PlatformStand = false end
            
            if Settings.EnableSpeedMode then
                hum.WalkSpeed = 16 
                if hum.MoveDirection.Magnitude > 0 then hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (Settings.SpeedMultiplier * deltaTime)) end
            else hum.WalkSpeed = 16 end
        end

        if Settings.GoldenHeist or Settings.AutoFarm then
            for _, part in ipairs(char:GetChildren()) do if part:IsA("BasePart") then part.CanCollide = false end end
        else
            for _, part in ipairs(char:GetChildren()) do if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.CanCollide = true end end
        end

        if Settings.GoldenHeist then
            local target = getRaidHeistTarget()
            if target then
                local targetRoot = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Torso") or target.PrimaryPart
                if targetRoot then 
                    hrp.CFrame = CFrame.lookAt((targetRoot.CFrame * CFrame.new(0, 0, Settings.Distance)).Position, targetRoot.Position) 
                    getgenv().IsAttacking = true
                end
            end
        elseif Settings.AutoFarm then
            local target = getLiveScannedMonster()
            if target then
                local tRoot = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Torso") or target.PrimaryPart
                if tRoot then 
                    hrp.CFrame = CFrame.lookAt((tRoot.CFrame * CFrame.new(0, 0, Settings.Distance)).Position, tRoot.Position) 
                    getgenv().IsAttacking = true
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if Settings.AutoClick and getgenv().IsAttacking and not getgenv().IsBuffing then
            pcall(function()
                local cam = workspace.CurrentCamera
                local midX = cam.ViewportSize.X / 2
                local midY = cam.ViewportSize.Y / 2
                VirtualInputManager:SendMouseButtonEvent(midX, midY, 0, true, game, 1)
                task.wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(midX, midY, 0, false, game, 1)
            end)
        end
    end
end)
