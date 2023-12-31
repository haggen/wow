-- Reelease
-- MIT License © 2023 Arthur Corenzan
-- More on https://github.com/haggen/wow

---Add-on namespace.
---@type string
local REELEASE = ...;

---Add-on API.
---@class API.
local api = select(..., 2);

---Saved variables.
---@class SavedVars
api.savedVars = {
	version = 1,
	reelKey = "1",
	attenuateSounds = true,
};

---Saved variables. Will be initialized by the game.
---@class SavedVars
ReeleaseSavedVars = {};

---Initialize saved variables.
function api:InitSavedVars()
	if (ReeleaseSavedVars.version ~= api.savedVars.version) then
		for key, value in pairs(api.savedVars) do
			if (ReeleaseSavedVars[key] == nil) then
				ReeleaseSavedVars[key] = value;
			end
		end

		for key in pairs(ReeleaseSavedVars) do
			if (api.savedVars[key] == nil) then
				ReeleaseSavedVars[key] = nil;
			end
		end

		ReeleaseSavedVars.version = api.savedVars.version;
	end

	api.savedVars = ReeleaseSavedVars;
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

---Saved CVar values.
---@type table<string, any>
local savedCVars = {};

---Override CVar saving the previous value.
---@param name string
---@param override any
function api:OverrideCVar(name, override)
	local savedValue = GetCVar(name);

	for key, value in pairs(savedCVars) do
		if (key == name) then
			savedValue = value;
		end
	end

	if type(override) == "function" then
		SetCVar(name, override(savedValue));
	else
		SetCVar(name, override);
	end

	savedCVars[name] = savedValue;
end

---Restore saved CVar value.
---@param name string
function api:RestoreCVar(name)
	for key, value in pairs(savedCVars) do
		if (key == name) then
			SetCVar(name, value);
			return;
		end
	end
end