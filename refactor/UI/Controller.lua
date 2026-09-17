--!strict
-- SimpleSpy UI Refactor / Controller
-- Presentation controller for LogStore. It contains no remote interception logic.

local Controller = {}
Controller.__index = Controller

function Controller.new(builder, store)
    return setmetatable({
        builder = builder,
        store = store,
        root = nil,
        disconnectStore = nil,
        connections = {},
        logButtons = {},
        currentFilter = "",
        currentCode = "",
    }, Controller)
end

function Controller:_disconnectAll()
    for _, connection in ipairs(self.connections) do
        if connection then
            connection:Disconnect()
        end
    end
    table.clear(self.connections)
end

function Controller:_matches(entry)
    local filter = string.lower(self.currentFilter)
    if filter == "" then
        return true
    end

    local name = string.lower(entry.name or "")
    local method = string.lower(entry.method or "")
    return string.find(name, filter, 1, true) ~= nil
        or string.find(method, filter, 1, true) ~= nil
end

function Controller:_renderLogs()
    if not self.root then
        return
    end

    local list = self.root.Logs
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("GuiObject") then
            child:Destroy()
        end
    end

    table.clear(self.logButtons)

    for _, entry in ipairs(self.store.entries) do
        if self:_matches(entry) then
            local title = entry.name or "Unnamed Remote"
            if entry.method and entry.method ~= "" then
                title = string.format("%s  ·  %s", title, entry.method)
            end

            local row = self.builder.createLog(list, title, nil, function()
                self.store:select(entry.id)
            end)
            self.logButtons[entry.id] = row
        end
    end
end

function Controller:setFilter(text: string)
    self.currentFilter = text or ""
    self:_renderLogs()
end

function Controller:setCode(text: string)
    self.currentCode = text or ""
    if self.root and self.root.CodeText then
        self.root.CodeText.Text = self.currentCode
    end
end

function Controller:mount(root)
    self:unmount()
    self.root = root

    self.disconnectStore = self.store:onChanged(function()
        self:_renderLogs()
    end)

    table.insert(self.connections, root.Search:GetPropertyChangedSignal("Text"):Connect(function()
        self:setFilter(root.Search.Text)
    end))

    table.insert(self.connections, root.CodeText.FocusLost:Connect(function()
        self.currentCode = root.CodeText.Text
    end))

    self:_renderLogs()
    self:setCode(self.currentCode)
    return self
end

function Controller:unmount()
    self:_disconnectAll()

    if self.disconnectStore then
        self.disconnectStore()
        self.disconnectStore = nil
    end

    self.root = nil
    table.clear(self.logButtons)
end

return Controller
