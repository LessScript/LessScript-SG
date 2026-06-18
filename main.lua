-- LessScript v0.6.10 - Mobile Only, No Mouse/Keyboard, Unicode Fixed
-- Aimbot head lock + AutoFire only when 100% hit chance (no obstacles), No Smoothness
-- All combat functions only target enemies (opposite team), ESP only shows enemies
-- Info menu inside main GUI, infinite ammo, improved functions

if getgenv().LessScriptLoaded then return end
getgenv().LessScriptLoaded = true

local LessScript = {
    Version = "v0.6.10",
    Settings = {
        Fly = {Enabled = false, Speed = 50},
        Aimbot = {Enabled = false, FOV = 120, AimPart = "Head", Smoothness = 0.15, ShowFOV = true, AutoFire = false},
        SilentAim = {Enabled = false, FOV = 120, AimPart = "Head", AutoFire = false},
        AimView = {Enabled = false, FOV = 80},
        ThirdPerson = {Enabled = false, Distance = 10},
        ESP = {Enabled = false, Boxes = true, Names = true, Health = true, Distance = true},
        TriggerBot = {Enabled = false, Delay = 0.05},
        SpeedHack = {Enabled = false, Speed = 50},
        NoClip = {Enabled = false},
        InfiniteJump = {Enabled = false},
        SpinBot = {Enabled = false, Speed = 10},
        Reach = {Enabled = false, Distance = 15},
        AntiAfk = {Enabled = false},
        AutoFarm = {Enabled = false, Range = 50},
        ChatSpy = {Enabled = false},
        Crosshair = {Enabled = false, Size = 20},
        AutoDodge = {Enabled = false, Distance = 20},
        Teleport = {Enabled = false},
        Nuke = {Enabled = false, Range = 30},
        InfiniteAmmo = {Enabled = false},
        NoRecoil = {Enabled = false},
        RapidFire = {Enabled = false, Speed = 0.05},
        BulletPrediction = {Enabled = false},
        AutoReload = {Enabled = false},
        HitboxExpander = {Enabled = false, Size = 2}
    },
    Connections = {},
    ESPObjects = {},
    FOVCircle = nil,
    CrosshairObj = nil,
    AimViewCircle = nil
}

if not game:IsLoaded() then game.Loaded:Wait() end

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait() end
if not Camera then repeat Camera = Workspace.CurrentCamera wait() until Camera end

-- CLEAN OLD INSTANCES
for _, parent in pairs({
    pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui"),
    pcall(function() return LocalPlayer:FindFirstChildOfClass("PlayerGui") end) and LocalPlayer:FindFirstChildOfClass("PlayerGui")
}) do
    if parent then for _, obj in pairs(parent:GetChildren()) do
        if obj.Name:find("LessScript") then pcall(function() obj:Destroy() end) end
    end end
end

local function injectGui(gui)
    local s = pcall(function() gui.Parent = game:GetService("CoreGui") end)
    if not s then
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if pg then gui.Parent = pg else pcall(function() gui.Parent = LocalPlayer:WaitForChild("PlayerGui", 10) end) end
    end
end

-- ===== LOADING SCREEN =====
local Loader = Instance.new("ScreenGui"); Loader.Name = "LessScript_Loader"; Loader.ResetOnSpawn = false
local LoadFrame = Instance.new("Frame"); LoadFrame.Size = UDim2.new(0, 260, 0, 100); LoadFrame.Position = UDim2.new(0.5, -130, 0.5, -50); LoadFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15); LoadFrame.BorderSizePixel = 0; LoadFrame.Parent = Loader
Instance.new("UICorner", LoadFrame).CornerRadius = UDim.new(0, 10)
local lds = Instance.new("UIStroke"); lds.Color = Color3.fromRGB(255, 60, 60); lds.Thickness = 2; lds.Parent = LoadFrame
local ldt = Instance.new("TextLabel"); ldt.Size = UDim2.new(1, -20, 0, 28); ldt.Position = UDim2.new(0, 10, 0, 12); ldt.BackgroundTransparency = 1; ldt.Text = "LessScript " .. LessScript.Version; ldt.TextColor3 = Color3.fromRGB(255, 255, 255); ldt.TextSize = 20; ldt.Font = Enum.Font.GothamBlack; ldt.Parent = LoadFrame
local ldst = Instance.new("TextLabel"); ldst.Size = UDim2.new(1, -20, 0, 16); ldst.Position = UDim2.new(0, 10, 0, 42); ldst.BackgroundTransparency = 1; ldst.Text = "Initializing..."; ldst.TextColor3 = Color3.fromRGB(180, 180, 180); ldst.TextSize = 11; ldst.Font = Enum.Font.Gotham; ldst.Parent = LoadFrame
local ldbg = Instance.new("Frame"); ldbg.Size = UDim2.new(1, -20, 0, 5); ldbg.Position = UDim2.new(0, 10, 0, 65); ldbg.BackgroundColor3 = Color3.fromRGB(40, 40, 40); ldbg.BorderSizePixel = 0; ldbg.Parent = LoadFrame; Instance.new("UICorner", ldbg).CornerRadius = UDim.new(1, 0)
local ldb = Instance.new("Frame"); ldb.Size = UDim2.new(0, 0, 1, 0); ldb.BackgroundColor3 = Color3.fromRGB(255, 60, 60); ldb.BorderSizePixel = 0; ldb.Parent = ldbg; Instance.new("UICorner", ldb).CornerRadius = UDim.new(1, 0)
injectGui(Loader)

spawn(function()
    for i = 1, 100 do
        ldb.Size = UDim2.new(i/100, 0, 1, 0)
        if i == 25 then ldst.Text = "Loading modules..."
        elseif i == 50 then ldst.Text = "Building interface..."
        elseif i == 75 then ldst.Text = "Almost ready..."
        elseif i == 95 then ldst.Text = "Complete!" end
        wait(0.01)
    end
    wait(0.3)
    LoadFrame:TweenPosition(UDim2.new(0.5, -130, -0.5, -50), "In", "Back", 0.4, true)
    wait(0.4)
    Loader:Destroy()
end)

wait(1.6)

-- ===== WATERMARK =====
local Watermark = Instance.new("ScreenGui"); Watermark.Name = "LessScript_Watermark"; Watermark.ResetOnSpawn = false; Watermark.DisplayOrder = 998

local WatermarkFrame = Instance.new("Frame")
WatermarkFrame.Name = "WatermarkFrame"
WatermarkFrame.Size = UDim2.new(0, 48, 0, 48)
WatermarkFrame.Position = UDim2.new(0, 15, 0, 15)
WatermarkFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
WatermarkFrame.BorderSizePixel = 0
WatermarkFrame.Active = true
WatermarkFrame.Draggable = true
WatermarkFrame.Parent = Watermark

local WatermarkCorner = Instance.new("UICorner")
WatermarkCorner.CornerRadius = UDim.new(0, 12)
WatermarkCorner.Parent = WatermarkFrame

local WatermarkStroke = Instance.new("UIStroke")
WatermarkStroke.Color = Color3.fromRGB(255, 60, 60)
WatermarkStroke.Thickness = 2
WatermarkStroke.Parent = WatermarkFrame

local WatermarkGradient = Instance.new("UIGradient")
WatermarkGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 60, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 120, 120))
})
WatermarkGradient.Rotation = 45
WatermarkGradient.Parent = WatermarkStroke

local WatermarkLabel = Instance.new("TextLabel")
WatermarkLabel.Size = UDim2.new(1, 0, 1, 0)
WatermarkLabel.BackgroundTransparency = 1
WatermarkLabel.Text = "LS"
WatermarkLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
WatermarkLabel.TextSize = 22
WatermarkLabel.Font = Enum.Font.GothamBlack
WatermarkLabel.Parent = WatermarkFrame

