-- Standard
-- The MIT License © 2017 Arthur Corenzan

-- Shortcut to print in chat.
local function print(message)
    DEFAULT_CHAT_FRAME:AddMessage(message);
end

--
--
--

function StandardFrame_OnLoad()
    this:RegisterEvent("ADDON_LOADED");
    this:RegisterEvent("UPDATE_CHAT_WINDOWS");

    -- MultiBarRight:SetHeight(38);
    -- MultiBarRight:SetWidth(500);
    -- MultiBarRight:ClearAllPoints();
    -- MultiBarRight:SetPoint("BOTTOMLEFT", "MultiBarBottomRight", "TOPLEFT", 0, 6);

    -- MultiBarRightButton1:ClearAllPoints();
    -- MultiBarRightButton1:SetPoint("BOTTOMLEFT", "MultiBarRight");

    -- for i = 2, NUM_MULTIBAR_BUTTONS do
    --     local button = getglobal("MultiBarRightButton"..i);
    --     button:ClearAllPoints();
    --     button:SetPoint("LEFT", "MultiBarRightButton"..(i - 1), "RIGHT", 6, 0);
    -- end

    -- CastingBarFrame:ClearAllPoints();
    -- CastingBarFrame:SetPoint("BOTTOM", "UIParent", "CENTER", 0, 0);
end

function StandardFrame_OnEvent()
    if (event == "ADDON_LOADED") then
        if (not StandardSavedVars) then
            StandardSavedVars = {};
        end
    end

    if (event == "UPDATE_CHAT_WINDOWS") then
        ChatFrame2:ClearAllPoints();
        ChatFrame2:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 32, 42);
        ChatFrame2:SetWidth(400);
        ChatFrame2:SetHeight(180);
        FCF_SetWindowAlpha(ChatFrame2, 0);

        ChatFrame1:ClearAllPoints();
        ChatFrame1:SetPoint("BOTTOMLEFT", "ChatFrame2", "TOPLEFT", 0, 42);
        ChatFrame1:SetWidth(400);
        ChatFrame1:SetHeight(180);
    end
end

function StandardFrame_OnUpdate()
end
