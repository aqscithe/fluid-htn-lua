-- IFactory.lua
-- Not needed in lua
local IFactory = {}
IFactory.__index = IFactory

function IFactory:New()
    error("IFactory is an interface and cannot be instantiated")
end

function IFactory:CreateArray(length)
    error("CreateArray method not implemented")
end

function IFactory:FreeArray(array)
    error("FreeArray method not implemented")
end

function IFactory:CreateQueue()
    error("CreateQueue method not implemented")
end

function IFactory:FreeQueue(queue)
    error("FreeQueue method not implemented")
end

function IFactory:CreateList()
    error("CreateList method not implemented")
end

function IFactory:FreeList(list)
    error("FreeList method not implemented")
end

function IFactory:Create()
    error("Create method not implemented")
end

function IFactory:Free(obj)
    error("Free method not implemented")
end

return IFactory
