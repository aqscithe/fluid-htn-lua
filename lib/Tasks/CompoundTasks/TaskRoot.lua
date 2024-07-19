-- TaskRoot.lua
local Selector = require("lib.Tasks.CompoundTasks.Selector")

local TaskRoot = setmetatable({}, Selector)
TaskRoot.__index = TaskRoot

function TaskRoot:New()
    return setmetatable(Selector:New(), TaskRoot)
end

return TaskRoot
