-- Threatrack
-- MIT License © 2019 Arthur Corenzan
-- More on https://github.com/haggen/wow

-- Constants.
--
local UNKNOWN = "UNKNOWN";
local HOSTILE = "HOSTILE";
local FRIENDLY = "FRIENDLY";
local FEMALE = "FEMALE";
local MALE = "MALE";
local SKULL = -1;

local FLAG_FRIENDLY = COMBATLOG_OBJECT_REACTION_FRIENDLY;
local FLAG_HOSTILE = COMBATLOG_OBJECT_REACTION_HOSTILE;
local FLAG_PLAYER = COMBATLOG_OBJECT_TYPE_PLAYER;

-- Time in seconds after which the player data becomes stale.
--
local FRESHNESS_THRESHOLD = 20;

-- Registry of handlers to player presence detection.
--
local playerPresenceHandlers = {};

-- Register playe presence detection handler.
--
local function HandlePlayerPresence(handler)
	table.insert(playerPresenceHandlers, handler);
end

-- Walk through the registry and fire new presence detection handlers.
--
local function CallPlayerPresenceHandlers()
	for i = 1, #playerPresenceHandlers do
		playerPresenceHandlers[i]();
	end
end

-- Returns a blank player data object.
--
local function CreatePlayerData()
	return {
		firstDetectionTime = GetTime(),
		lastDetectionTime = GetTime(),
		name = "",
		sex = UNKNOWN,
		race = UNKNOWN,
		class = UNKNOWN,
		effectiveLevel = 0,
		estimatedLevel = 0,
		reaction = UNKNOWN,
	};
end

-- Given old and new values, solve for which one should be honored.
--
local function MergePlayerDataValue(key, oldValue, newValue)
	if (key == "lastDetectionTime") then
		return newValue;
	elseif (key == "name") then
		if (newValue == "") then
			return oldValue;
		else
			return newValue;
		end
	elseif (key == "sex") or (key == "race") or (key == "class") or (key == "reaction") then
		if (newValue == UNKNOWN) then
			return oldValue;
		else
			return newValue;
		end
	elseif (key == "effectiveLevel") then
		if (newValue == SKULL) then
			return newValue;
		else
			return math.max(oldValue, newValue);
		end
	elseif (key == "estimatedLevel") then
		return math.max(oldValue, newValue);
	end

	return oldValue;
end

-- Update existing player data.
--
local function UpdatePlayerData(oldData, newData)
	for key, newValue in pairs(newData) do
		oldData[key] = MergePlayerDataValue(key, oldData[key], newValue);
	end
end

-- Database of player presence detected data during the current session.
--
-- TODO: This table only grows, and it's looped over every time
-- player player data is requested so we should fix it, eventually.
--
local allPlayerData = {};

-- Register new player data into the database.
--
local function RegisterPlayerPresence(playerData)
	for i = 1, #allPlayerData do
		if (playerData.name == allPlayerData[i].name) then
			UpdatePlayerData(allPlayerData[i], playerData);
			return nil;
		end
	end
	table.insert(allPlayerData, playerData);
end

-- Tell whether given player data is stale, i.e. past the freshness threshold.
--
local function IsPresenceStale(data)
	return GetTime() - data.lastDetectionTime > FRESHNESS_THRESHOLD;
end

-- Return fresh player presence data.
--
local function GetFreshPlayerData()
	local freshPlayerData = {};
	for i = 1, #allPlayerData do
		if (not IsPresenceStale(allPlayerData[i])) then
			table.insert(freshPlayerData, allPlayerData[i]);
		end
	end
	return freshPlayerData;
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

-- Derive player player data from given unit.
--
local function CreatePlayerDataFromUnit(unit)
	if (not UnitIsPlayer(unit)) then
		return nil;
	end

	local data = CreatePlayerData();

	data.name = GetUnitName(unit);
	data.race = string.upper(select(2, UnitRace(unit)));
	data.class = select(2, UnitClass(unit));
	data.effectiveLevel = UnitLevel(unit);

	if UnitIsEnemy(unit, "player") then
		data.reaction = HOSTILE;
	elseif UnitIsFriend(unit, "player") then
		data.reaction = FRIENDLY;
	end

	local sex = UnitSex(unit);
	if (sex == 2) then
		data.sex = MALE;
	elseif (sex == 3) then
		data.sex = FEMALE;
	end

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

-- Collect player data from combat log event source or target player.
--
local function CreatePlayerDataFromCombatLogEvent(name, flags, spell)
	if (not IsCombatLogFlagsTypePlayer(flags)) then
		return nil;
	end

	local data = CreatePlayerData();

	data.name = name or "";
	data.reaction = ReadCombatLogFlagsReaction(flags);

	if (spell) then
		local estimateData = THREATRACK_SPELL_DATA[spell];
		if (estimateData) then
			data.race = estimateData[1] or UNKNOWN;
			data.class = estimateData[2] or UNKNOWN;
			data.estimatedLevel = estimateData[3];
		end
	end

	return data;
end

-- Event handler.
--
local function OnEvent(_, event)
	if (event == "PLAYER_TARGET_CHANGED") then
		local data = CreatePlayerDataFromUnit("target");
		if (data) then
			RegisterPlayerPresence(data);
			CallPlayerPresenceHandlers();
		end
	elseif (event == "UPDATE_MOUSEOVER_UNIT") then
		local data = CreatePlayerDataFromUnit("mouseover");
		if (data) then
			RegisterPlayerPresence(data);
			CallPlayerPresenceHandlers();
		end
	elseif (event == "COMBAT_LOG_EVENT_UNFILTERED") then
		local combatLogEvent = {CombatLogGetCurrentEventInfo()};

		-- local timestamp, event, hideCaster, sourceGuid, sourceName, sourceFlags, sourceRaidFlags,
		-- 	targetGuid, targetName, targetFlags, targetRaidFlags, _, spellName, _, _, _, _, _, _, _ = unpack(combatLogEvent);

		local sourceData = CreatePlayerDataFromCombatLogEvent(combatLogEvent[5], combatLogEvent[6], combatLogEvent[13]);
		if (sourceData) then
			RegisterPlayerPresence(sourceData);
		end

		local targetData = CreatePlayerDataFromCombatLogEvent(combatLogEvent[9], combatLogEvent[10]);
		if (targetData) then
			RegisterPlayerPresence(targetData);
		end

		if (sourceData or targetData) then
			CallPlayerPresenceHandlers();
		end
	end
end
frame:SetScript("OnEvent", OnEvent);

--
--
--

Threatrack_GetFreshPlayerData = GetFreshPlayerData;
Threatrack_HandlePlayerPresence = HandlePlayerPresence;
Threatrack_IsPresenceStale = IsPresenceStale;
