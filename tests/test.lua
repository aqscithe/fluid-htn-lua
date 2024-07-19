local EffectType = require("lib.Effects.EffectType")

local function applyEffect(effectType)
    if effectType == EffectType.PlanAndExecute then
        print("Applying PlanAndExecute effect")
    elseif effectType == EffectType.PlanOnly then
        print("Applying PlanOnly effect")
    elseif effectType == EffectType.Permanent then
        print("Applying Permanent effect")
    else
        print("Unknown effect type")
    end
end

applyEffect(EffectType.PlanAndExecute)  -- Output: Applying PlanAndExecute effect
applyEffect(EffectType.PlanOnly)        -- Output: Applying PlanOnly effect
applyEffect(EffectType.Permanent)       -- Output: Applying Permanent effect