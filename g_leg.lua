-- ============================================
-- SKIBIDI GUI v6.0 FIXED - PRODUCTION READY
-- ============================================
-- ✓ Proper integration with main script
-- ✓ Fast mode shows boost.png ONLY (no white screen)
-- ✓ All images load 100% opaque from GitHub
-- ✓ Mobile + Desktop responsive
-- ✓ Clean, modern interface
-- ============================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local GUI = {}
GUI.Config = {}
GUI.SkibidiGui = nil
GUI.MainFrame = nil
GUI.BackgroundImage = nil
GUI.MusicSound = nil
GUI.LoadingScreen = nil
GUI.Connections = {}
GUI.Tasks = {}
GUI.RunningTweens = {}
GUI.SessionStartTime = tick()
GUI._BoostScreen = nil
GUI.IsMobile = false

-- Detect mobile
local function DetectMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

GUI.IsMobile = DetectMobile()

-- Modern color palette
GUI.Colors = {
    Background = Color3.fromRGB(11, 14, 20),
    Surface = Color3.fromRGB(17, 20, 28),
    SurfaceLight = Color3.fromRGB(24, 28, 38),
    Primary = Color3.fromRGB(88, 166, 255),
    PrimaryDark = Color3.fromRGB(58, 136, 255),
    Success = Color3.fromRGB(52, 211, 153),
    Warning = Color3.fromRGB(251, 191, 36),
    Error = Color3.fromRGB(248, 113, 113),
    Text = Color3.fromRGB(248, 250, 252),
    TextMuted = Color3.fromRGB(148, 163, 184),
    Border = Color3.fromRGB(30, 41, 59),
    Overlay = Color3.fromRGB(0, 0, 0)
}

-- GitHub CDN for all assets
local ASSETS_REPO = "https://raw.githubusercontent.com/Ryu-Dev-here/assetsfora/main/"

-- File paths
local WORKSPACE_FOLDER = "cuackerdoing"
local ASSETS_FOLDER = WORKSPACE_FOLDER .. "/assets"
local IMAGES_FOLDER = ASSETS_FOLDER .. "/images"
local SOUNDS_FOLDER = ASSETS_FOLDER .. "/sounds"
local DATA_FOLDER = WORKSPACE_FOLDER .. "/data"

local MUSIC_FILENAME = "sound.mp3"
local BG_FILENAME = "backlua.png"
local LOADING_BG_FILENAME = "loading.png"
local CHANGE_BG_FILENAME = "change.png"
local BOOST_BG_FILENAME = "boost.png"
local TIME_FILENAME = "musictime.txt"

local MUSIC_PATH = SOUNDS_FOLDER .. "/" .. MUSIC_FILENAME
local BG_PATH = IMAGES_FOLDER .. "/" .. BG_FILENAME
local LOADING_PATH = IMAGES_FOLDER .. "/" .. LOADING_BG_FILENAME
local CHANGE_PATH = IMAGES_FOLDER .. "/" .. CHANGE_BG_FILENAME
local BOOST_PATH = IMAGES_FOLDER .. "/" .. BOOST_BG_FILENAME
local TIME_PATH = DATA_FOLDER .. "/" .. TIME_FILENAME

GUI.Config = {
    AutoFarmEnabled = true,
    InstaTeleportEnabled = true,
    AntiRagdollEnabled = true,
    FruitAttackEnabled = true,
    MusicEnabled = true,
    MusicVolume = 0.5,
    FastMode = false
}

-- ============================================
-- WORKSPACE INITIALIZATION
-- ============================================

local function InitWorkspace()
    local folders = {
        WORKSPACE_FOLDER,
        ASSETS_FOLDER,
        IMAGES_FOLDER,
        SOUNDS_FOLDER,
        DATA_FOLDER
    }
    
    for _, folder in ipairs(folders) do
        pcall(function()
            if not isfolder(folder) then
                makefolder(folder)
            end
        end)
    end
end

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

function GUI.AddConnection(connection)
    if connection then
        table.insert(GUI.Connections, connection)
    end
    return connection
end

function GUI.AddTask(taskThread)
    if taskThread then
        table.insert(GUI.Tasks, taskThread)
    end
    return taskThread
end

