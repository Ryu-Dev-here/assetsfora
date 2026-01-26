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

-- Modern accent colors - Animated theme
GUI.AccentColor = Color3.fromRGB(138, 43, 226) -- Blue Violet
GUI.SecondaryColor = Color3.fromRGB(255, 20, 147) -- Deep Pink
GUI.BackgroundColor = Color3.fromRGB(15, 15, 25)
GUI.SurfaceColor = Color3.fromRGB(25, 25, 40)
GUI.TextPrimary = Color3.fromRGB(240, 240, 255)
GUI.TextSecondary = Color3.fromRGB(150, 150, 180)

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
    MusicVolume = 0.5
}

-- Helper functions for cleanup
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

-- Smooth animations with cleanup tracking
local function SmoothTween(object, properties, duration, style, direction)
    if not object or not object.Parent then 
        return nil
    end
    
    local success, tween = pcall(function()
        return TweenService:Create(
            object,
            TweenInfo.new(
                duration or 0.5, 
                style or Enum.EasingStyle.Quint, 
                direction or Enum.EasingDirection.Out
            ),
            properties
        )
    end)
    
    if not success or not tween then
        return nil
    end
    
    table.insert(GUI.RunningTweens, tween)
    
    tween.Completed:Connect(function()
        local index = table.find(GUI.RunningTweens, tween)
        if index then
            table.remove(GUI.RunningTweens, index)
        end
    end)
    
    pcall(function()
        tween:Play()
    end)
    
    return tween
end

-- Animated particle system
local function CreateFloatingParticle(parent, color)
    if not parent or not parent.Parent then
        return nil
    end
    
    local particle = Instance.new("Frame")
    particle.Size = UDim2.new(0, math.random(3, 6), 0, math.random(3, 6))
    particle.BackgroundColor3 = color or GUI.AccentColor
    particle.BorderSizePixel = 0
    particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
    particle.BackgroundTransparency = math.random(30, 70) / 100
    particle.Parent = parent
    particle.ZIndex = 10
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = particle
    
    local animTask = task.spawn(function()
        while particle and particle.Parent and parent and parent.Parent do
            local success = pcall(function()
                local randomX = math.random()
                local randomY = math.random()
                local randomDuration = math.random(40, 80) / 10
                local randomTransparency = math.random(30, 90) / 100
                
                SmoothTween(particle, {
                    Position = UDim2.new(randomX, 0, randomY, 0),
                    BackgroundTransparency = randomTransparency
                }, randomDuration, Enum.EasingStyle.Sine)
            end)
            
            if not success then
                break
            end
            
            task.wait(math.random(30, 80) / 10)
        end
        
        if particle and particle.Parent then
            particle:Destroy()
        end
    end)
    
    GUI.AddTask(animTask)
    
    return particle
end

function GUI.SaveMusicState()
    if not GUI.MusicSound then 
        return 
    end
    
    pcall(function()
        if GUI.MusicSound.IsPlaying and writefile then
            local timePos = GUI.MusicSound.TimePosition
            if timePos and type(timePos) == "number" and timePos > 0 then
                writefile(TIME_PATH, tostring(timePos))
                print("[SKIBIDI] Music state saved: " .. timePos)
            end
        end
    end)
end

