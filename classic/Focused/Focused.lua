-- Focused
-- MIT License © 2018 Arthur Corenzan
-- More on https://github.com/haggen/wow

-- Add-on namespace.
--
local FOCUSED = ...;

-- Default frame anchor points.
--
local defaultFramePoint = {
	[PlayerFrame] = "RIGHT",
	[TargetFrame] = "LEFT"
};

-- Reset frame position to the center of the screen.
--
local function SetInitialPosition(frame)
	frame:SetUserPlaced(true);
	frame:ClearAllPoints();
	frame:SetPoint(defaultFramePoint[frame], UIParent, "CENTER");
end

-- Given a user placed frames, update its offsetX to a mirrored value of the given anchor.
--
local function SetMirroredPosition(frame, anchor)
	local _, _, _, offsetX, offsetY = unpack(anchor);
	local mirroredOffsetX = GetScreenWidth() - offsetX - frame:GetWidth();
	frame:ClearAllPoints();
	frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", mirroredOffsetX, offsetY);
end

--
--
--

-- Saved variables.
-- installed (boolean) - Tells if it's the first the add-on is being loaded.
--
FocusedSavedVars = {
	installed = false,
};

-- Main frame mixin.
--
FocusedFrameMixin = {};

-- Load callback.
--
function FocusedFrameMixin:OnLoad()
	self:RegisterEvent("ADDON_LOADED");
end

-- Registered events callback.
--
function FocusedFrameMixin:OnEvent(event, ...)
	if (event == "ADDON_LOADED") then
		local name = ...;

		if (name == FOCUSED) then
			if (not FocusedSavedVars.installed) then
				SetInitialPosition(PlayerFrame);
				PlayerFrame_SetLocked(false);
				SetInitialPosition(TargetFrame);
				TargetFrame_SetLocked(false);
			end
			FocusedSavedVars.installed = true;
		end
	end
end

-- Update the other frame's position whenever one is being dragged.
--
function FocusedFrameMixin:OnUpdate()
	if (PlayerFrame:IsDragging()) then
		SetMirroredPosition(TargetFrame, {PlayerFrame:GetPoint(1)});
	elseif (TargetFrame:IsDragging()) then
		SetMirroredPosition(PlayerFrame, {TargetFrame:GetPoint(1)});
	end
end

--
--
--

-- Override game's "Reset position" option.
-- FrameXML/TargetFrame.lua:1146
--
function TargetFrame_ResetUserPlacedPosition()
	SetInitialPosition(PlayerFrame);
	SetInitialPosition(TargetFrame);
end

-- Override game's "Reset position" option.
-- FrameXML/PlayerFrame.lua:821
--
function PlayerFrame_ResetUserPlacedPosition()
	SetInitialPosition(PlayerFrame);
	SetInitialPosition(TargetFrame);
end
