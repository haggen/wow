-- Focused
-- MIT License © 2018 Arthur Corenzan
-- More on https://github.com/haggen/wow

-- Constants.
--
local FRAME_INITIAL_POSITION = {
	[PlayerFrame] = "RIGHT",
	[TargetFrame] = "LEFT"
};

-- Global object.
--
Focused = {};

-- Reset frame's position to the center of the screen.
--
local function SetInitialPosition(frame)
	frame:SetUserPlaced(true);
	frame:ClearAllPoints();
	frame:SetPoint(FRAME_INITIAL_POSITION[frame], UIParent, "CENTER");
end

-- Initialization.
--
function Focused:OnLoad()
	Focused = self;

	if (not PlayerFrame:IsUserPlaced()) then
		SetInitialPosition(PlayerFrame);
	end

	if (not TargetFrame:IsUserPlaced()) then
		SetInitialPosition(TargetFrame);
	end
end

-- Given two frames, mirror their offset along the X axis.
--
local function SetMirroredPosition(a, b)
	local _, _, _, offsetX, offsetY = b:GetPoint(1);
	local mirroredOffsetX = GetScreenWidth() - offsetX - a:GetWidth();
	a:ClearAllPoints();
	a:SetPoint("TOPLEFT", nil, "TOPLEFT", mirroredOffsetX, offsetY);
end

-- Update the other frame position when one is moving.
--
function Focused:OnUpdate()
	if (PlayerFrame:IsDragging()) then
		SetMirroredPosition(TargetFrame, PlayerFrame);
	elseif (TargetFrame:IsDragging()) then
		SetMirroredPosition(PlayerFrame, TargetFrame);
	end
end

--
--
--

-- FrameXML/TargetFrame.lua:1146
hooksecurefunc("TargetFrame_ResetUserPlacedPosition", function()
	SetInitialPosition(TargetFrame);

	if (PlayerFrame:IsUserPlaced()) then
		SetInitialPosition(PlayerFrame);
	end
end);

-- FrameXML/PlayerFrame.lua:821
hooksecurefunc("PlayerFrame_ResetUserPlacedPosition", function()
	SetInitialPosition(PlayerFrame);

	if (TargetFrame:IsUserPlaced()) then
		SetInitialPosition(TargetFrame);
	end
end);
