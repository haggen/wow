-- Dangeradar
-- MIT License © 2019 Arthur Corenzan
-- More on https://github.com/haggen/wow

-- Grab add-on name from local space.
--
local NAMESPACE = ...;

-- Flag/value for combat log event hostile reaction.
--
local HOSTILE = 0x00000040;

-- Gap between portraits.
--
local GUTTER = 8;

--
--
--

-- ...
--
local function SortStackedPresenceData(a, b)
	return DangeradarData:GetClassOrder(a.class) < DangeradarData:GetClassOrder(b.class);
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
				stack = { data[i] },
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
	local data = DangeradarAPI:GetFreshPlayerData();

	if (DangeradarSavedVars.showHostileOnly) then
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

DangeradarFrameMixin = {};

-- ..
--
function DangeradarFrameMixin:ShouldSkipUpdate()
	return self.isDragging;
end

-- ...
--
function DangeradarFrameMixin:Update()
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
function DangeradarFrameMixin:ResetPosition()
	self:SetUserPlaced(false);
	self:ClearAllPoints();
	self:SetPoint("TOP", 0, -8);
end

-- ...
--
function DangeradarFrameMixin:OnLoad()
	do
		-- The breath bar default position overlaps with our frame, so we move it a bit.
		-- See FrameXML/MirrorTimer.xml:80
		local point, relativeTo, relativePoint, x, y = MirrorTimer1:GetPoint(1);
		MirrorTimer1:ClearAllPoints();
		MirrorTimer1:SetPoint(point, relativeTo, relativePoint, x, y - 8);
	end

	DangeradarAPI:HandlePlayerPresence(function()
		self:Update();
	end);

	self:RegisterEvent("ADDON_LOADED");
end

-- ...
--
function DangeradarFrameMixin:OnEvent(event, ...)
	if (event == "ADDON_LOADED") then
		local name = ...;
		if (name == NAMESPACE) then
			self:SetScale(DangeradarSavedVars.frameScale);
		end
	end
end
