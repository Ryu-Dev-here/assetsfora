local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")

local GUI = {}
GUI.Config = {}
GUI.AccentColor = Color3.fromRGB(138, 43, 226)
GUI.SkibidiGui = nil
GUI.MainFrame = nil
GUI.ToastContainer = nil
GUI.MusicSound = nil
GUI.Blur = nil
GUI.BackgroundImage = nil

local CONFIG_FILE = "SkibidiConfig.json"
local SCRIPT_FOLDER = "c:/Users/Admin/Documents/script"
local MUSIC_FILE = SCRIPT_FOLDER .. "/sound.mp3"
local BG_FILE = SCRIPT_FOLDER .. "/backlua.png"

local DefaultConfig = {
    AutoFarmEnabled = true,
    InstaTeleportEnabled = false,
    AntiRagdollEnabled = false,
    FruitAttackEnabled = false,
    FARM_DURATION = 30,
    FruitAttackRange = 600,
    PREDICTION_TIME = 0.00,
    YOffset = 0,
    SELECTED_FRUIT = "Dragon",
    ToggleKeybind = "RightShift",
    MusicEnabled = true,
    MusicVolume = 0.5,
    AccentR = 138,
    AccentG = 43,
    AccentB = 226
}

function GUI.SaveConfig()
    pcall(function()
        writefile(CONFIG_FILE, HttpService:JSONEncode(GUI.Config))
    end)
end

function GUI.LoadConfig()
    for k, v in pairs(DefaultConfig) do GUI.Config[k] = v end
    pcall(function()
        if isfile and isfile(CONFIG_FILE) then
            local data = readfile(CONFIG_FILE)
            local loaded = HttpService:JSONDecode(data)
            for k, v in pairs(loaded) do
                if DefaultConfig[k] ~= nil then GUI.Config[k] = v end
            end
        end
    end)
    GUI.AccentColor = Color3.fromRGB(GUI.Config.AccentR, GUI.Config.AccentG, GUI.Config.AccentB)
end

function GUI.ShowToast(msg, ttype)
    if not GUI.ToastContainer then return end
    local colors = {
        Info = Color3.fromRGB(59, 130, 246),
        Success = Color3.fromRGB(34, 197, 94),
        Warning = Color3.fromRGB(251, 191, 36),
        Error = Color3.fromRGB(239, 68, 68),
        Combat = Color3.fromRGB(249, 115, 22),
        Target = GUI.AccentColor,
        Teleport = Color3.fromRGB(139, 92, 246),
        Farm = Color3.fromRGB(16, 185, 129)
    }
    local col = colors[ttype] or GUI.AccentColor
    local toast = Instance.new("Frame")
    toast.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    toast.BackgroundTransparency = 0.1
    toast.Size = UDim2.new(1, 0, 0, 56)
    toast.Position = UDim2.new(1, 10, 0, 0)
    toast.Parent = GUI.ToastContainer
    toast.ZIndex = 100
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = toast
    local stroke = Instance.new("UIStroke")
    stroke.Color = col
    stroke.Transparency = 0.3
    stroke.Thickness = 2
    stroke.Parent = toast
    local glow = Instance.new("ImageLabel")
    glow.BackgroundTransparency = 1
    glow.Position = UDim2.new(0, -15, 0, -15)
    glow.Size = UDim2.new(1, 30, 1, 30)
    glow.Image = "rbxassetid://5028857084"
    glow.ImageColor3 = col
    glow.ImageTransparency = 0.7
    glow.ZIndex = 99
    glow.Parent = toast
    local accent = Instance.new("Frame")
    accent.BackgroundColor3 = col
    accent.Size = UDim2.new(0, 5, 1, -12)
    accent.Position = UDim2.new(0, 6, 0, 6)
    accent.ZIndex = 101
    accent.Parent = toast
    local acorner = Instance.new("UICorner")
    acorner.CornerRadius = UDim.new(0, 3)
    acorner.Parent = accent
    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, 20, 0, 0)
    lbl.Size = UDim2.new(1, -28, 1, 0)
    lbl.Font = Enum.Font.GothamMedium
    lbl.Text = msg
    lbl.TextColor3 = Color3.fromRGB(240, 240, 250)
    lbl.TextSize = 13
    lbl.TextWrapped = true
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 101
    lbl.Parent = toast
    TweenService:Create(toast, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    TweenService:Create(glow, TweenInfo.new(0.4), {ImageTransparency = 0.85}):Play()
    task.delay(5, function()
        TweenService:Create(toast, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(1, 10, 0, 0), BackgroundTransparency = 1}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.4), {Transparency = 1}):Play()
        TweenService:Create(glow, TweenInfo.new(0.4), {ImageTransparency = 1}):Play()
        task.wait(0.45)
        toast:Destroy()
    end)
