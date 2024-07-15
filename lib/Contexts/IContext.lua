-- Define ContextState enum
local ContextState = {
    Planning = 1,
    Executing = 2
}

-- Define PartialPlanEntry structure
local PartialPlanEntry = {}
PartialPlanEntry.__index = PartialPlanEntry

function PartialPlanEntry:New(task, taskIndex)
    local instance = setmetatable({}, PartialPlanEntry)
    instance.Task = task
    instance.TaskIndex = taskIndex
    return instance
end

-- Define the IContext interface
local IContext = {}
IContext.__index = IContext

function IContext:New(factory, plannerState)
    local instance = setmetatable({}, IContext)
    instance.IsInitialized = false
    instance.IsDirty = false
    instance.ContextState = ContextState.Planning
    instance.CurrentDecompositionDepth = 0
    instance.Factory = factory
    instance.PlannerState = plannerState
    instance.MethodTraversalRecord = {}
    instance.MTRDebug = {}
    instance.LastMTR = {}
    instance.LastMTRDebug = {}
    instance.DebugMTR = false
    instance.DecompositionLog = {}
    instance.LogDecomposition = false
    instance.PartialPlanQueue = {}
    instance.HasPausedPartialPlan = false
    instance.WorldState = {}
    instance.WorldStateChangeStack = {}
    return instance
end

function IContext:Reset()
    -- Reset the context state to default values
end

function IContext:TrimForExecution()
    -- Trim for execution logic
end

function IContext:TrimToStackDepth(stackDepth)
    -- Trim to stack depth logic
end

function IContext:HasState(state, value)
    -- Check if has state logic
end

function IContext:GetState(state)
    -- Get state logic
end

function IContext:SetState(state, value, setAsDirty, e)
    -- Set state logic
end

function IContext:GetWorldStateChangeDepth(factory)
    -- Get world state change depth logic
end

function IContext:Log(name, description, depth, task, color)
    -- Log task logic
end

function IContext:LogCondition(name, description, depth, condition, color)
    -- Log condition logic
end

function IContext:LogEffect(name, description, depth, effect, color)
    -- Log effect logic
end

return {
    ContextState = ContextState,
    PartialPlanEntry = PartialPlanEntry,
    IContext = IContext
}
