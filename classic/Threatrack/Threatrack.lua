-- Threatrack
-- MIT License © 2019 Arthur Corenzan
-- More on https://github.com/haggen/wow

-- High level hostile players.
--
local SKULL = -1;

-- Flag/value for combat log event hostile reaction.
--
local HOSTILE = 0x00000040;

-- Max player level.
--
local MAXED = 60;

-- Race enum.
--
local DWARF = "Dwarf";
local GNOME = "Gnome";
local HUMAN = "Human";
local NIGHTELF = "NightElf";
local ORC = "Orc";
local SCOURGE = "Scourge";
local TAUREN = "Tauren";
local TROLL = "Troll";

-- Class enum.
--
local DRUID = "DRUID";
local HUNTER = "HUNTER";
local MAGE = "MAGE";
local PALADIN = "PALADIN";
local PRIEST = "PRIEST";
local ROGUE = "ROGUE";
local SHAMAN = "SHAMAN";
local WARLOCK = "WARLOCK";
local WARRIOR = "WARRIOR";

-- ...
--
local SORT_RANKING = {
	[WARRIOR] = 1,
	[PALADIN] = 2,
	[ROGUE] = 3,
	[HUNTER] = 4,
	[DRUID] = 5,
	[SHAMAN] = 6,
	[PRIEST] = 7,
	[MAGE] = 8,
	[WARLOCK] = 9,
};

-- Used for getting localized names.
--
local CLASS_RACE_IDS = {
	[DWARF] = 3,
	[GNOME] = 7,
	[HUMAN] = 1,
	[NIGHTELF] = 4,
	[ORC] = 2,
	[SCOURGE] = 5,
	[TAUREN] = 6,
	[TROLL] = 8,
	[DRUID] = 11,
	[HUNTER] = 3,
	[MAGE] = 8,
	[PALADIN] = 2,
	[PRIEST] = 5,
	[ROGUE] = 4,
	[SHAMAN] = 7,
	[WARLOCK] = 9,
	[WARRIOR] = 1,
};

-- Gap between portraits.
--
local GUTTER = 8;

-- Coordinates for cropping race/class texture maps.
--
local TEXTURE_COORDS = {
	[WARRIOR] = {0.011718750, 0.238281250, 0.01171875, 0.23828125},
	[MAGE] = {0.257812500, 0.484375000, 0.01171875, 0.23828125},
	[ROGUE] = {0.503906250, 0.730468750, 0.01171875, 0.23828125},
	[DRUID] = {0.750000000, 0.976562500, 0.01171875, 0.23828125},
	[HUNTER] = {0.011718750, 0.238281250, 0.26171875, 0.48828125},
	[SHAMAN] = {0.257812500, 0.484375000, 0.26171875, 0.48828125},
	[PRIEST] = {0.503906250, 0.730468750, 0.26171875, 0.48828125},
	[WARLOCK] = {0.753906250, 0.980468750, 0.26171875, 0.48828125},
	[PALADIN] = {0.011718750, 0.238281250, 0.51171875, 0.73828125},
};

--
--
--

-- ...
--
local function EstimatedLevelThreshold()
	return UnitLevel("player") + 10;
end

-- Tell whether the Skull icon should be displayed given a player's level information.
--
local function ShouldDisplaySkullLevel(data)
	if (data.effectiveLevel == SKULL) then
		return data.estimatedLevel < EstimatedLevelThreshold();
	end
	return false;
end

-- Format player level's information to be displayed.
--
local function GetDisplayLevel(data)
	if (data.effectiveLevel > 0) then
		return tostring(data.effectiveLevel);
	end
	if (data.estimatedLevel > 0) then
		if (data.effectiveLevel ~= SKULL or data.estimatedLevel > EstimatedLevelThreshold()) then
			if (data.estimatedLevel == MAXED) then
				return MAXED;
			else
				return string.format("%d+", data.estimatedLevel);
			end
		end
	end
	return "??";
end

