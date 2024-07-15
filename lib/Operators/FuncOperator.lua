-- Import required modules
local TaskStatus = require("lib.Tasks.TaskStatus")
local IOperator = require("IOperator")

-- Define the FuncOperator class
local FuncOperator = setmetatable({}, IOperator)
FuncOperator.__index = FuncOperator

function FuncOperator:New(func, funcStop, funcAborted)
    local instance = setmetatable({}, FuncOperator)
    instance._func = func
    instance._funcStop = funcStop
    instance._funcAborted = funcAborted
    return instance
end

function FuncOperator:Update(ctx)
    if self._func then
        return self._func(ctx) or TaskStatus.Failure
    else
        return TaskStatus.Failure
    end
end

function FuncOperator:Stop(ctx)
    if self._funcStop then
        self._funcStop(ctx)
    end
end

function FuncOperator:Aborted(ctx)
    if self._funcAborted then
        self._funcAborted(ctx)
    end
end

return FuncOperator