function GUI.CreateFullScreenLoader()
    local LoaderScreen = Instance.new("Frame")
    LoaderScreen.Name = "FullScreenLoader"
    LoaderScreen.Size = UDim2.new(1, 0, 1, 0)
    LoaderScreen.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
    LoaderScreen.BorderSizePixel = 0
    LoaderScreen.ZIndex = 1000
    LoaderScreen.Parent = GUI.SkibidiGui
    
    -- Animated gradient background
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 25)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(25, 15, 35)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
    }
    Gradient.Rotation = 45
    Gradient.Parent = LoaderScreen
    
    -- Rotate gradient continuously
    GUI.AddTask(task.spawn(function()
        while LoaderScreen and LoaderScreen.Parent and Gradient and Gradient.Parent do
            SmoothTween(Gradient, {Rotation = Gradient.Rotation + 360}, 10, Enum.EasingStyle.Linear)
            task.wait(10)
        end
    end))
    
    -- Particles for ambiance
    for i = 1, 30 do
        CreateFloatingParticle(LoaderScreen, i % 2 == 0 and GUI.AccentColor or GUI.SecondaryColor)
    end
    
    -- Center container
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0, 500, 0, 350)
    Container.Position = UDim2.new(0.5, -250, 0.5, -175)
    Container.BackgroundTransparency = 1
    Container.Parent = LoaderScreen
    
    -- Animated logo text
    local LogoText = Instance.new("TextLabel")
    LogoText.Text = "SKIBIDI"
    LogoText.Size = UDim2.new(1, 0, 0, 100)
    LogoText.BackgroundTransparency = 1
    LogoText.Font = Enum.Font.GothamBlack
    LogoText.TextColor3 = GUI.TextPrimary
    LogoText.TextSize = 72
    LogoText.TextTransparency = 1
    LogoText.Parent = Container
    
    -- Gradient on logo
    local LogoGradient = Instance.new("UIGradient")
    LogoGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, GUI.AccentColor),
        ColorSequenceKeypoint.new(0.5, GUI.SecondaryColor),
        ColorSequenceKeypoint.new(1, GUI.AccentColor)
    }
    LogoGradient.Rotation = 45
    LogoGradient.Parent = LogoText
    
    -- Subtitle
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Text = "AUTO FARM SYSTEM"
    Subtitle.Size = UDim2.new(1, 0, 0, 35)
    Subtitle.Position = UDim2.new(0, 0, 0, 100)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Font = Enum.Font.GothamMedium
    Subtitle.TextColor3 = GUI.TextSecondary
    Subtitle.TextSize = 18
    Subtitle.TextTransparency = 1
    Subtitle.Parent = Container
    
    -- Loading bar container
    local BarContainer = Instance.new("Frame")
    BarContainer.Size = UDim2.new(0.85, 0, 0, 8)
    BarContainer.Position = UDim2.new(0.075, 0, 0, 180)
    BarContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    BarContainer.BorderSizePixel = 0
    BarContainer.BackgroundTransparency = 1
    BarContainer.Parent = Container
    
    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(1, 0)
    BarCorner.Parent = BarContainer
    
    -- Progress bar
    local ProgressBar = Instance.new("Frame")
    ProgressBar.Size = UDim2.new(0, 0, 1, 0)
    ProgressBar.BackgroundColor3 = GUI.AccentColor
    ProgressBar.BorderSizePixel = 0
    ProgressBar.Parent = BarContainer
    
    local ProgressCorner = Instance.new("UICorner")
    ProgressCorner.CornerRadius = UDim.new(1, 0)
    ProgressCorner.Parent = ProgressBar
    
    -- Bar glow
    local BarGlow = Instance.new("Frame")
    BarGlow.Size = UDim2.new(1, 20, 1, 20)
    BarGlow.Position = UDim2.new(0, -10, 0, -10)
    BarGlow.BackgroundColor3 = GUI.AccentColor
    BarGlow.BackgroundTransparency = 0.7
    BarGlow.BorderSizePixel = 0
    BarGlow.ZIndex = 0
    BarGlow.Parent = ProgressBar
    
    local GlowCorner = Instance.new("UICorner")
    GlowCorner.CornerRadius = UDim.new(1, 0)
    GlowCorner.Parent = BarGlow
    
    -- Loading status text
    local StatusText = Instance.new("TextLabel")
    StatusText.Text = "Initializing..."
    StatusText.Size = UDim2.new(1, 0, 0, 30)
    StatusText.Position = UDim2.new(0, 0, 0, 210)
    StatusText.BackgroundTransparency = 1
    StatusText.Font = Enum.Font.GothamMedium
    StatusText.TextColor3 = GUI.TextSecondary
    StatusText.TextSize = 16
    StatusText.TextTransparency = 1
    StatusText.Parent = Container
    
    -- Percentage text
    local PercentText = Instance.new("TextLabel")
    PercentText.Text = "0%"
    PercentText.Size = UDim2.new(1, 0, 0, 40)
    PercentText.Position = UDim2.new(0, 0, 0, 250)
    PercentText.BackgroundTransparency = 1
    PercentText.Font = Enum.Font.GothamBold
    PercentText.TextColor3 = GUI.TextPrimary
    PercentText.TextSize = 32
    PercentText.TextTransparency = 1
    PercentText.Parent = Container
    
    -- Fade in animations
    SmoothTween(LogoText, {TextTransparency = 0}, 0.8)
    task.wait(0.2)
    SmoothTween(Subtitle, {TextTransparency = 0}, 0.8)
    task.wait(0.2)
    SmoothTween(BarContainer, {BackgroundTransparency = 0.6}, 0.8)
    SmoothTween(StatusText, {TextTransparency = 0}, 0.8)
    SmoothTween(PercentText, {TextTransparency = 0}, 0.8)
    
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
                SmoothTween(ProgressBar, {
                    Size = UDim2.new(progress, 0, 1, 0)
                }, 0.4, Enum.EasingStyle.Quad)
            end
        end,
        Complete = function()
            if not LoaderScreen or not LoaderScreen.Parent then
                return
            end
            
            if StatusText and StatusText.Parent then
                StatusText.Text = "Complete!"
            end
            if PercentText and PercentText.Parent then
                PercentText.Text = "100%"
            end
            
            task.wait(0.6)
            
            pcall(function()
                SmoothTween(LoaderScreen, {BackgroundTransparency = 1}, 0.5)
                
                for _, child in pairs(LoaderScreen:GetDescendants()) do
                    pcall(function()
                        if child:IsA("TextLabel") or child:IsA("TextButton") then
                            SmoothTween(child, {TextTransparency = 1, BackgroundTransparency = 1}, 0.5)
                        elseif child:IsA("ImageLabel") or child:IsA("ImageButton") then
                            SmoothTween(child, {ImageTransparency = 1, BackgroundTransparency = 1}, 0.5)
                        elseif child:IsA("Frame") then
                            SmoothTween(child, {BackgroundTransparency = 1}, 0.5)
                        end
                    end)
                end
            end)
            
            task.wait(0.6)
            
            if LoaderScreen and LoaderScreen.Parent then
                LoaderScreen:Destroy()
            end
            
            GUI.LoadingScreen = nil
        end
    }
