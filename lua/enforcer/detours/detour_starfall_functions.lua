local Enforcer = Enforcer
local detours_library = Enforcer.Detours
local compatibility = Enforcer.Compatibility

local queue = Enforcer.Library.Queue()

function detours_library.AddStarfallTypeMethodDetour(...)
    queue:push{method = "AddStarfallTypeMethodDetour", args = {...}}
end

-- Because this has to detour SF.Instance.Compile, it needs to wait until Starfall is ready
compatibility.WaitForAddon("Starfall", function()
    if detours_library.SFDetours == nil then detours_library.SFDetours = {} end
    local sfdetours = detours_library.SFDetours

    if sfdetours.type_detours == nil then sfdetours.type_detours = {} end
    local type_detours = sfdetours.type_detours

    local function patchInstance(instance)
        for type_name, methods in pairs(type_detours) do
            local instanceMethods = instance.Types[type_name].Methods
            for method_name, detours in pairs(methods) do
                for detour_name, detour in pairs(detours) do
                    instanceMethods[method_name] = detours_library.AddDetour(instanceMethods[method_name], detour_name, detour, instance)
                end
            end
        end
    end

    SF.Instance.Compile = detours_library.AddDetour(SF.Instance.Compile, "__enforcerinternal_sfcompile_extension", detours_library.DetourObject(nil, function(ok, instance)
        if not ok then return end

        patchInstance(instance)
    end, false, false))

    function detours_library.AddStarfallTypeMethodDetour(type_name, function_name, detour_uniquename, detour)
        if type_detours[type_name] == nil then
            type_detours[type_name] = {}
        end

        local detours_for_type = type_detours[type_name]

        if detours_for_type[function_name] == nil then
            detours_for_type[function_name] = {}
        end

        local detours_for_func = detours_for_type[function_name]
        detours_for_func[detour_uniquename] = detour

        -- live patch all current starfalls
        for instance, _ in pairs(SF.allInstances) do
            local methods = instance.Types[type_name].Methods
            methods[function_name] = detours_library.AddDetour(methods[function_name], detour_uniquename, detour, instance)
        end
    end

    -- detour any calls to AddStarfallTypeMethodDetour/etc... before starfall initialized, now that we have everything ready
    for _, v in queue:iterate() do
        detours_library[v.method](unpack(v.args))
    end
end, 10, 0.1, function()
    Enforcer.Log("Starfall was not found! This isn't necessary for Enforcer to function, but some extensions may rely on it.")
    detours_library.AddStarfallTypeMethodDetour = Enforcer.FunctionRequiresUnavailableDependency
end)