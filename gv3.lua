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

-- Detect if mobile device
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

-- Configuration with organized workspace
local WORKSPACE_FOLDER = "cuackerdoing"
local ASSETS_FOLDER = WORKSPACE_FOLDER .. "/assets"
local IMAGES_FOLDER = ASSETS_FOLDER .. "/images"
local SOUNDS_FOLDER = ASSETS_FOLDER .. "/sounds"
local DATA_FOLDER = WORKSPACE_FOLDER .. "/data"

-- GitHub CDN for icons (using reliable icon sources)
local ICON_CDN = "https://raw.githubusercontent.com/Ryu-Dev-here/assetsfora/main/"

-- File paths
local MUSIC_FILENAME = "sound.mp3"
local BG_FILENAME = "backlua.png"
local LOADING_BG_FILENAME = "loading.png"
local CHANGE_BG_FILENAME = "change.png"
local BOOST_BG_FILENAME = "boost.png"
local TIME_FILENAME = "musictime.txt"

-- Asset URLs
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
        if not isfolder(folder) then
            makefolder(folder)
            print("[Workspace] Created folder: " .. folder)
        end
    end
    
    print("[Workspace] ✓ Workspace structure initialized")
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
-- WEB ICON LOADER (GitHub/CDN Icons)
-- ============================================

local WebIcons = {}
WebIcons.Cache = {}

-- Lucide Icons CDN (clean, modern SVG icons)
local LUCIDE_CDN = "https://api.iconify.design/lucide/"

function WebIcons.GetIconUrl(iconName)
    local iconMap = {
        -- Using Lucide icons as SVG
        target = ICON_CDN .. "target.png",
        status = ICON_CDN .. "activity.png",
        bounty = ICON_CDN .. "gem.png",
        time = ICON_CDN .. "clock.png",
        boost = ICON_CDN .. "zap.png",
        music = ICON_CDN .. "music.png",
        settings = ICON_CDN .. "settings.png",
        close = ICON_CDN .. "x.png"
    }
    
    return iconMap[iconName] or ICON_CDN .. iconName .. ".png"
end

function WebIcons.LoadIcon(parent, iconName, size, color)
    local imageLabel = Instance.new("ImageLabel")
    imageLabel.Size = UDim2.new(0, size, 0, size)
    imageLabel.BackgroundTransparency = 1
    imageLabel.ImageColor3 = color or GUI.Colors.Primary
    imageLabel.ScaleType = Enum.ScaleType.Fit
    imageLabel.Parent = parent
    
    local iconUrl = WebIcons.GetIconUrl(iconName)
    
    -- Try to load from GitHub
    local success, result = pcall(function()
        imageLabel.Image = iconUrl
    end)
    
    if not success then
        print("[WebIcons] Failed to load: " .. iconName)
        -- Create fallback icon
        local fallbackFrame = Instance.new("Frame")
        fallbackFrame.Size = UDim2.new(0.6, 0, 0.6, 0)
        fallbackFrame.Position = UDim2.new(0.2, 0, 0.2, 0)
        fallbackFrame.BackgroundColor3 = color or GUI.Colors.Primary
        fallbackFrame.BorderSizePixel = 0
        fallbackFrame.Parent = imageLabel
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0.3, 0)
        corner.Parent = fallbackFrame
    end
    
    return imageLabel
end

-- ============================================
-- RESPONSIVE SIZING
-- ============================================

local function GetResponsiveSize()
    local viewport = workspace.CurrentCamera.ViewportSize
    local isMobile = GUI.IsMobile
    
    if isMobile then
        -- Mobile: smaller, more compact
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
        -- Desktop: larger, more spacious
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
-- IMAGE LOADING FROM GITHUB
-- ============================================

local function LoadImageFromGitHub(filename, imageLabel, callback)
    if not imageLabel or not imageLabel.Parent then
        return
    end
    
    local url = ICON_CDN .. filename
    
    local success, result = pcall(function()
        imageLabel.Image = url
        
        if callback then
            task.spawn(callback)
        end
    end)
    
    if not success then
        print("[ImageLoader] Failed: " .. filename)
        if callback then
            task.spawn(callback)
        end
    end
