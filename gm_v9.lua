-- ============================================
-- HOHO'S BOUNTY REMAKE v9.0 - FULLSCREEN IMAGES
-- By Ryu and Caucker - January 2026
-- Modified: Fullscreen centered images, all text on LEFT side with animated gradient
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
GUI.VideoBackground = nil
GUI.MusicSound = nil
GUI.Connections = {}
GUI.Tasks = {}
GUI.RunningTweens = {}
GUI.SessionStartTime = tick()
GUI._BoostScreen = nil
GUI.IsMinimized = false
GUI.IsPaused = false
GUI.IsMobile = false
GUI.IsTablet = false
GUI.ScreenSize = Vector2.new(0, 0)
repeat task.wait() until getgenv().SkibidiPersistentStorage
GUI.PersistentData = getgenv().SkibidiPersistentStorage
GUI.DownloadQueue = {}
GUI.DownloadProgress = {}
GUI.LoadedAssets = {}

-- Enhanced color palette
GUI.Colors = {
    Background = Color3.fromRGB(6, 8, 15),
    Surface = Color3.fromRGB(12, 15, 25),
    SurfaceLight = Color3.fromRGB(20, 24, 38),
    Primary = Color3.fromRGB(88, 166, 255),
    PrimaryGlow = Color3.fromRGB(120, 190, 255),
    Success = Color3.fromRGB(52, 211, 153),
    Warning = Color3.fromRGB(251, 191, 36),
    Error = Color3.fromRGB(239, 68, 68),
    Text = Color3.fromRGB(255, 255, 255),
    TextMuted = Color3.fromRGB(156, 163, 175),
    Border = Color3.fromRGB(40, 48, 70),
    Overlay = Color3.fromRGB(0, 0, 0),
    Accent1 = Color3.fromRGB(168, 85, 247),
    Accent2 = Color3.fromRGB(236, 72, 153),
    Accent3 = Color3.fromRGB(34, 211, 238),
}

-- Z-INDEX LAYERS
GUI.ZLayers = {
    VideoBackground = 1000,
    MainGUI = 10000,
    Controls = 10100,
    LoadingScreen = 20000,
    ServerChange = 25000
}

-- Configuration
local WORKSPACE_FOLDER = "cuackerdoing"
local ASSETS_FOLDER = WORKSPACE_FOLDER .. "/assets"
local DATA_FILE = WORKSPACE_FOLDER .. "/persistent_data.json"
local MUSIC_TIME_FILE = WORKSPACE_FOLDER .. "/musictime.txt"
local ASSETS_REPO = "https://raw.githubusercontent.com/Ryu-Dev-here/assetsfora/main/"

-- IMAGES ONLY ASSET DEFINITIONS
local ASSETS = {
    -- Images (PNG files)
    {name = "background.png", type = "image", size = 590000, priority = 1, isLarge = false},
    {name = "backlua.png", type = "image", size = 174000, priority = 1, isLarge = false},
    {name = "boost.png", type = "image", size = 800000, priority = 3},
    {name = "change.png", type = "image", size = 800000, priority = 3},
    {name = "loading.png", type = "image", size = 800000, priority = 1},
    
    -- Audio (MP3 file - LARGE)
    {name = "sound.mp3", type = "audio", size = 7949000, priority = 2, isLarge = true, lazyLoad = true},
}

GUI.Config = {
    AutoFarmEnabled = true,
    MusicEnabled = true,
    MusicVolume = 0.5,
    FastMode = false,
    VideoBackgrounds = true
}

-- ============================================
-- DEVICE DETECTION
-- ============================================

local function DetectDevice()
    local viewportSize = workspace.CurrentCamera.ViewportSize
    GUI.ScreenSize = viewportSize
    
    if viewportSize.X < 600 or (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.GamepadEnabled) then
        GUI.IsMobile = true
        GUI.IsTablet = false
    elseif viewportSize.X >= 600 and viewportSize.X < 1024 and UserInputService.TouchEnabled then
        GUI.IsMobile = false
        GUI.IsTablet = true
    else
        GUI.IsMobile = false
        GUI.IsTablet = false
    end
end

local function GetResponsiveValue(desktopValue, mobileValue, tabletValue)
    if GUI.IsMobile then
        return mobileValue or (desktopValue * 0.6)
    elseif GUI.IsTablet then
        return tabletValue or (desktopValue * 0.8)
    else
        return desktopValue
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
-- PREMIUM ICON SYSTEM
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
        local outerCircle = Instance.new("Frame")
        outerCircle.Size = UDim2.new(0.8, 0, 0.8, 0)
        outerCircle.Position = UDim2.new(0.1, 0, 0.1, 0)
        outerCircle.BackgroundTransparency = 1
        outerCircle.Parent = canvas
        
        local outerStroke = Instance.new("UIStroke")
        outerStroke.Color = color
        outerStroke.Thickness = 2
        outerStroke.Parent = outerCircle
        
        local outerCorner = Instance.new("UICorner")
        outerCorner.CornerRadius = UDim.new(1, 0)
        outerCorner.Parent = outerCircle
        
        local centerDot = Instance.new("Frame")
        centerDot.Size = UDim2.new(0.3, 0, 0.3, 0)
        centerDot.Position = UDim2.new(0.35, 0, 0.35, 0)
        centerDot.BackgroundColor3 = color
        centerDot.Parent = canvas
        
        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = centerDot
        
    elseif iconType == "status" then
        local center = Instance.new("Frame")
        center.Size = UDim2.new(0.4, 0, 0.4, 0)
        center.Position = UDim2.new(0.3, 0, 0.3, 0)
        center.BackgroundColor3 = color
        center.Parent = canvas
        
        local centerCorner = Instance.new("UICorner")
        centerCorner.CornerRadius = UDim.new(1, 0)
        centerCorner.Parent = center
        
    elseif iconType == "bounty" then
        local diamond = Instance.new("Frame")
        diamond.Size = UDim2.new(0.6, 0, 0.6, 0)
        diamond.Position = UDim2.new(0.2, 0, 0.2, 0)
        diamond.BackgroundColor3 = color
        diamond.Rotation = 45
        diamond.Parent = canvas
        
        local diamondCorner = Instance.new("UICorner")
        diamondCorner.CornerRadius = UDim.new(0.15, 0)
        diamondCorner.Parent = diamond
        
    elseif iconType == "time" then
        local clockFace = Instance.new("Frame")
        clockFace.Size = UDim2.new(0.9, 0, 0.9, 0)
        clockFace.Position = UDim2.new(0.05, 0, 0.05, 0)
        clockFace.BackgroundTransparency = 1
        clockFace.Parent = canvas
        
        local clockStroke = Instance.new("UIStroke")
        clockStroke.Color = color
        clockStroke.Thickness = 2
        clockStroke.Parent = clockFace
        
        local clockCorner = Instance.new("UICorner")
        clockCorner.CornerRadius = UDim.new(1, 0)
        clockCorner.Parent = clockFace
        
        local hourHand = Instance.new("Frame")
        hourHand.Size = UDim2.new(0, 2, 0.25, 0)
        hourHand.Position = UDim2.new(0.5, -1, 0.5, 0)
        hourHand.AnchorPoint = Vector2.new(0.5, 1)
        hourHand.BackgroundColor3 = color
        hourHand.Rotation = 45
        hourHand.Parent = canvas
        
        local hourCorner = Instance.new("UICorner")
        hourCorner.CornerRadius = UDim.new(1, 0)
        hourCorner.Parent = hourHand
        
        local minuteHand = Instance.new("Frame")
        minuteHand.Size = UDim2.new(0, 1.5, 0.35, 0)
        minuteHand.Position = UDim2.new(0.5, -0.75, 0.5, 0)
        minuteHand.AnchorPoint = Vector2.new(0.5, 1)
        minuteHand.BackgroundColor3 = color
        minuteHand.Rotation = 135
        minuteHand.Parent = canvas
        
        local minuteCorner = Instance.new("UICorner")
        minuteCorner.CornerRadius = UDim.new(1, 0)
        minuteCorner.Parent = minuteHand
    end
    
    return frame
