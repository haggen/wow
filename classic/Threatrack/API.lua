-- Threatrack
-- MIT License © 2019 Arthur Corenzan
-- More on https://github.com/haggen/wow

-- Unknown values.
--
local UNKNOWN = "UNKNOWN";

-- Flag bits for unit reaction and type.
--
local HOSTILE = 0x00000040;
local FRIENDLY = 0x00000010;
local PLAYER = 0x00000400;

-- Sex values.
--
local MALE = 3;
local FEMALE = 2;

-- Time in seconds after which the player data becomes stale.
--
local FRESHNESS_THRESHOLD = 30;

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
		lastEncounterTime = GetTime(),
		lastDetectionTime = GetTime(),
		guid = nil,
		name = nil,
		sex = nil,
		race = nil,
		class = nil,
		reaction = nil,
		effectiveLevel = 0,
		estimatedLevel = 0,
	};
end

-- Tell whether given player data is stale, i.e. past the freshness threshold.
--
local function IsPresenceStale(data)
	return GetTime() - data.lastDetectionTime > FRESHNESS_THRESHOLD;
end

-- Given old and new values, solve for which one should be honored.
--
local function MergePlayerDataKey(key, oldData, newData)
	if (key == "lastEncounterTime") then
		if IsPresenceStale(oldData) then
			return newData[key];
		else
			return oldData[key];
		end
	elseif (key == "lastDetectionTime") then
		return newData[key];
	elseif (key == "effectiveLevel") then
		if (newData[key] == 0) then
			return oldData[key];
		end
	elseif (key == "estimatedLevel") then
		return math.max(oldData[key], newData[key]);
	end

	if (newData[key]) then
		return newData[key];
	end

	return oldData[key];
end

-- Update existing player data.
--
local function UpdatePlayerData(oldData, newData)
	for key, _ in pairs(newData) do
		oldData[key] = MergePlayerDataKey(key, oldData, newData);
	end
end

-- Table of detected player data.
--
local detectedPlayers = {};

-- Register player presence into the table.
--
local function RegisterPlayerData(newData)
	local oldData = detectedPlayers[newData.guid];
	if (oldData) then
		UpdatePlayerData(oldData, newData);
	else
		detectedPlayers[newData.guid] = newData;
	end
end

-- Return fresh player presence data.
--
local function GetFreshPlayerData()
	local freshlyDetectedPlayers = {};
	for _, data in pairs(detectedPlayers) do
		if (not IsPresenceStale(data)) then
			table.insert(freshlyDetectedPlayers, data);
		end
	end
	return freshlyDetectedPlayers;
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

	data.guid = UnitGUID(unit);
	data.name = GetUnitName(unit);
	data.sex = UnitSex(unit);
	data.race = select(2, UnitRace(unit));
	data.class = select(2, UnitClass(unit));
	data.effectiveLevel = UnitLevel(unit);

	if UnitIsEnemy(unit, "player") then
		data.reaction = HOSTILE;
	elseif UnitIsFriend(unit, "player") then
		data.reaction = FRIENDLY;
	end

	return data;
end

-- Tell whether a combat log event source or target has a
-- friendly, hostile or unknown reaction towards the player.
--
local function ReadCombatLogFlagsReaction(flags)
	if (HOSTILE == bit.band(flags, HOSTILE)) then
		return HOSTILE;
	elseif (FRIENDLY == bit.band(flags, FRIENDLY)) then
		return FRIENDLY;
	end
	return nil;
end

-- Tell whether a combat log event source or target is a player.
--
local function IsCombatLogFlagsTypePlayer(flags)
	return PLAYER == bit.band(flags, PLAYER);
end

-- Collect player data from combat log event source or target player.
--
local function CreatePlayerDataFromCombatLogEvent(guid, flags, spellName)
	if (not IsCombatLogFlagsTypePlayer(flags)) then
		return nil;
	end

	local data = CreatePlayerData();

	data.guid = guid;
	data.reaction = ReadCombatLogFlagsReaction(flags);

	_, data.class, _, data.race, data.sex, data.name = GetPlayerInfoByGUID(guid);

	if (spellName) then
		local spellData = THREATRACK_SPELL_DATA[spellName];
		if (spellData) then
			data.estimatedLevel = spellData[3];
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
			RegisterPlayerData(data);
			CallPlayerPresenceHandlers();
		end
	elseif (event == "UPDATE_MOUSEOVER_UNIT") then
		local data = CreatePlayerDataFromUnit("mouseover");
		if (data) then
			RegisterPlayerData(data);
			CallPlayerPresenceHandlers();
		end
	elseif (event == "COMBAT_LOG_EVENT_UNFILTERED") then
		local _, _, _, sourceGuid, _, sourceFlags, _, targetGuid, _, targetFlags,
			_, _, spellName, _, _, _, _, _, _, _, _ = CombatLogGetCurrentEventInfo();

		local sourceData = CreatePlayerDataFromCombatLogEvent(sourceGuid, sourceFlags, spellName);
		if (sourceData) then
			RegisterPlayerData(sourceData);
		end

		local targetData = CreatePlayerDataFromCombatLogEvent(targetGuid, targetFlags);
		if (targetData) then
			RegisterPlayerData(targetData);
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
