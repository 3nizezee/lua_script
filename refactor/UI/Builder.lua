--!strict
-- SimpleSpy UI Refactor / Builder
-- Presentation layer only; remote interception stays in the legacy core.

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Theme = require(script.Parent.Theme)
local C, M, Motion = Theme.Colors, Theme.Metrics, Theme.Motion

local Builder = { colors = C }

local function make(className, props, parent)
    local object = Instance.new(className)
    for key, value in pairs(props or {}) do object[key] = value end
    object.Parent = parent
    return object
end

local function corner(parent, radius)
    return make("UICorner", {CornerRadius = UDim.new(0, radius or M.Radius)}, parent)
end

local function stroke(parent, color, transparency)
    return make("UIStroke", {Color = color or C.Border, Transparency = transparency or 0, Thickness = 1}, parent)
end

function Builder.tween(object, properties, info)
    local tween = TweenService:Create(object, info or Motion.Normal, properties)
    tween:Play()
    return tween
end

function Builder.createRoot()
    local gui = make("ScreenGui", {Name = "SimpleSpyRefactor", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true})
    local window = make("Frame", {Name = "Window", BackgroundColor3 = C.Background, BorderSizePixel = 0, Position = UDim2.fromScale(.5,.5), AnchorPoint = Vector2.new(.5,.5), Size = UDim2.fromOffset(M.DefaultWidth,M.DefaultHeight), ClipsDescendants = true}, gui)
    corner(window); stroke(window,C.Border,.15)

    local topbar = make("Frame", {Name="Topbar", BackgroundColor3=C.Surface, BorderSizePixel=0, Size=UDim2.new(1,0,0,M.TopbarHeight)}, window)
    local title = make("TextLabel", {Name="Title", BackgroundTransparency=1, Position=UDim2.fromOffset(16,0), Size=UDim2.new(.5,0,1,0), Font=Enum.Font.GothamBold, Text="SimpleSpy", TextColor3=C.Text, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left}, topbar)
    local status = make("TextLabel", {Name="Status", BackgroundTransparency=1, Position=UDim2.new(.5,0,0,0), Size=UDim2.new(.5,-16,1,0), Font=Enum.Font.GothamMedium, Text="CAPTURE READY", TextColor3=C.Success, TextSize=11, TextXAlignment=Enum.TextXAlignment.Right}, topbar)

    local body = make("Frame", {Name="Body", BackgroundTransparency=1, Position=UDim2.fromOffset(0,M.TopbarHeight), Size=UDim2.new(1,0,1,-M.TopbarHeight)}, window)
    local sidebar = make("Frame", {Name="Sidebar", BackgroundColor3=C.Surface, BorderSizePixel=0, Position=UDim2.fromOffset(M.Padding,M.Padding), Size=UDim2.new(0,M.SidebarWidth,1,-M.Padding*2)}, body)
    corner(sidebar,M.SmallRadius); stroke(sidebar,C.Border,.35)
    local content = make("Frame", {Name="Content", BackgroundColor3=C.Surface, BorderSizePixel=0, Position=UDim2.new(0,M.SidebarWidth+M.Padding*2,0,M.Padding), Size=UDim2.new(1,-(M.SidebarWidth+M.Padding*3),1,-M.Padding*2)}, body)
    corner(content,M.SmallRadius); stroke(content,C.Border,.35)

    local search = make("TextBox", {Name="Search", BackgroundColor3=C.Surface2, BorderSizePixel=0, Position=UDim2.fromOffset(10,10), Size=UDim2.new(1,-20,0,34), ClearTextOnFocus=false, Font=Enum.Font.Gotham, PlaceholderText="Search remotes...", PlaceholderColor3=C.TextDim, Text="", TextColor3=C.Text, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left}, sidebar)
    corner(search,M.SmallRadius); stroke(search,C.Border,.45)
    local logs = make("ScrollingFrame", {Name="Logs", Active=true, AutomaticCanvasSize=Enum.AutomaticSize.Y, BackgroundTransparency=1, BorderSizePixel=0, Position=UDim2.fromOffset(10,52), Size=UDim2.new(1,-20,1,-62), ScrollBarThickness=3, ScrollBarImageColor3=C.Accent, CanvasSize=UDim2.new()}, sidebar)
    make("UIListLayout", {Padding=UDim.new(0,5), SortOrder=Enum.SortOrder.LayoutOrder}, logs)

    make("TextLabel", {Name="CodeTitle", BackgroundTransparency=1, Position=UDim2.fromOffset(12,10), Size=UDim2.new(1,-24,0,28), Font=Enum.Font.GothamBold, Text="Generated Code", TextColor3=C.Text, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left}, content)
    local code = make("TextBox", {Name="CodeText", BackgroundColor3=C.Code, BorderSizePixel=0, Position=UDim2.fromOffset(12,42), Size=UDim2.new(1,-24,.57,-48), ClearTextOnFocus=false, MultiLine=true, Font=Enum.Font.Code, Text="", TextColor3=C.Text, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top}, content)
    corner(code,M.SmallRadius); stroke(code,C.Border,.5)
    local actions = make("ScrollingFrame", {Name="Actions", Active=true, AutomaticCanvasSize=Enum.AutomaticSize.Y, BackgroundTransparency=1, BorderSizePixel=0, Position=UDim2.new(0,12,.57,4), Size=UDim2.new(1,-24,.43,-16), ScrollBarThickness=3, ScrollBarImageColor3=C.Accent, CanvasSize=UDim2.new()}, content)
    make("UIGridLayout", {CellPadding=UDim2.fromOffset(7,7), CellSize=UDim2.new(.25,-6,0,34), SortOrder=Enum.SortOrder.LayoutOrder}, actions)

    return {Gui=gui,Window=window,Topbar=topbar,Title=title,Status=status,Body=body,Sidebar=sidebar,Search=search,Logs=logs,Content=content,Code=code,CodeText=code,Actions=actions}
