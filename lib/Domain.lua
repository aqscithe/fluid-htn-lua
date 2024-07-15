-- Importing the required modules
local TaskRoot = require("lib.Tasks.CompoundTasks.TaskRoot")
local DecompositionStatus = require("lib.Tasks.CompoundTasks.DecompositionStatus")
local ContextState = require("lib.Contexts.IContext").ContextState

-- Define the Domain class
local Domain = {}
Domain.__index = Domain

-- Constructor
function Domain:New(name)
    local instance = setmetatable({}, Domain)
    instance._slots = nil
    instance.Root = TaskRoot:New()
    instance.Root.Name = name
    instance.Root.Parent = nil
    return instance
end

-- Add a subtask to a parent compound task
function Domain:Add(parent, subtask)
    if parent == subtask then
        error("Parent-task and Sub-task can't be the same instance!")
    end
    parent:AddSubtask(subtask)
    subtask.Parent = parent
end

-- Add a slot to a parent compound task
function Domain:AddSlot(parent, slot)
    if parent == slot then
        error("Parent-task and Sub-task can't be the same instance!")
    end

    if self._slots and self._slots[slot.SlotId] then
        error("This slot id already exists in the domain definition!")
    end

    parent:AddSubtask(slot)
    slot.Parent = parent

    if not self._slots then
        self._slots = {}
    end

    self._slots[slot.SlotId] = slot
end

-- Find a plan
function Domain:FindPlan(ctx)
    if not ctx.IsInitialized then
        error("Context was not initialized!")
    end

    if not ctx.MethodTraversalRecord then
        error("We require the Method Traversal Record to have a valid instance.")
    end

    ctx.ContextState = ContextState.Planning

    local plan = nil
    local status = DecompositionStatus.Rejected

    if ctx.HasPausedPartialPlan and #ctx.LastMTR == 0 then
        status = self:OnPausedPartialPlan(ctx, plan, status)
    else
        status = self:OnReplanDuringPartialPlanning(ctx, plan, status)
    end

    if self:HasFoundSamePlan(ctx) then
        plan = nil
        status = DecompositionStatus.Rejected
    end

    if self:HasDecompositionSucceeded(status) then
        self:ApplyPermanentWorldStateStackChanges(ctx)
    else
        self:ClearWorldStateStackChanges(ctx)
    end

    ctx.ContextState = ContextState.Executing
    return status, plan
end

-- Replan during partial planning
function Domain:OnReplanDuringPartialPlanning(ctx, plan, status)
    local lastPartialPlanQueue = self:CacheLastPartialPlan(ctx)

    self:ClearMethodTraversalRecord(ctx)

    status = self.Root:Decompose(ctx, 0, plan)

    if self:HasDecompositionFailed(status) then
        self:RestoreLastPartialPlan(ctx, lastPartialPlanQueue, status)
    end

    return status
end

-- Cache the last partial plan
function Domain:CacheLastPartialPlan(ctx)
    if not ctx.HasPausedPartialPlan then
        return nil
    end

    ctx.HasPausedPartialPlan = false
    local lastPartialPlanQueue = ctx.Factory:CreateQueue()

    while #ctx.PartialPlanQueue > 0 do
        table.insert(lastPartialPlanQueue, table.remove(ctx.PartialPlanQueue, 1))
    end

    return lastPartialPlanQueue
end

-- Restore the last partial plan
function Domain:RestoreLastPartialPlan(ctx, lastPartialPlanQueue, status)
    if not lastPartialPlanQueue then
        return
    end

    ctx.HasPausedPartialPlan = true
    ctx.PartialPlanQueue = {}

    while #lastPartialPlanQueue > 0 do
        table.insert(ctx.PartialPlanQueue, table.remove(lastPartialPlanQueue, 1))
    end

    ctx.Factory:FreeQueue(lastPartialPlanQueue)
end

-- Clear the method traversal record
function Domain:ClearMethodTraversalRecord(ctx)
    ctx.MethodTraversalRecord = {}

    if ctx.DebugMTR then
        ctx.MTRDebug = {}
    end
end

-- Check if decomposition failed
function Domain:HasDecompositionFailed(status)
    return status == DecompositionStatus.Rejected or status == DecompositionStatus.Failed
end

-- Check if decomposition succeeded
function Domain:HasDecompositionSucceeded(status)
    return status == DecompositionStatus.Succeeded or status == DecompositionStatus.Partial
end

-- Handle paused partial plan
function Domain:OnPausedPartialPlan(ctx, plan, status)
    ctx.HasPausedPartialPlan = false

    while #ctx.PartialPlanQueue > 0 do
        local kvp = table.remove(ctx.PartialPlanQueue, 1)
        if not plan then
            status = kvp.Task:Decompose(ctx, kvp.TaskIndex, plan)
        else
            status = kvp.Task:Decompose(ctx, kvp.TaskIndex, subPlan)
            if self:HasDecompositionSucceeded(status) then
                self:EnqueueToExistingPlan(plan, subPlan)
            end
        end

        if ctx.HasPausedPartialPlan then
            break
        end
    end

    if self:HasDecompositionFailed(status) then
        self:ClearMethodTraversalRecord(ctx)
        status = self.Root:Decompose(ctx, 0, plan)
    end

    return status
end

-- Enqueue sub-plan to the existing plan
function Domain:EnqueueToExistingPlan(plan, subPlan)
    while #subPlan > 0 do
        table.insert(plan, table.remove(subPlan, 1))
    end
end

-- Check if the same plan was found
function Domain:HasFoundSamePlan(ctx)
    local isMTRsEqual = #ctx.MethodTraversalRecord == #ctx.LastMTR
    if isMTRsEqual then
        for i = 1, #ctx.MethodTraversalRecord do
            if ctx.MethodTraversalRecord[i] < ctx.LastMTR[i] then
                isMTRsEqual = false
                break
            end
        end

        return isMTRsEqual
    end

    return false
end

-- Apply permanent world state stack changes
function Domain:ApplyPermanentWorldStateStackChanges(ctx)
    ctx:TrimForExecution()

    for i = 1, #ctx.WorldStateChangeStack do
        local stack = ctx.WorldStateChangeStack[i]
        if stack and #stack > 0 then
            ctx.WorldState[i] = stack[#stack].Value
            stack = {}
        end
    end
end

-- Clear world state stack changes
function Domain:ClearWorldStateStackChanges(ctx)
    for _, stack in ipairs(ctx.WorldStateChangeStack) do
        if stack and #stack > 0 then
            stack = {}
        end
    end
end

-- Try to set a slot domain
function Domain:TrySetSlotDomain(slotId, subDomain)
    if self._slots and self._slots[slotId] then
        return self._slots[slotId]:Set(subDomain.Root)
    end
    return false
end

-- Clear a slot
function Domain:ClearSlot(slotId)
    if self._slots and self._slots[slotId] then
        self._slots[slotId]:Clear()
    end
end

return Domain