end

-- ============================================
-- AGGRESSIVE ASSET DOWNLOADER
-- ============================================

local AssetDownloader = {}

function AssetDownloader:DownloadAsset(asset, onProgress)
    return GUI.AddTask(task.spawn(function()
        pcall(function()
            if not game.HttpGet or not writefile then
                if onProgress then onProgress(asset.name, 0, asset.size, "failed") end
                return
            end
            
            local path = ASSETS_FOLDER .. "/" .. asset.name
            
            if isfile and isfile(path) then
                if onProgress then
                    onProgress(asset.name, 1, asset.size, "cached")
                end
                task.wait(0.1)
                return path
            end
            
            if onProgress then
                onProgress(asset.name, 0.1, asset.size, "downloading")
            end
            
            local maxRetries = 5
            local retryCount = 0
            local success = false
            local content = nil
            
            while not success and retryCount < maxRetries do
                local downloadSuccess, downloadData = pcall(function()
                    return game:HttpGet(ASSETS_REPO .. asset.name, true)
                end)
                
                if downloadSuccess and downloadData and type(downloadData) == "string" and #downloadData > 100 then
                    content = downloadData
                    success = true
                    print(string.format("[ASSET] ✅ Downloaded: %s (%d bytes)", asset.name, #downloadData))
                else
                    retryCount = retryCount + 1
                    if retryCount < maxRetries then
                        warn(string.format("[ASSET] ⚠️ Retry %d/%d for: %s", retryCount, maxRetries, asset.name))
                        task.wait(2 * retryCount)
                    end
                end
            end
            
            if not success or not content then
                if onProgress then
                    onProgress(asset.name, 0, asset.size, "failed")
                end
                warn(string.format("[ASSET] ❌ Failed to download %s after %d retries", asset.name, maxRetries))
                return
            end
            
            if onProgress then
                onProgress(asset.name, 0.8, asset.size, "writing")
            end
            
            local writeSuccess = pcall(function()
                writefile(path, content)
            end)
            
            if writeSuccess then
                if isfile and isfile(path) then
                    local verify = readfile(path)
                    if #verify == #content then
                        print(string.format("[ASSET] 💾 Saved and verified: %s", asset.name))
                        if onProgress then
                            onProgress(asset.name, 1, asset.size, "complete")
                        end
                        task.wait(0.1)
                        return path
                    end
                end
            end
            
            if onProgress then
                onProgress(asset.name, 0, asset.size, "failed")
            end
            warn(string.format("[ASSET] ❌ Failed to write %s to disk", asset.name))
        end)
    end))
end

function AssetDownloader:LoadAsset(assetPath, targetObject)
    local success = pcall(function()
        local assetFunc = getcustomasset or getsynasset
        if not assetFunc then
            warn("[ASSET] ❌ Asset loading not supported - missing getcustomasset/getsynasset")
            return
        end
        
        if not isfile or not isfile(assetPath) then
            warn("[ASSET] ❌ Asset file not found: " .. assetPath)
            return
        end
        
        local assetUrl = assetFunc(assetPath)
        print(string.format("[ASSET] 🔗 Generated URL for: %s", assetPath))
        
        if targetObject:IsA("ImageLabel") or targetObject:IsA("ImageButton") then
            targetObject.Image = assetUrl
            print(string.format("[ASSET] 🖼️ Applied image"))
            
        elseif targetObject:IsA("Sound") then
            targetObject.SoundId = assetUrl
            print(string.format("[ASSET] 🔊 Applied sound"))
        end
        
        GUI.LoadedAssets[assetPath] = true
    end)
    
    if not success then
        warn("[ASSET] ❌ Failed to load asset: " .. assetPath)
    end
    
    return success
end

function AssetDownloader:LazyLoadAsset(asset, targetObject, onProgress)
    return GUI.AddTask(task.spawn(function()
        local path = ASSETS_FOLDER .. "/" .. asset.name
        if GUI.LoadedAssets[path] then
            print(string.format("[ASSET] ✓ Already loaded: %s", asset.name))
            return true
        end
        
        print(string.format("[ASSET] ⏳ Lazy loading: %s", asset.name))
        
        if not isfile or not isfile(path) then
            self:DownloadAsset(asset, onProgress)
            
            local maxWait = 30
            local waited = 0
            while waited < maxWait do
                if isfile and isfile(path) then
                    break
                end
                task.wait(0.5)
                waited = waited + 0.5
            end
        end
        
        if isfile and isfile(path) then
            return self:LoadAsset(path, targetObject)
        end
        
        return false
    end))
end

-- ============================================
-- ANIMATED GRADIENT TEXT FUNCTION
-- ============================================

local function CreateAnimatedGradientText(parent, text, size, position, textSize, zIndex)
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Text = text
    TextLabel.Size = size
    TextLabel.Position = position
    TextLabel.BackgroundTransparency = 1
    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.TextSize = textSize
    TextLabel.TextColor3 = GUI.Colors.Text
    TextLabel.TextTransparency = 1
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.ZIndex = zIndex
    TextLabel.Parent = parent
    
    -- ANIMATED GRADIENT
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, GUI.Colors.Primary),
        ColorSequenceKeypoint.new(0.5, GUI.Colors.Accent1),
        ColorSequenceKeypoint.new(1, GUI.Colors.Accent3)
    }
    Gradient.Offset = Vector2.new(-1, 0)
    Gradient.Rotation = 0
    Gradient.Parent = TextLabel
    
    -- Animate gradient
    task.spawn(function()
        while TextLabel and TextLabel.Parent and Gradient and Gradient.Parent do
            Tween(Gradient, {Offset = Vector2.new(1, 0)}, 3, Enum.EasingStyle.Linear)
            task.wait(3)
            if not Gradient or not Gradient.Parent then break end
            Gradient.Offset = Vector2.new(-1, 0)
        end
    end)
    
    return TextLabel
end

-- ============================================
-- LOADING SCREEN WITH FULLSCREEN IMAGE
-- ============================================

