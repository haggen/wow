-- Fastbind
-- The MIT License © 2017 Arthur Corenzan
-- More on https://github.com/haggen/wow

-- Add-on name constant.
--
local FASTBIND = ...

-- Add-on table.
--
local api = select(2, ...)

-- Saved variables.
--
FastbindSavedVars = {}

-- Default values.
--
api.defaultSavedVars = {
	debug = false,
	minimapButtonPosition = 0,
}

-- Enforce schema by deleting unrecognized keys from
-- stored saved variables and setting new defaults.
--
function api.MigrateSavedVars()
	-- Remove keys with no default.
	for key in pairs(FastbindSavedVars) do
		if (api.defaultSavedVars[key] == nil) then
			FastbindSavedVars[key] = nil
		end
	end

	-- Set new keys.
	for key, defaultValue in pairs(api.defaultSavedVars) do
		if (FastbindSavedVars[key] == nil) then
			FastbindSavedVars[key] = defaultValue
		end
	end
end

-- Get saved variable.
--
function api.GetSavedVar(name)
	return FastbindSavedVars[name] or api.defaultSavedVars[name]
end

-- Set saved variable.
--
function api.SetSavedVar(name, value)
	FastbindSavedVars[name] = value
end

-- Dump variables, if debug is enabled.
--
function api.Dump(...)
	if not api.GetSavedVar("debug") then
		return
	end

	if not IsAddOnLoaded("Blizzard_DebugTools") then
		LoadAddOn("Blizzard_DebugTools")
	end

	DevTools_Dump({ FASTBIND, ... })
end

-- Print formatted message, if debug is enabled.
--
function api.Printf(message, ...)
	if not api.GetSavedVar("debug") then
		return
	end
	print(string.format("|cff00ff00%s|r: %s", FASTBIND, string.format(message, ...)))
end