end

-- ============================================
-- MUSIC SYSTEM
-- ============================================

function GUI.InitAssets()
    InitWorkspace()
    
    -- Load background music
    task.spawn(function()
        if not GUI.Config.MusicEnabled then return end
        
        local success = pcall(function()
            if isfile(MUSIC_PATH) then
                if GUI.MusicSound then
                    GUI.MusicSound:Stop()
                    GUI.MusicSound:Destroy()
                end
                
                GUI.MusicSound = Instance.new("Sound")
                GUI.MusicSound.SoundId = getcustomasset(MUSIC_PATH)
                GUI.MusicSound.Volume = GUI.Config.MusicVolume
                GUI.MusicSound.Looped = true
                GUI.MusicSound.Parent = SoundService
                
                local savedTime = GUI.LoadMusicState()
                if savedTime then
                    GUI.MusicSound.TimePosition = savedTime
                end
                
                GUI.MusicSound:Play()
                print("[Music] ♪ Background music loaded")
                
                GUI.AddTask(task.spawn(function()
                    while GUI.MusicSound and GUI.MusicSound.Parent do
                        task.wait(5)
                        GUI.SaveMusicState()
                    end
                end))
            else
                print("[Music] File not found, downloading...")
                local musicData = game:HttpGet(ICON_CDN .. MUSIC_FILENAME, true)
                writefile(MUSIC_PATH, musicData)
                GUI.InitAssets()
            end
        end)
        
        if not success then
            print("[Music] Failed to load background music")
        end
    end)
    
    -- Load background images
    if GUI.BackgroundImage then
        LoadImageFromGitHub(BG_FILENAME, GUI.BackgroundImage)
    end
end

function GUI.SaveMusicState()
    if GUI.MusicSound and GUI.MusicSound.Parent then
        local currentTime = GUI.MusicSound.TimePosition
        writefile(TIME_PATH, tostring(currentTime))
    end
end

