--!strict

-- Integration layer for the existing SpyV2Beta runtime.
-- This module deliberately does not install hooks or execute remote calls.
-- It only connects the legacy log objects to the presentation layer.

local Integration = {}
Integration.__index = Integration

type Store = any
type Controller = any

type LegacyLog = {
    Name: string?,
    Remote: Instance?,
    Function: any,
    metamethod: string?,
    args: {any}?,
    DebugId: string?,
    Pinned: boolean?,
    Blocked: boolean?,
    GenScript: string?,
    Log: GuiObject?,
}

type Options = {
    store: Store,
    controller: Controller,
    logs: {LegacyLog},
    genScript: ((Instance, {any}) -> string)?,
    onSelected: ((LegacyLog) -> ())?,
}

function Integration.new(options: Options)
    assert(options.store, "Integration requires a LogStore")
    assert(options.controller, "Integration requires a UI controller")
    assert(options.logs, "Integration requires the legacy logs table")

    local self = setmetatable({
        store = options.store,
        controller = options.controller,
        logs = options.logs,
        genScript = options.genScript,
        onSelected = options.onSelected,
        index = {},
    }, Integration)

    return self
end

function Integration:_syncEntry(legacy: LegacyLog)
    local entryId = legacy.DebugId or tostring(legacy.Remote)
    local existing = self.index[legacy]

    if existing then
        return existing
    end

    local entry = self.store:add({
        id = entryId,
        remote = legacy.Remote,
        name = legacy.Name or (legacy.Remote and legacy.Remote.Name) or "Unknown",
        method = legacy.metamethod or "Unknown",
        args = legacy.args or {},
        timestamp = os.clock(),
        pinned = legacy.Pinned == true,
        blocked = legacy.Blocked == true,
    })

    self.index[legacy] = entry.id
    return entry
end

function Integration:sync()
    for _, legacy in ipairs(self.logs) do
        self:_syncEntry(legacy)
    end
end

function Integration:select(entryId: string)
    local entry = self.store:find(entryId)
    if not entry then
        return nil
    end

    for legacy, id in pairs(self.index) do
        if id == entryId then
            if self.genScript and legacy.Remote and legacy.args then
                legacy.GenScript = self.genScript(legacy.Remote, legacy.args)
            end
            if self.onSelected then
                self.onSelected(legacy)
            end
            return legacy
        end
    end

    return nil
end

function Integration:refresh()
    self:sync()
    self.controller:_renderLogs()
end

return Integration
