TestConfiguration = {}

function TestConfiguration:testPanelOpensByDefaultInAnA320()
    flyWithLuaStub:reset()
    flyWithLuaStub:setPlaneIcao("A320")
    local checklist = dofile("scripts/A320_checklist.lua")
    flyWithLuaStub:bootstrapAllMacros()
    flyWithLuaStub:runNextFrameAfterExternalWritesToDatarefs()

    luaUnit.assertIsTrue(flyWithLuaStub:isMacroActive(a320ChecklistPackageExport.test.defaultMacroName))
end

function TestConfiguration:testPanelDoesNotOpenByDefaultInOtherAirplanes()
    flyWithLuaStub:reset()
    flyWithLuaStub:setPlaneIcao("MD82")
    local checklist = dofile("scripts/A320_checklist.lua")
    flyWithLuaStub:bootstrapAllMacros()
    flyWithLuaStub:runNextFrameAfterExternalWritesToDatarefs()

    luaUnit.assertIsFalse(flyWithLuaStub:isMacroActive("A320 NORMAL CHECKLIST in plane MD82"))
end

function TestConfiguration:testPanelDoesNotOpenByDefaultInOtherAirplanesEvenAfterOpeningItManually()
    flyWithLuaStub:reset()
    flyWithLuaStub:setPlaneIcao("MD82")
    local checklist = dofile("scripts/A320_checklist.lua")
    a320ChecklistPackageExport.test.Config.Content.Windows.MainWindowVisibility = "hidden"
    flyWithLuaStub:bootstrapAllMacros()
    flyWithLuaStub:runNextFrameAfterExternalWritesToDatarefs()

    luaUnit.assertIsFalse(flyWithLuaStub:isMacroActive(a320ChecklistPackageExport.test.defaultMacroName))

    flyWithLuaStub:activateAllMacros(true)

    luaUnit.assertEquals(a320ChecklistPackageExport.test.Config.Content.Windows.MainWindowVisibility, "hidden")
end

function TestConfiguration:testPanelDoesNotOpenUpAgainAutomaticallyAfterClosingItInAnA320ButThenAgainWhenOpened()
    flyWithLuaStub:reset()
    flyWithLuaStub:setPlaneIcao("A320")
    local checklist = dofile("scripts/A320_checklist.lua")
    flyWithLuaStub:bootstrapAllMacros()
    flyWithLuaStub:runNextFrameAfterExternalWritesToDatarefs()

    luaUnit.assertIsTrue(flyWithLuaStub:isMacroActive(a320ChecklistPackageExport.test.defaultMacroName))

    luaUnit.assertEquals(a320ChecklistPackageExport.test.Config.Content.Windows.MainWindowVisibility, "visible")
    flyWithLuaStub:closeWindowByTitle(a320ChecklistPackageExport.test.defaultWindowTitle)
    luaUnit.assertEquals(a320ChecklistPackageExport.test.Config.Content.Windows.MainWindowVisibility, "hidden")

    flyWithLuaStub:activateMacro(a320ChecklistPackageExport.test.defaultMacroName, false)
    flyWithLuaStub:activateMacro(a320ChecklistPackageExport.test.defaultMacroName, true)
    luaUnit.assertEquals(a320ChecklistPackageExport.test.Config.Content.Windows.MainWindowVisibility, "visible")
end
