-- ============================================
-- HOHO'S BOUNTY REMAKE v10.0 - CUSTOM GUI
-- Integrated with New Script Functions
-- By Ryu and Caucker - January 2026
-- ============================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local GUI = {}
GUI.SkibidiGui = nil
GUI.MainFrame = nil
GUI.Connections = {}
GUI.Tasks = {}
GUI.RunningTweens = {}
GUI.IsMinimized = false
GUI.IsPaused = false
GUI.IsMobile = false
GUI.IsTablet = false
GUI.ScreenSize = Vector2.new(0, 0)

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
    MainGUI = 10000,
    Controls = 10100,
    ServerChange = 25000
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
        
    elseif iconType == "kills" then
        local crosshair = Instance.new("Frame")
        crosshair.Size = UDim2.new(0.15, 0, 0.7, 0)
        crosshair.Position = UDim2.new(0.425, 0, 0.15, 0)
        crosshair.BackgroundColor3 = color
        crosshair.Parent = canvas
        
        local crosshairCorner = Instance.new("UICorner")
        crosshairCorner.CornerRadius = UDim.new(1, 0)
        crosshairCorner.Parent = crosshair
        
        local crosshair2 = Instance.new("Frame")
        crosshair2.Size = UDim2.new(0.7, 0, 0.15, 0)
        crosshair2.Position = UDim2.new(0.15, 0, 0.425, 0)
        crosshair2.BackgroundColor3 = color
        crosshair2.Parent = canvas
        
        local crosshair2Corner = Instance.new("UICorner")
        crosshair2Corner.CornerRadius = UDim.new(1, 0)
        crosshair2Corner.Parent = crosshair2
    end
    
    return frame
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
    GUI.AddTask(task.spawn(function()
        while TextLabel and TextLabel.Parent and Gradient and Gradient.Parent do
            Tween(Gradient, {Offset = Vector2.new(1, 0)}, 3, Enum.EasingStyle.Linear)
            task.wait(3)
            if not Gradient or not Gradient.Parent then break end
            Gradient.Offset = Vector2.new(-1, 0)
        end
    end))
    
    return TextLabel
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
    
    local mainWidth, mainHeight
    
    if GUI.IsMobile then
        mainWidth = math.min(GUI.ScreenSize.X * 0.95, 360)
        mainHeight = math.min(GUI.ScreenSize.Y * 0.7, 520)
    elseif GUI.IsTablet then
        mainWidth = math.min(GUI.ScreenSize.X * 0.85, 650)
        mainHeight = math.min(GUI.ScreenSize.Y * 0.65, 460)
    else
        mainWidth = 500
        mainHeight = 560
    end
    
    local cornerRadius = GetResponsiveValue(14, 12, 13)
    local controlBarHeight = GetResponsiveValue(38, 34, 36)
    
    GUI.MainFrame = Instance.new("Frame")
    GUI.MainFrame.Name = "MainFrame"
    GUI.MainFrame.BackgroundColor3 = GUI.Colors.Background
    GUI.MainFrame.BackgroundTransparency = 0.1
    GUI.MainFrame.Position = UDim2.new(0.5, -mainWidth/2, 0.1, 0)
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
    
    -- Animated border glow
    GUI.AddTask(task.spawn(function()
        while MainStroke and MainStroke.Parent do
            Tween(MainStroke, {Color = GUI.Colors.PrimaryGlow}, 2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(2)
            if not MainStroke or not MainStroke.Parent then break end
            Tween(MainStroke, {Color = GUI.Colors.Primary}, 2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(2)
        end
    end))
    
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
            if GUIVars.StateValue then
                GUIVars.StateValue.Text = "PAUSED"
                GUIVars.StateValue.TextColor3 = GUI.Colors.Warning
            end
        else
            if GUIVars.StateValue then
                GUIVars.StateValue.TextColor3 = GUI.Colors.Success
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
    local TitleLabel = CreateAnimatedGradientText(
        ControlsBar,
        "HOHO'S BOUNTY v10.0",
        UDim2.new(1, -220, 1, 0),
        UDim2.new(0, buttonStartX + (3 * buttonSpacing) + 8, 0, 0),
        titleSize,
        GUI.ZLayers.Controls + 1
    )
    TitleLabel.TextYAlignment = Enum.TextYAlignment.Center
    
    local ContentPanel = Instance.new("Frame")
    ContentPanel.Name = "ContentPanel"
    ContentPanel.Size = UDim2.new(1, 0, 1, -controlBarHeight)
    ContentPanel.Position = UDim2.new(0, 0, 0, controlBarHeight)
    ContentPanel.BackgroundColor3 = GUI.Colors.Surface
    ContentPanel.BackgroundTransparency = 0.2
    ContentPanel.BorderSizePixel = 0
    ContentPanel.ClipsDescendants = true
    ContentPanel.ZIndex = GUI.ZLayers.MainGUI
    ContentPanel.Parent = GUI.MainFrame
    
    local headerHeight = GetResponsiveValue(60, 50, 55)
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, headerHeight)
    Header.BackgroundTransparency = 1
    Header.ZIndex = GUI.ZLayers.MainGUI + 1
    Header.Parent = ContentPanel
    
    local headerTitleSize = GetResponsiveValue(18, 14, 16)
    local headerPadding = GetResponsiveValue(20, 14, 17)
    
    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Text = "AUTO FARM STATUS"
    HeaderTitle.Size = UDim2.new(1, -headerPadding * 2, 0, headerTitleSize + 10)
    HeaderTitle.Position = UDim2.new(0, headerPadding, 0, 12)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Font = Enum.Font.GothamBold
    HeaderTitle.TextColor3 = GUI.Colors.Text
    HeaderTitle.TextSize = headerTitleSize
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeaderTitle.ZIndex = GUI.ZLayers.MainGUI + 2
    HeaderTitle.Parent = Header
    
    local subtitleSize = GetResponsiveValue(10, 8, 9)
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Text = "Real-time farming statistics"
    Subtitle.Size = UDim2.new(1, -headerPadding * 2, 0, subtitleSize + 6)
    Subtitle.Position = UDim2.new(0, headerPadding, 0, headerTitleSize + 24)
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
    
    GUIVars.TargetValue = CreateStatCard("CURRENT TARGET", "Searching...", "target", 1)
    GUIVars.StateValue = CreateStatCard("STATUS", "Initializing", "status", 2)
    GUIVars.BountyValue = CreateStatCard("BOUNTY GAIN", "+0", "bounty", 3)
    GUIVars.TimeValue = CreateStatCard("SESSION TIME", "0:00", "time", 4)
    GUIVars.KillsValue = CreateStatCard("KILLS", "0", "kills", 5)
    
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
    
    local Logger = {}
    
    function Logger:Log(m)
        if GUIVars.StateValue and GUIVars.StateValue.Parent then
            GUIVars.StateValue.Text = tostring(m)
        end
    end
    
    function Logger:Info(m) self:Log(m) end
    function Logger:Success(m) 
        self:Log(m)
        if GUIVars.StateValue and GUIVars.StateValue.Parent then
            GUIVars.StateValue.TextColor3 = GUI.Colors.Success
        end
    end
    function Logger:Warning(m) 
        self:Log(m)
        if GUIVars.StateValue and GUIVars.StateValue.Parent then
            GUIVars.StateValue.TextColor3 = GUI.Colors.Warning
        end
    end
    function Logger:Error(m) 
        self:Log(m)
        if GUIVars.StateValue and GUIVars.StateValue.Parent then
            GUIVars.StateValue.TextColor3 = GUI.Colors.Error
        end
    end
    
    function Logger:Target(m)
        if GUIVars.TargetValue and GUIVars.TargetValue.Parent then
            GUIVars.TargetValue.Text = tostring(m)
        end
    end
    
    print("✅ Custom GUI v10.0 loaded!")
    print("🎨 Premium interface initialized")
    print("📊 Live stats tracking enabled")
    
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
    Screen.ZIndex = GUI.ZLayers.ServerChange
    Screen.Parent = GUI.SkibidiGui
    
    local Overlay = Instance.new("Frame")
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3 = GUI.Colors.Overlay
    Overlay.BackgroundTransparency = 0.3
    Overlay.BorderSizePixel = 0
    Overlay.ZIndex = GUI.ZLayers.ServerChange + 2
    Overlay.Parent = Screen
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, GUI.Colors.Primary),
        ColorSequenceKeypoint.new(0.5, GUI.Colors.Accent1),
        ColorSequenceKeypoint.new(1, GUI.Colors.Accent3)
    }
    gradient.Rotation = 45
    gradient.Parent = Overlay
    
    local containerWidth = GetResponsiveValue(600, 340, 450)
    local containerHeight = GetResponsiveValue(200, 160, 180)
    
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0, containerWidth, 0, containerHeight)
    Container.Position = UDim2.new(0.5, -containerWidth/2, 0.5, -containerHeight/2)
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
    Title.TextXAlignment = Enum.TextXAlignment.Center
    
    local subtitleSize = GetResponsiveValue(20, 14, 17)
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Text = "Finding optimal server..."
    Subtitle.Size = UDim2.new(1, 0, 0, subtitleSize + 12)
    Subtitle.Position = UDim2.new(0, 0, 0, titleSize + 32)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextSize = subtitleSize
    Subtitle.TextColor3 = GUI.Colors.Primary
    Subtitle.TextXAlignment = Enum.TextXAlignment.Center
    Subtitle.ZIndex = GUI.ZLayers.ServerChange + 4
    Subtitle.Parent = Container
    
    local progressY = titleSize + 76
    local ProgressBg = Instance.new("Frame")
    ProgressBg.Size = UDim2.new(0.8, 0, 0, 6)
    ProgressBg.Position = UDim2.new(0.1, 0, 0, progressY)
    ProgressBg.BackgroundColor3 = GUI.Colors.Surface
    ProgressBg.BorderSizePixel = 0
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
    
    Tween(Progress, {Size = UDim2.new(1, 0, 1, 0)}, 3.5, Enum.EasingStyle.Linear)
    
    print("🌐 Server change screen displayed")
end

-- ============================================
-- CLEANUP
-- ============================================

function GUI.Cleanup()
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
    
    if GUI.SkibidiGui then
        pcall(function() GUI.SkibidiGui:Destroy() end)
        GUI.SkibidiGui = nil
    end
    
    GUI.MainFrame = nil
    
    print("🧹 GUI cleaned up")
end

getgenv().HohosBountyRemake_v10_0 = GUI

return GUI
