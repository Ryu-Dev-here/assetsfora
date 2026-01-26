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
GUI.MusicLoaded = false -- Prevent double loading

-- Stunning gradient colors - Premium feel
GUI.AccentColor = Color3.fromRGB(147, 51, 234) -- Purple
GUI.SecondaryColor = Color3.fromRGB(236, 72, 153) -- Pink
GUI.TertiaryColor = Color3.fromRGB(59, 130, 246) -- Blue
GUI.BackgroundColor = Color3.fromRGB(12, 12, 20)
GUI.SurfaceColor = Color3.fromRGB(20, 20, 32)
GUI.CardColor = Color3.fromRGB(24, 24, 38)
GUI.TextPrimary = Color3.fromRGB(248, 250, 252)
GUI.TextSecondary = Color3.fromRGB(148, 163, 184)
GUI.GlowColor = Color3.fromRGB(167, 139, 250)

-- Configuration
local WORKSPACE_FOLDER = "cuackerdoing"
local MUSIC_FILENAME = "sound.mp3"
local BG_FILENAME = "backlua.png"
local TIME_FILENAME = "musictime.txt"
local POS_FILENAME = "guiposition.txt"
local MUSIC_PATH = WORKSPACE_FOLDER .. "/" .. MUSIC_FILENAME
local BG_PATH = WORKSPACE_FOLDER .. "/" .. BG_FILENAME
local TIME_PATH = WORKSPACE_FOLDER .. "/" .. TIME_FILENAME
local POS_PATH = WORKSPACE_FOLDER .. "/" .. POS_FILENAME
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

-- Save GUI position
function GUI.SavePosition()
    if not GUI.MainFrame or not GUI.MainFrame.Parent then return end
    
    pcall(function()
        if writefile then
            local pos = GUI.MainFrame.Position
            local posData = string.format("%f,%f,%f,%f", 
                pos.X.Scale, pos.X.Offset, 
                pos.Y.Scale, pos.Y.Offset
            )
            writefile(POS_PATH, posData)
        end
    end)
end

-- Load GUI position
function GUI.LoadPosition()
    local success, result = pcall(function()
        if isfile and readfile and isfile(POS_PATH) then
            local posData = readfile(POS_PATH)
            local parts = {}
            for num in string.gmatch(posData, "[^,]+") do
                table.insert(parts, tonumber(num))
            end
            if #parts == 4 then
                return UDim2.new(parts[1], parts[2], parts[3], parts[4])
            end
        end
    end)
    
    return success and result or UDim2.new(0.5, -225, 0.5, -300)
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

-- Premium particle system with glow
local function CreateFloatingParticle(parent, color)
    if not parent or not parent.Parent then
        return nil
    end
    
    local size = math.random(2, 5)
    local particle = Instance.new("Frame")
    particle.Size = UDim2.new(0, size, 0, size)
    particle.BackgroundColor3 = color or GUI.AccentColor
    particle.BorderSizePixel = 0
    particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
    particle.BackgroundTransparency = math.random(40, 80) / 100
    particle.Parent = parent
    particle.ZIndex = 5
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = particle
    
    -- Glow effect
    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(3, 0, 3, 0)
    glow.Position = UDim2.new(-1, 0, -1, 0)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    glow.ImageColor3 = color or GUI.AccentColor
    glow.ImageTransparency = 0.8
    glow.ZIndex = 4
    glow.Parent = particle
    
    local animTask = task.spawn(function()
        while particle and particle.Parent and parent and parent.Parent do
            local success = pcall(function()
                local randomX = math.random()
                local randomY = math.random()
                local randomDuration = math.random(50, 100) / 10
                local randomTransparency = math.random(40, 90) / 100
                
                SmoothTween(particle, {
                    Position = UDim2.new(randomX, 0, randomY, 0),
                    BackgroundTransparency = randomTransparency
                }, randomDuration, Enum.EasingStyle.Sine)
            end)
            
            if not success then
                break
            end
            
            task.wait(math.random(40, 90) / 10)
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
                print("[CUACKER] Music state saved: " .. timePos)
            end
        end
    end)
end

