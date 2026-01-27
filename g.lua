-- ============================================
-- PREMIUM SKIBIDI GUI v5.0
-- Ultra-clean, modern, professional design
-- Custom SVG icons, smooth animations, dual-panel layout
-- ============================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

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

-- Modern color palette - Dark theme with electric blue accents
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

-- Configuration
local WORKSPACE_FOLDER = "cuackerdoing"
local MUSIC_FILENAME = "sound.mp3"
local BG_FILENAME = "backlua.png"
local TIME_FILENAME = "musictime.txt"
local MUSIC_PATH = WORKSPACE_FOLDER .. "/" .. MUSIC_FILENAME
local BG_PATH = WORKSPACE_FOLDER .. "/" .. BG_FILENAME
local TIME_PATH = WORKSPACE_FOLDER .. "/" .. TIME_FILENAME
local ASSETS_REPO = "https://raw.githubusercontent.com/Ryu-Dev-here/assetsfora/main/"

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

-- Premium smooth tweening
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
-- CUSTOM SVG ICON SYSTEM
-- ============================================

local Icons = {}

function Icons.Create(parent, iconType, size, color)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, size, 0, size)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local canvas = Instance.new("Frame")
    canvas.Size = UDim2.new(1, 0, 1, 0)
    canvas.BackgroundTransparency = 1
    canvas.Parent = frame
    
    color = color or GUI.Colors.Primary
    
    if iconType == "target" then
        -- Crosshair icon
        local h = Instance.new("Frame")
        h.Size = UDim2.new(0.7, 0, 0, 2)
        h.Position = UDim2.new(0.15, 0, 0.5, -1)
        h.BackgroundColor3 = color
        h.BorderSizePixel = 0
        h.Parent = canvas
        
        local v = Instance.new("Frame")
        v.Size = UDim2.new(0, 2, 0.7, 0)
        v.Position = UDim2.new(0.5, -1, 0.15, 0)
        v.BackgroundColor3 = color
        v.BorderSizePixel = 0
        v.Parent = canvas
        
        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0.5, 0, 0.5, 0)
        circle.Position = UDim2.new(0.25, 0, 0.25, 0)
        circle.BackgroundColor3 = color
        circle.BackgroundTransparency = 0.7
        circle.BorderSizePixel = 0
        circle.Parent = canvas
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = circle
        
    elseif iconType == "status" then
        -- Activity pulse icon
        for i = 1, 3 do
            local bar = Instance.new("Frame")
            bar.Size = UDim2.new(0, 3, 0.3 + (i * 0.15), 0)
            bar.Position = UDim2.new(0.2 + (i * 0.2), 0, 0.5, 0)
            bar.AnchorPoint = Vector2.new(0, 0.5)
            bar.BackgroundColor3 = color
            bar.BorderSizePixel = 0
            bar.Parent = canvas
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 2)
            corner.Parent = bar
        end
        
    elseif iconType == "bounty" then
        -- Diamond icon
        local top = Instance.new("Frame")
        top.Size = UDim2.new(0.6, 0, 0.3, 0)
        top.Position = UDim2.new(0.2, 0, 0.15, 0)
        top.BackgroundColor3 = color
        top.BorderSizePixel = 0
        top.Parent = canvas
        top.Rotation = 45
        
        local bottom = Instance.new("Frame")
        bottom.Size = UDim2.new(0.6, 0, 0.4, 0)
        bottom.Position = UDim2.new(0.2, 0, 0.45, 0)
        bottom.BackgroundColor3 = color
        bottom.BorderSizePixel = 0
        bottom.Parent = canvas
        bottom.Rotation = 45
        
    elseif iconType == "time" then
        -- Clock icon
        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0.8, 0, 0.8, 0)
        circle.Position = UDim2.new(0.1, 0, 0.1, 0)
        circle.BackgroundColor3 = color
        circle.BackgroundTransparency = 0.7
        circle.BorderSizePixel = 0
        circle.Parent = canvas
        
        local circleCorner = Instance.new("UICorner")
        circleCorner.CornerRadius = UDim.new(1, 0)
        circleCorner.Parent = circle
        
        local hourHand = Instance.new("Frame")
        hourHand.Size = UDim2.new(0, 2, 0.3, 0)
        hourHand.Position = UDim2.new(0.5, -1, 0.5, 0)
        hourHand.AnchorPoint = Vector2.new(0.5, 1)
        hourHand.BackgroundColor3 = color
        hourHand.BorderSizePixel = 0
        hourHand.Parent = canvas
        
        local corner1 = Instance.new("UICorner")
        corner1.CornerRadius = UDim.new(1, 0)
        corner1.Parent = hourHand
        
        local minuteHand = Instance.new("Frame")
        minuteHand.Size = UDim2.new(0, 2, 0.35, 0)
        minuteHand.Position = UDim2.new(0.5, -1, 0.5, 0)
        minuteHand.AnchorPoint = Vector2.new(0.5, 1)
        minuteHand.BackgroundColor3 = color
        minuteHand.BorderSizePixel = 0
        minuteHand.Rotation = 90
        minuteHand.Parent = canvas
        
        local corner2 = Instance.new("UICorner")
        corner2.CornerRadius = UDim.new(1, 0)
        corner2.Parent = minuteHand
        
    elseif iconType == "skull" then
        -- Skull icon (for eliminations)
        local head = Instance.new("Frame")
        head.Size = UDim2.new(0.6, 0, 0.5, 0)
        head.Position = UDim2.new(0.2, 0, 0.15, 0)
        head.BackgroundColor3 = color
        head.BorderSizePixel = 0
        head.Parent = canvas
        
        local headCorner = Instance.new("UICorner")
        headCorner.CornerRadius = UDim.new(0.3, 0)
        headCorner.Parent = head
        
        local jaw = Instance.new("Frame")
        jaw.Size = UDim2.new(0.45, 0, 0.25, 0)
        jaw.Position = UDim2.new(0.275, 0, 0.6, 0)
        jaw.BackgroundColor3 = color
        jaw.BorderSizePixel = 0
        jaw.Parent = canvas
        
        local jawCorner = Instance.new("UICorner")
        jawCorner.CornerRadius = UDim.new(0, 4)
        jawCorner.Parent = jaw
        
    elseif iconType == "zap" then
        -- Lightning bolt (for fast mode)
        local bolt = Instance.new("Frame")
        bolt.Size = UDim2.new(0.5, 0, 0.7, 0)
        bolt.Position = UDim2.new(0.25, 0, 0.15, 0)
        bolt.BackgroundColor3 = color
        bolt.BorderSizePixel = 0
        bolt.Rotation = 15
        bolt.Parent = canvas
        
        local cutout = Instance.new("Frame")
        cutout.Size = UDim2.new(0.6, 0, 0.3, 0)
        cutout.Position = UDim2.new(0.4, 0, 0.35, 0)
        cutout.BackgroundColor3 = GUI.Colors.Background
        cutout.BorderSizePixel = 0
        cutout.Parent = canvas
    end
    
    return frame
