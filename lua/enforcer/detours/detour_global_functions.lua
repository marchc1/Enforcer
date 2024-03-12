local Enforcer = Enforcer
local detours_library = Enforcer.Detours

function detours_library.AddGlobalDetour(global_name, detour_uniquename, detour)
    detour = detours_library.CheckDetour(detour)

    _G[global_name] = detours_library.AddDetour(_G[global_name], detour_uniquename, detour)
end

function detours_library.RemoveGlobalDetour(global_name, detour_uniquename)
    detours_library.RemoveDetour(_G[global_name], detour_uniquename)
end