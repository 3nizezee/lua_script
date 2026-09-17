# SimpleSpy Refactor

This directory is the cleaned presentation architecture for the existing `SpyV2Beta.lua` runtime.

## Structure

- `App.lua` — presentation entry point and lifecycle.
- `Core/Config.lua` — isolated configuration state.
- `Core/ExecutorAdapter.lua` — compatibility boundary for executor-specific globals.
- `Core/Integration.lua` — adapter from legacy log objects into the new store.
- `Core/LegacyBridge.lua` — small legacy-to-presentation data bridge.
- `Core/LogStore.lua` — presentation-independent log state.
- `UI/Theme.lua` — centralized visual tokens.
- `UI/Builder.lua` — rebuilt responsive UI.
- `UI/Controller.lua` — filtering, selection, rendering and pin state.

## Integration contract

The legacy runtime owns interception, serialization and existing add-ons. The refactor layer owns presentation. A host can construct the new UI with:

```lua
local App = require(Refactor.App)

local app = App.new({
    logs = logs,
    genScript = genScript,
    parent = gethui and gethui() or game:GetService("CoreGui"),
    onSelected = function(legacyLog)
        selected = legacyLog
    end,
})
```

`logs` and `genScript` are supplied by the existing runtime; the refactor layer does not install hooks or fire remotes.

## Important runtime note

These files are ModuleScript-oriented Luau source. They are intentionally not injected into `SpyV2Beta.lua` automatically because the original script is a single-file executor script while these modules use `require(script.Parent...)`. In Roblox Studio, place the `refactor` directory under a Folder/ModuleScript hierarchy matching the paths above. For a single-file executor release, a build/packaging step should inline these modules before distribution.

## Verification

Static source consistency was checked by keeping the legacy runtime separate from the presentation layer. Roblox/executor runtime execution was not available in this environment, so live hook behavior and executor compatibility remain unverified.
