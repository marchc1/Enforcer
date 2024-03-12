local function Queue()
    local obj = {}
    obj.__items = {}

    function obj:push(item)
        self.__items[#self.__items + 1] = item
    end

    function obj:pop()
        local ret = self.__items[1]
        table.remove(self.__items, 1)
        return ret
    end

    function obj:empty()
        return self.__items[1] == nil
    end

    local function iter(self)
        if not self:empty() then return #self.__items, self:pop() end
    end

    -- returns an iterator like ipairs that pops all items when they're iterated
    function obj:iterate()
        return iter, self, 0
    end

    return obj
end

return Queue