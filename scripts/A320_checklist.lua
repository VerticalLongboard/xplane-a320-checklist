--[[

MIT License

Copyright (c) 2020 VerticalLongboard

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

--]]
local licensesOfDependencies = {
	{"Lua INI Parser", "MIT License", "https://github.com/Dynodzzo/Lua_INI_Parser"}
}

for i = 1, #licensesOfDependencies do
	logMsg(
		("A320 NORMAL CHECKLIST using '%s' with license '%s'. Project homepage: %s"):format(
			licensesOfDependencies[i][1],
			licensesOfDependencies[i][2],
			licensesOfDependencies[i][3]
		)
	)
end

TRACK_ISSUE = TRACK_ISSUE or function(component, description, workaround)
	end

MULTILINE_TEXT = MULTILINE_TEXT or function(...)
	end

TRIGGER_ISSUE_AFTER_TIME = TRIGGER_ISSUE_AFTER_TIME or function(...)
	end

TRIGGER_ISSUE_IF = TRIGGER_ISSUE_IF or function(conditition)
	end

local function trim(str)
	return str:gsub("^%s*(.-)%s*$", "%1")
end

local function windowVisibilityToInitialMacroState(windowIsVisible)
	if windowIsVisible then
		return "activate"
	else
		return "deactivate"
	end
end

local LuaIniParser = require("LIP")

local function fileExists(filePath)
	local file = io.open(filePath, "r")
	if file == nil then
		return false
	end

	io.close(file)
	return true
end

local ConfigurationClass
do
	Configuration = {}

	function Configuration:new(iniFilePath)
		local newInstanceWithState = {
			Path = iniFilePath,
			Content = {}
		}
		setmetatable(newInstanceWithState, self)
		self.__index = self
		return newInstanceWithState
	end

	function Configuration:load()
		if (not fileExists(self.Path)) then
			return
		end

		self.Content = LuaIniParser.load(self.Path)
	end

	function Configuration:save()
		LuaIniParser.save(self.Path, self.Content)
	end

	function Configuration:setValue(section, key, value)
		if (self.Content[section] == nil) then
			self.Content[section] = {}
		end
		if (type(value) == "string") then
			value = trim(value)
		end

		self.Content[section][key] = value
	end

	function Configuration:getValue(section, key, defaultValue)
		if (self.Content[section] == nil) then
			self.Content[section] = {}
		end
		if (self.Content[section][key]) == nil then
			self.Content[section][key] = defaultValue
		end

		return self.Content[section][key]
	end
end

local Config = Configuration:new(SCRIPT_DIRECTORY .. "A320_checklist.ini")

local windowVisibilityVisible = "visible"
local windowVisibilityHidden = "hidden"

local beforeStartChecklistItems = {
	{"COCKPIT PREP", "COMPLETE (BOTH)"},
	{"SIGNS", "ON/AUTO"},
	{"ADIRS", "NAV"},
	{"FUEL QTY/BAL", "KG / BALANCED"},
	{"MCDU TO DATA", "SET"},
	{"BARO REF", "# SET"},
	{"-"},
	{"WINDOWS/DOORS", "CLOSED/ARMED (BOTH)"},
	{"BEACON", "ON"},
	{"THRUST LEV", "IDLE"},
	{"PARK BRK", "SET"}
}

local afterStartChecklistItems = {
	{"ANTI ICE", "AS RQRD"},
	{"ECAM STATUS", "CHECKED"},
	{"PITCH TRIM", "# SET"},
	{"RUDDER TRIM", "ZERO"}
}

local beforeTakeoffChecklistItems = {
	{"FLT CTRL", "CHECKED (BOTH)"},
	{"FLT INSTR", "CHECKED (BOTH)"},
	{"BRIEFING", "CONFIRMED"},
	{"FLAPS SETTING", "CONF (BOTH)"},
	{"V1/VR/V2/FLEX", "CROSSCHECK (BOTH)"},
	{"TRANSPONDER", "SET"},
	{"ECAM MEMO", "TAKEOFF NO BLUE"},
	{"TAKEOFF RWY", "CONFIRMED"},
	{"-"},
	{"CABIN CREW", "ADVISED"},
	{"ENG MODE", "AS RQRD"},
	{"TCAS", "TA/RA"},
	{"PACKS", "AS RQRD"}
}

local afterTakeoffChecklistItems = {
	{"LANDING GEAR", "GEAR UP"},
	{"FLAPS", "RETRACTED"},
	{"PACKS", "ON"},
	{"-"},
	{"BARO REF", "STD SET"}
}

local afterApproachChecklistItems = {
	{"BRIEFING", "CONFIRMED"},
	{"ECAM STATUS", "CHECKED"},
	{"SEAT BELTS", "ON"},
	{"-"},
	{"BARO REF", "# SET"},
	{"MDA/DH", "SET (BOTH)"},
	{"ENG MODE", "AS RQRD"}
}

local landingChecklistItems = {
	{"CABIN", "SECURED"},
	{"A/THR", "SPEED/OFF"},
	{"AUTOBRAKE", "AS RQRD"},
	{"GO-AROUND", "ALTITUDE SET"},
	{"ECAM MEMO", "LANDING NO BLUE"}
}