local WatermarkVersion = Instance.new("TextLabel")
WatermarkVersion.Size = UDim2.new(1, 0, 0, 12)
WatermarkVersion.Position = UDim2.new(0, 0, 1, -12)
WatermarkVersion.BackgroundTransparency = 1
WatermarkVersion.Text = "v0.6.10"
WatermarkVersion.TextColor3 = Color3.fromRGB(200, 200, 200)
WatermarkVersion.TextSize = 8
WatermarkVersion.Font = Enum.Font.Gotham
WatermarkVersion.Parent = WatermarkFrame

injectGui(Watermark)

-- ===== MAIN GUI =====
local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "LessScript_Main"; ScreenGui.ResetOnSpawn = false; ScreenGui.DisplayOrder = 1000

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 380)
MainFrame.Position = UDim2.new(0, 10, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local uis = Instance.new("UIStroke"); uis.Color = Color3.fromRGB(255, 60, 60); uis.Thickness = 1.5; uis.Parent = MainFrame

-- Resize handle
local ResizeHandle = Instance.new("Frame"); ResizeHandle.Size = UDim2.new(0, 18, 0, 18); ResizeHandle.Position = UDim2.new(1, -9, 1, -9); ResizeHandle.BackgroundColor3 = Color3.fromRGB(255, 60, 60); ResizeHandle.BorderSizePixel = 0; ResizeHandle.ZIndex = 10; ResizeHandle.Parent = MainFrame; Instance.new("UICorner", ResizeHandle).CornerRadius = UDim.new(0, 5)
local ResizeLabel = Instance.new("TextLabel"); ResizeLabel.Size = UDim2.new(1, 0, 1, 0); ResizeLabel.BackgroundTransparency = 1; ResizeLabel.Text = "o"; ResizeLabel.TextColor3 = Color3.fromRGB(255, 255, 255); ResizeLabel.TextSize = 10; ResizeLabel.Font = Enum.Font.GothamBold; ResizeLabel.Parent = ResizeHandle

local resizing = false; local startSize, startPos, startTouchPos
ResizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        resizing = true; startSize = MainFrame.AbsoluteSize; startPos = MainFrame.AbsolutePosition; startTouchPos = input.Position
    end
end)
UserInputService.TouchMoved:Connect(function(input)
    if resizing then
        local delta = input.Position - startTouchPos
        MainFrame.Size = UDim2.new(0, math.clamp(startSize.X + delta.X, 250, 500), 0, math.clamp(startSize.Y + delta.Y, 350, 700))
    end
end)
UserInputService.TouchEnded:Connect(function(input)
    resizing = false
end)

-- Title Bar
local TitleBar = Instance.new("Frame"); TitleBar.Size = UDim2.new(1, 0, 0, 30); TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25); TitleBar.BorderSizePixel = 0; TitleBar.Parent = MainFrame; Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 8)
local TitleText = Instance.new("TextLabel"); TitleText.Size = UDim2.new(1, -45, 1, 0); TitleText.Position = UDim2.new(0, 12, 0, 0); TitleText.BackgroundTransparency = 1; TitleText.Text = "LessScript " .. LessScript.Version; TitleText.TextColor3 = Color3.fromRGB(255, 255, 255); TitleText.TextSize = 13; TitleText.Font = Enum.Font.GothamBold; TitleText.TextXAlignment = Enum.TextXAlignment.Left; TitleText.Parent = TitleBar
local CloseButton = Instance.new("TextButton"); CloseButton.Size = UDim2.new(0, 24, 0, 24); CloseButton.Position = UDim2.new(1, -28, 0, 3); CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60); CloseButton.Text = "X"; CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255); CloseButton.TextSize = 12; CloseButton.Font = Enum.Font.GothamBold; CloseButton.BorderSizePixel = 0; CloseButton.AutoButtonColor = false; CloseButton.Parent = TitleBar; Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 5)
CloseButton.Activated:Connect(function() MainFrame.Visible = false end)

-- Tabs
local TabButtons = {}; local TabContents = {}
local TabRow = Instance.new("Frame"); TabRow.Size = UDim2.new(1, -8, 0, 26); TabRow.Position = UDim2.new(0, 4, 0, 34); TabRow.BackgroundColor3 = Color3.fromRGB(22, 22, 22); TabRow.BorderSizePixel = 0; TabRow.Parent = MainFrame; Instance.new("UICorner", TabRow).CornerRadius = UDim.new(0, 5)
local ContentArea = Instance.new("Frame"); ContentArea.Size = UDim2.new(1, -8, 1, -64); ContentArea.Position = UDim2.new(0, 4, 0, 64); ContentArea.BackgroundColor3 = Color3.fromRGB(20, 20, 20); ContentArea.BorderSizePixel = 0; ContentArea.ClipsDescendants = true; ContentArea.Parent = MainFrame

local tabNames = {"Info", "Combat", "Move", "Visuals", "Misc"}
local tabIcons = {"[i]", "[>]", "[>>]", "[o]", "[*]"}

local function SwitchTab(tabName)
    for name, content in pairs(TabContents) do content.Visible = (name == tabName) end
    for name, button in pairs(TabButtons) do
        button.BackgroundColor3 = (name == tabName) and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(30, 30, 30)
        button.TextColor3 = (name == tabName) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
    end
end

for i, tabName in ipairs(tabNames) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0.2, -2, 1, -2)
    tabBtn.Position = UDim2.new((i-1)*0.2, 1, 0, 1)
    tabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    tabBtn.Text = tabIcons[i]
    tabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    tabBtn.TextSize = 12
    tabBtn.Font = Enum.Font.Gotham
    tabBtn.BorderSizePixel = 0
    tabBtn.AutoButtonColor = false
    tabBtn.Parent = TabRow
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 4)
    
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -4, 1, -4)
    content.Position = UDim2.new(0, 2, 0, 2)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 2
    content.ScrollBarImageColor3 = Color3.fromRGB(255, 60, 60)
    content.CanvasSize = UDim2.new(0, 0, 4, 0)
    content.Visible = (i == 1)
    content.ScrollingEnabled = true
    content.ElasticBehavior = Enum.ElasticBehavior.Never
    content.Parent = ContentArea
    
    local list = Instance.new("UIListLayout"); list.Padding = UDim.new(0, 4); list.Parent = content
    
    TabButtons[tabName] = tabBtn; TabContents[tabName] = content
    tabBtn.Activated:Connect(function() SwitchTab(tabName) end)
end
if TabButtons["Info"] then TabButtons["Info"].BackgroundColor3 = Color3.fromRGB(255, 60, 60); TabButtons["Info"].TextColor3 = Color3.fromRGB(255, 255, 255) end

-- ===== INFO TAB CONTENT =====
local infoContent = TabContents["Info"]

-- Script Title
local infoTitle = Instance.new("TextLabel")
infoTitle.Size = UDim2.new(1, -8, 0, 36)
infoTitle.Position = UDim2.new(0, 4, 0, 10)
infoTitle.BackgroundTransparency = 1
infoTitle.Text = "LessScript"
infoTitle.TextColor3 = Color3.fromRGB(255, 60, 60)
infoTitle.TextSize = 26
infoTitle.Font = Enum.Font.GothamBlack
infoTitle.TextXAlignment = Enum.TextXAlignment.Center
infoTitle.Parent = infoContent

-- Info lines
local infoLines = {
    "Telegram channel: @LessScriptRB",
    "Version: " .. LessScript.Version,
    "Best Script for Roblox games",
    "Made With Love"
}

