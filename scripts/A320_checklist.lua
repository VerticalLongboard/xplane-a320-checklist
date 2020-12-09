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

local beforeStartChecklistString =
	"" ..
	"COCKPIT PREP     COMPLETE (BOTH)\n" ..
		"SIGNS            ON/AUTO\n" ..
			"ADIRS            NAV\n" ..
				"FUEL QTY/BAL     KG / BALANCED\n" ..
					"MCDU TO DATA     SET\n" ..
						"BARO REF         # SET\n" ..
							"------------------------------------\n" ..
								"WINDOWS/DOORS    CLOSED/ARMED (BOTH)\n" ..
									"BEACON           ON\n" .. "THRUST LEV       IDLE\n" .. "PARK BRK         SET\n"

local afterStartChecklistString =
	"" ..
	"ANTI ICE         AS RQRD\n" .. "ECAM STATUS      CHECKED\n" .. "PITCH TRIM       # SET\n" .. "RUDDER TRIM      ZERO\n"

local beforeTakeoffChecklistString =
	"" ..
	"FLT CTRL         CHECKED (BOTH)\n" ..
		"FLT INSTR        CHECKED (BOTH)\n" ..
			"BRIEFING         CONFIRMED\n" ..
				"FLAPS SETTING    CONF (BOTH)\n" ..
					"V1/VR/V2/FLEX    CROSSCHECK (BOTH)\n" ..
						"TRANSPONDER      SET\n" ..
							"ECAM MEMO        TAKEOFF NO BLUE\n" ..
								"TAKEOFF RWY      CONFIRMED\n" ..
									"------------------------------------\n" ..
										"CABIN CREW       ADVISED\n" ..
											"ENG MODE         AS RQRD\n" .. "TCAS             TA/RA\n" .. "PACKS            AS RQRD\n"

local afterTakeoffChecklistString =
	"" ..
	"LANDING GEAR     GEAR UP\n" ..
		"FLAPS            RETRACTED\n" ..
			"PACKS            ON\n" .. "------------------------------------\n" .. "BARO REF         STD SET\n"

local afterApproachChecklistString =
	"" ..
	"BRIEFING         CONFIRMED\n" ..
		"ECAM STATUS      CHECKED\n" ..
			"SEAT BELTS       ON\n" ..
				"------------------------------------\n" ..
					"BARO REF         # SET\n" .. "MDA/DH           SET (BOTH)\n" .. "ENG MODE         AS RQRD\n"

local landingChecklistString =
	"" ..
	"CABIN            SECURED\n" ..
		"A/THR            SPEED/OFF\n" ..
			"AUTOBRAKE        AS RQRD\n" .. "GO-AROUND        ALTITUDE SET\n" .. "ECAM MEMO        LANDING NO BLUE\n"

local afterLandingChecklistString =
	"" ..
	"FLAPS            RETRACTED\n" ..
		"SPOILERS         DISARMED\n" .. "APU              AS RQRD\n" .. "RADAR            OFF\n" .. "RDR WINDSH SYS   OFF\n"

local parkingChecklistString =
	"" ..
	"APU BLEED        AS RQRD\n" ..
		"Y ELEC PUMP      OFF\n" ..
			"ENGINES          OFF\n" ..
				"SEAT BELTS       OFF\n" ..
					"EXT LT           AS RQRD\n" ..
						"FUEL PUMPS       OFF\n" .. "PRK BRK, CHOCKS  AS RQRD\n" .. "TRANSPONDER      STANDBY\n"

local securingAircraftChecklistString =
	"" ..
	"ADIRS            OFF\n" ..
		"OXYGEN           OFF\n" ..
			"APU BLEED        OFF\n" .. "EMER EXIT LT     OFF\n" .. "NO SMOKING       OFF\n" .. "APU AND BAT      OFF\n"

local checklistButtonTitleIndex = 1
local checklistTitleIndex = 2
local checklistContentIndex = 3

local a320ChecklistTable = {
	{"Before Start", "BEFORE START CHECKLIST", beforeStartChecklistString},
	{"After Start", "AFTER START CHECKLIST", afterStartChecklistString},
	{"Before Tkoff", "BEFORE TAKEOFF CHECKLIST", beforeTakeoffChecklistString},
	{"After Tkoff", "AFTER TAKEOFF CHECKLIST", afterTakeoffChecklistString},
	{"After Appr", "AFTER APPROACH CHECKLIST", afterApproachChecklistString},
	{"Landing", "LANDING CHECKLIST", landingChecklistString},
	{"After Landg", "AFTER LANDING CHECKLIST (SILENT)", afterLandingChecklistString},
	{"Parking", "PARKING CHECKLIST", parkingChecklistString},
	{"Securing A/c", "SECURING AIRCRAFT CHECKLIST", securingAircraftChecklistString}
}