local afterLandingChecklistItems = {
	{"FLAPS", "RETRACTED"},
	{"SPOILERS", "DISARMED"},
	{"APU", "AS RQRD"},
	{"RADAR", "OFF"},
	{"RDR WINDSH SYS", "OFF"}
}

local parkingChecklistItems = {
	{"APU BLEED", "AS RQRD"},
	{"Y ELEC PUMP", "OFF"},
	{"ENGINES", "OFF"},
	{"SEAT BELTS", "OFF"},
	{"EXT LT", "AS RQRD"},
	{"FUEL PUMPS", "OFF"},
	{"PRK BRK, CHOCKS", "AS RQRD"},
	{"TRANSPONDER", "STANDBY"}
}

local securingAircraftChecklistItems = {
	{"ADIRS", "OFF"},
	{"OXYGEN", "OFF"},
	{"APU BLEED", "OFF"},
	{"EMER EXIT LT", "OFF"},
	{"NO SMOKING", "OFF"},
	{"APU AND BAT", "OFF"}
}

local a320ChecklistItemsTable = {
	{"Before Start", "BEFORE START CHECKLIST", beforeStartChecklistItems},
	{"After Start", "AFTER START CHECKLIST", afterStartChecklistItems},
	{"Before Tkoff", "BEFORE TAKEOFF CHECKLIST", beforeTakeoffChecklistItems},
	{"After Tkoff", "AFTER TAKEOFF CHECKLIST", afterTakeoffChecklistItems},
	{"After Appr", "AFTER APPROACH CHECKLIST", afterApproachChecklistItems},
	{"Landing", "LANDING CHECKLIST", landingChecklistItems},
	{"After Landg", "AFTER LANDING CHECKLIST (SILENT)", afterLandingChecklistItems},
	{"Parking", "PARKING CHECKLIST", parkingChecklistItems},
	{"Securing A/c", "SECURING AIRCRAFT CHECKLIST", securingAircraftChecklistItems}
}

local checklistBackButtonTitleIndex = 1
local checklistNextButtonTitleIndex = 2
local checklistTitleIndex = 3
local checklistContentIndex = 4
local a320ChecklistTable = {}

local defaultLineMaxWidth = 35

function getCenteredString(str, maxWidth)
	local linePadding = maxWidth - str:len()
	local leftPadding = nil
	local rightPadding = nil
	if (linePadding % 2 == 0) then
		leftPadding = linePadding * 0.5
		rightPadding = leftPadding
	else
		leftPadding = math.floor(linePadding * 0.5)
		rightPadding = leftPadding + 1
	end

	local padWhitespaceLeft = string.rep(" ", leftPadding)
	local padWhitespaceRight = string.rep(" ", rightPadding)
	return ("%s%s%s"):format(padWhitespaceLeft, str, padWhitespaceRight)
end

function getLeftRightDottedString(left, right, maxWidth)
	local dots = string.rep(".", maxWidth - left:len() - right:len())
	return ("%s%s%s"):format(left, dots, right)
end

local function generateChecklistStringFromItems(items, maxWidth)
	local checklistString = ""
	for _, item in ipairs(items) do
		if (item[1] == "-") then
			checklistString = ("%s%s\n"):format(checklistString, string.rep("=", maxWidth))
		else
			checklistString = ("%s%s\n"):format(checklistString, getLeftRightDottedString(item[1], item[2], maxWidth))
		end
	end

	return checklistString
end

local function getBackButtonText(title, buttonWidth)
	return ("< %s%s"):format(title, string.rep(" ", buttonWidth - title:len() - 2))
end

local function getNextButtonText(title, buttonWidth)
	return ("%s%s >"):format(string.rep(" ", buttonWidth - title:len() - 2), title)
end

local function generateChecklistTable()
	local halfButtonWidth = 16
	for _, cl in ipairs(a320ChecklistItemsTable) do
		table.insert(
			a320ChecklistTable,
			{
				getBackButtonText(cl[1], halfButtonWidth),
				getNextButtonText(cl[1], halfButtonWidth),
				getCenteredString(cl[2], defaultLineMaxWidth),
				generateChecklistStringFromItems(cl[3], 36)
			}
		)
	end
end

local currentA320ChecklistIndex = 1

local a320Blue = 0xFFFFDDAA
local Colors = {
	White = 0xFFFFFFFF,
	Black = 0xFF000000,
	BrightGrey = 0xFFAAAAAA,
	MediumGrey = 0xFF888888
}

local whiteImageId = nil
local windowWidth = 270.0
local windowHeight = 240.0

