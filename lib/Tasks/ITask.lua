-- ITask.lua
local ITask = {}
ITask.__index = ITask

function ITask:New()
    error("ITask is an interface and cannot be instantiated")
end

function ITask:GetName()
    error("getName method not implemented")
end

function ITask:SetName(name)
    error("setName method not implemented")
end

function ITask:GetParent()
    error("getParent method not implemented")
end

function ITask:SetParent(parent)
    error("setParent method not implemented")
end

function ITask:GetConditions()
    error("getConditions method not implemented")
end

function ITask:AddCondition(condition)
    error("AddCondition method not implemented")
end

function ITask:IsValid(ctx)
    error("IsValid method not implemented")
end

function ITask:OnIsValidFailed(ctx)
    error("OnIsValidFailed method not implemented")
end

return ITask
