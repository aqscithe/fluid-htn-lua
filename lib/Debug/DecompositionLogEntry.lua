-- Define the Debug utility
local Debug = {}

function Debug.DepthToString(depth)
    local s = ""
    for i = 1, depth do
        s = s .. "\t"
    end
    s = s .. "- "
    return s
end

-- Define IBaseDecompositionLogEntry interface
local IBaseDecompositionLogEntry = {}
IBaseDecompositionLogEntry.__index = IBaseDecompositionLogEntry

function IBaseDecompositionLogEntry:New(name, description, depth, color)
    local instance = setmetatable({}, IBaseDecompositionLogEntry)
    instance.Name = name
    instance.Description = description
    instance.Depth = depth
    instance.Color = color
    return instance
end

function IBaseDecompositionLogEntry:ToString()
    return self.Name .. ": " .. self.Description .. " at depth " .. self.Depth
end

-- Define IDecompositionLogEntry interface
local function IDecompositionLogEntry(base)
    local interface = {}
    interface.__index = interface
    setmetatable(interface, {__index = base})

    function interface:New(name, description, depth, color, entry)
        local instance = base.New(self, name, description, depth, color)
        setmetatable(instance, interface)
        instance.Entry = entry
        return instance
    end

    return interface
end

-- Define DecomposedCompoundTaskEntry struct
local DecomposedCompoundTaskEntry = IDecompositionLogEntry(IBaseDecompositionLogEntry)
DecomposedCompoundTaskEntry.__index = DecomposedCompoundTaskEntry

-- Define DecomposedConditionEntry struct
local DecomposedConditionEntry = IDecompositionLogEntry(IBaseDecompositionLogEntry)
DecomposedConditionEntry.__index = DecomposedConditionEntry

-- Define DecomposedEffectEntry struct
local DecomposedEffectEntry = IDecompositionLogEntry(IBaseDecompositionLogEntry)
DecomposedEffectEntry.__index = DecomposedEffectEntry

-- Export the module
return {
    Debug = Debug,
    IBaseDecompositionLogEntry = IBaseDecompositionLogEntry,
    DecomposedCompoundTaskEntry = DecomposedCompoundTaskEntry,
    DecomposedConditionEntry = DecomposedConditionEntry,
    DecomposedEffectEntry = DecomposedEffectEntry
}
