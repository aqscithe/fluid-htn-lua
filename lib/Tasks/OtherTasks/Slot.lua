-- Slot.lua
local ITask = require("lib.Tasks.ITask")
local DecompositionStatus = require("lib.Tasks.CompoundTasks.DecompositionStatus")
local ConsoleColor = { White = "white", Green = "green", Red = "red" } -- Simulating ConsoleColor

local Slot = setmetatable({}, ITask)
Slot.__index = Slot

function Slot:New(slotId, name)
    local instance = setmetatable({}, Slot)
    instance.SlotId = slotId or 0
    instance.Name = name or ""
    instance.Parent = nil
    instance.Conditions = nil
    instance.Subtask = nil
    return instance
end

function Slot:GetName()
    return self.Name
end

function Slot:SetName(name)
    self.Name = name
end

function Slot:GetParent()
    return self.Parent
end

function Slot:SetParent(parent)
    self.Parent = parent
end

function Slot:GetConditions()
    return self.Conditions
end

function Slot:AddCondition(condition)
    error("Slot tasks do not support conditions.")
end

function Slot:Set(subtask)
    if self.Subtask ~= nil then
        return false
    end
    self.Subtask = subtask
    return true
end

function Slot:Clear()
    self.Subtask = nil
end

function Slot:Decompose(ctx, startIndex)
    if self.Subtask ~= nil then
        return self.Subtask:Decompose(ctx, startIndex)
    end
    return DecompositionStatus.Failed, nil
end

function Slot:IsValid(ctx)
    local result = self.Subtask ~= nil

    if ctx.LogDecomposition then
        self:Log(ctx, string.format("Slot.IsValid:%s!", result and "Success" or "Failed"), result and ConsoleColor.Green or ConsoleColor.Red)
    end

    return result
end

function Slot:OnIsValidFailed(ctx)
    return DecompositionStatus.Failed
end

function Slot:Log(ctx, description, color)
    ctx:Log(self.Name, description, ctx.CurrentDecompositionDepth, self, color)
end

return Slot
