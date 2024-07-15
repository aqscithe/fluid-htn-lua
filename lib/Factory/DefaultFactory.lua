-- DefaultFactory.lua
local IFactory = require("IFactory")

local DefaultFactory = setmetatable({}, IFactory)
DefaultFactory.__index = DefaultFactory

function DefaultFactory:New()
    return setmetatable({}, DefaultFactory)
end

function DefaultFactory:CreateArray(length)
    local array = {}
    for i = 1, length do
        array[i] = nil  -- Assuming default value is nil; change as needed
    end
    return array
end

function DefaultFactory:FreeArray(array)
    if array then
        for i in ipairs(array) do
            array[i] = nil
        end
        return true
    end
    return false
end

function DefaultFactory:CreateQueue()
    local queue = {first = 0, last = -1}
    function queue:push(value)
        local last = self.last + 1
        self.last = last
        self[last] = value
    end
    function queue:pop()
        local first = self.first
        if first > self.last then return nil end
        local value = self[first]
        self[first] = nil
        self.first = first + 1
        return value
    end
    return queue
end

function DefaultFactory:FreeQueue(queue)
    if queue then
        for k in pairs(queue) do
            queue[k] = nil
        end
        return true
    end
    return false
end

function DefaultFactory:CreateList()
    return {}
end

function DefaultFactory:FreeList(list)
    if list then
        for i in ipairs(list) do
            list[i] = nil
        end
        return true
    end
    return false
end

function DefaultFactory:Create()
    return {}
end

function DefaultFactory:Free(obj)
    if obj then
        for k in pairs(obj) do
            obj[k] = nil
        end
        return true
    end
    return false
end

return DefaultFactory
