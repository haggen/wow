-- Threatrack
-- MIT License © 2019 Arthur Corenzan
-- More on https://github.com/haggen/wow

-- High level hostile players.
--
local SKULL = -1;

-- Max player level.
--
local MAXED = 60;

-- Colors. Stolen from WoW default interface.
RegularColor = CreateColor(1.0, 0.82, 0.0);
GuildColor = CreateColor(0.251, 0.753, 0.251);

--
--
--

-- ...
--
ThreatrackPortraitTextureMixin = {};

-- ...
--
function ThreatrackPortraitTextureMixin:SetRace(race)
	self:SetTexCoord(unpack(ThreatrackData:GetRaceTexCoords(race)));
end

-- ...
--
function ThreatrackPortraitTextureMixin:SetClass(class)
	self:SetTexCoord(unpack(ThreatrackData:GetClassTexCoords(class)));
end

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

	portrait.Texture:SetTexCoord(unpack(ThreatrackData:GetClassTexCoords(stackedData.class)));
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

	portrait.Texture:SetTexCoord(unpack(ThreatrackData:GetClassTexCoords(data.class)));
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
			GameTooltip:AddLine(data.stack[i].guild.name, GuildColor:GetRGB());
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
		GameTooltip:AddLine(data.guild.name, GuildColor:GetRGB());
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
	self.Level:SetTextColor(RegularColor:GetRGB());

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
		ToggleDropDownMenu(1, nil, ThreatrackMenu, "cursor", 0, -8);
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
