-- Threatrack
-- MIT License © 2019 Arthur Corenzan
-- More on https://github.com/haggen/wow

-- Add-on namespace.
--
local THREATRACK = ...;

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
	for key, defaultValue in pairs(defaults) do
		if (savedVars[key] == nil) then
			savedVars[key] = defaultValue;
		end
	end

	for key, value in pairs(savedVars) do
		if (defaults[key] == nil) then
			savedVars[key] = nil;
		end

		if ("table" == type(value)) then
			UpdateSavedVars(defaults[key], value);
		end
	end
end

do
	local frame = CreateFrame("FRAME");

	-- Initialize global saved vars.
	ThreatrackSavedVars = {};

	-- Wait for saved variables to be loaded.
	--
	frame:SetScript("OnEvent", function(self, event, ...)
		if (event == "ADDON_LOADED") then
			local name = ...;
			if (name == THREATRACK) then
				UpdateSavedVars(defaultSavedVars, ThreatrackSavedVars);
			end
		end
	end);
	frame:RegisterEvent("ADDON_LOADED");
end