function GUI.CreateAdvancedLoader()
    local LoaderScreen = Instance.new("Frame")
    LoaderScreen.Name = "AdvancedLoader"
    LoaderScreen.Size = UDim2.new(1, 0, 1, 0)
    LoaderScreen.BackgroundColor3 = GUI.Colors.Background
    LoaderScreen.BackgroundTransparency = 0
    LoaderScreen.ZIndex = GUI.ZLayers.LoadingScreen
    LoaderScreen.Parent = GUI.SkibidiGui
    
    -- FULLSCREEN CENTERED LOADING IMAGE
    local LoadingImage = Instance.new("ImageLabel")
    LoadingImage.Size = UDim2.new(1, 0, 1, 0)
    LoadingImage.Position = UDim2.new(0.5, 0, 0.5, 0)
    LoadingImage.AnchorPoint = Vector2.new(0.5, 0.5)
    LoadingImage.BackgroundTransparency = 1
    LoadingImage.ScaleType = Enum.ScaleType.Crop
    LoadingImage.ZIndex = GUI.ZLayers.LoadingScreen + 1
    LoadingImage.Parent = LoaderScreen

    -- Load loading.png
    task.spawn(function()
        local loadingAsset = nil
        for _, asset in ipairs(ASSETS) do
            if asset.name == "loading.png" then
                loadingAsset = asset
                break
            end
        end
        
        if loadingAsset then
            AssetDownloader:DownloadAsset(loadingAsset, function(name, progress, size, status)
                print(string.format("[LOADING.PNG] %s - %.0f%%", status, progress * 100))
                
                if (status == "complete" or status == "cached") then
                    local path = ASSETS_FOLDER .. "/" .. name
                    AssetDownloader:LoadAsset(path, LoadingImage)
                end
            end)
        end
    end)
    
    -- Dark overlay for readability
    local Overlay = Instance.new("Frame")
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3 = GUI.Colors.Overlay
    Overlay.BackgroundTransparency = 0.4
    Overlay.BorderSizePixel = 0
    Overlay.ZIndex = GUI.ZLayers.LoadingScreen + 2
    Overlay.Parent = LoaderScreen
    
    -- Gradient from left
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
    }
    gradient.Rotation = 0
    gradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(0.6, 0.7),
        NumberSequenceKeypoint.new(1, 1)
    }
    gradient.Parent = Overlay
    
    -- TEXT CONTAINER ON LEFT SIDE
    local containerWidth = GetResponsiveValue(600, 340, 450)
    local containerHeight = GetResponsiveValue(400, 280, 340)
    
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0, containerWidth, 0, containerHeight)
    Container.Position = UDim2.new(0, 50, 0.5, -containerHeight/2)
    Container.BackgroundTransparency = 1
    Container.ZIndex = GUI.ZLayers.LoadingScreen + 3
    Container.Parent = LoaderScreen
    
    local logoSize = GetResponsiveValue(62, 44, 52)
    local Logo = CreateAnimatedGradientText(
        Container,
        "HOHO'S BOUNTY",
        UDim2.new(1, 0, 0, logoSize + 18),
        UDim2.new(0, 0, 0, 0),
        logoSize,
        GUI.ZLayers.LoadingScreen + 4
    )
    
    local badgeSize = GetResponsiveValue(14, 11, 12)
    local VersionBadge = Instance.new("TextLabel")
    VersionBadge.Text = "REMAKE v9.0 - By Ryu & Caucker"
    VersionBadge.Size = UDim2.new(1, 0, 0, badgeSize + 14)
    VersionBadge.Position = UDim2.new(0, 0, 0, logoSize + 26)
    VersionBadge.BackgroundTransparency = 1
    VersionBadge.Font = Enum.Font.GothamMedium
    VersionBadge.TextColor3 = GUI.Colors.Primary
    VersionBadge.TextSize = badgeSize
    VersionBadge.TextTransparency = 1
    VersionBadge.TextXAlignment = Enum.TextXAlignment.Left
    VersionBadge.ZIndex = GUI.ZLayers.LoadingScreen + 4
    VersionBadge.Parent = Container
    
    local progressY = GetResponsiveValue(160, 130, 145)
    local ProgressBar = Instance.new("Frame")
    ProgressBar.Size = UDim2.new(1, -40, 0, 6)
    ProgressBar.Position = UDim2.new(0, 0, 0, progressY)
    ProgressBar.BackgroundColor3 = GUI.Colors.Surface
    ProgressBar.BorderSizePixel = 0
    ProgressBar.BackgroundTransparency = 1
    ProgressBar.ZIndex = GUI.ZLayers.LoadingScreen + 4
    ProgressBar.Parent = Container
    
    local ProgressCorner = Instance.new("UICorner")
    ProgressCorner.CornerRadius = UDim.new(1, 0)
    ProgressCorner.Parent = ProgressBar
    
    local Progress = Instance.new("Frame")
    Progress.Size = UDim2.new(0, 0, 1, 0)
    Progress.BackgroundColor3 = GUI.Colors.Primary
    Progress.BorderSizePixel = 0
    Progress.ZIndex = GUI.ZLayers.LoadingScreen + 5
    Progress.Parent = ProgressBar
    
    local ProgressCorner2 = Instance.new("UICorner")
    ProgressCorner2.CornerRadius = UDim.new(1, 0)
    ProgressCorner2.Parent = Progress
    
    local statusSize = GetResponsiveValue(15, 11, 13)
    local StatusText = Instance.new("TextLabel")
    StatusText.Text = "Initializing..."
    StatusText.Size = UDim2.new(1, -40, 0, statusSize + 8)
    StatusText.Position = UDim2.new(0, 0, 0, progressY + 26)
    StatusText.BackgroundTransparency = 1
    StatusText.Font = Enum.Font.GothamMedium
    StatusText.TextColor3 = GUI.Colors.TextMuted
    StatusText.TextSize = statusSize
    StatusText.TextTransparency = 1
    StatusText.TextXAlignment = Enum.TextXAlignment.Left
    StatusText.ZIndex = GUI.ZLayers.LoadingScreen + 4
    StatusText.Parent = Container
    
    local percentSize = GetResponsiveValue(42, 28, 35)
    local PercentText = CreateAnimatedGradientText(
        Container,
        "0%",
        UDim2.new(1, -40, 0, percentSize + 8),
        UDim2.new(0, 0, 0, progressY + 52),
        percentSize,
        GUI.ZLayers.LoadingScreen + 4
    )
    
    local detailsY = progressY + 110
    local DetailsContainer = Instance.new("ScrollingFrame")
    DetailsContainer.Size = UDim2.new(1, -40, 0, 140)
    DetailsContainer.Position = UDim2.new(0, 0, 0, detailsY)
    DetailsContainer.BackgroundTransparency = 1
    DetailsContainer.BorderSizePixel = 0
    DetailsContainer.ScrollBarThickness = 4
    DetailsContainer.ScrollBarImageColor3 = GUI.Colors.Primary
    DetailsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    DetailsContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    DetailsContainer.ZIndex = GUI.ZLayers.LoadingScreen + 4
    DetailsContainer.Parent = Container
    
    local DetailsLayout = Instance.new("UIListLayout")
    DetailsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    DetailsLayout.Padding = UDim.new(0, 6)
    DetailsLayout.Parent = DetailsContainer
    
    Tween(Logo, {TextTransparency = 0}, 0.8)
    task.wait(0.2)
    Tween(VersionBadge, {TextTransparency = 0}, 0.8)
    task.wait(0.2)
    Tween(ProgressBar, {BackgroundTransparency = 0.5}, 0.8)
    Tween(StatusText, {TextTransparency = 0}, 0.8)
    Tween(PercentText, {TextTransparency = 0}, 0.8)
    
    local downloadItems = {}
    
    return {
        Screen = LoaderScreen,
        Progress = Progress,
        Status = StatusText,
        Percent = PercentText,
        Details = DetailsContainer,
        LoadingImage = LoadingImage,
        
        AddDownloadItem = function(assetName)
            local itemSize = GetResponsiveValue(12, 9, 10)
            local Item = Instance.new("Frame")
            Item.Size = UDim2.new(1, 0, 0, itemSize + 10)
            Item.BackgroundColor3 = GUI.Colors.SurfaceLight
            Item.BorderSizePixel = 0
            Item.ZIndex = GUI.ZLayers.LoadingScreen + 5
            Item.Parent = DetailsContainer
            
            local ItemCorner = Instance.new("UICorner")
            ItemCorner.CornerRadius = UDim.new(0, 5)
            ItemCorner.Parent = Item
            
            local NameLabel = Instance.new("TextLabel")
            NameLabel.Text = assetName
            NameLabel.Size = UDim2.new(0.6, -8, 1, 0)
            NameLabel.Position = UDim2.new(0, 8, 0, 0)
            NameLabel.BackgroundTransparency = 1
            NameLabel.Font = Enum.Font.GothamMedium
            NameLabel.TextColor3 = GUI.Colors.Text
            NameLabel.TextSize = itemSize
            NameLabel.TextXAlignment = Enum.TextXAlignment.Left
            NameLabel.TextTruncate = Enum.TextTruncate.AtEnd
            NameLabel.ZIndex = GUI.ZLayers.LoadingScreen + 6
            NameLabel.Parent = Item
            
            local StatusLabel = Instance.new("TextLabel")
            StatusLabel.Text = "Waiting..."
            StatusLabel.Size = UDim2.new(0.4, -8, 1, 0)
            StatusLabel.Position = UDim2.new(0.6, 0, 0, 0)
            StatusLabel.BackgroundTransparency = 1
            StatusLabel.Font = Enum.Font.Gotham
            StatusLabel.TextColor3 = GUI.Colors.TextMuted
            StatusLabel.TextSize = itemSize - 1
            StatusLabel.TextXAlignment = Enum.TextXAlignment.Right
            StatusLabel.ZIndex = GUI.ZLayers.LoadingScreen + 6
            StatusLabel.Parent = Item
            
            downloadItems[assetName] = {
                Frame = Item,
                Status = StatusLabel
            }
            
            return Item
        end,
        
        UpdateDownloadItem = function(assetName, progress, size, status)
            if downloadItems[assetName] then
                local statusText = ""
                local color = GUI.Colors.TextMuted
                
                if status == "downloading" then
                    statusText = string.format("%.0f%%", progress * 100)
                    color = GUI.Colors.Primary
                elseif status == "complete" then
                    statusText = "✓ Complete"
                    color = GUI.Colors.Success
                elseif status == "cached" then
                    statusText = "✓ Cached"
                    color = GUI.Colors.Success
                elseif status == "failed" then
                    statusText = "✗ Failed"
                    color = GUI.Colors.Error
                elseif status == "lazy" then
                    statusText = "⏭ Lazy"
                    color = GUI.Colors.Warning
                else
                    statusText = status
                end
                
                downloadItems[assetName].Status.Text = statusText
                downloadItems[assetName].Status.TextColor3 = color
            end
        end,
        
        Update = function(progress, statusText)
            if StatusText and StatusText.Parent then
                StatusText.Text = statusText or "Loading..."
            end
            if PercentText and PercentText.Parent then
                PercentText.Text = math.floor(progress * 100) .. "%"
            end
            if Progress and Progress.Parent then
                Tween(Progress, {Size = UDim2.new(progress, 0, 1, 0)}, 0.3)
            end
        end,
        
        Complete = function()
            if not LoaderScreen or not LoaderScreen.Parent then return end
            
            if StatusText then StatusText.Text = "Ready!" end
            if PercentText then PercentText.Text = "100%" end
            
            task.wait(0.8)
            
            Tween(LoaderScreen, {BackgroundTransparency = 1}, 1)
            
            for _, child in pairs(LoaderScreen:GetDescendants()) do
                if child:IsA("TextLabel") or child:IsA("Frame") or child:IsA("ImageLabel") then
                    pcall(function()
                        if child.TextTransparency then
                            Tween(child, {TextTransparency = 1, BackgroundTransparency = 1}, 1)
                        else
                            Tween(child, {BackgroundTransparency = 1, ImageTransparency = 1}, 1)
                        end
                    end)
                end
            end
            
            task.wait(1.2)
            
            if LoaderScreen and LoaderScreen.Parent then
                LoaderScreen:Destroy()
            end
        end
    }
