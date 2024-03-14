local random = math.Rand

local timers = {}
Enforcer.Library.Timers = timers

function timers.RandomDelay(unique_name, min_time, max_time, func)
    timer.Create(unique_name, random(min_time, max_time), 0, function()
        func()
        timer.Adjust(unique_name, random(min_time, max_time))
    end)
end