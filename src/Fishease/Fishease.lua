-- Fishease
-- MIT License © 2023 Arthur Corenzan
-- More on https://github.com/haggen/wow

---Add-on namespace.
---@type string
local FISHEASE = ...;

---Add-on API.
---@type API
local api = select(2, ...);

---Frame mixin.
---@class FisheaseFrameMixin: Frame
FisheaseFrameMixin = {};

---OnLoad handler.
function FisheaseFrameMixin:OnLoad()
	self:RegisterEvent("ADDON_LOADED");
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
	self:RegisterEvent("PLAYER_REGEN_DISABLED");
end

---OnEvent handler.
---@param event string
function FisheaseFrameMixin:OnEvent(event, ...)
	if (event == "ADDON_LOADED") then
		self:OnAddonLoaded(...);
	elseif (event == "UNIT_SPELLCAST_CHANNEL_START") then
		self:OnUnitSpellcastChannelStart(...);
	elseif (event == "UNIT_SPELLCAST_CHANNEL_STOP") then
		self:OnUnitSpellcastChannelStop(...);
	elseif (event == "PLAYER_REGEN_DISABLED") then
		api:RestoreSoundSettings();
	end
end

---Event handler.
---@param name string
function FisheaseFrameMixin:OnAddonLoaded(name)
	if (name ~= FISHEASE) then
		return;
	end

	api:InitSavedVars();
	---In case we disconnected while fishing.
	api:RestoreAllSettings();
end

--Event handler.
---@param unitTarget string
---@param castGUID string
---@param spellID number
function FisheaseFrameMixin:OnUnitSpellcastChannelStart(unitTarget, castGUID, spellID)
	if not api:IsFishing(spellID) then
		return;
	end

	api:Activate();
end

--Event handler.
---@param unitTarget string
---@param castGUID string
---@param spellID number
function FisheaseFrameMixin:OnUnitSpellcastChannelStop(unitTarget, castGUID, spellID)
	if not api:IsFishing(spellID) then
		return;
	end

	api:RestoreAllSettings();
end
