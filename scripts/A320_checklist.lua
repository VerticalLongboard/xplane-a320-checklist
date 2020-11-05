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

local Configuration = {
	Path = SCRIPT_DIRECTORY .. "A320_checklist.ini",
	Content = {}
}

local function fileExists(filePath)
	local file = io.open(filePath, "r")
	if file == nil then
		return false
	end

	io.close(file)
	return true
end

local function loadConfiguration()
	if (not fileExists(Configuration.Path)) then
		return
	end

	Configuration.Content = LuaIniParser.load(Configuration.Path)
end

local function saveConfiguration()
	LuaIniParser.save(Configuration.Path, Configuration.Content)
end

local function setConfigurationValue(section, key, value)
	if Configuration.Content == nil then
		Configuration.Content = {}
	end
	if Configuration.Content[section] == nil then
		Configuration.Content[section] = {}
	end
	if type(value) == "string" then
		value = trim(value)
	end

	Configuration.Content[section][key] = value
end

local function getConfigurationValue(section, key, defaultValue)
	if Configuration.Content == nil then
		Configuration.Content = {}
	end
	if Configuration.Content[section] == nil then
		Configuration.Content[section] = {}
	end
	if Configuration.Content[section][key] == nil then
		Configuration.Content[section][key] = defaultValue
	end

	return Configuration.Content[section][key]
end

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

function buildA320ChecklistWindow()
	imgui.SetWindowFontScale(1.0)

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

	imgui.PushStyleColor(imgui.constant.Col.Text, a320Blue)
	imgui.TextUnformatted(a320ChecklistTable[currentA320ChecklistIndex][checklistTitleIndex])
	imgui.PopStyleColor()
	imgui.TextUnformatted(a320ChecklistTable[currentA320ChecklistIndex][checklistContentIndex])
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
		setConfigurationValue("Windows", "MainWindowVisibility", windowVisibilityHidden)
	end

	saveConfiguration()
end

function createA320ChecklistWindow()
	a320ChecklistWindow = float_wnd_create(270, 230, 1, true)
	float_wnd_set_title(a320ChecklistWindow, "A320 NORMAL CHECKLIST")
	float_wnd_set_imgui_builder(a320ChecklistWindow, "buildA320ChecklistWindow")
	float_wnd_set_onclose(a320ChecklistWindow, "destroyA320ChecklistWindow")

	if (PlaneCheckerSingleton:isAirbusA320()) then
		setConfigurationValue("Windows", "MainWindowVisibility", windowVisibilityVisible)
	end

	saveConfiguration()
end

local function initializeOnce()
	loadConfiguration()

	windowIsSupposedToBeVisible = false
	if (trim(getConfigurationValue("Windows", "MainWindowVisibility", windowVisibilityVisible)) == windowVisibilityVisible) then
		windowIsSupposedToBeVisible = true
	end

	if (not PlaneCheckerSingleton:isAirbusA320()) then
		windowIsSupposedToBeVisible = false

		add_macro(
			("A320 NORMAL CHECKLIST in plane %s"):format(PlaneCheckerSingleton:getIcao()),
			"createA320ChecklistWindow()",
			"destroyA320ChecklistWindow()",
			windowVisibilityToInitialMacroState(windowIsSupposedToBeVisible)
		)
	else
		add_macro(
			"A320 NORMAL CHECKLIST",
			"createA320ChecklistWindow()",
			"destroyA320ChecklistWindow()",
			windowVisibilityToInitialMacroState(windowIsSupposedToBeVisible)
		)
	end
end

initializeOnce()
