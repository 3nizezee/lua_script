--!strict
-- SimpleSpy Refactor App
-- ModuleScript entry point for the rebuilt presentation layer.
-- The legacy interception/serialization system remains external to this module.

local Builder = require(script.UI.Builder)
local Controller = require(script.UI.Controller)
local LogStore = require(script.Core.LogStore)
local Config = require(script.Core.Config)
local Integration = require(script.Core.Integration)

local App = {}
App.__index = App

function App.new(options)
    options = options or {}
    local store = options.store or LogStore.new(options.maxEntries or 300)
    local controller = Controller.new(Builder, store)
    local root = Builder.createRoot()
    local config = options.config or Config.new()

    root.Gui.Parent = options.parent or game:GetService("CoreGui")
    controller:mount(root)

    local integration = nil
    if options.logs then
        integration = Integration.new({
            store=store,
            controller=controller,
            logs=options.logs,
            genScript=options.genScript,
            onSelected=options.onSelected,
        })
        integration:sync()
        controller:_renderLogs()
    end

    local self = setmetatable({root=root,store=store,controller=controller,config=config,integration=integration}, App)
    return self
end

function App:refresh()
    if self.integration then self.integration:refresh() else self.controller:_renderLogs() end
end

function App:destroy()
    self.controller:unmount()
    if self.root and self.root.Gui then self.root.Gui:Destroy() end
end

return App
