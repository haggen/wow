-- Threatrack
-- MIT License © 2019 Arthur Corenzan
-- More on https://github.com/haggen/wow

local playerPresenceHandlers = {};

local function HandlePlayerPresence(callback)
	table.insert(playerPresenceHandlers, callback);
end

local function CallPlayerPresenceHandlers()
	for i = 1, #playerPresenceHandlers do
		playerPresenceHandlers[i]();
	end
end

local function RefreshPlayerPresence(oldData, newData)
	for key, value in pairs(newData) do
		oldData[key] = newData[key];
	end
end

-- TODO: This table only grows, and it's looped over every time
-- player presence data is requested so we should fix it, eventually.
local playerPresenceData = {};

local function RegisterPlayerPresence(data)
	for i = 1, #playerPresenceData do
		if (data.name == playerPresenceData[i].name) then
			RefreshPlayerPresence(playerPresenceData[i], data);
			return;
		end
	end
	table.insert(playerPresenceData, data);
end

local function IsPlayerPresenceStale(data)
	return GetTime() - data.lastSeen > 10;
end

local function GetPlayerPresenceData()
	local freshPlayerPresenceData = {};
	for i = 1, #playerPresenceData do
		if (not IsPlayerPresenceStale(playerPresenceData[i])) then
			table.insert(freshPlayerPresenceData, playerPresenceData[i]);
		end
	end
	return freshPlayerPresenceData;
end

--
--
--

local frame = CreateFrame("FRAME");

frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT");

local function CreatePlayerPresenceData(unit)
	local data = {
		lastSeen = GetTime(),
		name = GetUnitName(unit),
		class = select(2, UnitClass(unit)),
		race = string.upper(select(2, UnitRace(unit))),
		level = UnitLevel(unit),
		sex = UnitSex(unit),
		isEnemy = UnitIsEnemy(unit)
	};
	return data;
end

local function OnEvent(self, event, ...)
	if (event == "UPDATE_MOUSEOVER_UNIT") then
		if UnitIsPlayer("mouseover") then
			local data = CreatePlayerPresenceData("mouseover");
			RegisterPlayerPresence(data);
			CallPlayerPresenceHandlers();
		end
	end
end
frame:SetScript("OnEvent", OnEvent);

--
--
--

Threatrack_GetPlayerPresenceData = GetPlayerPresenceData;
Threatrack_HandlePlayerPresence = HandlePlayerPresence;
Threatrack_IsPlayerPresenceStale = IsPlayerPresenceStale;