-- Update portrait frame given stacked data, i.e. non-flat.
--
local function UpdateStackedPortrait(portrait, data)
	portrait.Level:Show();
	portrait.Level:SetText(string.format("×%d", #data.stack));

	portrait.Class:SetTexCoord(unpack(TEXTURE_COORDS[data.class]));
end

-- Update portrait frame given flat data, i.e. non-stacked.
--
local function UpdateFlatPortrait(portrait, data)
	if ShouldDisplaySkullLevel(data) then
		portrait.Skull:Show()
	else
		portrait.Level:Show();
		local displayLevel = GetDisplayLevel(data);
		-- Small tweak to fix text alignment problems due to the font not being fixed width.
		if string.find(displayLevel, "[2-6]%d?%+") then
			displayLevel = " "..displayLevel;
		end
		portrait.Level:SetText(displayLevel);

		if (displayLevel ~= "??") then
			local color = GetCreatureDifficultyColor(string.match(displayLevel, "%d+"));
			portrait.Level:SetVertexColor(color.r, color.g, color.b);
		end
	end

	portrait.Class:SetTexCoord(unpack(TEXTURE_COORDS[data.class]));
end

-- ...
--
local function GetLocalizedRaceName(race)
	return C_CreatureInfo.GetRaceInfo(CLASS_RACE_IDS[race]).raceName;
end

-- ...
--
local function GetLocalizedClassName(class)
	return C_CreatureInfo.GetClassInfo(CLASS_RACE_IDS[class]).className;
end

-- ...
--
local function SetStackedPortraitTooltip(data)
	GameTooltip:SetText(GetLocalizedClassName(data.class));

	for i = 1, #data.stack do
		local details = string.format(TOOLTIP_UNIT_LEVEL_RACE_CLASS, GetDisplayLevel(data.stack[i]), GetLocalizedRaceName(data.stack[i].race), "");
		GameTooltip:AddLine(data.stack[i].name or "??");
		GameTooltip:AddLine(details, 1, 1, 1);

		local frame = _G["GameTooltipTextLeft"..(i * 2)];
		frame:SetHeight(18);
		frame:SetJustifyV("BOTTOM");
	end
end

-- ...
--
local function SetFlatPortraitTooltip(data)
	local details = string.format(TOOLTIP_UNIT_LEVEL_RACE_CLASS, GetDisplayLevel(data), GetLocalizedRaceName(data.race), GetLocalizedClassName(data.class));
	GameTooltip:SetText(data.name or "??");
	GameTooltip:AddLine(details, 1, 1, 1);
end

-- ..
--
local function RestoreTooltipTextHeight()
	local frame = GameTooltipTextLeft1;
	local index = 1;

	while (frame ~= nil) do
		index = index + 1
		frame:SetHeight(0);
		frame = _G["GameTooltipTextLeft"..index];
	end
end

--
--
--

-- Portrait mixin.
--
ThreatrackPortrait = {};

-- Update portrait.
--
function ThreatrackPortrait:Update(data)
	self.data = data;

	self.Skull:Hide();
	self.Level:Hide();
	self.Level:SetVertexColor(NORMAL_FONT_COLOR:GetRGB());

	if (data.stack) then
		UpdateStackedPortrait(self, data);
	else
		UpdateFlatPortrait(self, data);
	end
end

-- Portrait OnUpdate handler. We use it to request an update once the data becomes stale.
--
function ThreatrackPortrait:OnUpdate()
	if (not self:IsShown()) then
		return nil;
	end

	if (self.data.stack) then
		local stack = self.data.stack;
		for i = 1, #stack do
			if Threatrack_IsPresenceStale(stack[i]) then
				Threatrack:Update();
				return nil;
			end
		end
	else
		if Threatrack_IsPresenceStale(self.data) then
			Threatrack:Update();
		end
	end
end

-- Portrait OnEnter handler. Used to display tooltip.
--
function ThreatrackPortrait:OnEnter()
	GameTooltip:ClearAllPoints();
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -8);

	if (self.data.stack) then
		SetStackedPortraitTooltip(self.data);
	else
		SetFlatPortraitTooltip(self.data);
	end

	GameTooltip:Show();
end

-- Portrait OnEnter handler. Used to hide the tooltip.
--
function ThreatrackPortrait:OnLeave()
	GameTooltip:Hide();
	RestoreTooltipTextHeight();
end

--
--
--

-- ...
--
local function SortStackedPresenceData(a, b)
	return SORT_RANKING[a.class] < SORT_RANKING[b.class];
end

-- ...
--
local function StackPresenceData(data)
	local stackedData = {};
	for i = 1, #data do
		local playerClass = data[i].class;

		if (stackedData[playerClass] == nil) then
			stackedData[playerClass] = {
				class = playerClass,
				stack = {data[i]},
			};
			-- stackedData is a numbered as well as associative table,
			-- we use hash maps to quickly check and gain access, but
			-- we also insert in a numbered position to be able to more
			-- easily sort and manipulate it later on.
			table.insert(stackedData, stackedData[playerClass]);
		else
			table.insert(stackedData[playerClass].stack, data[i]);
		end
	end
	return stackedData;
end

-- ...
--
local function SortFlatPresenceData(a, b)
	return a.lastEncounterTime < b.lastEncounterTime;
end

-- Enforce saved variables schema by deleting unrecognized keys from
-- from current saved vars and setting the default value for new .
--
local function Migrate(default, current)
	for key, defaultValue in pairs(default) do
		if (current[key] == nil) then
			current[key] = defaultValue;
		end
	end

	for key, currentValue in pairs(current) do
		if (default[key] == nil) then
			current[key] = nil;
		end

		if (type(currentValue) == "table") then
			Migrate(default[key], currentValue);
		end
	end
end

-- ...
--
local defaultSavedVars = {
	options = {
		showOnlyHostile = true
	},
};

-- ...
--
ThreatrackSavedVars = {};

--
--
--

-- Frame and mixin.
--
Threatrack = {};

-- ...
--
function Threatrack:GetPresenceData()
	local data = Threatrack_GetFreshPlayerData();

	if (ThreatrackSavedVars.options.showOnlyHostile) then
		local filteredData = {};
		for i = 1, #data do
			if (data[i].reaction == HOSTILE) then
				table.insert(filteredData, data[i]);
			end
		end
		data = filteredData;
	end

	if (#data > #self.portraits) then
		data = StackPresenceData(data);
		table.sort(data, SortStackedPresenceData);
	else
		table.sort(data, SortFlatPresenceData);
	end

	return data;
end

-- ...
--
function Threatrack:Update()
	local presenceData = self:GetPresenceData();

	self:SetWidth(0);

	for i = 1, #self.portraits do
		local portrait = self.portraits[i];
		local data = presenceData[i];

		portrait:ClearAllPoints();
		portrait:Hide();

		if data then
			portrait:Update(data);
			portrait:Show();

			if (i > 1) then
				portrait:SetPoint("LEFT", self.portraits[i - 1], "RIGHT", GUTTER, 0);
				self:SetWidth(self:GetWidth() + GUTTER + portrait:GetWidth());
			else
				portrait:SetPoint("LEFT", self);
				self:SetWidth(portrait:GetWidth());
			end
		end
	end
end

-- ...
--
function Threatrack:OnLoad()
	Threatrack = self;

	-- BreathBar default position overlaps with the portraits.
	-- FrameXML/MirrorTimer.xml:80
	MirrorTimer1:ClearAllPoints();
	MirrorTimer1:SetPoint("TOP", 0, -104);

	Threatrack_HandlePlayerPresence(function()
		self:Update();
	end);

	self:RegisterEvent("ADDON_LOADED");
end

-- ...
--
function Threatrack:OnEvent(event, ...)
	if (event == "ADDON_LOADED") then
		local name = ...;
		if (name == "Threatrack") then
			Migrate(defaultSavedVars, ThreatrackSavedVars);
		end
	end
end
