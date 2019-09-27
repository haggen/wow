-- Standard
-- MIT © 2019 Arthur Corenzan
-- More on https://github.com/haggen/wow

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
