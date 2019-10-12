-- Threatrack
-- MIT License © 2019 Arthur Corenzan
-- More on https://github.com/haggen/wow

-- Add-on namespace.
--
local NAMESPACE = ...;

-- Default values.
--
local defaultSavedVars = {
	devMode = false,
	showHostileOnly = true,
	frameScale = 1,
};

-- Enforce schema by deleting unrecognized keys from
-- current saved vars and setting new defaults.
--
local function UpdateSavedVars(default, current)
	for key, defaultValue in pairs(default) do
		if (current[key] == nil) then
			current[key] = defaultValue;
		end
	end

	for key, currentValue in pairs(current) do
		if (default[key] == nil) then
			current[key] = nil;
		end

		if ("table" == type(currentValue)) then
			UpdateSavedVars(default[key], currentValue);
		end
	end
end

do
	local frame = CreateFrame("FRAME");

	-- Wait for saved variables to be loaded.
	--
	frame:SetScript("OnEvent", function(self, event, ...)
		if (event == "ADDON_LOADED") then
			local name = ...;
			if (name == NAMESPACE) then
				UpdateSavedVars(defaultSavedVars, ThreatrackSavedVars);
			end
		end
	end);
	frame:RegisterEvent("ADDON_LOADED");
end