for i, line in ipairs(infoLines) do
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, -8, 0, 22)
    infoLabel.Position = UDim2.new(0, 4, 0, 55 + (i - 1) * 26)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = line
    infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    infoLabel.TextSize = 12
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextXAlignment = Enum.TextXAlignment.Center
    infoLabel.Parent = infoContent
end

-- Separator
local separator = Instance.new("Frame")
separator.Size = UDim2.new(0.8, 0, 0, 1)
separator.Position = UDim2.new(0.1, 0, 0, 160)
separator.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
separator.BorderSizePixel = 0
separator.Parent = infoContent

-- Features count
local featuresLabel = Instance.new("TextLabel")
featuresLabel.Size = UDim2.new(1, -8, 0, 20)
featuresLabel.Position = UDim2.new(0, 4, 0, 170)
featuresLabel.BackgroundTransparency = 1
featuresLabel.Text = "Features: Aimbot, ESP, Fly, NoClip,"
featuresLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
featuresLabel.TextSize = 10
featuresLabel.Font = Enum.Font.Gotham
featuresLabel.TextXAlignment = Enum.TextXAlignment.Center
featuresLabel.Parent = infoContent

local featuresLabel2 = Instance.new("TextLabel")
featuresLabel2.Size = UDim2.new(1, -8, 0, 20)
featuresLabel2.Position = UDim2.new(0, 4, 0, 188)
featuresLabel2.BackgroundTransparency = 1
featuresLabel2.Text = "Infinite Ammo, No Recoil, Rapid Fire,"
featuresLabel2.TextColor3 = Color3.fromRGB(180, 180, 180)
featuresLabel2.TextSize = 10
featuresLabel2.Font = Enum.Font.Gotham
featuresLabel2.TextXAlignment = Enum.TextXAlignment.Center
featuresLabel2.Parent = infoContent

local featuresLabel3 = Instance.new("TextLabel")
featuresLabel3.Size = UDim2.new(1, -8, 0, 20)
featuresLabel3.Position = UDim2.new(0, 4, 0, 206)
featuresLabel3.BackgroundTransparency = 1
featuresLabel3.Text = "Silent Aim, TriggerBot, Hitbox Expander"
featuresLabel3.TextColor3 = Color3.fromRGB(180, 180, 180)
featuresLabel3.TextSize = 10
featuresLabel3.Font = Enum.Font.Gotham
featuresLabel3.TextXAlignment = Enum.TextXAlignment.Center
featuresLabel3.Parent = infoContent

local featuresLabel4 = Instance.new("TextLabel")
featuresLabel4.Size = UDim2.new(1, -8, 0, 20)
featuresLabel4.Position = UDim2.new(0, 4, 0, 224)
featuresLabel4.BackgroundTransparency = 1
featuresLabel4.Text = "and many more..."
featuresLabel4.TextColor3 = Color3.fromRGB(255, 100, 100)
featuresLabel4.TextSize = 10
featuresLabel4.Font = Enum.Font.GothamBold
featuresLabel4.TextXAlignment = Enum.TextXAlignment.Center
featuresLabel4.Parent = infoContent

-- Helpers
local function CreateSection(parent, name)
    local sec = Instance.new("Frame"); sec.Size = UDim2.new(1, -4, 0, 22); sec.BackgroundColor3 = Color3.fromRGB(28, 28, 28); sec.BorderSizePixel = 0; sec.Parent = parent; Instance.new("UICorner", sec).CornerRadius = UDim.new(0, 4)
    local line = Instance.new("Frame"); line.Size = UDim2.new(0, 2, 1, -6); line.Position = UDim2.new(0, 5, 0, 3); line.BackgroundColor3 = Color3.fromRGB(255, 60, 60); line.BorderSizePixel = 0; line.Parent = sec; Instance.new("UICorner", line).CornerRadius = UDim.new(1, 0)
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, -14, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0); lbl.BackgroundTransparency = 1; lbl.Text = name; lbl.TextColor3 = Color3.fromRGB(255, 255, 255); lbl.TextSize = 10; lbl.Font = Enum.Font.GothamBold; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = sec
end

local function CreateToggle(parent, settings, name, callback)
    local frm = Instance.new("Frame"); frm.Size = UDim2.new(1, -4, 0, 28); frm.BackgroundColor3 = Color3.fromRGB(24, 24, 24); frm.BorderSizePixel = 0; frm.Parent = parent; Instance.new("UICorner", frm).CornerRadius = UDim.new(0, 4)
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(0.55, 0, 1, 0); lbl.Position = UDim2.new(0, 8, 0, 0); lbl.BackgroundTransparency = 1; lbl.Text = name; lbl.TextColor3 = Color3.fromRGB(255, 255, 255); lbl.TextSize = 10; lbl.Font = Enum.Font.Gotham; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = frm
    local bg = Instance.new("Frame"); bg.Size = UDim2.new(0, 28, 0, 15); bg.Position = UDim2.new(1, -34, 0.5, -7); bg.BackgroundColor3 = Color3.fromRGB(50, 50, 50); bg.BorderSizePixel = 0; bg.Parent = frm; Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
    local dot = Instance.new("Frame"); dot.Size = UDim2.new(0, 11, 0, 11); dot.Position = UDim2.new(0, 2, 0.5, -5); dot.BackgroundColor3 = Color3.fromRGB(200, 200, 200); dot.BorderSizePixel = 0; dot.Parent = bg; Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    local enabled = settings.Enabled or false
    local function update()
        if enabled then bg.BackgroundColor3 = Color3.fromRGB(255, 60, 60); TweenService:Create(dot, TweenInfo.new(0.12), {Position = UDim2.new(0, 15, 0.5, -5)}):Play()
        else bg.BackgroundColor3 = Color3.fromRGB(50, 50, 50); TweenService:Create(dot, TweenInfo.new(0.12), {Position = UDim2.new(0, 2, 0.5, -5)}):Play() end
    end
    update()
    bg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            enabled = not enabled; settings.Enabled = enabled; update(); if callback then callback(enabled) end
        end
    end)
    dot.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            enabled = not enabled; settings.Enabled = enabled; update(); if callback then callback(enabled) end
        end
    end)
end

local function CreateSlider(parent, settings, name, min, max, default, callback)
    settings.Value = default
    local frm = Instance.new("Frame"); frm.Size = UDim2.new(1, -4, 0, 44); frm.BackgroundColor3 = Color3.fromRGB(24, 24, 24); frm.BorderSizePixel = 0; frm.Parent = parent; Instance.new("UICorner", frm).CornerRadius = UDim.new(0, 4)
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, -12, 0, 16); lbl.Position = UDim2.new(0, 6, 0, 2); lbl.BackgroundTransparency = 1; lbl.Text = name .. ": " .. default; lbl.TextColor3 = Color3.fromRGB(255, 255, 255); lbl.TextSize = 10; lbl.Font = Enum.Font.Gotham; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = frm
    local sbg = Instance.new("Frame"); sbg.Size = UDim2.new(1, -12, 0, 5); sbg.Position = UDim2.new(0, 6, 0, 24); sbg.BackgroundColor3 = Color3.fromRGB(50, 50, 50); sbg.BorderSizePixel = 0; sbg.Parent = frm; Instance.new("UICorner", sbg).CornerRadius = UDim.new(1, 0)
    local fill = Instance.new("Frame"); fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(255, 60, 60); fill.BorderSizePixel = 0; fill.Parent = sbg; Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    local dragging = false
    local function updateSlider(input)
        local px = input.Position.X; local sp = sbg.AbsolutePosition; local ss = sbg.AbsoluteSize
        local rx = math.clamp(px - sp.X, 0, ss.X); local pct = rx / ss.X; local val = math.floor(min + (max-min)*pct)
        settings.Value = val; fill.Size = UDim2.new(pct, 0, 1, 0); lbl.Text = name .. ": " .. val
        if callback then callback(val) end
    end
    sbg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then dragging = true; updateSlider(input) end
    end)
    sbg.InputEnded:Connect(function() dragging = false end)
    UserInputService.TouchMoved:Connect(function(input)
        if dragging then updateSlider(input) end
    end)
