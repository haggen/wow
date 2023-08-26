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
-- TargetFrame.healthbar.Text = TargetFrameTextureFrame:CreateFontString(
--     "TargetFrameHealthBarText", "BACKGROUND", "TextStatusBarText");
-- TargetFrame.healthbar.Text:SetPoint("CENTER", -50, 3);
-- TargetFrame.healthbar.showPercentage = true;
-- TargetFrame.healthbar.showNumeric = false;
-- SetTextStatusBarText(TargetFrame.healthbar, TargetFrame.healthbar.Text);

-- Move the left vertical action bars a
-- bit away from the edge of the screen.
--
hooksecurefunc("MultiActionBar_Update", function()
    local point, _, _, x, y = VerticalMultiBarsContainer:GetPoint(1);
    VerticalMultiBarsContainer:ClearAllPoints();
    VerticalMultiBarsContainer:SetPoint(point, x - 8, y);
end);
