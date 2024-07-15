-- IDecomposeAll.lua
local ICompoundTask = require("ICompoundTask")

local IDecomposeAll = setmetatable({}, ICompoundTask)
IDecomposeAll.__index = IDecomposeAll

function IDecomposeAll:New()
    error("IDecomposeAll is an interface and cannot be instantiated")
end

return IDecomposeAll
