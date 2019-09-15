-- Focused
-- MIT License © 2018 Arthur Corenzan
-- More on https://github.com/haggen/wow

local function SetMirroredPosition(a, b)
	local _, _, _, offsetX, offsetY = b:GetPoint(1);
	local mirroredOffsetX = GetScreenWidth() - offsetX - a:GetWidth();
	a:ClearAllPoints();
	a:SetPoint("TOPLEFT", nil, "TOPLEFT", mirroredOffsetX, offsetY);
end

local initialPositionPoint = {
	[PlayerFrame] = "RIGHT",
	[TargetFrame] = "LEFT"
};

local function SetInitialPosition(frame)
	frame:SetUserPlaced(true);
	frame:ClearAllPoints();
	frame:SetPoint(initialPositionPoint[frame], UIParent, "CENTER");
end

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

if (not PlayerFrame:IsUserPlaced()) then
	SetInitialPosition(PlayerFrame);
end

if (not TargetFrame:IsUserPlaced()) then
	SetInitialPosition(TargetFrame);
end

function FocusedFrame_OnUpdate()
	if (PlayerFrame:IsDragging()) then
		SetMirroredPosition(TargetFrame, PlayerFrame);
	elseif (TargetFrame:IsDragging()) then
		SetMirroredPosition(PlayerFrame, TargetFrame);
	end
end

--
--
--

-- Bring back text label over target's health bar.
-- Though only the percentage can be shown since the
-- game's API doesn't provide the actual health values.
--
-- Also, it's not really a feature of this add-on but
-- I've got no where else to put it.
--
TargetFrame.healthbar.Text = TargetFrameTextureFrame:CreateFontString("TargetFrameHealthBarText", "BACKGROUND", "TextStatusBarText");
TargetFrame.healthbar.Text:SetPoint("CENTER", -50, 3);
TargetFrame.healthbar.showPercentage = true;
TargetFrame.healthbar.showNumeric = false;
SetTextStatusBarText(TargetFrame.healthbar, TargetFrame.healthbar.Text);