end

-- Drawing functions
local function CreateFOVCircle()
    if LessScript.FOVCircle then LessScript.FOVCircle:Remove() end
    local c = Drawing.new("Circle")
    c.Visible = LessScript.Settings.Aimbot.ShowFOV
    c.Radius = LessScript.Settings.Aimbot.FOV
    c.Color = Color3.fromRGB(255, 60, 60)
    c.Thickness = 1.5
    c.Transparency = 0.7
    c.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    LessScript.FOVCircle = c
    if LessScript.Connections.FOVUpd then LessScript.Connections.FOVUpd:Disconnect() end
    LessScript.Connections.FOVUpd = RunService.RenderStepped:Connect(function()
        if LessScript.FOVCircle then
            LessScript.FOVCircle.Visible = LessScript.Settings.Aimbot.ShowFOV
            LessScript.FOVCircle.Radius = LessScript.Settings.Aimbot.FOV
            LessScript.FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        end
    end)
end
local function RemoveFOVCircle()
    if LessScript.FOVCircle then LessScript.FOVCircle:Remove(); LessScript.FOVCircle = nil end
    if LessScript.Connections.FOVUpd then LessScript.Connections.FOVUpd:Disconnect() end
end

local function CreateAimViewCircle()
    if LessScript.AimViewCircle then LessScript.AimViewCircle:Remove() end
    local c = Drawing.new("Circle")
    c.Visible = true
    c.Radius = LessScript.Settings.AimView.FOV
    c.Color = Color3.fromRGB(255, 200, 0)
    c.Thickness = 1
    c.Transparency = 0.8
    c.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    LessScript.AimViewCircle = c
    if LessScript.Connections.AVUpd then LessScript.Connections.AVUpd:Disconnect() end
    LessScript.Connections.AVUpd = RunService.RenderStepped:Connect(function()
        if LessScript.AimViewCircle then
            LessScript.AimViewCircle.Radius = LessScript.Settings.AimView.FOV
            LessScript.AimViewCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        end
    end)
end
local function RemoveAimViewCircle()
    if LessScript.AimViewCircle then LessScript.AimViewCircle:Remove(); LessScript.AimViewCircle = nil end
    if LessScript.Connections.AVUpd then LessScript.Connections.AVUpd:Disconnect() end
end

local function CreateCrosshair()
    if LessScript.CrosshairObj then for _, o in pairs(LessScript.CrosshairObj) do o:Remove() end end
    local s = LessScript.Settings.Crosshair.Size
    local c = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local h = Drawing.new("Line"); h.Visible = true; h.From = Vector2.new(c.X - s, c.Y); h.To = Vector2.new(c.X + s, c.Y); h.Color = Color3.fromRGB(255, 60, 60); h.Thickness = 1.5
    local v = Drawing.new("Line"); v.Visible = true; v.From = Vector2.new(c.X, c.Y - s); v.To = Vector2.new(c.X, c.Y + s); v.Color = Color3.fromRGB(255, 60, 60); v.Thickness = 1.5
    LessScript.CrosshairObj = {h, v}
    if LessScript.Connections.ChUpd then LessScript.Connections.ChUpd:Disconnect() end
    LessScript.Connections.ChUpd = RunService.RenderStepped:Connect(function()
        if LessScript.Settings.Crosshair.Enabled and LessScript.CrosshairObj then
            local nc = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local sz = LessScript.Settings.Crosshair.Size
            LessScript.CrosshairObj[1].From = Vector2.new(nc.X - sz, nc.Y); LessScript.CrosshairObj[1].To = Vector2.new(nc.X + sz, nc.Y)
            LessScript.CrosshairObj[2].From = Vector2.new(nc.X, nc.Y - sz); LessScript.CrosshairObj[2].To = Vector2.new(nc.X, nc.Y + sz)
        end
    end)
end
local function RemoveCrosshair()
    if LessScript.CrosshairObj then for _, o in pairs(LessScript.CrosshairObj) do o:Remove() end; LessScript.CrosshairObj = nil end
    if LessScript.Connections.ChUpd then LessScript.Connections.ChUpd:Disconnect() end
end

-- Helper function to check if a player is an enemy
local function IsEnemy(player)
    if player == LocalPlayer then return false end
    local myTeam = LocalPlayer.Team
    local playerTeam = player.Team
    if myTeam and playerTeam then
        return myTeam ~= playerTeam
    end
    return true
end

-- Check if there is clear line of sight to target (no obstacles)
local function HasClearLineOfSight(origin, targetPos)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character or game}
    
    if LocalPlayer.Character then
        local ignoreList = {}
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                table.insert(ignoreList, plr.Character)
            end
        end
        raycastParams.FilterDescendantsInstances = ignoreList
    end
    
    local direction = (targetPos - origin).Unit
    local distance = (targetPos - origin).Magnitude
    local raycastResult = Workspace:Raycast(origin, direction * distance, raycastParams)
    
    if raycastResult then
        local hitPart = raycastResult.Instance
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and hitPart:IsDescendantOf(plr.Character) then
                return true
            end
        end
        return false
    end
    
    return true
end

-- Core combat functions - only targets enemies
local function GetClosestEnemyInFOV(fov)
    local best, bestDist = nil, fov or 9999
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, player in pairs(Players:GetPlayers()) do
        if IsEnemy(player) and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local hum = player.Character:FindFirstChild("Humanoid")
            if head and hum and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if dist < bestDist then bestDist = dist; best = player end
                end
            end
        end
    end
    return best
end

local function GetAimPart(character, partName)
    if partName == "Head" and character:FindFirstChild("Head") then return character.Head end
    if partName == "Torso" and character:FindFirstChild("UpperTorso") then return character.UpperTorso end
    if partName == "HumanoidRootPart" and character:FindFirstChild("HumanoidRootPart") then return character.HumanoidRootPart end
    return character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
end

-- ===== BUILD ALL CONTENT =====

