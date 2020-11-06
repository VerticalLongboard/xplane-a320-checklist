local luaUnitOutput = require("luaunit_output")
local luaUnit = require("luaunit")
local flyWithLuaStub = require("xplane_fly_with_lua_stub")
local imguiStub = require("imgui_stub")

local a320Checklist = dofile("scripts/A320_checklist.lua")
flyWithLuaStub:suppressLogMessagesBeginningWith("A320 NORMAL CHECKLIST using '")

require("test_configuration")

local runner = luaUnit.LuaUnit.new()
runner:setOutput(luaUnitOutput.ColorText)
os.exit(runner:runSuite())