function GUI.CreateFullScreenLoader()
    local LoaderScreen = Instance.new("Frame")
    LoaderScreen.Name = "FullScreenLoader"
    LoaderScreen.Size = UDim2.new(1, 0, 1, 0)
    LoaderScreen.BackgroundColor3 = Color3.fromRGB(8, 8, 15)
    LoaderScreen.BorderSizePixel = 0
    LoaderScreen.ZIndex = 1000
    LoaderScreen.Parent = GUI.SkibidiGui
    
    -- Animated radial gradient
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 12, 20)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 15, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 12, 20))
    }
    Gradient.Rotation = 0
    Gradient.Parent = LoaderScreen
    
    -- Smooth gradient rotation
    GUI.AddTask(task.spawn(function()
        while LoaderScreen and LoaderScreen.Parent and Gradient and Gradient.Parent do
            SmoothTween(Gradient, {Rotation = Gradient.Rotation + 360}, 12, Enum.EasingStyle.Linear)
            task.wait(12)
        end
    end))
    
    -- Enhanced particles
    for i = 1, 40 do
        local colors = {GUI.AccentColor, GUI.SecondaryColor, GUI.TertiaryColor, GUI.GlowColor}
        CreateFloatingParticle(LoaderScreen, colors[math.random(1, #colors)])
    end
    
    -- Center container
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0, 550, 0, 400)
    Container.Position = UDim2.new(0.5, -275, 0.5, -200)
    Container.BackgroundTransparency = 1
    Container.Parent = LoaderScreen
    
    -- Glowing logo container
    local LogoGlow = Instance.new("Frame")
    LogoGlow.Size = UDim2.new(1, 40, 0, 140)
    LogoGlow.Position = UDim2.new(0, -20, 0, -20)
    LogoGlow.BackgroundColor3 = GUI.GlowColor
    LogoGlow.BackgroundTransparency = 0.9
    LogoGlow.BorderSizePixel = 0
    LogoGlow.Parent = Container
    
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(0, 30)
    glowCorner.Parent = LogoGlow
    
    -- Pulsing glow effect
    GUI.AddTask(task.spawn(function()
        while LogoGlow and LogoGlow.Parent do
            SmoothTween(LogoGlow, {BackgroundTransparency = 0.7}, 1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.5)
            SmoothTween(LogoGlow, {BackgroundTransparency = 0.9}, 1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.5)
        end
    end))
    
    -- Main logo text
    local LogoText = Instance.new("TextLabel")
    LogoText.Text = "CUACKER'S CUM"
    LogoText.Size = UDim2.new(1, 0, 0, 100)
    LogoText.BackgroundTransparency = 1
    LogoText.Font = Enum.Font.GothamBlack
    LogoText.TextColor3 = GUI.TextPrimary
    LogoText.TextSize = 56
    LogoText.TextTransparency = 1
    LogoText.Parent = Container
    
    -- Multi-color gradient on logo
    local LogoGradient = Instance.new("UIGradient")
    LogoGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, GUI.AccentColor),
        ColorSequenceKeypoint.new(0.4, GUI.SecondaryColor),
        ColorSequenceKeypoint.new(0.7, GUI.TertiaryColor),
        ColorSequenceKeypoint.new(1, GUI.GlowColor)
    }
    LogoGradient.Rotation = 45
    LogoGradient.Parent = LogoText
    
    -- Animate logo gradient
    GUI.AddTask(task.spawn(function()
        while LogoGradient and LogoGradient.Parent do
            SmoothTween(LogoGradient, {Rotation = LogoGradient.Rotation + 360}, 8, Enum.EasingStyle.Linear)
            task.wait(8)
        end
    end))
    
    -- Subtitle with glow
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Text = "PREMIUM AUTO FARM SYSTEM"
    Subtitle.Size = UDim2.new(1, 0, 0, 35)
    Subtitle.Position = UDim2.new(0, 0, 0, 110)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Font = Enum.Font.GothamBold
    Subtitle.TextColor3 = GUI.TextSecondary
    Subtitle.TextSize = 16
    Subtitle.TextTransparency = 1
    Subtitle.Parent = Container
    
    local SubtitleStroke = Instance.new("UIStroke")
    SubtitleStroke.Color = GUI.GlowColor
    SubtitleStroke.Thickness = 0.5
    SubtitleStroke.Transparency = 0.5
    SubtitleStroke.Parent = Subtitle
    
    -- Modern loading bar container
    local BarContainer = Instance.new("Frame")
    BarContainer.Size = UDim2.new(0.9, 0, 0, 6)
    BarContainer.Position = UDim2.new(0.05, 0, 0, 200)
    BarContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    BarContainer.BorderSizePixel = 0
    BarContainer.BackgroundTransparency = 1
    BarContainer.Parent = Container
    
    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(1, 0)
    BarCorner.Parent = BarContainer
    
    -- Progress bar with gradient
    local ProgressBar = Instance.new("Frame")
    ProgressBar.Size = UDim2.new(0, 0, 1, 0)
    ProgressBar.BackgroundColor3 = GUI.AccentColor
    ProgressBar.BorderSizePixel = 0
    ProgressBar.Parent = BarContainer
    
    local ProgressCorner = Instance.new("UICorner")
    ProgressCorner.CornerRadius = UDim.new(1, 0)
    ProgressCorner.Parent = ProgressBar
    
    local ProgressGradient = Instance.new("UIGradient")
    ProgressGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, GUI.AccentColor),
        ColorSequenceKeypoint.new(0.5, GUI.SecondaryColor),
        ColorSequenceKeypoint.new(1, GUI.TertiaryColor)
    }
    ProgressGradient.Parent = ProgressBar
    
    -- Enhanced glow
    local BarGlow = Instance.new("Frame")
    BarGlow.Size = UDim2.new(1, 30, 1, 30)
    BarGlow.Position = UDim2.new(0, -15, 0, -15)
    BarGlow.BackgroundColor3 = GUI.GlowColor
    BarGlow.BackgroundTransparency = 0.6
    BarGlow.BorderSizePixel = 0
    BarGlow.ZIndex = 0
    BarGlow.Parent = ProgressBar
    
    local GlowCorner = Instance.new("UICorner")
    GlowCorner.CornerRadius = UDim.new(1, 0)
    GlowCorner.Parent = BarGlow
    
    -- Status text with better positioning
    local StatusText = Instance.new("TextLabel")
    StatusText.Text = "Initializing systems..."
    StatusText.Size = UDim2.new(1, 0, 0, 30)
    StatusText.Position = UDim2.new(0, 0, 0, 240)
    StatusText.BackgroundTransparency = 1
    StatusText.Font = Enum.Font.GothamMedium
    StatusText.TextColor3 = GUI.TextSecondary
    StatusText.TextSize = 15
    StatusText.TextTransparency = 1
    StatusText.Parent = Container
    
    -- Percentage text with gradient
    local PercentText = Instance.new("TextLabel")
    PercentText.Text = "0%"
    PercentText.Size = UDim2.new(1, 0, 0, 50)
    PercentText.Position = UDim2.new(0, 0, 0, 280)
    PercentText.BackgroundTransparency = 1
    PercentText.Font = Enum.Font.GothamBlack
    PercentText.TextColor3 = GUI.TextPrimary
    PercentText.TextSize = 42
    PercentText.TextTransparency = 1
    PercentText.Parent = Container
    
    local PercentGradient = Instance.new("UIGradient")
    PercentGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, GUI.AccentColor),
        ColorSequenceKeypoint.new(1, GUI.SecondaryColor)
    }
    PercentGradient.Parent = PercentText
    
    -- Staggered fade in
    task.wait(0.1)
    SmoothTween(LogoText, {TextTransparency = 0}, 1)
    task.wait(0.15)
    SmoothTween(Subtitle, {TextTransparency = 0}, 0.8)
    task.wait(0.15)
    SmoothTween(BarContainer, {BackgroundTransparency = 0.5}, 0.8)
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
                }, 0.3, Enum.EasingStyle.Quad)
            end
        end,
        Complete = function()
            if not LoaderScreen or not LoaderScreen.Parent then
                return
            end
            
            if StatusText and StatusText.Parent then
                StatusText.Text = "Launch complete!"
            end
            if PercentText and PercentText.Parent then
                PercentText.Text = "100%"
            end
            
            task.wait(0.8)
            
            pcall(function()
                SmoothTween(LoaderScreen, {BackgroundTransparency = 1}, 0.6)
                
                for _, child in pairs(LoaderScreen:GetDescendants()) do
                    pcall(function()
                        if child:IsA("TextLabel") or child:IsA("TextButton") then
                            SmoothTween(child, {TextTransparency = 1, BackgroundTransparency = 1}, 0.6)
                        elseif child:IsA("ImageLabel") or child:IsA("ImageButton") then
                            SmoothTween(child, {ImageTransparency = 1, BackgroundTransparency = 1}, 0.6)
                        elseif child:IsA("Frame") then
                            SmoothTween(child, {BackgroundTransparency = 1}, 0.6)
                        end
                    end)
                end
            end)
            
            task.wait(0.7)
            
            if LoaderScreen and LoaderScreen.Parent then
                LoaderScreen:Destroy()
            end
            
            GUI.LoadingScreen = nil
        end
    }
