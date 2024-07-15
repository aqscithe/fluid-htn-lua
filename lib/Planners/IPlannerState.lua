-- IPlannerState.lua
local IPlannerState = {}
IPlannerState.__index = IPlannerState

function IPlannerState:New()
    local instance = setmetatable({}, IPlannerState)
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

function IPlannerState:GetCurrentTask()
    return self.CurrentTask
end

function IPlannerState:SetCurrentTask(task)
    self.CurrentTask = task
end

function IPlannerState:GetPlan()
    return self.Plan
end

function IPlannerState:SetPlan(plan)
    self.Plan = plan
end

function IPlannerState:GetLastStatus()
    return self.LastStatus
end

function IPlannerState:SetLastStatus(status)
    self.LastStatus = status
end

function IPlannerState:SetOnNewPlan(callback)
    self.OnNewPlan = callback
end

function IPlannerState:SetOnReplacePlan(callback)
    self.OnReplacePlan = callback
end

function IPlannerState:SetOnNewTask(callback)
    self.OnNewTask = callback
end

function IPlannerState:SetOnNewTaskConditionFailed(callback)
    self.OnNewTaskConditionFailed = callback
end

function IPlannerState:SetOnStopCurrentTask(callback)
    self.OnStopCurrentTask = callback
end

function IPlannerState:SetOnCurrentTaskCompletedSuccessfully(callback)
    self.OnCurrentTaskCompletedSuccessfully = callback
end

function IPlannerState:SetOnApplyEffect(callback)
    self.OnApplyEffect = callback
end

function IPlannerState:SetOnCurrentTaskFailed(callback)
    self.OnCurrentTaskFailed = callback
end

function IPlannerState:SetOnCurrentTaskContinues(callback)
    self.OnCurrentTaskContinues = callback
end

function IPlannerState:SetOnCurrentTaskExecutingConditionFailed(callback)
    self.OnCurrentTaskExecutingConditionFailed = callback
end

return IPlannerState