end

function GUI.CreateLogger()
    local Logger = {}
    function Logger:Log(category, message) GUI.ShowToast(message, category) end
    function Logger:Info(msg) self:Log("Info", msg) end
    function Logger:Success(msg) self:Log("Success", msg) end
    function Logger:Warning(msg) self:Log("Warning", msg) end
    function Logger:Error(msg) self:Log("Error", msg) end
    function Logger:Combat(msg) self:Log("Combat", msg) end
    function Logger:Target(msg) self:Log("Target", msg) end
    function Logger:Teleport(msg) self:Log("Teleport", msg) end
    function Logger:Farm(msg) self:Log("Farm", msg) end
    return Logger
end

function GUI.InitAssets(progressCallback)
    GUI.MusicSound = Instance.new("Sound")
    GUI.MusicSound.Name = "SkibidiMusic"
    GUI.MusicSound.Looped = true
    GUI.MusicSound.Volume = GUI.Config.MusicVolume
    GUI.MusicSound.Parent = SoundService
    
    -- URLs for assets from GitHub
    local MUSIC_URL = "https://raw.githubusercontent.com/Ryu-Dev-here/assetsfora/main/sound.mp3"
    local BG_URL = "https://raw.githubusercontent.com/Ryu-Dev-here/assetsfora/main/backlua.png"
    
    task.spawn(function()
        pcall(function()
            if progressCallback then progressCallback("Downloading music...", 0.3) end
            
            -- Try to download music from URL if not already cached
            if not isfile(MUSIC_FILE) then
                local success, musicData = pcall(function()
                    return game:HttpGet(MUSIC_URL)
                end)
                if success and musicData then
                    writefile(MUSIC_FILE, musicData)
                    if progressCallback then progressCallback("Music downloaded", 0.4) end
                else
                    if progressCallback then progressCallback("Failed to download music", 0.4) end
                    return
                end
            end
            
            local asset = getcustomasset or getsynasset
            if asset and isfile(MUSIC_FILE) then
                GUI.MusicSound.SoundId = asset(MUSIC_FILE)
                if progressCallback then progressCallback("Music loaded", 0.5) end
                if GUI.Config.MusicEnabled then 
                    task.wait(0.2)
                    GUI.MusicSound:Play() 
                end
            else
                if progressCallback then progressCallback("Music file not found", 0.5) end
            end
        end)
    end)
    
    task.spawn(function()
        pcall(function()
            if progressCallback then progressCallback("Downloading background...", 0.6) end
            
            -- Try to download background from URL if not already cached
            if not isfile(BG_FILE) then
                local success, bgData = pcall(function()
                    return game:HttpGet(BG_URL)
                end)
                if success and bgData then
                    writefile(BG_FILE, bgData)
                    if progressCallback then progressCallback("Background downloaded", 0.7) end
                else
                    if progressCallback then progressCallback("Failed to download background", 0.7) end
                    return
                end
            end
            
            local asset = getcustomasset or getsynasset
            if asset and isfile(BG_FILE) and GUI.BackgroundImage then
                GUI.BackgroundImage.Image = asset(BG_FILE)
                if progressCallback then progressCallback("Background loaded", 0.8) end
            else
                if progressCallback then progressCallback("Background file not found", 0.8) end
            end
        end)
    end)
end

