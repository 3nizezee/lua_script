--!strict
-- SimpleSpy Refactor / Legacy Bridge
-- Adapter contract between the existing SpyV2Beta state and the new presentation layer.
-- This module does not hook remotes, execute generated code, or add interception behavior.

local LegacyBridge = {}
LegacyBridge.__index = LegacyBridge

function LegacyBridge.new(store)
    return setmetatable({
        store = store,
        selectedLegacyLog = nil,
        onSelectionChanged = nil,
    }, LegacyBridge)
end

function LegacyBridge:_notifySelection(entry, legacyLog)
    self.selectedLegacyLog = legacyLog
    if self.onSelectionChanged then
        self.onSelectionChanged(entry, legacyLog)
    end
end

function LegacyBridge:setSelectionCallback(callback)
    self.onSelectionChanged = callback
end

function LegacyBridge:ingest(legacyLog)
    if type(legacyLog) ~= "table" then
        return nil
    end

    local remote = legacyLog.Remote
    local method = legacyLog.metamethod or legacyLog.Function or "Unknown"
    local entry = self.store:add({
        remote = remote,
        name = legacyLog.Name or (remote and remote.Name) or "Unknown",
        method = method,
        args = legacyLog.args,
        timestamp = legacyLog.timestamp,
        pinned = legacyLog.Pinned == true,
        blocked = legacyLog.Blocked == true,
    })

    return entry
end

function LegacyBridge:select(entryId, legacyLog)
    if not self.store:select(entryId) then
        return false
    end

    local entry = self.store:getSelected()
    self:_notifySelection(entry, legacyLog)
    return true
end

function LegacyBridge:syncBlocked(entryId, blocked)
    local entry = self.store:find(entryId)
    if not entry then
        return false
    end

    entry.blocked = blocked == true
    return true
end

return LegacyBridge
