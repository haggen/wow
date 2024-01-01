-- Reelease
-- MIT License © 2023 Arthur Corenzan
-- More on https://github.com/haggen/wow

---Add-on namespace.
---@type string
local REELEASE = ...;

---Add-on API.
---@class API
local api = select(2, ...);

---Saved variables.
---@class SavedVars
---@field state `active`|`idle`
---@field version number
---@field interactKey string
---@field attenuateSounds boolean
---@field changedCVars table<string, any>
api.savedVars = {
	version = 3,
	state = "idle",
	interactKey = "F",
	attenuateSounds = true,
	changedCVars = {},
};

---Global saved variables.
ReeleaseSavedVars = api.savedVars;

---Initialize saved variables.
function api:InitSavedVars()
	if (ReeleaseSavedVars.version ~= self.savedVars.version) then
		for key, value in pairs(self.savedVars) do
			if (ReeleaseSavedVars[key] == nil) then
				ReeleaseSavedVars[key] = value;
			end
		end

		for key in pairs(ReeleaseSavedVars) do
			if (self.savedVars[key] == nil) then
				ReeleaseSavedVars[key] = nil;
			end
		end

		ReeleaseSavedVars.version = self.savedVars.version;
	end

	---Make so api.savedVars is the same table as ReeleaseSavedVars.
	self.savedVars = ReeleaseSavedVars;
end

---Tell if the given spell is Fishing.
---@param spellID number
function api:IsFishing(spellID) 
	if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
		return spellID == 7732;
	end
	if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
		return spellID == 131476;
	end
	return false;
end

---Override CVar saving the previous value.
---@param name string
---@param override any
function api:OverrideCVar(name, override)
	local savedValue = GetCVar(name);

	for key, value in pairs(self.savedVars.changedCVars) do
		if (key == name) then
			savedValue = value;
		end
	end

	if type(override) == "function" then
		SetCVar(name, override(savedValue));
	else
		SetCVar(name, override);
	end

	self.savedVars.changedCVars[name] = savedValue;
end

---Restore saved CVar value.
---@param name string
function api:RestoreCVar(name)
	for key, value in pairs(self.savedVars.changedCVars) do
		if (key == name) then
			SetCVar(name, value);
			self.savedVars.changedCVars[name] = nil;
			return;
		end
	end
end

---Attenuate sound volume.
---@param value string
local function Attenuate(value) 
	return tonumber(value) * 0.2;
end

---Tell if key name is valid.
---@param name string
local function IsValidKey(name)
	return name and not name:match("(unb(i|ou)nd|none|off|disabled)");
end

---Tweak game settings for fishing.
function api:Activate()
	self:OverrideCVar("SoftTargetInteract", 3);
	self:OverrideCVar("SoftTargetInteractArc", 2);
	self:OverrideCVar("SoftTargetInteractRange", 30);
	self:OverrideCVar("SoftTargetIconGameObject", 1);
	self:OverrideCVar("SoftTargetIconInteract", 1);

	if self.savedVars.attenuateSounds then
		self:OverrideCVar("Sound_SFXVolume", 1);
		self:OverrideCVar("Sound_MusicVolume", Attenuate);
		self:OverrideCVar("Sound_AmbienceVolume", Attenuate);
		self:OverrideCVar("Sound_DialogVolume", Attenuate);
	end

	if IsValidKey(self.savedVars.interactKey) then
		SetBinding(self.savedVars.interactKey, "INTERACTTARGET", GetCurrentBindingSet());
	end

	self.savedVars.state = "active";
end

---Restore sound settings.
function api:RestoreSoundSettings()
	self:RestoreCVar("Sound_SFXVolume");
	self:RestoreCVar("Sound_MusicVolume");
	self:RestoreCVar("Sound_AmbienceVolume");
	self:RestoreCVar("Sound_DialogVolume");
end

---Restore all change settings.
function api:RestoreAllSettings()
	self:RestoreCVar("SoftTargetInteract");
	self:RestoreCVar("SoftTargetInteractArc");
	self:RestoreCVar("SoftTargetInteractRange");
	self:RestoreCVar("SoftTargetIconGameObject");
	self:RestoreCVar("SoftTargetIconInteract");

	self:RestoreSoundSettings();

	if IsValidKey(self.savedVars.interactKey) then
		LoadBindings(GetCurrentBindingSet());
	end

	self.savedVars.state = "idle";
end

---Print to chat.
---@param message string
---@vararg string|number|boolean|nil
function api:Print(message, ...)
	print("|cff6666ffReelease|r: " .. message:format(...));
end