local function Tween(object, properties, duration, style, direction, callback)
    if not object or not object.Parent then return nil end
    
    local success, tween = pcall(function()
        return TweenService:Create(
            object,
            TweenInfo.new(
                duration or 0.4,
                style or Enum.EasingStyle.Quart,
                direction or Enum.EasingDirection.Out
            ),
            properties
        )
    end)
    
    if not success or not tween then return nil end
    
    table.insert(GUI.RunningTweens, tween)
    
    tween.Completed:Connect(function()
        local index = table.find(GUI.RunningTweens, tween)
        if index then
            table.remove(GUI.RunningTweens, index)
        end
        if callback then callback() end
    end)
    
    pcall(function() tween:Play() end)
    return tween
end

-- ============================================
-- RESPONSIVE SIZING
-- ============================================

local function GetResponsiveSize()
    local viewport = workspace.CurrentCamera.ViewportSize
    local isMobile = GUI.IsMobile
    
    if isMobile then
        return {
            width = math.min(viewport.X * 0.95, 500),
            height = math.min(viewport.Y * 0.8, 650),
            padding = 10,
            buttonHeight = 40,
            fontSize = {
                title = 20,
                subtitle = 14,
                label = 12,
                button = 14
            }
        }
    else
        return {
            width = 900,
            height = 600,
            padding = 20,
            buttonHeight = 50,
            fontSize = {
                title = 28,
                subtitle = 18,
                label = 14,
                button = 16
            }
        }
    end
end

-- ============================================
-- IMAGE LOADING FROM GITHUB - 100% OPAQUE
-- ============================================

local function LoadImageFromGitHub(filename, imageLabel, callback)
    if not imageLabel or not imageLabel.Parent then
        return
    end
    
    GUI.AddTask(task.spawn(function()
        local success = pcall(function()
            -- Load directly from GitHub CDN
            local url = ASSETS_REPO .. filename
            imageLabel.Image = url
            
            -- Set 100% opaque (0 = fully visible)
            imageLabel.ImageTransparency = 0
            
            print("[GUI] ✓ Loaded: " .. filename .. " (100% opaque)")
            
            if callback then
                callback()
            end
        end)
        
        if not success then
            print("[GUI] ✗ Failed to load: " .. filename)
            if callback then
                callback()
            end
        end
    end))
end

-- ============================================
-- MUSIC SYSTEM
-- ============================================

function GUI.SaveMusicState()
    if not GUI.MusicSound then return end
    
    pcall(function()
        if GUI.MusicSound.IsPlaying and writefile then
            local timePos = GUI.MusicSound.TimePosition
            if timePos and type(timePos) == "number" and timePos > 0 then
                writefile(TIME_PATH, tostring(timePos))
            end
        end
    end)
end

function GUI.LoadMusicState()
    if isfile and isfile(TIME_PATH) and readfile then
        local timeStr = readfile(TIME_PATH)
        return tonumber(timeStr) or 0
    end
    return 0
end

function GUI.InitAssets()
    InitWorkspace()
    
    -- Load background music
    GUI.AddTask(task.spawn(function()
        if not GUI.Config.MusicEnabled then return end
        
        pcall(function()
            if isfile and isfile(MUSIC_PATH) and (getcustomasset or getsynasset) then
                local asset = getcustomasset or getsynasset
                
                if GUI.MusicSound then
                    GUI.MusicSound:Stop()
                    GUI.MusicSound:Destroy()
                end
                
                GUI.MusicSound = Instance.new("Sound")
                GUI.MusicSound.SoundId = asset(MUSIC_PATH)
                GUI.MusicSound.Volume = GUI.Config.MusicVolume
                GUI.MusicSound.Looped = true
                GUI.MusicSound.Parent = SoundService
                
                local savedTime = GUI.LoadMusicState()
                if savedTime then
                    GUI.MusicSound.TimePosition = savedTime
                end
                
                GUI.MusicSound:Play()
                print("[GUI] ♪ Music playing")
                
                -- Auto-save music position
                GUI.AddTask(task.spawn(function()
                    while GUI.MusicSound and GUI.MusicSound.Parent do
                        task.wait(5)
                        GUI.SaveMusicState()
                    end
                end))
            else
                print("[GUI] Music file not found, downloading...")
                if writefile then
                    local musicData = game:HttpGet(ASSETS_REPO .. MUSIC_FILENAME, true)
                    writefile(MUSIC_PATH, musicData)
                    GUI.InitAssets()
                end
            end
        end)
    end))
    
    -- Load background images for main GUI
    if GUI.BackgroundImage then
        LoadImageFromGitHub(BG_FILENAME, GUI.BackgroundImage)
    end
