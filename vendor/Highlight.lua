--!strict
-- SimpleSpy local Highlight dependency.
-- API-compatible local implementation: new(), init(), setRaw(), getRaw(), getString().

local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local Highlight = {}
Highlight.__index = Highlight

local COLORS = {
    background = Color3.fromRGB(11, 13, 17),
    text = Color3.fromRGB(238, 240, 245),
    keyword = Color3.fromRGB(198, 160, 255),
    string = Color3.fromRGB(150, 205, 125),
    number = Color3.fromRGB(225, 175, 105),
    comment = Color3.fromRGB(130, 138, 150),
    function = Color3.fromRGB(120, 175, 245),
}

local KEYWORDS = {
    ["and"] = true, ["break"] = true, ["do"] = true, ["else"] = true,
    ["elseif"] = true, ["end"] = true, ["false"] = true, ["for"] = true,
    ["function"] = true, ["if"] = true, ["in"] = true, ["local"] = true,
    ["nil"] = true, ["not"] = true, ["or"] = true, ["repeat"] = true,
    ["return"] = true, ["then"] = true, ["true"] = true, ["until"] = true,
    ["while"] = true, ["continue"] = true,
}

local function escape(text)
    return text:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;")
end

local function rgb(color)
    return string.format("rgb(%d,%d,%d)", color.R * 255, color.G * 255, color.B * 255)
end

local function colorize(source)
    local out = {}
    local i = 1
    local length = #source

    while i <= length do
        local two = source:sub(i, i + 1)
        local one = source:sub(i, i)

        if two == "--" then
            local close = source:find("\n", i, true) or (length + 1)
            table.insert(out, string.format('<font color="%s">%s</font>', rgb(COLORS.comment), escape(source:sub(i, close - 1))))
            i = close
        elseif one == '"' or one == "'" then
            local quote = one
            local j = i + 1
            while j <= length do
                if source:sub(j, j) == "\\" then
                    j += 2
                elseif source:sub(j, j) == quote then
                    j += 1
                    break
                else
                    j += 1
                end
            end
            table.insert(out, string.format('<font color="%s">%s</font>', rgb(COLORS.string), escape(source:sub(i, j - 1))))
            i = j
        elseif one:match("[%a_]") then
            local j = i + 1
            while j <= length and source:sub(j, j):match("[%w_]") do j += 1 end
            local word = source:sub(i, j - 1)
            local color = KEYWORDS[word] and COLORS.keyword or nil
            if not color then
                local k = j
                while k <= length and source:sub(k, k):match("%s") do k += 1 end
                color = source:sub(k, k) == "(" and COLORS.function or COLORS.text
            end
            table.insert(out, string.format('<font color="%s">%s</font>', rgb(color), escape(word)))
            i = j
        elseif one:match("[%d]") then
            local j = i + 1
            while j <= length and source:sub(j, j):match("[%w%.]") do j += 1 end
            table.insert(out, string.format('<font color="%s">%s</font>', rgb(COLORS.number), escape(source:sub(i, j - 1))))
            i = j
        else
            table.insert(out, escape(one))
            i += 1
        end
    end

    return table.concat(out)
end

function Highlight.new(frame)
    local self = setmetatable({frame = nil, scrolling = nil, text = nil, lineNumbers = nil, raw = "", connection = nil}, Highlight)
    self:init(frame)
    return self
end

function Highlight:init(frame)
    assert(typeof(frame) == "Instance" and frame:IsA("Frame"), "Highlight expects a Frame")
    if self.connection then self.connection:Disconnect() end
    frame:ClearAllChildren()
    self.frame = frame

    local scrolling = Instance.new("ScrollingFrame")
    scrolling.Name = "CodeScroll"
    scrolling.BackgroundColor3 = COLORS.background
    scrolling.BorderSizePixel = 0
    scrolling.ScrollBarThickness = 4
    scrolling.Size = UDim2.fromScale(1, 1)
    scrolling.CanvasSize = UDim2.new()
    scrolling.Parent = frame

    local text = Instance.new("TextLabel")
    text.Name = "CodeText"
    text.BackgroundTransparency = 1
    text.RichText = true
    text.Font = Enum.Font.Code
    text.TextSize = 13
    text.TextColor3 = COLORS.text
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.TextYAlignment = Enum.TextYAlignment.Top
    text.Size = UDim2.fromOffset(1, 1)
    text.Position = UDim2.fromOffset(10, 8)
    text.Parent = scrolling

    local lineNumbers = Instance.new("TextLabel")
    lineNumbers.Name = "LineNumbers"
    lineNumbers.BackgroundTransparency = 1
    lineNumbers.Font = Enum.Font.Code
    lineNumbers.TextSize = 13
    lineNumbers.TextColor3 = COLORS.comment
    lineNumbers.TextXAlignment = Enum.TextXAlignment.Right
    lineNumbers.TextYAlignment = Enum.TextYAlignment.Top
    lineNumbers.Size = UDim2.fromOffset(34, 1)
    lineNumbers.Position = UDim2.fromOffset(0, 8)
    lineNumbers.Parent = scrolling

    self.scrolling = scrolling
    self.text = text
    self.lineNumbers = lineNumbers
    self.connection = frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        scrolling.Size = UDim2.fromScale(1, 1)
    end)
    self:setRaw("")
end

function Highlight:setRaw(raw)
    self.raw = tostring(raw or "")
    if not self.text then return end
    local lines = string.split(self.raw, "\n")
    self.text.Text = colorize(self.raw)
    self.lineNumbers.Text = table.concat((function()
        local result = {}
        for i = 1, math.max(#lines, 1) do result[i] = tostring(i) end
        return result
    end)(), "\n")
    local bounds = TextService:GetTextSize(self.raw, self.text.TextSize, self.text.Font, Vector2.new(math.huge, math.huge))
    local width = math.max(bounds.X + 70, self.frame.AbsoluteSize.X)
    local height = math.max(bounds.Y + 24, self.frame.AbsoluteSize.Y)
    self.text.Size = UDim2.fromOffset(width - 50, height)
    self.lineNumbers.Size = UDim2.fromOffset(34, height)
    self.scrolling.CanvasSize = UDim2.fromOffset(width, height)
end

function Highlight:getRaw()
    return self.raw
end

function Highlight:getString()
    return self.raw
end

function Highlight:getTable()
    local result = {}
    for char in self.raw:gmatch(".") do
        result[#result + 1] = {Char = char, Color = COLORS.text}
    end
    return result
end

function Highlight:getSize()
    return #self.raw
end

return Highlight
