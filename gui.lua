-- ============================================
-- SKIBIDI FARM V3.0 - REDESIGNED
-- Clean GUI | Fixed Gradients | Simplified Audio
-- ============================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- ============================================
-- FIXED GRADIENT PALETTE
-- ============================================
local Theme = {
    -- Primary Colors
    Primary = Color3.fromRGB(88, 101, 242),      -- Discord Blurple
    Secondary = Color3.fromRGB(114, 137, 218),   -- Light Blurple
    Success = Color3.fromRGB(87, 242, 135),      -- Green
    Warning = Color3.fromRGB(254, 231, 92),      -- Yellow
    Error = Color3.fromRGB(237, 66, 69),         -- Red
    
    -- Background Colors
    Background = Color3.fromRGB(32, 34, 37),     -- Dark Gray
    Surface = Color3.fromRGB(47, 49, 54),        -- Medium Gray
    Elevated = Color3.fromRGB(54, 57, 63),       -- Light Gray
    
    -- Text Colors
    TextPrimary = Color3.fromRGB(255, 255, 255), -- White
    TextSecondary = Color3.fromRGB(185, 187, 190), -- Light Gray
    TextMuted = Color3.fromRGB(114, 118, 125),   -- Muted Gray
    
    -- Accent Colors
    Accent1 = Color3.fromRGB(255, 115, 250),     -- Pink
    Accent2 = Color3.fromRGB(115, 255, 250),     -- Cyan
    Accent3 = Color3.fromRGB(255, 255, 115),     -- Yellow
}

-- Gradient Presets
local Gradients = {
    Primary = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.Primary),
        ColorSequenceKeypoint.new(0.5, Theme.Secondary),
        ColorSequenceKeypoint.new(1, Theme.Primary)
    },
    Rainbow = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.Accent1),
        ColorSequenceKeypoint.new(0.5, Theme.Accent2),
        ColorSequenceKeypoint.new(1, Theme.Accent3)
    },
    Success = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.Success),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 255, 150))
    }
}

-- ============================================
-- GLOBAL VARIABLES
-- ============================================
local GUI = {}
GUI.ScreenGui = nil
GUI.MainFrame = nil
GUI.Connections = {}
GUI.Tweens = {}
GUI.MusicSound = nil

local SecurityLayer = {
    Validated = false,
    KeyHash = nil,
    SessionToken = nil
}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================
local function Tween(object, properties, duration, style, direction)
    if not object or not object.Parent then return nil end
    
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    
    local tween = TweenService:Create(object, tweenInfo, properties)
    table.insert(GUI.Tweens, tween)
    
    tween.Completed:Connect(function()
        local index = table.find(GUI.Tweens, tween)
        if index then table.remove(GUI.Tweens, index) end
    end)
    
    tween:Play()
    return tween
end

local function CreateGradient(parent, gradientPreset, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = gradientPreset
    gradient.Rotation = rotation or 0
    gradient.Parent = parent
    return gradient
end

local function AnimateGradient(gradient, speed)
    task.spawn(function()
        while gradient and gradient.Parent do
            Tween(gradient, {Rotation = gradient.Rotation + 360}, speed or 3, Enum.EasingStyle.Linear)
            task.wait(speed or 3)
        end
    end)
end

local function CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 12)
    corner.Parent = parent
    return corner
end

local function CreateStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Primary
    stroke.Thickness = thickness or 2
    stroke.Transparency = transparency or 0
    stroke.Parent = parent
    return stroke
end

-- ============================================
-- AUDIO SYSTEM (SIMPLIFIED)
-- ============================================
local AUDIO_URL = "https://raw.githubusercontent.com/Ryu-Dev-here/assetsfora/main/sound.mp3"
local AUDIO_PATH = "skibidi_music/sound.mp3"

local function InitAudio()
    print("[AUDIO] Initializing music system...")
    
    task.spawn(function()
        pcall(function()
            -- Create folder if it doesn't exist
            if makefolder and not isfolder("skibidi_music") then
                makefolder("skibidi_music")
            end
            
            -- Download audio if not exists
            if isfile and not isfile(AUDIO_PATH) then
                print("[AUDIO] Downloading music...")
                if writefile then
                    local audioData = game:HttpGet(AUDIO_URL, true)
                    if audioData and #audioData > 1000 then
                        writefile(AUDIO_PATH, audioData)
                        print("[AUDIO] Music downloaded successfully")
                    end
                end
            end
            
            -- Load and play audio
            if isfile and isfile(AUDIO_PATH) then
                local getasset = getcustomasset or getsynasset
                if getasset then
                    GUI.MusicSound = Instance.new("Sound")
                    GUI.MusicSound.Name = "SkibidiMusic"
                    GUI.MusicSound.SoundId = getasset(AUDIO_PATH)
                    GUI.MusicSound.Volume = 0.5
                    GUI.MusicSound.Looped = true
                    GUI.MusicSound.Parent = SoundService
                    GUI.MusicSound:Play()
                    print("[AUDIO] Music playing")
                end
            end
        end)
    end)
