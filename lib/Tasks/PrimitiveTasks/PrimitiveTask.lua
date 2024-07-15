-- PrimitiveTask.lua
local IPrimitiveTask = require("IPrimitiveTask")
local ContextState = require("lib.Contexts.IContext").ContextState
local DecompositionStatus = require("lib.Tasks.CompoundTasks.DecompositionStatus")

local PrimitiveTask = setmetatable({}, IPrimitiveTask)
PrimitiveTask.__index = PrimitiveTask

function PrimitiveTask:New(name)
    local instance = setmetatable({}, PrimitiveTask)
    instance.Name = name or ""
    instance.Parent = nil
    instance.Conditions = {}
    instance.ExecutingConditions = {}
    instance.Operator = nil
    instance.Effects = {}
    return instance
end

function PrimitiveTask:GetName()
    return self.Name
end

function PrimitiveTask:SetName(name)
    self.Name = name
end

function PrimitiveTask:GetParent()
    return self.Parent
end

function PrimitiveTask:SetParent(parent)
    self.Parent = parent
end

function PrimitiveTask:GetConditions()
    return self.Conditions
end

function PrimitiveTask:AddCondition(condition)
    table.insert(self.Conditions, condition)
    return self
end

function PrimitiveTask:GetExecutingConditions()
    return self.ExecutingConditions
end

function PrimitiveTask:AddExecutingCondition(condition)
    table.insert(self.ExecutingConditions, condition)
    return self
end

function PrimitiveTask:GetOperator()
    return self.Operator
end

function PrimitiveTask:SetOperator(action)
    if self.Operator then
        error("A Primitive Task can only contain a single Operator!")
    end
    self.Operator = action
end

function PrimitiveTask:GetEffects()
    return self.Effects
end

function PrimitiveTask:AddEffect(effect)
    table.insert(self.Effects, effect)
    return self
end

function PrimitiveTask:ApplyEffects(ctx)
    if ctx.ContextState == ContextState.Planning and ctx.LogDecomposition then
        self:Log(ctx, "PrimitiveTask.ApplyEffects", "yellow")
    end

    if ctx.LogDecomposition then
        ctx.CurrentDecompositionDepth = ctx.CurrentDecompositionDepth + 1
    end

    for _, effect in ipairs(self.Effects) do
        effect:Apply(ctx)
    end

    if ctx.LogDecomposition then
        ctx.CurrentDecompositionDepth = ctx.CurrentDecompositionDepth - 1
    end
end

function PrimitiveTask:Stop(ctx)
    if self.Operator and self.Operator.Stop then
        self.Operator:Stop(ctx)
    end
end

function PrimitiveTask:Aborted(ctx)
    if self.Operator and self.Operator.Aborted then
        self.Operator:Aborted(ctx)
    end
end

function PrimitiveTask:IsValid(ctx)
    if ctx.LogDecomposition then
        self:Log(ctx, "PrimitiveTask.IsValid check")
    end

    for _, condition in ipairs(self.Conditions) do
        if ctx.LogDecomposition then
            ctx.CurrentDecompositionDepth = ctx.CurrentDecompositionDepth + 1
        end

        local result = condition:IsValid(ctx)

        if ctx.LogDecomposition then
            ctx.CurrentDecompositionDepth = ctx.CurrentDecompositionDepth - 1
            self:Log(ctx, string.format("PrimitiveTask.IsValid:%s:%s is%s valid!",
                result and "Success" or "Failed",
                condition:GetName(),
                result and "" or " not"), result and "darkgreen" or "darkred")
        end

        if not result then
            if ctx.LogDecomposition then
                self:Log(ctx, "PrimitiveTask.IsValid:Failed:Preconditions not met!", "red")
            end
            return false
        end
    end

    if ctx.LogDecomposition then
        self:Log(ctx, "PrimitiveTask.IsValid:Success!", "green")
    end

    return true
end

function PrimitiveTask:OnIsValidFailed(ctx)
    return DecompositionStatus.Failed
end

function PrimitiveTask:Log(ctx, description, color)
    ctx:Log(self.Name, description, ctx.CurrentDecompositionDepth + 1, self, color)
end

return PrimitiveTask
