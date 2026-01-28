-- ============================================
-- ULTIMATE SKIBIDI GUI v6.0 - SYNCED & ENHANCED
-- macOS-style controls, vibrant images, fast mode overlay
-- Perfect sync with func.lua
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
GUI.IsMinimized = false
GUI.IsPaused = false

-- Vibrant color palette
GUI.Colors = {
    Background = Color3.fromRGB(8, 11, 18),
    Surface = Color3.fromRGB(15, 18, 28),
    SurfaceLight = Color3.fromRGB(22, 27, 40),
    Primary = Color3.fromRGB(99, 179, 255),
    PrimaryDark = Color3.fromRGB(58, 136, 255),
    Success = Color3.fromRGB(52, 211, 153),
    Warning = Color3.fromRGB(251, 191, 36),
    Error = Color3.fromRGB(239, 68, 68),
    Text = Color3.fromRGB(255, 255, 255),
    TextMuted = Color3.fromRGB(156, 163, 175),
    Border = Color3.fromRGB(45, 55, 72),
    Overlay = Color3.fromRGB(0, 0, 0),
    MacRed = Color3.fromRGB(255, 95, 86),
    MacYellow = Color3.fromRGB(255, 189, 46),
    MacGreen = Color3.fromRGB(39, 201, 63)
}

-- Configuration
local WORKSPACE_FOLDER = "cuackerdoing"
local MUSIC_FILENAME = "sound.mp3"
local BG_FILENAME = "backlua.png"
local LOADING_BG_FILENAME = "loading.png"
local CHANGE_BG_FILENAME = "change.png"
local BOOST_BG_FILENAME = "boost.png"
local TIME_FILENAME = "musictime.txt"
local MUSIC_PATH = WORKSPACE_FOLDER .. "/" .. MUSIC_FILENAME
local BG_PATH = WORKSPACE_FOLDER .. "/" .. BG_FILENAME
local LOADING_PATH = WORKSPACE_FOLDER .. "/" .. LOADING_BG_FILENAME
local CHANGE_PATH = WORKSPACE_FOLDER .. "/" .. CHANGE_BG_FILENAME
local BOOST_PATH = WORKSPACE_FOLDER .. "/" .. BOOST_BG_FILENAME
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
-- ENHANCED ICON SYSTEM
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
        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0.7, 0, 0.7, 0)
        circle.Position = UDim2.new(0.15, 0, 0.15, 0)
        circle.BackgroundTransparency = 1
        circle.BorderSizePixel = 0
        circle.Parent = canvas
        
        local outerRing = Instance.new("UIStroke")
        outerRing.Color = color
        outerRing.Thickness = 2.5
        outerRing.Parent = circle
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = circle
        
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0.2, 0, 0.2, 0)
        dot.Position = UDim2.new(0.4, 0, 0.4, 0)
        dot.BackgroundColor3 = color
        dot.BorderSizePixel = 0
        dot.Parent = canvas
        
        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = dot
        
    elseif iconType == "status" then
        local positions = {0.15, 0.425, 0.7}
        local heights = {0.45, 0.7, 0.55}
        
        for i = 1, 3 do
            local bar = Instance.new("Frame")
            bar.Size = UDim2.new(0.18, 0, heights[i], 0)
            bar.Position = UDim2.new(positions[i], 0, 0.5, 0)
            bar.AnchorPoint = Vector2.new(0, 0.5)
            bar.BackgroundColor3 = color
            bar.BorderSizePixel = 0
            bar.Parent = canvas
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0.35, 0)
            corner.Parent = bar
        end
        
    elseif iconType == "bounty" then
        local top = Instance.new("Frame")
        top.Size = UDim2.new(0.55, 0, 0.3, 0)
        top.Position = UDim2.new(0.225, 0, 0.18, 0)
        top.BackgroundColor3 = color
        top.BorderSizePixel = 0
        top.Rotation = 45
        top.Parent = canvas
        
        local bottom = Instance.new("Frame")
        bottom.Size = UDim2.new(0.55, 0, 0.4, 0)
        bottom.Position = UDim2.new(0.225, 0, 0.48, 0)
        bottom.BackgroundColor3 = color
        bottom.BorderSizePixel = 0
        bottom.Rotation = 45
        bottom.Parent = canvas
        
    elseif iconType == "time" then
        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0.88, 0, 0.88, 0)
        circle.Position = UDim2.new(0.06, 0, 0.06, 0)
        circle.BackgroundTransparency = 1
        circle.BorderSizePixel = 0
        circle.Parent = canvas
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = color
        stroke.Thickness = 2.5
        stroke.Parent = circle
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = circle
        
        local hourHand = Instance.new("Frame")
        hourHand.Size = UDim2.new(0, 2.5, 0.28, 0)
        hourHand.Position = UDim2.new(0.5, -1.25, 0.5, 0)
        hourHand.AnchorPoint = Vector2.new(0.5, 1)
        hourHand.BackgroundColor3 = color
        hourHand.BorderSizePixel = 0
        hourHand.Parent = canvas
        
        local corner1 = Instance.new("UICorner")
        corner1.CornerRadius = UDim.new(1, 0)
        corner1.Parent = hourHand
        
        local minuteHand = Instance.new("Frame")
        minuteHand.Size = UDim2.new(0, 2.5, 0.38, 0)
        minuteHand.Position = UDim2.new(0.5, -1.25, 0.5, 0)
        minuteHand.AnchorPoint = Vector2.new(0.5, 1)
        minuteHand.BackgroundColor3 = color
        minuteHand.BorderSizePixel = 0
        minuteHand.Rotation = 90
        minuteHand.Parent = canvas
        
        local corner2 = Instance.new("UICorner")
        corner2.CornerRadius = UDim.new(1, 0)
        corner2.Parent = minuteHand
        
    elseif iconType == "skull" then
        local head = Instance.new("Frame")
        head.Size = UDim2.new(0.65, 0, 0.55, 0)
        head.Position = UDim2.new(0.175, 0, 0.13, 0)
        head.BackgroundColor3 = color
        head.BorderSizePixel = 0
        head.Parent = canvas
        
        local headCorner = Instance.new("UICorner")
        headCorner.CornerRadius = UDim.new(0.32, 0)
        headCorner.Parent = head
        
        local jaw = Instance.new("Frame")
        jaw.Size = UDim2.new(0.5, 0, 0.28, 0)
        jaw.Position = UDim2.new(0.25, 0, 0.58, 0)
        jaw.BackgroundColor3 = color
        jaw.BorderSizePixel = 0
        jaw.Parent = canvas
        
        local jawCorner = Instance.new("UICorner")
        jawCorner.CornerRadius = UDim.new(0, 5)
        jawCorner.Parent = jaw
        
        for i = 1, 2 do
            local eye = Instance.new("Frame")
            eye.Size = UDim2.new(0.14, 0, 0.14, 0)
            eye.Position = UDim2.new(0.28 + (i-1) * 0.28, 0, 0.33, 0)
            eye.BackgroundColor3 = GUI.Colors.Background
            eye.BorderSizePixel = 0
            eye.Parent = canvas
            
            local eyeCorner = Instance.new("UICorner")
            eyeCorner.CornerRadius = UDim.new(1, 0)
            eyeCorner.Parent = eye
        end
        
    elseif iconType == "zap" then
        local bolt = Instance.new("Frame")
        bolt.Size = UDim2.new(0.45, 0, 0.75, 0)
        bolt.Position = UDim2.new(0.275, 0, 0.125, 0)
        bolt.BackgroundColor3 = color
        bolt.BorderSizePixel = 0
        bolt.Rotation = 18
        bolt.Parent = canvas
        
        local leftCut = Instance.new("Frame")
        leftCut.Size = UDim2.new(0.3, 0, 0.3, 0)
        leftCut.Position = UDim2.new(-0.1, 0, 0.35, 0)
        leftCut.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        leftCut.BorderSizePixel = 0
        leftCut.Rotation = 45
        leftCut.Parent = bolt
    end
    
    return frame