end

-- ============================================
-- KEY SYSTEM GUI
-- ============================================
local KeySystem = {
    API_URL = "https://key.raservices.shop/auth/key",
    Authenticated = false,
    Attempts = 0,
    MaxAttempts = 3
}

function KeySystem:ValidateKey(key)
    if not key or type(key) ~= "string" or key == "" then
        return false, "Key cannot be empty"
    end
    
    local success, result = pcall(function()
        -- Get device info
        local deviceInfo = {
            hwid = game:GetService("RbxAnalyticsService"):GetClientId() or "UNKNOWN",
            timestamp = os.time(),
            game_id = game.PlaceId
        }
        
        -- Build payload
        local payload = {
            key = tostring(key),
            hwid = deviceInfo.hwid,
            timestamp = deviceInfo.timestamp,
            game_id = deviceInfo.game_id
        }
        
        -- Make request
        local response = request({
            Url = self.API_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["User-Agent"] = "SkibidiFarm/3.0"
            },
            Body = HttpService:JSONEncode(payload)
        })
        
        if response.StatusCode == 200 then
            local data = HttpService:JSONDecode(response.Body)
            if data.valid == true then
                SecurityLayer.Validated = true
                SecurityLayer.KeyHash = tostring(key)
                SecurityLayer.SessionToken = data.session_token or tostring(os.time())
                return true, data.message or "Authentication successful"
            else
                return false, data.message or "Invalid key"
            end
        else
            return false, "Server error: " .. tostring(response.StatusCode)
        end
    end)
    
    if not success then
        return false, "Authentication error: " .. tostring(result)
    end
    
    return result
end

