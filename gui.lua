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

-- Modern accent colors
GUI.AccentColor = Color3.fromRGB(147, 51, 234) -- Purple
GUI.SecondaryColor = Color3.fromRGB(236, 72, 153) -- Pink
GUI.BackgroundColor = Color3.fromRGB(17, 17, 27)
GUI.SurfaceColor = Color3.fromRGB(28, 28, 40)

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
        warn("[SKIBIDI] Tween creation failed:", tween)
        return nil
    end
    
    table.insert(GUI.RunningTweens, tween)
    
    tween.Completed:Connect(function()
        local index = table.find(GUI.RunningTweens, tween)
        if index then
            table.remove(GUI.RunningTweens, index)
        end
    end)
    
    local playSuccess = pcall(function()
        tween:Play()
    end)
    
    if not playSuccess then
        local index = table.find(GUI.RunningTweens, tween)
        if index then
            table.remove(GUI.RunningTweens, index)
        end
    end
    
    return tween
end

-- Particle effect system with proper cleanup
local function CreateParticle(parent)
    if not parent or not parent.Parent then
        return nil
    end
    
    local particle = Instance.new("Frame")
    particle.Size = UDim2.new(0, 4, 0, 4)
    particle.BackgroundColor3 = GUI.AccentColor
    particle.BorderSizePixel = 0
    particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
    particle.BackgroundTransparency = 0.3
    particle.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = particle
    
    local animTask = task.spawn(function()
        while particle and particle.Parent and parent and parent.Parent do
            local success = pcall(function()
                local randomX = math.random()
                local randomY = math.random()
                SmoothTween(particle, {
                    Position = UDim2.new(randomX, 0, randomY, 0),
                    BackgroundTransparency = math.random() > 0.5 and 0.8 or 0.3
                }, 3, Enum.EasingStyle.Sine)
            end)
            
            if not success then
                break
            end
            
            task.wait(3)
        end
        
        -- Cleanup
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
    
    local success, err = pcall(function()
        if GUI.MusicSound.IsPlaying and writefile then
            local timePos = GUI.MusicSound.TimePosition
            if timePos and type(timePos) == "number" and timePos > 0 then
                writefile(TIME_PATH, tostring(timePos))
                print("[SKIBIDI] Music position saved: " .. timePos)
            end
        end
    end)
    
    if not success then
        warn("[SKIBIDI] Failed to save music state:", err)
    end
end

function GUI.CreateLoadingScreen()
    local LoadingScreen = Instance.new("Frame")
    LoadingScreen.Name = "LoadingScreen"
    LoadingScreen.Size = UDim2.new(1, 0, 1, 0)
    LoadingScreen.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    LoadingScreen.BorderSizePixel = 0
    LoadingScreen.ZIndex = 999
    LoadingScreen.Parent = GUI.SkibidiGui
    
    -- Gradient background
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(17, 17, 27)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 20, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(17, 17, 27))
    }
    Gradient.Rotation = 45
    Gradient.Parent = LoadingScreen
    
    -- Animated gradient
    GUI.AddTask(task.spawn(function()
        while LoadingScreen and LoadingScreen.Parent and Gradient and Gradient.Parent do
            SmoothTween(Gradient, {Rotation = Gradient.Rotation + 360}, 8, Enum.EasingStyle.Linear)
            task.wait(8)
        end
    end))
    
    -- Logo container
    local LogoContainer = Instance.new("Frame")
    LogoContainer.Size = UDim2.new(0, 400, 0, 300)
    LogoContainer.Position = UDim2.new(0.5, -200, 0.5, -150)
    LogoContainer.BackgroundTransparency = 1
    LogoContainer.Parent = LoadingScreen
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Text = "SKIBIDI"
    Title.Size = UDim2.new(1, 0, 0, 80)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBlack
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 56
    Title.TextTransparency = 1
    Title.Parent = LogoContainer
    
    -- Gradient text effect
    local TitleGradient = Instance.new("UIGradient")
    TitleGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, GUI.AccentColor),
        ColorSequenceKeypoint.new(0.5, GUI.SecondaryColor),
        ColorSequenceKeypoint.new(1, GUI.AccentColor)
    }
    TitleGradient.Rotation = 45
    TitleGradient.Parent = Title
    
    -- Subtitle
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Text = "PREMIUM AUTO FARM"
    Subtitle.Size = UDim2.new(1, 0, 0, 30)
    Subtitle.Position = UDim2.new(0, 0, 0, 80)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Font = Enum.Font.GothamMedium
    Subtitle.TextColor3 = Color3.fromRGB(200, 200, 220)
    Subtitle.TextSize = 16
    Subtitle.TextTransparency = 1
    Subtitle.Parent = LogoContainer
    
    -- Loading bar background
    local BarBg = Instance.new("Frame")
    BarBg.Size = UDim2.new(0.8, 0, 0, 6)
    BarBg.Position = UDim2.new(0.1, 0, 0, 150)
    BarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    BarBg.BorderSizePixel = 0
    BarBg.BackgroundTransparency = 1
    BarBg.Parent = LogoContainer
    
    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(1, 0)
    BarCorner.Parent = BarBg
    
    -- Loading bar
    local LoadingBar = Instance.new("Frame")
    LoadingBar.Size = UDim2.new(0, 0, 1, 0)
    LoadingBar.BackgroundColor3 = GUI.AccentColor
    LoadingBar.BorderSizePixel = 0
    LoadingBar.Parent = BarBg
    
    local LoadBarCorner = Instance.new("UICorner")
    LoadBarCorner.CornerRadius = UDim.new(1, 0)
    LoadBarCorner.Parent = LoadingBar
    
    -- Glow effect
    local Glow = Instance.new("ImageLabel")
    Glow.Size = UDim2.new(1.5, 0, 1.5, 0)
    Glow.Position = UDim2.new(-0.25, 0, -0.25, 0)
    Glow.BackgroundTransparency = 1
    Glow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    Glow.ImageColor3 = GUI.AccentColor
    Glow.ImageTransparency = 0.5
    Glow.Parent = LoadingBar
    
    -- Loading text
    local LoadText = Instance.new("TextLabel")
    LoadText.Text = "Initializing..."
    LoadText.Size = UDim2.new(1, 0, 0, 30)
    LoadText.Position = UDim2.new(0, 0, 0, 170)
    LoadText.BackgroundTransparency = 1
    LoadText.Font = Enum.Font.Gotham
    LoadText.TextColor3 = Color3.fromRGB(180, 180, 200)
    LoadText.TextSize = 14
    LoadText.TextTransparency = 1
    LoadText.Parent = LogoContainer
    
    -- Particles
    for i = 1, 20 do
        CreateParticle(LoadingScreen)
    end
    
    -- Fade in animation
    SmoothTween(Title, {TextTransparency = 0}, 0.8)
    task.wait(0.2)
    SmoothTween(Subtitle, {TextTransparency = 0}, 0.8)
    task.wait(0.2)
    SmoothTween(BarBg, {BackgroundTransparency = 0.5}, 0.8)
    SmoothTween(LoadText, {TextTransparency = 0}, 0.8)
    
    GUI.LoadingScreen = LoadingScreen
    
    return {
        Screen = LoadingScreen,
        Bar = LoadingBar,
        Text = LoadText,
        Update = function(progress, text)
            if LoadText and LoadText.Parent then
                LoadText.Text = text or "Loading..."
            end
            if LoadingBar and LoadingBar.Parent then
                SmoothTween(LoadingBar, {Size = UDim2.new(progress, 0, 1, 0)}, 0.3)
            end
        end,
        Complete = function()
            if not LoadingScreen or not LoadingScreen.Parent then
                return
            end
            
            if LoadText and LoadText.Parent then
                LoadText.Text = "Complete!"
            end
            
            task.wait(0.5)
            
            pcall(function()
                SmoothTween(LoadingScreen, {BackgroundTransparency = 1}, 0.5)
                
                for _, child in pairs(LoadingScreen:GetDescendants()) do
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
            
            if LoadingScreen and LoadingScreen.Parent then
                LoadingScreen:Destroy()
            end
            
            GUI.LoadingScreen = nil
        end
    }
end

function GUI.InitAssets(progressCallback)
    print("[SKIBIDI] Initializing assets...")
    
    local loading = GUI.CreateLoadingScreen()
    if not loading then
        warn("[SKIBIDI] Failed to create loading screen")
        return
    end
    
    loading.Update(0.1, "Creating workspace...")
    
    -- Create workspace folder
    pcall(function()
        if makefolder and not isfolder(WORKSPACE_FOLDER) then 
            makefolder(WORKSPACE_FOLDER) 
            print("[SKIBIDI] Created workspace folder")
        end
    end)
    
    task.wait(0.3)
    loading.Update(0.2, "Loading music system...")

    -- Initialize music sound object
    local musicSuccess = pcall(function()
        GUI.MusicSound = Instance.new("Sound")
        GUI.MusicSound.Name = "SkibidiMusic"
        GUI.MusicSound.Looped = true
        GUI.MusicSound.Volume = GUI.Config.MusicVolume
        GUI.MusicSound.Parent = SoundService
    end)
    
    if not musicSuccess then
        warn("[SKIBIDI] Failed to create music sound")
    end

    -- Load music asynchronously
    GUI.AddTask(task.spawn(function()
        task.wait(0.1) -- Small delay to ensure sound is ready
        
        local success, err = pcall(function()
            local asset = getcustomasset or getsynasset
            if not asset then 
                warn("[SKIBIDI] No asset loader available")
                loading.Update(0.5, "Music unavailable")
                return 
            end
            
            -- Download music if not cached
            if isfile and not isfile(MUSIC_PATH) then
                if writefile then
                    loading.Update(0.35, "Downloading music...")
                    local httpSuccess, musicData = pcall(function()
                        return game:HttpGet(ASSETS_REPO .. MUSIC_FILENAME, true)
                    end)
                    
                    if httpSuccess and musicData then
                        writefile(MUSIC_PATH, musicData)
                        print("[SKIBIDI] Music downloaded")
                    else
                        warn("[SKIBIDI] Failed to download music")
                        loading.Update(0.5, "Music download failed")
                        return
                    end
                end
            end
            
            -- Load music from file
            if isfile and isfile(MUSIC_PATH) and GUI.MusicSound then
                local assetUrl = asset(MUSIC_PATH)
                GUI.MusicSound.SoundId = assetUrl
                
                -- Restore saved position
                if isfile(TIME_PATH) and readfile then
                    local savedTimeStr = readfile(TIME_PATH)
                    local savedTime = tonumber(savedTimeStr)
                    if savedTime and savedTime > 0 then 
                        GUI.MusicSound.TimePosition = savedTime
                        print("[SKIBIDI] Restored music position: " .. savedTime)
                    end
                end
                
                -- Play music
                GUI.MusicSound:Play()
                print("[SKIBIDI] Music loaded and playing")
                loading.Update(0.5, "Music loaded!")
            else
                loading.Update(0.5, "Music file not found")
            end
        end)
        
        if not success then
            warn("[SKIBIDI] Music load error:", err)
            loading.Update(0.5, "Music load failed")
        end
    end))

    task.wait(0.4)
    loading.Update(0.6, "Waiting for GUI...")

    -- Wait for BackgroundImage to be created (by GUI.Init)
    local maxWait = 100 -- 10 seconds max
    local waited = 0
    while not GUI.BackgroundImage and waited < maxWait do
        task.wait(0.1)
        waited = waited + 1
    end
    
    if not GUI.BackgroundImage then
        warn("[SKIBIDI] BackgroundImage not initialized in time")
        loading.Update(0.9, "Background skipped")
    else
        loading.Update(0.65, "Loading background...")
        
        -- Load background image asynchronously
        GUI.AddTask(task.spawn(function()
            local success, err = pcall(function()
                local asset = getcustomasset or getsynasset
                if not asset then 
                    warn("[SKIBIDI] No asset loader available for background")
                    loading.Update(0.9, "Background unavailable")
                    return 
                end
                
                -- Download background if not cached
                if isfile and not isfile(BG_PATH) then
                    if writefile then
                        loading.Update(0.7, "Downloading background...")
                        local httpSuccess, bgData = pcall(function()
                            return game:HttpGet(ASSETS_REPO .. BG_FILENAME, true)
                        end)
                        
                        if httpSuccess and bgData then
                            writefile(BG_PATH, bgData)
                            print("[SKIBIDI] Background downloaded")
                        else
                            warn("[SKIBIDI] Failed to download background")
                            loading.Update(0.9, "Background download failed")
                            return
                        end
                    end
                end
                
                -- Load background from file
                if isfile and isfile(BG_PATH) and GUI.BackgroundImage and GUI.BackgroundImage.Parent then
                    local assetUrl = asset(BG_PATH)
                    GUI.BackgroundImage.Image = assetUrl
                    print("[SKIBIDI] Background loaded: " .. assetUrl)
                    loading.Update(0.9, "Background loaded!")
                else
                    loading.Update(0.9, "Background not available")
                end
            end)
            
            if not success then
                warn("[SKIBIDI] Background load error:", err)
                loading.Update(0.9, "Background load failed")
            end
        end))
    end
    
    task.wait(1)
    loading.Update(1, "Starting farm...")
    task.wait(0.5)
    loading.Complete()
    
    -- Save music state on teleport
    local teleportConnection = Players.LocalPlayer.OnTeleport:Connect(function()
        GUI.SaveMusicState()
    end)
    GUI.AddConnection(teleportConnection)
    
    print("[SKIBIDI] Assets initialized")
end

function GUI.Init(vars)
    -- Cleanup existing GUI
    if GUI.SkibidiGui then 
        GUI.Cleanup()
    end
    
    -- Validate vars table
    if not vars or type(vars) ~= "table" then
        warn("[SKIBIDI] Invalid vars table provided, creating new one")
        vars = {}
    end
    
    local lp = Players.LocalPlayer
    if not lp then
        warn("[SKIBIDI] LocalPlayer not found")
        return nil
    end
    
    -- Create main ScreenGui
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

    -- Main Frame with glassmorphism
    GUI.MainFrame = Instance.new("Frame")
    GUI.MainFrame.Name = "MainFrame"
    GUI.MainFrame.BackgroundColor3 = GUI.BackgroundColor
    GUI.MainFrame.BackgroundTransparency = 0.1
    GUI.MainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
    GUI.MainFrame.Size = UDim2.new(0, 0, 0, 0)
    GUI.MainFrame.BorderSizePixel = 0
    GUI.MainFrame.ClipsDescendants = true
    GUI.MainFrame.Parent = GUI.SkibidiGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 20)
    Corner.Parent = GUI.MainFrame
    
    -- Animated gradient border
    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 2
    Stroke.Transparency = 0.3
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
            SmoothTween(StrokeGradient, {Rotation = StrokeGradient.Rotation + 360}, 4, Enum.EasingStyle.Linear)
            task.wait(4)
        end
    end))
    
    -- Blur effect
    local Blur = Instance.new("Frame")
    Blur.Size = UDim2.new(1, 0, 1, 0)
    Blur.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Blur.BackgroundTransparency = 0.95
    Blur.BorderSizePixel = 0
    Blur.Parent = GUI.MainFrame
    
    local BlurCorner = Instance.new("UICorner")
    BlurCorner.CornerRadius = UDim.new(0, 20)
    BlurCorner.Parent = Blur

    -- Background Image Layer - CREATE THIS BEFORE InitAssets
    GUI.BackgroundImage = Instance.new("ImageLabel")
    GUI.BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
    GUI.BackgroundImage.BackgroundTransparency = 1
    GUI.BackgroundImage.ScaleType = Enum.ScaleType.Crop
    GUI.BackgroundImage.ImageTransparency = 0.3
    GUI.BackgroundImage.ZIndex = 0
    GUI.BackgroundImage.Parent = GUI.MainFrame
    
    local BgCorner = Instance.new("UICorner")
    BgCorner.CornerRadius = UDim.new(0, 20)
    BgCorner.Parent = GUI.BackgroundImage
    
    -- Dragging functionality
    local dragging, dragInput, dragStart, startPos
    
    local dragBeganConnection = GUI.MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = GUI.MainFrame.Position
            
            SmoothTween(GUI.MainFrame, {
                Size = GUI.MainFrame.Size - UDim2.new(0, 5, 0, 5)
            }, 0.1)
            
            local endConnection
            endConnection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then 
                    dragging = false
                    SmoothTween(GUI.MainFrame, {
                        Size = UDim2.new(0, 350, 0, 500)
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

    -- Header with icon
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 60)
    Header.BackgroundTransparency = 1
    Header.Parent = GUI.MainFrame
    
    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Text = "SKIBIDI FARM"
    HeaderTitle.Size = UDim2.new(1, -40, 1, 0)
    HeaderTitle.Position = UDim2.new(0, 20, 0, 0)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Font = Enum.Font.GothamBlack
    HeaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    HeaderTitle.TextSize = 28
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
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
    VersionBadge.Size = UDim2.new(0, 50, 0, 24)
    VersionBadge.Position = UDim2.new(1, -70, 0.5, -12)
    VersionBadge.BackgroundColor3 = GUI.AccentColor
    VersionBadge.BackgroundTransparency = 0.8
    VersionBadge.Font = Enum.Font.GothamBold
    VersionBadge.TextColor3 = Color3.fromRGB(255, 255, 255)
    VersionBadge.TextSize = 12
    VersionBadge.Parent = Header
    
    local BadgeCorner = Instance.new("UICorner")
    BadgeCorner.CornerRadius = UDim.new(0, 12)
    BadgeCorner.Parent = VersionBadge

    -- Stats Container
    local StatsContainer = Instance.new("Frame")
    StatsContainer.Position = UDim2.new(0, 20, 0, 80)
    StatsContainer.Size = UDim2.new(1, -40, 0, 380)
    StatsContainer.BackgroundTransparency = 1
    StatsContainer.Parent = GUI.MainFrame
    
    local Layout = Instance.new("UIListLayout")
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 12)
    Layout.Parent = StatsContainer

    local function CreateStatCard(label, value, icon)
        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(1, 0, 0, 70)
        Card.BackgroundColor3 = GUI.SurfaceColor
        Card.BackgroundTransparency = 0.3
        Card.BorderSizePixel = 0
        Card.Parent = StatsContainer
        
        local CardCorner = Instance.new("UICorner")
        CardCorner.CornerRadius = UDim.new(0, 12)
        CardCorner.Parent = Card
        
        -- Hover effect
        local enterConnection = Card.MouseEnter:Connect(function()
            SmoothTween(Card, {BackgroundTransparency = 0.1}, 0.2)
        end)
        GUI.AddConnection(enterConnection)
        
        local leaveConnection = Card.MouseLeave:Connect(function()
            SmoothTween(Card, {BackgroundTransparency = 0.3}, 0.2)
        end)
        GUI.AddConnection(leaveConnection)
        
        -- Icon
        local IconLabel = Instance.new("TextLabel")
        IconLabel.Text = icon
        IconLabel.Size = UDim2.new(0, 40, 0, 40)
        IconLabel.Position = UDim2.new(0, 15, 0.5, -20)
        IconLabel.BackgroundTransparency = 1
        IconLabel.Font = Enum.Font.GothamBold
        IconLabel.TextSize = 24
        IconLabel.TextColor3 = GUI.AccentColor
        IconLabel.Parent = Card
        -- Label
    local Label = Instance.new("TextLabel")
    Label.Text = label
    Label.Size = UDim2.new(1, -70, 0, 20)
    Label.Position = UDim2.new(0, 60, 0, 12)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextColor3 = Color3.fromRGB(160, 160, 180)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Card
    
    -- Value
    local Value = Instance.new("TextLabel")
    Value.Text = value
    Value.Size = UDim2.new(1, -70, 0, 28)
    Value.Position = UDim2.new(0, 60, 0, 32)
    Value.BackgroundTransparency = 1
    Value.Font = Enum.Font.GothamBold
    Value.TextSize = 20
    Value.TextColor3 = Color3.fromRGB(255, 255, 255)
    Value.TextXAlignment = Enum.TextXAlignment.Left
    Value.Parent = Card
    
    -- Pulse animation for value changes
    local lastValue = value
    GUI.AddTask(task.spawn(function()
        while Value and Value.Parent and Card and Card.Parent do
            task.wait(0.1)
            if Value.Text ~= lastValue then
                lastValue = Value.Text
                pcall(function()
                    SmoothTween(Value, {TextSize = 24}, 0.1)
                    task.wait(0.1)
                    SmoothTween(Value, {TextSize = 20}, 0.1)
                end)
            end
        end
    end))
    
    return Value
