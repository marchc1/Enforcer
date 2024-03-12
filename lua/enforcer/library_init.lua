Enforcer.Library = {}

local incSH = Enforcer.incSH

-- helper classes
Enforcer.Library.Stopwatch = incSH("library/stopwatch.lua")
Enforcer.Library.Queue = incSH("library/queue.lua")

incSH("library/notifications.lua")
incSH("library/compatibility.lua")