local Enforcer = Enforcer
local detours_library = Enforcer.Detours

-- Example usage:
--[[
if SERVER then
    AddMetatableDetour("Entity", "SetCollisionGroup", "unique_name", function(ent, collision_group)
        print("Set collision group called, trying to set " .. ent:EntIndex() .. " to group " .. collision_group)
        if collision_group ~= 0 then return false end
    end)
    Entity(94):SetCollisionGroup(1)
    print(Entity(94):GetCollisionGroup())
end
]]
function detours_library.AddMetatableDetour(metatable_name, function_name, detour_uniquename, detour)
    detour = detours_library.CheckDetour(detour)

    local metatable = FindMetaTable(metatable_name)
    if metatable == nil then error("No metatable for '" .. type(metatable_name) .. "'.") end

    metatable[function_name] = detours_library.AddDetour(metatable[function_name], detour_uniquename, detour)
end

function detours_library.RemoveMetatableDetour(metatable_name, function_name, detour_uniquename)
    local metatable = FindMetaTable(type(metatable_name))
    if metatable == nil then error("No metatable for '" .. type(metatable_name) .. "'.") end

    detours_library.RemoveDetour(metatable[function_name], detour_uniquename)
end