end

-- ============================================
-- ASSET INITIALIZATION
-- ============================================

function GUI.InitAssets()
    local loader = GUI.CreateAdvancedLoader()
    if not loader then return end
    
    loader.Update(0.05, "Creating workspace...")
    
    PersistentStorage:Init()
    
    task.wait(1)
    
    loader.Update(0.15, "Preparing downloads...")
    
    table.sort(ASSETS, function(a, b)
        return (a.priority or 99) < (b.priority or 99)
    end)
    
    for _, asset in ipairs(ASSETS) do
        loader.AddDownloadItem(asset.name)
    end
    
    task.wait(0.3)
    
    loader.UpdateDownloadItem("loading.png", 1, 0, "cached")
    
    local totalSize = 0
    local downloadedSize = 0
    local completedDownloads = 0
    local lazyLoadCount = 0
    
    for _, asset in ipairs(ASSETS) do
        totalSize = totalSize + asset.size
    end
    
    for i, asset in ipairs(ASSETS) do
        if asset.name == "loading.png" then 
            loader.UpdateDownloadItem(asset.name, 1, asset.size, "cached")
            completedDownloads = completedDownloads + 1
            downloadedSize = downloadedSize + asset.size
            continue 
        end
        
        if asset.lazyLoad then
            loader.UpdateDownloadItem(asset.name, 0, asset.size, "lazy")
            lazyLoadCount = lazyLoadCount + 1
            completedDownloads = completedDownloads + 1
            downloadedSize = downloadedSize + asset.size
        else
            loader.Update(0.15 + (i - 1) * 0.6 / #ASSETS, "Downloading " .. asset.name .. "...")
            
            AssetDownloader:DownloadAsset(asset, function(name, progress, size, status)
                loader.UpdateDownloadItem(name, progress, size, status)
                
                if status == "complete" or status == "cached" then
                    downloadedSize = downloadedSize + size
                    completedDownloads = completedDownloads + 1
                    local totalProgress = 0.15 + (downloadedSize / totalSize) * 0.6
                    loader.Update(totalProgress, "Downloaded " .. name)
                end
            end)
        end
    end
    
    loader.Update(0.8, "Waiting for downloads...")
    local maxWaitTime = 30
    local waitStartTime = tick()
    
    while completedDownloads < #ASSETS and (tick() - waitStartTime) < maxWaitTime do
        task.wait(0.1)
    end
    
    if lazyLoadCount > 0 then
        loader.Update(0.85, string.format("%d files marked for lazy load", lazyLoadCount))
    else
        loader.Update(0.85, "All downloads complete!")
    end
    
    task.wait(0.5)
    
    loader.Update(0.92, "Initializing systems...")
    
    pcall(function()
        GUI.MusicSound = Instance.new("Sound")
        GUI.MusicSound.Name = "HohoMusic"
        GUI.MusicSound.Looped = true
        GUI.MusicSound.Volume = GUI.Config.MusicVolume
        GUI.MusicSound.Parent = SoundService
        
        task.spawn(function()
            task.wait(2)
            
            local musicAsset = nil
            for _, asset in ipairs(ASSETS) do
                if asset.name == "sound.mp3" then
                    musicAsset = asset
                    break
                end
            end
            
            if musicAsset then
                AssetDownloader:LazyLoadAsset(musicAsset, GUI.MusicSound, function(name, progress, size, status)
                    print(string.format("[MUSIC] %s: %s", name, status))
                end)
                
                local musicPath = ASSETS_FOLDER .. "/sound.mp3"
                if isfile and isfile(musicPath) then
                    if isfile and isfile(MUSIC_TIME_FILE) and readfile then
                        local savedTime = tonumber(readfile(MUSIC_TIME_FILE))
                        if savedTime and savedTime > 0 then
                            GUI.MusicSound.TimePosition = savedTime
                        end
                    end
                    
                    if GUI.Config.MusicEnabled then
                        GUI.MusicSound:Play()
                    end
                end
            end
        end)
    end)
    
    task.wait(0.5)
    loader.Update(0.98, "Complete! Loading GUI...")
    
    task.wait(0.5)
    loader.Update(1, "Ready!")
    task.wait(0.8)
    loader.Complete()
    
    local teleportConnection = Players.LocalPlayer.OnTeleport:Connect(function()
        GUI.SaveMusicState()
    end)
    GUI.AddConnection(teleportConnection)
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
                writefile(MUSIC_TIME_FILE, tostring(timePos))
            end
        end
    end)
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
    
    DetectDevice()
    
    local GUIVars = {}
    
    GUI.SkibidiGui = Instance.new("ScreenGui")
    GUI.SkibidiGui.Name = "HohosBountyGui"
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
    
    local mainWidth, mainHeight, leftPanelWidth, rightPanelWidth
    
    if GUI.IsMobile then
        mainWidth = math.min(GUI.ScreenSize.X * 0.95, 360)
        mainHeight = math.min(GUI.ScreenSize.Y * 0.7, 480)
        leftPanelWidth = 0
        rightPanelWidth = mainWidth
    elseif GUI.IsTablet then
        mainWidth = math.min(GUI.ScreenSize.X * 0.85, 650)
        mainHeight = math.min(GUI.ScreenSize.Y * 0.65, 420)
        leftPanelWidth = math.floor(mainWidth * 0.35)
        rightPanelWidth = mainWidth - leftPanelWidth
    else
        mainWidth = 800
        mainHeight = 480
        leftPanelWidth = 320
        rightPanelWidth = 480
    end
    
    local cornerRadius = GetResponsiveValue(14, 12, 13)
    local controlBarHeight = GetResponsiveValue(38, 34, 36)
    
    GUI.MainFrame = Instance.new("Frame")
    GUI.MainFrame.Name = "MainFrame"
    GUI.MainFrame.BackgroundColor3 = GUI.Colors.Background
    GUI.MainFrame.BackgroundTransparency = 0.1
    GUI.MainFrame.Position = UDim2.new(0.5, -mainWidth/2, 0.5, -mainHeight/2)
    GUI.MainFrame.Size = UDim2.new(0, 0, 0, 0)
    GUI.MainFrame.BorderSizePixel = 0
    GUI.MainFrame.ClipsDescendants = true
    GUI.MainFrame.ZIndex = GUI.ZLayers.MainGUI
    GUI.MainFrame.Parent = GUI.SkibidiGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, cornerRadius)
    MainCorner.Parent = GUI.MainFrame
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = GUI.Colors.Primary
    MainStroke.Thickness = 1.5
    MainStroke.Transparency = 0.3
    MainStroke.Parent = GUI.MainFrame
    
    local ControlsBar = Instance.new("Frame")
    ControlsBar.Name = "ControlsBar"
    ControlsBar.Size = UDim2.new(1, 0, 0, controlBarHeight)
    ControlsBar.BackgroundColor3 = GUI.Colors.Surface
    ControlsBar.BorderSizePixel = 0
    ControlsBar.ZIndex = GUI.ZLayers.Controls
    ControlsBar.Parent = GUI.MainFrame
    
    local ControlsCorner = Instance.new("UICorner")
    ControlsCorner.CornerRadius = UDim.new(0, cornerRadius)
    ControlsCorner.Parent = ControlsBar
    
    local ControlsMask = Instance.new("Frame")
    ControlsMask.Size = UDim2.new(1, 0, 0, cornerRadius + 5)
    ControlsMask.Position = UDim2.new(0, 0, 1, -(cornerRadius + 5))
    ControlsMask.BackgroundColor3 = GUI.Colors.Surface
    ControlsMask.BorderSizePixel = 0
    ControlsMask.ZIndex = GUI.ZLayers.Controls
    ControlsMask.Parent = ControlsBar
    
    local buttonSize = GetResponsiveValue(12, 10, 11)
    local buttonSpacing = GetResponsiveValue(18, 16, 17)
    local buttonStartX = GetResponsiveValue(14, 11, 12)
    
    local function CreateControlButton(color, position, onClick)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, buttonSize, 0, buttonSize)
        btn.Position = UDim2.new(0, buttonStartX + (position * buttonSpacing), 0.5, -buttonSize/2)
        btn.BackgroundColor3 = color
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.ZIndex = GUI.ZLayers.Controls + 1
        btn.Parent = ControlsBar
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = btn
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Thickness = 1
        stroke.Transparency = 0.8
        stroke.Parent = btn
        
        btn.MouseEnter:Connect(function()
            Tween(btn, {Size = UDim2.new(0, buttonSize + 2, 0, buttonSize + 2)}, 0.15)
            Tween(stroke, {Transparency = 0.3}, 0.15)
        end)
        
        btn.MouseLeave:Connect(function()
            Tween(btn, {Size = UDim2.new(0, buttonSize, 0, buttonSize)}, 0.15)
            Tween(stroke, {Transparency = 0.8}, 0.15)
        end)
        
        btn.MouseButton1Click:Connect(onClick)
        
        return btn
    end
    
    CreateControlButton(Color3.fromRGB(255, 95, 86), 0, function()
        GUI.Cleanup()
        if getgenv()._SkibidiShuttingDown ~= nil then
            getgenv()._SkibidiShuttingDown = true
        end
    end)
    
    CreateControlButton(Color3.fromRGB(255, 189, 46), 1, function()
        GUI.IsPaused = not GUI.IsPaused
        
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
    
    local minWidth = GetResponsiveValue(200, 160, 180)
    CreateControlButton(Color3.fromRGB(39, 201, 63), 2, function()
        GUI.IsMinimized = not GUI.IsMinimized
        
        if GUI.IsMinimized then
            Tween(GUI.MainFrame, {Size = UDim2.new(0, minWidth, 0, controlBarHeight)}, 0.4, Enum.EasingStyle.Quart)
        else
            Tween(GUI.MainFrame, {Size = UDim2.new(0, mainWidth, 0, mainHeight)}, 0.4, Enum.EasingStyle.Quart)
        end
    end)
    
    local titleSize = GetResponsiveValue(13, 10, 11)
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Text = "HOHO'S BOUNTY REMAKE"
    TitleLabel.Size = UDim2.new(1, -220, 1, 0)
    TitleLabel.Position = UDim2.new(0, buttonStartX + (3 * buttonSpacing) + 8, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = titleSize
    TitleLabel.TextColor3 = GUI.Colors.Text
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = GUI.ZLayers.Controls + 1
    TitleLabel.Parent = ControlsBar
    
    local versionBadgeWidth = GetResponsiveValue(110, 90, 100)
    local versionBadgeHeight = GetResponsiveValue(24, 20, 22)
    
    local VersionBadge = Instance.new("Frame")
    VersionBadge.Size = UDim2.new(0, versionBadgeWidth, 0, versionBadgeHeight)
    VersionBadge.Position = UDim2.new(1, -versionBadgeWidth - 10, 0.5, -versionBadgeHeight/2)
    VersionBadge.BackgroundColor3 = GUI.Colors.Primary
    VersionBadge.BorderSizePixel = 0
    VersionBadge.ZIndex = GUI.ZLayers.Controls + 1
    VersionBadge.Parent = ControlsBar
    
    local VersionCorner = Instance.new("UICorner")
    VersionCorner.CornerRadius = UDim.new(0, 6)
    VersionCorner.Parent = VersionBadge
    
    local versionTextSize = GetResponsiveValue(11, 9, 10)
    local VersionText = Instance.new("TextLabel")
    VersionText.Text = "v9.0"
    VersionText.Size = UDim2.new(1, 0, 1, 0)
    VersionText.BackgroundTransparency = 1
    VersionText.Font = Enum.Font.GothamBold
    VersionText.TextColor3 = Color3.fromRGB(0, 0, 0)
    VersionText.TextSize = versionTextSize
    VersionText.ZIndex = GUI.ZLayers.Controls + 2
    VersionText.Parent = VersionBadge
    
    GUI.AddTask(task.spawn(function()
        while VersionBadge and VersionBadge.Parent do
            Tween(VersionBadge, {BackgroundColor3 = GUI.Colors.PrimaryGlow}, 2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(2)
            if not VersionBadge or not VersionBadge.Parent then break end
            Tween(VersionBadge, {BackgroundColor3 = GUI.Colors.Primary}, 2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(2)
        end
    end))
    
    if leftPanelWidth > 0 then
        local LeftPanel = Instance.new("Frame")
        LeftPanel.Name = "LeftPanel"
        LeftPanel.Size = UDim2.new(0, leftPanelWidth, 1, -controlBarHeight)
        LeftPanel.Position = UDim2.new(0, 0, 0, controlBarHeight)
        LeftPanel.BackgroundTransparency = 1
        LeftPanel.BorderSizePixel = 0
        LeftPanel.ClipsDescendants = true
        LeftPanel.ZIndex = GUI.ZLayers.MainGUI
        LeftPanel.Parent = GUI.MainFrame
        
        local bgPath = ASSETS_FOLDER .. "/background.png"
        local backluaPath = ASSETS_FOLDER .. "/backlua.png"
        local imageLoaded = false
        
        if isfile and isfile(bgPath) then
            pcall(function()
                local BgImage = Instance.new("ImageLabel")
                BgImage.Size = UDim2.new(1, 0, 1, 0)
                BgImage.BackgroundTransparency = 1
                BgImage.ScaleType = Enum.ScaleType.Crop
                BgImage.ZIndex = GUI.ZLayers.MainGUI
                BgImage.Parent = LeftPanel
                
                local success = AssetDownloader:LoadAsset(bgPath, BgImage)
                if success then
                    imageLoaded = true
                    print("[GUI] ✅ Loaded background.png")
                else
                    BgImage:Destroy()
                end
            end)
        end
        
        if not imageLoaded and isfile and isfile(backluaPath) then
            pcall(function()
                local BackgroundImage = Instance.new("ImageLabel")
                BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
                BackgroundImage.BackgroundTransparency = 1
                BackgroundImage.ScaleType = Enum.ScaleType.Crop
                BackgroundImage.ImageTransparency = 0
                BackgroundImage.ZIndex = GUI.ZLayers.MainGUI
                BackgroundImage.Parent = LeftPanel
                
                AssetDownloader:LoadAsset(backluaPath, BackgroundImage)
                print("[GUI] ✅ Loaded backlua.png (fallback)")
            end)
        end
        
        local ImageOverlay = Instance.new("Frame")
        ImageOverlay.Size = UDim2.new(1, 0, 1, 0)
        ImageOverlay.BackgroundColor3 = GUI.Colors.Overlay
        ImageOverlay.BackgroundTransparency = 0.3
        ImageOverlay.BorderSizePixel = 0
        ImageOverlay.ZIndex = GUI.ZLayers.MainGUI + 1
        ImageOverlay.Parent = LeftPanel
        
        local OverlayGradient = Instance.new("UIGradient")
        OverlayGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
            ColorSequenceKeypoint.new(1, GUI.Colors.Background)
        }
        OverlayGradient.Rotation = 90
        OverlayGradient.Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0.4),
            NumberSequenceKeypoint.new(1, 0)
        }
        OverlayGradient.Parent = ImageOverlay
        
        local logoSize = GetResponsiveValue(42, 32, 38)
        local LeftLogo = Instance.new("TextLabel")
        LeftLogo.Text = "HOHO'S\nBOUNTY"
        LeftLogo.Size = UDim2.new(1, -16, 0, (logoSize + 16) * 2)
        LeftLogo.Position = UDim2.new(0, 8, 1, -((logoSize + 16) * 2 + 8))
        LeftLogo.BackgroundTransparency = 1
        LeftLogo.Font = Enum.Font.GothamBold
        LeftLogo.TextColor3 = GUI.Colors.Text
        LeftLogo.TextSize = logoSize
        LeftLogo.TextXAlignment = Enum.TextXAlignment.Left
        LeftLogo.TextYAlignment = Enum.TextYAlignment.Bottom
        LeftLogo.ZIndex = GUI.ZLayers.MainGUI + 2
        LeftLogo.Parent = LeftPanel
        
        local authorWidth = GetResponsiveValue(140, 110, 125)
        local authorHeight = GetResponsiveValue(20, 16, 18)
        local AuthorBadge = Instance.new("Frame")
        AuthorBadge.Size = UDim2.new(0, authorWidth, 0, authorHeight)
        AuthorBadge.Position = UDim2.new(0, 8, 0, 8)
        AuthorBadge.BackgroundColor3 = GUI.Colors.Surface
        AuthorBadge.BackgroundTransparency = 0.3
        AuthorBadge.BorderSizePixel = 0
        AuthorBadge.ZIndex = GUI.ZLayers.MainGUI + 2
        AuthorBadge.Parent = LeftPanel
        
        local AuthorCorner = Instance.new("UICorner")
        AuthorCorner.CornerRadius = UDim.new(0, 6)
        AuthorCorner.Parent = AuthorBadge
        
        local authorTextSize = GetResponsiveValue(9, 7, 8)
        local AuthorText = Instance.new("TextLabel")
        AuthorText.Text = "By Ryu & Caucker"
        AuthorText.Size = UDim2.new(1, 0, 1, 0)
        AuthorText.BackgroundTransparency = 1
        AuthorText.Font = Enum.Font.GothamMedium
        AuthorText.TextColor3 = GUI.Colors.TextMuted
        AuthorText.TextSize = authorTextSize
        AuthorText.ZIndex = GUI.ZLayers.MainGUI + 3
        AuthorText.Parent = AuthorBadge
    end
    
    local ContentPanel = Instance.new("Frame")
    ContentPanel.Name = "ContentPanel"
    ContentPanel.Size = UDim2.new(0, rightPanelWidth, 1, -controlBarHeight)
    ContentPanel.Position = UDim2.new(0, leftPanelWidth, 0, controlBarHeight)
    ContentPanel.BackgroundColor3 = GUI.Colors.Surface
    ContentPanel.BackgroundTransparency = 0.2
    ContentPanel.BorderSizePixel = 0
    ContentPanel.ClipsDescendants = true
    ContentPanel.ZIndex = GUI.ZLayers.MainGUI
    ContentPanel.Parent = GUI.MainFrame
    
    local headerHeight = GetResponsiveValue(70, 58, 64)
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, headerHeight)
    Header.BackgroundTransparency = 1
    Header.ZIndex = GUI.ZLayers.MainGUI + 1
    Header.Parent = ContentPanel
    
    local headerTitleSize = GetResponsiveValue(20, 16, 18)
    local headerPadding = GetResponsiveValue(20, 14, 17)
    
    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Text = "CONTROL PANEL"
    HeaderTitle.Size = UDim2.new(1, -headerPadding * 2, 0, headerTitleSize + 10)
    HeaderTitle.Position = UDim2.new(0, headerPadding, 0, 14)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Font = Enum.Font.GothamBold
    HeaderTitle.TextColor3 = GUI.Colors.Text
    HeaderTitle.TextSize = headerTitleSize
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeaderTitle.ZIndex = GUI.ZLayers.MainGUI + 2
    HeaderTitle.Parent = Header
    
    local subtitleSize = GetResponsiveValue(10, 8, 9)
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Text = "Total Lifetime Stats"
    Subtitle.Size = UDim2.new(1, -headerPadding * 2, 0, subtitleSize + 6)
    Subtitle.Position = UDim2.new(0, headerPadding, 0, headerTitleSize + 26)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextColor3 = GUI.Colors.Primary
    Subtitle.TextSize = subtitleSize
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.ZIndex = GUI.ZLayers.MainGUI + 2
    Subtitle.Parent = Header
    
    local statsPadding = GetResponsiveValue(20, 14, 17)
    local statsTop = headerHeight + 6
    
    local StatsContainer = Instance.new("ScrollingFrame")
    StatsContainer.Position = UDim2.new(0, statsPadding, 0, statsTop)
    StatsContainer.Size = UDim2.new(1, -statsPadding * 2, 1, -statsTop - 10)
    StatsContainer.BackgroundTransparency = 1
    StatsContainer.BorderSizePixel = 0
    StatsContainer.ScrollBarThickness = 4
    StatsContainer.ScrollBarImageColor3 = GUI.Colors.Primary
    StatsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    StatsContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    StatsContainer.ZIndex = GUI.ZLayers.MainGUI + 1
    StatsContainer.Parent = ContentPanel
    
    local StatsLayout = Instance.new("UIListLayout")
    StatsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    StatsLayout.Padding = UDim.new(0, GetResponsiveValue(10, 8, 9))
    StatsLayout.Parent = StatsContainer
    
    local function CreateStatCard(label, value, iconType, order)
        local cardHeight = GetResponsiveValue(68, 56, 62)
        
        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(1, 0, 0, cardHeight)
        Card.BackgroundColor3 = GUI.Colors.SurfaceLight
        Card.BorderSizePixel = 0
        Card.LayoutOrder = order
        Card.ZIndex = GUI.ZLayers.MainGUI + 2
        Card.Parent = StatsContainer
        
        local CardCorner = Instance.new("UICorner")
        CardCorner.CornerRadius = UDim.new(0, GetResponsiveValue(12, 10, 11))
        CardCorner.Parent = Card
        
        local CardStroke = Instance.new("UIStroke")
        CardStroke.Color = GUI.Colors.Border
        CardStroke.Thickness = 1
        CardStroke.Transparency = 0.6
        CardStroke.Parent = Card
        
        local iconContainerSize = GetResponsiveValue(48, 42, 45)
        local iconContainerX = GetResponsiveValue(14, 11, 12)
        
        local IconContainer = Instance.new("Frame")
        IconContainer.Size = UDim2.new(0, iconContainerSize, 0, iconContainerSize)
        IconContainer.Position = UDim2.new(0, iconContainerX, 0.5, -iconContainerSize/2)
        IconContainer.BackgroundColor3 = GUI.Colors.Surface
        IconContainer.BorderSizePixel = 0
        IconContainer.ZIndex = GUI.ZLayers.MainGUI + 3
        IconContainer.Parent = Card
        
        local IconCorner = Instance.new("UICorner")
        IconCorner.CornerRadius = UDim.new(0, GetResponsiveValue(12, 10, 11))
        IconCorner.Parent = IconContainer
        
        local IconStroke = Instance.new("UIStroke")
        IconStroke.Color = GUI.Colors.Primary
        IconStroke.Thickness = 1.5
        IconStroke.Transparency = 0.5
        IconStroke.Parent = IconContainer
        
        local iconSize = GetResponsiveValue(26, 22, 24)
        local Icon = Icons.Create(IconContainer, iconType, iconSize, GUI.Colors.Primary)
        Icon.Position = UDim2.new(0.5, -iconSize/2, 0.5, -iconSize/2)
        Icon.ZIndex = GUI.ZLayers.MainGUI + 4
        
        local labelX = iconContainerX + iconContainerSize + GetResponsiveValue(12, 10, 11)
        local labelSize = GetResponsiveValue(10, 8, 9)
        
        local Label = Instance.new("TextLabel")
        Label.Text = label
        Label.Size = UDim2.new(1, -labelX - 8, 0, labelSize + 8)
        Label.Position = UDim2.new(0, labelX, 0, cardHeight * 0.22)
        Label.BackgroundTransparency = 1
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = labelSize
        Label.TextColor3 = GUI.Colors.TextMuted
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.ZIndex = GUI.ZLayers.MainGUI + 3
        Label.Parent = Card
        
        local valueSize = GetResponsiveValue(22, 16, 19)
        
        local Value = Instance.new("TextLabel")
        Value.Text = value
        Value.Size = UDim2.new(1, -labelX - 8, 0, valueSize + 6)
        Value.Position = UDim2.new(0, labelX, 0, cardHeight * 0.56)
        Value.BackgroundTransparency = 1
        Value.Font = Enum.Font.GothamBold
        Value.TextSize = valueSize
        Value.TextColor3 = GUI.Colors.Text
        Value.TextXAlignment = Enum.TextXAlignment.Left
        Value.TextTruncate = Enum.TextTruncate.AtEnd
        Value.ZIndex = GUI.ZLayers.MainGUI + 3
        Value.Parent = Card
        
        local hoverConnection = Card.MouseEnter:Connect(function()
            Tween(CardStroke, {Transparency = 0.2, Color = GUI.Colors.Primary}, 0.2)
            Tween(IconStroke, {Transparency = 0.1}, 0.2)
            Tween(Card, {BackgroundColor3 = GUI.Colors.Surface}, 0.2)
        end)
        GUI.AddConnection(hoverConnection)
        
        local leaveConnection = Card.MouseLeave:Connect(function()
            Tween(CardStroke, {Transparency = 0.6, Color = GUI.Colors.Border}, 0.2)
            Tween(IconStroke, {Transparency = 0.5}, 0.2)
            Tween(Card, {BackgroundColor3 = GUI.Colors.SurfaceLight}, 0.2)
        end)
        GUI.AddConnection(leaveConnection)
        
        task.wait(order * 0.03)
        
        return Value
    end
    
    local stats = GUI.PersistentData and GUI.PersistentData:Load() or {}
    
    GUIVars.TargetValue = CreateStatCard("TARGET", "Searching...", "target", 1)
    GUIVars.StateValue = CreateStatCard("STATUS", "Initializing", "status", 2)
    GUIVars.BountyValue = CreateStatCard(
        "TOTAL BOUNTY",
        "+" .. tostring(stats.TotalBountyGained or 0),
        "bounty",
        3
    )
    GUIVars.TimeValue = CreateStatCard("TOTAL TIME", "0:00", "time", 4)
    
    getgenv().GUIVars = GUIVars
    
    local dragging, dragInput, dragStart, startPos
    
    local dragBeganConnection = ControlsBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            if GUI.IsMinimized then return end
            
            dragging = true
            dragStart = input.Position
            startPos = GUI.MainFrame.Position
            
            local endConnection
            endConnection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
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
    
    Tween(GUI.MainFrame, {Size = UDim2.new(0, mainWidth, 0, mainHeight)}, 0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    task.spawn(function()
        GUI.InitAssets()
    end)
    
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
-- SERVER CHANGE SCREEN (FULLSCREEN IMAGE, TEXT LEFT!)
-- ============================================

function GUI.ShowServerChangeScreen()
    if not GUI.SkibidiGui then return end
    
    local Screen = Instance.new("Frame")
    Screen.Name = "ServerHopScreen"
    Screen.Size = UDim2.new(1, 0, 1, 0)
    Screen.BackgroundColor3 = GUI.Colors.Background
    Screen.BackgroundTransparency = 0
    Screen.ZIndex = GUI.ZLayers.ServerChange
    Screen.Parent = GUI.SkibidiGui
    
    -- FULLSCREEN CENTERED IMAGE
    local BgImage = Instance.new("ImageLabel")
    BgImage.Size = UDim2.new(1, 0, 1, 0)
    BgImage.Position = UDim2.new(0.5, 0, 0.5, 0)
    BgImage.AnchorPoint = Vector2.new(0.5, 0.5)
    BgImage.BackgroundTransparency = 1
    BgImage.ScaleType = Enum.ScaleType.Crop
    BgImage.ZIndex = GUI.ZLayers.ServerChange + 1
    BgImage.Parent = Screen

    -- Load change.png
    task.spawn(function()
        local changeAsset = nil
        for _, asset in ipairs(ASSETS) do
            if asset.name == "change.png" then
                changeAsset = asset
                break
            end
        end
        
        if changeAsset then
            print("[GUI] 📥 Lazy loading change.png...")
            AssetDownloader:LazyLoadAsset(changeAsset, BgImage, function(name, progress, size, status)
                print(string.format("[CHANGE.PNG] %s: %s", name, status))
            end)
        end
    end)
    
    -- Dark overlay
    local Overlay = Instance.new("Frame")
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3 = GUI.Colors.Overlay
    Overlay.BackgroundTransparency = 0.4
    Overlay.BorderSizePixel = 0
    Overlay.ZIndex = GUI.ZLayers.ServerChange + 2
    Overlay.Parent = Screen
    
    -- Gradient from left for text visibility
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
    }
    gradient.Rotation = 0
    gradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(0.6, 0.8),
        NumberSequenceKeypoint.new(1, 1)
    }
    gradient.Parent = Overlay
    
    -- TEXT CONTAINER ON LEFT SIDE
    local containerWidth = GetResponsiveValue(600, 340, 450)
    local containerHeight = GetResponsiveValue(200, 160, 180)
    
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0, containerWidth, 0, containerHeight)
    Container.Position = UDim2.new(0, 50, 0.5, -containerHeight/2)
    Container.BackgroundTransparency = 1
    Container.ZIndex = GUI.ZLayers.ServerChange + 3
    Container.Parent = Screen
    
    local titleSize = GetResponsiveValue(56, 36, 46)
    local Title = CreateAnimatedGradientText(
        Container,
        "CHANGING SERVER",
        UDim2.new(1, 0, 0, titleSize + 20),
        UDim2.new(0, 0, 0, 0),
        titleSize,
        GUI.ZLayers.ServerChange + 4
    )
    
    local subtitleSize = GetResponsiveValue(20, 14, 17)
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Text = "Finding optimal server..."
    Subtitle.Size = UDim2.new(1, 0, 0, subtitleSize + 12)
    Subtitle.Position = UDim2.new(0, 0, 0, titleSize + 32)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextSize = subtitleSize
    Subtitle.TextColor3 = GUI.Colors.Primary
    Subtitle.TextTransparency = 1
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.ZIndex = GUI.ZLayers.ServerChange + 4
    Subtitle.Parent = Container
    
    local progressY = titleSize + 76
    local ProgressBg = Instance.new("Frame")
    ProgressBg.Size = UDim2.new(1, 0, 0, 6)
    ProgressBg.Position = UDim2.new(0, 0, 0, progressY)
    ProgressBg.BackgroundColor3 = GUI.Colors.Surface
    ProgressBg.BorderSizePixel = 0
    ProgressBg.BackgroundTransparency = 1
    ProgressBg.ZIndex = GUI.ZLayers.ServerChange + 4
    ProgressBg.Parent = Container
    
    local ProgressCorner = Instance.new("UICorner")
    ProgressCorner.CornerRadius = UDim.new(1, 0)
    ProgressCorner.Parent = ProgressBg
    
    local Progress = Instance.new("Frame")
    Progress.Size = UDim2.new(0, 0, 1, 0)
    Progress.BackgroundColor3 = GUI.Colors.Primary
    Progress.BorderSizePixel = 0
    Progress.ZIndex = GUI.ZLayers.ServerChange + 5
    Progress.Parent = ProgressBg
    
    local ProgressCorner2 = Instance.new("UICorner")
    ProgressCorner2.CornerRadius = UDim.new(1, 0)
    ProgressCorner2.Parent = Progress
    
    Tween(Title, {TextTransparency = 0}, 0.7)
    task.wait(0.1)
    Tween(Subtitle, {TextTransparency = 0}, 0.7)
    task.wait(0.1)
    Tween(ProgressBg, {BackgroundTransparency = 0.4}, 0.7)
    
    Tween(Progress, {Size = UDim2.new(1, 0, 1, 0)}, 3.5, Enum.EasingStyle.Linear)