function KeySystem:CreateGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "KeySystemGUI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 450, 0, 280)
    MainFrame.Position = UDim2.new(0.5, -225, 0.5, -140)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    CreateCorner(MainFrame, 16)
    CreateStroke(MainFrame, Theme.Primary, 2, 0)
    
    -- Animated gradient border
    local borderGradient = CreateGradient(MainFrame:FindFirstChildOfClass("UIStroke"), Gradients.Rainbow, 0)
    AnimateGradient(borderGradient, 4)
    
    -- Header
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 80)
    Header.BackgroundColor3 = Theme.Elevated
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame
    
    CreateCorner(Header, 16)
    
    local HeaderGradient = CreateGradient(Header, Gradients.Primary, 45)
    AnimateGradient(HeaderGradient, 5)
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -40, 0, 40)
    Title.Position = UDim2.new(0, 20, 0, 10)
    Title.BackgroundTransparency = 1
    Title.Text = "🔐 SKIBIDI FARM"
    Title.TextColor3 = Theme.TextPrimary
    Title.TextSize = 28
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header
    
    -- Subtitle
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(1, -40, 0, 20)
    Subtitle.Position = UDim2.new(0, 20, 0, 50)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "Authentication Required"
    Subtitle.TextColor3 = Theme.TextSecondary
    Subtitle.TextSize = 14
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.Parent = Header
    
    -- Key Input Container
    local InputContainer = Instance.new("Frame")
    InputContainer.Size = UDim2.new(1, -40, 0, 50)
    InputContainer.Position = UDim2.new(0, 20, 0, 100)
    InputContainer.BackgroundColor3 = Theme.Surface
    InputContainer.BorderSizePixel = 0
    InputContainer.Parent = MainFrame
    
    CreateCorner(InputContainer, 10)
    CreateStroke(InputContainer, Theme.Primary, 1, 0.5)
    
    -- Key Input Box
    local KeyBox = Instance.new("TextBox")
    KeyBox.Size = UDim2.new(1, -20, 1, 0)
    KeyBox.Position = UDim2.new(0, 10, 0, 0)
    KeyBox.BackgroundTransparency = 1
    KeyBox.Text = ""
    KeyBox.PlaceholderText = "Enter your key..."
    KeyBox.TextColor3 = Theme.TextPrimary
    KeyBox.PlaceholderColor3 = Theme.TextMuted
    KeyBox.TextSize = 16
    KeyBox.Font = Enum.Font.Gotham
    KeyBox.ClearTextOnFocus = false
    KeyBox.Parent = InputContainer
    
    -- Submit Button
    local SubmitButton = Instance.new("TextButton")
    SubmitButton.Size = UDim2.new(1, -40, 0, 45)
    SubmitButton.Position = UDim2.new(0, 20, 0, 165)
    SubmitButton.BackgroundColor3 = Theme.Primary
    SubmitButton.BorderSizePixel = 0
    SubmitButton.Text = "SUBMIT KEY"
    SubmitButton.TextColor3 = Theme.TextPrimary
    SubmitButton.TextSize = 16
    SubmitButton.Font = Enum.Font.GothamBold
    SubmitButton.AutoButtonColor = false
    SubmitButton.Parent = MainFrame
    
    CreateCorner(SubmitButton, 10)
    local buttonGradient = CreateGradient(SubmitButton, Gradients.Primary, 0)
    
    -- Button hover effect
    SubmitButton.MouseEnter:Connect(function()
        Tween(SubmitButton, {Size = UDim2.new(1, -35, 0, 45)}, 0.2)
        AnimateGradient(buttonGradient, 2)
    end)
    
    SubmitButton.MouseLeave:Connect(function()
        Tween(SubmitButton, {Size = UDim2.new(1, -40, 0, 45)}, 0.2)
    end)
    
    -- Status Label
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -40, 0, 20)
    StatusLabel.Position = UDim2.new(0, 20, 0, 220)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = ""
    StatusLabel.TextColor3 = Theme.Error
    StatusLabel.TextSize = 13
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Parent = MainFrame
    
    -- Get Key Button
    local GetKeyButton = Instance.new("TextButton")
    GetKeyButton.Size = UDim2.new(1, -40, 0, 25)
    GetKeyButton.Position = UDim2.new(0, 20, 0, 245)
    GetKeyButton.BackgroundTransparency = 1
    GetKeyButton.Text = "🔗 Get Key"
    GetKeyButton.TextColor3 = Theme.Secondary
    GetKeyButton.TextSize = 13
    GetKeyButton.Font = Enum.Font.Gotham
    GetKeyButton.Parent = MainFrame
    
    GetKeyButton.MouseButton1Click:Connect(function()
        setclipboard("https://key.raservices.shop")
        StatusLabel.Text = "✅ Link copied to clipboard!"
        StatusLabel.TextColor3 = Theme.Success
        Tween(StatusLabel, {TextTransparency = 0}, 0.2)
        task.wait(3)
        Tween(StatusLabel, {TextTransparency = 1}, 0.5)
    end)
    
    -- Submit logic
    local validating = false
    SubmitButton.MouseButton1Click:Connect(function()
        if validating then return end
        validating = true
        
        local key = KeyBox.Text
        StatusLabel.Text = "⏳ Validating..."
        StatusLabel.TextColor3 = Theme.Warning
        SubmitButton.Text = "PLEASE WAIT..."
        
        task.wait(0.5)
        
        local valid, message = self:ValidateKey(key)
        
        if valid then
            StatusLabel.Text = "✅ " .. message
            StatusLabel.TextColor3 = Theme.Success
            self.Authenticated = true
            
            task.wait(1)
            Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.5)
            task.wait(0.6)
            ScreenGui:Destroy()
        else
            self.Attempts = self.Attempts + 1
            StatusLabel.Text = string.format("❌ %s (%d/%d)", message, self.Attempts, self.MaxAttempts)
            StatusLabel.TextColor3 = Theme.Error
            SubmitButton.Text = "SUBMIT KEY"
            
            if self.Attempts >= self.MaxAttempts then
                StatusLabel.Text = "❌ Maximum attempts reached"
                SubmitButton.Enabled = false
                KeyBox.TextEditable = false
                task.wait(2)
                Players.LocalPlayer:Kick("Maximum key validation attempts reached")
            end
        end
        
        validating = false
    end)
    
    -- Animate entrance
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    Tween(MainFrame, {Size = UDim2.new(0, 450, 0, 280)}, 0.6, Enum.EasingStyle.Back)
    
    -- Wait for authentication
    while not self.Authenticated do
        task.wait(0.5)
    end
    
    return true
end

