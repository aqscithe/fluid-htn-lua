-- Selector.lua
local CompoundTask = require("CompoundTask")
local DecompositionStatus = require("DecompositionStatus")
local ConsoleColor = { Red = "red", Green = "green", Blue = "blue", DarkBlue = "darkblue" }

local Selector = setmetatable({}, CompoundTask)
Selector.__index = Selector

function Selector:New()
    local instance = setmetatable(CompoundTask:New(), Selector)
    instance.Plan = {}
    return instance
end

function Selector:IsValid(ctx)
    if not CompoundTask.IsValid(self, ctx) then
        if ctx.LogDecomposition then
            self:Log(ctx, "Selector.IsValid:Failed:Preconditions not met!", ConsoleColor.Red)
        end
        return false
    end

    if #self.Subtasks == 0 then
        if ctx.LogDecomposition then
            self:Log(ctx, "Selector.IsValid:Failed:No sub-tasks!", ConsoleColor.Red)
        end
        return false
    end

    if ctx.LogDecomposition then
        self:Log(ctx, "Selector.IsValid:Success!", ConsoleColor.Green)
    end

    return true
end

function Selector:BeatsLastMTR(ctx, taskIndex, currentDecompositionIndex)
    if ctx.LastMTR[currentDecompositionIndex] < taskIndex then
        for i = 1, #ctx.MethodTraversalRecord do
            local diff = ctx.MethodTraversalRecord[i] - ctx.LastMTR[i]
            if diff < 0 then
                return true
            end
            if diff > 0 then
                return false
            end
        end
        return false
    end
    return true
end