end

-- ============================================
-- MUSIC STATE MANAGEMENT
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

-- ============================================
-- PREMIUM LOADING SCREEN
-- ============================================

function GUI.CreateFullScreenLoader()
    local LoaderScreen = Instance.new("Frame")
    LoaderScreen.Name = "FullScreenLoader"
    LoaderScreen.Size = UDim2.new(1, 0, 1, 0)
    LoaderScreen.BackgroundColor3 = GUI.Colors.Background
    LoaderScreen.BorderSizePixel = 0
    LoaderScreen.ZIndex = 10000
    LoaderScreen.Parent = GUI.SkibidiGui
    
    -- Background image
    local Bg = Instance.new("ImageLabel")
    Bg.Size = UDim2.new(1, 0, 1, 0)
    Bg.BackgroundTransparency = 1
    Bg.ImageTransparency = 1
    Bg.ScaleType = Enum.ScaleType.Crop
    Bg.ZIndex = 10001
    Bg.Parent = LoaderScreen
    
    GUI.AddTask(task.spawn(function()
        local asset = getcustomasset or getsynasset
        if asset and isfile and writefile then
            local path = WORKSPACE_FOLDER.."/loading.png"
            if not isfile(path) then
                writefile(path, game:HttpGet(ASSETS_REPO.."loading.png", true))
            end
            Bg.Image = asset(path)
            Tween(Bg, {ImageTransparency = 0.1}, 1.2, Enum.EasingStyle.Sine)
        end
    end))
    
    -- Dark overlay
    local Overlay = Instance.new("Frame")
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3 = GUI.Colors.Overlay
    Overlay.BackgroundTransparency = 0.3
    Overlay.BorderSizePixel = 0
    Overlay.ZIndex = 10002
    Overlay.Parent = LoaderScreen
    
    -- Center container
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0, 600, 0, 400)
    Container.Position = UDim2.new(0.5, -300, 0.5, -200)
    Container.BackgroundTransparency = 1
    Container.ZIndex = 10003
    Container.Parent = LoaderScreen
    
    -- Logo
    local LogoText = Instance.new("TextLabel")
    LogoText.Text = "SKIBIDI"
    LogoText.Size = UDim2.new(1, 0, 0, 80)
    LogoText.BackgroundTransparency = 1
    LogoText.Font = Enum.Font.GothamBold
    LogoText.TextColor3 = GUI.Colors.Text
    LogoText.TextSize = 64
    LogoText.TextTransparency = 1
    LogoText.ZIndex = 10004
    LogoText.Parent = Container
    
    -- Subtitle
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Text = "ADVANCED AUTOMATION SYSTEM"
    Subtitle.Size = UDim2.new(1, 0, 0, 30)
    Subtitle.Position = UDim2.new(0, 0, 0, 85)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Font = Enum.Font.GothamMedium
    Subtitle.TextColor3 = GUI.Colors.TextMuted
    Subtitle.TextSize = 16
    Subtitle.TextTransparency = 1
    Subtitle.ZIndex = 10004
    Subtitle.Parent = Container
    
    -- Progress container
    local ProgressContainer = Instance.new("Frame")
    ProgressContainer.Size = UDim2.new(1, 0, 0, 6)
    ProgressContainer.Position = UDim2.new(0, 0, 0, 180)
    ProgressContainer.BackgroundColor3 = GUI.Colors.Surface
    ProgressContainer.BorderSizePixel = 0
    ProgressContainer.BackgroundTransparency = 1
    ProgressContainer.ZIndex = 10004
    ProgressContainer.Parent = Container
    
    local ProgressCorner = Instance.new("UICorner")
    ProgressCorner.CornerRadius = UDim.new(1, 0)
    ProgressCorner.Parent = ProgressContainer
    
    -- Progress bar
    local ProgressBar = Instance.new("Frame")
    ProgressBar.Size = UDim2.new(0, 0, 1, 0)
    ProgressBar.BackgroundColor3 = GUI.Colors.Primary
    ProgressBar.BorderSizePixel = 0
    ProgressBar.ZIndex = 10005
    ProgressBar.Parent = ProgressContainer
    
    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(1, 0)
    BarCorner.Parent = ProgressBar
    
    -- Glow effect
    local Glow = Instance.new("ImageLabel")
    Glow.Size = UDim2.new(1, 40, 1, 40)
    Glow.Position = UDim2.new(0, -20, 0, -20)
    Glow.BackgroundTransparency = 1
    Glow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    Glow.ImageColor3 = GUI.Colors.Primary
    Glow.ImageTransparency = 0.5
    Glow.ZIndex = 10004
    Glow.Parent = ProgressBar
    
    -- Status text
    local StatusText = Instance.new("TextLabel")
    StatusText.Text = "Initializing system..."
    StatusText.Size = UDim2.new(1, 0, 0, 25)
    StatusText.Position = UDim2.new(0, 0, 0, 210)
    StatusText.BackgroundTransparency = 1
    StatusText.Font = Enum.Font.Gotham
    StatusText.TextColor3 = GUI.Colors.TextMuted
    StatusText.TextSize = 15
    StatusText.TextTransparency = 1
    StatusText.ZIndex = 10004
    StatusText.Parent = Container
    
    -- Percentage
    local PercentText = Instance.new("TextLabel")
    PercentText.Text = "0%"
    PercentText.Size = UDim2.new(1, 0, 0, 50)
    PercentText.Position = UDim2.new(0, 0, 0, 250)
    PercentText.BackgroundTransparency = 1
    PercentText.Font = Enum.Font.GothamBold
    PercentText.TextColor3 = GUI.Colors.Primary
    PercentText.TextSize = 36
    PercentText.TextTransparency = 1
    PercentText.ZIndex = 10004
    PercentText.Parent = Container
    
    -- Fade in
    Tween(LogoText, {TextTransparency = 0}, 0.8)
    task.wait(0.15)
    Tween(Subtitle, {TextTransparency = 0}, 0.8)
    task.wait(0.15)
    Tween(ProgressContainer, {BackgroundTransparency = 0.6}, 0.8)
    Tween(StatusText, {TextTransparency = 0}, 0.8)
    Tween(PercentText, {TextTransparency = 0}, 0.8)
    
    GUI.LoadingScreen = LoaderScreen
    
    return {
        Screen = LoaderScreen,
        Bar = ProgressBar,
        Status = StatusText,
        Percent = PercentText,
        Update = function(progress, statusText)
            if StatusText and StatusText.Parent then
                StatusText.Text = statusText or "Loading..."
            end
            if PercentText and PercentText.Parent then
                PercentText.Text = math.floor(progress * 100) .. "%"
            end
            if ProgressBar and ProgressBar.Parent then
                Tween(ProgressBar, {Size = UDim2.new(progress, 0, 1, 0)}, 0.3)
            end
        end,
        Complete = function()
            if not LoaderScreen or not LoaderScreen.Parent then return end
            
            if StatusText and StatusText.Parent then
                StatusText.Text = "Launch ready"
            end
            if PercentText and PercentText.Parent then
                PercentText.Text = "100%"
            end
            
            task.wait(0.5)
            
            Tween(LoaderScreen, {BackgroundTransparency = 1}, 0.6)
            
            for _, child in pairs(LoaderScreen:GetDescendants()) do
                if child:IsA("TextLabel") or child:IsA("Frame") or child:IsA("ImageLabel") then
                    pcall(function()
                        if child.TextTransparency then
                            Tween(child, {TextTransparency = 1, BackgroundTransparency = 1}, 0.6)
                        elseif child.ImageTransparency then
                            Tween(child, {ImageTransparency = 1, BackgroundTransparency = 1}, 0.6)
                        else
                            Tween(child, {BackgroundTransparency = 1}, 0.6)
                        end
                    end)
                end
            end
            
            task.wait(0.7)
            
            if LoaderScreen and LoaderScreen.Parent then
                LoaderScreen:Destroy()
            end
            
            GUI.LoadingScreen = nil
        end
    }
