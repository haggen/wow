-- Threatrack
-- MIT License © 2019 Arthur Corenzan
-- More on https://github.com/haggen/wow

local NAMESPACE = ...;

-- Enforce saved variables schema by deleting unrecognized keys
-- from current saved vars and setting new default values.
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

local defaultSavedVars = {
	showHostileOnly = true,
	frameScale = 1,
};

do
	local frame = CreateFrame("FRAME");
	frame:RegisterEvent("ADDON_LOADED");

	-- ...
	--
	frame:SetScript("OnEvent", function(self, event, ...)
		if (event == "ADDON_LOADED") then
			local name = ...;
			if (name == NAMESPACE) then
				UpdateSavedVars(defaultSavedVars, ThreatrackSavedVars);
			end
		end
	end);
end
