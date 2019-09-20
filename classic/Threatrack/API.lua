-- Threatrack
-- MIT License © 2019 Arthur Corenzan
-- More on https://github.com/haggen/wow

local detectionHandlers = {};

local function HandleDetection(callback)
	table.insert(detectionHandlers, callback);
end

local function CallHandlers()
	for i = 1, #detectionHandlers do
		detectionHandlers[i]();
	end
end

local function RefreshDetection(data)
	data.lastSeen = GetTime();
end

local detectedPlayers = {};

local function RegisterDetection(data)
	for i = 1, #detectedPlayers do
		if (data.name == detectedPlayers[i]) then
			RefreshDetection(detectedPlayers[i], data);
			return;
		end
	end
	table.insert(detectedPlayers, data);
	CallHandlers();
end
local function IsDetectionStale(data)
	return GetTime() - data.lastSeen > 10;
end

local function GetDetectedPlayers()
	local recentlyDetectedPlayers = {};
	for i = 1, #detectedPlayers do
		if (not IsDetectionStale(detectedPlayers[i])) then
			table.insert(recentlyDetectedPlayers, detectedPlayers[i]);
		end
	end
	return detectedPlayers;
end

--
--
--

local frame = CreateFrame("FRAME");

frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT");

local function CreatePlayerData(unit)
	local data = {
		lastSeen = GetTime(),
		name = GetUnitName(unit),
		class = select(2, UnitClass(unit)),
		race = string.upper(select(2, UnitRace(unit))),
		level = UnitLevel(unit),
	};
	return data;
end

local function OnEvent(self, event, ...)
	if (event == "UPDATE_MOUSEOVER_UNIT") then
		if UnitIsPlayer("mouseover") then
			local data = CreatePlayerData("mouseover");
			RegisterDetection(data);
		end
	end
end
frame:SetScript("OnEvent", OnEvent);

--
--
--

Threatrack_GetDetectedPlayers = GetDetectedPlayers;
Threatrack_HandleDetection = HandleDetection;
Threatrack_IsDetectionStale = IsDetectionStale;

