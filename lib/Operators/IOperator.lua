-- IOperator.lua
local IOperator = {}
IOperator.__index = IOperator

function IOperator:New()
    error("IOperator is an interface and cannot be instantiated")
end

function IOperator:Update(ctx)
    error("Update method not implemented")
end

function IOperator:Stop(ctx)
    error("Stop method not implemented")
end

function IOperator:Aborted(ctx)
    error("Aborted method not implemented")
end

return IOperator
