-- Focus 1.0.0
-- The MIT License © 2017 Arthur Corenzan

-- Shortcut to print in chat.
local function print(message)
    DEFAULT_CHAT_FRAME:AddMessage(message);
end

-- Used to enable/disable dragging of PlayerFrame.
local isPlayerFrameLocked;

-- Used to check if TargetFrame should be moving as well.
local isPlayerFrameMoving;

-- Used during to rollback any changes
-- in case the player clicks on Discard.
local savedPlayerFrameOffsetX;
local savedPlayerFrameOffsetY;
local savedTargetFrameOffsetX;
local savedTargetFrameOffsetY;

-- Run once after install and on the first "/focus" after a reset.
local function Setup()
    -- Save default position of both frames but drop the relativeFrame 
    -- value since it's a frame can't be encoded in saved variables.
    -- nil will default to UIParent which is the original value.
    FocusSavedVars.defaultPlayerFramePoint = { PlayerFrame:GetPoint(1) };
    FocusSavedVars.defaultTargetFramePoint = { TargetFrame:GetPoint(1) };
    if (type(FocusSavedVars.defaultPlayerFramePoint[2]) == "userdata") then
        FocusSavedVars.defaultPlayerFramePoint[2] = FocusSavedVars.defaultPlayerFramePoint[2]:GetName();
    end
    if (type(FocusSavedVars.defaultTargetFramePoint[2]) == "userdata") then
        FocusSavedVars.defaultTargetFramePoint[2] = FocusSavedVars.defaultTargetFramePoint[2]:GetName();
    end

    -- Move both PlayerFrame and TargetFrame smackdab at the center of the screen.
    -- The first time it happens both frames will be moved but on subsequential 
    -- runs they won't. That's because by then they'll have been flagged as "user placed"
    -- and as such their position is handled by the layout cache of the game.
    PlayerFrame:ClearAllPoints();
    PlayerFrame:SetPoint("RIGHT", nil, "CENTER", 0, 0);

    TargetFrame:ClearAllPoints();
    TargetFrame:SetPoint("LEFT", nil, "CENTER", 0, 0);

    FocusSavedVars.setup = true;
    FocusSavedVars.reset = nil;
end

-- Run on UI load as long as it's not been reset.
local function Startup()
    if (not FocusSavedVars.setup) then
        Setup();
    end

    -- Flag both frames as "user placed". This makes the
    -- game remember the frames position across sessions.
    PlayerFrame:SetUserPlaced(true)
    TargetFrame:SetUserPlaced(true)

    -- PlayerFrame is already "movable" and "mouse enabled" so
    -- all is left is to allow dragging with the left click.
    -- Before allowing it to move we check the "lock", plus
    -- once it starts moving we flag it so the TargetFrame
    -- can mirror its movement.
    PlayerFrame:RegisterForDrag("LeftButton")
    PlayerFrame:SetScript("OnDragStart", function()
        if (not isPlayerFrameLocked) then
            PlayerFrame:StartMoving();
            isPlayerFrameMoving = true;
        end
    end);
    PlayerFrame:SetScript("OnDragStop", function()
        if (isPlayerFrameMoving) then
            PlayerFrame:StopMovingOrSizing();
            isPlayerFrameMoving = nil;
        end
    end);

    -- Unlocks with "/focus".
    isPlayerFrameLocked = true;
end

-- Undo changes made during setup
-- then prompt to reload the UI.
local function Reset()
    PlayerFrame:SetUserPlaced(false);
    TargetFrame:SetUserPlaced(false);

    PlayerFrame:ClearAllPoints();
    PlayerFrame:SetPoint(unpack(FocusSavedVars.defaultPlayerFramePoint));

    TargetFrame:ClearAllPoints();
    TargetFrame:SetPoint(unpack(FocusSavedVars.defaultTargetFramePoint));
    
    PlayerFrame:SetScript("OnDragStart", nil);
    PlayerFrame:SetScript("OnDragStop", nil);
    
    PlayerFrame:RegisterForDrag(nil);

    FocusSavedVars.reset = true;
    FocusSavedVars.setup = nil;
end

-- Unlock PlayerFrame for moving. Save both PlayerFrame
-- and TargetFrame positions in case of rollback, and then
-- prompt for an interface reload.
local function Unlock()
    -- Make sure the player is targeting something so 
    -- they can see the TargetFrame moving as well.
    if (not UnitExists("target")) then
        TargetUnit("player");
    end

    -- Save momentarily the current offsets.
    _, _, _, savedPlayerFrameOffsetX, savedPlayerFrameOffsetY = PlayerFrame:GetPoint(1);
    _, _, _, savedTargetFrameOffsetX, savedTargetFrameOffsetY = TargetFrame:GetPoint(1);

    -- Unlock dragging for PlayerFrame.
    isPlayerFrameLocked = false;

    StaticPopup_Show("FOCUS_SETUP");
end

-- Lock PlayerFrame for moving and hide the prompt.
local function Relock()
    isPlayerFrameLocked = true;
    StaticPopup_Hide("FOCUS_SETUP");
end

-- Called when the player clicks Apply in the prompt.
local function Apply()
    -- Simply relock since its position is 
    -- already being tracked by layout cache.
    Relock()
end

-- Called when the player clicks Discard in the prompt.
local function Discard()
    -- Restore saved position.
    PlayerFrame:ClearAllPoints()
    PlayerFrame:SetPoint("TOPLEFT", nil, "TOPLEFT", savedPlayerFrameOffsetX, savedPlayerFrameOffsetY)

    TargetFrame:ClearAllPoints()
    TargetFrame:SetPoint("TOPLEFT", nil, "TOPLEFT", savedTargetFrameOffsetX, savedTargetFrameOffsetY)

    -- Relock.
    Relock()
end

--
--
--

-- TODO: Translate strings.

-- Prompt during Focus repositioning.
StaticPopupDialogs.FOCUS_SETUP = {
    text = "Drag your character's health around and your target's health will mirror its movement. Once you're done press Save. You can press Discard to undo any changes.",
    button1 = "Save",
    button2 = "Discard",
    OnAccept = function() 
        Apply();
    end,
    OnCancel = function() 
        Discard();
    end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = true,
};

-- Slash command setup.
SLASH_FOCUS1 = "/focus";
SlashCmdList.FOCUS = function(option)
    if (FocusSavedVars.reset) then
        Startup();
    end

    if (option == "reset") then
        Reset();
    else
        Unlock();
    end
end;

function FocusFrame_OnLoad()
    this:RegisterEvent("ADDON_LOADED");    
end

function FocusFrame_OnEvent()
    if (event == "ADDON_LOADED") then
        if (not FocusSavedVars) then
            FocusSavedVars = {};
        end

        if (not FocusSavedVars.reset) then
            Startup();
        end
    end
end

function FocusFrame_OnUpdate()
    -- Whenever the player is dragging PlayerFrame around 
    -- we do a calculation to mirror its movement across 
    -- the Y axis and reposition TargetFrame accordingly.
    if (isPlayerFrameMoving) then
        local _, _, _, offsetX, offsetY = PlayerFrame:GetPoint(1);
        local mirroredOffsetX = GetScreenWidth() - offsetX - TargetFrame:GetWidth();
        TargetFrame:ClearAllPoints();
        TargetFrame:SetPoint("TOPLEFT", nil, "TOPLEFT", mirroredOffsetX, offsetY);
    end  
end