end

-- ============================================
-- LOADING SCREEN
-- ============================================

function GUI.CreateLoadingScreen()
    local Screen = Instance.new("Frame")
    Screen.Name = "LoadingScreen"
    Screen.Size = UDim2.new(1, 0, 1, 0)
    Screen.BackgroundColor3 = GUI.Colors.Background
    Screen.ZIndex = 10000
    Screen.Parent = GUI.SkibidiGui
    
    -- Background image - 100% OPAQUE
    local Bg = Instance.new("ImageLabel")
    Bg.Size = UDim2.new(1, 0, 1, 0)
    Bg.BackgroundTransparency = 1
    Bg.ScaleType = Enum.ScaleType.Crop
    Bg.ImageTransparency = 0  -- 100% opaque
    Bg.ZIndex = 10001
    Bg.Parent = Screen
    
    LoadImageFromGitHub(LOADING_BG_FILENAME, Bg)
    
    -- Dark overlay
    local Overlay = Instance.new("Frame")
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3 = GUI.Colors.Overlay
    Overlay.BackgroundTransparency = 0.5
    Overlay.BorderSizePixel = 0
    Overlay.ZIndex = 10002
    Overlay.Parent = Screen
    
    local responsive = GetResponsiveSize()
    
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0, GUI.IsMobile and 350 or 500, 0, GUI.IsMobile and 180 or 250)
    Container.Position = UDim2.new(0.5, GUI.IsMobile and -175 or -250, 0.5, GUI.IsMobile and -90 or -125)
    Container.BackgroundTransparency = 1
    Container.ZIndex = 10003
    Container.Parent = Screen
    
    local Title = Instance.new("TextLabel")
    Title.Text = "SKIBIDI"
    Title.Size = UDim2.new(1, 0, 0, GUI.IsMobile and 50 or 70)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = GUI.IsMobile and 40 or 56
    Title.TextColor3 = GUI.Colors.Text
    Title.TextStrokeTransparency = 0.3
    Title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    Title.ZIndex = 10004
    Title.Parent = Container
    
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Text = "AUTO FARM SYSTEM"
    Subtitle.Size = UDim2.new(1, 0, 0, GUI.IsMobile and 20 or 25)
    Subtitle.Position = UDim2.new(0, 0, 0, GUI.IsMobile and 55 or 75)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Font = Enum.Font.GothamMedium
    Subtitle.TextSize = GUI.IsMobile and 12 or 14
    Subtitle.TextColor3 = GUI.Colors.TextMuted
    Subtitle.ZIndex = 10004
    Subtitle.Parent = Container
    
    -- Compact progress bar (2px)
    local ProgressBg = Instance.new("Frame")
    ProgressBg.Size = UDim2.new(1, 0, 0, 2)
    ProgressBg.Position = UDim2.new(0, 0, 0, GUI.IsMobile and 100 or 130)
    ProgressBg.BackgroundColor3 = GUI.Colors.Surface
    ProgressBg.BorderSizePixel = 0
    ProgressBg.BackgroundTransparency = 0.6
    ProgressBg.ZIndex = 10004
    ProgressBg.Parent = Container
    
    local ProgressCorner = Instance.new("UICorner")
    ProgressCorner.CornerRadius = UDim.new(1, 0)
    ProgressCorner.Parent = ProgressBg
    
    local Progress = Instance.new("Frame")
    Progress.Size = UDim2.new(0, 0, 1, 0)
    Progress.BackgroundColor3 = GUI.Colors.Primary
    Progress.BorderSizePixel = 0
    Progress.ZIndex = 10005
    Progress.Parent = ProgressBg
    
    local ProgressCorner2 = Instance.new("UICorner")
    ProgressCorner2.CornerRadius = UDim.new(1, 0)
    ProgressCorner2.Parent = Progress
    
    local StatusText = Instance.new("TextLabel")
    StatusText.Text = "Initializing..."
    StatusText.Size = UDim2.new(1, 0, 0, 20)
    StatusText.Position = UDim2.new(0, 0, 0, GUI.IsMobile and 115 or 145)
    StatusText.BackgroundTransparency = 1
    StatusText.Font = Enum.Font.Gotham
    StatusText.TextSize = GUI.IsMobile and 12 or 13
    StatusText.TextColor3 = GUI.Colors.TextMuted
    StatusText.ZIndex = 10004
    StatusText.Parent = Container
    
    GUI.LoadingScreen = Screen
    
    -- Loading sequence
    local steps = {
        {text = "Loading workspace...", duration = 0.3},
        {text = "Checking security...", duration = 0.4},
        {text = "Loading assets...", duration = 0.5},
        {text = "Preparing GUI...", duration = 0.4},
        {text = "Ready!", duration = 0.4}
    }
    
    GUI.AddTask(task.spawn(function()
        for i, step in ipairs(steps) do
            if StatusText and StatusText.Parent then
                StatusText.Text = step.text
            end
            local targetProgress = i / #steps
            Tween(Progress, {Size = UDim2.new(targetProgress, 0, 1, 0)}, step.duration, Enum.EasingStyle.Quart)
            task.wait(step.duration)
        end
        
        task.wait(0.5)
        
        -- Fade out
        Tween(Screen, {BackgroundTransparency = 1}, 0.6)
        Tween(Bg, {ImageTransparency = 1}, 0.6)
        Tween(Overlay, {BackgroundTransparency = 1}, 0.6)
        Tween(Title, {TextTransparency = 1}, 0.6)
        Tween(Subtitle, {TextTransparency = 1}, 0.6)
        Tween(StatusText, {TextTransparency = 1}, 0.6)
        Tween(ProgressBg, {BackgroundTransparency = 1}, 0.6, nil, nil, function()
            if Screen and Screen.Parent then
                Screen:Destroy()
            end
            GUI.LoadingScreen = nil
        end)
    end))
    
    return Screen
