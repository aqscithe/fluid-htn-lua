-- Sequence.lua
local CompoundTask = require("lib.Tasks.CompoundTasks.CompoundTask")
local DecompositionStatus = require("lib.Tasks.CompoundTasks.DecompositionStatus")
local ConsoleColor = { Red = "red", Green = "green", Blue = "blue", DarkBlue = "darkblue" }

local Sequence = setmetatable({}, CompoundTask)
Sequence.__index = Sequence

function Sequence:New()
    local instance = setmetatable(CompoundTask:New(), Sequence)
    instance.Plan = {}
    return instance
end

function Sequence:IsValid(ctx)
    if not CompoundTask.IsValid(self, ctx) then
        if ctx.LogDecomposition then
            self:Log(ctx, "Sequence.IsValid:Failed:Preconditions not met!", ConsoleColor.Red)
        end
        return false
    end

    if #self.Subtasks == 0 then
        if ctx.LogDecomposition then
            self:Log(ctx, "Sequence.IsValid:Failed:No sub-tasks!", ConsoleColor.Red)
        end
        return false
    end

    if ctx.LogDecomposition then
        self:Log(ctx, "Sequence.IsValid:Success!", ConsoleColor.Green)
    end

    return true
end

function Sequence:OnDecompose(ctx, startIndex, result)
    self.Plan = {}

    local oldStackDepth = ctx:GetWorldStateChangeDepth(ctx.Factory)

    for taskIndex = startIndex, #self.Subtasks do
        local task = self.Subtasks[taskIndex]
        if ctx.LogDecomposition then
            self:Log(ctx, "Sequence.OnDecompose:Task index: " .. taskIndex .. ": " .. (task and task.Name or ""))
        end

        local status = self:OnDecomposeTask(ctx, task, taskIndex, oldStackDepth, result)
        if status == DecompositionStatus.Rejected or status == DecompositionStatus.Failed or status == DecompositionStatus.Partial then
            ctx.Factory:FreeArray(oldStackDepth)
            return status
        end
    end

    ctx.Factory:FreeArray(oldStackDepth)

    result = self.Plan
    return #result == 0 and DecompositionStatus.Failed or DecompositionStatus.Succeeded
end

