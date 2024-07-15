-- Define the IEffect interface
local IEffect = {}
IEffect.__index = IEffect

function IEffect:New(name, effectType)
    local instance = setmetatable({}, IEffect)
    instance.Name = name
    instance.Type = effectType
    return instance
end

function IEffect:Apply(ctx)
    -- This function should be overridden in derived classes
    error("Apply method not implemented")
end

return IEffect
