# SimpleSpy refactor / UI v3

Branch: `refactor/ui-v3`

This branch preserves `SpyV2Beta.lua` as the reference implementation and introduces a separated presentation layer under `refactor/UI/`.

## Goals

- Keep the existing remote-spy/interception and serialization behavior as the compatibility baseline.
- Separate UI construction from state, event capture, serialization, and executor compatibility.
- Replace the fixed 450x268 layout with a responsive desktop/mobile-friendly layout.
- Centralize colors, dimensions, animation timings, and spacing in `UI/Theme.lua`.
- Centralize widget construction, hover states, log rows, action buttons, and dragging in `UI/Builder.lua`.
- Keep callbacks injected from the existing core instead of duplicating remote logic in the UI.

## Planned architecture

```text
SpyV2Beta.lua (compatibility/core)
        |
        +-- ExecutorAdapter
        +-- RemoteCapture
        +-- Scheduler
        +-- Serializer
        +-- LogStore
        +-- ConfigStore
        |
        +-- UI Controller
              |
              +-- UI.Theme
              +-- UI.Builder
              +-- LogList
              +-- CodeView
              +-- ActionBar
              +-- Settings
```

## Existing issues to fix during integration

The current source contains several correctness hazards that should be fixed without changing intended behavior:

1. Recursive `Search` calls do not preserve the `logtable` argument.
2. `ThreadIsNotDead` uses `not status(thread) == "dead"`; this should be expressed as `status(thread) ~= "dead"`.
3. `clean` uses `not typeof(max) == "number"`; this should be expressed as `typeof(max) ~= "number"`.
4. `tabletostring` is declared but empty.
5. The UI currently mixes construction, state, event wiring, and core operations in one large file.
6. Runtime HTTP loading of optional dependencies should have explicit fallbacks and versioning.
7. UI cleanup should use one connection registry and deterministic teardown.
8. The existing resize validation has an X/Y comparison mix-up that should be corrected when the new responsive layout is integrated.

## Integration rule

Do not rewrite the remote interception layer blindly. First extract it behind stable interfaces, then swap the UI. This keeps behavior comparable against the original implementation and makes regressions easier to isolate.

## Verification checklist

- Toggle capture on/off repeatedly.
- Fire RemoteEvent, UnreliableRemoteEvent, and RemoteFunction calls.
- Select, pin, filter, and clear logs.
- Generate code for primitive values, Instances, tables, cyclic/duplicate tables, and long strings.
- Resize and drag at multiple viewport sizes.
- Close/reopen repeatedly and verify all connections/hooks are restored.
- Verify settings persistence and graceful behavior when optional executor APIs are unavailable.