-- ============================================
-- SERVER HOP FUNCTION (FROM BLOX FRUITS SOURCE)
-- ============================================
local function ServerHop()
    print("[SERVER HOP] Looking for new server...")
    
    local PlaceID = game.PlaceId
    local AllIDs = {}
    local foundAnything = ""
    local actualHour = os.date("!*t").hour
    
    local File = pcall(function()
        AllIDs = HttpService:JSONDecode(readfile("NotSameServers.json"))
    end)
    
    if not File then
        table.insert(AllIDs, actualHour)
        writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs))
    end
    
    local function TPReturner()
        local Site
        if foundAnything == "" then
            Site = HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
        else
            Site = HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
        end
        
        local ID = ""
        if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
            foundAnything = Site.nextPageCursor
        end
        
        local num = 0
        for i, v in pairs(Site.data) do
            local Possible = true
            ID = tostring(v.id)
            
            if tonumber(v.maxPlayers) > tonumber(v.playing) then
                for _, Existing in pairs(AllIDs) do
                    if num ~= 0 then
                        if ID == tostring(Existing) then
                            Possible = false
                        end
                    else
                        if tonumber(actualHour) ~= tonumber(Existing) then
                            pcall(function()
                                delfile("NotSameServers.json")
                                AllIDs = {}
                                table.insert(AllIDs, actualHour)
                            end)
                        end
                    end
                    num = num + 1
                end
                
                if Possible == true then
                    table.insert(AllIDs, ID)
                    wait()
                    pcall(function()
                        writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs))
                        wait()
                        game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, Players.LocalPlayer)
                    end)
                    wait(4)
                end
            end
        end
    end
    
    while wait() do
        pcall(function()
            TPReturner()
            if foundAnything ~= "" then
                TPReturner()
            end
        end)
    end
end

-- ============================================
-- MAIN GUI
-- ============================================
local function CreateMainGUI()
    GUI.ScreenGui = Instance.new("ScreenGui")
    GUI.ScreenGui.Name = "SkibidiGUI"
    GUI.ScreenGui.ResetOnSpawn = false
    GUI.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    pcall(function()
        GUI.ScreenGui.Parent = CoreGui
    end)
    
    if not GUI.ScreenGui.Parent then
        GUI.ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Main Frame
    GUI.MainFrame = Instance.new("Frame")
    GUI.MainFrame.Size = UDim2.new(0, 400, 0, 500)
    GUI.MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    GUI.MainFrame.BackgroundColor3 = Theme.Background
    GUI.MainFrame.BorderSizePixel = 0
    GUI.MainFrame.Parent = GUI.ScreenGui
    
    CreateCorner(GUI.MainFrame, 20)
    CreateStroke(GUI.MainFrame, Theme.Primary, 3, 0)
    
    -- Animated border
    local borderGradient = CreateGradient(GUI.MainFrame:FindFirstChildOfClass("UIStroke"), Gradients.Rainbow, 0)
    AnimateGradient(borderGradient, 4)
    
    -- Header
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 70)
    Header.BackgroundColor3 = Theme.Elevated
    Header.BorderSizePixel = 0
    Header.Parent = GUI.MainFrame
    
    CreateCorner(Header, 20)
    local headerGradient = CreateGradient(Header, Gradients.Primary, 45)
    AnimateGradient(headerGradient, 6)
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -30, 0, 35)
    Title.Position = UDim2.new(0, 15, 0, 10)
    Title.BackgroundTransparency = 1
    Title.Text = "⚡ SKIBIDI FARM"
    Title.TextColor3 = Theme.TextPrimary
    Title.TextSize = 26
    Title.Font = Enum.Font.GothamBlack
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header
    
    -- Version
    local Version = Instance.new("TextLabel")
    Version.Size = UDim2.new(1, -30, 0, 18)
    Version.Position = UDim2.new(0, 15, 0, 45)
    Version.BackgroundTransparency = 1
    Version.Text = "v3.0 Redesigned"
    Title.TextColor3 = Theme.TextSecondary
    Version.TextSize = 12
    Version.Font = Enum.Font.Gotham
    Version.TextXAlignment = Enum.TextXAlignment.Left
    Version.Parent = Header
    
    -- Stats Container
    local StatsContainer = Instance.new("ScrollingFrame")
    StatsContainer.Size = UDim2.new(1, -30, 1, -100)
    StatsContainer.Position = UDim2.new(0, 15, 0, 85)
    StatsContainer.BackgroundTransparency = 1
    StatsContainer.BorderSizePixel = 0
    StatsContainer.ScrollBarThickness = 4
    StatsContainer.ScrollBarImageColor3 = Theme.Primary
    StatsContainer.Parent = GUI.MainFrame
    
    local Layout = Instance.new("UIListLayout")
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 12)
    Layout.Parent = StatsContainer
    
    -- Create stat cards
    local function CreateStatCard(title, icon, initialValue, color)
        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(1, -8, 0, 80)
        Card.BackgroundColor3 = Theme.Surface
        Card.BorderSizePixel = 0
        Card.Parent = StatsContainer
        
        CreateCorner(Card, 12)
        CreateStroke(Card, color, 2, 0.6)
        
        -- Icon
        local Icon = Instance.new("TextLabel")
        Icon.Size = UDim2.new(0, 50, 0, 50)
        Icon.Position = UDim2.new(0, 15, 0.5, -25)
        Icon.BackgroundColor3 = color
        Icon.BackgroundTransparency = 0.8
        Icon.Text = icon
        Icon.TextSize = 24
        Icon.Font = Enum.Font.GothamBold
        Icon.TextColor3 = color
        Icon.Parent = Card
        
        CreateCorner(Icon, 10)
        
        -- Title
        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Size = UDim2.new(1, -85, 0, 22)
        TitleLabel.Position = UDim2.new(0, 75, 0, 15)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Text = title
        TitleLabel.TextColor3 = Theme.TextSecondary
        TitleLabel.TextSize = 13
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabel.Parent = Card
        
        -- Value
        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Size = UDim2.new(1, -85, 0, 32)
        ValueLabel.Position = UDim2.new(0, 75, 0, 38)
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Text = initialValue
        ValueLabel.TextColor3 = Theme.TextPrimary
        ValueLabel.TextSize = 22
        ValueLabel.Font = Enum.Font.GothamBlack
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Left
        ValueLabel.TextTruncate = Enum.TextTruncate.AtEnd
        ValueLabel.Parent = Card
        
        return ValueLabel
    end
    
    -- Create stats
    local TargetLabel = CreateStatCard("CURRENT TARGET", "🎯", "Searching...", Theme.Primary)
    local StatusLabel = CreateStatCard("STATUS", "⚡", "Initializing", Theme.Success)
    local BountyLabel = CreateStatCard("BOUNTY GAINED", "💰", "+0", Theme.Warning)
    local TimeLabel = CreateStatCard("SESSION TIME", "⏱️", "00:00:00", Theme.Secondary)
    local KillsLabel = CreateStatCard("ELIMINATIONS", "💀", "0", Theme.Error)
    
    -- Animate entrance
    GUI.MainFrame.Size = UDim2.new(0, 0, 0, 0)
    Tween(GUI.MainFrame, {Size = UDim2.new(0, 400, 0, 500)}, 0.7, Enum.EasingStyle.Back)
    
    -- Make draggable
    local dragging, dragInput, dragStart, startPos
    
    GUI.MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = GUI.MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            GUI.MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    return {
        TargetLabel = TargetLabel,
        StatusLabel = StatusLabel,
        BountyLabel = BountyLabel,
        TimeLabel = TimeLabel,
        KillsLabel = KillsLabel
    }
