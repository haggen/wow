-- Dangeradar
-- MIT License © 2019 Arthur Corenzan
-- More on https://github.com/haggen/wow

-- Add-on namespace.
--
local DANGERADAR = ...;

-- Default values.
--
local defaultSavedVars = {
	developerMode = false,
	verboseMode = false,
	showHostileOnly = true,
	frameScale = 1,
};

-- Enforce schema by deleting unrecognized keys from
-- current saved vars and setting new defaults.
--
local function UpdateSavedVars(defaults, savedVars)
	-- Remove keys with no defaults.
	for key in pairs(savedVars) do
		if (defaults[key] == nil) then
			savedVars[key] = nil;
		end
	end

	-- Set new keys.
	for key, defaultValue in pairs(defaults) do
		if (savedVars[key] == nil) then
			savedVars[key] = defaultValue;
		end
	end
end

do
	local frame = CreateFrame("FRAME");

	-- Initialize global table. Will be overwritten if existing saved vars are loaded.
	--
	DangeradarSavedVars = {};

	-- Wait for saved variables to be loaded.
	--
	frame:SetScript("OnEvent", function(self, event, ...)
		if (event == "ADDON_LOADED") then
			local name = ...;
			if (name == DANGERADAR) then
				UpdateSavedVars(defaultSavedVars, DangeradarSavedVars);
			end
		end
	end);
	frame:RegisterEvent("ADDON_LOADED");
end
