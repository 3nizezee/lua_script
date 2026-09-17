--!strict
-- SimpleSpy UI Refactor / Controller
-- Binds the new presentation layer to a LogStore through callbacks.
-- No remote interception or execution logic lives here.

local Controller = {}
Controller.__index = Controller

function Controller.new(builder, store)
    local self = setmetatable({
        builder = builder,
        store = store,
        root = nil,
        disconnectStore = nil,
        logButtons = {},
        currentFilter = "",
        currentCode = "",
    }, Controller)
    return self
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

    local list = self.root.LogList
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("GuiObject") then
            child:Destroy()
        end
    end

    table.clear(self.logButtons)

    for _, entry in ipairs(self.store.entries) do
        if self:_matches(entry) then
            local row = self.builder.createLog(list, entry, function()
                self.store:select(entry.id)
            end, function()
                self.store:togglePinned(entry.id)
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
    self.root = root

    self.disconnectStore = self.store:onChanged(function()
        self:_renderLogs()
    end)

    if root.SearchBox then
        root.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
            self:setFilter(root.SearchBox.Text)
        end)
    end

    if root.ClearButton then
        root.ClearButton.Activated:Connect(function()
            self.store:clear(false)
        end)
    end

    self:_renderLogs()
    return self
end

function Controller:unmount()
    if self.disconnectStore then
        self.disconnectStore()
        self.disconnectStore = nil
    end
    self.root = nil
    table.clear(self.logButtons)
end

return Controller
