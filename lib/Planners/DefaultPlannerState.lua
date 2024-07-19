-- DefaultPlannerState.lua
local IPlannerState = require("lib.Planners.IPlannerState")
local DefaultPlannerState = setmetatable({}, IPlannerState)
DefaultPlannerState.__index = DefaultPlannerState

function DefaultPlannerState:New()
    local instance = setmetatable({}, DefaultPlannerState)
    instance.CurrentTask = nil
    instance.Plan = {}
    instance.LastStatus = nil

    instance.OnNewPlan = nil
    instance.OnReplacePlan = nil
    instance.OnNewTask = nil
    instance.OnNewTaskConditionFailed = nil
    instance.OnStopCurrentTask = nil
    instance.OnCurrentTaskCompletedSuccessfully = nil
    instance.OnApplyEffect = nil
    instance.OnCurrentTaskFailed = nil
    instance.OnCurrentTaskContinues = nil
    instance.OnCurrentTaskExecutingConditionFailed = nil

    return instance
end

function DefaultPlannerState:GetCurrentTask()
    return self.CurrentTask
end

function DefaultPlannerState:SetCurrentTask(task)
    self.CurrentTask = task
end

function DefaultPlannerState:GetPlan()
    return self.Plan
end

function DefaultPlannerState:SetPlan(plan)
    self.Plan = plan
end

function DefaultPlannerState:GetLastStatus()
    return self.LastStatus
end

function DefaultPlannerState:SetLastStatus(status)
    self.LastStatus = status
end

function DefaultPlannerState:SetOnNewPlan(callback)
    self.OnNewPlan = callback
end

function DefaultPlannerState:SetOnReplacePlan(callback)
    self.OnReplacePlan = callback
end

function DefaultPlannerState:SetOnNewTask(callback)
    self.OnNewTask = callback
end

function DefaultPlannerState:SetOnNewTaskConditionFailed(callback)
    self.OnNewTaskConditionFailed = callback
end

function DefaultPlannerState:SetOnStopCurrentTask(callback)
    self.OnStopCurrentTask = callback
end

function DefaultPlannerState:SetOnCurrentTaskCompletedSuccessfully(callback)
    self.OnCurrentTaskCompletedSuccessfully = callback
end

function DefaultPlannerState:SetOnApplyEffect(callback)
    self.OnApplyEffect = callback
end

function DefaultPlannerState:SetOnCurrentTaskFailed(callback)
    self.OnCurrentTaskFailed = callback
end

function DefaultPlannerState:SetOnCurrentTaskContinues(callback)
    self.OnCurrentTaskContinues = callback
end

function DefaultPlannerState:SetOnCurrentTaskExecutingConditionFailed(callback)
    self.OnCurrentTaskExecutingConditionFailed = callback
end

return DefaultPlannerState