function GUI.LoadMusicState()
    if isfile(TIME_PATH) then
        local timeStr = readfile(TIME_PATH)
        return tonumber(timeStr) or 0
    end
    return 0
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
    
    local Bg = Instance.new("ImageLabel")
    Bg.Size = UDim2.new(1, 0, 1, 0)
    Bg.BackgroundTransparency = 1
    Bg.ScaleType = Enum.ScaleType.Crop
    Bg.ImageTransparency = 0.85
    Bg.ZIndex = 10001
    Bg.Parent = Screen
    
    LoadImageFromGitHub(LOADING_BG_FILENAME, Bg)
    
    local Overlay = Instance.new("Frame")
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3 = GUI.Colors.Overlay
    Overlay.BackgroundTransparency = 0.3
    Overlay.BorderSizePixel = 0
    Overlay.ZIndex = 10002
    Overlay.Parent = Screen
    
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0, 400, 0, 200)
    Container.Position = UDim2.new(0.5, -200, 0.5, -100)
    Container.BackgroundTransparency = 1
    Container.ZIndex = 10003
    Container.Parent = Screen
    
    -- BOLD Title
    local Title = Instance.new("TextLabel")
    Title.Text = "SKIBIDI AUTO FARM"
    Title.Size = UDim2.new(1, 0, 0, 60)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 36
    Title.TextColor3 = GUI.Colors.Primary
    Title.TextStrokeTransparency = 0.5
    Title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    Title.ZIndex = 10004
    Title.Parent = Container
    
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Text = "Initializing..."
    Subtitle.Size = UDim2.new(1, 0, 0, 30)
    Subtitle.Position = UDim2.new(0, 0, 0, 70)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Font = Enum.Font.GothamMedium
    Subtitle.TextSize = 16
    Subtitle.TextColor3 = GUI.Colors.TextMuted
    Subtitle.ZIndex = 10004
    Subtitle.Parent = Container
    
    -- Compact progress bar
    local ProgressBg = Instance.new("Frame")
    ProgressBg.Size = UDim2.new(1, 0, 0, 2)
    ProgressBg.Position = UDim2.new(0, 0, 0, 120)
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
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Text = "Loading assets..."
    StatusLabel.Size = UDim2.new(1, 0, 0, 20)
    StatusLabel.Position = UDim2.new(0, 0, 0, 140)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextSize = 13
    StatusLabel.TextColor3 = GUI.Colors.TextMuted
    StatusLabel.ZIndex = 10004
    StatusLabel.Parent = Container
    
    GUI.LoadingScreen = Screen
    
    local steps = {
        {text = "Loading workspace...", duration = 0.3},
        {text = "Initializing security...", duration = 0.4},
        {text = "Loading assets...", duration = 0.5},
        {text = "Preparing GUI...", duration = 0.4},
        {text = "Ready!", duration = 0.4}
    }
    
    task.spawn(function()
        local totalProgress = 0
        for i, step in ipairs(steps) do
            StatusLabel.Text = step.text
            local targetProgress = i / #steps
            Tween(Progress, {Size = UDim2.new(targetProgress, 0, 1, 0)}, step.duration, Enum.EasingStyle.Quart)
            task.wait(step.duration)
        end
        
        task.wait(0.5)
        
        Tween(Screen, {BackgroundTransparency = 1}, 0.5)
        Tween(Bg, {ImageTransparency = 1}, 0.5)
        Tween(Overlay, {BackgroundTransparency = 1}, 0.5)
        Tween(Title, {TextTransparency = 1}, 0.5)
        Tween(Subtitle, {TextTransparency = 1}, 0.5)
        Tween(StatusLabel, {TextTransparency = 1}, 0.5)
        Tween(ProgressBg, {BackgroundTransparency = 1}, 0.5, nil, nil, function()
            if Screen and Screen.Parent then
                Screen:Destroy()
            end
            GUI.LoadingScreen = nil
        end)
    end)
    
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
    screenGui.Parent = CoreGui
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
    
    -- Background image
    local bgImage = Instance.new("ImageLabel")
    bgImage.Size = UDim2.new(1, 0, 1, 0)
    bgImage.BackgroundTransparency = 1
    bgImage.ScaleType = Enum.ScaleType.Crop
    bgImage.ImageTransparency = 0.85
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
    
    -- Header with BOLD title
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, GUI.IsMobile and 50 or 60)
    header.BackgroundColor3 = GUI.Colors.Surface
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 16)
    headerCorner.Parent = header
    
    -- BOLD title text
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
    
    -- Tab system
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, 0, 0, responsive.buttonHeight)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = content
    
    local tabListLayout = Instance.new("UIListLayout")
    tabListLayout.FillDirection = Enum.FillDirection.Horizontal
    tabListLayout.Padding = UDim.new(0, GUI.IsMobile and 5 : 10)
    tabListLayout.Parent = tabContainer
    
    local tabs = {"Main", "Stats", "Settings"}
    local tabButtons = {}
    local activeTab = "Main"
    
    -- Create tab buttons
    for i, tabName in ipairs(tabs) do
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = tabName .. "Tab"
        tabBtn.Size = UDim2.new(0, GUI.IsMobile and 85 or 120, 1, 0)
        tabBtn.BackgroundColor3 = tabName == "Main" and GUI.Colors.Primary or GUI.Colors.Surface
        tabBtn.Text = tabName
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.TextSize = responsive.fontSize.button
        tabBtn.TextColor3 = GUI.Colors.Text
        tabBtn.BorderSizePixel = 0
        tabBtn.Parent = tabContainer
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 8)
        tabCorner.Parent = tabBtn
        
        tabButtons[tabName] = tabBtn
        
        tabBtn.MouseButton1Click:Connect(function()
            for name, btn in pairs(tabButtons) do
                Tween(btn, {BackgroundColor3 = GUI.Colors.Surface}, 0.2)
            end
            Tween(tabBtn, {BackgroundColor3 = GUI.Colors.Primary}, 0.2)
            activeTab = tabName
            
            -- Hide all panels
            for _, child in ipairs(content:GetChildren()) do
                if child:IsA("Frame") and child.Name:find("Panel") then
                    child.Visible = false
                end
            end
            
            -- Show selected panel
            local panel = content:FindFirstChild(tabName .. "Panel")
            if panel then
                panel.Visible = true
            end
        end)
    end
    
    -- Panel container
    local panelContainer = Instance.new("Frame")
    panelContainer.Name = "PanelContainer"
    panelContainer.Size = UDim2.new(1, 0, 1, -(responsive.buttonHeight + 10))
    panelContainer.Position = UDim2.new(0, 0, 0, responsive.buttonHeight + 10)
    panelContainer.BackgroundTransparency = 1
    panelContainer.Parent = content
    
    -- MAIN PANEL
    local mainPanel = Instance.new("ScrollingFrame")
    mainPanel.Name = "MainPanel"
    mainPanel.Size = UDim2.new(1, 0, 1, 0)
    mainPanel.BackgroundTransparency = 1
    mainPanel.BorderSizePixel = 0
    mainPanel.ScrollBarThickness = 4
    mainPanel.ScrollBarImageColor3 = GUI.Colors.Primary
    mainPanel.CanvasSize = UDim2.new(0, 0, 0, GUI.IsMobile and 800 or 600)
    mainPanel.Parent = panelContainer
    
    local mainLayout = Instance.new("UIListLayout")
    mainLayout.Padding = UDim.new(0, GUI.IsMobile and 8 or 12)
    mainLayout.Parent = mainPanel
    
    -- Control variables table
    local vars = {}
    
    -- Target display - BOLD
    local targetFrame = Instance.new("Frame")
    targetFrame.Name = "TargetFrame"
    targetFrame.Size = UDim2.new(1, 0, 0, GUI.IsMobile and 60 or 70)
    targetFrame.BackgroundColor3 = GUI.Colors.Surface
    targetFrame.BorderSizePixel = 0
    targetFrame.Parent = mainPanel
    
    local targetCorner = Instance.new("UICorner")
    targetCorner.CornerRadius = UDim.new(0, 10)
    targetCorner.Parent = targetFrame
    
    local targetIcon = WebIcons.LoadIcon(targetFrame, "target", GUI.IsMobile and 24 or 32, GUI.Colors.Primary)
    targetIcon.Position = UDim2.new(0, 15, 0.5, GUI.IsMobile and -12 or -16)
    
    local targetTitle = Instance.new("TextLabel")
    targetTitle.Text = "CURRENT TARGET"
    targetTitle.Size = UDim2.new(1, -60, 0, GUI.IsMobile and 18 or 20)
    targetTitle.Position = UDim2.new(0, GUI.IsMobile and 50 or 60, 0, 8)
    targetTitle.BackgroundTransparency = 1
    targetTitle.Font = Enum.Font.GothamBold
    targetTitle.TextSize = responsive.fontSize.label
    targetTitle.TextColor3 = GUI.Colors.TextMuted
    targetTitle.TextXAlignment = Enum.TextXAlignment.Left
    targetTitle.Parent = targetFrame
    
    local targetLabel = Instance.new("TextLabel")
    targetLabel.Text = "Searching..."
    targetLabel.Size = UDim2.new(1, -60, 0, GUI.IsMobile and 24 or 28)
    targetLabel.Position = UDim2.new(0, GUI.IsMobile and 50 or 60, 0, GUI.IsMobile and 30 or 35)
    targetLabel.BackgroundTransparency = 1
    targetLabel.Font = Enum.Font.GothamBold
    targetLabel.TextSize = responsive.fontSize.button
    targetLabel.TextColor3 = GUI.Colors.Text
    targetLabel.TextXAlignment = Enum.TextXAlignment.Left
    targetLabel.Parent = targetFrame
    vars.TargetLabel = targetLabel
    
    -- Status display - BOLD
    local statusFrame = Instance.new("Frame")
    statusFrame.Name = "StatusFrame"
    statusFrame.Size = UDim2.new(1, 0, 0, GUI.IsMobile and 60 or 70)
    statusFrame.BackgroundColor3 = GUI.Colors.Surface
    statusFrame.BorderSizePixel = 0
    statusFrame.Parent = mainPanel
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 10)
    statusCorner.Parent = statusFrame
    
    local statusIcon = WebIcons.LoadIcon(statusFrame, "status", GUI.IsMobile and 24 or 32, GUI.Colors.Success)
    statusIcon.Position = UDim2.new(0, 15, 0.5, GUI.IsMobile and -12 or -16)
    
    local statusTitle = Instance.new("TextLabel")
    statusTitle.Text = "STATUS"
    statusTitle.Size = UDim2.new(1, -60, 0, GUI.IsMobile and 18 or 20)
    statusTitle.Position = UDim2.new(0, GUI.IsMobile and 50 or 60, 0, 8)
    statusTitle.BackgroundTransparency = 1
    statusTitle.Font = Enum.Font.GothamBold
    statusTitle.TextSize = responsive.fontSize.label
    statusTitle.TextColor3 = GUI.Colors.TextMuted
    statusTitle.TextXAlignment = Enum.TextXAlignment.Left
    statusTitle.Parent = statusFrame
    
    local stateLabel = Instance.new("TextLabel")
    stateLabel.Text = "Idle"
    stateLabel.Size = UDim2.new(1, -60, 0, GUI.IsMobile and 24 or 28)
    stateLabel.Position = UDim2.new(0, GUI.IsMobile and 50 or 60, 0, GUI.IsMobile and 30 or 35)
    stateLabel.BackgroundTransparency = 1
    stateLabel.Font = Enum.Font.GothamBold
    stateLabel.TextSize = responsive.fontSize.button
    stateLabel.TextColor3 = GUI.Colors.Success
    stateLabel.TextXAlignment = Enum.TextXAlignment.Left
    stateLabel.Parent = statusFrame
    vars.StateLabel = stateLabel
    
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
    
    CreateButton("🎯 Start Auto Farm", GUI.Colors.Success, function()
        if getgenv().AutoFarmEnabled then
            getgenv().AutoFarmEnabled = false
            print("[GUI] Auto Farm stopped")
        else
            getgenv().AutoFarmEnabled = true
            print("[GUI] Auto Farm started")
        end
    end)
    
    CreateButton("⚡ Toggle Fast Mode", GUI.Colors.Warning, function()
        GUI.Config.FastMode = not GUI.Config.FastMode
        GUI.SetBoostFPS(GUI.Config.FastMode)
        print("[GUI] Fast Mode: " .. tostring(GUI.Config.FastMode))
    end)
    
    CreateButton("🔄 Server Hop", GUI.Colors.Primary, function()
        if getgenv().ServerHop then
            getgenv().ServerHop()
        end
    end)
    
    -- STATS PANEL - COMPACT VERSION
    local statsPanel = Instance.new("ScrollingFrame")
    statsPanel.Name = "StatsPanel"
    statsPanel.Size = UDim2.new(1, 0, 1, 0)
    statsPanel.BackgroundTransparency = 1
    statsPanel.BorderSizePixel = 0
    statsPanel.ScrollBarThickness = 4
    statsPanel.ScrollBarImageColor3 = GUI.Colors.Primary
    statsPanel.CanvasSize = UDim2.new(0, 0, 0, GUI.IsMobile and 500 : 400)
    statsPanel.Visible = false
    statsPanel.Parent = panelContainer
    
    local statsLayout = Instance.new("UIListLayout")
    statsLayout.Padding = UDim.new(0, GUI.IsMobile and 6 or 8)
    statsLayout.Parent = statsPanel
    
    -- BOLD Stats title
    local statsTitle = Instance.new("TextLabel")
    statsTitle.Text = "📊 SESSION STATISTICS"
    statsTitle.Size = UDim2.new(1, 0, 0, GUI.IsMobile and 35 or 40)
    statsTitle.BackgroundTransparency = 1
    statsTitle.Font = Enum.Font.GothamBold
    statsTitle.TextSize = responsive.fontSize.title - 4
    statsTitle.TextColor3 = GUI.Colors.Text
    statsTitle.TextXAlignment = Enum.TextXAlignment.Left
    statsTitle.TextStrokeTransparency = 0.7
    statsTitle.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    statsTitle.Parent = statsPanel
    
    local function CreateCompactStat(iconName, labelText, valueText, color)
        local statFrame = Instance.new("Frame")
        statFrame.Size = UDim2.new(1, 0, 0, GUI.IsMobile and 45 or 50)
        statFrame.BackgroundColor3 = GUI.Colors.Surface
        statFrame.BorderSizePixel = 0
        statFrame.Parent = statsPanel
        
        local statCorner = Instance.new("UICorner")
        statCorner.CornerRadius = UDim.new(0, 8)
        statCorner.Parent = statFrame
        
        local icon = WebIcons.LoadIcon(statFrame, iconName, GUI.IsMobile and 20 or 24, color)
        icon.Position = UDim2.new(0, 12, 0.5, GUI.IsMobile and -10 or -12)
        
        local label = Instance.new("TextLabel")
        label.Text = labelText
        label.Size = UDim2.new(0.5, -50, 1, 0)
        label.Position = UDim2.new(0, GUI.IsMobile and 40 or 48, 0, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamMedium
        label.TextSize = GUI.IsMobile and 11 or 13
        label.TextColor3 = GUI.Colors.TextMuted
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = statFrame
        
        local value = Instance.new("TextLabel")
        value.Text = valueText
        value.Size = UDim2.new(0.5, -20, 1, 0)
        value.Position = UDim2.new(0.5, 0, 0, 0)
        value.BackgroundTransparency = 1
        value.Font = Enum.Font.GothamBold
        value.TextSize = GUI.IsMobile and 14 or 16
        value.TextColor3 = color
        value.TextXAlignment = Enum.TextXAlignment.Right
        value.Parent = statFrame
        
        return value
    end
    
    -- Compact stat displays
    local bountyValue = CreateCompactStat("bounty", "Bounty Gained", "0", GUI.Colors.Warning)
    local killsValue = CreateCompactStat("target", "Total Kills", "0", GUI.Colors.Error)
    local timeValue = CreateCompactStat("time", "Session Time", "0:00", GUI.Colors.Primary)
    local fpsValue = CreateCompactStat("boost", "FPS", "60", GUI.Colors.Success)
    
    vars.BountyValue = bountyValue
    vars.KillsValue = killsValue
    vars.TimeValue = timeValue
    vars.FPSValue = fpsValue
    
    -- Update stats loop
    GUI.AddTask(task.spawn(function()
        while GUI.SkibidiGui and GUI.SkibidiGui.Parent do
            local sessionTime = math.floor(tick() - GUI.SessionStartTime)
            local minutes = math.floor(sessionTime / 60)
            local seconds = sessionTime % 60
            timeValue.Text = string.format("%d:%02d", minutes, seconds)
            
            local fps = math.floor(1 / RunService.RenderStepped:Wait())
            fpsValue.Text = tostring(fps)
            
            if getgenv().GetCurrentBounty and getgenv().InitialBounty then
                local current = getgenv().GetCurrentBounty()
                local initial = getgenv().InitialBounty or 0
                bountyValue.Text = tostring(current - initial)
            end
            
            if getgenv().TotalKills then
                killsValue.Text = tostring(getgenv().TotalKills or 0)
            end
            
            task.wait(1)
        end
    end))
    
    -- SETTINGS PANEL
    local settingsPanel = Instance.new("ScrollingFrame")
    settingsPanel.Name = "SettingsPanel"
    settingsPanel.Size = UDim2.new(1, 0, 1, 0)
    settingsPanel.BackgroundTransparency = 1
    settingsPanel.BorderSizePixel = 0
    settingsPanel.ScrollBarThickness = 4
    settingsPanel.ScrollBarImageColor3 = GUI.Colors.Primary
    settingsPanel.CanvasSize = UDim2.new(0, 0, 0, GUI.IsMobile and 400 or 300)
    settingsPanel.Visible = false
    settingsPanel.Parent = panelContainer
    
    local settingsLayout = Instance.new("UIListLayout")
    settingsLayout.Padding = UDim.new(0, GUI.IsMobile and 8 or 12)
    settingsLayout.Parent = settingsPanel
    
    -- BOLD Settings title
    local settingsTitle = Instance.new("TextLabel")
    settingsTitle.Text = "⚙️ SETTINGS"
    settingsTitle.Size = UDim2.new(1, 0, 0, GUI.IsMobile and 35 or 40)
    settingsTitle.BackgroundTransparency = 1
    settingsTitle.Font = Enum.Font.GothamBold
    settingsTitle.TextSize = responsive.fontSize.title - 4
    settingsTitle.TextColor3 = GUI.Colors.Text
    settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
    settingsTitle.TextStrokeTransparency = 0.7
    settingsTitle.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    settingsTitle.Parent = settingsPanel
    
    local function CreateToggle(labelText, defaultState, callback)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Size = UDim2.new(1, 0, 0, responsive.buttonHeight)
        toggleFrame.BackgroundColor3 = GUI.Colors.Surface
        toggleFrame.BorderSizePixel = 0
        toggleFrame.Parent = settingsPanel
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 8)
        toggleCorner.Parent = toggleFrame
        
        local label = Instance.new("TextLabel")
        label.Text = labelText
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.Position = UDim2.new(0, 15, 0, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamMedium
        label.TextSize = responsive.fontSize.button - 2
        label.TextColor3 = GUI.Colors.Text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = toggleFrame
        
        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Size = UDim2.new(0, GUI.IsMobile and 50 or 60, 0, GUI.IsMobile and 26 or 30)
        toggleBtn.Position = UDim2.new(1, -(GUI.IsMobile and 60 or 70), 0.5, -(GUI.IsMobile and 13 or 15))
        toggleBtn.BackgroundColor3 = defaultState and GUI.Colors.Success or GUI.Colors.Surface
        toggleBtn.Text = ""
        toggleBtn.BorderSizePixel = 0
        toggleBtn.Parent = toggleFrame
        
        local toggleCorner2 = Instance.new("UICorner")
        toggleCorner2.CornerRadius = UDim.new(1, 0)
        toggleCorner2.Parent = toggleBtn
        
        local toggleIndicator = Instance.new("Frame")
        toggleIndicator.Size = UDim2.new(0, GUI.IsMobile and 20 or 24, 0, GUI.IsMobile and 20 or 24)
        toggleIndicator.Position = defaultState and UDim2.new(1, -(GUI.IsMobile and 23 or 27), 0.5, -(GUI.IsMobile and 10 or 12)) or UDim2.new(0, 3, 0.5, -(GUI.IsMobile and 10 or 12))
        toggleIndicator.BackgroundColor3 = GUI.Colors.Text
        toggleIndicator.BorderSizePixel = 0
        toggleIndicator.Parent = toggleBtn
        
        local indicatorCorner = Instance.new("UICorner")
        indicatorCorner.CornerRadius = UDim.new(1, 0)
        indicatorCorner.Parent = toggleIndicator
        
        local state = defaultState
        
        toggleBtn.MouseButton1Click:Connect(function()
            state = not state
            
            Tween(toggleBtn, {BackgroundColor3 = state and GUI.Colors.Success or GUI.Colors.Surface}, 0.2)
            Tween(toggleIndicator, {
                Position = state and UDim2.new(1, -(GUI.IsMobile and 23 or 27), 0.5, -(GUI.IsMobile and 10 or 12)) or UDim2.new(0, 3, 0.5, -(GUI.IsMobile and 10 or 12))
            }, 0.2)
            
            if callback then
                callback(state)
            end
        end)
        
        return toggleBtn
    end
    
    CreateToggle("🎵 Background Music", GUI.Config.MusicEnabled, function(state)
        GUI.Config.MusicEnabled = state
        if GUI.MusicSound then
            if state then
                GUI.MusicSound:Play()
            else
                GUI.MusicSound:Pause()
            end
        end
    end)
    
    CreateToggle("📡 Insta Teleport", GUI.Config.InstaTeleportEnabled, function(state)
        GUI.Config.InstaTeleportEnabled = state
        if getgenv().InstaTeleportEnabled ~= nil then
            getgenv().InstaTeleportEnabled = state
        end
    end)
    
    CreateToggle("🛡️ Anti-Ragdoll", GUI.Config.AntiRagdollEnabled, function(state)
        GUI.Config.AntiRagdollEnabled = state
        if getgenv().AntiRagdollEnabled ~= nil then
            getgenv().AntiRagdollEnabled = state
        end
    end)
    
    CreateToggle("💥 Fruit Attack", GUI.Config.FruitAttackEnabled, function(state)
        GUI.Config.FruitAttackEnabled = state
        if getgenv().FruitAttackEnabled ~= nil then
            getgenv().FruitAttackEnabled = state
        end
    end)
    
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
-- SERVER HOP SCREEN
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
    
    local Bg = Instance.new("ImageLabel")
    Bg.Size = UDim2.new(1, 0, 1, 0)
    Bg.BackgroundTransparency = 1
    Bg.ScaleType = Enum.ScaleType.Crop
    Bg.ImageTransparency = 0.85
    Bg.ZIndex = 20001
    Bg.Parent = Screen
    
    LoadImageFromGitHub(CHANGE_BG_FILENAME, Bg, function()
        Tween(Bg, {ImageTransparency = 0.15}, 1)
    end)
    
    local Overlay = Instance.new("Frame")
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3 = GUI.Colors.Overlay
    Overlay.BackgroundTransparency = 0.3
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
    Title.TextTransparency = 1
    Title.TextStrokeTransparency = 0.5
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
    Subtitle.TextTransparency = 1
    Subtitle.ZIndex = 20004
    Subtitle.Parent = Container
    
    local ProgressBg = Instance.new("Frame")
    ProgressBg.Size = UDim2.new(1, 0, 0, 2)
    ProgressBg.Position = UDim2.new(0, 0, 0, GUI.IsMobile and 85 or 130)
    ProgressBg.BackgroundColor3 = GUI.Colors.Surface
    ProgressBg.BorderSizePixel = 0
    ProgressBg.BackgroundTransparency = 1
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
    
    Tween(Title, {TextTransparency = 0}, 0.6)
    task.wait(0.1)
    Tween(Subtitle, {TextTransparency = 0}, 0.6)
    task.wait(0.1)
    Tween(ProgressBg, {BackgroundTransparency = 0.6}, 0.6)
    
    Tween(Progress, {Size = UDim2.new(1, 0, 1, 0)}, 3, Enum.EasingStyle.Linear)
    
    GUI.AddTask(task.spawn(function()
        while Screen and Screen.Parent do
            Tween(Title, {TextTransparency = 0.3}, 1.2, Enum.EasingStyle.Sine)
            task.wait(1.2)
            if not Screen or not Screen.Parent then break end
            Tween(Title, {TextTransparency = 0}, 1.2, Enum.EasingStyle.Sine)
            task.wait(1.2)
        end
    end))
end

-- ============================================
-- BOOST FPS MODE - FULL SCREEN FIX
-- ============================================

function GUI.SetBoostFPS(state)
    if state then
        if GUI._BoostScreen then return end
        
        -- Create FULL SCREEN overlay with boost.png
        local Screen = Instance.new("ImageLabel")
        Screen.Name = "BoostScreen"
        Screen.Size = UDim2.new(1, 0, 1, 0)
        Screen.Position = UDim2.new(0, 0, 0, 0)
        Screen.BackgroundTransparency = 1
        Screen.ScaleType = Enum.ScaleType.Crop
        Screen.ImageTransparency = 0
        Screen.ZIndex = 15000
        Screen.Parent = GUI.SkibidiGui
        
        -- Load boost background - FULL SCREEN
        LoadImageFromGitHub(BOOST_BG_FILENAME, Screen, function()
            print("[GUI] ✓ Boost screen covering full screen")
        end)
        
        GUI._BoostScreen = Screen
        print("[GUI] ⚡ Boost FPS Mode activated - Full screen overlay")
    else
        if GUI._BoostScreen then
            GUI._BoostScreen:Destroy()
            GUI._BoostScreen = nil
            print("[GUI] Boost FPS Mode deactivated")
        end
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

return GUI
