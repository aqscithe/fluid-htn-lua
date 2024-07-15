-- Define the ICondition interface
local ICondition = {}
ICondition.__index = ICondition

function ICondition:New(name)
    local instance = setmetatable({}, ICondition)
    instance.Name = name
    return instance
end

function ICondition:IsValid(ctx)
    -- This function should be overridden in derived classes
    error("IsValid method not implemented")
end

return ICondition
