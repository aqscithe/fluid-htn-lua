-- setup.lua
local function get_project_root(levels_up)
    local path = debug.getinfo(1, "S").source:sub(2)
    for i = 1, levels_up do
        path = path:match("(.*)/")
    end
    return path
end

-- Calculate the project root path
local project_root = get_project_root(0)  -- Adjust '0' based on the levels to navigate up

-- Diagnostic print to check the value of project_root
print("Project root path:", project_root)

if project_root then
    -- Add the paths to your modules
    package.path = package.path 
        .. ";" .. project_root .. "/lib/?.lua"
        .. ";" .. project_root .. "/lib/UnitTests/?.lua"
        .. ";" .. project_root .. "/lib/Conditions/?.lua"
        .. ";" .. project_root .. "/lib/Contexts/?.lua"
        .. ";" .. project_root .. "/lib/Debug/?.lua"
        .. ";" .. project_root .. "/lib/Effects/?.lua"
        .. ";" .. project_root .. "/lib/Factory/?.lua"
        .. ";" .. project_root .. "/lib/Operators/?.lua"
        .. ";" .. project_root .. "/lib/Planners/?.lua"
        .. ";" .. project_root .. "/lib/Tasks/?.lua"
        .. ";" .. project_root .. "/lib/Tasks/CompoundTasks/?.lua"
        .. ";" .. project_root .. "/lib/Tasks/PrimitiveTasks/?.lua"
        .. ";" .. project_root .. "/lib/Tasks/OtherTasks/?.lua"
else
    error("Failed to determine project root path")
end
