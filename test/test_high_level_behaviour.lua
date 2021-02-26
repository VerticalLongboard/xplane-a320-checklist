local flyWithLuaStub = require("xplane_fly_with_lua_stub")

TestHighLevelBehaviour = {}

function TestHighLevelBehaviour:bootstrapChecklist()
    flyWithLuaStub:reset()

    flyWithLuaStub:createSharedDatarefHandle(
        "sim/graphics/scenery/sun_pitch_degrees",
        flyWithLuaStub.Constants.DatarefTypeFloat,
        -1.337
    )

    local checklist = dofile("scripts/A320_checklist.lua")
    flyWithLuaStub:bootstrapAllMacros()
    flyWithLuaStub:runNextCompleteFrameAfterExternalWritesToDatarefs()
end
