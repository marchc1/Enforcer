local Enforcer = Enforcer
local detours_library = Enforcer.Detours


-- Example:
--[[
if SERVER then
    hook.Add("Tick", "testing123", function() print("hey") end)

    AddHookDetour("Tick", "testing123", "i_want_to_stop_this", function(...) return false end)
end
]]
function detours_library.AddHookDetour(hook_name, hook_unique_name, detour_uniquename, detour)
    detour = detours_library.CheckDetour(detour)

    local hooks = hook.GetTable()[hook_name]
    if hooks == nil then return end

    local hook_function = hooks[hook_unique_name]
    if hook_function == nil then return end

    hook.Add(hook_name, hook_unique_name, detours_library.AddDetour(hook_function, detour_uniquename, detour))
end

function detours_library.RemoveHookDetour(hook_name, hook_unique_name, detour_uniquename)
    local hooks = hook.GetTable()[hook_name]
    if hooks == nil then return end

    local hook_function = hooks[hook_unique_name]
    if hook_function == nil then return end

    detours_library.RemoveDetour(hook_function, detour_uniquename)
end