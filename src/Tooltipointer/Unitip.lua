hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
    tooltip:SetOwner(parent, "ANCHOR_CURSOR_RIGHT", 0, 10)

    if tooltip.StatusBar then
        tooltip.StatusBar:SetAlpha(0)
    end
end)
