-- Powerythm
-- The MIT License © 2019 Arthur Corenzan

UIParentLoadAddOn("Blizzard_DebugTools");

local function d(...)
	print(string.format("[%d]", GetTime()), ...);
end

local power = {
	type = "",
	value = 0,
	max = 0,
	delta = 0,
};

local function UpdatePower() 
	_, power.type = UnitPowerType("player");
	local value = UnitPower("player");
	power.max = UnitPowerMax("player");
	power.delta = value - power.value;
	power.value = value;

	if (power.delta < 0) then
		PowerythmFrameTexture.color = {1.0, 0.5, 0.0, 1.0};
	elseif (power.delta > 0) then
		if (power.type == "MANA") then
			PowerythmFrameTexture.color = {0.0, 0.0, 1.0, 1.0};
		elseif (power.type == "ENERGY") then
			PowerythmFrameTexture.color = {1.0, 1.0, 0.0, 1.0};
		else
			PowerythmFrameTexture.color = {0.5, 0.5, 0.5, 1.0};
		end
	end
end

function PowerythmFrame_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
	self:RegisterEvent("UNIT_POWER_UPDATE");
	self:RegisterEvent("UNIT_POWER_FREQUENT");
	self:RegisterEvent("PLAYER_REGEN_ENABLED");
	self:RegisterEvent("PLAYER_REGEN_DISABLED");

	self:RegisterForDrag("LeftButton");

	PowerythmFrameTexture.color = {0.0, 0.0, 0.0, 0.0};
end

function PowerythmFrame_OnEvent(self, event, ...)
	if (event == "PLAYER_ENTERING_WORLD") then
		UpdatePower();
	elseif (event == "UPDATE_SHAPESHIFT_FORM") then
		UpdatePower();
	elseif (event == "UNIT_POWER_UPDATE") then
		UpdatePower();
	elseif (event == "UNIT_POWER_FREQUENT") then
	elseif (event == "PLAYER_REGEN_ENABLED") then
	elseif (event == "PLAYER_REGEN_DISABLED") then
	end
end

function PowerythmFrame_OnDragStart(self)
	if (not self.isLocked) then
		self:StartMoving()
	end
end

function PowerythmFrame_OnDragStop(self)
	self:StopMovingOrSizing()
end

local step = 0.001;

function PowerythmFrame_OnUpdate(self, elapsed)
	PowerythmFrameTexture:SetColorTexture(unpack(PowerythmFrameTexture.color));

	local r, g, b, a = unpack(PowerythmFrameTexture.color);
	PowerythmFrameTexture.color = {
		r * 0.995,
		g * 0.995,
		b * 0.995,
		a * 0.995,
	};
end