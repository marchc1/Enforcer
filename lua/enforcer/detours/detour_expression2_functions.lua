local Enforcer = Enforcer
local detours_library = Enforcer.Detours

-- Converts something like e:applyForce(v) to applyForce(e:v)
local function E2HelperSignatureToBaseSignature(helper_sig)
    local name = ""
    local args = {}
    local workarg = ""

    local colonized = false
    local started_args = false
    for i = 1, #helper_sig do
        local c = helper_sig[i]
        if c ~= " " then
            if c == ':' then
                if colonized then
                    error("Can't specify (this): more than once in a signature")
                end

                colonized = true
                args[#args + 1] = name .. ":"
                name = ""
            elseif c == '(' then
                if started_args then
                    error("Can't start arg reading again")
                end

                started_args = true
            elseif c == ')' then
                if not started_args then
                    error("Can't end arg reading; it never started")
                end

                if workarg ~= "" then
                    args[#args + 1] = workarg
                end

                break
            elseif c == ',' then
                if not started_args then
                    error("Can't separate arguments; arg reading didn't start")
                end
                args[#args + 1] = workarg
                workarg = ""
            else
                if started_args == false then
                    name = name .. c
                else
                    workarg = workarg .. c
                end
            end
        end
    end

    return table.concat{name, "(", table.concat(args), ")"}
end

local function getE2FuncTable(e2helper_signature)
    local converted_signature = E2HelperSignatureToBaseSignature(e2helper_signature)
    local e2_functiondef = wire_expression2_funcs[converted_signature]
    if e2_functiondef == nil then error("No E2 function with real signature '" .. converted_signature .. "' (e2helper_signature: '" .. e2helper_signature .. "')") end
    return e2_functiondef
end

-- Example: 
-- AddExpression2Detour("e:use()", "block_usage", function(self, args) return false end)
function detours_library.AddExpression2Detour(e2helper_signature, detour_uniquename, detour)
    detour = detours_library.CheckDetour(detour)

    local e2_functiondef = getE2FuncTable(e2helper_signature)

    e2_functiondef[3] = detours_library.AddDetour(e2_functiondef[3], detour_uniquename, detour)
end

function detours_library.RemoveExpression2Detour(e2helper_signature, detour_uniquename)
    local e2_functiondef = getE2FuncTable(e2helper_signature)

    detours_library.RemoveDetour(e2_functiondef[3], detour_uniquename)
end