end

function GUI.InitAssets(progressCallback)
    print("[SKIBIDI] Initializing assets...")
    
    local loader = GUI.CreateFullScreenLoader()
    if not loader then
        warn("[SKIBIDI] Failed to create loader")
        return
    end
    
    loader.Update(0.05, "Creating workspace...")
    
    -- Create workspace
    pcall(function()
        if makefolder and not isfolder(WORKSPACE_FOLDER) then 
            makefolder(WORKSPACE_FOLDER) 
            print("[SKIBIDI] Workspace created")
        end
    end)
    
    task.wait(0.3)
    loader.Update(0.15, "Initializing audio system...")

    -- Initialize music
    local musicSuccess = pcall(function()
        GUI.MusicSound = Instance.new("Sound")
        GUI.MusicSound.Name = "SkibidiMusic"
        GUI.MusicSound.Looped = true
        GUI.MusicSound.Volume = GUI.Config.MusicVolume
        GUI.MusicSound.Parent = SoundService
    end)
    
    if not musicSuccess then
        warn("[SKIBIDI] Music initialization failed")
    end

    task.wait(0.2)
    loader.Update(0.25, "Loading audio files...")

    -- Load music asynchronously
    GUI.AddTask(task.spawn(function()
        task.wait(0.1)
        
        local success, err = pcall(function()
            local asset = getcustomasset or getsynasset
            if not asset then 
                warn("[SKIBIDI] Asset loader unavailable")
                loader.Update(0.5, "Audio system unavailable")
                return 
            end
            
            -- Download if needed
            if isfile and not isfile(MUSIC_PATH) then
                if writefile then
                    loader.Update(0.35, "Downloading audio...")
                    local httpSuccess, musicData = pcall(function()
                        return game:HttpGet(ASSETS_REPO .. MUSIC_FILENAME, true)
                    end)
                    
                    if httpSuccess and musicData then
                        writefile(MUSIC_PATH, musicData)
                        print("[SKIBIDI] Audio downloaded")
                    else
                        warn("[SKIBIDI] Audio download failed")
                        loader.Update(0.5, "Audio download failed")
                        return
                    end
                end
            end
            
            -- Load music
            if isfile and isfile(MUSIC_PATH) and GUI.MusicSound then
                local assetUrl = asset(MUSIC_PATH)
                GUI.MusicSound.SoundId = assetUrl
                
                -- Restore position
                if isfile(TIME_PATH) and readfile then
                    local savedTimeStr = readfile(TIME_PATH)
                    local savedTime = tonumber(savedTimeStr)
                    if savedTime and savedTime > 0 then 
                        GUI.MusicSound.TimePosition = savedTime
                        print("[SKIBIDI] Audio position restored: " .. savedTime)
                    end
                end
                
                GUI.MusicSound:Play()
                print("[SKIBIDI] Audio loaded successfully")
                loader.Update(0.5, "Audio system ready")
            else
                loader.Update(0.5, "Audio file not found")
            end
        end)
        
        if not success then
            warn("[SKIBIDI] Audio load error:", err)
            loader.Update(0.5, "Audio system error")
        end
    end))

    task.wait(0.4)
    loader.Update(0.6, "Preparing interface...")

    -- Wait for BackgroundImage
    local maxWait = 100
    local waited = 0
    while not GUI.BackgroundImage and waited < maxWait do
        task.wait(0.1)
        waited = waited + 1
    end
    
    if not GUI.BackgroundImage then
        warn("[SKIBIDI] Background element not found")
        loader.Update(0.8, "Background unavailable")
    else
        loader.Update(0.65, "Loading background...")
        
        -- Load background
        GUI.AddTask(task.spawn(function()
            local success, err = pcall(function()
                local asset = getcustomasset or getsynasset
                if not asset then 
                    warn("[SKIBIDI] Asset loader unavailable for background")
                    loader.Update(0.8, "Background unavailable")
                    return 
                end
                
                -- Download if needed
                if isfile and not isfile(BG_PATH) then
                    if writefile then
                        loader.Update(0.7, "Downloading background...")
                        local httpSuccess, bgData = pcall(function()
                            return game:HttpGet(ASSETS_REPO .. BG_FILENAME, true)
                        end)
                        
                        if httpSuccess and bgData then
                            writefile(BG_PATH, bgData)
                            print("[SKIBIDI] Background downloaded")
                        else
                            warn("[SKIBIDI] Background download failed")
                            loader.Update(0.8, "Background download failed")
                            return
                        end
                    end
                end
                
                -- Load background
                if isfile and isfile(BG_PATH) and GUI.BackgroundImage and GUI.BackgroundImage.Parent then
                    local assetUrl = asset(BG_PATH)
                    GUI.BackgroundImage.Image = assetUrl
                    print("[SKIBIDI] Background loaded")
                    loader.Update(0.8, "Background ready")
                else
                    loader.Update(0.8, "Background not available")
                end
            end)
            
            if not success then
                warn("[SKIBIDI] Background error:", err)
                loader.Update(0.8, "Background error")
            end
        end))
    end
    
    task.wait(0.5)
    loader.Update(0.9, "Finalizing...")
    task.wait(0.4)
    loader.Update(1, "Launch ready")
    task.wait(0.5)
    loader.Complete()
    
    -- Save music on teleport
    local teleportConnection = Players.LocalPlayer.OnTeleport:Connect(function()
        GUI.SaveMusicState()
    end)
    GUI.AddConnection(teleportConnection)
    
    print("[SKIBIDI] Assets initialized")