function GUI.CreateToggle(parent, label, default, callback)
    local Row = Instance.new("Frame")
    Row.BackgroundTransparency = 1
    Row.Size = UDim2.new(1, 0, 0, 32)
    Row.Parent = parent
    local Lbl = Instance.new("TextLabel")
    Lbl.BackgroundTransparency = 1
    Lbl.Size = UDim2.new(0.65, 0, 1, 0)
    Lbl.Font = Enum.Font.GothamMedium
    Lbl.Text = label
    Lbl.TextColor3 = Color3.fromRGB(210, 210, 220)
    Lbl.TextSize = 13
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Row
    local ToggleBG = Instance.new("Frame")
    ToggleBG.BackgroundColor3 = default and GUI.AccentColor or Color3.fromRGB(45, 45, 60)
    ToggleBG.Position = UDim2.new(1, -50, 0.5, -12)
    ToggleBG.Size = UDim2.new(0, 50, 0, 24)
    ToggleBG.Parent = Row
    local TCorner = Instance.new("UICorner")
    TCorner.CornerRadius = UDim.new(1, 0)
    TCorner.Parent = ToggleBG
    local TStroke = Instance.new("UIStroke")
    TStroke.Color = default and GUI.AccentColor or Color3.fromRGB(60, 60, 75)
    TStroke.Transparency = 0.5
    TStroke.Thickness = 1.5
    TStroke.Parent = ToggleBG
    local Circle = Instance.new("Frame")
    Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Circle.Position = default and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    Circle.Size = UDim2.new(0, 20, 0, 20)
    Circle.Parent = ToggleBG
    local CCorner = Instance.new("UICorner")
    CCorner.CornerRadius = UDim.new(1, 0)
    CCorner.Parent = Circle
    local CShadow = Instance.new("ImageLabel")
    CShadow.BackgroundTransparency = 1
    CShadow.Position = UDim2.new(0, -4, 0, -4)
    CShadow.Size = UDim2.new(1, 8, 1, 8)
    CShadow.Image = "rbxassetid://5028857084"
    CShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    CShadow.ImageTransparency = 0.7
    CShadow.Parent = Circle
    local enabled = default
    local Btn = Instance.new("TextButton")
    Btn.BackgroundTransparency = 1
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.Text = ""
    Btn.Parent = ToggleBG
    Btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        TweenService:Create(ToggleBG, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {BackgroundColor3 = enabled and GUI.AccentColor or Color3.fromRGB(45, 45, 60)}):Play()
        TweenService:Create(TStroke, TweenInfo.new(0.25), {Color = enabled and GUI.AccentColor or Color3.fromRGB(60, 60, 75)}):Play()
        TweenService:Create(Circle, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Position = enabled and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)}):Play()
        callback(enabled)
    end)
    Btn.MouseEnter:Connect(function()
        TweenService:Create(ToggleBG, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
    end)
    Btn.MouseLeave:Connect(function()
        TweenService:Create(ToggleBG, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
    end)
end

function GUI.CreateSlider(parent, label, min, max, default, callback)
    local Row = Instance.new("Frame")
    Row.BackgroundTransparency = 1
    Row.Size = UDim2.new(1, 0, 0, 48)
    Row.Parent = parent
    local Lbl = Instance.new("TextLabel")
    Lbl.BackgroundTransparency = 1
    Lbl.Size = UDim2.new(0.55, 0, 0, 20)
    Lbl.Font = Enum.Font.GothamMedium
    Lbl.Text = label
    Lbl.TextColor3 = Color3.fromRGB(210, 210, 220)
    Lbl.TextSize = 13
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Row
    local ValLbl = Instance.new("TextLabel")
    ValLbl.BackgroundTransparency = 1
    ValLbl.Position = UDim2.new(0.55, 0, 0, 0)
    ValLbl.Size = UDim2.new(0.45, 0, 0, 20)
    ValLbl.Font = Enum.Font.GothamBold
    ValLbl.Text = tostring(default)
    ValLbl.TextColor3 = GUI.AccentColor
    ValLbl.TextSize = 14
    ValLbl.TextXAlignment = Enum.TextXAlignment.Right
    ValLbl.Parent = Row
    local Track = Instance.new("Frame")
    Track.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
    Track.Position = UDim2.new(0, 0, 0, 28)
    Track.Size = UDim2.new(1, 0, 0, 10)
    Track.Parent = Row
    local TCorner = Instance.new("UICorner")
    TCorner.CornerRadius = UDim.new(1, 0)
    TCorner.Parent = Track
    local TStroke = Instance.new("UIStroke")
    TStroke.Color = Color3.fromRGB(50, 50, 65)
    TStroke.Transparency = 0.5
    TStroke.Thickness = 1
    TStroke.Parent = Track
    local Fill = Instance.new("Frame")
    Fill.BackgroundColor3 = GUI.AccentColor
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.Parent = Track
    local FCorner = Instance.new("UICorner")
    FCorner.CornerRadius = UDim.new(1, 0)
    FCorner.Parent = Fill
    local FGradient = Instance.new("UIGradient")
    FGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, GUI.AccentColor), ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 120, 255))}
    FGradient.Parent = Fill
    local Knob = Instance.new("Frame")
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.Position = UDim2.new((default - min) / (max - min), -10, 0.5, -10)
    Knob.Size = UDim2.new(0, 20, 0, 20)
    Knob.Parent = Track
    local KCorner = Instance.new("UICorner")
    KCorner.CornerRadius = UDim.new(1, 0)
    KCorner.Parent = Knob
    local KStroke = Instance.new("UIStroke")
    KStroke.Color = GUI.AccentColor
    KStroke.Thickness = 2
    KStroke.Transparency = 0.3
    KStroke.Parent = Knob
    local KShadow = Instance.new("ImageLabel")
    KShadow.BackgroundTransparency = 1
    KShadow.Position = UDim2.new(0, -6, 0, -6)
    KShadow.Size = UDim2.new(1, 12, 1, 12)
    KShadow.Image = "rbxassetid://5028857084"
    KShadow.ImageColor3 = GUI.AccentColor
    KShadow.ImageTransparency = 0.6
    KShadow.Parent = Knob
    local dragging = false
    local function update(input)
        local rel = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + rel * (max - min))
        Fill.Size = UDim2.new(rel, 0, 1, 0)
        Knob.Position = UDim2.new(rel, -10, 0.5, -10)
        ValLbl.Text = tostring(val)
        callback(val)
    end
    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
            TweenService:Create(Knob, TweenInfo.new(0.1), {Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new((Fill.Size.X.Scale), -12, 0.5, -12)}):Play()
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                TweenService:Create(Knob, TweenInfo.new(0.2), {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new((Fill.Size.X.Scale), -10, 0.5, -10)}):Play()
            end
        end
    end)