end

function GUI.InitAssets(progressCallback)
    print("[CUACKER] Initializing assets...")
    
    local loader = GUI.CreateFullScreenLoader()
    if not loader then
        warn("[CUACKER] Failed to create loader")
        return
    end
    
    loader.Update(0.05, "Setting up workspace...")
    
    -- Create workspace
    pcall(function()
        if makefolder and not isfolder(WORKSPACE_FOLDER) then 
            makefolder(WORKSPACE_FOLDER) 
            print("[CUACKER] Workspace created")
        end
    end)
    
    task.wait(0.3)
    loader.Update(0.15, "Preparing audio engine...")

    -- Initialize music ONCE
    if not GUI.MusicLoaded then
        local musicSuccess = pcall(function()
            GUI.MusicSound = Instance.new("Sound")
            GUI.MusicSound.Name = "CuackerMusic"
            GUI.MusicSound.Looped = true
            GUI.MusicSound.Volume = GUI.Config.MusicVolume
            GUI.MusicSound.Parent = SoundService
        end)
        
        if not musicSuccess then
            warn("[CUACKER] Music initialization failed")
        end

        task.wait(0.2)
        loader.Update(0.25, "Loading audio files...")

        -- Load music asynchronously (SINGLE LOAD)
        GUI.AddTask(task.spawn(function()
            task.wait(0.1)
            
            local success, err = pcall(function()
                local asset = getcustomasset or getsynasset
                if not asset then 
                    warn("[CUACKER] Asset loader unavailable")
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
                            print("[CUACKER] Audio downloaded")
                        else
                            warn("[CUACKER] Audio download failed")
                            loader.Update(0.5, "Audio download failed")
                            return
                        end
                    end
                end
                
                -- Load music ONLY ONCE
                if isfile and isfile(MUSIC_PATH) and GUI.MusicSound and not GUI.MusicLoaded then
                    local assetUrl = asset(MUSIC_PATH)
                    GUI.MusicSound.SoundId = assetUrl
                    GUI.MusicLoaded = true -- Mark as loaded
                    
                    -- Restore position
                    if isfile(TIME_PATH) and readfile then
                        local savedTimeStr = readfile(TIME_PATH)
                        local savedTime = tonumber(savedTimeStr)
                        if savedTime and savedTime > 0 then 
                            GUI.MusicSound.TimePosition = savedTime
                            print("[CUACKER] Audio position restored: " .. savedTime)
                        end
                    end
                    
                    GUI.MusicSound:Play()
                    print("[CUACKER] Audio loaded successfully")
                    loader.Update(0.5, "Audio system ready")
                else
                    loader.Update(0.5, "Audio already loaded or unavailable")
                end
            end)
            
            if not success then
                warn("[CUACKER] Audio load error:", err)
                loader.Update(0.5, "Audio system error")
            end
        end))
    else
        loader.Update(0.5, "Audio already initialized")
    end

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
        warn("[CUACKER] Background element not found")
        loader.Update(0.85, "Background unavailable")
    else
        loader.Update(0.65, "Loading background...")
        
        -- Load background
        GUI.AddTask(task.spawn(function()
            local success, err = pcall(function()
                local asset = getcustomasset or getsynasset
                if not asset then 
                    warn("[CUACKER] Asset loader unavailable for background")
                    loader.Update(0.85, "Background unavailable")
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
                            print("[CUACKER] Background downloaded")
                        else
                            warn("[CUACKER] Background download failed")
                            loader.Update(0.85, "Background download failed")
                            return
                        end
                    end
                end
                
                -- Load background
                if isfile and isfile(BG_PATH) and GUI.BackgroundImage and GUI.BackgroundImage.Parent then
                    local assetUrl = asset(BG_PATH)
                    GUI.BackgroundImage.Image = assetUrl
                    print("[CUACKER] Background loaded")
                    loader.Update(0.85, "Background ready")
                else
                    loader.Update(0.85, "Background not available")
                end
            end)
            
            if not success then
                warn("[CUACKER] Background error:", err)
                loader.Update(0.85, "Background error")
            end
        end))
    end
    
    task.wait(0.5)
    loader.Update(0.92, "Finalizing systems...")
    task.wait(0.4)
    loader.Update(1, "Ready to launch")
    task.wait(0.6)
    loader.Complete()
    
    -- Save music on teleport
    local teleportConnection = Players.LocalPlayer.OnTeleport:Connect(function()
        GUI.SaveMusicState()
    end)
    GUI.AddConnection(teleportConnection)
    
    print("[CUACKER] Assets initialized")
