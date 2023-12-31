-- Reelease
-- MIT License © 2023 Arthur Corenzan
-- More on https://github.com/haggen/wow

---Add-on namespace.
---@type string
local REELEASE = ...;

---Add-on API.
---@class API.
local api = select(..., 2);

---Frame mixin.
---@class Frame
ReeleaseFrameMixin = {};

---OnLoad handler.
function ReeleaseFrameMixin:OnLoad()
	self:RegisterEvent("ADDON_LOADED");
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
end

---OnEvent handler.
---@param event string
function ReeleaseFrameMixin:OnEvent(event, ...)
	if (event == "ADDON_LOADED") then
		self:OnAddonLoaded(...);
	elseif (event == "UNIT_SPELLCAST_CHANNEL_START") then
		self:OnUnitSpellcastChannelStart(...);
	elseif (event == "UNIT_SPELLCAST_CHANNEL_STOP") then
		self:OnUnitSpellcastChannelStop(...);
	end
end

---Event handler.
---@param name string
function ReeleaseFrameMixin:OnAddonLoaded(name)
	if (name ~= REELEASE) then
		return;
	end

	api:InitSavedVars();
end

--Event handler.
---@param unitTarget string
---@param castGUID string
---@param spellID number
function ReeleaseFrameMixin:OnUnitSpellcastChannelStart(unitTarget, castGUID, spellID)
	if not api:IsFishing(spellID) then
		return;
	end

	api:OverrideCVar("SoftTargetInteractArc", 2);
	api:OverrideCVar("SoftTargetInteractRange", 30);

	if api.savedVars.attenuateSounds then
		api:OverrideCVar("Sound_SFXVolume", 1);
		api:OverrideCVar("Sound_MusicVolume", function(value) return tonumber(value) * 0.5; end);
		api:OverrideCVar("Sound_AmbienceVolume", function(value) return tonumber(value) * 0.5; end);
		api:OverrideCVar("Sound_DialogVolume", function(value) return tonumber(value) * 0.5; end);
	end

	if api.savedVars.reelKey then
		SetBinding(api.savedVars.reelKey, "INTERACTTARGET", GetCurrentBindingSet());
	end
end

--Event handler.
---@param unitTarget string
---@param castGUID string
---@param spellID number
function ReeleaseFrameMixin:OnUnitSpellcastChannelStop(unitTarget, castGUID, spellID)
	if not api:IsFishing(spellID) then
		return;
	end

	api:RestoreCVar("SoftTargetInteractArc");
	api:RestoreCVar("SoftTargetInteractRange");

	api:RestoreCVar("Sound_SFXVolume");
	api:RestoreCVar("Sound_MusicVolume");
	api:RestoreCVar("Sound_AmbienceVolume");
	api:RestoreCVar("Sound_DialogVolume");

	LoadBindings(GetCurrentBindingSet());
end