end

function GUI.Init(vars)
    -- Cleanup existing
    if GUI.SkibidiGui then 
        GUI.Cleanup()
    end
    
    -- Validate vars
    if not vars or type(vars) ~= "table" then
        warn("[SKIBIDI] Invalid vars, creating new table")
        vars = {}
    end
    
    local lp = Players.LocalPlayer
    if not lp then
        warn("[SKIBIDI] LocalPlayer not found")
        return nil
    end
    
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
            warn("[SKIBIDI] Failed to parent GUI")
            return nil
        end
    end

    -- Main Frame
    GUI.MainFrame = Instance.new("Frame")
    GUI.MainFrame.Name = "MainFrame"
    GUI.MainFrame.BackgroundColor3 = GUI.BackgroundColor
    GUI.MainFrame.BackgroundTransparency = 0.05
    GUI.MainFrame.Position = UDim2.new(0.5, -200, 0.5, -280)
    GUI.MainFrame.Size = UDim2.new(0, 0, 0, 0)
    GUI.MainFrame.BorderSizePixel = 0
    GUI.MainFrame.ClipsDescendants = true
    GUI.MainFrame.Parent = GUI.SkibidiGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 16)
    Corner.Parent = GUI.MainFrame
    
    -- Animated border
    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 2
    Stroke.Transparency = 0.2
    Stroke.Parent = GUI.MainFrame
    
    local StrokeGradient = Instance.new("UIGradient")
    StrokeGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, GUI.AccentColor),
        ColorSequenceKeypoint.new(0.5, GUI.SecondaryColor),
        ColorSequenceKeypoint.new(1, GUI.AccentColor)
    }
    StrokeGradient.Rotation = 0
    StrokeGradient.Parent = Stroke
    
    -- Animate border
    GUI.AddTask(task.spawn(function()
        while Stroke and Stroke.Parent and StrokeGradient and StrokeGradient.Parent do
            SmoothTween(StrokeGradient, {Rotation = StrokeGradient.Rotation + 360}, 5, Enum.EasingStyle.Linear)
            task.wait(5)
        end
    end))
    
    -- Glass effect overlay
    local GlassOverlay = Instance.new("Frame")
    GlassOverlay.Size = UDim2.new(1, 0, 1, 0)
    GlassOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    GlassOverlay.BackgroundTransparency = 0.97
    GlassOverlay.BorderSizePixel = 0
    GlassOverlay.Parent = GUI.MainFrame
    
    local GlassCorner = Instance.new("UICorner")
    GlassCorner.CornerRadius = UDim.new(0, 16)
    GlassCorner.Parent = GlassOverlay

    -- Background Image Layer
    GUI.BackgroundImage = Instance.new("ImageLabel")
    GUI.BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
    GUI.BackgroundImage.BackgroundTransparency = 1
    GUI.BackgroundImage.ScaleType = Enum.ScaleType.Crop
    GUI.BackgroundImage.ImageTransparency = 0.65
    GUI.BackgroundImage.ZIndex = 0
    GUI.BackgroundImage.Parent = GUI.MainFrame
    
    local BgCorner = Instance.new("UICorner")
    BgCorner.CornerRadius = UDim.new(0, 16)
    BgCorner.Parent = GUI.BackgroundImage
    
    -- Dark overlay on background
    local DarkOverlay = Instance.new("Frame")
    DarkOverlay.Size = UDim2.new(1, 0, 1, 0)
    DarkOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    DarkOverlay.BackgroundTransparency = 0.4
    DarkOverlay.BorderSizePixel = 0
    DarkOverlay.ZIndex = 1
    DarkOverlay.Parent = GUI.MainFrame
    
    local DarkCorner = Instance.new("UICorner")
    DarkCorner.CornerRadius = UDim.new(0, 16)
    DarkCorner.Parent = DarkOverlay
    
    -- Floating particles
    for i = 1, 15 do
        CreateFloatingParticle(GUI.MainFrame, i % 2 == 0 and GUI.AccentColor or GUI.SecondaryColor)
    end
    
    -- Dragging
    local dragging, dragInput, dragStart, startPos
    
    local dragBeganConnection = GUI.MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = GUI.MainFrame.Position
            
            SmoothTween(GUI.MainFrame, {
                Size = GUI.MainFrame.Size - UDim2.new(0, 6, 0, 6)
            }, 0.1)
            
            local endConnection
            endConnection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then 
                    dragging = false
                    SmoothTween(GUI.MainFrame, {
                        Size = UDim2.new(0, 400, 0, 560)
                    }, 0.1)
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
            local newPos = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
            GUI.MainFrame.Position = newPos
        end
    end)
    GUI.AddConnection(inputChangedConnection)

    -- Header
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 70)
    Header.BackgroundTransparency = 1
    Header.ZIndex = 2
    Header.Parent = GUI.MainFrame
    
    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Text = "SKIBIDI FARM"
    HeaderTitle.Size = UDim2.new(1, -50, 1, 0)
    HeaderTitle.Position = UDim2.new(0, 25, 0, 0)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Font = Enum.Font.GothamBlack
    HeaderTitle.TextColor3 = GUI.TextPrimary
    HeaderTitle.TextSize = 32
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeaderTitle.ZIndex = 3
    HeaderTitle.Parent = Header
    
    local HeaderGradient = Instance.new("UIGradient")
    HeaderGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, GUI.AccentColor),
        ColorSequenceKeypoint.new(1, GUI.SecondaryColor)
    }
    HeaderGradient.Rotation = 45
    HeaderGradient.Parent = HeaderTitle
    
    -- Version badge
    local VersionBadge = Instance.new("TextLabel")
    VersionBadge.Text = "v4.2"
    VersionBadge.Size = UDim2.new(0, 55, 0, 28)
    VersionBadge.Position = UDim2.new(1, -80, 0.5, -14)
    VersionBadge.BackgroundColor3 = GUI.AccentColor
    VersionBadge.BackgroundTransparency = 0.75
    VersionBadge.Font = Enum.Font.GothamBold
    VersionBadge.TextColor3 = GUI.TextPrimary
    VersionBadge.TextSize = 14
    VersionBadge.ZIndex = 3
    VersionBadge.Parent = Header
    
    local BadgeCorner = Instance.new("UICorner")
    BadgeCorner.CornerRadius = UDim.new(0, 14)
    BadgeCorner.Parent = VersionBadge
    
    local BadgeStroke = Instance.new("UIStroke")
    BadgeStroke.Color = GUI.AccentColor
    BadgeStroke.Thickness = 1
    BadgeStroke.Transparency = 0.5
    BadgeStroke.Parent = VersionBadge

    -- Stats Container
    local StatsContainer = Instance.new("Frame")
    StatsContainer.Position = UDim2.new(0, 20, 0, 90)
    StatsContainer.Size = UDim2.new(1, -40, 0, 440)
    StatsContainer.BackgroundTransparency = 1
    StatsContainer.ZIndex = 2
    StatsContainer.Parent = GUI.MainFrame
    
    local Layout = Instance.new("UIListLayout")
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 14)
    Layout.Parent = StatsContainer

    -- Create custom icon function
    local function CreateIconFrame(iconText, color)
        local IconFrame = Instance.new("Frame")
        IconFrame.Size = UDim2.new(0, 48, 0, 48)
        IconFrame.BackgroundColor3 = color
        IconFrame.BackgroundTransparency = 0.85
        IconFrame.BorderSizePixel = 0
        
        local IconCorner = Instance.new("UICorner")
        IconCorner.CornerRadius = UDim.new(0, 12)
        IconCorner.Parent = IconFrame
        
        local IconStroke = Instance.new("UIStroke")
        IconStroke.Color = color
        IconStroke.Thickness = 1.5
        IconStroke.Transparency = 0.6
        IconStroke.Parent = IconFrame
        
        local Icon = Instance.new("TextLabel")
        Icon.Size = UDim2.new(1, 0, 1, 0)
        Icon.BackgroundTransparency = 1
        Icon.Font = Enum.Font.GothamBold
        Icon.Text = iconText
        Icon.TextColor3 = color
        Icon.TextSize = 24
        Icon.Parent = IconFrame
        
        return IconFrame
    end
    
    local function CreateStatCard(label, value, iconText, iconColor, order)
        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(1, 0, 0, 82)
        Card.BackgroundColor3 = GUI.SurfaceColor
        Card.BackgroundTransparency = 0.25
        Card.BorderSizePixel = 0
        Card.LayoutOrder = order
        Card.ZIndex = 2
        Card.Parent = StatsContainer
        
        local CardCorner = Instance.new("UICorner")
        CardCorner.CornerRadius = UDim.new(0, 14)
        CardCorner.Parent = Card
        
        local CardStroke = Instance.new("UIStroke")
        CardStroke.Color = Color3.fromRGB(60, 60, 80)
        CardStroke.Thickness = 1
        CardStroke.Transparency = 0.7
        CardStroke.Parent = Card
        
        -- Hover effect
        local enterConnection = Card.MouseEnter:Connect(function()
            SmoothTween(Card, {BackgroundTransparency = 0.1}, 0.2)
            SmoothTween(CardStroke, {Transparency = 0.4}, 0.2)
        end)
        GUI.AddConnection(enterConnection)
        
        local leaveConnection = Card.MouseLeave:Connect(function()
            SmoothTween(Card, {BackgroundTransparency = 0.25}, 0.2)
            SmoothTween(CardStroke, {Transparency = 0.7}, 0.2)
        end)
        GUI.AddConnection(leaveConnection)
        
        -- Icon
        local Icon = CreateIconFrame(iconText, iconColor)
        Icon.Position = UDim2.new(0, 17, 0.5, -24)
        Icon.Parent = Card
        
        -- Label
        local Label = Instance.new("TextLabel")
        Label.Text = label
        Label.Size = UDim2.new(1, -85, 0, 22)
        Label.Position = UDim2.new(0, 75, 0, 14)
        Label.BackgroundTransparency = 1
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 14
        Label.TextColor3 = GUI.TextSecondary
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.ZIndex = 3
        Label.Parent = Card
        
        -- Value
        local Value = Instance.new("TextLabel")
        Value.Text = value
        Value.Size = UDim2.new(1, -85, 0, 32)
        Value.Position = UDim2.new(0, 75, 0, 36)
        Value.BackgroundTransparency = 1
        Value.Font = Enum.Font.GothamBold
        Value.TextSize = 22
        Value.TextColor3 = GUI.TextPrimary
        Value.TextXAlignment = Enum.TextXAlignment.Left
        Value.ZIndex = 3
        Value.TextTruncate = Enum.TextTruncate.AtEnd
        Value.Parent = Card
        
        return Value
    end

    -- Create stat cards with custom icons
    vars.TargetLabel = CreateStatCard("Current Target", "Searching...", "◉", GUI.AccentColor, 1)
    vars.StateLabel = CreateStatCard("Status", "Initializing", "⚡", GUI.SecondaryColor, 2)
    vars.BountyLabel = CreateStatCard("Bounty Gained", "+0", "◆", Color3.fromRGB(255, 215, 0), 3)
    vars.TimeLabel = CreateStatCard("Session Time", "00:00:00", "◷", Color3.fromRGB(100, 200, 255), 4)
    vars.KillsLabel = CreateStatCard("Total Eliminations", "0", "✦", Color3.fromRGB(255, 100, 100), 5)

    -- Session time updater (updates every 1 second, not every frame)
    local sessionStartTime = tick()
    GUI.AddTask(task.spawn(function()
        while vars.TimeLabel and vars.TimeLabel.Parent do
            task.wait(1) -- Update every 1 second instead of every frame
            
            local elapsed = tick() - sessionStartTime
            local hours = math.floor(elapsed / 3600)
            local minutes = math.floor((elapsed % 3600) / 60)
            local seconds = math.floor(elapsed % 60)
            
            vars.TimeLabel.Text = string.format("%02d:%02d:%02d", hours, minutes, seconds)
        end
    end))

    -- Entrance animation
    SmoothTween(GUI.MainFrame, {
        Size = UDim2.new(0, 400, 0, 560)
    }, 0.7, Enum.EasingStyle.Back)

    -- Stagger card animations
    GUI.AddTask(task.spawn(function()
        for i, card in ipairs(StatsContainer:GetChildren()) do
            if card:IsA("Frame") and card ~= Layout then
                card.BackgroundTransparency = 1
                task.wait(0.06)
                SmoothTween(card, {BackgroundTransparency = 0.25}, 0.5)
            end
        end
    end))

    print("[SKIBIDI] GUI initialized")

    -- Logger
    local Logger = {}
    
    function Logger:Log(m) 
        if vars.StateLabel and vars.StateLabel.Parent then
            vars.StateLabel.Text = tostring(m)
        end
    end
    
    function Logger:Info(m) 
        if vars.StateLabel and vars.StateLabel.Parent then
            vars.StateLabel.Text = tostring(m)
        end
    end
    
    function Logger:Success(m) 
        if vars.StateLabel and vars.StateLabel.Parent then
            vars.StateLabel.Text = tostring(m)
        end
    end
    
    function Logger:Warning(m) 
        if vars.StateLabel and vars.StateLabel.Parent then
            vars.StateLabel.Text = tostring(m)
        end
    end
    
    function Logger:Error(m) 
        if vars.StateLabel and vars.StateLabel.Parent then
            vars.StateLabel.Text = tostring(m)
        end
    end
    
    function Logger:Target(m) 
        if vars.TargetLabel and vars.TargetLabel.Parent then
            vars.TargetLabel.Text = tostring(m)
        end
    end
    
    return Logger
