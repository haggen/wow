-- Fishease
-- MIT License © 2023 Arthur Corenzan
-- More on https://github.com/haggen/wow

---Add-on namespace.
---@type string
local FISHEASE = ...;

---Add-on API.
---@type API
local api = select(2, ...);

---Slash commands.
SLASH_FISHEASE1 = "/fishease";
SLASH_FISHEASE2 = "/fe";

---Parse boolean value out of human expression.
---@param value string
local function ParseBool(value)
	return value:match("(1|on|yes|true)") ~= nil;
end

---Slash command handler.
---@param message string
SlashCmdList.FISHEASE = function(message)
	---@type string, string
	local command, argument = message:lower():match("^(%S*)%s*(%S*)$");

	if command == "interactkey" then
		if argument ~= "" then
			api.savedVars.interactKey = argument:upper();
		end
		api:Print("Bobber interaction key is set to |cffff6699%s|r.", api.savedVars.interactKey);
	elseif command == "soundattenuation" then
		if argument ~= "" then
			api.savedVars.attenuateSounds = ParseBool(argument);
		end
		api:Print("Sound attenuation is |cffff6699%s|r.", api.savedVars.attenuateSounds and "on" or "off");
	else
		api:Print("Options:");
		api:Print("1. |cff44ff44interactkey|r - Bobber interaction key. Current is |cffff6699%s|r.", api.savedVars.interactKey);
		api:Print("2. |cff44ff44soundattenuation|r - Lower other sounds while fishing. Current is |cffff6699%s|r.", api.savedVars.attenuateSounds and "on" or "off");
		api:Print([[Type "|cffff6699/fe <option> <value>|r" to change it.]]);
	end
end