TRACK_ISSUE(
	"Imgui",
	"Setting imgui.constant.Col.WindowBg/ChildBg does not change the window background color, even though it should.",
	"Draw a white image in the background."
)
TRACK_ISSUE(
	"Imgui",
	"Text cannot have a specific background color.",
	"Use a button that does nothing to display background-colored text."
)
function buildA320ChecklistWindow()
	imgui.DrawList_AddImage(whiteImageId, 0.0, 0.0, windowWidth, windowHeight, 0.0, 0.0, 1.0, 1.0, Colors.White)

	imgui.PushStyleColor(imgui.constant.Col.Button, Colors.MediumGrey)
	imgui.PushStyleColor(imgui.constant.Col.ButtonActive, Colors.MediumGrey)
	imgui.PushStyleColor(imgui.constant.Col.ButtonHovered, Colors.MediumGrey)
	imgui.PushStyleColor(imgui.constant.Col.Text, Colors.White)
	if (currentA320ChecklistIndex > 1) then
		if (imgui.Button(a320ChecklistTable[currentA320ChecklistIndex - 1][checklistBackButtonTitleIndex])) then
			currentA320ChecklistIndex = currentA320ChecklistIndex - 1
		end
	end

	if (currentA320ChecklistIndex < #a320ChecklistTable) then
		imgui.SameLine(141)
		if (imgui.Button(a320ChecklistTable[currentA320ChecklistIndex + 1][checklistNextButtonTitleIndex])) then
			currentA320ChecklistIndex = currentA320ChecklistIndex + 1
		end
	end
	imgui.PopStyleColor()
	imgui.PopStyleColor()
	imgui.PopStyleColor()
	imgui.PopStyleColor()

	imgui.PushStyleColor(imgui.constant.Col.Text, Colors.White)
	imgui.PushStyleColor(imgui.constant.Col.Button, Colors.Black)
	imgui.PushStyleColor(imgui.constant.Col.ButtonActive, Colors.Black)
	imgui.PushStyleColor(imgui.constant.Col.ButtonHovered, Colors.Black)
	imgui.Button(a320ChecklistTable[currentA320ChecklistIndex][checklistTitleIndex])
	imgui.PopStyleColor()
	imgui.PopStyleColor()
	imgui.PopStyleColor()
	imgui.PopStyleColor()

	imgui.PushStyleColor(imgui.constant.Col.Text, Colors.Black)
	imgui.TextUnformatted(a320ChecklistTable[currentA320ChecklistIndex][checklistContentIndex])
	imgui.PopStyleColor()
end

a320ChecklistWindow = nil

local PlaneCheckerSingleton
do
	PlaneCheckerSingleton = {}

	function PlaneCheckerSingleton:isAirbusA320Series()
		if (PLANE_ICAO == "A320" or PLANE_ICAO == "A319" or PLANE_ICAO == "A321") then
			return true
		end
		return false
	end

	function PlaneCheckerSingleton:getIcao()
		return PLANE_ICAO
	end
end

function destroyA320ChecklistWindow()
	if (a320ChecklistWindow) then
		float_wnd_destroy(a320ChecklistWindow)
	end

	if (PlaneCheckerSingleton:isAirbusA320Series()) then
		Config:setValue("Windows", "MainWindowVisibility", windowVisibilityHidden)
	end

	Config:save()
end

local defaultWindowTitle = "A320 NORMAL CHECKLIST"

function createA320ChecklistWindow()
	whiteImageId = float_wnd_load_image(SCRIPT_DIRECTORY .. "a320-checklist-data/White.png")

	a320ChecklistWindow = float_wnd_create(windowWidth, windowHeight, 1, true)
	float_wnd_set_title(a320ChecklistWindow, defaultWindowTitle)
	float_wnd_set_imgui_builder(a320ChecklistWindow, "buildA320ChecklistWindow")
	float_wnd_set_onclose(a320ChecklistWindow, "destroyA320ChecklistWindow")

	if (PlaneCheckerSingleton:isAirbusA320Series()) then
		Config:setValue("Windows", "MainWindowVisibility", windowVisibilityVisible)
	end

	Config:save()
end

local defaultMacroName = "A320 NORMAL CHECKLIST"

local function initializeOnce()
	generateChecklistTable()

	Config:load()

	windowIsSupposedToBeVisible = false
	if (trim(Config:getValue("Windows", "MainWindowVisibility", windowVisibilityVisible)) == windowVisibilityVisible) then
		windowIsSupposedToBeVisible = true
	end

	if (not PlaneCheckerSingleton:isAirbusA320Series()) then
		windowIsSupposedToBeVisible = false

		add_macro(
			("%s in plane %s"):format(defaultMacroName, PlaneCheckerSingleton:getIcao()),
			"createA320ChecklistWindow()",
			"destroyA320ChecklistWindow()",
			windowVisibilityToInitialMacroState(windowIsSupposedToBeVisible)
		)
	else
		add_macro(
			("%s NORMAL CHECKLIST"):format(PlaneCheckerSingleton:getIcao()),
			"createA320ChecklistWindow()",
			"destroyA320ChecklistWindow()",
			windowVisibilityToInitialMacroState(windowIsSupposedToBeVisible)
		)
	end
end

initializeOnce()

a320ChecklistPackageExport = {}
a320ChecklistPackageExport.test = {}
a320ChecklistPackageExport.test.Config = Config
a320ChecklistPackageExport.test.defaultMacroName = defaultMacroName
a320ChecklistPackageExport.test.defaultWindowTitle = defaultWindowTitle

return
