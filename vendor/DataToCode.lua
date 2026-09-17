--!strict
-- SimpleSpy local DataToCode-compatible serializer.
-- Provides the subset used by SpyV2Beta: Convert(value) and ConvertKnown(type,value).

local Serializer = {}

local function escapeString(value)
    return string.format("%q", value)
end

local function number(value)
    if value ~= value then return "0/0" end
    if value == math.huge then return "math.huge" end
    if value == -math.huge then return "-math.huge" end
    return tostring(value)
end

local function instancePath(value)
    if value == game then return "game" end
    if value == workspace then return "workspace" end
    if typeof(value) ~= "Instance" then return "nil" end

    local Players = game:GetService("Players")
    local player = Players:GetPlayerFromCharacter(value)
    if player then
        if value == player.Character then
            if player == Players.LocalPlayer then return 'game:GetService("Players").LocalPlayer.Character' end
            return 'game:GetService("Players"):WaitForChild(' .. escapeString(player.Name) .. ').Character'
        end
    elseif value == Players.LocalPlayer then
        return 'game:GetService("Players").LocalPlayer'
    end

    local parts = {}
    local current = value
    while current and current ~= game do
        table.insert(parts, 1, current.Name)
        current = current.Parent
    end
    if current ~= game then return "nil" end

    local first = parts[1]
    local service = first and game:FindService(first)
    local result
    if service then
        result = 'game:GetService(' .. escapeString(first) .. ')'
        table.remove(parts, 1)
    else
        result = "game"
    end

    for _, part in ipairs(parts) do
        if part:match("^[%a_][%w_]*$") then
            result ..= "." .. part
        else
            result ..= ":WaitForChild(" .. escapeString(part) .. ")"
        end
    end
    return result
end

local function serialize(value, seen, depth)
    seen = seen or {}
    depth = depth or 0
    if depth > 30 then return "nil --[[maximum serializer depth]]" end

    local valueType = typeof(value)
    if value == nil then return "nil" end
    if valueType == "string" then return escapeString(value) end
    if valueType == "number" then return number(value) end
    if valueType == "boolean" then return tostring(value) end
    if valueType == "Instance" then return instancePath(value) end
    if valueType == "Vector2" then return string.format("Vector2.new(%s, %s)", number(value.X), number(value.Y)) end
    if valueType == "Vector3" then return string.format("Vector3.new(%s, %s, %s)", number(value.X), number(value.Y), number(value.Z)) end
    if valueType == "CFrame" then
        local parts = {value:GetComponents()}
        local out = {}
        for i, part in ipairs(parts) do out[i] = number(part) end
        return "CFrame.new(" .. table.concat(out, ", ") .. ")"
    end
    if valueType == "Color3" then return string.format("Color3.new(%s, %s, %s)", number(value.R), number(value.G), number(value.B)) end
    if valueType == "BrickColor" then return "BrickColor.new(" .. tostring(value.Number) .. ")" end
    if valueType == "NumberRange" then return string.format("NumberRange.new(%s, %s)", number(value.Min), number(value.Max)) end
    if valueType == "UDim" then return string.format("UDim.new(%s, %d)", number(value.Scale), value.Offset) end
    if valueType == "UDim2" then return string.format("UDim2.new(%s, %d, %s, %d)", number(value.X.Scale), value.X.Offset, number(value.Y.Scale), value.Y.Offset) end
    if valueType == "TweenInfo" then
        return string.format("TweenInfo.new(%s, Enum.EasingStyle.%s, Enum.EasingDirection.%s, %d, %s, %s)", number(value.Time), value.EasingStyle.Name, value.EasingDirection.Name, value.RepeatCount, tostring(value.Reverses), number(value.DelayTime))
    end
    if valueType == "EnumItem" then return tostring(value) end
    if valueType == "Ray" then return "Ray.new(" .. serialize(value.Origin, seen, depth + 1) .. ", " .. serialize(value.Direction, seen, depth + 1) .. ")" end
    if valueType == "Faces" then
        local faces = {}
        for _, name in ipairs({"Top", "Bottom", "Left", "Right", "Back", "Front"}) do
            if value[name] then faces[#faces + 1] = "Enum.NormalId." .. name end
        end
        return "Faces.new(" .. table.concat(faces, ", ") .. ")"
    end
    if valueType == "table" then
        if seen[value] then return "nil --[[cyclic table]]" end
        seen[value] = true
        local parts = {}
        for key, item in next, value do
            local keyText
            if type(key) == "string" and key:match("^[%a_][%w_]*$") then
                keyText = key
            else
                keyText = "[" .. serialize(key, seen, depth + 1) .. "]"
            end
            parts[#parts + 1] = keyText .. " = " .. serialize(item, seen, depth + 1)
        end
        seen[value] = nil
        return "{" .. table.concat(parts, ", ") .. "}"
    end
    if valueType == "function" then return "function() end" end
    return "nil --[[unsupported " .. valueType .. "]]"
end

function Serializer.Convert(value, format)
    return serialize(value)
end

function Serializer.ConvertKnown(dataType, value, format)
    return serialize(value)
end

Serializer.Version = "local-1"
return Serializer