end

-- Create stat cards
vars.TargetLabel = CreateStatCard("Current Target", "Searching...", "🎯")
vars.StateLabel = CreateStatCard("Status", "Initializing", "⚡")
vars.BountyLabel = CreateStatCard("Bounty Gained", "+0", "💎")
vars.TimeLabel = CreateStatCard("Session Time", "00:00:00", "⏱️")
vars.FarmedLabel = CreateStatCard("Players Farmed", "0", "📊")

-- Entrance animation
SmoothTween(GUI.MainFrame, {
    Size = UDim2.new(0, 350, 0, 500)
}, 0.6, Enum.EasingStyle.Back)

-- Stagger animation for cards
GUI.AddTask(task.spawn(function()
    for i, card in ipairs(StatsContainer:GetChildren()) do
        if card:IsA("Frame") and card ~= Layout then
            card.BackgroundTransparency = 1
            task.wait(0.05)
            SmoothTween(card, {BackgroundTransparency = 0.3}, 0.4)
        end
    end
end))

print("[SKIBIDI] Modern GUI initialized")

-- Logger with clean output
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
-- Complete cleanup function
function GUI.Cleanup()
print("[SKIBIDI] Starting cleanup...")
-- Save music state
GUI.SaveMusicState()

-- Cancel all tweens
for _, tween in ipairs(GUI.RunningTweens) do
    pcall(function()
        if tween then
            tween:Cancel()
        end
    end)
end
GUI.RunningTweens = {}

-- Cancel all tasks
for _, taskThread in ipairs(GUI.Tasks) do
    pcall(function()
        if taskThread then
            task.cancel(taskThread)
        end
    end)
end
GUI.Tasks = {}

-- Disconnect all connections
for _, connection in ipairs(GUI.Connections) do
    pcall(function()
        if connection and connection.Connected then
            connection:Disconnect()
        end
    end)
end
GUI.Connections = {}

-- Stop and cleanup music
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
