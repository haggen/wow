-- Focused
-- MIT License © 2018 Arthur Corenzan
-- More on https://github.com/haggen/wow

-- Constants.
--
local FRAME_POINT = {
	[PlayerFrame] = "RIGHT",
	[TargetFrame] = "LEFT"
};

-- Global object.
--
Focused = {};

local framePositionChangedInCombat = false;
local framePositionResetInCombat = false;

-- Reset frame's position to the center of the screen.
--
local function SetInitialPosition(frame)
	if InCombatLockdown() then
		framePositionResetInCombat = true;
	else
		frame:SetUserPlaced(true);
		frame:ClearAllPoints();
		frame:SetPoint(FRAME_POINT[frame], UIParent, "CENTER");
	end
end

local function ResetUserPlacedPosition()
	SetInitialPosition(PlayerFrame);
	PlayerFrame_SetLocked(false);
	SetInitialPosition(TargetFrame);
	TargetFrame_SetLocked(false);
end

-- Given a user placed frames, update its offsetX to a mirrored value of the given anchor.
--
function SetMirroredPosition(frame, anchor)
	if InCombatLockdown() then
		framePositionChangedInCombat = {frame, anchor};
	else
		local _, _, _, offsetX, offsetY = unpack(anchor);
		local mirroredOffsetX = GetScreenWidth() - offsetX - frame:GetWidth();
		frame:ClearAllPoints();
		frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", mirroredOffsetX, offsetY);
	end
end

-- Initialization.
--
function Focused:OnLoad()
	Focused = self;

	self:RegisterEvent("PLAYER_REGEN_ENABLED");

	if (not PlayerFrame:IsUserPlaced()) or (not TargetFrame:IsUserPlaced()) then
		ResetUserPlacedPosition();
	end
end

-- Update the other frame position when one is moving.
--
function Focused:OnUpdate()
	if (PlayerFrame:IsDragging()) then
		SetMirroredPosition(TargetFrame, {PlayerFrame:GetPoint(1)});
	elseif (TargetFrame:IsDragging()) then
		SetMirroredPosition(PlayerFrame, {TargetFrame:GetPoint(1)});
	end
end

function Focused:OnEvent(event)
	if (event == "PLAYER_REGEN_ENABLED") then
		if (framePositionResetInCombat) then
			ResetUserPlacedPosition();
		elseif (framePositionChangedInCombat) then
			SetMirroredPosition(unpack(framePositionChangedInCombat));
		end

		framePositionResetInCombat = false;
		framePositionChangedInCombat = false;
	end
end

--
--
--

-- FrameXML/TargetFrame.lua:1146
function TargetFrame_ResetUserPlacedPosition()
-- hooksecurefunc("TargetFrame_ResetUserPlacedPosition", function()
	ResetUserPlacedPosition();
-- end);
end

-- FrameXML/PlayerFrame.lua:821
function PlayerFrame_ResetUserPlacedPosition()
-- hooksecurefunc("PlayerFrame_ResetUserPlacedPosition", function()
	ResetUserPlacedPosition();
-- end);
end
