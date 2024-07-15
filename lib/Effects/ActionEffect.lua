-- Import the IEffect interface and EffectType enum
local IEffect = require("IEffect")
local EffectType = require("EffectType")

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
    if ctx.LogDecomposition then
        ctx:Log(self.Name, "ActionEffect.Apply:" .. tostring(self.Type), ctx.CurrentDecompositionDepth + 1, self)
    end

    if self._action then
        self._action(ctx, self.Type)
    else
        error("Unexpected context type!")
    end
end

return ActionEffect