end

-- ============================================
-- IMAGE LOADING
-- ============================================

local function LoadImageFromGitHub(imageName, imageLabel, onComplete)
    GUI.AddTask(task.spawn(function()
        pcall(function()
            local asset = getcustomasset or getsynasset
            if not asset then return end
            if not isfolder then return end
            
            if not isfolder(WORKSPACE_FOLDER) then
                makefolder(WORKSPACE_FOLDER)
            end
            
            local path = WORKSPACE_FOLDER .. "/" .. imageName
            
            if not isfile(path) then
                local success, imageData = pcall(function()
                    return game:HttpGet(ASSETS_REPO .. imageName, true)
                end)
                
                if success and imageData and #imageData > 0 then
                    writefile(path, imageData)
                    print(string.format("[GUI] Downloaded: %s (%d bytes)", imageName, #imageData))
                end
            end
            
            if isfile(path) then
                local assetUrl = asset(path)
                if imageLabel and imageLabel.Parent then
                    imageLabel.Image = assetUrl
                    print(string.format("[GUI] Loaded: %s", imageName))
                    
                    if onComplete then
                        onComplete()
                    end
                end
            end
        end)
    end))
end

-- ============================================
-- MUSIC STATE
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
    
    local Bg = Instance.new("ImageLabel")
    Bg.Size = UDim2.new(1, 0, 1, 0)
    Bg.BackgroundTransparency = 1
    Bg.ImageTransparency = 0.4
    Bg.ScaleType = Enum.ScaleType.Crop
    Bg.ZIndex = 10001
    Bg.Parent = LoaderScreen
    
    LoadImageFromGitHub(LOADING_BG_FILENAME, Bg, function()
        Tween(Bg, {ImageTransparency = 0}, 1.5, Enum.EasingStyle.Sine)
    end)
    
    local Overlay = Instance.new("Frame")
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3 = GUI.Colors.Overlay
    Overlay.BackgroundTransparency = 0.2
    Overlay.BorderSizePixel = 0
    Overlay.ZIndex = 10002
    Overlay.Parent = LoaderScreen
    
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0, 550, 0, 320)
    Container.Position = UDim2.new(0.5, -275, 0.5, -160)
    Container.BackgroundTransparency = 1
    Container.ZIndex = 10003
    Container.Parent = LoaderScreen
    
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
    
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Text = "AUTOMATION SYSTEM v6.0"
    Subtitle.Size = UDim2.new(1, 0, 0, 28)
    Subtitle.Position = UDim2.new(0, 0, 0, 85)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Font = Enum.Font.GothamMedium
    Subtitle.TextColor3 = GUI.Colors.Primary
    Subtitle.TextSize = 16
    Subtitle.TextTransparency = 1
    Subtitle.ZIndex = 10004
    Subtitle.Parent = Container
    
    local ProgressContainer = Instance.new("Frame")
    ProgressContainer.Size = UDim2.new(1, 0, 0, 4)
    ProgressContainer.Position = UDim2.new(0, 0, 0, 160)
    ProgressContainer.BackgroundColor3 = GUI.Colors.Surface
    ProgressContainer.BorderSizePixel = 0
    ProgressContainer.BackgroundTransparency = 1
    ProgressContainer.ZIndex = 10004
    ProgressContainer.Parent = Container
    
    local ProgressCorner = Instance.new("UICorner")
    ProgressCorner.CornerRadius = UDim.new(1, 0)
    ProgressCorner.Parent = ProgressContainer
    
    local ProgressBar = Instance.new("Frame")
    ProgressBar.Size = UDim2.new(0, 0, 1, 0)
    ProgressBar.BackgroundColor3 = GUI.Colors.Primary
    ProgressBar.BorderSizePixel = 0
    ProgressBar.ZIndex = 10005
    ProgressBar.Parent = ProgressContainer
    
    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(1, 0)
    BarCorner.Parent = ProgressBar
    
    local Glow = Instance.new("Frame")
    Glow.Size = UDim2.new(1, 30, 1, 30)
    Glow.Position = UDim2.new(0, -15, 0, -15)
    Glow.BackgroundColor3 = GUI.Colors.Primary
    Glow.BackgroundTransparency = 0.5
    Glow.BorderSizePixel = 0
    Glow.ZIndex = 10004
    Glow.Parent = ProgressBar
    
    local GlowCorner = Instance.new("UICorner")
    GlowCorner.CornerRadius = UDim.new(1, 0)
    GlowCorner.Parent = Glow
    
    local StatusText = Instance.new("TextLabel")
    StatusText.Text = "Initializing..."
    StatusText.Size = UDim2.new(1, 0, 0, 22)
    StatusText.Position = UDim2.new(0, 0, 0, 185)
    StatusText.BackgroundTransparency = 1
    StatusText.Font = Enum.Font.Gotham
    StatusText.TextColor3 = GUI.Colors.TextMuted
    StatusText.TextSize = 14
    StatusText.TextTransparency = 1
    StatusText.ZIndex = 10004
    StatusText.Parent = Container
    
    local PercentText = Instance.new("TextLabel")
    PercentText.Text = "0%"
    PercentText.Size = UDim2.new(1, 0, 0, 48)
    PercentText.Position = UDim2.new(0, 0, 0, 220)
    PercentText.BackgroundTransparency = 1
    PercentText.Font = Enum.Font.GothamBold
    PercentText.TextColor3 = GUI.Colors.Primary
    PercentText.TextSize = 38
    PercentText.TextTransparency = 1
    PercentText.ZIndex = 10004
    PercentText.Parent = Container
    
    Tween(LogoText, {TextTransparency = 0}, 1)
    task.wait(0.15)
    Tween(Subtitle, {TextTransparency = 0}, 1)
    task.wait(0.15)
    Tween(ProgressContainer, {BackgroundTransparency = 0.5}, 1)
    Tween(StatusText, {TextTransparency = 0}, 1)
    Tween(PercentText, {TextTransparency = 0}, 1)
    
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
                Tween(ProgressBar, {Size = UDim2.new(progress, 0, 1, 0)}, 0.4)
            end
        end,
        Complete = function()
            if not LoaderScreen or not LoaderScreen.Parent then return end
            
            if StatusText and StatusText.Parent then
                StatusText.Text = "Ready!"
            end
            if PercentText and PercentText.Parent then
                PercentText.Text = "100%"
            end
            
            task.wait(0.6)
            
            Tween(LoaderScreen, {BackgroundTransparency = 1}, 0.7)
            
            for _, child in pairs(LoaderScreen:GetDescendants()) do
                if child:IsA("TextLabel") or child:IsA("Frame") or child:IsA("ImageLabel") then
                    pcall(function()
                        if child.TextTransparency then
                            Tween(child, {TextTransparency = 1, BackgroundTransparency = 1}, 0.7)
                        elseif child.ImageTransparency then
                            Tween(child, {ImageTransparency = 1, BackgroundTransparency = 1}, 0.7)
                        else
                            Tween(child, {BackgroundTransparency = 1}, 0.7)
                        end
                    end)
                end
            end
            
            task.wait(0.8)
            
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
    loader.Update(0.15, "Initializing audio...")
    
    local musicSuccess = pcall(function()
        GUI.MusicSound = Instance.new("Sound")
        GUI.MusicSound.Name = "SkibidiMusic"
        GUI.MusicSound.Looped = true
        GUI.MusicSound.Volume = GUI.Config.MusicVolume
        GUI.MusicSound.Parent = SoundService
    end)
    
    task.wait(0.2)
    loader.Update(0.25, "Downloading assets...")
    
    GUI.AddTask(task.spawn(function()
        task.wait(0.1)
        
        pcall(function()
            local asset = getcustomasset or getsynasset
            if not asset then
                loader.Update(0.4, "Audio unavailable")
                return
            end
            
            if isfile and not isfile(MUSIC_PATH) then
                if writefile then
                    loader.Update(0.3, "Downloading audio...")
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
                loader.Update(0.4, "Audio ready")
            end
        end)
    end))
    
    task.wait(0.4)
    loader.Update(0.5, "Preparing interface...")
    
    local maxWait = 50
    local waited = 0
    while not GUI.BackgroundImage and waited < maxWait do
        task.wait(0.1)
        waited = waited + 1
    end
    
    if GUI.BackgroundImage then
        loader.Update(0.6, "Loading visuals...")
        LoadImageFromGitHub(BG_FILENAME, GUI.BackgroundImage, function()
            loader.Update(0.8, "Visuals ready")
        end)
    end
    
    task.wait(0.5)
    loader.Update(0.9, "Finalizing...")
    task.wait(0.4)
    loader.Update(1, "Complete")
    task.wait(0.5)
    loader.Complete()
    
    local teleportConnection = Players.LocalPlayer.OnTeleport:Connect(function()
        GUI.SaveMusicState()
    end)
    GUI.AddConnection(teleportConnection)
end

-- ============================================
-- MAIN GUI CREATION
-- ============================================

function GUI.CreateMainGUI()
    if GUI.SkibidiGui then
        GUI.Cleanup()
    end
    
    local lp = Players.LocalPlayer
    if not lp then return nil end
    
    local GUIVars = {}
    
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
    
    -- Main container
    GUI.MainFrame = Instance.new("Frame")
    GUI.MainFrame.Name = "MainFrame"
    GUI.MainFrame.BackgroundColor3 = GUI.Colors.Background
    GUI.MainFrame.Position = UDim2.new(0.5, -500, 0.5, -300)
    GUI.MainFrame.Size = UDim2.new(0, 0, 0, 0)
    GUI.MainFrame.BorderSizePixel = 0
    GUI.MainFrame.ClipsDescendants = true
    GUI.MainFrame.Parent = GUI.SkibidiGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 16)
    MainCorner.Parent = GUI.MainFrame
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = GUI.Colors.Border
    MainStroke.Thickness = 1.5
    MainStroke.Transparency = 0.3
    MainStroke.Parent = GUI.MainFrame
    
    -- ============================================
    -- macOS WINDOW CONTROLS
    -- ============================================
    
    local ControlsBar = Instance.new("Frame")
    ControlsBar.Name = "ControlsBar"
    ControlsBar.Size = UDim2.new(1, 0, 0, 40)
    ControlsBar.BackgroundColor3 = GUI.Colors.Surface
    ControlsBar.BorderSizePixel = 0
    ControlsBar.ZIndex = 100
    ControlsBar.Parent = GUI.MainFrame
    
    local ControlsCorner = Instance.new("UICorner")
    ControlsCorner.CornerRadius = UDim.new(0, 16)
    ControlsCorner.Parent = ControlsBar
    
    local ControlsMask = Instance.new("Frame")
    ControlsMask.Size = UDim2.new(1, 0, 0, 20)
    ControlsMask.Position = UDim2.new(0, 0, 1, -20)
    ControlsMask.BackgroundColor3 = GUI.Colors.Surface
    ControlsMask.BorderSizePixel = 0
    ControlsMask.ZIndex = 100
    ControlsMask.Parent = ControlsBar
    
    local function CreateMacButton(color, position, onClick)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 13, 0, 13)
        btn.Position = UDim2.new(0, 12 + (position * 20), 0.5, -6.5)
        btn.BackgroundColor3 = color
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.ZIndex = 101
        btn.Parent = ControlsBar
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = btn
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(0, 0, 0)
        stroke.Thickness = 0.8
        stroke.Transparency = 0.7
        stroke.Parent = btn
        
        btn.MouseEnter:Connect(function()
            Tween(btn, {Size = UDim2.new(0, 15, 0, 15)}, 0.15)
            Tween(stroke, {Transparency = 0.4}, 0.15)
        end)
        
        btn.MouseLeave:Connect(function()
            Tween(btn, {Size = UDim2.new(0, 13, 0, 13)}, 0.15)
            Tween(stroke, {Transparency = 0.7}, 0.15)
        end)
        
        btn.MouseButton1Click:Connect(onClick)
        
        return btn
    end
    
    -- Red (Close)
    CreateMacButton(GUI.Colors.MacRed, 0, function()
        print("[GUI] Closing GUI...")
        GUI.Cleanup()
        if getgenv()._SkibidiShuttingDown ~= nil then
            getgenv()._SkibidiShuttingDown = true
        end
    end)
    
    -- Yellow (Pause)
    CreateMacButton(GUI.Colors.MacYellow, 1, function()
        GUI.IsPaused = not GUI.IsPaused
        print("[GUI] Paused:", GUI.IsPaused)
        
        if GUI.IsPaused then
            if getgenv().AutoFarmEnabled ~= nil then
                getgenv().AutoFarmEnabled = false
            end
            if GUIVars.StateValue then
                GUIVars.StateValue.Text = "PAUSED"
                GUIVars.StateValue.TextColor3 = GUI.Colors.Warning
            end
        else
            if getgenv().AutoFarmEnabled ~= nil then
                getgenv().AutoFarmEnabled = true
            end
            if GUIVars.StateValue then
                GUIVars.StateValue.TextColor3 = GUI.Colors.Text
            end
        end
    end)
    
    -- Green (Minimize)
    CreateMacButton(GUI.Colors.MacGreen, 2, function()
        GUI.IsMinimized = not GUI.IsMinimized
        print("[GUI] Minimized:", GUI.IsMinimized)
        
        if GUI.IsMinimized then
            Tween(GUI.MainFrame, {Size = UDim2.new(0, 200, 0, 40)}, 0.4, Enum.EasingStyle.Quart)
        else
            Tween(GUI.MainFrame, {Size = UDim2.new(0, 1000, 0, 600)}, 0.4, Enum.EasingStyle.Quart)
        end
    end)
    
    -- Title in controls bar
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Text = "SKIBIDI v6.0"
    TitleLabel.Size = UDim2.new(1, -160, 1, 0)
    TitleLabel.Position = UDim2.new(0, 80, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 13
    TitleLabel.TextColor3 = GUI.Colors.Text
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 101
    TitleLabel.Parent = ControlsBar
    
    -- ============================================
    -- LEFT PANEL - Image Panel
    -- ============================================
    
    local LeftPanel = Instance.new("Frame")
    LeftPanel.Name = "LeftPanel"
    LeftPanel.Size = UDim2.new(0, 450, 1, -40)
    LeftPanel.Position = UDim2.new(0, 0, 0, 40)
    LeftPanel.BackgroundTransparency = 1
    LeftPanel.BorderSizePixel = 0
    LeftPanel.ClipsDescendants = true
    LeftPanel.Parent = GUI.MainFrame
    
    -- VIBRANT Background Image
    GUI.BackgroundImage = Instance.new("ImageLabel")
    GUI.BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
    GUI.BackgroundImage.BackgroundTransparency = 1
    GUI.BackgroundImage.ScaleType = Enum.ScaleType.Crop
    GUI.BackgroundImage.ImageTransparency = 0
    GUI.BackgroundImage.ZIndex = 1
    GUI.BackgroundImage.Parent = LeftPanel
    
    -- Subtle dark overlay
    local ImageOverlay = Instance.new("Frame")
    ImageOverlay.Size = UDim2.new(1, 0, 1, 0)
    ImageOverlay.BackgroundColor3 = GUI.Colors.Overlay
    ImageOverlay.BackgroundTransparency = 0.25
    ImageOverlay.BorderSizePixel = 0
    ImageOverlay.ZIndex = 2
    ImageOverlay.Parent = LeftPanel
    
    local OverlayGradient = Instance.new("UIGradient")
    OverlayGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 11, 18))
    }
    OverlayGradient.Rotation = 90
    OverlayGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(1, 0)
    }
    OverlayGradient.Parent = ImageOverlay
    
    -- Logo
    local LeftLogo = Instance.new("TextLabel")
    LeftLogo.Text = "SKIBIDI"
    LeftLogo.Size = UDim2.new(1, -40, 0, 70)
    LeftLogo.Position = UDim2.new(0, 20, 1, -90)
    LeftLogo.BackgroundTransparency = 1
    LeftLogo.Font = Enum.Font.GothamBold
    LeftLogo.TextColor3 = GUI.Colors.Text
    LeftLogo.TextSize = 48
    LeftLogo.TextXAlignment = Enum.TextXAlignment.Left
    LeftLogo.ZIndex = 3
    LeftLogo.Parent = LeftPanel
    
    -- Version badge
    local VersionBadge = Instance.new("Frame")
    VersionBadge.Size = UDim2.new(0, 75, 0, 32)
    VersionBadge.Position = UDim2.new(0, 20, 0, 20)
    VersionBadge.BackgroundColor3 = GUI.Colors.Primary
    VersionBadge.BackgroundTransparency = 0
    VersionBadge.BorderSizePixel = 0
    VersionBadge.ZIndex = 3
    VersionBadge.Parent = LeftPanel
    
    local BadgeCorner = Instance.new("UICorner")
    BadgeCorner.CornerRadius = UDim.new(0, 8)
    BadgeCorner.Parent = VersionBadge
    
    local BadgeText = Instance.new("TextLabel")
    BadgeText.Text = "v6.0"
    BadgeText.Size = UDim2.new(1, 0, 1, 0)
    BadgeText.BackgroundTransparency = 1
    BadgeText.Font = Enum.Font.GothamBold
    BadgeText.TextColor3 = Color3.fromRGB(0, 0, 0)
    BadgeText.TextSize = 15
    BadgeText.ZIndex = 4
    BadgeText.Parent = VersionBadge
    
    -- ============================================
    -- RIGHT PANEL - Stats Panel
    -- ============================================
    
    local RightPanel = Instance.new("Frame")
    RightPanel.Name = "RightPanel"
    RightPanel.Size = UDim2.new(0, 550, 1, -40)
    RightPanel.Position = UDim2.new(0, 450, 0, 40)
    RightPanel.BackgroundColor3 = GUI.Colors.Surface
    RightPanel.BorderSizePixel = 0
    RightPanel.Parent = GUI.MainFrame
    
    -- Header
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 90)
    Header.BackgroundTransparency = 1
    Header.Parent = RightPanel
    
    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Text = "AUTOMATION PANEL"
    HeaderTitle.Size = UDim2.new(1, -70, 0, 40)
    HeaderTitle.Position = UDim2.new(0, 35, 0, 25)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Font = Enum.Font.GothamBold
    HeaderTitle.TextColor3 = GUI.Colors.Text
    HeaderTitle.TextSize = 24
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeaderTitle.Parent = Header
    
    -- Fast mode toggle
    local FastModeBtn = Instance.new("TextButton")
    FastModeBtn.Name = "FastModeBtn"
    FastModeBtn.Size = UDim2.new(0, 140, 0, 45)
    FastModeBtn.Position = UDim2.new(1, -175, 0, 22.5)
    FastModeBtn.BackgroundColor3 = GUI.Colors.SurfaceLight
    FastModeBtn.BorderSizePixel = 0
    FastModeBtn.Font = Enum.Font.GothamBold
    FastModeBtn.TextColor3 = GUI.Colors.TextMuted
    FastModeBtn.TextSize = 14
    FastModeBtn.Text = "  FAST MODE"
    FastModeBtn.TextXAlignment = Enum.TextXAlignment.Left
    FastModeBtn.AutoButtonColor = false
    FastModeBtn.Parent = Header
    
    local FastBtnCorner = Instance.new("UICorner")
    FastBtnCorner.CornerRadius = UDim.new(0, 10)
    FastBtnCorner.Parent = FastModeBtn
    
    local FastBtnStroke = Instance.new("UIStroke")
    FastBtnStroke.Color = GUI.Colors.Border
    FastBtnStroke.Thickness = 1.5
    FastBtnStroke.Transparency = 0.6
    FastBtnStroke.Parent = FastModeBtn
    
    local FastIcon = Icons.Create(FastModeBtn, "zap", 20, GUI.Colors.TextMuted)
    FastIcon.Position = UDim2.new(0, 15, 0.5, -10)
    
    local FastIndicator = Instance.new("Frame")
    FastIndicator.Size = UDim2.new(0, 8, 0, 8)
    FastIndicator.Position = UDim2.new(1, -15, 0.5, -4)
    FastIndicator.BackgroundColor3 = GUI.Colors.TextMuted
    FastIndicator.BorderSizePixel = 0
    FastIndicator.Parent = FastModeBtn
    
    local FastIndCorner = Instance.new("UICorner")
    FastIndCorner.CornerRadius = UDim.new(1, 0)
    FastIndCorner.Parent = FastIndicator
    
    -- Fast mode toggle logic
    FastModeBtn.MouseButton1Click:Connect(function()
        GUI.Config.FastMode = not GUI.Config.FastMode
        
        if GUI.Config.FastMode then
            Tween(FastModeBtn, {BackgroundColor3 = GUI.Colors.Primary}, 0.25)
            Tween(FastModeBtn, {TextColor3 = Color3.fromRGB(0, 0, 0)}, 0.25)
            Tween(FastBtnStroke, {Transparency = 1}, 0.25)
            Tween(FastIndicator, {BackgroundColor3 = GUI.Colors.Success}, 0.25)
            FastIcon:Destroy()
            FastIcon = Icons.Create(FastModeBtn, "zap", 20, Color3.fromRGB(0, 0, 0))
            FastIcon.Position = UDim2.new(0, 15, 0.5, -10)
            
            GUI.SetBoostFPS(true)
            print("[GUI] ⚡ Fast mode ENABLED")
        else
            Tween(FastModeBtn, {BackgroundColor3 = GUI.Colors.SurfaceLight}, 0.25)
            Tween(FastModeBtn, {TextColor3 = GUI.Colors.TextMuted}, 0.25)
            Tween(FastBtnStroke, {Transparency = 0.6}, 0.25)
            Tween(FastIndicator, {BackgroundColor3 = GUI.Colors.TextMuted}, 0.25)
            FastIcon:Destroy()
            FastIcon = Icons.Create(FastModeBtn, "zap", 20, GUI.Colors.TextMuted)
            FastIcon.Position = UDim2.new(0, 15, 0.5, -10)
            
            GUI.SetBoostFPS(false)
            print("[GUI] Fast mode DISABLED")
        end
    end)
    
    -- Stats container
    local StatsContainer = Instance.new("Frame")
    StatsContainer.Position = UDim2.new(0, 35, 0, 110)
    StatsContainer.Size = UDim2.new(1, -70, 1, -130)
    StatsContainer.BackgroundTransparency = 1
    StatsContainer.Parent = RightPanel
    
    local StatsLayout = Instance.new("UIListLayout")
    StatsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    StatsLayout.Padding = UDim.new(0, 18)
    StatsLayout.Parent = StatsContainer
    
    -- Stat card creation
    local function CreateStatCard(label, value, iconType, order)
        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(1, 0, 0, 85)
        Card.BackgroundColor3 = GUI.Colors.SurfaceLight
        Card.BorderSizePixel = 0
        Card.LayoutOrder = order
        Card.Parent = StatsContainer
        
        local CardCorner = Instance.new("UICorner")
        CardCorner.CornerRadius = UDim.new(0, 14)
        CardCorner.Parent = Card
        
        local CardStroke = Instance.new("UIStroke")
        CardStroke.Color = GUI.Colors.Border
        CardStroke.Thickness = 1.5
        CardStroke.Transparency = 0.7
        CardStroke.Parent = Card
        
        local IconContainer = Instance.new("Frame")
        IconContainer.Size = UDim2.new(0, 60, 0, 60)
        IconContainer.Position = UDim2.new(0, 18, 0.5, -30)
        IconContainer.BackgroundColor3 = GUI.Colors.Surface
        IconContainer.BorderSizePixel = 0
        IconContainer.Parent = Card
        
        local IconCorner = Instance.new("UICorner")
        IconCorner.CornerRadius = UDim.new(0, 14)
        IconCorner.Parent = IconContainer
        
        local IconStroke = Instance.new("UIStroke")
        IconStroke.Color = GUI.Colors.Primary
        IconStroke.Thickness = 1.5
        IconStroke.Transparency = 0.6
        IconStroke.Parent = IconContainer
        
        local Icon = Icons.Create(IconContainer, iconType, 30, GUI.Colors.Primary)
        Icon.Position = UDim2.new(0.5, -15, 0.5, -15)
        
        local Label = Instance.new("TextLabel")
        Label.Text = label
        Label.Size = UDim2.new(1, -105, 0, 24)
        Label.Position = UDim2.new(0, 95, 0, 16)
        Label.BackgroundTransparency = 1
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 12
        Label.TextColor3 = GUI.Colors.TextMuted
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Card
        
        local Value = Instance.new("TextLabel")
        Value.Text = value
        Value.Size = UDim2.new(1, -105, 0, 36)
        Value.Position = UDim2.new(0, 95, 0, 40)
        Value.BackgroundTransparency = 1
        Value.Font = Enum.Font.GothamBold
        Value.TextSize = 26
        Value.TextColor3 = GUI.Colors.Text
        Value.TextXAlignment = Enum.TextXAlignment.Left
        Value.TextTruncate = Enum.TextTruncate.AtEnd
        Value.Parent = Card
        
        local hoverConnection = Card.MouseEnter:Connect(function()
            Tween(CardStroke, {Transparency = 0.3}, 0.2)
            Tween(IconStroke, {Transparency = 0.2}, 0.2)
        end)
        GUI.AddConnection(hoverConnection)
        
        local leaveConnection = Card.MouseLeave:Connect(function()
            Tween(CardStroke, {Transparency = 0.7}, 0.2)
            Tween(IconStroke, {Transparency = 0.6}, 0.2)
        end)
        GUI.AddConnection(leaveConnection)
        
        task.wait(order * 0.06)
        
        return Value
    end
    
    -- Create stat cards
    GUIVars.TargetValue = CreateStatCard("CURRENT TARGET", "Searching...", "target", 1)
    GUIVars.StateValue = CreateStatCard("STATUS", "Initializing", "status", 2)
    GUIVars.BountyValue = CreateStatCard("SESSION BOUNTY", "+0", "bounty", 3)
    GUIVars.TimeValue = CreateStatCard("SESSION TIME", "0:00", "time", 4)
    GUIVars.KillsValue = CreateStatCard("TOTAL ELIMINATIONS", "0", "skull", 5)
    
    -- Store in getgenv for func.lua access
    getgenv().GUIVars = GUIVars
    
    -- Dragging
    local dragging, dragInput, dragStart, startPos
    
    local dragBeganConnection = ControlsBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            if GUI.IsMinimized then return end
            
            dragging = true
            dragStart = input.Position
            startPos = GUI.MainFrame.Position
            
            Tween(GUI.MainFrame, {Size = GUI.MainFrame.Size - UDim2.new(0, 6, 0, 6)}, 0.12)
            
            local endConnection
            endConnection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    Tween(GUI.MainFrame, {Size = UDim2.new(0, 1000, 0, 600)}, 0.12)
                    if endConnection then
                        endConnection:Disconnect()
                    end
                end
            end)
        end
    end)
    GUI.AddConnection(dragBeganConnection)
    
    local dragChangedConnection = ControlsBar.InputChanged:Connect(function(input)
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
    Tween(GUI.MainFrame, {Size = UDim2.new(0, 1000, 0, 600)}, 0.9, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    
    -- Auto-load assets
    task.spawn(function()
        GUI.InitAssets()
    end)
    
    -- Logger
    local Logger = {}
    
    function Logger:Log(m)
        if GUIVars.StateValue and GUIVars.StateValue.Parent then
            GUIVars.StateValue.Text = tostring(m)
        end
    end
    
    function Logger:Info(m) self:Log(m) end
    function Logger:Success(m) self:Log(m) end
    function Logger:Warning(m) self:Log(m) end
    function Logger:Error(m) self:Log(m) end
    
    function Logger:Target(m)
        if GUIVars.TargetValue and GUIVars.TargetValue.Parent then
            GUIVars.TargetValue.Text = tostring(m)
        end
    end
    
    return Logger
end

-- ============================================
-- SERVER CHANGE SCREEN
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
    Bg.ImageTransparency = 0.5
    Bg.ZIndex = 20001
    Bg.Parent = Screen
    
    LoadImageFromGitHub(CHANGE_BG_FILENAME, Bg, function()
        Tween(Bg, {ImageTransparency = 0}, 1.2)
    end)
    
    local Overlay = Instance.new("Frame")
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3 = GUI.Colors.Overlay
    Overlay.BackgroundTransparency = 0.15
    Overlay.BorderSizePixel = 0
    Overlay.ZIndex = 20002
    Overlay.Parent = Screen
    
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0, 550, 0, 220)
    Container.Position = UDim2.new(0.5, -275, 0.5, -110)
    Container.BackgroundTransparency = 1
    Container.ZIndex = 20003
    Container.Parent = Screen
    
    local Title = Instance.new("TextLabel")
    Title.Text = "CHANGING SERVER"
    Title.Size = UDim2.new(1, 0, 0, 70)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 48
    Title.TextColor3 = GUI.Colors.Text
    Title.TextTransparency = 1
    Title.ZIndex = 20004
    Title.Parent = Container
    
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Text = "Optimizing server selection..."
    Subtitle.Size = UDim2.new(1, 0, 0, 32)
    Subtitle.Position = UDim2.new(0, 0, 0, 80)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextSize = 18
    Subtitle.TextColor3 = GUI.Colors.Primary
    Subtitle.TextTransparency = 1
    Subtitle.ZIndex = 20004
    Subtitle.Parent = Container
    
    local ProgressBg = Instance.new("Frame")
    ProgressBg.Size = UDim2.new(1, 0, 0, 5)
    ProgressBg.Position = UDim2.new(0, 0, 0, 145)
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
    
    local Glow = Instance.new("Frame")
    Glow.Size = UDim2.new(1, 40, 1, 40)
    Glow.Position = UDim2.new(0, -20, 0, -20)
    Glow.BackgroundColor3 = GUI.Colors.Primary
    Glow.BackgroundTransparency = 0.4
    Glow.BorderSizePixel = 0
    Glow.ZIndex = 20004
    Glow.Parent = Progress
    
    local GlowCorner = Instance.new("UICorner")
    GlowCorner.CornerRadius = UDim.new(1, 0)
    GlowCorner.Parent = Glow
    
    Tween(Title, {TextTransparency = 0}, 0.7)
    task.wait(0.12)
    Tween(Subtitle, {TextTransparency = 0}, 0.7)
    task.wait(0.12)
    Tween(ProgressBg, {BackgroundTransparency = 0.4}, 0.7)
    
    Tween(Progress, {Size = UDim2.new(1, 0, 1, 0)}, 3.5, Enum.EasingStyle.Linear)
    
    GUI.AddTask(task.spawn(function()
        while Screen and Screen.Parent do
            Tween(Title, {TextTransparency = 0.25}, 1.4, Enum.EasingStyle.Sine)
            task.wait(1.4)
            if not Screen or not Screen.Parent then break end
            Tween(Title, {TextTransparency = 0}, 1.4, Enum.EasingStyle.Sine)
            task.wait(1.4)
        end
    end))
end

-- ============================================
-- BOOST FPS MODE - FULL SCREEN IMAGE OVERLAY
-- ============================================

function GUI.SetBoostFPS(state)
    if state then
        if GUI._BoostScreen then return end
        
        local Screen = Instance.new("ImageLabel")
        Screen.Name = "BoostScreen"
        Screen.Size = UDim2.new(1, 0, 1, 0)
        Screen.BackgroundTransparency = 1
        Screen.ScaleType = Enum.ScaleType.Crop
        Screen.ImageTransparency = 0
        Screen.ZIndex = 15000
        Screen.Parent = GUI.SkibidiGui
        
        -- Load boost background - FULL OPAQUE
        LoadImageFromGitHub(BOOST_BG_FILENAME, Screen, function()
            print("[GUI] 🚀 Boost image loaded - FULL SCREEN")
        end)
        
        GUI._BoostScreen = Screen
        print("[GUI] ⚡ FAST MODE ACTIVATED - Full screen overlay")
    else
        if GUI._BoostScreen then
            Tween(GUI._BoostScreen, {ImageTransparency = 1}, 0.5, nil, nil, function()
                if GUI._BoostScreen then
                    GUI._BoostScreen:Destroy()
                    GUI._BoostScreen = nil
                end
            end)
            print("[GUI] Fast mode deactivated")
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

-- Set in getgenv for access from func.lua
getgenv().SkibidiGUI_v6 = GUI

return GUI