local currentA320ChecklistIndex = 1

local a320Blue = 0xFFFFDDAA
local Colors = {
	White = 0xFFFFFFFF,
	Black = 0xFF000000
}

local whiteImageId = nil

TRACK_ISSUE(
	"Imgui",
	"Setting imgui.constant.Col.WindowBg/ChildBg does not change the window background color, even though it should.",
	"Draw a white image in the background."
)
function buildA320ChecklistWindow()
	imgui.PushStyleColor(imgui.constant.Col.Button, Colors.Black)
	imgui.PushStyleColor(imgui.constant.Col.ButtonActive, Colors.Black)
	imgui.PushStyleColor(imgui.constant.Col.ButtonHovered, Colors.Black)

	imgui.DrawList_AddImage(whiteImageId, 0.0, 0.0, 270.0, 230.0, 0.0, 0.0, 1.0, 1.0, Colors.White)

	imgui.SetWindowFontScale(1.0)

	imgui.PushStyleColor(imgui.constant.Col.Text, Colors.White)
	if (currentA320ChecklistIndex > 1) then
		if (imgui.Button("< " .. a320ChecklistTable[currentA320ChecklistIndex - 1][checklistButtonTitleIndex])) then
			currentA320ChecklistIndex = currentA320ChecklistIndex - 1
		end
	end

	if (currentA320ChecklistIndex < #a320ChecklistTable) then
		imgui.SameLine(130)
		if (imgui.Button(a320ChecklistTable[currentA320ChecklistIndex + 1][checklistButtonTitleIndex] .. " >")) then
			currentA320ChecklistIndex = currentA320ChecklistIndex + 1
		end
	end
	imgui.PopStyleColor()

	imgui.PushStyleColor(imgui.constant.Col.Text, Colors.Black)
	imgui.TextUnformatted(a320ChecklistTable[currentA320ChecklistIndex][checklistTitleIndex])
	imgui.Separator()
	imgui.TextUnformatted(a320ChecklistTable[currentA320ChecklistIndex][checklistContentIndex])
	imgui.PopStyleColor()

	imgui.PopStyleColor()
	imgui.PopStyleColor()
	imgui.PopStyleColor()
end

a320ChecklistWindow = nil

local PlaneCheckerSingleton
do
	PlaneCheckerSingleton = {}

	function PlaneCheckerSingleton:isAirbusA320()
		if (PLANE_ICAO == "A320") then
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

	if (PlaneCheckerSingleton:isAirbusA320()) then
		Config:setValue("Windows", "MainWindowVisibility", windowVisibilityHidden)
	end

	Config:save()
end

local defaultWindowTitle = "A320 NORMAL CHECKLIST"

function createA320ChecklistWindow()
	whiteImageId = float_wnd_load_image(SCRIPT_DIRECTORY .. "a320-checklist-data/White.png")

	a320ChecklistWindow = float_wnd_create(270, 230, 1, true)
	float_wnd_set_title(a320ChecklistWindow, defaultWindowTitle)
	float_wnd_set_imgui_builder(a320ChecklistWindow, "buildA320ChecklistWindow")
	float_wnd_set_onclose(a320ChecklistWindow, "destroyA320ChecklistWindow")

	if (PlaneCheckerSingleton:isAirbusA320()) then
		Config:setValue("Windows", "MainWindowVisibility", windowVisibilityVisible)
	end

	Config:save()
end

local defaultMacroName = "A320 NORMAL CHECKLIST"

local function initializeOnce()
	Config:load()

	windowIsSupposedToBeVisible = false
	if (trim(Config:getValue("Windows", "MainWindowVisibility", windowVisibilityVisible)) == windowVisibilityVisible) then
		windowIsSupposedToBeVisible = true
	end

	if (not PlaneCheckerSingleton:isAirbusA320()) then
		windowIsSupposedToBeVisible = false

		add_macro(
			("%s in plane %s"):format(defaultMacroName, PlaneCheckerSingleton:getIcao()),
			"createA320ChecklistWindow()",
			"destroyA320ChecklistWindow()",
			windowVisibilityToInitialMacroState(windowIsSupposedToBeVisible)
		)
	else
		add_macro(
			defaultMacroName,
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
