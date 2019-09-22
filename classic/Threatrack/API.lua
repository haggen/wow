-- Threatrack
-- MIT License © 2019 Arthur Corenzan
-- More on https://github.com/haggen/wow

local timeToStale = 20;

local playerPresenceHandlers = {};

local function HandlePresence(callback)
	table.insert(playerPresenceHandlers, callback);
end

local function CallPresenceHandlers()
	for i = 1, #playerPresenceHandlers do
		playerPresenceHandlers[i]();
	end
end

local function MergeDataValue(key, oldValue, newValue)
	if (oldValue == nil) then
		return newValue;
	end

	if (newValue == nil) then
		return oldValue;
	end

	if (key == "minLevel") then
		return math.max(newValue, oldValue);
	end

	return newValue;
end

local function RefreshPresence(oldData, newData)
	for key, newValue in pairs(newData) do
		oldData[key] = MergeDataValue(key, oldData[key], newValue);
	end
end

-- TODO: This table only grows, and it's looped over every time
-- player presence data is requested so we should fix it, eventually.
local playerPresenceData = {};

local function RegisterPresence(data)
	for i = 1, #playerPresenceData do
		if (data.name == playerPresenceData[i].name) then
			RefreshPresence(playerPresenceData[i], data);
			return;
		end
	end
	table.insert(playerPresenceData, data);
end

local function IsPresenceStale(data)
	return GetTime() - data.lastSeen > timeToStale;
end

local function GetPresenceData()
	local freshPresenceData = {};
	for i = 1, #playerPresenceData do
		if (not IsPresenceStale(playerPresenceData[i])) then
			table.insert(freshPresenceData, playerPresenceData[i]);
		end
	end
	return freshPresenceData;
end

--
--
--

local frame = CreateFrame("FRAME");

frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
frame:RegisterEvent("PLAYER_TARGET_CHANGED");
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");

local function GetUnitReaction(unit)
	if UnitIsEnemy("player", unit) then
		return "hostile";
	elseif UnitIsFriend("player", unit) then
		return "friendly";
	end
	return "unknown";
end

local function CreateDataFromUnit(unit)
	if (not UnitIsPlayer(unit)) then
		return nil;
	end

	local data = {
		lastSeen = GetTime(),
		name = GetUnitName(unit),
		class = string.lower(select(2, UnitClass(unit))),
		race = string.lower(select(2, UnitRace(unit))),
		level = UnitLevel(unit),
		sex = UnitSex(unit),
		reaction = GetUnitReaction(unit),
	};
	return data;
end

local combatLogFlagHostile = COMBATLOG_OBJECT_REACTION_HOSTILE;
local combatLogFlagFriendly = COMBATLOG_OBJECT_REACTION_FRIENDLY;
local combatLogFlagTypePlayer = COMBATLOG_OBJECT_TYPE_PLAYER;

local function GetCombatLogFlagsReaction(flags)
	if (bit.band(flags, combatLogFlagHostile) == combatLogFlagHostile) then
		return "hostile";
	elseif (bit.band(flags, combatLogFlagFriendly) == combatLogFlagFriendly) then
		return "friendly";
	end
	return "unknown";
end

local function IsCombatLogFlagsTypePlayer(flags)
	return bit.band(flags, combatLogFlagTypePlayer) == combatLogFlagTypePlayer;
end

local function CreateDataFromCombatLog(name, flags, spell)
	if not IsCombatLogFlagsTypePlayer(flags) then
		return nil;
	end

	local data = {
		lastSeen = GetTime(),
		name = name,
		class = nil,
		race = nil,
		level = nil,
		sex = nil,
		reaction = GetCombatLogFlagsReaction(flags),
	};

	local estimate = Threatrack_Spells[spell];
	if (estimate) then
		data.class = estimate[2];
		data.race = estimate[1];
		data.minLevel = estimate[3];
	end

	return data;
end

local function OnEvent(_, event)
	if (event == "PLAYER_TARGET_CHANGED") then
		local data = CreateDataFromUnit("target");
		if (data) then
			RegisterPresence(data);
			CallPresenceHandlers();
		end
	elseif (event == "UPDATE_MOUSEOVER_UNIT") then
		local data = CreateDataFromUnit("mouseover");
		if (data) then
			RegisterPresence(data);
			CallPresenceHandlers();
		end
	elseif (event == "COMBAT_LOG_EVENT_UNFILTERED") then
		-- timestamp, event, hideCaster, sourceGuid, sourceName, sourceFlags, sourceRaidFlags,
		-- targetGuid, targetName, targetFlags, targetRaidFlags, a, b, c, d, e, f
		local info = { CombatLogGetCurrentEventInfo() };

		local sourceData = CreateDataFromCombatLog(info[5], info[6], info[13]);
		if (sourceData) then
			RegisterPresence(sourceData);
		end

		local targetData = CreateDataFromCombatLog(info[9], info[10], info[13]);
		if (targetData) then
			RegisterPresence(targetData);
		end

		if (sourceData or targetData) then
			CallPresenceHandlers();
		end
	end
end
frame:SetScript("OnEvent", OnEvent);

--
--
--

Threatrack_GetPresenceData = GetPresenceData;
Threatrack_HandlePresence = HandlePresence;
Threatrack_IsPresenceStale = IsPresenceStale;
