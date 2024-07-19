-- PausePlanTask.lua
local ITask = require("lib.Tasks.ITask")
local DecompositionStatus = require("lib.Tasks.CompoundTasks.DecompositionStatus")
local ConsoleColor = { Green = "green" } -- Simulating ConsoleColor

local PausePlanTask = setmetatable({}, ITask)
PausePlanTask.__index = PausePlanTask

function PausePlanTask:New(name)
    local instance = setmetatable({}, PausePlanTask)
    instance.Name = name or ""
    instance.Parent = nil
    instance.Conditions = nil
    instance.Effects = nil
    return instance
end

function PausePlanTask:GetName()
    return self.Name
end

function PausePlanTask:SetName(name)
    self.Name = name
end

function PausePlanTask:GetParent()
    return self.Parent
end

function PausePlanTask:SetParent(parent)
    self.Parent = parent
end

function PausePlanTask:GetConditions()
    return self.Conditions
end

function PausePlanTask:AddCondition(condition)
    error("Pause Plan tasks do not support conditions.")
end

function PausePlanTask:AddEffect(effect)
    error("Pause Plan tasks do not support effects.")
end

function PausePlanTask:ApplyEffects(ctx)
    -- No effects to apply
end

function PausePlanTask:IsValid(ctx)
    if ctx.LogDecomposition then
        self:Log(ctx, "PausePlanTask.IsValid:Success!")
    end
    return true
end

function PausePlanTask:OnIsValidFailed(ctx)
    return DecompositionStatus.Failed
end

function PausePlanTask:Log(ctx, description)
    ctx:Log(self.Name, description, ctx.CurrentDecompositionDepth, self, ConsoleColor.Green)
end

return PausePlanTask
