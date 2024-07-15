-- BaseDomainBuilder.lua
local Domain = require("Domain")
local DefaultFactory = require("lib.Factory.DefaultFactory")
local FuncCondition = require("lib.Conditions.FuncCondition")
local FuncOperator = require("lib.Operators.FuncOperator")
local ActionEffect = require("lib.Effects.ActionEffect")
local Sequence = require("lib.Tasks.CompoundTasks.Sequence")
local Selector = require("lib.Tasks.CompoundTasks.Selector")
local PrimitiveTask = require("lib.Tasks.PrimitiveTasks.PrimitiveTask")
local PausePlanTask = require("lib.Tasks.CompoundTasks.PausePlanTask")
local Slot = require("lib.Tasks.OtherTasks.Slot")

local BaseDomainBuilder = {}
BaseDomainBuilder.__index = BaseDomainBuilder

function BaseDomainBuilder:New(domainName, factory)
    factory = factory or DefaultFactory:New()
    local instance = setmetatable({
        _factory = factory,
        _domain = Domain:New(domainName),
        _pointers = {Domain:New(domainName).Root}
    }, BaseDomainBuilder)
    return instance
end

function BaseDomainBuilder:Pointer()
    return self._pointers[#self._pointers] or nil
end

function BaseDomainBuilder:CompoundTask(name, task)
    if not task then error("task is nil") end
    local pointer = self:Pointer()
    if pointer and pointer:IsCompoundTask() then
        task.Name = name
        self._domain:Add(pointer, task)
        table.insert(self._pointers, task)
    else
        error("Pointer is not a compound task type.")
    end
    return self
end

function BaseDomainBuilder:PrimitiveTask(name)
    local pointer = self:Pointer()
    if pointer and pointer:IsCompoundTask() then
        local task = PrimitiveTask:New(name)
        self._domain:Add(pointer, task)
        table.insert(self._pointers, task)
    else
        error("Pointer is not a compound task type.")
    end
    return self
end

function BaseDomainBuilder:PausePlanTask()
    local pointer = self:Pointer()
    if pointer and pointer:IsDecomposeAll() then
        local task = PausePlanTask:New()
        self._domain:Add(pointer, task)
    else
        error("Pointer is not a decompose-all compound task type.")
    end
    return self
end

function BaseDomainBuilder:Sequence(name)
    return self:CompoundTask(name, Sequence:New())
end

function BaseDomainBuilder:Select(name)
    return self:CompoundTask(name, Selector:New())
end

function BaseDomainBuilder:Action(name)
    return self:PrimitiveTask(name)
end

function BaseDomainBuilder:Condition(name, condition)
    local cond = FuncCondition:New(name, condition)
    self:Pointer():AddCondition(cond)
    return self
end

function BaseDomainBuilder:ExecutingCondition(name, condition)
    local pointer = self:Pointer()
    if pointer and pointer:IsPrimitiveTask() then
        local cond = FuncCondition:New(name, condition)
        pointer:AddExecutingCondition(cond)
    else
        error("Pointer is not a Primitive Task!")
    end
    return self
end

function BaseDomainBuilder:Do(action, forceStopAction)
    local pointer = self:Pointer()
    if pointer and pointer:IsPrimitiveTask() then
        local op = FuncOperator:New(action, forceStopAction)
        pointer:SetOperator(op)
    else
        error("Pointer is not a Primitive Task!")
    end
    return self
end

function BaseDomainBuilder:Effect(name, effectType, action)
    local pointer = self:Pointer()
    if pointer and pointer:IsPrimitiveTask() then
        local effect = ActionEffect:New(name, effectType, action)
        pointer:AddEffect(effect)
    else
        error("Pointer is not a Primitive Task!")
    end
    return self
end

function BaseDomainBuilder:End()
    table.remove(self._pointers)
    return self
end

function BaseDomainBuilder:Splice(domain)
    local pointer = self:Pointer()
    if pointer and pointer:IsCompoundTask() then
        self._domain:Add(pointer, domain.Root)
    else
        error("Pointer is not a compound task type.")
    end
    return self
end

function BaseDomainBuilder:Slot(slotId)
    local pointer = self:Pointer()
    if pointer and pointer:IsCompoundTask() then
        local slot = Slot:New(slotId)
        self._domain:Add(pointer, slot)
    else
        error("Pointer is not a compound task type.")
    end
    return self
end

function BaseDomainBuilder:Build()
    if self:Pointer() ~= self._domain.Root then
        error("The domain definition lacks one or more End() statements.")
    end
    self._factory:FreeList(self._pointers)
    return self._domain
end

return BaseDomainBuilder
