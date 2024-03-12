local Enforcer = Enforcer
Enforcer.Extensions = {Loaded = {}}

local extensions = Enforcer.Extensions
local compatibility = Enforcer.Compatibility
local loaded = Enforcer.Extensions.Loaded

-- The extension file creates an extension object itself. 
-- It calls this function with its UUID, which gives an Extension object it can modify.
-- LastRegisteredExtension is stored for when the include ends.

function Enforcer.Extension(uuid)
    local obj = {}

    obj.Name = "Unnamed Extension"
    obj.Author = "Unknown Author"
    obj.Description = "No description provided."
    obj.Help = "No help provided."
    obj.Source = "[???]"
    obj.UUID = uuid
    obj.IsReloading = extensions.Loaded[obj.UUID] ~= nil

    obj.Preferences = {}
    obj.Compatibility = {
        Require = {},
        Delay = 0.1,
        MaxTries = 10
    }

    function obj:Register() end
    function obj:Unregister() end

    timer.Simple(0.001, function() if obj.RegisterDelay ~= nil then timer.Simple(obj.RegisterDelay, function() extensions.Register(obj) end) return end extensions.Register(obj) end)

    extensions.LastRegisteredExtension = obj
    return obj
end

function extensions.Register(obj)
    local function finalizeRegistration()
        local good, whyisntit = pcall(function() obj:Register() end)

        if not good then
            Enforcer.Log("    [REGISTER/FAILURE]: " .. obj.Source)
            Enforcer.Log("        The component failed to register: " .. whyisntit)
            return
        end

        extensions.Loaded[obj.UUID] = obj
        Enforcer.Log("    [REGISTER/SUCCESS]: " .. obj.Name .. " by " .. obj.Author .. " [" .. obj.UUID .. "]")
    end

    if obj.Compatibility.Require ~= nil and #obj.Compatibility.Require > 0 then
        local maxtries, delay = obj.Compatibility.MaxTries or 10, obj.Compatibility.Delay or 0.1
        local registration_checks = {}

        local function check()
            for k, v in pairs(registration_checks) do
                if v ~= true then return end
            end
            finalizeRegistration()
        end

        local function fail()
            Enforcer.Log("    [REGISTER/FAILURE]: " .. obj.Source)
            Enforcer.Log("        The component failed its compatibility checks.: ")

            for k, v in pairs(registration_checks) do
                if type(k) == "function" then
                    local inf = debug.getinfo(v)
                    Enforcer.Log("            Custom check (function at " .. inf.short_src .. ", defined at line " .. inf.linedefined .. "): " .. v)
                else
                    Enforcer.Log("            Addon-compatibility check for '" .. k .. "': " .. v)
                end
            end
        end

        for _, v in ipairs(obj.Compatibility.Require) do
            registration_checks[v] = false
        end

        for _, v in ipairs(obj.Compatibility.Require) do
            local method = type(v) == "string" and compatibility.WaitForAddon or compatibility.WaitUntil

            method(v, function() registration_checks[v] = true check() end, maxtries, delay, function() fail() end)
        end
    else
        finalizeRegistration()
    end
end

function extensions.Unregister(obj)
    local good, whyisntit = pcall(function() obj:Unregister() end)

    if not good then
        Enforcer.Log("    [UNREGISTER/FAILURE]: " .. obj.Source)
        Enforcer.Log("        The component failed to unregister: " .. whyisntit)
        return
    end

    extensions.Loaded[obj.UUID] = nil
    Enforcer.Log("    [UNREGISTER/SUCCESS]: " .. obj.Name .. " by " .. obj.Author .. " [" .. obj.UUID .. "]")
end

local function safeInclude(filename)
    if CLIENT then -- for some reason, file.Read on lua files fails (even though the file exists), but only on the client...?
        include(filename)
        return
    end

    local can_compile = CompileString(file.Read(filename, "LUA"), "", false)
    if type(can_compile) ~= "function" then
        error("lua error" .. can_compile)
    end

    include(filename)
    return true
end

function extensions.NewExtension(filename, multifolder, folder)
    local source = "[???]"

    local succeeded, why = pcall(function() -- loads extensions
        if multifolder then
            local full_folder = "enforcer/" .. folder .. "/" .. filename .. "/"
            local shared = full_folder .. "shared.lua"
            source = full_folder
            if file.Exists(shared, "LUA") then AddCSLuaFile(shared) safeInclude(shared) end
        else
            local f = "enforcer/" .. folder .. "/" .. filename
            source = f
            if SERVER then
                AddCSLuaFile(f)
                safeInclude(f)
            else
                safeInclude(f)
            end
        end
    end)

    local obj = extensions.LastRegisteredExtension

    if obj == nil then
        Enforcer.Log("    last registered extension == nil?")
        return
    end

    if succeeded == false then
        Enforcer.Log("    [ BUILD/FAILURE]: " .. filename)
        Enforcer.Log("        The component at " .. source .. " failed: \"" .. string.sub(why, 54) .. "\"")
        return false
    end

    obj.Source = source

    loaded[obj.UUID] = obj
    EXTENSION = nil
    return true
end

local function LoadExtensionFolder(base_folder)
    local single_shared_file_extensions, multi_folder_extensions = file.Find("enforcer/" .. base_folder .. "/*", "LUA")
    local num_of_extensions, failed_extensions = 0, 0

    for _, filename in ipairs(single_shared_file_extensions) do
        local success = extensions.NewExtension(filename, false, base_folder)
        if success then num_of_extensions = num_of_extensions + 1 else failed_extensions = failed_extensions + 1 end
    end

    for _, folder in ipairs(multi_folder_extensions) do
        local success = extensions.NewExtension(folder, true, base_folder)
        if success then num_of_extensions = num_of_extensions + 1 else failed_extensions = failed_extensions + 1 end
    end

    return num_of_extensions, failed_extensions
end

extensions.LoadingAll = true
Enforcer.Log("Loading extensions...")
local extens, failedextens = LoadExtensionFolder("extensions")
Enforcer.Log("Loaded " .. extens .. " Enforcer extensions." .. (failedextens > 0 and (" " .. failedextens .. " extension" .. (failedextens > 1 and "s" or "") .. " failed to load.") or ""))
extensions.LoadingAll = false