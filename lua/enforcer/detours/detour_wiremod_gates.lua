local Enforcer = Enforcer
local detours_library = Enforcer.Detours

function detours_library.AddWireGateDetour(gate_name, detour_uniquename, detour)
    detour = detours_library.CheckDetour(detour)

    local gate_function = GateActions[gate_name]
    if gate_function == nil then error("Gate '" .. gate_name .. "' does not exist on the server.") end
    gate_function.output = detours_library.AddDetour(gate_function.output, detour_uniquename, detour)
end

function detours_library.RemoveWireGateDetour(gate_name, detour_uniquename)
    local gate_function = GateActions[gate_name]
    if gate_function == nil then error("Gate '" .. gate_name .. "' does not exist on the server.") end

    detours_library.RemoveDetour(gate_function.output, detour_uniquename)
end