end

-- ============================================
-- ASSET INITIALIZATION
-- ============================================

function GUI.InitAssets()
    local loader = GUI.CreateFullScreenLoader()
    if not loader then return end
    
    loader.Update(0.05, "Creating workspace...")
    
    pcall(function()
        if makefolder and not isfolder(WORKSPACE_FOLDER) then
            makefolder(WORKSPACE_FOLDER)
        end
    end)
    
    task.wait(0.3)
    loader.Update(0.15, "Initializing audio system...")
    
    local musicSuccess = pcall(function()
        GUI.MusicSound = Instance.new("Sound")
        GUI.MusicSound.Name = "SkibidiMusic"
        GUI.MusicSound.Looped = true
        GUI.MusicSound.Volume = GUI.Config.MusicVolume
        GUI.MusicSound.Parent = SoundService
    end)
    
    task.wait(0.2)
    loader.Update(0.25, "Loading audio files...")
    
    GUI.AddTask(task.spawn(function()
        task.wait(0.1)
        
        pcall(function()
            local asset = getcustomasset or getsynasset
            if not asset then
                loader.Update(0.5, "Audio system unavailable")
                return
            end
            
            if isfile and not isfile(MUSIC_PATH) then
                if writefile then
                    loader.Update(0.35, "Downloading audio...")
                    local httpSuccess, musicData = pcall(function()
                        return game:HttpGet(ASSETS_REPO .. MUSIC_FILENAME, true)
                    end)
                    
                    if httpSuccess and musicData then
                        writefile(MUSIC_PATH, musicData)
                    end
                end
            end
            
            if isfile and isfile(MUSIC_PATH) and GUI.MusicSound then
                local assetUrl = asset(MUSIC_PATH)
                GUI.MusicSound.SoundId = assetUrl
                
                if isfile(TIME_PATH) and readfile then
                    local savedTimeStr = readfile(TIME_PATH)
                    local savedTime = tonumber(savedTimeStr)
                    if savedTime and savedTime > 0 then
                        GUI.MusicSound.TimePosition = savedTime
                    end
                end
                
                GUI.MusicSound:Play()
                loader.Update(0.5, "Audio system ready")
            end
        end)
    end))
    
    task.wait(0.4)
    loader.Update(0.6, "Preparing interface...")
    
    local maxWait = 100
    local waited = 0
    while not GUI.BackgroundImage and waited < maxWait do
        task.wait(0.1)
        waited = waited + 1
    end
    
    if GUI.BackgroundImage then
        loader.Update(0.65, "Loading background...")
        
        GUI.AddTask(task.spawn(function()
            pcall(function()
                local asset = getcustomasset or getsynasset
                if not asset then
                    loader.Update(0.8, "Background unavailable")
                    return
                end
                
                if isfile and not isfile(BG_PATH) then
                    if writefile then
                        loader.Update(0.7, "Downloading background...")
                        local httpSuccess, bgData = pcall(function()
                            return game:HttpGet(ASSETS_REPO .. BG_FILENAME, true)
                        end)
                        
                        if httpSuccess and bgData then
                            writefile(BG_PATH, bgData)
                        end
                    end
                end
                
                if isfile and isfile(BG_PATH) and GUI.BackgroundImage and GUI.BackgroundImage.Parent then
                    local assetUrl = asset(BG_PATH)
                    GUI.BackgroundImage.Image = assetUrl
                    loader.Update(0.8, "Background ready")
                end
            end)
        end))
    end
    
    task.wait(0.5)
    loader.Update(0.9, "Finalizing...")
    task.wait(0.4)
    loader.Update(1, "Launch ready")
    task.wait(0.5)
    loader.Complete()
    
    local teleportConnection = Players.LocalPlayer.OnTeleport:Connect(function()
        GUI.SaveMusicState()
    end)
    GUI.AddConnection(teleportConnection)
