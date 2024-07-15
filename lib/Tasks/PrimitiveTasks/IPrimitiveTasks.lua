-- IPrimitiveTask.lua
local IPrimitiveTask = {}
IPrimitiveTask.__index = IPrimitiveTask

function IPrimitiveTask:New()
    error("IPrimitiveTask is an interface and cannot be instantiated")
end

function IPrimitiveTask:GetExecutingConditions()
    error("GetExecutingConditions method not implemented")
end

function IPrimitiveTask:AddExecutingCondition(condition)
    error("AddExecutingCondition method not implemented")
end

function IPrimitiveTask:GetOperator()
    error("GetOperator method not implemented")
end

function IPrimitiveTask:SetOperator(action)
    error("SetOperator method not implemented")
end

function IPrimitiveTask:GetEffects()
    error("GetEffects method not implemented")
end

function IPrimitiveTask:AddEffect(effect)
    error("AddEffect method not implemented")
end

function IPrimitiveTask:ApplyEffects(ctx)
    error("ApplyEffects method not implemented")
end

function IPrimitiveTask:Stop(ctx)
    error("Stop method not implemented")
end

function IPrimitiveTask:Aborted(ctx)
    error("Aborted method not implemented")
end

return IPrimitiveTask