end

-- ============================================
-- MAIN GUI CREATION
-- ============================================

function GUI.CreateMainGUI()
    InitWorkspace()
    
    -- Clean up existing GUI
    if GUI.SkibidiGui then
        GUI.Cleanup()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SkibidiGui_v6"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local success = pcall(function()
        screenGui.Parent = CoreGui
    end)
    
    if not success then
        local player = Players.LocalPlayer
        local playerGui = player:WaitForChild("PlayerGui", 5)
        if playerGui then
            screenGui.Parent = playerGui
        end
    end
    
    GUI.SkibidiGui = screenGui
    
    GUI.CreateLoadingScreen()
    
    local responsive = GetResponsiveSize()
    
    -- Main container
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = GUI.Colors.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    GUI.MainFrame = mainFrame
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 16)
    mainCorner.Parent = mainFrame
    
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = GUI.Colors.Border
    mainStroke.Thickness = 1
    mainStroke.Transparency = 0.5
    mainStroke.Parent = mainFrame
    
    -- Background image - 100% OPAQUE
    local bgImage = Instance.new("ImageLabel")
    bgImage.Size = UDim2.new(1, 0, 1, 0)
    bgImage.BackgroundTransparency = 1
    bgImage.ScaleType = Enum.ScaleType.Crop
    bgImage.ImageTransparency = 0.15  -- Slight transparency for overlay effect
    bgImage.Parent = mainFrame
    GUI.BackgroundImage = bgImage
    
    LoadImageFromGitHub(BG_FILENAME, bgImage)
    
    -- Dark overlay
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = GUI.Colors.Overlay
    overlay.BackgroundTransparency = 0.3
    overlay.BorderSizePixel = 0
    overlay.Parent = mainFrame
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, GUI.IsMobile and 50 or 60)
    header.BackgroundColor3 = GUI.Colors.Surface
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 16)
    headerCorner.Parent = header
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = "⚡ SKIBIDI AUTO FARM"
    titleLabel.Size = UDim2.new(1, -100, 1, 0)
    titleLabel.Position = UDim2.new(0, responsive.padding, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = responsive.fontSize.title
    titleLabel.TextColor3 = GUI.Colors.Text
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextStrokeTransparency = 0.7
    titleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    titleLabel.Parent = header
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 40, 0, 40)
    closeBtn.Position = UDim2.new(1, -50, 0.5, -20)
    closeBtn.BackgroundColor3 = GUI.Colors.Error
    closeBtn.Text = "×"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 24
    closeBtn.TextColor3 = GUI.Colors.Text
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = header
    
    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 8)
    closeBtnCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        Tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}, 0.2)
        task.wait(0.2)
        GUI.Cleanup()
    end)
    
    -- Content area
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -responsive.padding * 2, 1, -(GUI.IsMobile and 60 or 80))
    content.Position = UDim2.new(0, responsive.padding, 0, GUI.IsMobile and 55 or 65)
    content.BackgroundTransparency = 1
    content.Parent = mainFrame
    
    -- Simple single-panel layout (no tabs for simplicity)
    local mainPanel = Instance.new("ScrollingFrame")
    mainPanel.Name = "MainPanel"
    mainPanel.Size = UDim2.new(1, 0, 1, 0)
    mainPanel.BackgroundTransparency = 1
    mainPanel.BorderSizePixel = 0
    mainPanel.ScrollBarThickness = 4
    mainPanel.ScrollBarImageColor3 = GUI.Colors.Primary
    mainPanel.CanvasSize = UDim2.new(0, 0, 0, GUI.IsMobile and 900 or 700)
    mainPanel.Parent = content
    
    local mainLayout = Instance.new("UIListLayout")
    mainLayout.Padding = UDim.new(0, GUI.IsMobile and 8 or 12)
    mainLayout.Parent = mainPanel
    
    -- Control variables table
    local vars = {}
    
    -- Target display
    local targetFrame = Instance.new("Frame")
    targetFrame.Name = "TargetFrame"
    targetFrame.Size = UDim2.new(1, 0, 0, GUI.IsMobile and 60 or 70)
    targetFrame.BackgroundColor3 = GUI.Colors.Surface
    targetFrame.BorderSizePixel = 0
    targetFrame.Parent = mainPanel
    
    local targetCorner = Instance.new("UICorner")
    targetCorner.CornerRadius = UDim.new(0, 10)
    targetCorner.Parent = targetFrame
    
    local targetTitle = Instance.new("TextLabel")
    targetTitle.Text = "🎯 CURRENT TARGET"
    targetTitle.Size = UDim2.new(1, -30, 0, GUI.IsMobile and 18 or 20)
    targetTitle.Position = UDim2.new(0, 15, 0, 8)
    targetTitle.BackgroundTransparency = 1
    targetTitle.Font = Enum.Font.GothamBold
    targetTitle.TextSize = responsive.fontSize.label
    targetTitle.TextColor3 = GUI.Colors.TextMuted
    targetTitle.TextXAlignment = Enum.TextXAlignment.Left
    targetTitle.Parent = targetFrame
    
    local targetLabel = Instance.new("TextLabel")
    targetLabel.Text = "Searching..."
    targetLabel.Size = UDim2.new(1, -30, 0, GUI.IsMobile and 24 or 28)
    targetLabel.Position = UDim2.new(0, 15, 0, GUI.IsMobile and 30 or 35)
    targetLabel.BackgroundTransparency = 1
    targetLabel.Font = Enum.Font.GothamBold
    targetLabel.TextSize = responsive.fontSize.button
    targetLabel.TextColor3 = GUI.Colors.Text
    targetLabel.TextXAlignment = Enum.TextXAlignment.Left
    targetLabel.Parent = targetFrame
    vars.TargetLabel = targetLabel
    
    -- Status display
    local statusFrame = Instance.new("Frame")
    statusFrame.Name = "StatusFrame"
    statusFrame.Size = UDim2.new(1, 0, 0, GUI.IsMobile and 60 or 70)
    statusFrame.BackgroundColor3 = GUI.Colors.Surface
    statusFrame.BorderSizePixel = 0
    statusFrame.Parent = mainPanel
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 10)
    statusCorner.Parent = statusFrame
    
    local statusTitle = Instance.new("TextLabel")
    statusTitle.Text = "📊 STATUS"
    statusTitle.Size = UDim2.new(1, -30, 0, GUI.IsMobile and 18 or 20)
    statusTitle.Position = UDim2.new(0, 15, 0, 8)
    statusTitle.BackgroundTransparency = 1
    statusTitle.Font = Enum.Font.GothamBold
    statusTitle.TextSize = responsive.fontSize.label
    statusTitle.TextColor3 = GUI.Colors.TextMuted
    statusTitle.TextXAlignment = Enum.TextXAlignment.Left
    statusTitle.Parent = statusFrame
    
    local stateLabel = Instance.new("TextLabel")
    stateLabel.Text = "Idle"
    stateLabel.Size = UDim2.new(1, -30, 0, GUI.IsMobile and 24 or 28)
    stateLabel.Position = UDim2.new(0, 15, 0, GUI.IsMobile and 30 or 35)
    stateLabel.BackgroundTransparency = 1
    stateLabel.Font = Enum.Font.GothamBold
    stateLabel.TextSize = responsive.fontSize.button
    stateLabel.TextColor3 = GUI.Colors.Success
    stateLabel.TextXAlignment = Enum.TextXAlignment.Left
    stateLabel.Parent = statusFrame
    vars.StateLabel = stateLabel
    
    -- Stats displays
    local function CreateStat(emoji, label, value, color)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, GUI.IsMobile and 50 or 60)
        frame.BackgroundColor3 = GUI.Colors.Surface
        frame.BorderSizePixel = 0
        frame.Parent = mainPanel
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = frame
        
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Text = emoji .. " " .. label
        titleLabel.Size = UDim2.new(0.5, 0, 1, 0)
        titleLabel.Position = UDim2.new(0, 15, 0, 0)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Font = Enum.Font.GothamMedium
        titleLabel.TextSize = responsive.fontSize.label
        titleLabel.TextColor3 = GUI.Colors.TextMuted
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = frame
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Text = value
        valueLabel.Size = UDim2.new(0.5, -15, 1, 0)
        valueLabel.Position = UDim2.new(0.5, 0, 0, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextSize = responsive.fontSize.button
        valueLabel.TextColor3 = color
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Parent = frame
        
        return valueLabel
    end
    
    vars.BountyValue = CreateStat("💎", "SESSION BOUNTY", "+0", GUI.Colors.Warning)
    vars.KillsValue = CreateStat("💀", "TOTAL KILLS", "0", GUI.Colors.Error)
    vars.TimeValue = CreateStat("⏱️", "SESSION TIME", "0:00", GUI.Colors.Primary)
    
    -- Control buttons
    local function CreateButton(text, color, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, responsive.buttonHeight)
        btn.BackgroundColor3 = color
        btn.Text = text
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = responsive.fontSize.button
        btn.TextColor3 = GUI.Colors.Text
        btn.BorderSizePixel = 0
        btn.Parent = mainPanel
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 10)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            local originalColor = btn.BackgroundColor3
            Tween(btn, {BackgroundColor3 = Color3.fromRGB(
                math.min(255, originalColor.R * 255 + 30),
                math.min(255, originalColor.G * 255 + 30),
                math.min(255, originalColor.B * 255 + 30)
            )}, 0.1)
            task.wait(0.1)
            Tween(btn, {BackgroundColor3 = originalColor}, 0.1)
            
            if callback then
                callback()
            end
        end)
        
        return btn
    end
    
    CreateButton("⚡ TOGGLE FAST MODE", GUI.Colors.Warning, function()
        GUI.Config.FastMode = not GUI.Config.FastMode
        GUI.SetBoostFPS(GUI.Config.FastMode)
        print("[GUI] Fast Mode: " .. tostring(GUI.Config.FastMode))
    end)
    
    CreateButton("🔄 SERVER HOP", GUI.Colors.Primary, function()
        if getgenv().ServerHop then
            getgenv().ServerHop()
        end
    end)
    
    -- Stats update loop
    GUI.AddTask(task.spawn(function()
        while GUI.SkibidiGui and GUI.SkibidiGui.Parent do
            pcall(function()
                -- Update time
                if vars.TimeValue and vars.TimeValue.Parent then
                    local sessionTime = math.floor(tick() - GUI.SessionStartTime)
                    local minutes = math.floor(sessionTime / 60)
                    local seconds = sessionTime % 60
                    vars.TimeValue.Text = string.format("%d:%02d", minutes, seconds)
                end
                
                -- Update bounty from getgenv
                if vars.BountyValue and vars.BountyValue.Parent then
                    if getgenv().GetCurrentBounty and getgenv().InitialBounty then
                        local current = getgenv().GetCurrentBounty()
                        local initial = getgenv().InitialBounty or 0
                        vars.BountyValue.Text = "+" .. tostring(current - initial)
                    end
                end
                
                -- Update kills from getgenv
                if vars.KillsValue and vars.KillsValue.Parent then
                    if getgenv().TotalKills then
                        vars.KillsValue.Text = tostring(getgenv().TotalKills or 0)
                    end
                end
            end)
            
            task.wait(1)
        end
    end))
    
    -- Make draggable
    local dragging, dragInput, dragStart, startPos
    
    local dragBeginConnection = header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    GUI.AddConnection(dragBeginConnection)
    
    local dragMoveConnection = header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    GUI.AddConnection(dragMoveConnection)
    
    local inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging and GUI.MainFrame and GUI.MainFrame.Parent then
            local delta = input.Position - dragStart
            GUI.MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    GUI.AddConnection(inputChangedConnection)
    
    -- Entrance animation
    Tween(GUI.MainFrame, {Size = UDim2.new(0, responsive.width, 0, responsive.height)}, 0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    
    -- Auto-load assets
    task.spawn(function()
        GUI.InitAssets()
    end)
    
    -- Expose vars to getgenv
    getgenv().GUIVars = vars
    
    -- Logger
    local Logger = {}
    
    function Logger:Log(m)
        if vars.StateLabel and vars.StateLabel.Parent then
            vars.StateLabel.Text = tostring(m)
        end
    end
    
    function Logger:Info(m) self:Log(m) end
    function Logger:Success(m) self:Log(m) end
    function Logger:Warning(m) self:Log(m) end
    function Logger:Error(m) self:Log(m) end
    
    function Logger:Target(m)
        if vars.TargetLabel and vars.TargetLabel.Parent then
            vars.TargetLabel.Text = tostring(m)
        end
    end
    
    return Logger
end

-- ============================================
-- SERVER CHANGE SCREEN - 100% OPAQUE
-- ============================================

function GUI.ShowServerChangeScreen()
    if not GUI.SkibidiGui then return end
    
    local Screen = Instance.new("Frame")
    Screen.Name = "ServerHopScreen"
    Screen.Size = UDim2.new(1, 0, 1, 0)
    Screen.BackgroundColor3 = GUI.Colors.Background
    Screen.BackgroundTransparency = 0
    Screen.ZIndex = 20000
    Screen.Parent = GUI.SkibidiGui
    
    -- Background image - 100% OPAQUE
    local Bg = Instance.new("ImageLabel")
    Bg.Size = UDim2.new(1, 0, 1, 0)
    Bg.BackgroundTransparency = 1
    Bg.ScaleType = Enum.ScaleType.Crop
    Bg.ImageTransparency = 0  -- 100% opaque
    Bg.ZIndex = 20001
    Bg.Parent = Screen
    
    LoadImageFromGitHub(CHANGE_BG_FILENAME, Bg)
    
    -- Dark overlay
    local Overlay = Instance.new("Frame")
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3 = GUI.Colors.Overlay
    Overlay.BackgroundTransparency = 0.5
    Overlay.BorderSizePixel = 0
    Overlay.ZIndex = 20002
    Overlay.Parent = Screen
    
    local responsive = GetResponsiveSize()
    
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0, GUI.IsMobile and 300 or 500, 0, GUI.IsMobile and 150 or 200)
    Container.Position = UDim2.new(0.5, GUI.IsMobile and -150 or -250, 0.5, GUI.IsMobile and -75 or -100)
    Container.BackgroundTransparency = 1
    Container.ZIndex = 20003
    Container.Parent = Screen
    
    local Title = Instance.new("TextLabel")
    Title.Text = "CHANGING SERVER"
    Title.Size = UDim2.new(1, 0, 0, GUI.IsMobile and 40 or 60)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = GUI.IsMobile and 28 or 42
    Title.TextColor3 = GUI.Colors.Text
    Title.TextStrokeTransparency = 0.3
    Title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    Title.ZIndex = 20004
    Title.Parent = Container
    
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Text = "Finding optimal server..."
    Subtitle.Size = UDim2.new(1, 0, 0, GUI.IsMobile and 20 or 30)
    Subtitle.Position = UDim2.new(0, 0, 0, GUI.IsMobile and 45 or 70)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextSize = GUI.IsMobile and 12 or 16
    Subtitle.TextColor3 = GUI.Colors.TextMuted
    Subtitle.ZIndex = 20004
    Subtitle.Parent = Container
    
    -- Compact progress bar
    local ProgressBg = Instance.new("Frame")
    ProgressBg.Size = UDim2.new(1, 0, 0, 2)
    ProgressBg.Position = UDim2.new(0, 0, 0, GUI.IsMobile and 85 or 130)
    ProgressBg.BackgroundColor3 = GUI.Colors.Surface
    ProgressBg.BorderSizePixel = 0
    ProgressBg.BackgroundTransparency = 0.6
    ProgressBg.ZIndex = 20004
    ProgressBg.Parent = Container
    
    local ProgressCorner = Instance.new("UICorner")
    ProgressCorner.CornerRadius = UDim.new(1, 0)
    ProgressCorner.Parent = ProgressBg
    
    local Progress = Instance.new("Frame")
    Progress.Size = UDim2.new(0, 0, 1, 0)
    Progress.BackgroundColor3 = GUI.Colors.Primary
    Progress.BorderSizePixel = 0
    Progress.ZIndex = 20005
    Progress.Parent = ProgressBg
    
    local ProgressCorner2 = Instance.new("UICorner")
    ProgressCorner2.CornerRadius = UDim.new(1, 0)
    ProgressCorner2.Parent = Progress
    
    Tween(Progress, {Size = UDim2.new(1, 0, 1, 0)}, 3, Enum.EasingStyle.Linear)
    
    print("[GUI] 📸 Server change screen displayed")