end

-- ============================================
-- BOOST SCREEN (FULLSCREEN IMAGE CENTERED!)
-- ============================================

function GUI.ShowBoostScreen()
    if GUI._BoostScreen then
        pcall(function() GUI._BoostScreen:Destroy() end)
    end
    
    local Screen = Instance.new("Frame")
    Screen.Name = "BoostScreen"
    Screen.Size = UDim2.new(1, 0, 1, 0)
    Screen.BackgroundTransparency = 1
    Screen.ZIndex = GUI.ZLayers.ServerChange
    Screen.Parent = GUI.SkibidiGui
    
    GUI._BoostScreen = Screen
    
    -- FULLSCREEN CENTERED BOOST IMAGE
    local BoostImage = Instance.new("ImageLabel")
    BoostImage.Size = UDim2.new(1, 0, 1, 0)
    BoostImage.Position = UDim2.new(0.5, 0, 0.5, 0)
    BoostImage.AnchorPoint = Vector2.new(0.5, 0.5)
    BoostImage.BackgroundTransparency = 1
    BoostImage.ScaleType = Enum.ScaleType.Crop
    BoostImage.ZIndex = GUI.ZLayers.ServerChange + 1
    BoostImage.Parent = Screen
    
    -- Load boost.png
    task.spawn(function()
        local boostAsset = nil
        for _, asset in ipairs(ASSETS) do
            if asset.name == "boost.png" then
                boostAsset = asset
                break
            end
        end
        
        if boostAsset then
            print("[GUI] 📥 Lazy loading boost.png...")
            AssetDownloader:LazyLoadAsset(boostAsset, BoostImage, function(name, progress, size, status)
                print(string.format("[BOOST.PNG] %s: %s", name, status))
            end)
            
            task.wait(5)
            if Screen and Screen.Parent then
                Tween(Screen, {BackgroundTransparency = 1}, 0.5)
                Tween(BoostImage, {ImageTransparency = 1}, 0.5)
                task.wait(0.6)
                Screen:Destroy()
            end
            GUI._BoostScreen = nil
        end
    end)
