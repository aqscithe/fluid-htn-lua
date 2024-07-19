local BaseContext = require("lib.Contexts.BaseContext")
local DefaultFactory = require("lib.Factory.DefaultFactory")
local DefaultPlannerState = require("lib.Planners.DefaultPlannerState")


local MyWorldState = {
    HasA = 1,
    HasB = 2,
    HasC = 3,
}

local MyContext = setmetatable({}, { __index = BaseContext })
MyContext.__index = MyContext

function MyContext:New()
    local instance = setmetatable(BaseContext:New(), MyContext)
    
    instance.WorldState = {}
    for _, value in pairs(MyWorldState) do
        instance.WorldState[value] = 0
    end

    instance.Factory = DefaultFactory:New()
    instance.PlannerState = DefaultPlannerState:New()
    instance.MTRDebug = nil
    instance.LastMTRDebug = nil
    instance.DebugMTR = false
    instance.DecompositionLog = nil
    instance.LogDecomposition = false
    instance.Done = false
    return instance
end

function MyContext:HasState(state, value)
    return BaseContext.HasState(self, state, value)
end

function MyContext:SetState(state, value, effectType)
    BaseContext.SetState(self, state, value, true, effectType)
end

function MyContext:GetState(state)
    return BaseContext.GetState(self, state)
end

return MyContext
