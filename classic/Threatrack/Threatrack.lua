-- Threatrack
-- MIT License © 2019 Arthur Corenzan
-- More on https://github.com/haggen/wow

-- Grab add-on name from local space.
--
local NAMESPACE = ...;

-- Flag/value for combat log event hostile reaction.
--
local HOSTILE = 0x00000040;

-- High level hostile players.
--
local SKULL = -1;

-- Max player level.
--
local MAXED = 60;

-- Gap between portraits.
--
local GUTTER = 8;

--
--
--

-- At which estimated level it should be displayed instead of Skull level (??).
--
local function EstimatedLevelThreshold()
	return UnitLevel("player") + 10;
end

-- Tells whether the Skull icon should be displayed given a player's level information.
--
local function ShouldDisplaySkullLevel(data)
	if (data.effectiveLevel == SKULL) then
		return data.estimatedLevel < EstimatedLevelThreshold();
	end
	return false;
end

-- Format player level's information to be displayed.
--
local function GetDisplayPlayerLevel(data)
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

-- Update portrait given stacked player data.
--
local function UpdateStackedPortrait(portrait, stackedData)
	portrait.Level:Show();
	portrait.Level:SetText(string.format("×%d", #stackedData.stack));

	portrait.Class:SetTexCoord(unpack(ThreatrackData:GetClassTexCoords(stackedData.class)));
end

-- Update portrait given flat player data.
--
local function UpdateFlatPortrait(portrait, data)
	if ShouldDisplaySkullLevel(data) then
		portrait.Skull:Show()
	else
		portrait.Level:Show();
		local displayLevel = GetDisplayPlayerLevel(data);

		-- Small tweak to fix text alignment problems.
		--
		-- When we're showing an estimated level with append a "+" sign at the end.
		-- This kinda screws with the text alignment, unless the level starts with
		-- a "1". To help with we prepend a space character in every other case.
		if string.find(displayLevel, "^[2-9]%d?%+") then
			displayLevel = " "..displayLevel;
		end

		portrait.Level:SetText(displayLevel);

		if (displayLevel ~= "??") then
			local color = GetCreatureDifficultyColor(string.match(displayLevel, "%d+"));
			portrait.Level:SetTextColor(color.r, color.g, color.b);
		end
	end

	portrait.Class:SetTexCoord(unpack(ThreatrackData:GetClassTexCoords(data.class)));
end

-- ..
--
local function GetDisplayPlayerName(data)
	return data.name;
end

-- ...
--
local function SetStackedPortraitTooltip(data)
	GameTooltip:SetText(ThreatrackData:GetLocalizedClassName(data.class));

	local skip = 0;
	for i = 1, #data.stack do
		local details = string.format(TOOLTIP_UNIT_LEVEL_RACE_CLASS, GetDisplayPlayerLevel(data.stack[i]), ThreatrackData:GetLocalizedRaceName(data.stack[i].race), "");

		local frame = _G["GameTooltipTextLeft"..(i * 2 + skip)];
		frame:SetHeight(18);
		frame:SetJustifyV("BOTTOM");

		GameTooltip:AddLine(GetDisplayPlayerName(data.stack[i]));
		if (data.stack[i].guild) then
			GameTooltip:AddLine(data.stack[i].guild.name, DIM_GREEN_FONT_COLOR:GetRGB());
			skip = skip + 1;
		end
		GameTooltip:AddLine(details, 1, 1, 1);
	end
end

-- ...
--
local function SetFlatPortraitTooltip(data)
	local details = string.format(TOOLTIP_UNIT_LEVEL_RACE_CLASS, GetDisplayPlayerLevel(data), ThreatrackData:GetLocalizedRaceName(data.race), ThreatrackData:GetLocalizedClassName(data.class));
	GameTooltip:SetText(GetDisplayPlayerName(data));
	if (data.guild) then
		GameTooltip:AddLine(data.guild.name, DIM_GREEN_FONT_COLOR:GetRGB());
	end
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

-- Portrait template mixin.
--
ThreatrackPortraitMixin = {};

-- Update portrait.
--
function ThreatrackPortraitMixin:Update(data)
	self.data = data;

	self.Skull:Hide();
	self.Level:Hide();
	self.Level:SetTextColor(NORMAL_FONT_COLOR:GetRGB());

	if (data.stack) then
		UpdateStackedPortrait(self, data);
	else
		UpdateFlatPortrait(self, data);
	end
end

-- Portrait OnUpdate handler. We use it to request an update once the data becomes stale.
--
function ThreatrackPortraitMixin:OnUpdate()
	if (not self:IsShown()) then
		return nil;
	end

	if (self.data.stack) then
		local stack = self.data.stack;
		for i = 1, #stack do
			if ThreatrackAPI:IsPresenceStale(stack[i]) then
				ThreatrackFrame:Update();
				return nil;
			end
		end
	else
		if ThreatrackAPI:IsPresenceStale(self.data) then
			ThreatrackFrame:Update();
		end
	end
end

-- Portrait OnEnter handler. Used to display tooltip.
--
function ThreatrackPortraitMixin:OnEnter()
	GameTooltip:ClearAllPoints();
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -8);
	GameTooltip:ClearLines();

	if (self.data.stack) then
		SetStackedPortraitTooltip(self.data);
	else
		SetFlatPortraitTooltip(self.data);
	end

	GameTooltip:Show();
end

-- Portrait OnEnter handler. Used to hide the tooltip.
--
function ThreatrackPortraitMixin:OnLeave()
	GameTooltip:Hide();
	RestoreTooltipTextHeight();
end

-- ...
--
function ThreatrackPortraitMixin:OnMouseDown(button)
	if (button == "RightButton") then
		ToggleDropDownMenu(1, nil, ThreatrackDropDown, "cursor", 0, -8);
	elseif (button == "LeftButton") then
		if (not ThreatrackFrame.isLocked) then
			ThreatrackFrame.isDragging = true;
			ThreatrackFrame:SetUserPlaced(true);
			ThreatrackFrame:StartMoving();
		end
	end
end

-- ...
--
function ThreatrackPortraitMixin:OnMouseUp()
	ThreatrackFrame.isDragging = nil;
	ThreatrackFrame:StopMovingOrSizing();
end

--
--
--

-- ...
--
local function SortStackedPresenceData(a, b)
	return ThreatrackData:GetClassOrder(a.class) < ThreatrackData:GetClassOrder(b.class);
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
			-- The stacked data is a table that is both sequential and associative.
			-- We use keyed indices to quickly check existing values, and the
			-- sequential numbered indices to sort and manipulate it later on.
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

-- ...
--
local function GetPresenceData(stackedModeThreshold)
	local data = ThreatrackAPI:GetFreshPlayerData();

	if (ThreatrackSavedVars.showHostileOnly) then
		local filteredData = {};
		for i = 1, #data do
			if (data[i].reaction == HOSTILE) then
				table.insert(filteredData, data[i]);
			end
		end
		data = filteredData;
	end

	if (#data > stackedModeThreshold) then
		data = StackPresenceData(data);
		table.sort(data, SortStackedPresenceData);
	else
		table.sort(data, SortFlatPresenceData);
	end

	return data;
end

--
--
--

ThreatrackFrameMixin = {};

-- ..
--
function ThreatrackFrameMixin:ShouldSkipUpdate()
	return self.isDragging;
end

-- ...
--
function ThreatrackFrameMixin:Update()
	if self:ShouldSkipUpdate() then
		return nil;
	end

	local presenceData = GetPresenceData(#self.portraits);

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

-- ..
--
function ThreatrackFrameMixin:ResetPosition()
	self:SetUserPlaced(false);
	self:ClearAllPoints();
	self:SetPoint("TOP", 0, -8);
end

-- ...
--
function ThreatrackFrameMixin:OnLoad()
	do
		-- The breath bar default position overlaps with our frame, so we move it a bit.
		-- See FrameXML/MirrorTimer.xml:80
		local point, relativeTo, relativePoint, x, y = MirrorTimer1:GetPoint(1);
		MirrorTimer1:ClearAllPoints();
		MirrorTimer1:SetPoint(point, relativeTo, relativePoint, x, y - 8);
	end

	ThreatrackAPI:HandlePlayerPresence(function()
		self:Update();
	end);

	self:RegisterEvent("ADDON_LOADED");
end

-- ...
--
function ThreatrackFrameMixin:OnEvent(event, ...)
	if (event == "ADDON_LOADED") then
		local name = ...;
		if (name == NAMESPACE) then
			self:SetScale(ThreatrackSavedVars.frameScale);
		end
	end
end

--
--
--

-- ..
--
ThreatrackDropDownMixin = {};

-- ..
--
function ThreatrackDropDownMixin:Initialize()
	UIDropDownMenu_AddButton({
		text = NAMESPACE,
		notCheckable = 1,
		isTitle = 1,
	});

	UIDropDownMenu_AddSeparator(1);

	UIDropDownMenu_AddButton({
		text = "Size",
		notCheckable = 1,
		isTitle = 1,
	});
	UIDropDownMenu_AddButton({
		text = "Default",
		checked = function()
			return (1 == ThreatrackFrame:GetScale());
		end,
		func = function()
			ThreatrackFrame:SetScale(1);
			ThreatrackSavedVars.frameScale = 1;
		end,
	});
	UIDropDownMenu_AddButton({
		text = "Small",
		checked = function()
			return (0.75 == ThreatrackFrame:GetScale());
		end,
		func = function()
			ThreatrackFrame:SetScale(0.75);
			ThreatrackSavedVars.frameScale = 0.75;
		end,
	});

	UIDropDownMenu_AddSeparator(1);

	UIDropDownMenu_AddButton({
		text = "Position",
		notCheckable = 1,
		isTitle = 1,
	});
	UIDropDownMenu_AddButton({
		text = "Reset",
		notCheckable = 1,
		func = function()
			ThreatrackFrame:ResetPosition();
		end,
	});

	UIDropDownMenu_AddSeparator(1);

	UIDropDownMenu_AddButton({
		text = "Cancel",
		notCheckable = 1,
	});
end

-- ..
--
function ThreatrackDropDownMixin:OnLoad()
	UIDropDownMenu_SetInitializeFunction(self, ThreatrackDropDownMixin.Initialize);
	UIDropDownMenu_SetDisplayMode(self, "MENU");
end

