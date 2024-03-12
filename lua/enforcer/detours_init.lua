local Enforcer = Enforcer

if Enforcer.Detours == nil then Enforcer.Detours = {} end
if Enforcer.Detours.Storage == nil then Enforcer.Detours.Storage = {} end
if Enforcer.Detours.Storage.Func2Detour == nil then Enforcer.Detours.Storage.Func2Detour = {} end

local detours_library     = Enforcer.Detours
local storage     = detours_library.Storage
local func2detour = storage.Func2Detour

local unpack, ipairs, pairs, empty, type = unpack, ipairs, pairs, table.IsEmpty, type

local function __detourcall(self, ...)
    local detours = self.detours
    if empty(detours) then
        return self.original(...)
    end

    local packed = {...}

    for _, v in pairs(detours) do
        if v.pre then
            local continues = {v.pre(...)}

            if continues[1] == false and v.blocking then
                local ret = {}

                for i = 2, #continues do
                    ret[i - 1] = continues[i]
                end

                return unpack(ret)
            end

            if #continues > 0 and v.modifying then
                for k, v2 in ipairs(continues) do
                    packed[k] = v2
                end
            end
        end
    end

    local ret = {self.original(unpack(packed))}

    for _, v in pairs(detours) do
        if v.post then
            v.post(unpack(ret))
        end
    end

    return unpack(ret)
end

-- Update existing detour functions with this new detour function
for k, v in pairs(func2detour) do
    v.call = __detourcall
end

-- If a function is provided, automatically build a Detours.Detour object with this function set as the pre function.
-- Otherwise, return as normal

function detours_library.CheckDetour(item)
    if type(item) == "function" then
        return detours_library.DetourObject(item, nil, true)
    end

    return item
end

-- If you REALLY need to get the original function back for some reason, use this method.
-- It will work even if the function was never detoured.

function detours_library.GetOriginalFunction(func)
    detours_library.ConfirmIfDetourable(func)

    local detour_storage = func2detour[func]
    if detour_storage == nil then return func end

    return detour_storage.original
end

-- Create a detour object with the original function and the hooks.
-- These are the base objects that store original functions, all detour registrations, & the __detourcall function that 
-- replaces the original function
function detours_library.CreateOriginalFunctionStorage(original_function)
    local obj = {}
    obj.original = original_function
    obj.detours = {}
    obj.call = __detourcall
    return obj
end

-- Detours can have two different kinds of behaviors for pre-methods:

-- 1. Blocking: Returning false from this detour will immediately halt execution. Remaining arguments in the return from the detour can be the result of the function,
-- which allows you to modify the return value.
-- 2. Modifying: Returning anything from this detour will not halt execution, but instead modify the original arguments of the function. This allows you to let
-- the original function run, but also modify what ultimately ends up being passed as arguments to it.

-- Pre methods are ran before the original function is ran. The arguments passed are the same arguments passed to the function call.
-- Post methods are ran after the original function is ran. Blocking is not applicable to post-methods, but modifying, instead of modifying the original arguments for
-- the original function call, now will modify the return results. The arguments passed to the post method are the return values from the original function call.

-- The default of a detour, when a function is provided to AddDetour methods, is to be a pre-executing blocking detour, since this is the most typical behavior needed.

function detours_library.DetourObject(pre, post, blocking, modifiying)
    local obj = {}
    obj.pre = pre
    obj.post = post
    obj.blocking = (blocking == nil and true or blocking)
    obj.modifying = (modifiying == nil and false or modifiying)
    return obj
end

function detours_library.ConfirmIfDetourable(item)
    if item == nil then error("Cannot detour nil.") end
    if type(item) ~= "function" then error("Cannot detour a non-function.") end
    return item
end

-- Under the hood, everything uses this detouring system. It wraps the function and returns the new function to take its place.
-- Note: the code is smart enough to recognize when an already-detoured function is being detoured again, so just do original = adddetour(original, etc...)

function detours_library.AddDetour(func, unique_name, detour)
    detours_library.ConfirmIfDetourable(func)
    detour = detours_library.CheckDetour(detour)

    local detour_storage = func2detour[func]
    local returning_function = nil
    if detour_storage == nil then
        detour_storage = detours_library.CreateOriginalFunctionStorage(func)
        returning_function = function(...)
            return detour_storage:call(...)
        end
        func2detour[returning_function] = detour_storage
    else
        returning_function = func
    end

    detour_storage.detours[unique_name] = detour
    return returning_function
end

function detours_library.RemoveDetour(func, unique_name)
    local detour_storage = func2detour[func]
    if detour_storage == nil then return end

    detour_storage.detours[unique_name] = nil
end

local incSH, incSV = Enforcer.incSH, Enforcer.incSV

incSH "detours/detour_entity_functions.lua"
incSV "detours/detour_wiremod_gates.lua"
incSV "detours/detour_expression2_functions.lua"
incSH "detours/detour_global_functions.lua"
incSH "detours/detour_hooks.lua"
incSH "detours/detour_metatable_functions.lua"
incSH "detours/detour_starfall_functions.lua"