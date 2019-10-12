-- Threatrack
-- MIT License © 2019 Arthur Corenzan
-- More on https://github.com/haggen/wow

-- Grab add-on name from local space.
--
local THREATRACK = ...;

local SCALE = {
	default = 1,
	small = 0.75,
};

-- ..
--
ThreatrackDropDownMenuMixin = {};

-- ..
--
function ThreatrackDropDownMenuMixin:Initialize()
	UIDropDownMenu_AddButton({
		text = THREATRACK,
		notCheckable = 1,
		isTitle = 1,
	});

	if (ThreatrackSavedVars.devMode) then
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
function ThreatrackDropDownMenuMixin:OnLoad()
	UIDropDownMenu_SetInitializeFunction(self, ThreatrackDropDownMenuMixin.Initialize);
	UIDropDownMenu_SetDisplayMode(self, "MENU");
end