-- Combat Tab
CreateSection(TabContents["Combat"], "Aimbot")
CreateToggle(TabContents["Combat"], LessScript.Settings.Aimbot, "Aimbot", function(on)
    if on then
        CreateFOVCircle()
        if LessScript.Connections.Aim then LessScript.Connections.Aim:Disconnect() end
        LessScript.Connections.Aim = RunService.RenderStepped:Connect(function()
            if not LessScript.Settings.Aimbot.Enabled then return end
            
            local target = GetClosestEnemyInFOV(LessScript.Settings.Aimbot.FOV)
            if target and target.Character then
                local aimPart = GetAimPart(target.Character, LessScript.Settings.Aimbot.AimPart)
                if aimPart then
                    local targetPos = aimPart.Position
                    local cameraPos = Camera.CFrame.Position
                    
                    -- Always lock onto head regardless of AutoFire
                    Camera.CFrame = CFrame.new(cameraPos, targetPos)
                    
                    -- AutoFire only when 100% hit chance (clear line of sight, no obstacles)
                    if LessScript.Settings.Aimbot.AutoFire then
                        local myChar = LocalPlayer.Character
                        if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                            local myHeadPos = myChar:FindFirstChild("Head") and myChar.Head.Position or myChar.HumanoidRootPart.Position
                            local canHit = HasClearLineOfSight(myHeadPos, targetPos)
                            local dist = (myHeadPos - targetPos).Magnitude
                            if canHit and dist <= 300 then
                                local virtualUser = game:GetService("VirtualUser")
                                virtualUser:CaptureController()
                                virtualUser:ClickButton1(Vector2.new())
                            end
                        end
                    end
                end
            end
        end)
    else
        RemoveFOVCircle()
        if LessScript.Connections.Aim then LessScript.Connections.Aim:Disconnect() end
    end
end)
CreateToggle(TabContents["Combat"], LessScript.Settings.Aimbot, "AutoFire", function(on)
    LessScript.Settings.Aimbot.AutoFire = on
end)
CreateToggle(TabContents["Combat"], LessScript.Settings.Aimbot, "Show FOV Circle", function(on)
    LessScript.Settings.Aimbot.ShowFOV = on
    if LessScript.FOVCircle then LessScript.FOVCircle.Visible = on end
    if on and LessScript.Settings.Aimbot.Enabled and not LessScript.FOVCircle then CreateFOVCircle() end
end)
CreateSlider(TabContents["Combat"], LessScript.Settings.Aimbot, "FOV", 40, 400, 120, function(v) LessScript.Settings.Aimbot.FOV = v end)

CreateSection(TabContents["Combat"], "Silent Aim")
CreateToggle(TabContents["Combat"], LessScript.Settings.SilentAim, "Silent Aim", function(on)
    if on then
        local mt = getrawmetatable(game)
        if mt then
            setreadonly(mt, false)
            local oldNamecall = mt.__namecall
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                local args = {...}
                if method == "FireServer" and LessScript.Settings.SilentAim.Enabled then
                    local target = GetClosestEnemyInFOV(LessScript.Settings.SilentAim.FOV)
                    if target and target.Character then
                        local aimPart = GetAimPart(target.Character, LessScript.Settings.SilentAim.AimPart)
                        if aimPart then
                            local myChar = LocalPlayer.Character
                            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                                local myHeadPos = myChar:FindFirstChild("Head") and myChar.Head.Position or myChar.HumanoidRootPart.Position
                                local canHit = HasClearLineOfSight(myHeadPos, aimPart.Position)
                                if canHit then
                                    for i, arg in pairs(args) do
                                        if typeof(arg) == "Vector3" then
                                            args[i] = aimPart.Position
                                            return oldNamecall(self, unpack(args))
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                return oldNamecall(self, ...)
            end)
            setreadonly(mt, true)
        end
    end
end)
CreateToggle(TabContents["Combat"], LessScript.Settings.SilentAim, "Silent AutoFire", function(on)
    LessScript.Settings.SilentAim.AutoFire = on
end)
CreateSlider(TabContents["Combat"], LessScript.Settings.SilentAim, "Silent FOV", 40, 400, 120, function(v) LessScript.Settings.SilentAim.FOV = v end)

CreateSection(TabContents["Combat"], "AimView")
CreateToggle(TabContents["Combat"], LessScript.Settings.AimView, "AimView", function(on)
    if on then
        CreateAimViewCircle()
        if LessScript.Connections.AV then LessScript.Connections.AV:Disconnect() end
        LessScript.Connections.AV = RunService.RenderStepped:Connect(function()
            if not LessScript.Settings.AimView.Enabled then return end
            local target = GetClosestEnemyInFOV(LessScript.Settings.AimView.FOV)
            if target and target.Character then
                local aimPart = GetAimPart(target.Character, "Head")
                if aimPart then
                    local myChar = LocalPlayer.Character
                    if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                        local myHeadPos = myChar:FindFirstChild("Head") and myChar.Head.Position or myChar.HumanoidRootPart.Position
                        local canSee = HasClearLineOfSight(myHeadPos, aimPart.Position)
                        if canSee then
                            Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimPart.Position)
                        end
                    end
                end
            end
        end)
    else
        RemoveAimViewCircle()
        if LessScript.Connections.AV then LessScript.Connections.AV:Disconnect() end
    end
end)
CreateSlider(TabContents["Combat"], LessScript.Settings.AimView, "AimView FOV", 20, 200, 80, function(v) LessScript.Settings.AimView.FOV = v end)

CreateSection(TabContents["Combat"], "Trigger and Reach and Nuke")
CreateToggle(TabContents["Combat"], LessScript.Settings.TriggerBot, "TriggerBot", function(on)
    if on then
        if LessScript.Connections.Trg then LessScript.Connections.Trg:Disconnect() end
        LessScript.Connections.Trg = RunService.RenderStepped:Connect(function()
            if not LessScript.Settings.TriggerBot.Enabled then return end
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            local myHeadPos = char:FindFirstChild("Head") and char.Head.Position or char.HumanoidRootPart.Position
            
            local closestEnemy = nil
            local closestDist = 9999
            for _, plr in pairs(Players:GetPlayers()) do
                if IsEnemy(plr) and plr.Character then
                    local tgtHead = plr.Character:FindFirstChild("Head")
                    local tgtHum = plr.Character:FindFirstChild("Humanoid")
                    if tgtHead and tgtHum and tgtHum.Health > 0 then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(tgtHead.Position)
                        if onScreen then
                            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                            local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                            if screenDist < 50 and screenDist < closestDist then
                                if HasClearLineOfSight(myHeadPos, tgtHead.Position) then
                                    closestDist = screenDist
                                    closestEnemy = plr
                                end
                            end
                        end
                    end
                end
            end
            if closestEnemy then
                local virtualUser = game:GetService("VirtualUser")
                virtualUser:CaptureController()
                virtualUser:ClickButton1(Vector2.new())
                task.wait(LessScript.Settings.TriggerBot.Delay)
            end
        end)
    else
        if LessScript.Connections.Trg then LessScript.Connections.Trg:Disconnect() end
    end
end)
CreateSlider(TabContents["Combat"], LessScript.Settings.TriggerBot, "Trigger Delay", 0.01, 0.5, 0.05, function(v) LessScript.Settings.TriggerBot.Delay = v end)

CreateToggle(TabContents["Combat"], LessScript.Settings.Reach, "Reach", function(on)
    if on then
        if LessScript.Connections.Rch then LessScript.Connections.Rch:Disconnect() end
        LessScript.Connections.Rch = RunService.RenderStepped:Connect(function()
            if not LessScript.Settings.Reach.Enabled then return end
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local myRoot = char.HumanoidRootPart
                local myHeadPos = char:FindFirstChild("Head") and char.Head.Position or myRoot.Position
                for _, plr in pairs(Players:GetPlayers()) do
                    if IsEnemy(plr) and plr.Character then
                        local tgtRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                        local tgtHum = plr.Character:FindFirstChild("Humanoid")
                        if tgtRoot and tgtHum and tgtHum.Health > 0 then
                            local dist = (myRoot.Position - tgtRoot.Position).Magnitude
                            if dist <= LessScript.Settings.Reach.Distance then
                                if HasClearLineOfSight(myHeadPos, tgtRoot.Position) then
                                    local virtualUser = game:GetService("VirtualUser")
                                    virtualUser:CaptureController()
                                    virtualUser:ClickButton1(Vector2.new())
                                end
                            end
                        end
                    end
                end
            end
        end)
    else
        if LessScript.Connections.Rch then LessScript.Connections.Rch:Disconnect() end
    end
end)
CreateSlider(TabContents["Combat"], LessScript.Settings.Reach, "Reach Dist", 10, 30, 15, function(v) LessScript.Settings.Reach.Distance = v end)