end

function GUI.Init(vars)
    -- Cleanup existing
    if GUI.SkibidiGui then 
        GUI.Cleanup()
    end
    
    -- Validate vars
    if not vars or type(vars) ~= "table" then
        warn("[CUACKER] Invalid vars, creating new table")
        vars = {}
    end
    
    local lp = Players.LocalPlayer
    if not lp then
        warn("[CUACKER] LocalPlayer not found")
        return nil
    end
    
    -- Create ScreenGui
    GUI.SkibidiGui = Instance.new("ScreenGui")
    GUI.SkibidiGui.Name = "CuackerGui"
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
            warn("[CUACKER] Failed to parent GUI")
            return nil
        end
    end

    -- Load saved position
    local savedPos = GUI.LoadPosition()

    -- Main Frame with enhanced design
    GUI.MainFrame = Instance.new("Frame")
    GUI.MainFrame.Name = "MainFrame"
    GUI.MainFrame.BackgroundColor3 = GUI.BackgroundColor
    GUI.MainFrame.BackgroundTransparency = 0.02
    GUI.MainFrame.Position = savedPos
    GUI.MainFrame.Size = UDim2.new(0, 0, 0, 0)
    GUI.MainFrame.BorderSizePixel = 0
    GUI.MainFrame.ClipsDescendants = true
    GUI.MainFrame.Parent = GUI.SkibidiGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 20)
    Corner.Parent = GUI.MainFrame
    
    -- Premium multi-layer border
    local OuterStroke = Instance.new("UIStroke")
    OuterStroke.Thickness = 3
    OuterStroke.Transparency = 0.1
    OuterStroke.Parent = GUI.MainFrame
    
    local OuterGradient = Instance.new("UIGradient")
    OuterGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, GUI.AccentColor),
        ColorSequenceKeypoint.new(0.33, GUI.SecondaryColor),
        ColorSequenceKeypoint.new(0.66, GUI.TertiaryColor),
        ColorSequenceKeypoint.new(1, GUI.GlowColor)
    }
    OuterGradient.Rotation = 0
    OuterGradient.Parent = OuterStroke
    
    -- Smooth continuous border animation
    GUI.AddTask(task.spawn(function()
        while OuterStroke and OuterStroke.Parent and OuterGradient and OuterGradient.Parent do
            SmoothTween(OuterGradient, {Rotation = OuterGradient.Rotation + 360}, 6, Enum.EasingStyle.Linear)
            task.wait(6)
        end
    end))
    
    -- Frosted glass effect
    local GlassOverlay = Instance.new("Frame")
    GlassOverlay.Size = UDim2.new(1, 0, 1, 0)
    GlassOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    GlassOverlay.BackgroundTransparency = 0.96
    GlassOverlay.BorderSizePixel = 0
    GlassOverlay.Parent = GUI.MainFrame
    
    local GlassCorner = Instance.new("UICorner")
    GlassCorner.CornerRadius = UDim.new(0, 20)
    GlassCorner.Parent = GlassOverlay

    -- Background Image Layer
    GUI.BackgroundImage = Instance.new("ImageLabel")
    GUI.BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
    GUI.BackgroundImage.BackgroundTransparency = 1
    GUI.BackgroundImage.ScaleType = Enum.ScaleType.Crop
    GUI.BackgroundImage.ImageTransparency = 0.7
    GUI.BackgroundImage.ZIndex = 0
    GUI.BackgroundImage.Parent = GUI.MainFrame
    
    local BgCorner = Instance.new("UICorner")
    BgCorner.CornerRadius = UDim.new(0, 20)
    BgCorner.Parent = GUI.BackgroundImage
    
    -- Dark overlay
    local DarkOverlay = Instance.new("Frame")
    DarkOverlay.Size = UDim2.new(1, 0, 1, 0)
    DarkOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    DarkOverlay.BackgroundTransparency = 0.35
    DarkOverlay.BorderSizePixel = 0
    DarkOverlay.ZIndex = 1
    DarkOverlay.Parent = GUI.MainFrame
    
    local DarkCorner = Instance.new("UICorner")
    DarkCorner.CornerRadius = UDim.new(0, 20)
    DarkCorner.Parent = DarkOverlay
    
    -- Premium floating particles
    for i = 1, 25 do
        local colors = {GUI.AccentColor, GUI.SecondaryColor, GUI.TertiaryColor, GUI.GlowColor}
        CreateFloatingParticle(GUI.MainFrame, colors[math.random(1, #colors)])
    end
    
    -- Enhanced dragging with position saving
    local dragging, dragInput, dragStart, startPos
    
    local dragBeganConnection = GUI.MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = GUI.MainFrame.Position
            
            SmoothTween(GUI.MainFrame, {
                Size = GUI.MainFrame.Size - UDim2.new(0, 8, 0, 8)
            }, 0.15)
            SmoothTween(OuterStroke, {Thickness = 4}, 0.15)
            
            local endConnection
            endConnection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then 
                    dragging = false
                    SmoothTween(GUI.MainFrame, {
                        Size = UDim2.new(0, 450, 0, 600)
                    }, 0.15)
                    SmoothTween(OuterStroke, {Thickness = 3}, 0.15)
                    GUI.SavePosition() -- Save position when drag ends
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

    -- Premium Header with gradient
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 85)
    Header.BackgroundTransparency = 1
    Header.ZIndex = 2
    Header.Parent = GUI.MainFrame
    
    -- Header glow background
    local HeaderGlow = Instance.new("Frame")
    HeaderGlow.Size = UDim2.new(1, 0, 1, 0)
    HeaderGlow.BackgroundColor3 = GUI.GlowColor
    HeaderGlow.BackgroundTransparency = 0.92
    HeaderGlow.BorderSizePixel = 0
    HeaderGlow.ZIndex = 2
    HeaderGlow.Parent = Header
    
    local HeaderGlowTop = Instance.new("UICorner")
    HeaderGlowTop.CornerRadius = UDim.new(0, 20)
    HeaderGlowTop.Parent = HeaderGlow
    
    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Text = "CUACKER'S CUM"
    HeaderTitle.Size = UDim2.new(1, -100, 1, 0)
    HeaderTitle.Position = UDim2.new(0, 30, 0, 0)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Font = Enum.Font.GothamBlack
    HeaderTitle.TextColor3 = GUI.TextPrimary
    HeaderTitle.TextSize = 28
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeaderTitle.ZIndex = 3
    HeaderTitle.Parent = Header
    
    -- Animated gradient on title
    local HeaderGradient = Instance.new("UIGradient")
    HeaderGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, GUI.AccentColor),
        ColorSequenceKeypoint.new(0.5, GUI.SecondaryColor),
        ColorSequenceKeypoint.new(1, GUI.TertiaryColor)
    }
    HeaderGradient.Rotation = 0
    HeaderGradient.Parent = HeaderTitle
    
    GUI.AddTask(task.spawn(function()
        while HeaderGradient and HeaderGradient.Parent do
            SmoothTween(HeaderGradient, {Rotation = HeaderGradient.Rotation + 360}, 8, Enum.EasingStyle.Linear)
            task.wait(8)
        end
    end))
    
    -- Text stroke for better readability
    local TitleStroke = Instance.new("UIStroke")
    TitleStroke.Color = Color3.fromRGB(0, 0, 0)
    TitleStroke.Thickness = 1
    TitleStroke.Transparency = 0.7
    TitleStroke.Parent = HeaderTitle
    
    -- Enhanced version badge
    local VersionBadge = Instance.new("Frame")
    VersionBadge.Size = UDim2.new(0, 65, 0, 32)
    VersionBadge.Position = UDim2.new(1, -95, 0.5, -16)
    VersionBadge.BackgroundColor3 = GUI.AccentColor
    VersionBadge.BackgroundTransparency = 0.2
    VersionBadge.BorderSizePixel = 0
    VersionBadge.ZIndex = 3
    VersionBadge.Parent = Header
    
    local BadgeCorner = Instance.new("UICorner")
    BadgeCorner.CornerRadius = UDim.new(0, 16)
    BadgeCorner.Parent = VersionBadge
    
    local BadgeGradient = Instance.new("UIGradient")
    BadgeGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, GUI.AccentColor),
        ColorSequenceKeypoint.new(1, GUI.SecondaryColor)
    }
    BadgeGradient.Rotation = 45
    BadgeGradient.Parent = VersionBadge
    
    local BadgeStroke = Instance.new("UIStroke")
    BadgeStroke.Color = GUI.GlowColor
    BadgeStroke.Thickness = 1.5
    BadgeStroke.Transparency = 0.3
    BadgeStroke.Parent = VersionBadge
    
    local BadgeText = Instance.new("TextLabel")
    BadgeText.Text = "v5.0"
    BadgeText.Size = UDim2.new(1, 0, 1, 0)
    BadgeText.BackgroundTransparency = 1
    BadgeText.Font = Enum.Font.GothamBlack
    BadgeText.TextColor3 = GUI.TextPrimary
    BadgeText.TextSize = 15
    BadgeText.ZIndex = 4
    BadgeText.Parent = VersionBadge

    -- Stats Container with better spacing
    local StatsContainer = Instance.new("Frame")
    StatsContainer.Position = UDim2.new(0, 25, 0, 110)
    StatsContainer.Size = UDim2.new(1, -50, 0, 465)
    StatsContainer.BackgroundTransparency = 1
    StatsContainer.ZIndex = 2
    StatsContainer.Parent = GUI.MainFrame
    
    local Layout = Instance.new("UIListLayout")
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 16)
    Layout.Parent = StatsContainer

    -- Create modern icon with unicode symbols
    local function CreateIconFrame(iconText, color)
        local IconFrame = Instance.new("Frame")
        IconFrame.Size = UDim2.new(0, 54, 0, 54)
        IconFrame.BackgroundColor3 = color
        IconFrame.BackgroundTransparency = 0.75
        IconFrame.BorderSizePixel = 0
        
        local IconCorner = Instance.new("UICorner")
        IconCorner.CornerRadius = UDim.new(0, 14)
        IconCorner.Parent = IconFrame
        
        -- Glow effect
        local IconGlow = Instance.new("Frame")
        IconGlow.Size = UDim2.new(1, 12, 1, 12)
        IconGlow.Position = UDim2.new(0, -6, 0, -6)
        IconGlow.BackgroundColor3 = color
        IconGlow.BackgroundTransparency = 0.85
        IconGlow.BorderSizePixel = 0
        IconGlow.ZIndex = 0
        IconGlow.Parent = IconFrame
        
        local GlowCorner = Instance.new("UICorner")
        GlowCorner.CornerRadius = UDim.new(0, 16)
        GlowCorner.Parent = IconGlow
        
        local IconStroke = Instance.new("UIStroke")
        IconStroke.Color = color
        IconStroke.Thickness = 2
        IconStroke.Transparency = 0.4
        IconStroke.Parent = IconFrame
        
        local Icon = Instance.new("TextLabel")
        Icon.Size = UDim2.new(1, 0, 1, 0)
        Icon.BackgroundTransparency = 1
        Icon.Font = Enum.Font.GothamBlack
        Icon.Text = iconText
        Icon.TextColor3 = color
        Icon.TextSize = 26
        Icon.Parent = IconFrame
        
        return IconFrame
    end
    
    local function CreateStatCard(label, value, iconText, iconColor, order)
        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(1, 0, 0, 90)
        Card.BackgroundColor3 = GUI.CardColor
        Card.BackgroundTransparency = 0.15
        Card.BorderSizePixel = 0
        Card.LayoutOrder = order
        Card.ZIndex = 2
        Card.Parent = StatsContainer
        
        local CardCorner = Instance.new("UICorner")
        CardCorner.CornerRadius = UDim.new(0, 16)
        CardCorner.Parent = Card
        
        -- Multi-layer border
        local CardStroke = Instance.new("UIStroke")
        CardStroke.Color = Color3.fromRGB(50, 50, 70)
        CardStroke.Thickness = 1.5
        CardStroke.Transparency = 0.6
        CardStroke.Parent = Card
        
        -- Inner glow
        local InnerGlow = Instance.new("Frame")
        InnerGlow.Size = UDim2.new(1, 0, 1, 0)
        InnerGlow.BackgroundColor3 = iconColor
        InnerGlow.BackgroundTransparency = 0.96
        InnerGlow.BorderSizePixel = 0
        InnerGlow.ZIndex = 2
        InnerGlow.Parent = Card
        
        local InnerCorner = Instance.new("UICorner")
        InnerCorner.CornerRadius = UDim.new(0, 16)
        InnerCorner.Parent = InnerGlow
        
        -- Enhanced hover effect
        local enterConnection = Card.MouseEnter:Connect(function()
            SmoothTween(Card, {BackgroundTransparency = 0.05}, 0.25)
            SmoothTween(CardStroke, {Transparency = 0.3}, 0.25)
            SmoothTween(InnerGlow, {BackgroundTransparency = 0.92}, 0.25)
        end)
        GUI.AddConnection(enterConnection)
        
        local leaveConnection = Card.MouseLeave:Connect(function()
            SmoothTween(Card, {BackgroundTransparency = 0.15}, 0.25)
            SmoothTween(CardStroke, {Transparency = 0.6}, 0.25)
            SmoothTween(InnerGlow, {BackgroundTransparency = 0.96}, 0.25)
        end)
        GUI.AddConnection(leaveConnection)
        
        -- Icon
        local Icon = CreateIconFrame(iconText, iconColor)
        Icon.Position = UDim2.new(0, 18, 0.5, -27)
        Icon.Parent = Card
        
        -- Label
        local Label = Instance.new("TextLabel")
        Label.Text = label
        Label.Size = UDim2.new(1, -95, 0, 24)
        Label.Position = UDim2.new(0, 85, 0, 16)
        Label.BackgroundTransparency = 1
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 14
        Label.TextColor3 = GUI.TextSecondary
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.ZIndex = 3
        Label.Parent = Card
        
        -- Value
        local Value = Instance.new("TextLabel")
        Value.Text = value
        Value.Size = UDim2.new(1, -95, 0, 36)
        Value.Position = UDim2.new(0, 85, 0, 40)
        Value.BackgroundTransparency = 1
        Value.Font = Enum.Font.GothamBlack
        Value.TextSize = 24
        Value.TextColor3 = GUI.TextPrimary
        Value.TextXAlignment = Enum.TextXAlignment.Left
        Value.ZIndex = 3
        Value.TextTruncate = Enum.TextTruncate.AtEnd
        Value.Parent = Card
        
        return Value
    end

    -- Create stat cards with proper unicode icons
    vars.TargetLabel = CreateStatCard("Current Target", "Searching...", "●", GUI.AccentColor, 1)
    vars.StateLabel = CreateStatCard("Status", "Initializing", "⚡", GUI.SecondaryColor, 2)
    vars.BountyLabel = CreateStatCard("Bounty Gained", "+0", "◆", Color3.fromRGB(255, 215, 0), 3)
    vars.TimeLabel = CreateStatCard("Session Time", "00:00:00", "⏱", GUI.TertiaryColor, 4)

    -- Session time updater (optimized)
    local sessionStartTime = tick()
    GUI.AddTask(task.spawn(function()
        while vars.TimeLabel and vars.TimeLabel.Parent do
            task.wait(1)
            
            local elapsed = tick() - sessionStartTime
            local hours = math.floor(elapsed / 3600)
            local minutes = math.floor((elapsed % 3600) / 60)
            local seconds = math.floor(elapsed % 60)
            
            vars.TimeLabel.Text = string.format("%02d:%02d:%02d", hours, minutes, seconds)
        end
    end))

    -- Spectacular entrance animation
    SmoothTween(GUI.MainFrame, {
        Size = UDim2.new(0, 450, 0, 600)
    }, 0.8, Enum.EasingStyle.Back)

    -- Staggered card fade-in with delays
    GUI.AddTask(task.spawn(function()
        for i, card in ipairs(StatsContainer:GetChildren()) do
            if card:IsA("Frame") and card ~= Layout then
                card.BackgroundTransparency = 1
                for _, child in pairs(card:GetDescendants()) do
                    if child:IsA("TextLabel") then
                        child.TextTransparency = 1
                    elseif child:IsA("Frame") then
                        child.BackgroundTransparency = 1
                    end
                end
                
                task.wait(0.08)
                
                SmoothTween(card, {BackgroundTransparency = 0.15}, 0.6)
                for _, child in pairs(card:GetDescendants()) do
                    if child:IsA("TextLabel") and child.Name ~= "Icon" then
                        SmoothTween(child, {TextTransparency = 0}, 0.6)
                    elseif child:IsA("Frame") and child.Name ~= "InnerGlow" then
                        SmoothTween(child, {BackgroundTransparency = child.Name == "IconGlow" and 0.85 or 0.75}, 0.6)
                    end
                end
            end
        end
    end))

    print("[CUACKER] GUI initialized")
    
    -- Auto-load assets after GUI is created
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
    print("[CUACKER] Starting cleanup...")
    
    GUI.SaveMusicState()
    GUI.SavePosition()
    
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
    GUI.MusicLoaded = false
    
    print("[CUACKER] Cleanup complete")
end

return GUI
