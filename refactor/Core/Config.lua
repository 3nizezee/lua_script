--!strict
-- SimpleSpy UI Refactor / Config
-- Keeps configuration separate from UI and capture logic.

local Config = {}
Config.__index = Config

local DEFAULTS = {
    logcheckcaller = false,
    autoblock = false,
    funcEnabled = true,
    advancedinfo = false,
    supersecretdevtoggle = false,
    maxRemotes = 300,
}

function Config.new(overrides)
    local values = {}
    for key, value in pairs(DEFAULTS) do
        values[key] = value
    end
    for key, value in pairs(overrides or {}) do
        if DEFAULTS[key] ~= nil then
            values[key] = value
        end
    end
    return setmetatable({
        values = values,
        listeners = {},
    }, Config)
end

function Config:get(key: string)
    return self.values[key]
end

function Config:set(key: string, value: any)
    if DEFAULTS[key] == nil then
        return false
    end

    self.values[key] = value
    for _, listener in ipairs(self.listeners) do
        task.spawn(listener, key, value)
    end
    return true
end

function Config:onChanged(callback)
    table.insert(self.listeners, callback)
    local active = true
    return function()
        if not active then
            return
        end
        active = false
        for i, listener in ipairs(self.listeners) do
            if listener == callback then
                table.remove(self.listeners, i)
                break
            end
        end
    end
end

function Config:export()
    local copy = {}
    for key, value in pairs(self.values) do
        copy[key] = value
    end
    return copy
end

function Config:reset()
    for key, value in pairs(DEFAULTS) do
        self.values[key] = value
    end
end

return Config
