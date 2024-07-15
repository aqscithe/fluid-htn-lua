-- DomainBuilder.lua
local BaseDomainBuilder = require("BaseDomainBuilder")
local DefaultFactory = require("DefaultFactory")

local DomainBuilder = {}
DomainBuilder.__index = DomainBuilder
setmetatable(DomainBuilder, {__index = BaseDomainBuilder})

function DomainBuilder:New(domainName, factory)
    local instance = setmetatable(BaseDomainBuilder:New(domainName, factory or DefaultFactory:New()), DomainBuilder)
    return instance
end

return DomainBuilder
