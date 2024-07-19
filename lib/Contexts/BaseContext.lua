-- Import necessary modules
local ContextState = require("lib.Contexts.IContext").ContextState
local PartialPlanEntry = require("lib.Contexts.IContext").PartialPlanEntry

local EffectType = require("lib.Effects.EffectType")

-- Define the BaseContext class
local BaseContext = {}
BaseContext.__index = BaseContext

function BaseContext:New(factory, plannerState)
    local instance = setmetatable({}, BaseContext)
    instance.IsInitialized = false
    instance.IsDirty = false
    instance.ContextState = ContextState.Executing
    instance.CurrentDecompositionDepth = 0
    instance.Factory = factory
    instance.PlannerState = plannerState
    instance.MethodTraversalRecord = {}
    instance.LastMTR = {}
    instance.MTRDebug = {}
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

function BaseContext:Init()
    if not self.WorldStateChangeStack then
        self.WorldStateChangeStack = {}
        for i = 1, #self.WorldState do
            self.WorldStateChangeStack[i] = {}
        end
    end

    if self.DebugMTR then
        if not self.MTRDebug then
            self.MTRDebug = {}
        end

        if not self.LastMTRDebug then
            self.LastMTRDebug = {}
        end
    end

    if self.LogDecomposition then
        if not self.DecompositionLog then
            self.DecompositionLog = {}
        end
    end

    self.IsInitialized = true
end

function BaseContext:HasState(state, value)
    return self:GetState(state) == value
end

function BaseContext:GetState(state)
    if self.ContextState == ContextState.Executing then
        return self.WorldState[state]
    end

    if #self.WorldStateChangeStack[state] == 0 then
        return self.WorldState[state]
    end

    return self.WorldStateChangeStack[state][#self.WorldStateChangeStack[state]].Value
end

function BaseContext:SetState(state, value, setAsDirty, e)
    setAsDirty = setAsDirty or true
    e = e or EffectType.Permanent

    if self.ContextState == ContextState.Executing then
        if self.WorldState[state] == value then
            return
        end

        self.WorldState[state] = value
        if setAsDirty then
            self.IsDirty = true
        end
    else
        table.insert(self.WorldStateChangeStack[state], {e, value})
    end
end

function BaseContext:GetWorldStateChangeDepth(factory)
    local stackDepth = factory:CreateArray(#self.WorldStateChangeStack)

    for i = 1, #self.WorldStateChangeStack do
        stackDepth[i] = #self.WorldStateChangeStack[i]
    end

    return stackDepth
end

function BaseContext:TrimForExecution()
    if self.ContextState == ContextState.Executing then
        error("Cannot trim a context when in execution mode")
    end

    for _, stack in ipairs(self.WorldStateChangeStack) do
        while #stack ~= 0 and stack[#stack].Key ~= EffectType.Permanent do
            table.remove(stack)
        end
    end
end

function BaseContext:TrimToStackDepth(stackDepth)
    if self.ContextState == ContextState.Executing then
        error("Cannot trim a context when in execution mode")
    end

    for i = 1, #stackDepth do
        local stack = self.WorldStateChangeStack[i]
        while #stack > stackDepth[i] do
            table.remove(stack)
        end
    end
end

function BaseContext:Reset()
    self.MethodTraversalRecord = {}
    self.LastMTR = {}

    if self.DebugMTR then
        self.MTRDebug = {}
        self.LastMTRDebug = {}
    end

    self.IsInitialized = false
end

function BaseContext:Log(name, description, depth, entry, color)
    if not self.LogDecomposition then
        return
    end

    table.insert(self.DecompositionLog, {
        Name = name,
        Description = description,
        Entry = entry,
        Depth = depth,
        Color = color
    })
end

return BaseContext