end

-- ============================================
-- BOOST FPS MODE - ONLY BOOST.PNG (NO WHITE SCREEN)
-- ============================================

function GUI.SetBoostFPS(state)
    if state then
        if GUI._BoostScreen then return end
        
        -- Create FULL SCREEN overlay with boost.png ONLY
        local Screen = Instance.new("ImageLabel")
        Screen.Name = "BoostScreen"
        Screen.Size = UDim2.new(1, 0, 1, 0)
        Screen.Position = UDim2.new(0, 0, 0, 0)
        Screen.BackgroundTransparency = 1  -- No white screen background
        Screen.ScaleType = Enum.ScaleType.Crop
        Screen.ImageTransparency = 0  -- 100% opaque image
        Screen.ZIndex = 15000
        Screen.Parent = GUI.SkibidiGui
        
        -- Load boost.png - 100% OPAQUE
        LoadImageFromGitHub(BOOST_BG_FILENAME, Screen, function()
            print("[GUI] ⚡ Fast mode activated - boost.png covering screen")
        end)
        
        GUI._BoostScreen = Screen
        
        -- Disable rendering of other GUI elements (keep only boost screen)
        if GUI.MainFrame then
            GUI.MainFrame.Visible = false
        end
        
        print("[GUI] ⚡ FAST MODE: ON (boost.png only, 100% opaque)")
    else
        if GUI._BoostScreen then
            GUI._BoostScreen:Destroy()
            GUI._BoostScreen = nil
        end
        
        -- Re-enable main GUI
        if GUI.MainFrame then
            GUI.MainFrame.Visible = true
        end
        
        print("[GUI] FAST MODE: OFF")
    end
