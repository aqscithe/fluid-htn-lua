-- Import the ICondition interface
local ICondition = require("lib.Conditions.ICondition")

-- Define the FuncCondition class
local FuncCondition = setmetatable({}, ICondition)
FuncCondition.__index = FuncCondition

function FuncCondition:New(name, func)
    local instance = ICondition.new(self, name)
    instance._func = func
    return instance
end

function FuncCondition:IsValid(ctx)
    if ctx.LogDecomposition then
        ctx:Log(self.Name, "FuncCondition.IsValid called", ctx.CurrentDecompositionDepth + 1, self, nil)
    end

    if self._func then
        local result = self._func(ctx)
        
        if ctx.LogDecomposition then
            local color = result and "DarkGreen" or "DarkRed"
            ctx:Log(self.Name, "FuncCondition.IsValid: " .. tostring(result), ctx.CurrentDecompositionDepth + 1, self, color)
        end

        return result
    end

    return false
end

return FuncCondition
