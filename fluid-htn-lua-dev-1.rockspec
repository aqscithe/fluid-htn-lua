package = "fluid-htn-lua"
version = "dev-1"
source = {
   url = "git+ssh://git@github.com/aqscithe/fluid-htn-lua.git"
}
description = {
   homepage = "*** please enter a project homepage ***",
   license = "*** please specify a license ***"
}
dependencies = {
   "lua ~> 5.4"
}
build = {
   type = "builtin",
   modules = {
      BaseDomainBuilder = "lib\\BaseDomainBuilder.lua",
      ["Conditions.FuncCondition"] = "lib\\Conditions\\FuncCondition.lua",
      ["Conditions.ICondition"] = "lib\\Conditions\\ICondition.lua",
      ["Contexts.BaseContext"] = "lib\\Contexts\\BaseContext.lua",
      ["Contexts.IContext"] = "lib\\Contexts\\IContext.lua",
      ["Debug.DecompositionLogEntry"] = "lib\\Debug\\DecompositionLogEntry.lua",
      Domain = "lib\\Domain.lua",
      DomainBuilder = "lib\\DomainBuilder.lua",
      ["Effects.ActionEffect"] = "lib\\Effects\\ActionEffect.lua",
      ["Effects.EffectType"] = "lib\\Effects\\EffectType.lua",
      ["Effects.IEffect"] = "lib\\Effects\\IEffect.lua",
      ["Factory.DefaultFactory"] = "lib\\Factory\\DefaultFactory.lua",
      ["Factory.IFactory"] = "lib\\Factory\\IFactory.lua",
      IDomain = "lib\\IDomain.lua",
      ["Operators.FuncOperator"] = "lib\\Operators\\FuncOperator.lua",
      ["Operators.IOperator"] = "lib\\Operators\\IOperator.lua",
      ["Planners.DefaultPlannerState"] = "lib\\Planners\\DefaultPlannerState.lua",
      ["Planners.IPlannerState"] = "lib\\Planners\\IPlannerState.lua",
      ["Planners.Planner"] = "lib\\Planners\\Planner.lua",
      ["Tasks.CompoundTasks.CompoundTask"] = "lib\\Tasks\\CompoundTasks\\CompoundTask.lua",
      ["Tasks.CompoundTasks.DecompositionStatus"] = "lib\\Tasks\\CompoundTasks\\DecompositionStatus.lua",
      ["Tasks.CompoundTasks.ICompoundTask"] = "lib\\Tasks\\CompoundTasks\\ICompoundTask.lua",
      ["Tasks.CompoundTasks.IDecomposeAll"] = "lib\\Tasks\\CompoundTasks\\IDecomposeAll.lua",
      ["Tasks.CompoundTasks.PausePlanTask"] = "lib\\Tasks\\CompoundTasks\\PausePlanTask.lua",
      ["Tasks.CompoundTasks.Selector"] = "lib\\Tasks\\CompoundTasks\\Selector.lua",
      ["Tasks.CompoundTasks.Sequence"] = "lib\\Tasks\\CompoundTasks\\Sequence.lua",
      ["Tasks.CompoundTasks.TaskRoot"] = "lib\\Tasks\\CompoundTasks\\TaskRoot.lua",
      ["Tasks.ITask"] = "lib\\Tasks\\ITask.lua",
      ["Tasks.OtherTasks.Slot"] = "lib\\Tasks\\OtherTasks\\Slot.lua",
      ["Tasks.PrimitiveTasks.IPrimitiveTasks"] = "lib\\Tasks\\PrimitiveTasks\\IPrimitiveTasks.lua",
      ["Tasks.PrimitiveTasks.PrimitiveTask"] = "lib\\Tasks\\PrimitiveTasks\\PrimitiveTask.lua",
      ["Tasks.TaskStatus"] = "lib\\Tasks\\TaskStatus.lua"
   },
   copy_directories = {
      "tests"
   }
}
