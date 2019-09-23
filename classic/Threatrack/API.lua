-- Threatrack
-- MIT License © 2019 Arthur Corenzan
-- More on https://github.com/haggen/wow

-- Constants.
--
local LAST_SEEN = "lastSeen";
local NAME = "name";
local RACE = "race";
local CLASS = "class";
local REACTION = "reaction";
local LEVEL = "level";
local ESTIMATED_LEVEL = "estimatedLevel";

local UNKNOWN = "UNKNOWN";
local HOSTILE = "HOSTILE";
local FRIENDLY = "FRIENDLY";

local FLAG_HOSTILE = COMBATLOG_OBJECT_REACTION_HOSTILE;
local FLAG_FRIENDLY = COMBATLOG_OBJECT_REACTION_FRIENDLY;
local FLAG_PLAYER = COMBATLOG_OBJECT_TYPE_PLAYER;
local FLAG_PET = COMBATLOG_OBJECT_TYPE_PET;

-- Time in seconds after which the presence data becomes stale.
--
local FRESHNESS_THRESHOLD = 20;

-- Registry of handler to new presence detections.
--
local newPresenceHandlers = {};

-- Register new presence detection handler.
--
local function HandleNewPresence(handler)
	table.insert(newPresenceHandlers, handler);
end

-- Walk through the registry and fire new presence detection handlers.
--
local function CallNewPresenceHandlers()
	for i = 1, #newPresenceHandlers do
		newPresenceHandlers[i]();
	end
end

-- Create new presence data template.
--
local function CreatePresenceData()
	return {
		[LAST_SEEN]	= GetTime(),
		[NAME] = "",
		[RACE] = UNKNOWN,
		[CLASS] = UNKNOWN,
		[LEVEL] = 0,
		[ESTIMATED_LEVEL] = 0,
		[REACTION] = UNKNOWN,
	};
end

-- Given old and new values of a presence data, solve for which one should be honored.
--
local function MergePresenceDataValue(key, oldValue, newValue)
	if (key == CLASS) or (key == RACE) or (key == REACTION) then
		if (newValue == UNKNOWN) then
			return oldValue;
		else
			return newValue;
		end
	elseif (key == LEVEL) or (key == ESTIMATED_LEVEL) then
		return math.max(newValue, oldValue);
	end

	return newValue;
end

-- Update existing presence data.
--
local function UpdatePresenceData(oldData, newData)
	for key, newValue in pairs(newData) do
		oldData[key] = MergePresenceDataValue(key, oldData[key], newValue);
	end
end

-- Database of player presence detected data during the current session.
--
-- TODO: This table only grows, and it's looped over every time
-- player presence data is requested so we should fix it, eventually.
--
local allPresenceData = {};

-- Register new presence data into the database.
--
local function RegisterNewPresence(newData)
	for i = 1, #allPresenceData do
		if (newData.name == allPresenceData[i].name) then
			UpdatePresenceData(allPresenceData[i], newData);
			return nil;
		end
	end
	table.insert(allPresenceData, newData);
end

-- Tell whether given presence data is no longer fresh, i.e. past the freshness threshold.
--
local function IsPresenceStale(data)
	return GetTime() - data[LAST_SEEN] > FRESHNESS_THRESHOLD;
end

-- Return fresh player presence data, i.e. sans stale.
--
local function GetFreshPresenceData()
	local freshPresenceData = {};
	for i = 1, #allPresenceData do
		if (not IsPresenceStale(allPresenceData[i])) then
			table.insert(freshPresenceData, allPresenceData[i]);
		end
	end
	return freshPresenceData;
end

--
--
--

-- Frame used as event hub.
--
local frame = CreateFrame("FRAME");

-- Listen to game events to try and derive player presence.
--
frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
frame:RegisterEvent("PLAYER_TARGET_CHANGED");
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");

-- Given a unit return if its reaction towards you is friendly, hostile or unknown.
--
local function GetUnitReaction(unit)
	if UnitIsEnemy("player", unit) then
		return HOSTILE;
	elseif UnitIsFriend("player", unit) then
		return FRIENDLY;
	end
	return UNKNOWN;
end

