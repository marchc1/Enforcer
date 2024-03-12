-- Some general use compatibility functions I thought may be useful. 
-- Some of these may be removed, changed, and some new ones may be added as I see fit; remember this addon is very experimental at the moment.
local type = type
local timer_simple = timer.Simple
local pairs = pairs

local compatibility = {}
Enforcer.Compatibility = compatibility

local function luaexist(f) return file.Exists(f, "LUA") end
local function globalexist(n) return _G[n] ~= nil end

local function Addon(filename, globalname)
    return {
        UniqueFile = filename,
        GlobalTableName = globalname,
        Installed = function()
            if filename == nil then -- in cases where you're trying to compat-check implementations, ex. CPPI, leave filename nil and it purely goes off global tables
                return globalexist(globalname)
            end
            return luaexist(filename)
        end,
        Ready = function()
            if globalname == nil then return end
            return globalexist(globalname)
        end
    }
end

-- Some of these are tested, some arent
-- I was able to test ACF3, AdvDupe2, CPPI, Prop2Mesh, Primitive, Starfall and Wiremod
-- I don't see why the others would fail, but let me know if they do
-- Note: use shared files when possible

compatibility.ACE           = Addon("acf/shared/sh_ace_loader.lua",                     "ACF")
compatibility.ACF2          = Addon("acf/acfloader.lua",                                "ACF_DefineFuelTank")
compatibility.ACF3          = Addon("autorun/acf_loader.lua",                           "ACF")
compatibility.AdvDupe2      = Addon("advdupe2/",                                        "AdvDupe2")
compatibility.CFW           = Addon("autorun/cfw_loader.lua",                           "CFW")
compatibility.CPPI          = Addon(nil,                                                "CPPI")
compatibility.Prop2Mesh     = Addon("autorun/prop2mesh.lua",                            "prop2mesh")
compatibility.Primitive     = Addon("autorun/primitive.lua",                            "Primitive")
compatibility.Starfall      = Addon("starfall/",                                        "SF")
compatibility.Wiremod       = Addon("autorun/wire_load.lua",                            "WireLib")
compatibility.WiremodExtras = Addon("autorun/server/sv_wire_directional_radio_kit.lua", "WIRE_DIRECTIONAL_RADIO_KIT")

local AddonDefinitions = {}
for k, _ in pairs(compatibility) do
    AddonDefinitions[string.lower(k)] = k
end

-- API provided to register new addons for compatibility checking
function compatibility.NewAddon(addon_name, unique_file, global_name)
    if compatibility[addon_name] ~= nil then return end
    compatibility[addon_name] = Addon(unique_file, global_name)
    AddonDefinitions[string.lower(addon_name)] = addon_name
end

-- Dumps all registered addon compatibility checkers
function compatibility.Dump()
    Enforcer.Log("Compatibility checks:")
    local maxk = 0
    for k, _ in pairs(compatibility) do
        if AddonDefinitions[string.lower(k)] ~= nil and #k > maxk then maxk = #k end
    end

    for k, v in SortedPairs(compatibility) do
        if AddonDefinitions[string.lower(k)] ~= nil then
            local installed, ready = v.Installed(), v.Ready()
            local loaded = {installed and "installed" or "not installed", installed and (ready == nil and "readiness unknown" or (ready and "ready" or "not ready")) or nil}

            Enforcer.Log("    " .. k .. string.rep(" ", maxk - #k) .. "    :    " .. table.concat(loaded,", "))
        end
    end

    Enforcer.Log("Note that Enforcer itself does not rely on anything here, but extensions may rely on these addons.")
end

-- Gets addon compatibility checker by name
function compatibility.GetCompatibilityChecker(name)
    local compataddon = compatibility[AddonDefinitions[string.lower(name)]]

    if compataddon == nil then
        error("No compatibility for addon '" .. string.lower(name) .. "'.")
    end

    return compataddon
end

function compatibility.RunIfCompatible(compataddon, run)
    if type(compataddon) == "string" then
        compataddon = compatibility.GetCompatibilityChecker(compataddon)
    end

    if compataddon.Installed() and compataddon.Ready() then
        run()
        return true
    end

    return false
end

-- Waits on running a block of code until an addon is fully ready to be used. Will immediately try to run the code otherwise.
-- This means the addon must be both installed on the server and the global table must exist.
-- Note that this doesnt guarantee that everything in the addon is ready. You may want to do your own checks instead, see compatibility.WaitUntil for
-- a more extensible solution

function compatibility.WaitForAddon(name, when_pass, maxtries, delay, when_fail)
    delay    = delay or 0.1
    maxtries = maxtries or 10

    local firstTry = compatibility.RunIfCompatible(name, when_pass)
    if firstTry then return end

    local loop
    function loop(attempts)
        attempts = attempts + 1
        if attempts > maxtries then
            if when_fail then when_fail() end
            return
        end

        timer_simple(delay, function()
            local try = compatibility.RunIfCompatible(name, when_pass)
            if try then return end

            loop(attempts)
        end)
    end

    loop(1)
end

-- Waits on running a block of code until check returns true. 
function compatibility.WaitUntil(check, when_pass, maxtries, delay, when_fail)
    if check() == true then return when_pass() end

    local loop
    function loop(attempts)
        attempts = attempts + 1
        if attempts > maxtries then
            if when_fail then when_fail() end
            return
        end

        timer_simple(delay, function()
            if check() == true then return when_pass() end

            loop(attempts)
        end)
    end

    loop(1)
end

compatibility.Dump()