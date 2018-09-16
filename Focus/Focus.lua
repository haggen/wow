-- Focus 1.0.0
-- The MIT License © 2017 Arthur Corenzan

-- Hook around a frame's script handler.
local function HookScript(frame, script, hook)
    local handler = frame:GetScript(script)
    frame:SetScript(script, function()
        hook(function()
            if handler then
                handler()
            end
        end)
    end)
end

--
--
--

-- Used during setup to rollback the changes
-- in case the player clicks on Discard.
local savedPlayerFrameOffsetX
local savedPlayerFrameOffsetY
local savedTargetFrameOffsetX
local savedTargetFrameOffsetY

local function Focus_Setup()
    -- First of all let's re-anchor both PlayerFrame and TargetFrame 
    -- smackdab at the center of the screen. The first time it happens
    -- both frames will be repositioned but on subsequential runs they won't.
    -- That's because by then they'll have been flagged as "user placed"
    -- and as such their position is handled by the layout cache.
    PlayerFrame:ClearAllPoints()
    PlayerFrame:SetPoint("RIGHT", nil, "CENTER", 0, 0)

    TargetFrame:ClearAllPoints()
    TargetFrame:SetPoint("LEFT", nil, "CENTER", 0, 0)

    -- Flag both frames as "user placed". This makes the previous lines
    -- void ofter the first run and makes the game remember the frame's
    -- position after login.
    PlayerFrame:SetUserPlaced(true)
    TargetFrame:SetUserPlaced(true)

    -- PlayerFrame is already "movable" and "mouse enabled" so
    -- all is left is to allow dragging with the left click.
    -- Before allowing it to move we check the "lock", plus
    -- once it starts moving we flag it so the TargetFrame
    -- can mirror its movement.
    PlayerFrame:RegisterForDrag("LeftButton")
    PlayerFrame:SetScript("OnDragStart", function()
        if not this.isLocked then
            this:StartMoving()
            this.isMoving = true
        end
    end)
    PlayerFrame:SetScript("OnDragStop", function()
        if this.isMoving then
            this:StopMovingOrSizing()
            this.isMoving = nil
        end
    end)

    -- Starts locked.
    PlayerFrame.isLocked = true

    -- Here we hook after the OnUpdate handler of TargetFrame and 
    -- check if the PlayerFrame's being moved. If so we do some 
    -- calcuation to mirror its movement across the Y axis.
    HookScript(TargetFrame, "OnUpdate", function(originalHandler)
        originalHandler()

        if PlayerFrame.isMoving then
            local _, _, _, offsetX, offsetY = PlayerFrame:GetPoint(1)
            local mirroredOffsetX = GetScreenWidth() - offsetX - TargetFrame:GetWidth()

            TargetFrame:ClearAllPoints()
            TargetFrame:SetPoint("TOPLEFT", nil, "TOPLEFT", mirroredOffsetX, offsetY)
        end    
    end)
end

-- Reset both PlayerFrame and TargetFrame
-- back to the center of the screen.
-- Prompt before reloading the UI.
local function Focus_Reset()
    PlayerFrame:SetMovable(false)
    TargetFrame:SetMovable(false)

    StaticPopup_Show("FOCUS_RESET")
end

-- Unlock PlayerFrame for moving. Save both PlayerFrame
-- and TargetFrame positions in case of rollback, and then
-- prompt for an interface reload.
local function Focus_Unlock()
    if not UnitExists("target") then
        TargetUnit("player")
    end

    _, _, _, savedPlayerFrameOffsetX, savedPlayerFrameOffsetY = PlayerFrame:GetPoint(1)
    _, _, _, savedTargetFrameOffsetX, savedTargetFrameOffsetY = TargetFrame:GetPoint(1)

    PlayerFrame.isLocked = false
    StaticPopup_Show("FOCUS_SETUP")
end

-- Lock PlayerFrame for moving and hide the prompt.
local function Focus_Relock()
    PlayerFrame.isLocked = true
    StaticPopup_Hide("FOCUS_SETUP")
end

-- Called when the player clicks Apply in the prompt.
local function Focus_Apply()
    Focus_Relock()
end

-- Called when the player clicks Discard in the prompt.
local function Focus_Discard()
    PlayerFrame:ClearAllPoints()
    PlayerFrame:SetPoint("TOPLEFT", nil, "TOPLEFT", savedPlayerFrameOffsetX, savedPlayerFrameOffsetY)

    TargetFrame:ClearAllPoints()
    TargetFrame:SetPoint("TOPLEFT", nil, "TOPLEFT", savedTargetFrameOffsetX, savedTargetFrameOffsetY)

    Focus_Relock()
end

-- Prompt during Focus repositioning.
StaticPopupDialogs.FOCUS_SETUP = {
    text = "Move your health around until you're satisfied with its position. Once you're done press Save. You can press Discard to undo any changes.",
    button1 = "Save",
    button2 = "Discard",
    OnAccept = function() Focus_Apply() end,
    OnCancel = function() Focus_Discard() end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = true,
}

-- Prompt to reload the UI after reset.
StaticPopupDialogs.FOCUS_RESET = {
    text = "Would you like to reload your interface now?",
    button1 = "Reload",
    button2 = "Abort",
    OnAccept = function() ReloadUI() end,
    OnCancel = function() print("Your health's position will reset on your next login. You can type /reload to do it sooner.") end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = true,
}

-- Slash command setup.
SLASH_FOCUS1 = "/focus"
SlashCmdList.FOCUS = function(...)
    if arg[1] == "reset" then
        Focus_Reset()
    else
        Focus_Unlock()
    end
end

-- Entrypoint.
-- Focus_Setup()
