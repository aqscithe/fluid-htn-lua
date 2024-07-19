-- CompoundTask.lua
local ICompoundTask = require("lib.Tasks.CompoundTasks.ICompoundTask")
local DecompositionStatus = require("lib.Tasks.CompoundTasks.DecompositionStatus")
local ConsoleColor = { White = "white", DarkGreen = "darkgreen", DarkRed = "darkred", Green = "green", Red = "red" } -- Simulating ConsoleColor

local CompoundTask = setmetatable({}, ICompoundTask)
CompoundTask.__index = CompoundTask

function CompoundTask:New(name)
    local instance = setmetatable({}, CompoundTask)
    instance.Name = name or ""
    instance.Parent = nil
    instance.Conditions = {}
    instance.Subtasks = {}
    return instance
end

function CompoundTask:GetName()
    return self.Name
end

function CompoundTask:SetName(name)
    self.Name = name
end

function CompoundTask:GetParent()
    return self.Parent
end

function CompoundTask:SetParent(parent)
    self.Parent = parent
end

function CompoundTask:GetConditions()
    return self.Conditions
end

function CompoundTask:AddCondition(condition)
    table.insert(self.Conditions, condition)
    return self
end

function CompoundTask:GetSubtasks()
    return self.Subtasks
end

function CompoundTask:AddSubtask(subtask)
    table.insert(self.Subtasks, subtask)
    return self
end

function CompoundTask:Decompose(ctx, startIndex)
    if ctx.LogDecomposition then
        ctx.CurrentDecompositionDepth = ctx.CurrentDecompositionDepth + 1
    end

    local status, result = self:OnDecompose(ctx, startIndex)
    
    if ctx.LogDecomposition then
        ctx.CurrentDecompositionDepth = ctx.CurrentDecompositionDepth - 1
    end

    return status, result
end

function CompoundTask:OnDecompose(ctx, startIndex)
    error("OnDecompose method not implemented")
end

function CompoundTask:OnDecomposeTask(ctx, task, taskIndex, oldStackDepth)
    error("OnDecomposeTask method not implemented")
end

function CompoundTask:OnDecomposePrimitiveTask(ctx, task, taskIndex, oldStackDepth)
    error("OnDecomposePrimitiveTask method not implemented")
end

function CompoundTask:OnDecomposeCompoundTask(ctx, task, taskIndex, oldStackDepth)
    error("OnDecomposeCompoundTask method not implemented")
end

function CompoundTask:OnDecomposeSlot(ctx, task, taskIndex, oldStackDepth)
    error("OnDecomposeSlot method not implemented")
end

function CompoundTask:IsValid(ctx)
    for _, condition in ipairs(self.Conditions) do
        local result = condition:IsValid(ctx)
        
        if ctx.LogDecomposition then
            self:Log(ctx, string.format("CompoundTask.IsValid:%s:%s is%s valid!", result and "Success" or "Failed", condition:GetName(), result and "" or " not"), result and ConsoleColor.DarkGreen or ConsoleColor.DarkRed)
        end

        if not result then
            return false
        end
    end

    return true
end

function CompoundTask:OnIsValidFailed(ctx)
    return DecompositionStatus.Failed
end

function CompoundTask:Log(ctx, description, color)
    ctx:Log(self.Name, description, ctx.CurrentDecompositionDepth, self, color)
end

return CompoundTask
