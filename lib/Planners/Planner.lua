-- Planner.lua
local Planner = {}
Planner.__index = Planner

local DecompositionStatus = require("lib.Tasks.CompoundTasks.DecompositionStatus")
local TaskStatus = require("lib.Tasks.TaskStatus")

function Planner:New()
    local instance = setmetatable({}, Planner)
    return instance
end

function Planner:Tick(domain, ctx, allowImmediateReplan)
    if not ctx.IsInitialized then
        error("Context was not initialized!")
    end

    local decompositionStatus = DecompositionStatus.Failed
    local isTryingToReplacePlan = false
    
    if self:ShouldFindNewPlan(ctx) then
        isTryingToReplacePlan = self:TryFindNewPlan(domain, ctx, decompositionStatus)
    end

    if self:CanSelectNextTaskInPlan(ctx) then
        if not self:SelectNextTaskInPlan(domain, ctx) then
            return
        end
    end

    local task = ctx.PlannerState.CurrentTask
    if task and task.Operator then
        if not self:TryTickPrimitiveTaskOperator(domain, ctx, task, allowImmediateReplan) then
            return
        end
    end

    if self:HasFailedToFindPlan(isTryingToReplacePlan, decompositionStatus, ctx) then
        ctx.PlannerState.LastStatus = TaskStatus.Failure
    end
end

