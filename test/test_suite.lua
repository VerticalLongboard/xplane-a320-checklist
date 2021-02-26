local flyWithLuaStub = require("xplane_fly_with_lua_stub")

flyWithLuaStub:suppressLogMessagesContaining(
    {
        "A320 NORMAL CHECKLIST using '"
    }
)

require("test_high_level_behaviour")
require("test_configuration")