function Sequence:OnDecomposeTask(ctx, task, taskIndex, oldStackDepth, result)
    if not task:IsValid(ctx) then
        if ctx.LogDecomposition then
            self:Log(ctx, "Sequence.OnDecomposeTask:Failed:Task " .. task.Name .. ".IsValid returned false!", ConsoleColor.Red)
        end
        self.Plan = {}
        ctx:TrimToStackDepth(oldStackDepth)
        result = self.Plan
        return task:OnIsValidFailed(ctx)
    end

    if task.Decompose then
        return self:OnDecomposeCompoundTask(ctx, task, taskIndex, oldStackDepth, result)
    elseif task.ApplyEffects then
        self:OnDecomposePrimitiveTask(ctx, task, taskIndex, oldStackDepth, result)
    elseif task.Set then
        return self:OnDecomposeSlot(ctx, task, taskIndex, oldStackDepth, result)
    elseif task.PausePlanTask then
        if ctx.LogDecomposition then
            self:Log(ctx, "Sequence.OnDecomposeTask:Return partial plan at index " .. taskIndex .. "!", ConsoleColor.DarkBlue)
        end
        ctx.HasPausedPartialPlan = true
        ctx.PartialPlanQueue[#ctx.PartialPlanQueue + 1] = { Task = self, TaskIndex = taskIndex + 1 }
        result = self.Plan
        return DecompositionStatus.Partial
    end

    result = self.Plan
    local s = #result == 0 and DecompositionStatus.Failed or DecompositionStatus.Succeeded

    if ctx.LogDecomposition then
        self:Log(ctx, "Sequence.OnDecomposeTask:" .. tostring(s) .. "!", s == DecompositionStatus.Succeeded and ConsoleColor.Green or ConsoleColor.Red)
    end

    return s
end

function Sequence:OnDecomposePrimitiveTask(ctx, task, taskIndex, oldStackDepth, result)
    if ctx.LogDecomposition then
        self:Log(ctx, "Sequence.OnDecomposeTask:Pushed " .. task.Name .. " to plan!", ConsoleColor.Blue)
    end
    task:ApplyEffects(ctx)
    self.Plan[#self.Plan + 1] = task
    result = self.Plan
end

function Sequence:OnDecomposeCompoundTask(ctx, task, taskIndex, oldStackDepth, result)
    local status, subPlan = task:Decompose(ctx, 0, {})

    if status == DecompositionStatus.Rejected then
        if ctx.LogDecomposition then
            self:Log(ctx, "Sequence.OnDecomposeCompoundTask:" .. tostring(status) .. ": Decomposing " .. task.Name .. " was rejected.", ConsoleColor.Red)
        end
        self.Plan = {}
        ctx:TrimToStackDepth(oldStackDepth)
        result = nil
        return DecompositionStatus.Rejected
    elseif status == DecompositionStatus.Failed then
        if ctx.LogDecomposition then
            self:Log(ctx, "Sequence.OnDecomposeCompoundTask:" .. tostring(status) .. ": Decomposing " .. task.Name .. " failed.", ConsoleColor.Red)
        end
        self.Plan = {}
        ctx:TrimToStackDepth(oldStackDepth)
        result = self.Plan
        return DecompositionStatus.Failed
    end

    for _, p in ipairs(subPlan) do
        if ctx.LogDecomposition then
            self:Log(ctx, "Sequence.OnDecomposeCompoundTask:Decomposing " .. task.Name .. ":Pushed " .. p.Name .. " to plan!", ConsoleColor.Blue)
        end
        self.Plan[#self.Plan + 1] = p
    end

    if ctx.HasPausedPartialPlan then
        if ctx.LogDecomposition then
            self:Log(ctx, "Sequence.OnDecomposeCompoundTask:Return partial plan at index " .. taskIndex .. "!", ConsoleColor.DarkBlue)
        end
        if taskIndex < #self.Subtasks then
            ctx.PartialPlanQueue[#ctx.PartialPlanQueue + 1] = { Task = self, TaskIndex = taskIndex + 1 }
        end
        result = self.Plan
        return DecompositionStatus.Partial
    end

    result = self.Plan
    if ctx.LogDecomposition then
        self:Log(ctx, "Sequence.OnDecomposeCompoundTask:Succeeded!", ConsoleColor.Green)
    end
    return DecompositionStatus.Succeeded
end

function Sequence:OnDecomposeSlot(ctx, task, taskIndex, oldStackDepth, result)
    local status, subPlan = task:Decompose(ctx, 0, {})

    if status == DecompositionStatus.Rejected then
        if ctx.LogDecomposition then
            self:Log(ctx, "Sequence.OnDecomposeSlot:" .. tostring(status) .. ": Decomposing " .. task.Name .. " was rejected.", ConsoleColor.Red)
        end
        self.Plan = {}
        ctx:TrimToStackDepth(oldStackDepth)
        result = nil
        return DecompositionStatus.Rejected
    elseif status == DecompositionStatus.Failed then
        if ctx.LogDecomposition then
            self:Log(ctx, "Sequence.OnDecomposeSlot:" .. tostring(status) .. ": Decomposing " .. task.Name .. " failed.", ConsoleColor.Red)
        end
        self.Plan = {}
        ctx:TrimToStackDepth(oldStackDepth)
        result = self.Plan
        return DecompositionStatus.Failed
    end

    for _, p in ipairs(subPlan) do
        if ctx.LogDecomposition then
            self:Log(ctx, "Sequence.OnDecomposeSlot:Decomposing " .. task.Name .. ":Pushed " .. p.Name .. " to plan!", ConsoleColor.Blue)
        end
        self.Plan[#self.Plan + 1] = p
    end

    if ctx.HasPausedPartialPlan then
        if ctx.LogDecomposition then
            self:Log(ctx, "Sequence.OnDecomposeSlot:Return partial plan at index " .. taskIndex .. "!", ConsoleColor.DarkBlue)
        end
        if taskIndex < #self.Subtasks then
            ctx.PartialPlanQueue[#ctx.PartialPlanQueue + 1] = { Task = self, TaskIndex = taskIndex + 1 }
        end
        result = self.Plan
        return DecompositionStatus.Partial
    end

    result = self.Plan
    if ctx.LogDecomposition then
        self:Log(ctx, "Sequence.OnDecomposeSlot:Succeeded!", ConsoleColor.Green)
    end
    return DecompositionStatus.Succeeded
end

return Sequence
