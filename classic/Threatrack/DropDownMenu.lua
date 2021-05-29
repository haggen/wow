-- Threatrack
-- MIT License © 2019 Arthur Corenzan
-- More on https://github.com/haggen/wow

-- Add-on namespace.
--
local THREATRACK = ...;

local SCALE = {
	default = 1,
	small = 0.75,
};

-- ..
--
ThreatrackMenuMixin = {};

-- ..
--
function ThreatrackMenuMixin:Initialize()
	UIDropDownMenu_AddButton({
		text = THREATRACK,
		notCheckable = 1,
		isTitle = 1,
	});

	if (ThreatrackSavedVars.developerMode) then
		UIDropDownMenu_AddButton({
			text = "Show Hostile Only",
			isNotRadio = 1,
			checked = function()
				return (ThreatrackSavedVars.showHostileOnly);
			end,
			func = function()
				ThreatrackSavedVars.showHostileOnly = not ThreatrackSavedVars.showHostileOnly;
			end,
		});
		UIDropDownMenu_AddButton({
			text = "Verbose Mode",
			isNotRadio = 1,
			checked = function()
				return (ThreatrackSavedVars.verboseMode);
			end,
			func = function()
				ThreatrackSavedVars.verboseMode = not ThreatrackSavedVars.verboseMode;
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
			return (SCALE.default == ThreatrackFrame:GetScale());
		end,
		func = function()
			ThreatrackFrame:SetScale(SCALE.default);
			ThreatrackSavedVars.frameScale = SCALE.default;
		end,
	});
	UIDropDownMenu_AddButton({
		text = "Small",
		checked = function()
			return (SCALE.small == ThreatrackFrame:GetScale());
		end,
		func = function()
			ThreatrackFrame:SetScale(SCALE.small);
			ThreatrackSavedVars.frameScale = SCALE.small;
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
			ThreatrackFrame:ResetPosition();
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
function ThreatrackMenuMixin:OnLoad()
	UIDropDownMenu_SetInitializeFunction(self, ThreatrackMenuMixin.Initialize);
	UIDropDownMenu_SetDisplayMode(self, "MENU");
end
