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

local detectionData = {};

local function RegisterDetection(data)
	for i = 1, #detectionData do
		if (data.name == detectionData[i].name) then
			RefreshDetection(detectionData[i]);
			return;
		end
	end
	table.insert(detectionData, data);
end

local function IsDetectionStale(data)
	return GetTime() - data.lastSeen > 10;
end

local function GetDetectionData()
	local freshDetectionData = {};
	for i = 1, #detectionData do
		if (not IsDetectionStale(detectionData[i])) then
			table.insert(freshDetectionData, detectionData[i]);
		end
	end
	return freshDetectionData;
end

--
--
--

local frame = CreateFrame("FRAME");

frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT");

local function CreateDetectionData(unit)
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
			local data = CreateDetectionData("mouseover");
			RegisterDetection(data);
			CallHandlers();
		end
	end
end
frame:SetScript("OnEvent", OnEvent);

--
--
--

Threatrack_GetDetectionData = GetDetectionData;
Threatrack_HandleDetection = HandleDetection;
Threatrack_IsDetectionStale = IsDetectionStale;