function Selector:OnDecompose(ctx, startIndex, result)
    self.Plan = {}

    for taskIndex = startIndex, #self.Subtasks do
        if ctx.LogDecomposition then
            self:Log(ctx, "Selector.OnDecompose:Task index: " .. taskIndex .. ": " .. (self.Subtasks[taskIndex] and self.Subtasks[taskIndex].Name or ""))
        end

        if ctx.LastMTR and #ctx.LastMTR > 0 then
            if #ctx.MethodTraversalRecord < #ctx.LastMTR then
                local currentDecompositionIndex = #ctx.MethodTraversalRecord + 1
                if not self:BeatsLastMTR(ctx, taskIndex, currentDecompositionIndex) then
                    ctx.MethodTraversalRecord[#ctx.MethodTraversalRecord + 1] = -1
                    if ctx.DebugMTR then
                        ctx.MTRDebug[#ctx.MTRDebug + 1] = "REPLAN FAIL " .. self.Subtasks[taskIndex].Name
                    end
                    if ctx.LogDecomposition then
                        self:Log(ctx, "Selector.OnDecompose:Rejected:Index " .. currentDecompositionIndex .. " is beat by last method traversal record!", ConsoleColor.Red)
                    end
                    result = nil
                    return DecompositionStatus.Rejected
                end
            end
        end

        local task = self.Subtasks[taskIndex]
        local status = self:OnDecomposeTask(ctx, task, taskIndex, nil, result)
        if status == DecompositionStatus.Rejected or status == DecompositionStatus.Succeeded or status == DecompositionStatus.Partial then
            return status
        end
    end

    result = self.Plan
    return #result == 0 and DecompositionStatus.Failed or DecompositionStatus.Succeeded
end

function Selector:OnDecomposeTask(ctx, task, taskIndex, oldStackDepth, result)
    if not task:IsValid(ctx) then
        if ctx.LogDecomposition then
            self:Log(ctx, "Selector.OnDecomposeTask:Failed:Task " .. task.Name .. ".IsValid returned false!", ConsoleColor.Red)
        end
        result = self.Plan
        return task:OnIsValidFailed(ctx)
    end

    if task.Decompose then
        return self:OnDecomposeCompoundTask(ctx, task, taskIndex, nil, result)
    elseif task.ApplyEffects then
        self:OnDecomposePrimitiveTask(ctx, task, taskIndex, nil, result)
    elseif task.Set then
        return self:OnDecomposeSlot(ctx, task, taskIndex, nil, result)
    end

    result = self.Plan
    local status = #result == 0 and DecompositionStatus.Failed or DecompositionStatus.Succeeded

    if ctx.LogDecomposition then
        self:Log(ctx, "Selector.OnDecomposeTask:" .. tostring(status) .. "!", status == DecompositionStatus.Succeeded and ConsoleColor.Green or ConsoleColor.Red)
    end

    return status
end

function Selector:OnDecomposePrimitiveTask(ctx, task, taskIndex, oldStackDepth, result)
    ctx.MethodTraversalRecord[#ctx.MethodTraversalRecord + 1] = taskIndex
    if ctx.DebugMTR then
        ctx.MTRDebug[#ctx.MTRDebug + 1] = task.Name
    end
    if ctx.LogDecomposition then
        self:Log(ctx, "Selector.OnDecomposeTask:Pushed " .. task.Name .. " to plan!", ConsoleColor.Blue)
    end

    task:ApplyEffects(ctx)
    self.Plan[#self.Plan + 1] = task
    result = self.Plan
end

function Selector:OnDecomposeCompoundTask(ctx, task, taskIndex, oldStackDepth, result)
    ctx.MethodTraversalRecord[#ctx.MethodTraversalRecord + 1] = taskIndex
    if ctx.DebugMTR then
        ctx.MTRDebug[#ctx.MTRDebug + 1] = task.Name
    end

    local status, subPlan = task:Decompose(ctx, 0, {})

    if status == DecompositionStatus.Rejected then
        if ctx.LogDecomposition then
            self:Log(ctx, "Selector.OnDecomposeCompoundTask:" .. tostring(status) .. ": Decomposing " .. task.Name .. " was rejected.", ConsoleColor.Red)
        end
        result = nil
        return DecompositionStatus.Rejected
    elseif status == DecompositionStatus.Failed then
        ctx.MethodTraversalRecord[#ctx.MethodTraversalRecord] = nil
        if ctx.DebugMTR then
            ctx.MTRDebug[#ctx.MTRDebug] = nil
        end
        if ctx.LogDecomposition then
            self:Log(ctx, "Selector.OnDecomposeCompoundTask:" .. tostring(status) .. ": Decomposing " .. task.Name .. " failed.", ConsoleColor.Red)
        end
        result = self.Plan
        return DecompositionStatus.Failed
    end

    for _, p in ipairs(subPlan) do
        if ctx.LogDecomposition then
            self:Log(ctx, "Selector.OnDecomposeCompoundTask:Decomposing " .. task.Name .. ":Pushed " .. p.Name .. " to plan!", ConsoleColor.Blue)
        end
        self.Plan[#self.Plan + 1] = p
    end

    if ctx.HasPausedPartialPlan then
        if ctx.LogDecomposition then
            self:Log(ctx, "Selector.OnDecomposeCompoundTask:Return partial plan at index " .. taskIndex .. "!", ConsoleColor.DarkBlue)
        end
        result = self.Plan
        return DecompositionStatus.Partial
    end

    result = self.Plan
    local s = #result == 0 and DecompositionStatus.Failed or DecompositionStatus.Succeeded
    if ctx.LogDecomposition then
        self:Log(ctx, "Selector.OnDecomposeCompoundTask:" .. tostring(s) .. "!", s == DecompositionStatus.Succeeded and ConsoleColor.Green or ConsoleColor.Red)
    end
    return s
end

function Selector:OnDecomposeSlot(ctx, task, taskIndex, oldStackDepth, result)
    ctx.MethodTraversalRecord[#ctx.MethodTraversalRecord + 1] = taskIndex
    if ctx.DebugMTR then
        ctx.MTRDebug[#ctx.MTRDebug + 1] = task.Name
    end

    local status, subPlan = task:Decompose(ctx, 0, {})

    if status == DecompositionStatus.Rejected then
        if ctx.LogDecomposition then
            self:Log(ctx, "Selector.OnDecomposeSlot:" .. tostring(status) .. ": Decomposing " .. task.Name .. " was rejected.", ConsoleColor.Red)
        end
        result = nil
        return DecompositionStatus.Rejected
    elseif status == DecompositionStatus.Failed then
        ctx.MethodTraversalRecord[#ctx.MethodTraversalRecord] = nil
        if ctx.DebugMTR then
            ctx.MTRDebug[#ctx.MTRDebug] = nil
        end
        if ctx.LogDecomposition then
            self:Log(ctx, "Selector.OnDecomposeSlot:" .. tostring(status) .. ": Decomposing " .. task.Name .. " failed.", ConsoleColor.Red)
        end
        result = self.Plan
        return DecompositionStatus.Failed
    end

    for _, p in ipairs(subPlan) do
        if ctx.LogDecomposition then
            self:Log(ctx, "Selector.OnDecomposeSlot:Decomposing " .. task.Name .. ":Pushed " .. p.Name .. " to plan!", ConsoleColor.Blue)
        end
        self.Plan[#self.Plan + 1] = p
    end

    if ctx.HasPausedPartialPlan then
        if ctx.LogDecomposition then
            self:Log(ctx, "Selector.OnDecomposeSlot:Return partial plan!", ConsoleColor.DarkBlue)
        end
        result = self.Plan
        return DecompositionStatus.Partial
    end

    result = self.Plan
    local s = #result == 0 and DecompositionStatus.Failed or DecompositionStatus.Succeeded
    if ctx.LogDecomposition then
        self:Log(ctx, "Selector.OnDecomposeSlot:" .. tostring(s) .. "!", s == DecompositionStatus.Succeeded and ConsoleColor.Green or ConsoleColor.Red)
    end
    return s
end

return Selector
