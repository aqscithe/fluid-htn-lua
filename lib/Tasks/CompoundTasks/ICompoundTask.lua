-- ICompoundTask.lua
local ICompoundTask = {}
ICompoundTask.__index = ICompoundTask

function ICompoundTask:New()
    error("ICompoundTask is an interface and cannot be instantiated")
end

function ICompoundTask:GetSubtasks()
    error("GetSubtasks method not implemented")
end

function ICompoundTask:AddSubtask(subtask)
    error("AddSubtask method not implemented")
end

function ICompoundTask:Decompose(ctx, startIndex)
    error("Decompose method not implemented")
end

return ICompoundTask