end

-- Cleanup function
function GUI.Cleanup()
    print("[SKIBIDI] Starting cleanup...")
    
    GUI.SaveMusicState()
    
    -- Cancel tweens
    for _, tween in ipairs(GUI.RunningTweens) do
        pcall(function()
            if tween then
                tween:Cancel()
            end
        end)
    end
    GUI.RunningTweens = {}
    
    -- Cancel tasks
    for _, taskThread in ipairs(GUI.Tasks) do
        pcall(function()
            if taskThread then
                task.cancel(taskThread)
            end
        end)
    end
    GUI.Tasks = {}
    
    -- Disconnect connections
    for _, connection in ipairs(GUI.Connections) do
        pcall(function()
            if connection and connection.Connected then
                connection:Disconnect()
            end
        end)
    end
    GUI.Connections = {}
    
    -- Stop music
    if GUI.MusicSound then
        pcall(function()
            GUI.MusicSound:Stop()
            GUI.MusicSound:Destroy()
        end)
        GUI.MusicSound = nil
    end
    
    -- Destroy GUI
    if GUI.SkibidiGui then
        pcall(function()
            GUI.SkibidiGui:Destroy()
        end)
        GUI.SkibidiGui = nil
    end
    
    -- Clear references
    GUI.MainFrame = nil
    GUI.BackgroundImage = nil
    GUI.LoadingScreen = nil
    
    print("[SKIBIDI] Cleanup complete")
end

return GUI
