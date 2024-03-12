if CLIENT then
    net.Receive("enforcer.sendnotification", function()
        Enforcer.Notify(net.ReadString(), net.ReadFloat())
    end)
end

if SERVER then
    util.AddNetworkString("enforcer.sendnotification")
end

function Enforcer.Notify(message, time, players)
    time = time or 5
    if CLIENT then
        local uuid = "enforcernotif_" .. SysTime()
        notification.AddProgress(uuid, "Enforcer: " .. message)
        timer.Simple(time, function()
        	notification.Kill(uuid)
        end)
        surface.PlaySound("common/warning.wav")
    else
        net.Start("enforcer.sendnotification")
        net.WriteString(message)
        net.WriteFloat(time)
        if players == nil then
            net.Broadcast(players)
        else
            net.Send(players)
        end
    end
end