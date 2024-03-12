local Enforcer = Enforcer
local detours_library = Enforcer.Detours

-- Example:
-- AddSENTDetour("gmod_wire_user", "TriggerInput", "block_usage", function(self, iname, value) return false end)
function detours_library.AddSENTDetour(class_name, function_name, detour_uniquename, detour)
    detour = detours_library.CheckDetour(detour)

    local sent_table = scripted_ents.GetStored(class_name)
    if sent_table == nil then return end
    sent_table = sent_table.t

    sent_table[function_name] = detours_library.AddDetour(sent_table[function_name], detour_uniquename, detour)

    for _, v in ipairs(ents.FindByClass(class_name)) do
        v[function_name] = sent_table[function_name]
    end
end

function detours_library.RemoveSENTDetour(class_name, function_name, detour_uniquename)
    local sent_table = scripted_ents.GetStored(class_name)
    if sent_table == nil then return end
    sent_table = sent_table.t

    detours_library.RemoveDetour(sent_table[function_name], detour_uniquename)
end