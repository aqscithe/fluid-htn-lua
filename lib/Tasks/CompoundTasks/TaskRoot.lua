-- TaskRoot.lua
local Selector = require("Selector")

local TaskRoot = setmetatable({}, Selector)
TaskRoot.__index = TaskRoot

function TaskRoot:New()
    return setmetatable(Selector:New(), TaskRoot)
end

return TaskRoot