end

function GUI.CreateDropdown(parent, label, options, default, callback)
    local Row = Instance.new("Frame")
    Row.BackgroundTransparency = 1
    Row.Size = UDim2.new(1, 0, 0, 32)
    Row.ClipsDescendants = false
    Row.Parent = parent
    local Lbl = Instance.new("TextLabel")
    Lbl.BackgroundTransparency = 1
    Lbl.Size = UDim2.new(0.35, 0, 1, 0)
    Lbl.Font = Enum.Font.GothamMedium
    Lbl.Text = label
    Lbl.TextColor3 = Color3.fromRGB(210, 210, 220)
    Lbl.TextSize = 13
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Row
    local DropBtn = Instance.new("TextButton")
    DropBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    DropBtn.Position = UDim2.new(0.35, 0, 0, 0)
    DropBtn.Size = UDim2.new(0.65, 0, 1, 0)
    DropBtn.Font = Enum.Font.GothamMedium
    DropBtn.Text = "  " .. default .. " ▼"
    DropBtn.TextColor3 = Color3.fromRGB(230, 230, 240)
    DropBtn.TextSize = 13
    DropBtn.TextXAlignment = Enum.TextXAlignment.Left
    DropBtn.Parent = Row
    local DCorner = Instance.new("UICorner")
    DCorner.CornerRadius = UDim.new(0, 8)
    DCorner.Parent = DropBtn
    local DStroke = Instance.new("UIStroke")
    DStroke.Color = Color3.fromRGB(50, 50, 65)
    DStroke.Transparency = 0.5
    DStroke.Thickness = 1.5
    DStroke.Parent = DropBtn
    local List = Instance.new("ScrollingFrame")
    List.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
    List.Position = UDim2.new(0.35, 0, 1, 6)
    List.Size = UDim2.new(0.65, 0, 0, math.min(#options * 30 + 10, 200))
    List.Visible = false
    List.ZIndex = 150
    List.BorderSizePixel = 0
    List.ScrollBarThickness = 4
    List.ScrollBarImageColor3 = GUI.AccentColor
    List.CanvasSize = UDim2.new(0, 0, 0, #options * 30 + 10)
    List.Parent = Row
    local LCorner = Instance.new("UICorner")
    LCorner.CornerRadius = UDim.new(0, 8)
    LCorner.Parent = List
    local LStroke = Instance.new("UIStroke")
    LStroke.Color = GUI.AccentColor
    LStroke.Transparency = 0.4
    LStroke.Thickness = 2
    LStroke.Parent = List
    local LShadow = Instance.new("ImageLabel")
    LShadow.BackgroundTransparency = 1
    LShadow.Position = UDim2.new(0, -15, 0, -15)
    LShadow.Size = UDim2.new(1, 30, 1, 30)
    LShadow.Image = "rbxassetid://5028857084"
    LShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    LShadow.ImageTransparency = 0.5
    LShadow.ZIndex = 149
    LShadow.Parent = List
    local LLayout = Instance.new("UIListLayout")
    LLayout.Padding = UDim.new(0, 3)
    LLayout.SortOrder = Enum.SortOrder.LayoutOrder
    LLayout.Parent = List
    local LPad = Instance.new("UIPadding")
    LPad.PaddingTop = UDim.new(0, 5)
    LPad.PaddingLeft = UDim.new(0, 5)
    LPad.PaddingRight = UDim.new(0, 5)
    LPad.PaddingBottom = UDim.new(0, 5)
    LPad.Parent = List
    for _, opt in ipairs(options) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
        OptBtn.BackgroundTransparency = 0.3
        OptBtn.Size = UDim2.new(1, 0, 0, 28)
        OptBtn.Font = Enum.Font.GothamMedium
        OptBtn.Text = opt
        OptBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
        OptBtn.TextSize = 12
        OptBtn.ZIndex = 151
        OptBtn.Parent = List
        local OCorner = Instance.new("UICorner")
        OCorner.CornerRadius = UDim.new(0, 6)
        OCorner.Parent = OptBtn
        OptBtn.MouseEnter:Connect(function()
            TweenService:Create(OptBtn, TweenInfo.new(0.15), {BackgroundColor3 = GUI.AccentColor, BackgroundTransparency = 0}):Play()
        end)
        OptBtn.MouseLeave:Connect(function()
            TweenService:Create(OptBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 35, 48), BackgroundTransparency = 0.3}):Play()
        end)
        OptBtn.MouseButton1Click:Connect(function()
            DropBtn.Text = "  " .. opt .. " ▼"
            TweenService:Create(List, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {Size = UDim2.new(0.65, 0, 0, 0)}):Play()
            task.wait(0.2)
            List.Visible = false
            callback(opt)
        end)
    end
    DropBtn.MouseButton1Click:Connect(function()
        List.Visible = not List.Visible
        if List.Visible then
            List.Size = UDim2.new(0.65, 0, 0, 0)
            TweenService:Create(List, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Size = UDim2.new(0.65, 0, 0, math.min(#options * 30 + 10, 200))}):Play()
        else
            TweenService:Create(List, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {Size = UDim2.new(0.65, 0, 0, 0)}):Play()
        end
    end)
    DropBtn.MouseEnter:Connect(function()
        TweenService:Create(DStroke, TweenInfo.new(0.15), {Color = GUI.AccentColor, Transparency = 0.3}):Play()
    end)
    DropBtn.MouseLeave:Connect(function()
        TweenService:Create(DStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(50, 50, 65), Transparency = 0.5}):Play()
    end)
end

function GUI.CreateInfoLine(parent, label, value)
    local Line = Instance.new("Frame")
    Line.BackgroundTransparency = 1
    Line.Size = UDim2.new(1, 0, 0, 28)
    Line.Parent = parent
    local Lbl = Instance.new("TextLabel")
    Lbl.BackgroundTransparency = 1
    Lbl.Size = UDim2.new(0.5, 0, 1, 0)
    Lbl.Font = Enum.Font.GothamMedium
    Lbl.Text = label
    Lbl.TextColor3 = Color3.fromRGB(170, 170, 185)
    Lbl.TextSize = 12
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Line
    local Val = Instance.new("TextLabel")
    Val.Name = "Value"
    Val.BackgroundTransparency = 1
    Val.Position = UDim2.new(0.5, 0, 0, 0)
    Val.Size = UDim2.new(0.5, 0, 1, 0)
    Val.Font = Enum.Font.GothamBold
    Val.Text = value
    Val.TextColor3 = GUI.AccentColor
    Val.TextSize = 13
    Val.TextXAlignment = Enum.TextXAlignment.Right
    Val.Parent = Line
    return Val
end

function GUI.CreateSection(parent, title)
    local Section = Instance.new("Frame")
    Section.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    Section.BackgroundTransparency = 0.1
    Section.BorderSizePixel = 0
    Section.Size = UDim2.new(1, 0, 0, 0)
    Section.AutomaticSize = Enum.AutomaticSize.Y
    Section.Parent = parent
    local SCorner = Instance.new("UICorner")
    SCorner.CornerRadius = UDim.new(0, 12)
    SCorner.Parent = Section
    local SStroke = Instance.new("UIStroke")
    SStroke.Color = Color3.fromRGB(40, 40, 55)
    SStroke.Thickness = 1.5
    SStroke.Transparency = 0.4
    SStroke.Parent = Section
    local SGradient = Instance.new("UIGradient")
    SGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 18, 26)), ColorSequenceKeypoint.new(1, Color3.fromRGB(22, 22, 30))}
    SGradient.Rotation = 90
    SGradient.Parent = Section
    local STitle = Instance.new("TextLabel")
    STitle.BackgroundTransparency = 1
    STitle.Position = UDim2.new(0, 16, 0, 12)
    STitle.Size = UDim2.new(1, -32, 0, 20)
    STitle.Font = Enum.Font.GothamBlack
    STitle.Text = title
    STitle.TextColor3 = GUI.AccentColor
    STitle.TextSize = 14
    STitle.TextXAlignment = Enum.TextXAlignment.Left
    STitle.Parent = Section
    local STitleGradient = Instance.new("UIGradient")
    STitleGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, GUI.AccentColor), ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 120, 255))}
    STitleGradient.Parent = STitle
    local SContent = Instance.new("Frame")
    SContent.BackgroundTransparency = 1
    SContent.Position = UDim2.new(0, 16, 0, 40)
    SContent.Size = UDim2.new(1, -32, 0, 0)
    SContent.AutomaticSize = Enum.AutomaticSize.Y
    SContent.Parent = Section
    local SLayout = Instance.new("UIListLayout")
    SLayout.Padding = UDim.new(0, 10)
    SLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SLayout.Parent = SContent
    local SPad = Instance.new("UIPadding")
    SPad.PaddingBottom = UDim.new(0, 14)
    SPad.Parent = Section
    return SContent