CreateToggle(TabContents["Combat"], LessScript.Settings.Nuke, "Nuke", function(on)
    if on then
        if LessScript.Connections.Nuke then LessScript.Connections.Nuke:Disconnect() end
        LessScript.Connections.Nuke = RunService.RenderStepped:Connect(function()
            if not LessScript.Settings.Nuke.Enabled then return end
            local myChar = LocalPlayer.Character
            if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
            local myHeadPos = myChar:FindFirstChild("Head") and myChar.Head.Position or myChar.HumanoidRootPart.Position
            
            for _, plr in pairs(Players:GetPlayers()) do
                if IsEnemy(plr) and plr.Character then
                    local root = plr.Character:FindFirstChild("HumanoidRootPart")
                    local hum = plr.Character:FindFirstChild("Humanoid")
                    if root and hum and hum.Health > 0 then
                        if (myChar.HumanoidRootPart.Position - root.Position).Magnitude <= LessScript.Settings.Nuke.Range then
                            if HasClearLineOfSight(myHeadPos, root.Position) then
                                local virtualUser = game:GetService("VirtualUser")
                                virtualUser:CaptureController()
                                virtualUser:ClickButton1(Vector2.new())
                                task.wait(0.03)
                            end
                        end
                    end
                end
            end
        end)
    else
        if LessScript.Connections.Nuke then LessScript.Connections.Nuke:Disconnect() end
    end
end)
CreateSlider(TabContents["Combat"], LessScript.Settings.Nuke, "Nuke Range", 10, 100, 30, function(v) LessScript.Settings.Nuke.Range = v end)

CreateSection(TabContents["Combat"], "Weapon Mods")
CreateToggle(TabContents["Combat"], LessScript.Settings.InfiniteAmmo, "Infinite Ammo", function(on)
    if on then
        if LessScript.Connections.InfAm then LessScript.Connections.InfAm:Disconnect() end
        LessScript.Connections.InfAm = RunService.RenderStepped:Connect(function()
            if not LessScript.Settings.InfiniteAmmo.Enabled then return end
            local char = LocalPlayer.Character
            if char then
                for _, tool in pairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        if tool:FindFirstChild("Ammo") then
                            tool.Ammo.Value = 999
                        end
                        if tool:FindFirstChild("MaxAmmo") then
                            tool.MaxAmmo.Value = 999
                        end
                        if tool:FindFirstChild("CurrentAmmo") then
                            tool.CurrentAmmo.Value = 999
                        end
                        if tool:FindFirstChild("Magazine") then
                            tool.Magazine.Value = 999
                        end
                        for _, child in pairs(tool:GetDescendants()) do
                            if child:IsA("IntValue") or child:IsA("NumberValue") then
                                local lowerName = child.Name:lower()
                                if lowerName:find("ammo") or lowerName:find("mag") or lowerName:find("bullet") or lowerName:find("clip") then
                                    child.Value = 999
                                end
                            end
                        end
                    end
                end
            end
        end)
    else
        if LessScript.Connections.InfAm then LessScript.Connections.InfAm:Disconnect() end
    end
end)

CreateToggle(TabContents["Combat"], LessScript.Settings.NoRecoil, "No Recoil", function(on)
    if on then
        if LessScript.Connections.NoRec then LessScript.Connections.NoRec:Disconnect() end
        LessScript.Connections.NoRec = RunService.RenderStepped:Connect(function()
            if not LessScript.Settings.NoRecoil.Enabled then return end
            local char = LocalPlayer.Character
            if char then
                for _, tool in pairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        for _, child in pairs(tool:GetDescendants()) do
                            local lowerName = child.Name:lower()
                            if lowerName:find("recoil") or lowerName:find("kick") or lowerName:find("spread") or lowerName:find("camerashake") then
                                if child:IsA("NumberValue") or child:IsA("IntValue") or child:IsA("Vector3Value") then
                                    pcall(function()
                                        if child:IsA("Vector3Value") then
                                            child.Value = Vector3.new(0, 0, 0)
                                        else
                                            child.Value = 0
                                        end
                                    end)
                                end
                            end
                        end
                    end
                end
                local hum = char:FindFirstChild("Humanoid")
                if hum then
                    hum.CameraOffset = Vector3.new(0, 0, 0)
                end
            end
        end)
    else
        if LessScript.Connections.NoRec then LessScript.Connections.NoRec:Disconnect() end
    end
end)

CreateToggle(TabContents["Combat"], LessScript.Settings.RapidFire, "Rapid Fire", function(on)
    if on then
        if LessScript.Connections.Rpf then LessScript.Connections.Rpf:Disconnect() end
        LessScript.Connections.Rpf = RunService.RenderStepped:Connect(function()
            if not LessScript.Settings.RapidFire.Enabled then return end
            local virtualUser = game:GetService("VirtualUser")
            virtualUser:CaptureController()
            virtualUser:ClickButton1(Vector2.new())
            task.wait(LessScript.Settings.RapidFire.Speed)
            virtualUser:ClickButton1(Vector2.new())
        end)
    else
        if LessScript.Connections.Rpf then LessScript.Connections.Rpf:Disconnect() end
    end
end)
CreateSlider(TabContents["Combat"], LessScript.Settings.RapidFire, "Fire Speed", 0.01, 0.3, 0.05, function(v) LessScript.Settings.RapidFire.Speed = v end)

CreateToggle(TabContents["Combat"], LessScript.Settings.BulletPrediction, "Bullet Prediction", function(on)
    if on then
        if LessScript.Connections.BP then LessScript.Connections.BP:Disconnect() end
        LessScript.Connections.BP = RunService.RenderStepped:Connect(function()
            if not LessScript.Settings.BulletPrediction.Enabled then return end
            local target = GetClosestEnemyInFOV(LessScript.Settings.Aimbot.FOV)
            if target and target.Character then
                local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    if not targetRoot:GetAttribute("LastPos") then
                        targetRoot:SetAttribute("LastPos", targetRoot.Position)
                        targetRoot:SetAttribute("LastTime", tick())
                    else
                        local lastPos = targetRoot:GetAttribute("LastPos")
                        local lastTime = targetRoot:GetAttribute("LastTime")
                        local deltaTime = tick() - lastTime
                        if deltaTime > 0 then
                            local velocity = (targetRoot.Position - lastPos) / deltaTime
                            targetRoot:SetAttribute("PredictedPos", targetRoot.Position + velocity * 0.1)
                            targetRoot:SetAttribute("LastPos", targetRoot.Position)
                            targetRoot:SetAttribute("LastTime", tick())
                        end
                    end
                end
            end
        end)
    else
        if LessScript.Connections.BP then LessScript.Connections.BP:Disconnect() end
    end
end)

CreateToggle(TabContents["Combat"], LessScript.Settings.AutoReload, "Auto Reload", function(on)
    if on then
        if LessScript.Connections.AR then LessScript.Connections.AR:Disconnect() end
        LessScript.Connections.AR = RunService.RenderStepped:Connect(function()
            if not LessScript.Settings.AutoReload.Enabled then return end
            local char = LocalPlayer.Character
            if char then
                for _, tool in pairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        local ammoFound = false
                        for _, child in pairs(tool:GetDescendants()) do
                            if child:IsA("IntValue") or child:IsA("NumberValue") then
                                local lowerName = child.Name:lower()
                                if lowerName:find("ammo") or lowerName:find("mag") or lowerName:find("clip") then
                                    if child.Value <= 0 then
                                        ammoFound = true
                                        break
                                    end
                                end
                            end
                        end
                        if ammoFound then
                            local virtualInputManager = game:GetService("VirtualInputManager")
                            virtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, nil)
                            task.wait(0.1)
                            virtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, nil)
                        end
                    end
                end
            end
        end)
    else
        if LessScript.Connections.AR then LessScript.Connections.AR:Disconnect() end
    end
