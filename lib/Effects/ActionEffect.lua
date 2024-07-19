
-- Define the ActionEffect class
local ActionEffect = {}
ActionEffect.__index = ActionEffect

function ActionEffect:New(name, effectType, action)
    local instance = setmetatable({}, ActionEffect)
    instance.Name = name
    instance.Type = effectType
    instance._action = action
    return instance
end

function ActionEffect:Apply(ctx)
    -- Check if ctx has the necessary properties and methods to be considered an IContext
    if type(ctx) ~= "table" or not ctx.Log or type(ctx.CurrentDecompositionDepth) ~= "number" then
        error("Unexpected context type!")
    end

    if ctx.LogDecomposition then
        ctx:Log(self.Name, "ActionEffect.Apply:" .. tostring(self.Type), ctx.CurrentDecompositionDepth + 1, self)
    end

    if self._action then
        self._action(ctx, self.Type)
    end
end

return ActionEffect
