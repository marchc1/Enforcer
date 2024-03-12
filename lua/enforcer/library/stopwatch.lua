local function Stopwatch()
    local obj = {}
    obj.__elapsed = 0
    obj.__start = 0
    obj.__running = false

    function obj:start()
        if obj.__running then return end
        obj.__start = SysTime()
        obj.__running = true
    end

    function obj:stop()
        if not self.__running then return end
        self.__elapsed = self.__elapsed + (SysTime() - self.__start)
        self.__start = 0
        self.__running = false
    end

    function obj:reset()
        self.__elapsed = 0
        if self.__running then
            self.__start = SysTime()
        end
    end

    function obj:elapsed()
        if self.__running == false then
            return self.__elapsed
        else
            return self.__elapsed + (SysTime() - self.__start)
        end
    end

    function obj:elapsedSeconds()
        -- todo
    end

    function obj:elapsedString()
        -- todo
    end

    function obj:running() return self.__running end

    return obj
end

return Stopwatch