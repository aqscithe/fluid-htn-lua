
local MyContext = require("tests.MyContext")

local ActionEffect = require("lib.Effects.ActionEffect")
local EffectType = require("lib.Effects.EffectType")


local function runTests()
    -- Test function to check if the name is set correctly
    local function testSetsName_ExpectedBehavior()
        local e = ActionEffect:New("Name", EffectType.PlanOnly, nil)
        assert(e.Name == "Name", "testSetsName_ExpectedBehavior failed")
        print("testSetsName_ExpectedBehavior passed.")
    end

    -- Test function to check if the type is set correctly
    local function testSetsType_ExpectedBehavior()
        local e = ActionEffect:New("Name", EffectType.PlanOnly, nil)
        assert(e.Type == EffectType.PlanOnly, "testSetsType_ExpectedBehavior failed")
        print("testSetsType_ExpectedBehavior passed.")
    end

    -- Test function to check if Apply does nothing without a function pointer
    local function testApplyDoesNothingWithoutFunctionPtr()
        local ctx = MyContext:New()
        ctx.LogDecomposition = false
        local e = ActionEffect:New("Name", EffectType.PlanOnly, nil)
        e:Apply(ctx)
        print("testApplyDoesNothingWithoutFunctionPtr passed.")
    end

    -- Test function to check if Apply throws an error for a bad context
    local function testApplyThrowsIfBadContext_ExpectedBehavior()
        local e = ActionEffect:New("Name", EffectType.PlanOnly, nil)
        local status, err = pcall(function() e:Apply({}) end)
        assert(not status and err:find("Unexpected context type!"), "testApplyThrowsIfBadContext_ExpectedBehavior failed")
        print("testApplyThrowsIfBadContext_ExpectedBehavior passed.")
    end

    -- Test function to check if Apply calls the internal function pointer
    local function testApplyCallsInternalFunctionPtr_ExpectedBehavior()
        local ctx = MyContext:New()
        local e = ActionEffect:New("Name", EffectType.PlanOnly, function(c, et) c.Done = true end)
        e:Apply(ctx)
        assert(ctx.Done == true, "testApplyCallsInternalFunctionPtr_ExpectedBehavior failed")
        print("testApplyCallsInternalFunctionPtr_ExpectedBehavior passed.")
    end

    -- Run all tests
    testSetsName_ExpectedBehavior()
    testSetsType_ExpectedBehavior()
    testApplyDoesNothingWithoutFunctionPtr()
    testApplyThrowsIfBadContext_ExpectedBehavior()
    testApplyCallsInternalFunctionPtr_ExpectedBehavior()

    print("All tests passed.")
end

-- Run the tests
runTests()