end

function GUI.Init(vars, callbacks)
    GUI.LoadConfig()
    
    local lp = Players.LocalPlayer
    
    GUI.SkibidiGui = Instance.new("ScreenGui")
    GUI.SkibidiGui.Name = "SkibidiGui"
    GUI.SkibidiGui.ResetOnSpawn = false
    GUI.SkibidiGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    GUI.SkibidiGui.IgnoreGuiInset = true
    pcall(function() GUI.SkibidiGui.Parent = CoreGui end)
    if not GUI.SkibidiGui.Parent then GUI.SkibidiGui.Parent = lp:WaitForChild("PlayerGui") end
    
    GUI.Blur = Instance.new("DepthOfFieldEffect")
    GUI.Blur.Name = "SkibidiBlur"
    GUI.Blur.FarIntensity = 0
    GUI.Blur.FocusDistance = 0.05
    GUI.Blur.InFocusRadius = 10
    GUI.Blur.NearIntensity = 0.6
    GUI.Blur.Parent = Lighting
    GUI.Blur.Enabled = true
    
    GUI.ToastContainer = Instance.new("Frame")
    GUI.ToastContainer.Name = "ToastContainer"
    GUI.ToastContainer.BackgroundTransparency = 1
    GUI.ToastContainer.Position = UDim2.new(1, -330, 0, 20)
    GUI.ToastContainer.Size = UDim2.new(0, 310, 1, -40)
    GUI.ToastContainer.ZIndex = 100
    GUI.ToastContainer.Parent = GUI.SkibidiGui
    
    local ToastLayout = Instance.new("UIListLayout")
    ToastLayout.Padding = UDim.new(0, 10)
    ToastLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ToastLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    ToastLayout.Parent = GUI.ToastContainer
    
    GUI.MainFrame = Instance.new("Frame")
    GUI.MainFrame.Name = "MainFrame"
    GUI.MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
    GUI.MainFrame.BackgroundTransparency = 0.05
    GUI.MainFrame.BorderSizePixel = 0
    GUI.MainFrame.Position = UDim2.new(0.02, 0, 0.12, 0)
    GUI.MainFrame.Size = UDim2.new(0, 420, 0, 580)
    GUI.MainFrame.Parent = GUI.SkibidiGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 16)
    MainCorner.Parent = GUI.MainFrame
    
    local MainShadow = Instance.new("ImageLabel")
    MainShadow.BackgroundTransparency = 1
    MainShadow.Position = UDim2.new(0, -20, 0, -20)
    MainShadow.Size = UDim2.new(1, 40, 1, 40)
    MainShadow.Image = "rbxassetid://5028857084"
    MainShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    MainShadow.ImageTransparency = 0.4
    MainShadow.ZIndex = -1
    MainShadow.Parent = GUI.MainFrame
    
    GUI.BackgroundImage = Instance.new("ImageLabel")
    GUI.BackgroundImage.BackgroundTransparency = 1
    GUI.BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
    GUI.BackgroundImage.Image = ""
    GUI.BackgroundImage.ImageTransparency = 0.85
    GUI.BackgroundImage.ScaleType = Enum.ScaleType.Crop
    GUI.BackgroundImage.ZIndex = 0
    GUI.BackgroundImage.Parent = GUI.MainFrame
    local BGCorner = Instance.new("UICorner")
    BGCorner.CornerRadius = UDim.new(0, 16)
    BGCorner.Parent = GUI.BackgroundImage
    
    local BorderStroke = Instance.new("UIStroke")
    BorderStroke.Color = GUI.AccentColor
    BorderStroke.Thickness = 2.5
    BorderStroke.Transparency = 0.2
    BorderStroke.Parent = GUI.MainFrame
    
    task.spawn(function()
        while GUI.MainFrame and GUI.MainFrame.Parent do
            for i = 0, 360, 1.5 do
                if not GUI.MainFrame or not GUI.MainFrame.Parent then break end
                BorderStroke.Color = Color3.fromHSV(i / 360, 0.75, 0.98)
                task.wait(0.02)
            end
        end
    end)
    
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.BackgroundColor3 = Color3.fromRGB(14, 14, 22)
    Header.BackgroundTransparency = 0.05
    Header.BorderSizePixel = 0
    Header.Size = UDim2.new(1, 0, 0, 70)
    Header.ZIndex = 2
    Header.Parent = GUI.MainFrame
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 16)
    HeaderCorner.Parent = Header
    local HeaderBottom = Instance.new("Frame")
    HeaderBottom.BackgroundColor3 = Color3.fromRGB(14, 14, 22)
    HeaderBottom.BackgroundTransparency = 0.05
    HeaderBottom.BorderSizePixel = 0
    HeaderBottom.Position = UDim2.new(0, 0, 0.6, 0)
    HeaderBottom.Size = UDim2.new(1, 0, 0.4, 0)
    HeaderBottom.ZIndex = 2
    HeaderBottom.Parent = Header
    local HeaderGradient = Instance.new("UIGradient")
    HeaderGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 14, 22)), ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 26))}
    HeaderGradient.Rotation = 90
    HeaderGradient.Parent = Header
    
    local Title = Instance.new("TextLabel")
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 20, 0, 14)
    Title.Size = UDim2.new(1, -40, 0, 28)
    Title.Font = Enum.Font.GothamBlack
    Title.Text = "SKIBIDI FARM"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 22
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 3
    Title.Parent = Header
    
    local TitleGradient = Instance.new("UIGradient")
    TitleGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, GUI.AccentColor), ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 140, 255))}
    TitleGradient.Parent = Title
    
    local Subtitle = Instance.new("TextLabel")
    Subtitle.BackgroundTransparency = 1
    Subtitle.Position = UDim2.new(0, 20, 0, 44)
    Subtitle.Size = UDim2.new(1, -40, 0, 18)
    Subtitle.Font = Enum.Font.GothamBold
    Subtitle.Text = "⚡ GOONERS EDITION • LEVEL 8 UNC"
    Subtitle.TextColor3 = Color3.fromRGB(130, 130, 145)
    Subtitle.TextSize = 11
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.ZIndex = 3
    Subtitle.Parent = Header
    
    local Content = Instance.new("ScrollingFrame")
    Content.BackgroundTransparency = 1
    Content.BorderSizePixel = 0
    Content.Position = UDim2.new(0, 14, 0, 82)
    Content.Size = UDim2.new(1, -28, 1, -96)
    Content.CanvasSize = UDim2.new(0, 0, 0, 0)
    Content.ScrollBarThickness = 5
    Content.ScrollBarImageColor3 = GUI.AccentColor
    Content.ZIndex = 2
    Content.Parent = GUI.MainFrame
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 12)
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Parent = Content
    
    ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Content.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 18)
    end)
    
    local StatsSection = GUI.CreateSection(Content, "TATISTICS")
    vars.BountyLabel = GUI.CreateInfoLine(StatsSection, "Bounty", "0")
    vars.GainedLabel = GUI.CreateInfoLine(StatsSection, "Session Gain", "+0")
    vars.KillsLabel = GUI.CreateInfoLine(StatsSection, "Kills", "0")
    vars.TimeLabel = GUI.CreateInfoLine(StatsSection, "Time", "00:00:00")
    
    local ToggleSection = GUI.CreateSection(Content, "TOGGLES")
    GUI.CreateToggle(ToggleSection, "Auto Farm", GUI.Config.AutoFarmEnabled, callbacks.OnAutoFarmToggle)
    GUI.CreateToggle(ToggleSection, "Insta Teleport", GUI.Config.InstaTeleportEnabled, callbacks.OnInstaTpToggle)
    GUI.CreateToggle(ToggleSection, "Anti Ragdoll", GUI.Config.AntiRagdollEnabled, callbacks.OnAntiRagdollToggle)
    GUI.CreateToggle(ToggleSection, "Fruit Attack", GUI.Config.FruitAttackEnabled, callbacks.OnFruitAttackToggle)
    
    local SliderSection = GUI.CreateSection(Content, "SLIDERS")
    GUI.CreateSlider(SliderSection, "Farm Duration", 10, 120, GUI.Config.FARM_DURATION, callbacks.OnFarmDurationChange)
    GUI.CreateSlider(SliderSection, "Attack Range", 100, 1500, GUI.Config.FruitAttackRange, callbacks.OnAttackRangeChange)
    GUI.CreateSlider(SliderSection, "Prediction", 0, 100, math.floor(GUI.Config.PREDICTION_TIME * 100), callbacks.OnPredictionChange)
    GUI.CreateSlider(SliderSection, "Y Offset", -50, 50, GUI.Config.YOffset, callbacks.OnYOffsetChange)
    
    local FruitSection = GUI.CreateSection(Content, "FRUIT SELECT")
    GUI.CreateDropdown(FruitSection, "Fruit", vars.FruitList, GUI.Config.SELECTED_FRUIT, callbacks.OnFruitChange)
    
    local StatusSection = GUI.CreateSection(Content, "STATUS")
    vars.TargetLabel = GUI.CreateInfoLine(StatusSection, "Target", "Searching...")
    vars.StateLabel = GUI.CreateInfoLine(StatusSection, "State", "Active")
    vars.FarmedLabel = GUI.CreateInfoLine(StatusSection, "Farmed", "0")
    
    local ThemeSection = GUI.CreateSection(Content, " THEME")
    GUI.CreateSlider(ThemeSection, "Red", 0, 255, GUI.Config.AccentR, callbacks.OnThemeRChange)
    GUI.CreateSlider(ThemeSection, "Green", 0, 255, GUI.Config.AccentG, callbacks.OnThemeGChange)
    GUI.CreateSlider(ThemeSection, "Blue", 0, 255, GUI.Config.AccentB, callbacks.OnThemeBChange)
    
    local MusicSection = GUI.CreateSection(Content, " MUSIC")
    GUI.CreateToggle(MusicSection, "Enable Music", GUI.Config.MusicEnabled, callbacks.OnMusicToggle)
    GUI.CreateSlider(MusicSection, "Volume", 0, 100, math.floor(GUI.Config.MusicVolume * 100), callbacks.OnVolumeChange)
    
    local dragging, dragInput, dragStart, startPos
    local function updateDrag(input)
        local delta = input.Position - dragStart
        GUI.MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = GUI.MainFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    Header.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
    UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then updateDrag(input) end end)
    
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode[GUI.Config.ToggleKeybind] then
            GUI.MainFrame.Visible = not GUI.MainFrame.Visible
            GUI.Blur.Enabled = GUI.MainFrame.Visible
        end
    end)
    
    return GUI.CreateLogger()
end

return GUI