end

-- ============================================
-- CLEANUP FUNCTION
-- ============================================
local function Cleanup()
    print("[CLEANUP] Shutting down...")
    
    -- Stop music
    if GUI.MusicSound then
        GUI.MusicSound:Stop()
        GUI.MusicSound:Destroy()
    end
    
    -- Cancel tweens
    for _, tween in ipairs(GUI.Tweens) do
        pcall(function() tween:Cancel() end)
    end
    
    -- Disconnect connections
    for _, connection in ipairs(GUI.Connections) do
        pcall(function() connection:Disconnect() end)
    end
    
    -- Destroy GUI
    if GUI.ScreenGui then
        GUI.ScreenGui:Destroy()
    end
    
    print("[CLEANUP] Complete")
end

-- ============================================
-- MAIN EXECUTION
-- ============================================
repeat task.wait() until game:IsLoaded()
repeat task.wait() until Players.LocalPlayer

print("🚀 Initializing Skibidi Farm v3.0...")

-- Step 1: Authenticate
print("🔐 Starting key authentication...")
if not KeySystem:CreateGUI() then
    Players.LocalPlayer:Kick("Authentication failed")
    return
end

print("✅ Authenticated successfully!")

-- Step 2: Initialize audio
InitAudio()

-- Step 3: Create main GUI
print("🎨 Creating main interface...")
local GUIElements = CreateMainGUI()

-- Step 4: Start your farm logic here
print("🌾 Farm logic ready!")
print("✨ Skibidi Farm v3.0 loaded successfully!")

-- Update GUI example
task.spawn(function()
    local startTime = tick()
    while task.wait(1) do
        local elapsed = tick() - startTime
        local hours = math.floor(elapsed / 3600)
        local minutes = math.floor((elapsed % 3600) / 60)
        local seconds = math.floor(elapsed % 60)
        
        GUIElements.TimeLabel.Text = string.format("%02d:%02d:%02d", hours, minutes, seconds)
        GUIElements.StatusLabel.Text = "Running"
    end
end)

-- Cleanup on shutdown
game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child == GUI.ScreenGui then
        Cleanup()
    end
end)