end

function Builder.createAction(parent,text,callback)
    local button=make("TextButton",{AutoButtonColor=false,BackgroundColor3=C.Surface2,BorderSizePixel=0,Font=Enum.Font.GothamMedium,Text=text,TextColor3=C.Text,TextSize=11},parent)
    corner(button,M.SmallRadius); local outline=stroke(button,C.Border,.45)
    button.MouseEnter:Connect(function() Builder.tween(button,{BackgroundColor3=C.Surface3},Motion.Fast); Builder.tween(outline,{Transparency=0},Motion.Fast) end)
    button.MouseLeave:Connect(function() Builder.tween(button,{BackgroundColor3=C.Surface2},Motion.Fast); Builder.tween(outline,{Transparency=.45},Motion.Fast) end)
    button.Activated:Connect(function() if callback then callback(button) end end)
    return button
end

function Builder.createLog(parent,titleText,accent,callback)
    local button=make("TextButton",{AutoButtonColor=false,BackgroundColor3=C.Surface2,BorderSizePixel=0,Size=UDim2.new(1,0,0,40),Text=""},parent)
    corner(button,M.SmallRadius); stroke(button,C.Border,.55)
    make("Frame",{BackgroundColor3=accent or C.Accent,BorderSizePixel=0,Position=UDim2.fromOffset(7,9),Size=UDim2.fromOffset(3,22)},button)
    make("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(18,0),Size=UDim2.new(1,-24,1,0),Font=Enum.Font.GothamMedium,Text=titleText,TextColor3=C.Text,TextSize=11,TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=Enum.TextXAlignment.Left},button)
    button.MouseEnter:Connect(function() Builder.tween(button,{BackgroundColor3=C.Surface3},Motion.Fast) end)
    button.MouseLeave:Connect(function() Builder.tween(button,{BackgroundColor3=C.Surface2},Motion.Fast) end)
    button.Activated:Connect(function() if callback then callback(button) end end)
    return button
end

function Builder.enableDrag(window,handle)
    local dragging=false; local dragStart; local startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=true; dragStart=input.Position; startPos=window.Position end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging or (input.UserInputType~=Enum.UserInputType.MouseMovement and input.UserInputType~=Enum.UserInputType.Touch) then return end
        local d=input.Position-dragStart
        Builder.tween(window,{Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)},Motion.Fast)
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)
end

return Builder