end)

CreateToggle(TabContents["Combat"], LessScript.Settings.HitboxExpander, "Hitbox Expander", function(on)
    if on then
        if LessScript.Connections.Hbx then LessScript.Connections.Hbx:Disconnect() end
        LessScript.Connections.Hbx = RunService.RenderStepped:Connect(function()
            if not LessScript.Settings.HitboxExpander.Enabled then return end
            for _, plr in pairs(Players:GetPlayers()) do
                if IsEnemy(plr) and plr.Character then
                    for _, part in pairs(plr.Character:GetChildren()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            local origSize = part.Size
                            local expandSize = LessScript.Settings.HitboxExpander.Size
                            part.Size = Vector3.new(
                                origSize.X + expandSize,
                                origSize.Y + expandSize,
                                origSize.Z + expandSize
                            )
                            if part.Name == "Head" then
                                part.CanCollide = false
                                part.Transparency = 0.3
                            end
                        end
                    end
                end
            end
        end)
    else
        if LessScript.Connections.Hbx then LessScript.Connections.Hbx:Disconnect() end
    end
end)
CreateSlider(TabContents["Combat"], LessScript.Settings.HitboxExpander, "Hitbox Size", 1, 10, 2, function(v) LessScript.Settings.HitboxExpander.Size = v end)

-- Movement Tab
CreateSection(TabContents["Move"], "Movement")
CreateToggle(TabContents["Move"], LessScript.Settings.Fly, "Fly", function(on)
    if on then
        if LessScript.Connections.Fly then LessScript.Connections.Fly:Disconnect() end
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if root and hum then
            local bg = Instance.new("BodyGyro"); bg.P = 9e4; bg.maxTorque = Vector3.new(9e9, 9e9, 9e9); bg.CFrame = root.CFrame; bg.Parent = root
            local bv = Instance.new("BodyVelocity"); bv.maxForce = Vector3.new(9e9, 9e9, 9e9); bv.Parent = root
            LessScript.Connections.Fly = RunService.RenderStepped:Connect(function()
                if not LessScript.Settings.Fly.Enabled then bg:Destroy(); bv:Destroy(); LessScript.Connections.Fly:Disconnect(); hum.PlatformStand = false; return end
                hum.PlatformStand = true
                bv.Velocity = Camera.CFrame.LookVector * LessScript.Settings.Fly.Speed
                bg.CFrame = Camera.CFrame
            end)
        end
    else
        if LessScript.Connections.Fly then LessScript.Connections.Fly:Disconnect() end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.PlatformStand = false end
    end
end)
CreateSlider(TabContents["Move"], LessScript.Settings.Fly, "Fly Speed", 10, 200, 50, function(v) LessScript.Settings.Fly.Speed = v end)

CreateToggle(TabContents["Move"], LessScript.Settings.SpeedHack, "Speed Hack", function(on)
    if on then
        if LessScript.Connections.Spd then LessScript.Connections.Spd:Disconnect() end
        LessScript.Connections.Spd = RunService.RenderStepped:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = LessScript.Settings.SpeedHack.Speed
            end
        end)
    else
        if LessScript.Connections.Spd then LessScript.Connections.Spd:Disconnect() end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = 16 end
    end
end)
CreateSlider(TabContents["Move"], LessScript.Settings.SpeedHack, "Walk Speed", 16, 300, 50, function(v) LessScript.Settings.SpeedHack.Speed = v end)

CreateToggle(TabContents["Move"], LessScript.Settings.NoClip, "NoClip", function(on)
    if on then
        if LessScript.Connections.NC then LessScript.Connections.NC:Disconnect() end
        LessScript.Connections.NC = RunService.Stepped:Connect(function()
            if not LessScript.Settings.NoClip.Enabled then return end
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if LessScript.Connections.NC then LessScript.Connections.NC:Disconnect() end
    end
end)

CreateToggle(TabContents["Move"], LessScript.Settings.InfiniteJump, "Infinite Jump", function(on)
    if on then
        if LessScript.Connections.Jmp then LessScript.Connections.Jmp:Disconnect() end
        LessScript.Connections.Jmp = UserInputService.JumpRequest:Connect(function()
            if not LessScript.Settings.InfiniteJump.Enabled then return end
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if LessScript.Connections.Jmp then LessScript.Connections.Jmp:Disconnect() end
    end
end)

CreateToggle(TabContents["Move"], LessScript.Settings.SpinBot, "SpinBot", function(on)
    if on then
        if LessScript.Connections.Spn then LessScript.Connections.Spn:Disconnect() end
        LessScript.Connections.Spn = RunService.RenderStepped:Connect(function()
            if not LessScript.Settings.SpinBot.Enabled then return end
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(LessScript.Settings.SpinBot.Speed), 0)
            end
        end)
    else
        if LessScript.Connections.Spn then LessScript.Connections.Spn:Disconnect() end
    end
end)
CreateSlider(TabContents["Move"], LessScript.Settings.SpinBot, "Spin Speed", 1, 50, 10, function(v) LessScript.Settings.SpinBot.Speed = v end)

CreateToggle(TabContents["Move"], LessScript.Settings.AutoDodge, "Auto Dodge", function(on)
    if on then
        if LessScript.Connections.Ddg then LessScript.Connections.Ddg:Disconnect() end
        LessScript.Connections.Ddg = RunService.RenderStepped:Connect(function()
            if not LessScript.Settings.AutoDodge.Enabled then return end
            local myChar = LocalPlayer.Character
            if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
            local myRoot = myChar.HumanoidRootPart
            for _, plr in pairs(Players:GetPlayers()) do
                if IsEnemy(plr) and plr.Character then
                    local tgtRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                    if tgtRoot and (myRoot.Position - tgtRoot.Position).Magnitude < LessScript.Settings.AutoDodge.Distance then
                        local away = (myRoot.Position - tgtRoot.Position).Unit
                        myRoot.CFrame = CFrame.new(myRoot.Position + away * 8)
                    end
                end
            end
        end)
    else
        if LessScript.Connections.Ddg then LessScript.Connections.Ddg:Disconnect() end
    end
end)
CreateSlider(TabContents["Move"], LessScript.Settings.AutoDodge, "Dodge Dist", 5, 50, 20, function(v) LessScript.Settings.AutoDodge.Distance = v end)

CreateToggle(TabContents["Move"], LessScript.Settings.Teleport, "Teleport", function(on)
    if on then
        if LessScript.Connections.TP then LessScript.Connections.TP:Disconnect() end
        LessScript.Connections.TP = RunService.RenderStepped:Connect(function()
            if not LessScript.Settings.Teleport.Enabled then return end
            local myChar = LocalPlayer.Character
            if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
            local myRoot = myChar.HumanoidRootPart
            
            local nearestEnemy = nil
            local nearestDist = 9999
            
            for _, plr in pairs(Players:GetPlayers()) do
                if IsEnemy(plr) and plr.Character then
                    local tgtRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                    local tgtHum = plr.Character:FindFirstChild("Humanoid")
                    if tgtRoot and tgtHum and tgtHum.Health > 0 then
                        local dist = (myRoot.Position - tgtRoot.Position).Magnitude
                        if dist < nearestDist then
                            nearestDist = dist
                            nearestEnemy = plr
                        end
                    end
                end
            end
            
            if nearestEnemy and nearestEnemy.Character then
                local tgtRoot = nearestEnemy.Character:FindFirstChild("HumanoidRootPart")
                if tgtRoot then
                    local behindPos = tgtRoot.CFrame * CFrame.new(0, 0, 3)
                    myRoot.CFrame = behindPos
                end
            end
        end)
    else
        if LessScript.Connections.TP then LessScript.Connections.TP:Disconnect() end
    end
end)

-- Visuals Tab
CreateSection(TabContents["Visuals"], "ESP")
CreateToggle(TabContents["Visuals"], LessScript.Settings.ESP, "Player ESP", function(on)
    if on then
        for _, obj in pairs(LessScript.ESPObjects) do
            if typeof(obj) == "Instance" then obj:Destroy()
            elseif typeof(obj) == "RBXScriptConnection" then obj:Disconnect() end
        end
        LessScript.ESPObjects = {}
        local function addESP(player)
            if not IsEnemy(player) then return end
            local function createESP()
                local char = player.Character
                if not char then return end
                if LessScript.Settings.ESP.Boxes then
                    local hl = Instance.new("Highlight"); hl.FillColor = Color3.fromRGB(255, 60, 60); hl.FillTransparency = 0.6
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255); hl.OutlineTransparency = 0.3; hl.Parent = char
                    table.insert(LessScript.ESPObjects, hl)
                end
                local bb = Instance.new("BillboardGui"); bb.Size = UDim2.new(0, 120, 0, 50); bb.StudsOffset = Vector3.new(0, 3, 0)
                bb.AlwaysOnTop = true; bb.Parent = char; table.insert(LessScript.ESPObjects, bb)
                if LessScript.Settings.ESP.Names then
                    local nl = Instance.new("TextLabel"); nl.Size = UDim2.new(1, 0, 0, 14); nl.BackgroundTransparency = 1
                    nl.Text = player.Name; nl.TextColor3 = Color3.fromRGB(255, 255, 255); nl.TextSize = 10; nl.Font = Enum.Font.GothamBold; nl.Parent = bb
                end
                if LessScript.Settings.ESP.Health and char:FindFirstChild("Humanoid") then
                    local hll = Instance.new("TextLabel"); hll.Size = UDim2.new(1, 0, 0, 14); hll.Position = UDim2.new(0, 0, 0, 16); hll.BackgroundTransparency = 1
                    hll.Text = "HP: " .. math.floor(char.Humanoid.Health); hll.TextColor3 = Color3.fromRGB(255, 100, 100); hll.TextSize = 10; hll.Font = Enum.Font.Gotham; hll.Parent = bb
                    table.insert(LessScript.ESPObjects, char.Humanoid.HealthChanged:Connect(function(hp) hll.Text = "HP: " .. math.floor(hp) end))
                end
            end
            if player.Character then createESP() end
            player.CharacterAdded:Connect(function() if LessScript.Settings.ESP.Enabled then wait(0.3); createESP() end end)
        end
        for _, p in pairs(Players:GetPlayers()) do addESP(p) end
        Players.PlayerAdded:Connect(function(player)
            wait(0.5)
            addESP(player)
        end)
    else
        for _, obj in pairs(LessScript.ESPObjects) do
            if typeof(obj) == "Instance" then obj:Destroy()
            elseif typeof(obj) == "RBXScriptConnection" then obj:Disconnect() end
        end
        LessScript.ESPObjects = {}
    end
end)

