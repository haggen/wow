-- Tunnelvision
-- MIT License © 2018 Arthur Corenzan
-- More on https://github.com/haggen/wow

-- Add-on namespace.
--
local TUNNELVISION = ...;

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
TunnelvisionSavedVars = {
	installed = false,
};

-- Main frame mixin.
--
TunnelvisionFrameMixin = {};

-- Load callback.
--
function TunnelvisionFrameMixin:OnLoad()
	self:RegisterEvent("ADDON_LOADED");
end

-- Registered events callback.
--
function TunnelvisionFrameMixin:OnEvent(event, ...)
	if (event == "ADDON_LOADED") then
		local name = ...;

		if (name == TUNNELVISION) then
			if (not TunnelvisionSavedVars.installed) then
				SetInitialPosition(PlayerFrame);
				PlayerFrame_SetLocked(false);
				SetInitialPosition(TargetFrame);
				TargetFrame_SetLocked(false);
			end
			TunnelvisionSavedVars.installed = true;
		end
	end
end

-- Update the other frame's position whenever one is being dragged.
--
function TunnelvisionFrameMixin:OnUpdate()
	if (PlayerFrame:IsDragging()) then
		SetMirroredPosition(TargetFrame, { PlayerFrame:GetPoint(1) });
	elseif (TargetFrame:IsDragging()) then
		SetMirroredPosition(PlayerFrame, { TargetFrame:GetPoint(1) });
	end
end

--
--
--

-- Hook into frame options.
--
hooksecurefunc("TargetFrame_ResetUserPlacedPosition", function()
	SetInitialPosition(TargetFrame);
	SetInitialPosition(PlayerFrame);
end);

hooksecurefunc("TargetFrame_SetLocked", function(locked)
	if (PLAYER_FRAME_UNLOCKED == locked) then
		PlayerFrame_SetLocked(locked);
	end
end);

hooksecurefunc("PlayerFrame_ResetUserPlacedPosition", function()
	SetInitialPosition(TargetFrame);
	SetInitialPosition(PlayerFrame);
end);

hooksecurefunc("PlayerFrame_SetLocked", function(locked)
	if (TARGET_FRAME_UNLOCKED == locked) then
		TargetFrame_SetLocked(locked);
	end
end);