end

-- ============================================
-- CLEANUP
-- ============================================

function GUI.Cleanup()
    GUI.SaveMusicState()
    
    if getgenv().GetCurrentBounty then
        local currentBounty = getgenv().GetCurrentBounty()
        local initialBounty = getgenv().InitialBounty or 0
        local sessionGain = currentBounty - initialBounty
        local totalKills = getgenv().TotalKills or 0
        local sessionTime = math.floor(tick() - (getgenv().SessionStartTime or tick()))
        
        if GUI.PersistentData then
            local StoredData = GUI.PersistentData:Load() or {}
            GUI.PersistentData:Save({
                TotalBountyGained = (StoredData.TotalBountyGained or 0) + sessionGain,
                TotalKills = totalKills,
                SessionsCompleted = (StoredData.SessionsCompleted or 0) + 1,
                EliminatedPlayers = StoredData.EliminatedPlayers or {},
                LastSession = os.time()
            })
        end
    end
    
    for _, tween in ipairs(GUI.RunningTweens) do
        pcall(function() if tween then tween:Cancel() end end)
    end
    GUI.RunningTweens = {}
    
    for _, taskThread in ipairs(GUI.Tasks) do
        pcall(function() if taskThread then task.cancel(taskThread) end end)
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
        pcall(function() GUI._BoostScreen:Destroy() end)
        GUI._BoostScreen = nil
    end
    
    if GUI.VideoBackground then
        pcall(function() GUI.VideoBackground:Destroy() end)
        GUI.VideoBackground = nil
    end
    
    if GUI.SkibidiGui then
        pcall(function() GUI.SkibidiGui:Destroy() end)
        GUI.SkibidiGui = nil
    end
    
    GUI.MainFrame = nil
end

getgenv().HohosBountyRemake_v9_0 = GUI

return GUI