CreateSection(TabContents["Visuals"], "Camera and Crosshair")
CreateToggle(TabContents["Visuals"], LessScript.Settings.ThirdPerson, "Third Person", function(on)
    if on then
        LocalPlayer.CameraMaxZoomDistance = LessScript.Settings.ThirdPerson.Distance
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
    else
        LocalPlayer.CameraMaxZoomDistance = 10
    end
end)
CreateSlider(TabContents["Visuals"], LessScript.Settings.ThirdPerson, "Camera Dist", 5, 30, 10, function(v)
    LessScript.Settings.ThirdPerson.Distance = v
    if LessScript.Settings.ThirdPerson.Enabled then LocalPlayer.CameraMaxZoomDistance = v end
end)

CreateToggle(TabContents["Visuals"], LessScript.Settings.Crosshair, "Crosshair", function(on)
    if on then CreateCrosshair() else RemoveCrosshair() end
end)
CreateSlider(TabContents["Visuals"], LessScript.Settings.Crosshair, "Size", 5, 40, 20, function(v) LessScript.Settings.Crosshair.Size = v end)

-- Misc Tab
CreateSection(TabContents["Misc"], "Misc")
CreateToggle(TabContents["Misc"], LessScript.Settings.AntiAfk, "Anti AFK", function(on)
    if on then
        if LessScript.Connections.AFK then LessScript.Connections.AFK:Disconnect() end
        LessScript.Connections.AFK = LocalPlayer.Idled:Connect(function()
            local virtualUser = game:GetService("VirtualUser")
            virtualUser:CaptureController()
            virtualUser:ClickButton2(Vector2.new())
            wait(1)
            virtualUser:ClickButton2(Vector2.new())
        end)
    else
        if LessScript.Connections.AFK then LessScript.Connections.AFK:Disconnect() end
    end
end)

CreateToggle(TabContents["Misc"], LessScript.Settings.AutoFarm, "Auto Farm", function(on)
    if on then
        if LessScript.Connections.Frm then LessScript.Connections.Frm:Disconnect() end
        LessScript.Connections.Frm = RunService.RenderStepped:Connect(function()
            if not LessScript.Settings.AutoFarm.Enabled then return end
            local myChar = LocalPlayer.Character
            if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
            local myHeadPos = myChar:FindFirstChild("Head") and myChar.Head.Position or myChar.HumanoidRootPart.Position
            
            for _, plr in pairs(Players:GetPlayers()) do
                if IsEnemy(plr) and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
                    local root = plr.Character:FindFirstChild("HumanoidRootPart")
                    if root and (myChar.HumanoidRootPart.Position - root.Position).Magnitude <= LessScript.Settings.AutoFarm.Range then
                        if HasClearLineOfSight(myHeadPos, root.Position) then
                            local virtualUser = game:GetService("VirtualUser")
                            virtualUser:CaptureController()
                            virtualUser:ClickButton1(Vector2.new())
                        end
                    end
                end
            end
        end)
    else
        if LessScript.Connections.Frm then LessScript.Connections.Frm:Disconnect() end
    end
end)
CreateSlider(TabContents["Misc"], LessScript.Settings.AutoFarm, "Farm Range", 10, 200, 50, function(v) LessScript.Settings.AutoFarm.Range = v end)

CreateToggle(TabContents["Misc"], LessScript.Settings.ChatSpy, "Chat Spy", function(on)
    if on then
        if LessScript.Connections.Cht then LessScript.Connections.Cht:Disconnect() end
        LessScript.Connections.Cht = Players.PlayerChatted:Connect(function(plr, msg)
            if LessScript.Settings.ChatSpy.Enabled then print("[ChatSpy] " .. plr.Name .. ": " .. msg) end
        end)
    else
        if LessScript.Connections.Cht then LessScript.Connections.Cht:Disconnect() end
    end
end)

-- Inject main GUI
injectGui(ScreenGui)

-- ===== TOGGLE GUI =====
local function toggleGUI()
    MainFrame.Visible = not MainFrame.Visible
end

-- Watermark click - touch only
WatermarkFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        toggleGUI()
    end
end)

-- Respawn handler
LocalPlayer.CharacterAdded:Connect(function()
    wait(0.3)
    if LessScript.Settings.Fly.Enabled then
        LessScript.Settings.Fly.Enabled = false
        wait()
        LessScript.Settings.Fly.Enabled = true
    end
end)

print("LessScript " .. LessScript.Version .. " Loaded Successfully!")
print("Tap LS watermark to open menu")
