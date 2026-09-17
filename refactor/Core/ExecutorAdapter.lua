--!strict
-- SimpleSpy UI Refactor / ExecutorAdapter
-- Compatibility boundary only. Does not add new capabilities.

local ExecutorAdapter = {}

local function firstGlobal(...)
    for i = 1, select("#", ...) do
        local value = select(i, ...)
        if value ~= nil then
            return value
        end
    end
    return nil
end

function ExecutorAdapter.get(name: string)
    local env = getgenv and getgenv() or _G
    local value = rawget(env, name)
    if value ~= nil then
        return value
    end
    return rawget(_G, name)
end

function ExecutorAdapter.resolveHookMetamethod()
    return firstGlobal(
        ExecutorAdapter.get("hookmetamethod"),
        (syn and syn.hookmetamethod)
    )
end

function ExecutorAdapter.resolveNewCClosure()
    return firstGlobal(
        ExecutorAdapter.get("newcclosure"),
        (syn and syn.newcclosure)
    )
end

function ExecutorAdapter.resolveCloneRef()
    return firstGlobal(
        ExecutorAdapter.get("cloneref"),
        (syn and syn.cloneref)
    )
end

function ExecutorAdapter.resolveRequest()
    return firstGlobal(
        ExecutorAdapter.get("request"),
        syn and syn.request
    )
end

function ExecutorAdapter.resolveClipboard()
    return firstGlobal(
        ExecutorAdapter.get("setclipboard"),
        ExecutorAdapter.get("toclipboard"),
        ExecutorAdapter.get("set_clipboard")
    )
end

function ExecutorAdapter.hasFilesystem()
    return ExecutorAdapter.get("isfile") ~= nil
        and ExecutorAdapter.get("readfile") ~= nil
        and ExecutorAdapter.get("writefile") ~= nil
        and ExecutorAdapter.get("isfolder") ~= nil
        and ExecutorAdapter.get("makefolder") ~= nil
end

return ExecutorAdapter