end

-- ============================================
-- MAIN GUI INITIALIZATION
-- ============================================

function GUI.Init(vars)
    if GUI.SkibidiGui then
        GUI.Cleanup()
    end
    
    if not vars or type(vars) ~= "table" then
        vars = {}
    end
    
    local lp = Players.LocalPlayer
    if not lp then return nil end
    
    -- Create ScreenGui
    GUI.SkibidiGui = Instance.new("ScreenGui")
    GUI.SkibidiGui.Name = "SkibidiGui"
    GUI.SkibidiGui.ResetOnSpawn = false
    GUI.SkibidiGui.IgnoreGuiInset = true
    GUI.SkibidiGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local guiParented = pcall(function()
        GUI.SkibidiGui.Parent = CoreGui
    end)
    
    if not guiParented or not GUI.SkibidiGui.Parent then
        local playerGui = lp:WaitForChild("PlayerGui", 5)
        if playerGui then
            GUI.SkibidiGui.Parent = playerGui
        else
            return nil
        end
    end
    
    -- Main container (dual panel design)
    GUI.MainFrame = Instance.new("Frame")
    GUI.MainFrame.Name = "MainFrame"
    GUI.MainFrame.BackgroundColor3 = GUI.Colors.Background
    GUI.MainFrame.Position = UDim2.new(0.5, -450, 0.5, -300)
    GUI.MainFrame.Size = UDim2.new(0, 0, 0, 0)
    GUI.MainFrame.BorderSizePixel = 0
    GUI.MainFrame.ClipsDescendants = true
    GUI.MainFrame.Parent = GUI.SkibidiGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 20)
    MainCorner.Parent = GUI.MainFrame
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = GUI.Colors.Border
    MainStroke.Thickness = 1
    MainStroke.Transparency = 0.5
    MainStroke.Parent = GUI.MainFrame
    
    -- LEFT PANEL - Image Panel
    local LeftPanel = Instance.new("Frame")
    LeftPanel.Name = "LeftPanel"
    LeftPanel.Size = UDim2.new(0, 400, 1, 0)
    LeftPanel.BackgroundTransparency = 1
    LeftPanel.BorderSizePixel = 0
    LeftPanel.ClipsDescendants = true
    LeftPanel.Parent = GUI.MainFrame
    
    -- Background Image
    GUI.BackgroundImage = Instance.new("ImageLabel")
    GUI.BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
    GUI.BackgroundImage.BackgroundTransparency = 1
    GUI.BackgroundImage.ScaleType = Enum.ScaleType.Crop
    GUI.BackgroundImage.ImageTransparency = 0.15
    GUI.BackgroundImage.ZIndex = 1
    GUI.BackgroundImage.Parent = LeftPanel
    
    local BgCorner = Instance.new("UICorner")
    BgCorner.CornerRadius = UDim.new(0, 20)
    BgCorner.Parent = GUI.BackgroundImage
    
    -- Dark gradient overlay on image
    local ImageOverlay = Instance.new("Frame")
    ImageOverlay.Size = UDim2.new(1, 0, 1, 0)
    ImageOverlay.BackgroundColor3 = GUI.Colors.Overlay
    ImageOverlay.BackgroundTransparency = 0.4
    ImageOverlay.BorderSizePixel = 0
    ImageOverlay.ZIndex = 2
    ImageOverlay.Parent = LeftPanel
    
    local OverlayCorner = Instance.new("UICorner")
    OverlayCorner.CornerRadius = UDim.new(0, 20)
    OverlayCorner.Parent = ImageOverlay
    
    local OverlayGradient = Instance.new("UIGradient")
    OverlayGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(11, 14, 20))
    }
    OverlayGradient.Rotation = 90
    OverlayGradient.Parent = ImageOverlay
    
    -- Logo on left panel
    local LeftLogo = Instance.new("TextLabel")
    LeftLogo.Text = "SKIBIDI"
    LeftLogo.Size = UDim2.new(1, -40, 0, 60)
    LeftLogo.Position = UDim2.new(0, 20, 1, -80)
    LeftLogo.BackgroundTransparency = 1
    LeftLogo.Font = Enum.Font.GothamBold
    LeftLogo.TextColor3 = GUI.Colors.Text
    LeftLogo.TextSize = 42
    LeftLogo.TextXAlignment = Enum.TextXAlignment.Left
    LeftLogo.ZIndex = 3
    LeftLogo.Parent = LeftPanel
    
    -- Version badge
    local VersionBadge = Instance.new("Frame")
    VersionBadge.Size = UDim2.new(0, 65, 0, 28)
    VersionBadge.Position = UDim2.new(0, 20, 0, 20)
    VersionBadge.BackgroundColor3 = GUI.Colors.Primary
    VersionBadge.BackgroundTransparency = 0.1
    VersionBadge.BorderSizePixel = 0
    VersionBadge.ZIndex = 3
    VersionBadge.Parent = LeftPanel
    
    local BadgeCorner = Instance.new("UICorner")
    BadgeCorner.CornerRadius = UDim.new(0, 6)
    BadgeCorner.Parent = VersionBadge
    
    local BadgeText = Instance.new("TextLabel")
    BadgeText.Text = "v5.0"
    BadgeText.Size = UDim2.new(1, 0, 1, 0)
    BadgeText.BackgroundTransparency = 1
    BadgeText.Font = Enum.Font.GothamBold
    BadgeText.TextColor3 = GUI.Colors.Text
    BadgeText.TextSize = 13
    BadgeText.ZIndex = 4
    BadgeText.Parent = VersionBadge
    
    -- RIGHT PANEL - Stats Panel
    local RightPanel = Instance.new("Frame")
    RightPanel.Name = "RightPanel"
    RightPanel.Size = UDim2.new(0, 500, 1, 0)
    RightPanel.Position = UDim2.new(0, 400, 0, 0)
    RightPanel.BackgroundColor3 = GUI.Colors.Surface
    RightPanel.BorderSizePixel = 0
    RightPanel.Parent = GUI.MainFrame
    
    local RightCorner = Instance.new("UICorner")
    RightCorner.CornerRadius = UDim.new(0, 20)
    RightCorner.Parent = RightPanel
    
    -- Header in right panel
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 80)
    Header.BackgroundTransparency = 1
    Header.Parent = RightPanel
    
    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Text = "AUTOMATION PANEL"
    HeaderTitle.Size = UDim2.new(1, -60, 0, 35)
    HeaderTitle.Position = UDim2.new(0, 30, 0, 22)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Font = Enum.Font.GothamBold
    HeaderTitle.TextColor3 = GUI.Colors.Text
    HeaderTitle.TextSize = 22
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeaderTitle.Parent = Header
    
    -- Fast mode toggle button
    local FastModeBtn = Instance.new("TextButton")
    FastModeBtn.Name = "FastModeBtn"
    FastModeBtn.Size = UDim2.new(0, 120, 0, 40)
    FastModeBtn.Position = UDim2.new(1, -150, 0, 20)
    FastModeBtn.BackgroundColor3 = GUI.Colors.SurfaceLight
    FastModeBtn.BorderSizePixel = 0
    FastModeBtn.Font = Enum.Font.GothamBold
    FastModeBtn.TextColor3 = GUI.Colors.TextMuted
    FastModeBtn.TextSize = 13
    FastModeBtn.Text = "FAST MODE"
    FastModeBtn.AutoButtonColor = false
    FastModeBtn.Parent = Header
    
    local FastBtnCorner = Instance.new("UICorner")
    FastBtnCorner.CornerRadius = UDim.new(0, 8)
    FastBtnCorner.Parent = FastModeBtn
    
    local FastIcon = Icons.Create(FastModeBtn, "zap", 18, GUI.Colors.TextMuted)
    FastIcon.Position = UDim2.new(0, 12, 0.5, -9)
    
    -- Fast mode toggle logic
    FastModeBtn.MouseButton1Click:Connect(function()
        GUI.Config.FastMode = not GUI.Config.FastMode
        
        if GUI.Config.FastMode then
            Tween(FastModeBtn, {BackgroundColor3 = GUI.Colors.Primary}, 0.2)
            Tween(FastModeBtn, {TextColor3 = GUI.Colors.Text}, 0.2)
            FastIcon:Destroy()
            FastIcon = Icons.Create(FastModeBtn, "zap", 18, GUI.Colors.Text)
            FastIcon.Position = UDim2.new(0, 12, 0.5, -9)
            
            -- Enable fast mode
            if GUI.SetBoostFPS then
                GUI.SetBoostFPS(true)
            end
        else
            Tween(FastModeBtn, {BackgroundColor3 = GUI.Colors.SurfaceLight}, 0.2)
            Tween(FastModeBtn, {TextColor3 = GUI.Colors.TextMuted}, 0.2)
            FastIcon:Destroy()
            FastIcon = Icons.Create(FastModeBtn, "zap", 18, GUI.Colors.TextMuted)
            FastIcon.Position = UDim2.new(0, 12, 0.5, -9)
            
            -- Disable fast mode
            if GUI.SetBoostFPS then
                GUI.SetBoostFPS(false)
            end
        end
    end)
    
    -- Stats container
    local StatsContainer = Instance.new("Frame")
    StatsContainer.Position = UDim2.new(0, 30, 0, 100)
    StatsContainer.Size = UDim2.new(1, -60, 1, -120)
    StatsContainer.BackgroundTransparency = 1
    StatsContainer.Parent = RightPanel
    
    local StatsLayout = Instance.new("UIListLayout")
    StatsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    StatsLayout.Padding = UDim.new(0, 16)
    StatsLayout.Parent = StatsContainer
    
    -- Stat card creation function
    local function CreateStatCard(label, value, iconType, order)
        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(1, 0, 0, 90)
        Card.BackgroundColor3 = GUI.Colors.SurfaceLight
        Card.BorderSizePixel = 0
        Card.LayoutOrder = order
        Card.BackgroundTransparency = 1
        Card.Parent = StatsContainer
        
        local CardCorner = Instance.new("UICorner")
        CardCorner.CornerRadius = UDim.new(0, 12)
        CardCorner.Parent = Card
        
        local CardStroke = Instance.new("UIStroke")
        CardStroke.Color = GUI.Colors.Border
        CardStroke.Thickness = 1
        CardStroke.Transparency = 0.8
        CardStroke.Parent = Card
        
        -- Icon container
        local IconContainer = Instance.new("Frame")
        IconContainer.Size = UDim2.new(0, 56, 0, 56)
        IconContainer.Position = UDim2.new(0, 20, 0.5, -28)
        IconContainer.BackgroundColor3 = GUI.Colors.Surface
        IconContainer.BorderSizePixel = 0
        IconContainer.Parent = Card
        
        local IconCorner = Instance.new("UICorner")
        IconCorner.CornerRadius = UDim.new(0, 12)
        IconCorner.Parent = IconContainer
        
        local Icon = Icons.Create(IconContainer, iconType, 28, GUI.Colors.Primary)
        Icon.Position = UDim2.new(0.5, -14, 0.5, -14)
        
        -- Label
        local Label = Instance.new("TextLabel")
        Label.Text = label
        Label.Size = UDim2.new(1, -100, 0, 22)
        Label.Position = UDim2.new(0, 90, 0, 18)
        Label.BackgroundTransparency = 1
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 13
        Label.TextColor3 = GUI.Colors.TextMuted
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Card
        
        -- Value
        local Value = Instance.new("TextLabel")
        Value.Text = value
        Value.Size = UDim2.new(1, -100, 0, 32)
        Value.Position = UDim2.new(0, 90, 0, 42)
        Value.BackgroundTransparency = 1
        Value.Font = Enum.Font.GothamBold
        Value.TextSize = 24
        Value.TextColor3 = GUI.Colors.Text
        Value.TextXAlignment = Enum.TextXAlignment.Left
        Value.TextTruncate = Enum.TextTruncate.AtEnd
        Value.Parent = Card
        
        -- Hover effect
        local hoverConnection = Card.MouseEnter:Connect(function()
            Tween(Card, {BackgroundTransparency = 0}, 0.2)
            Tween(CardStroke, {Transparency = 0.5}, 0.2)
        end)
        GUI.AddConnection(hoverConnection)
        
        local leaveConnection = Card.MouseLeave:Connect(function()
            Tween(Card, {BackgroundTransparency = 1}, 0.2)
            Tween(CardStroke, {Transparency = 0.8}, 0.2)
        end)
        GUI.AddConnection(leaveConnection)
        
        -- Animate in
        Card.BackgroundTransparency = 1
        task.wait(order * 0.05)
        Tween(Card, {BackgroundTransparency = 0.3}, 0.5, Enum.EasingStyle.Quart)
        
        return Value
    end
    
    -- Create stat cards
    vars.TargetLabel = CreateStatCard("CURRENT TARGET", "Searching...", "target", 1)
    vars.StateLabel = CreateStatCard("STATUS", "Initializing", "status", 2)
    vars.BountyLabel = CreateStatCard("SESSION BOUNTY", "+0", "bounty", 3)
    vars.TimeLabel = CreateStatCard("SESSION TIME", "00:00:00", "time", 4)
    vars.KillsLabel = CreateStatCard("TOTAL ELIMINATIONS", "0", "skull", 5)
    
    -- Dragging
    local dragging, dragInput, dragStart, startPos
    
    local dragBeganConnection = GUI.MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = GUI.MainFrame.Position
            
            Tween(GUI.MainFrame, {Size = GUI.MainFrame.Size - UDim2.new(0, 4, 0, 4)}, 0.1)
            
            local endConnection
            endConnection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    Tween(GUI.MainFrame, {Size = UDim2.new(0, 900, 0, 600)}, 0.1)
                    if endConnection then
                        endConnection:Disconnect()
                    end
                end
            end)
        end
    end)
    GUI.AddConnection(dragBeganConnection)
    
    local dragChangedConnection = GUI.MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    GUI.AddConnection(dragChangedConnection)
    
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
    Tween(GUI.MainFrame, {Size = UDim2.new(0, 900, 0, 600)}, 0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    
    -- Auto-load assets
    task.spawn(function()
        GUI.InitAssets()
    end)
    
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
    
    -- Background image
    local Bg = Instance.new("ImageLabel")
    Bg.Size = UDim2.new(1, 0, 1, 0)
    Bg.BackgroundTransparency = 1
    Bg.ScaleType = Enum.ScaleType.Crop
    Bg.ImageTransparency = 1
    Bg.ZIndex = 20001
    Bg.Parent = Screen
    
    GUI.AddTask(task.spawn(function()
        local asset = getcustomasset or getsynasset
        if asset and isfile and writefile then
            local path = WORKSPACE_FOLDER.."/change.png"
            if not isfile(path) then
                writefile(path, game:HttpGet(ASSETS_REPO.."change.png", true))
            end
            Bg.Image = asset(path)
            Tween(Bg, {ImageTransparency = 0.15}, 1)
        end
    end))
    
    -- Dark overlay
    local Overlay = Instance.new("Frame")
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3 = GUI.Colors.Overlay
    Overlay.BackgroundTransparency = 0.3
    Overlay.BorderSizePixel = 0
    Overlay.ZIndex = 20002
    Overlay.Parent = Screen
    
    -- Center content
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0, 500, 0, 200)
    Container.Position = UDim2.new(0.5, -250, 0.5, -100)
    Container.BackgroundTransparency = 1
    Container.ZIndex = 20003
    Container.Parent = Screen
    
    local Title = Instance.new("TextLabel")
    Title.Text = "CHANGING SERVER"
    Title.Size = UDim2.new(1, 0, 0, 60)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 42
    Title.TextColor3 = GUI.Colors.Text
    Title.TextTransparency = 1
    Title.ZIndex = 20004
    Title.Parent = Container
    
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Text = "Finding optimal server..."
    Subtitle.Size = UDim2.new(1, 0, 0, 30)
    Subtitle.Position = UDim2.new(0, 0, 0, 70)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextSize = 16
    Subtitle.TextColor3 = GUI.Colors.TextMuted
    Subtitle.TextTransparency = 1
    Subtitle.ZIndex = 20004
    Subtitle.Parent = Container
    
    -- Progress bar
    local ProgressBg = Instance.new("Frame")
    ProgressBg.Size = UDim2.new(1, 0, 0, 4)
    ProgressBg.Position = UDim2.new(0, 0, 0, 130)
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
    
    -- Animate in
    Tween(Title, {TextTransparency = 0}, 0.6)
    task.wait(0.1)
    Tween(Subtitle, {TextTransparency = 0}, 0.6)
    task.wait(0.1)
    Tween(ProgressBg, {BackgroundTransparency = 0.6}, 0.6)
    
    -- Animate progress
    Tween(Progress, {Size = UDim2.new(1, 0, 1, 0)}, 3, Enum.EasingStyle.Linear)
    
    -- Pulse animation
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

function GUI.SetBoostFPS(state)
    if state then
        if GUI._BoostScreen then return end
        
        local Screen = Instance.new("ImageLabel")
        Screen.Size = UDim2.new(1, 0, 1, 0)
        Screen.BackgroundTransparency = 1
        Screen.ScaleType = Enum.ScaleType.Crop
        Screen.ImageTransparency = 0.8
        Screen.ZIndex = 15000
        Screen.Parent = GUI.SkibidiGui
        
        GUI.AddTask(task.spawn(function()
            local asset = getcustomasset or getsynasset
            if asset and isfile and writefile then
                local path = WORKSPACE_FOLDER.."/boost.png"
                if not isfile(path) then
                    writefile(path, game:HttpGet(ASSETS_REPO.."boost.png", true))
                end
                Screen.Image = asset(path)
            end
        end))
        
        GUI._BoostScreen = Screen
    else
        if GUI._BoostScreen then
            GUI._BoostScreen:Destroy()
            GUI._BoostScreen = nil
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