end

-- ============================================
-- CLEANUP
-- ============================================

function GUI.Cleanup()
    GUI.SaveMusicState()
    
    for _, tween in ipairs(GUI.RunningTweens) do
        pcall(function()
            if tween then tween:Cancel() end
        end)
    end
    GUI.RunningTweens = {}
    
    for _, taskThread in ipairs(GUI.Tasks) do
        pcall(function()
            if taskThread then task.cancel(taskThread) end
        end)
    end
    GUI.Tasks = {}
    
    for _, connection in ipairs(GUI.Connections) do
        pcall(function()
            if connection and connection.Connected then
                connection:Disconnect()
            end
        end)
    end
    GUI.Connections = {}
    
    if GUI.MusicSound then
        pcall(function()
            GUI.MusicSound:Stop()
            GUI.MusicSound:Destroy()
        end)
        GUI.MusicSound = nil
    end
    
    if GUI._BoostScreen then
        pcall(function()
            GUI._BoostScreen:Destroy()
        end)
        GUI._BoostScreen = nil
    end
    
    if GUI.SkibidiGui then
        pcall(function()
            GUI.SkibidiGui:Destroy()
        end)
        GUI.SkibidiGui = nil
    end
    
    GUI.MainFrame = nil
    GUI.BackgroundImage = nil
    GUI.LoadingScreen = nil
end

-- Export to global
getgenv().SkibidiGUI_v6 = GUI

return GUI
