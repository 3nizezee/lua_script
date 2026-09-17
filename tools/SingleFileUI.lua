-- SimpleSpy single-file presentation layer.
-- This file is appended by tools/package.py and intentionally depends only on
-- the legacy runtime variables already defined by SpyV2Beta.lua.

do
    local UIS = game:GetService("UserInputService")
    local TweenServiceLocal = game:GetService("TweenService")

    if SimpleSpy3 then
        SimpleSpy3.Enabled = false
    end

    local Theme2 = {
        Background = Color3.fromRGB(10, 11, 14),
        Surface = Color3.fromRGB(16, 18, 23),
        Surface2 = Color3.fromRGB(21, 23, 29),
        Surface3 = Color3.fromRGB(27, 30, 37),
        Border = Color3.fromRGB(45, 49, 58),
        Accent = Color3.fromRGB(116, 92, 255),
        Success = Color3.fromRGB(66, 190, 120),
        Warning = Color3.fromRGB(230, 170, 70),
        Danger = Color3.fromRGB(224, 75, 91),
        Text = Color3.fromRGB(238, 240, 245),
        Muted = Color3.fromRGB(151, 157, 170),
        Dim = Color3.fromRGB(105, 111, 124),
        Code = Color3.fromRGB(11, 13, 17),
    }

    local gui = Instance.new("ScreenGui")
    gui.Name = "SimpleSpyModern"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = (gethui and gethui()) or CoreGui
    getgenv().SimpleSpyModernGui = gui

    local window = Instance.new("Frame")
    window.Name = "Window"
    window.AnchorPoint = Vector2.new(.5, .5)
    window.Position = UDim2.fromScale(.5, .5)
    window.Size = UDim2.fromOffset(980, 610)
    window.BackgroundColor3 = Theme2.Background
    window.BorderSizePixel = 0
    window.Parent = gui

    local function corner(parent, radius)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, radius or 8)
        c.Parent = parent
        return c
    end

    local function stroke(parent, color, transparency)
        local s = Instance.new("UIStroke")
        s.Color = color or Theme2.Border
        s.Transparency = transparency or 0
        s.Thickness = 1
        s.Parent = parent
        return s
    end

    corner(window, 8)
    stroke(window, Theme2.Border, .15)

    local topbar = Instance.new("Frame")
    topbar.Size = UDim2.new(1, 0, 0, 44)
    topbar.BackgroundColor3 = Theme2.Surface
    topbar.BorderSizePixel = 0
    topbar.Parent = window

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.fromOffset(16, 0)
    title.Size = UDim2.new(.5, 0, 1, 0)
    title.Font = Enum.Font.GothamBold
    title.Text = "SimpleSpy"
    title.TextColor3 = Theme2.Text
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = topbar

    local status = Instance.new("TextLabel")
    status.BackgroundTransparency = 1
    status.Position = UDim2.new(.5, 0, 0, 0)
    status.Size = UDim2.new(.5, -56, 1, 0)
    status.Font = Enum.Font.GothamMedium
    status.Text = "CAPTURE READY"
    status.TextColor3 = Theme2.Success
    status.TextSize = 11
    status.TextXAlignment = Enum.TextXAlignment.Right
    status.Parent = topbar

    local close = Instance.new("TextButton")
    close.AutoButtonColor = false
    close.BackgroundTransparency = 1
    close.Position = UDim2.new(1, -44, 0, 0)
    close.Size = UDim2.fromOffset(44, 44)
    close.Font = Enum.Font.GothamBold
    close.Text = "×"
    close.TextColor3 = Theme2.Muted
    close.TextSize = 20
    close.Parent = topbar

    local sidebar = Instance.new("Frame")
    sidebar.Position = UDim2.fromOffset(12, 56)
    sidebar.Size = UDim2.new(0, 250, 1, -68)
    sidebar.BackgroundColor3 = Theme2.Surface
    sidebar.BorderSizePixel = 0
    sidebar.Parent = window
    corner(sidebar, 6)
    stroke(sidebar, Theme2.Border, .35)

    local search = Instance.new("TextBox")
    search.ClearTextOnFocus = false
    search.PlaceholderText = "Search remotes..."
    search.PlaceholderColor3 = Theme2.Dim
    search.Text = ""
    search.TextColor3 = Theme2.Text
    search.TextSize = 12
    search.Font = Enum.Font.Gotham
    search.BackgroundColor3 = Theme2.Surface2
    search.BorderSizePixel = 0
    search.Position = UDim2.fromOffset(10, 10)
    search.Size = UDim2.new(1, -20, 0, 34)
    search.Parent = sidebar
    corner(search, 6)
    stroke(search, Theme2.Border, .45)

    local logList = Instance.new("ScrollingFrame")
    logList.Active = true
    logList.BackgroundTransparency = 1
    logList.BorderSizePixel = 0
    logList.Position = UDim2.fromOffset(10, 52)
    logList.Size = UDim2.new(1, -20, 1, -62)
    logList.ScrollBarThickness = 3
    logList.ScrollBarImageColor3 = Theme2.Accent
    logList.CanvasSize = UDim2.new()
    logList.Parent = sidebar
    local logLayout = Instance.new("UIListLayout")
    logLayout.Padding = UDim.new(0, 5)
    logLayout.SortOrder = Enum.SortOrder.LayoutOrder
    logLayout.Parent = logList

    local content = Instance.new("Frame")
    content.Position = UDim2.new(0, 274, 0, 56)
    content.Size = UDim2.new(1, -286, 1, -68)
    content.BackgroundColor3 = Theme2.Surface
    content.BorderSizePixel = 0
    content.Parent = window
    corner(content, 6)
    stroke(content, Theme2.Border, .35)

    local codeFrame = Instance.new("Frame")
    codeFrame.Position = UDim2.fromOffset(12, 42)
    codeFrame.Size = UDim2.new(1, -24, .57, -48)
    codeFrame.BackgroundColor3 = Theme2.Code
    codeFrame.BorderSizePixel = 0
    codeFrame.Parent = content
    corner(codeFrame, 6)
    stroke(codeFrame, Theme2.Border, .5)

    local codeTitle = Instance.new("TextLabel")
    codeTitle.BackgroundTransparency = 1
    codeTitle.Position = UDim2.fromOffset(12, 10)
    codeTitle.Size = UDim2.new(1, -24, 0, 28)
    codeTitle.Font = Enum.Font.GothamBold
    codeTitle.Text = "Generated Code"
    codeTitle.TextColor3 = Theme2.Text
    codeTitle.TextSize = 12
    codeTitle.TextXAlignment = Enum.TextXAlignment.Left
    codeTitle.Parent = content

    local actions = Instance.new("ScrollingFrame")
    actions.Active = true
    actions.BackgroundTransparency = 1
    actions.BorderSizePixel = 0
    actions.Position = UDim2.new(0, 12, .57, 4)
    actions.Size = UDim2.new(1, -24, .43, -16)
    actions.ScrollBarThickness = 3
    actions.ScrollBarImageColor3 = Theme2.Accent
    actions.CanvasSize = UDim2.new()
    actions.Parent = content
    local actionGrid = Instance.new("UIGridLayout")
    actionGrid.CellPadding = UDim2.fromOffset(7, 7)
    actionGrid.CellSize = UDim2.new(.25, -6, 0, 34)
    actionGrid.SortOrder = Enum.SortOrder.LayoutOrder
    actionGrid.Parent = actions

    codebox = Highlight.new(codeFrame)
    codebox:setRaw("")

    local function makeAction(text, callback)
        local button = Instance.new("TextButton")
        button.AutoButtonColor = false
        button.BackgroundColor3 = Theme2.Surface2
        button.BorderSizePixel = 0
        button.Font = Enum.Font.GothamMedium
        button.Text = text
        button.TextColor3 = Theme2.Text
        button.TextSize = 11
        button.Parent = actions
        corner(button, 6)
        local outline = stroke(button, Theme2.Border, .45)
        button.MouseEnter:Connect(function()
            TweenServiceLocal:Create(button, TweenInfo.new(.12), {BackgroundColor3 = Theme2.Surface3}):Play()
            TweenServiceLocal:Create(outline, TweenInfo.new(.12), {Transparency = 0}):Play()
        end)
        button.MouseLeave:Connect(function()
            TweenServiceLocal:Create(button, TweenInfo.new(.12), {BackgroundColor3 = Theme2.Surface2}):Play()
            TweenServiceLocal:Create(outline, TweenInfo.new(.12), {Transparency = .45}):Play()
        end)
        button.Activated:Connect(function()
            if callback then pcall(callback) end
        end)
        return button
    end

    local function setStatus(text, color)
        status.Text = text
        status.TextColor3 = color or Theme2.Success
    end

    local currentSelection = nil
    local rows = {}
    local lastCount = -1
    local lastFilter = "\0"

    local function matches(log, filter)
        if filter == "" then return true end
        filter = string.lower(filter)
        return string.find(string.lower(log.Name or ""), filter, 1, true) ~= nil
            or string.find(string.lower(log.metamethod or log.Function or ""), filter, 1, true) ~= nil
    end

    local function selectLog(log)
        currentSelection = log
        selected = log
        log.GenScript = genScript(log.Remote, log.args)
        if log.Blocked then
            log.GenScript = "-- THIS REMOTE WAS PREVENTED FROM FIRING TO THE SERVER\n\n" .. log.GenScript
        end
        codebox:setRaw(log.GenScript or "")
        setStatus((log.Name or "Remote") .. "  /  " .. tostring(log.metamethod or log.Function or "Unknown"), Theme2.Accent)
    end

    local function renderLogs()
        for _, row in pairs(rows) do row:Destroy() end
        table.clear(rows)
        local filter = search.Text or ""
        for _, log in ipairs(logs) do
            if matches(log, filter) then
                local row = Instance.new("Frame")
                row.BackgroundTransparency = 1
                row.Size = UDim2.new(1, 0, 0, 40)
                row.Parent = logList
                local button = Instance.new("TextButton")
                button.AutoButtonColor = false
                button.BackgroundColor3 = log == currentSelection and Theme2.Surface3 or Theme2.Surface2
                button.BorderSizePixel = 0
                button.Position = UDim2.fromOffset(0, 0)
                button.Size = UDim2.new(1, -34, 1, 0)
                button.Text = ""
                button.Parent = row
                corner(button, 6)
                stroke(button, Theme2.Border, .55)
                local label = Instance.new("TextLabel")
                label.BackgroundTransparency = 1
                label.Position = UDim2.fromOffset(12, 0)
                label.Size = UDim2.new(1, -18, 1, 0)
                label.Font = Enum.Font.GothamMedium
                label.Text = (log.Name or "Unnamed") .. "  ·  " .. tostring(log.metamethod or log.Function or "Unknown")
                label.TextColor3 = Theme2.Text
                label.TextSize = 11
                label.TextTruncate = Enum.TextTruncate.AtEnd
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = button
                button.Activated:Connect(function() selectLog(log) end)

                local pin = Instance.new("TextButton")
                pin.AutoButtonColor = false
                pin.BackgroundColor3 = Theme2.Surface2
                pin.BorderSizePixel = 0
                pin.Position = UDim2.new(1, -29, 0, 0)
                pin.Size = UDim2.fromOffset(29, 40)
                pin.Font = Enum.Font.GothamBold
                pin.Text = "★"
                pin.TextColor3 = log.Pinned and Theme2.Warning or Theme2.Dim
                pin.TextSize = 14
                pin.Parent = row
                corner(pin, 6)
                stroke(pin, Theme2.Border, .55)
                pin.Activated:Connect(function()
                    log.Pinned = not log.Pinned
                    pin.TextColor3 = log.Pinned and Theme2.Warning or Theme2.Dim
                end)
                rows[#rows + 1] = row
            end
        end
        logList.CanvasSize = UDim2.fromOffset(0, logLayout.AbsoluteContentSize.Y)
    end

    search:GetPropertyChangedSignal("Text"):Connect(function()
        renderLogs()
    end)

    makeAction("Copy Code", function()
        setclipboard(codebox:getString())
        setStatus("COPIED CODE", Theme2.Success)
    end)

    makeAction("Copy Remote", function()
        if selected and selected.Remote then
            setclipboard(v2s(selected.Remote))
            setStatus("COPIED REMOTE", Theme2.Success)
        end
    end)

    makeAction("Copy Script", function()
        if selected and selected.Source then
            setclipboard(v2s(selected.Source))
            setStatus("COPIED SCRIPT", Theme2.Success)
        end
    end)

    makeAction("Clear Logs", function()
        local keep = {}
        for _, log in ipairs(logs) do if log.Pinned then keep[#keep + 1] = log end end
        logs = keep
        currentSelection = nil
        selected = nil
        codebox:setRaw("")
        renderLogs()
        setStatus("LOGS CLEARED", Theme2.Success)
    end)

    makeAction("Hide by ID", function()
        if selected then blacklist[OldDebugId(selected.Remote)] = true; setStatus("REMOTE HIDDEN", Theme2.Warning) end
    end)

    makeAction("Hide by Name", function()
        if selected then blacklist[selected.Name] = true; setStatus("REMOTE HIDDEN", Theme2.Warning) end
    end)

    makeAction("Clear Hidden", function()
        blacklist = {}
        setStatus("HIDDEN LIST CLEARED", Theme2.Success)
    end)

    makeAction("Block by ID", function()
        if selected then blocklist[OldDebugId(selected.Remote)] = true; setStatus("REMOTE BLOCKED", Theme2.Danger) end
    end)

    makeAction("Block by Name", function()
        if selected then blocklist[selected.Name] = true; setStatus("REMOTE BLOCKED", Theme2.Danger) end
    end)

    makeAction("Clear Blocks", function()
        blocklist = {}
        setStatus("BLOCK LIST CLEARED", Theme2.Success)
    end)

    makeAction("Function Info", function()
        if not selected or not selected.Function or typeof(selected.Function) == "string" then return end
        local func = selected.Function
        local infoData = {
            info = getinfo(func),
            constants = islclosure(func) and deepclone(getconstants(func)) or "C closure",
            upvalues = deepclone(getupvalues(func)),
            script = selected.Source or nil,
        }
        codebox:setRaw(v2v({functionInfo = infoData}))
        setStatus("FUNCTION INFO", Theme2.Accent)
    end)

    makeAction("Toggle Function Info", function()
        configs.funcEnabled = not configs.funcEnabled
        setStatus(configs.funcEnabled and "FUNCTION INFO ON" or "FUNCTION INFO OFF", configs.funcEnabled and Theme2.Success or Theme2.Warning)
    end)

    makeAction("Toggle Auto Block", function()
        configs.autoblock = not configs.autoblock
        history = {}
        excluding = {}
        setStatus(configs.autoblock and "AUTO BLOCK ON" or "AUTO BLOCK OFF", configs.autoblock and Theme2.Warning or Theme2.Success)
    end)

    makeAction("Toggle Caller Filter", function()
        configs.logcheckcaller = not configs.logcheckcaller
        setStatus(configs.logcheckcaller and "CALLER FILTER ON" or "CALLER FILTER OFF", Theme2.Accent)
    end)

    makeAction("Toggle Advanced", function()
        configs.advancedinfo = not configs.advancedinfo
        setStatus(configs.advancedinfo and "ADVANCED INFO ON" or "ADVANCED INFO OFF", Theme2.Accent)
    end)

    local dragging = false
    local dragStart
    local startPosition
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = window.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local delta = input.Position - dragStart
        window.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)

    close.Activated:Connect(function()
        gui:Destroy()
        if getgenv().SimpleSpyShutdown then pcall(getgenv().SimpleSpyShutdown) end
        getgenv().SimpleSpyModernGui = nil
    end)

    local refreshConnection
    refreshConnection = RunService.Heartbeat:Connect(function()
        if not gui.Parent then
            refreshConnection:Disconnect()
            return
        end
        local count = #logs
        local filter = search.Text or ""
        if count ~= lastCount or filter ~= lastFilter then
            lastCount = count
            lastFilter = filter
            renderLogs()
        end
    end)

    renderLogs()
end
