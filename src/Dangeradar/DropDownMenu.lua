-- Dangeradar
-- MIT License © 2019 Arthur Corenzan
-- More on https://github.com/haggen/wow

-- Add-on namespace.
--
local DANGERADAR = ...;

local SCALE = {
	default = 1,
	small = 0.75,
};

-- ..
--
DangeradarMenuMixin = {};

-- ..
--
function DangeradarMenuMixin:Initialize()
	UIDropDownMenu_AddButton({
		text = DANGERADAR,
		notCheckable = 1,
		isTitle = 1,
	});

	if (DangeradarSavedVars.developerMode) then
		UIDropDownMenu_AddButton({
			text = "Show Hostile Only",
			isNotRadio = 1,
			checked = function()
				return (DangeradarSavedVars.showHostileOnly);
			end,
			func = function()
				DangeradarSavedVars.showHostileOnly = not DangeradarSavedVars.showHostileOnly;
			end,
		});
		UIDropDownMenu_AddButton({
			text = "Verbose Mode",
			isNotRadio = 1,
			checked = function()
				return (DangeradarSavedVars.verboseMode);
			end,
			func = function()
				DangeradarSavedVars.verboseMode = not DangeradarSavedVars.verboseMode;
			end,
		});
	end

	UIDropDownMenu_AddSeparator(1);
	UIDropDownMenu_AddButton({
		text = "Size",
		notCheckable = 1,
		isTitle = 1,
	});
	UIDropDownMenu_AddButton({
		text = "Default",
		checked = function()
			return (SCALE.default == DangeradarFrame:GetScale());
		end,
		func = function()
			DangeradarFrame:SetScale(SCALE.default);
			DangeradarSavedVars.frameScale = SCALE.default;
		end,
	});
	UIDropDownMenu_AddButton({
		text = "Small",
		checked = function()
			return (SCALE.small == DangeradarFrame:GetScale());
		end,
		func = function()
			DangeradarFrame:SetScale(SCALE.small);
			DangeradarSavedVars.frameScale = SCALE.small;
		end,
	});

	UIDropDownMenu_AddSeparator(1);
	UIDropDownMenu_AddButton({
		text = "Position",
		notCheckable = 1,
		isTitle = 1,
	});
	UIDropDownMenu_AddButton({
		text = "Reset",
		notCheckable = 1,
		func = function()
			DangeradarFrame:ResetPosition();
		end,
	});

	UIDropDownMenu_AddSeparator(1);
	UIDropDownMenu_AddButton({
		text = "Cancel",
		notCheckable = 1,
	});
end

-- ..
--
function DangeradarMenuMixin:OnLoad()
	UIDropDownMenu_SetInitializeFunction(self, DangeradarMenuMixin.Initialize);
	UIDropDownMenu_SetDisplayMode(self, "MENU");
end
