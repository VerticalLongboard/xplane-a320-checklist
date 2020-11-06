TestConfiguration = {}

function TestConfiguration:testPanelOpensByDefaultInAnA320()
    flyWithLuaStub:reset()
    flyWithLuaStub:setPlaneIcao("A320")
    local checklist = dofile("scripts/A320_checklist.lua")
    flyWithLuaStub:bootstrapScriptUserInterface()
    flyWithLuaStub:runNextFrameAfterExternalWritesToDatarefs()

    luaUnit.assertIsTrue(flyWithLuaStub.userInterfaceIsActive)
end

function TestConfiguration:testPanelDoesNotOpenByDefaultInOtherAirplanes()
    flyWithLuaStub:reset()
    flyWithLuaStub:setPlaneIcao("MD82")
    local checklist = dofile("scripts/A320_checklist.lua")
    flyWithLuaStub:bootstrapScriptUserInterface()
    flyWithLuaStub:runNextFrameAfterExternalWritesToDatarefs()

    luaUnit.assertIsFalse(flyWithLuaStub.userInterfaceIsActive)
end

function TestConfiguration:testPanelDoesNotOpenByDefaultInOtherAirplanesEvenAfterOpeningItManually()
    flyWithLuaStub:reset()
    flyWithLuaStub:setPlaneIcao("MD82")
    local checklist = dofile("scripts/A320_checklist.lua")
    a320ChecklistPackageExport.test.Config.Content.Windows.MainWindowVisibility = "hidden"
    flyWithLuaStub:bootstrapScriptUserInterface()
    flyWithLuaStub:runNextFrameAfterExternalWritesToDatarefs()

    luaUnit.assertIsFalse(flyWithLuaStub.userInterfaceIsActive)

    flyWithLuaStub:activateUserInterfaceNow()

    luaUnit.assertEquals(a320ChecklistPackageExport.test.Config.Content.Windows.MainWindowVisibility, "hidden")
end

function TestConfiguration:testPanelDoesNotOpenUpAgainAutomaticallyAfterClosingItInAnA320()
    flyWithLuaStub:reset()
    flyWithLuaStub:setPlaneIcao("A320")
    local checklist = dofile("scripts/A320_checklist.lua")
    flyWithLuaStub:bootstrapScriptUserInterface()
    flyWithLuaStub:runNextFrameAfterExternalWritesToDatarefs()

    luaUnit.assertIsTrue(flyWithLuaStub.userInterfaceIsActive)

    luaUnit.assertEquals(a320ChecklistPackageExport.test.Config.Content.Windows.MainWindowVisibility, "visible")
    for _, window in pairs(flyWithLuaStub.windows) do
        flyWithLuaStub:closeWindow(window)
    end
    luaUnit.assertEquals(a320ChecklistPackageExport.test.Config.Content.Windows.MainWindowVisibility, "hidden")
end