-- Derive player presence data from given unit.
--
local function CreatePresenceDataFromUnit(unit)
	if (not UnitIsPlayer(unit)) then
		return nil;
	end

	local data = CreatePresenceData();
	data[NAME] = GetUnitName(unit);
	data[RACE] = string.upper(select(2, UnitRace(unit)));
	data[CLASS] = select(2, UnitClass(unit));
	data[LEVEL] = UnitLevel(unit);
	data[REACTION] = GetUnitReaction(unit);

	return data;
end

-- Tell whether a combat log event source or target has a
-- friendly, hostile or unknown reaction towards the player.
--
local function ReadCombatLogFlagsReaction(flags)
	if (bit.band(flags, FLAG_HOSTILE) == FLAG_HOSTILE) then
		return HOSTILE;
	elseif (bit.band(flags, FLAG_FRIENDLY) == FLAG_FRIENDLY) then
		return FRIENDLY;
	end
	return UNKNOWN;
end

-- Tell whether a combat log event source or target is a player.
--
local function IsCombatLogFlagsTypePlayer(flags)
	return bit.band(flags, FLAG_PLAYER) == FLAG_PLAYER;
end

-- Tell whether a combat log event source or target is a pet.
--
local function IsCombatLogFlagsTypePet(flags)
	return bit.band(flags, FLAG_PET) == FLAG_PET;
end

-- Collect presence data from combat log event source or target player.
--
local function CreatePresenceDataFromCombatLogEventPlayer(name, flags, spell)
	local data = CreatePresenceData();

	data[NAME] = name or "";
	data[REACTION] = ReadCombatLogFlagsReaction(flags);

	if (spell) then
		local estimateData = THREATRACK_SPELL_DATA[spell];
		if (estimateData) then
			data[RACE] = estimateData[1] or UNKNOWN;
			data[CLASS] = estimateData[2] or UNKNOWN;
			data[ESTIMATED_LEVEL] = estimateData[3];
		end
	end

	return data;
end

--
--
local function CreatePresenceDataFromCombatLogEventPet(name, flags, spell)
	local data = CreatePresenceData();

	data[REACTION] = ReadCombatLogFlagsReaction(flags);

	if (spell) then
		local estimateData = THREATRACK_PET_SPELL_DATA[spell];
		if (estimateData) then
			data[RACE] = estimateData[1] or UNKNOWN;
			data[CLASS] = estimateData[2] or UNKNOWN;
			data[ESTIMATED_LEVEL] = estimateData[3];
		end
	end

	return data;
end

-- Derive player presence data from a combat log event.
--
local function CreatePresenceDataFromCombatLogEvent(name, flags, spell)
	if IsCombatLogFlagsTypePlayer(flags) then
		return CreatePresenceDataFromCombatLogEventPlayer(name, flags, spell);
	elseif IsCombatLogFlagsTypePet(flags) then
		return CreatePresenceDataFromCombatLogEventPet(name, flags, spell);
	end

	return nil;
end

-- Event handler.
--
local function OnEvent(_, event)
	if (event == "PLAYER_TARGET_CHANGED") then
		local data = CreatePresenceDataFromUnit("target");
		if (data) then
			RegisterNewPresence(data);
			CallNewPresenceHandlers();
		end
	elseif (event == "UPDATE_MOUSEOVER_UNIT") then
		local data = CreatePresenceDataFromUnit("mouseover");
		if (data) then
			RegisterNewPresence(data);
			CallNewPresenceHandlers();
		end
	elseif (event == "COMBAT_LOG_EVENT_UNFILTERED") then
		local combatLogEvent = {CombatLogGetCurrentEventInfo()};

		local timestamp, event, hideCaster, sourceGuid, sourceName, sourceFlags, sourceRaidFlags,
			targetGuid, targetName, targetFlags, targetRaidFlags, _, spellName, _, _, _, _, _, _, _ = unpack(combatLogEvent);

		local sourceData = CreatePresenceDataFromCombatLogEvent(sourceName, sourceFlags, spellName);
		if (sourceData) then
			RegisterNewPresence(sourceData);
		end

		local targetData = CreatePresenceDataFromCombatLogEvent(targetName, targetFlags);
		if (targetData) then
			RegisterNewPresence(targetData);
		end

		if (sourceData or targetData) then
			CallNewPresenceHandlers();
		end
	end
end
frame:SetScript("OnEvent", OnEvent);

--
--
--

Threatrack_GetFreshPresenceData = GetFreshPresenceData;
Threatrack_HandleNewPresence = HandleNewPresence;
Threatrack_IsPresenceStale = IsPresenceStale;