function Planner:ShouldFindNewPlan(ctx)
    return ctx.IsDirty or (not ctx.PlannerState.CurrentTask and #ctx.PlannerState.Plan == 0)
end

function Planner:TryFindNewPlan(domain, ctx, decompositionStatus)
    local lastPartialPlanQueue = self:PrepareDirtyWorldStateForReplan(ctx)
    local isTryingToReplacePlan = #ctx.PlannerState.Plan > 0

    local newPlan = nil  -- Define newPlan before its usage
    decompositionStatus = domain:FindPlan(ctx, newPlan)

    if self:HasFoundNewPlan(decompositionStatus) then
        self:OnFoundNewPlan(ctx, newPlan)
    elseif lastPartialPlanQueue then
        self:RestoreLastPartialPlan(ctx, lastPartialPlanQueue)
        self:RestoreLastMethodTraversalRecord(ctx)
    end

    return isTryingToReplacePlan
end


function Planner:PrepareDirtyWorldStateForReplan(ctx)
    if not ctx.IsDirty then
        return nil
    end

    ctx.IsDirty = false
    local lastPartialPlan = self:CacheLastPartialPlan(ctx)
    if not lastPartialPlan then
        return nil
    end

    self:CopyMtrToLastMtr(ctx)
    return lastPartialPlan
end

function Planner:CacheLastPartialPlan(ctx)
    if not ctx.HasPausedPartialPlan then
        return nil
    end

    ctx.HasPausedPartialPlan = false
    local lastPartialPlanQueue = ctx.Factory:CreateQueue()

    while #ctx.PartialPlanQueue > 0 do
        lastPartialPlanQueue[#lastPartialPlanQueue + 1] = table.remove(ctx.PartialPlanQueue, 1)
    end

    return lastPartialPlanQueue
end

function Planner:RestoreLastPartialPlan(ctx, lastPartialPlanQueue)
    ctx.HasPausedPartialPlan = true
    ctx.PartialPlanQueue = {}

    while #lastPartialPlanQueue > 0 do
        ctx.PartialPlanQueue[#ctx.PartialPlanQueue + 1] = table.remove(lastPartialPlanQueue, 1)
    end

    ctx.Factory:FreeQueue(lastPartialPlanQueue)
end

function Planner:HasFoundNewPlan(decompositionStatus)
    return decompositionStatus == DecompositionStatus.Succeeded or decompositionStatus == DecompositionStatus.Partial
end

function Planner:OnFoundNewPlan(ctx, newPlan)
    if ctx.PlannerState.OnReplacePlan and (#ctx.PlannerState.Plan > 0 or ctx.PlannerState.CurrentTask) then
        ctx.PlannerState.OnReplacePlan(ctx.PlannerState.Plan, ctx.PlannerState.CurrentTask, newPlan)
    elseif ctx.PlannerState.OnNewPlan and #ctx.PlannerState.Plan == 0 then
        ctx.PlannerState.OnNewPlan(newPlan)
    end

    ctx.PlannerState.Plan = {}
    while #newPlan > 0 do
        ctx.PlannerState.Plan[#ctx.PlannerState.Plan + 1] = table.remove(newPlan, 1)
    end

    if ctx.PlannerState.CurrentTask and ctx.PlannerState.CurrentTask.Stop then
        ctx.PlannerState.OnStopCurrentTask(ctx.PlannerState.CurrentTask)
        ctx.PlannerState.CurrentTask:Stop(ctx)
        ctx.PlannerState.CurrentTask = nil
    end

    self:CopyMtrToLastMtr(ctx)
end

function Planner:CopyMtrToLastMtr(ctx)
    if ctx.MethodTraversalRecord then
        ctx.LastMTR = {}
        for _, record in ipairs(ctx.MethodTraversalRecord) do
            ctx.LastMTR[#ctx.LastMTR + 1] = record
        end

        if ctx.DebugMTR then
            ctx.LastMTRDebug = {}
            for _, record in ipairs(ctx.MTRDebug) do
                ctx.LastMTRDebug[#ctx.LastMTRDebug + 1] = record
            end
        end
    end
end

function Planner:RestoreLastMethodTraversalRecord(ctx)
    if #ctx.LastMTR > 0 then
        ctx.MethodTraversalRecord = {}
        for _, record in ipairs(ctx.LastMTR) do
            ctx.MethodTraversalRecord[#ctx.MethodTraversalRecord + 1] = record
        end
        ctx.LastMTR = {}

        if not ctx.DebugMTR then
            return
        end

        ctx.MTRDebug = {}
        for _, record in ipairs(ctx.LastMTRDebug) do
            ctx.MTRDebug[#ctx.MTRDebug + 1] = record
        end
        ctx.LastMTRDebug = {}
    end
end

function Planner:CanSelectNextTaskInPlan(ctx)
    return not ctx.PlannerState.CurrentTask and #ctx.PlannerState.Plan > 0
end

function Planner:SelectNextTaskInPlan(domain, ctx)
    ctx.PlannerState.CurrentTask = table.remove(ctx.PlannerState.Plan, 1)
    if ctx.PlannerState.CurrentTask then
        ctx.PlannerState.OnNewTask(ctx.PlannerState.CurrentTask)
        return self:IsConditionsValid(ctx)
    end
    return true
end

function Planner:TryTickPrimitiveTaskOperator(domain, ctx, task, allowImmediateReplan)
    if task.Operator then
        if not self:IsExecutingConditionsValid(domain, ctx, task, allowImmediateReplan) then
            return false
        end

        ctx.PlannerState.LastStatus = task.Operator:Update(ctx)

        if ctx.PlannerState.LastStatus == TaskStatus.Success then
            self:OnOperatorFinishedSuccessfully(domain, ctx, task, allowImmediateReplan)
            return true
        end

        if ctx.PlannerState.LastStatus == TaskStatus.Failure then
            self:FailEntirePlan(ctx, task)
            return true
        end

        ctx.PlannerState.OnCurrentTaskContinues(task)
        return true
    end

    task:Aborted(ctx)
    ctx.PlannerState.CurrentTask = nil
    ctx.PlannerState.LastStatus = TaskStatus.Failure
    return true
end

function Planner:IsConditionsValid(ctx)
    for _, condition in ipairs(ctx.PlannerState.CurrentTask.Conditions) do
        if not condition:IsValid(ctx) then
            ctx.PlannerState.OnNewTaskConditionFailed(ctx.PlannerState.CurrentTask, condition)
            self:AbortTask(ctx, ctx.PlannerState.CurrentTask)
            return false
        end
    end
    return true
end

function Planner:IsExecutingConditionsValid(domain, ctx, task, allowImmediateReplan)
    for _, condition in ipairs(task.ExecutingConditions) do
        if not condition:IsValid(ctx) then
            ctx.PlannerState.OnCurrentTaskExecutingConditionFailed(task, condition)
            self:AbortTask(ctx, task)
            if allowImmediateReplan then
                self:Tick(domain, ctx, false)
            end
            return false
        end
    end
    return true
end

function Planner:AbortTask(ctx, task)
    task:Aborted(ctx)
    self:ClearPlanForReplan(ctx)
end

function Planner:OnOperatorFinishedSuccessfully(domain, ctx, task, allowImmediateReplan)
    ctx.PlannerState.OnCurrentTaskCompletedSuccessfully(task)
    for _, effect in ipairs(task.Effects) do
        if effect.Type == "PlanAndExecute" then
            ctx.PlannerState.OnApplyEffect(effect)
            effect:Apply(ctx)
        end
    end

    ctx.PlannerState.CurrentTask = nil
    if #ctx.PlannerState.Plan == 0 then
        ctx.LastMTR = {}

        if ctx.DebugMTR then
            ctx.LastMTRDebug = {}
        end

        ctx.IsDirty = false

        if allowImmediateReplan then
            self:Tick(domain, ctx, false)
        end
    end
end

function Planner:FailEntirePlan(ctx, task)
    ctx.PlannerState.OnCurrentTaskFailed(task)
    task:Aborted(ctx)
    self:ClearPlanForReplan(ctx)
end

function Planner:ClearPlanForReplan(ctx)
    ctx.PlannerState.CurrentTask = nil
    ctx.PlannerState.Plan = {}

    ctx.LastMTR = {}

    if ctx.DebugMTR then
        ctx.LastMTRDebug = {}
    end

    ctx.HasPausedPartialPlan = false
    ctx.PartialPlanQueue = {}
    ctx.IsDirty = false
end

function Planner:HasFailedToFindPlan(isTryingToReplacePlan, decompositionStatus, ctx)
    return not ctx.PlannerState.CurrentTask and #ctx.PlannerState.Plan == 0 and not isTryingToReplacePlan and
        (decompositionStatus == DecompositionStatus.Failed or decompositionStatus == DecompositionStatus.Rejected)
end

function Planner:Reset(ctx)
    ctx.PlannerState.Plan = {}

    if ctx.PlannerState.CurrentTask and ctx.PlannerState.CurrentTask.Stop then
        ctx.PlannerState.CurrentTask:Stop(ctx)
    end

    self:ClearPlanForReplan(ctx)
end

return Planner
