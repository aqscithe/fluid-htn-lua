-- Importing the required library

-- Defining the IDomain interface
local IDomain = {}
IDomain.__index = IDomain

-- Constructor
function IDomain:New()
    local instance = setmetatable({}, IDomain)
    instance.root = nil -- TaskRoot should be set appropriately elsewhere
    return instance
end

-- Getter for the Root property
function IDomain:GetRoot()
    return self.root
end

-- Method to add a subtask to a parent compound task
function IDomain:Add(parent, subtask)
    parent:AddSubtask(subtask)
end

-- Method to add a slot to a parent compound task
function IDomain:AddSlot(parent, slot)
    parent:AddSlot(slot)
end

return IDomain
