--!strict
-- SimpleSpy UI Refactor / LogStore
-- Presentation-independent storage for captured log records.

export type Entry = {
    id: string,
    remote: Instance?,
    name: string,
    method: string,
    args: {any}?,
    timestamp: number,
    pinned: boolean,
    blocked: boolean,
}

local LogStore = {}
LogStore.__index = LogStore

function LogStore.new(maxEntries: number?)
    local self = setmetatable({
        entries = {},
        maxEntries = math.max(1, math.floor(maxEntries or 300)),
        selectedId = nil,
        nextId = 0,
        changed = nil,
    }, LogStore)
    return self
end

function LogStore:_emit()
    if self.changed then
        task.spawn(self.changed, self.entries, self.selectedId)
    end
end

function LogStore:onChanged(callback)
    self.changed = callback
    return function()
        if self.changed == callback then
            self.changed = nil
        end
    end
end

function LogStore:add(data)
    self.nextId += 1
    local entry = {
        id = tostring(self.nextId),
        remote = data.remote,
        name = data.name or (data.remote and data.remote.Name) or "Unknown",
        method = data.method or "Unknown",
        args = data.args,
        timestamp = data.timestamp or os.clock(),
        pinned = data.pinned == true,
        blocked = data.blocked == true,
    }

    table.insert(self.entries, entry)

    while #self.entries > self.maxEntries do
        local removeIndex = nil
        for i, value in ipairs(self.entries) do
            if not value.pinned then
                removeIndex = i
                break
            end
        end
        if not removeIndex then
            break
        end
        table.remove(self.entries, removeIndex)
    end

    self:_emit()
    return entry
end

function LogStore:find(id: string)
    for _, entry in ipairs(self.entries) do
        if entry.id == id then
            return entry
        end
    end
    return nil
end

function LogStore:select(id: string?)
    if id ~= nil and not self:find(id) then
        return false
    end
    self.selectedId = id
    self:_emit()
    return true
end

function LogStore:togglePinned(id: string)
    local entry = self:find(id)
    if not entry then
        return false
    end
    entry.pinned = not entry.pinned
    self:_emit()
    return entry.pinned
end

function LogStore:clear(includePinned: boolean?)
    if includePinned then
        table.clear(self.entries)
    else
        local kept = {}
        for _, entry in ipairs(self.entries) do
            if entry.pinned then
                table.insert(kept, entry)
            end
        end
        self.entries = kept
    end

    self.selectedId = nil
    self:_emit()
end

function LogStore:setMaxEntries(value: number)
    value = math.max(1, math.floor(value))
    self.maxEntries = value

    while #self.entries > self.maxEntries do
        local index = nil
        for i, entry in ipairs(self.entries) do
            if not entry.pinned then
                index = i
                break
            end
        end
        if not index then
            break
        end
        table.remove(self.entries, index)
    end

    self:_emit()
end

function LogStore:count()
    return #self.entries
end

function LogStore:getSelected()
    return self.selectedId and self:find(self.selectedId) or nil
end

return LogStore
