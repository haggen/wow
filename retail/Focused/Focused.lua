-- Focused
-- The MIT License © 2018 Arthur Corenzan

-- FauxTarget is a workaround of the fact that in
-- modern WoW we can't change the player's target.
-- The target portrait can be somewhat configured
-- to work with other units such as the player.
--
-- That's exactly what we do. But we're also very
-- careful to avoid breaking the game UI, so that
-- is why there's some additional complexity.
--
local FauxTarget = {
	enabled = false,
};

-- While standing by we listen to target
-- change events and clear or set a faux
-- target depending if there is or isn't
-- an actual target, respectively.
function FauxTarget:Enable()
	self.enabled = true;
	self:Set();
end

function FauxTarget:Disable()
	self.enabled = false;
	self:Clear();
end

-- Fake a target by configuring the target's
-- portrait to read from another unit; the player.
function FauxTarget:Set()
	TargetFrame.unit = "player";
	TargetFrame_Update(TargetFrame);
	TargetFrameTextureFrameName:SetText("...");
end

-- Restores the target's portrait original configuration.
function FauxTarget:Clear()
 	TargetFrame.unit = "target";
	TargetFrame_Update(TargetFrame);
end

function FauxTargetFrame_OnLoad(self)
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
end

function FauxTargetFrame_OnEvent(self, event)
	if (event == "PLAYER_TARGET_CHANGED") then
		if (FauxTarget.enabled) then
			if UnitExists("target") then
				FauxTarget:Clear();
			else
				FauxTarget:Set();
			end
		end
	end
end

--
--
--

-- When locking and unlocking the player and target
-- portraits I have to make the same calls the game
-- UI also does. But I also have to intercept these
-- same calls when I'm not the one making them.
-- e.g. When the player resets the position of either
-- portrait via right-click.

-- The way I deal with this is by arming a "trap"
-- to those calls. When the game make the calls
-- the trap goes off, but when I'm the one
-- calling I can disarm it beforehand.
--
local trapped = true;

local function UntrappedCall(functionName, ...)
	trapped = false;
	_G[functionName](...);
	trapped = true;
end

-- Use secure hook so I don't taint game calls.
local function SetTrappedHook(functionName, hook)
	hooksecurefunc(functionName, function(...)
		if (trapped) then
			hook(...);
		end
	end);
end

--
--
--

-- Updates frame A's position with a mirrored version of frame B's position.
local function SetMirroredPosition(a, b)
	local _, _, _, offsetX, offsetY = b:GetPoint(1);
	local mirroredOffsetX = GetScreenWidth() - offsetX - a:GetWidth();
	a:ClearAllPoints();
	a:SetPoint("TOPLEFT", nil, "TOPLEFT", mirroredOffsetX, offsetY);
end

--
--
--

-- Track prompt state.
local prompting;

-- Used to rollback the placement of the portraits.
local savedPlayerFramePoint;
local savedTargetFramePoint;

-- Called whenever the slash command is
-- issued and we cannot guarantee the proper
-- positioning of the target's portrait.
-- i.e. When the player unlocked either
-- portrait manually via right-click.
local function Activate()
	-- Reposition both frames to the center of the screen.
	-- Set both frames as "user placed".
	-- Flag as ACTIVE.

	PlayerFrame:ClearAllPoints();
	PlayerFrame:SetPoint("RIGHT", nil, "CENTER", 0, 0);
	TargetFrame:ClearAllPoints();
	TargetFrame:SetPoint("LEFT", nil, "CENTER", 0, 0);

	PlayerFrame:SetUserPlaced(true);
	TargetFrame:SetUserPlaced(true);

	FOCUSED_ACTIVE = true;
end

-- Called whenever the player wants to take manual
-- control of either portrait. i.e. When either
-- frame is unlocked via right-click or
-- when a reset command is issued.
local function Deactivate()
	-- Disable faux target.
	-- Clear prompt.
	-- Flag as not ACTIVE.

	FauxTarget:Disable();
	Prompt(false);
	FOCUSED_ACTIVE = nil;
end

-- Restore both player and target portraits initial position.
local function Reset()
	-- Reset position.
	-- Deactivate.

	UntrappedCall("TargetFrame_ResetUserPlacedPosition");
	UntrappedCall("PlayerFrame_ResetUserPlacedPosition");

	Deactivate();
end

-- Opens/closes the prompt during placement.
function Prompt(state)
	prompting = state
	if (prompting) then
		StaticPopup_Show("FOCUSED_PROMPT");
	else
		StaticPopup_Hide("FOCUSED_PROMPT");
	end
end

-- Called when the player wants to move
-- either frame with the mirroring aid.
local function Unlock()
	-- If it's not ACTIVE call Activate().
	-- If there's no target use a faux target.
	-- Save current position.
	-- Unlock both frames for dragging.
	-- Display prompt.

	if (not FOCUSED_ACTIVE) then
		Activate();
	end

	FauxTarget:Enable();

	savedPlayerFramePoint = { PlayerFrame:GetPoint(1) };
	savedPlayerFramePoint[2] = savedPlayerFramePoint[2] or "UIParent";
	savedTargetFramePoint = { TargetFrame:GetPoint(1) };
	savedTargetFramePoint[2] = savedTargetFramePoint[2] or "UIParent";

	UntrappedCall("PlayerFrame_SetLocked", false);
	UntrappedCall("TargetFrame_SetLocked", false);

	Prompt(true);
end

-- Called when the player is finished
-- moving the frames, either by applying
-- the changes or discarding them.
local function Relock()
	-- If faux target was used, undo.
	-- Lock both frames for dragging.
	FauxTarget:Disable();

	UntrappedCall("PlayerFrame_SetLocked", true);
	UntrappedCall("TargetFrame_SetLocked", true);
end

-- Save the new placement.
-- i.e. relock without rolling back.
local function Apply()
	Relock();
	Prompt(false);
end

-- Rollback portraits placement.
local function Rollback()
	PlayerFrame:ClearAllPoints();
	PlayerFrame:SetPoint(unpack(savedPlayerFramePoint));
	TargetFrame:ClearAllPoints();
	TargetFrame:SetPoint(unpack(savedTargetFramePoint));
end

-- Discard the new placement.
local function Discard()
	-- Rollback both frames placement.
	-- Relock.

	Rollback();
	Relock();
	Prompt(false);
end

--
--
--

SetTrappedHook("TargetFrame_ResetUserPlacedPosition", function()
	Deactivate();
end);

SetTrappedHook("PlayerFrame_ResetUserPlacedPosition", function()
	Deactivate();
end);

SetTrappedHook("TargetFrame_SetLocked", function(locked)
	if (prompting) then
		Apply();
	else
		Deactivate();
	end
end);

SetTrappedHook("PlayerFrame_SetLocked", function(locked)
	if (prompting) then
		Apply();
	else
		Deactivate();
	end
end);

-- TODO: Translate strings.

-- Prompt during portrait placement.
StaticPopupDialogs["FOCUSED_PROMPT"] = {
	text = "You're free to move around either your character's or your target's portrait.",
	button1 = "Save",
	button2 = "Discard",
	OnAccept = Apply,
	OnCancel = Discard,
	timeout = 0,
	whileDead = 1,
	showAlert = 1,
	hideOnEscape = true,
};

-- Slash command setup.
SLASH_FOCUSED1 = "/focused";
SlashCmdList["FOCUSED"] = function(option)
	if (option == "reset") then
		Reset();
	else
		if (prompting) then
			Relock();
		else
			Unlock();
		end
	end
end;

function FocusedFrame_OnUpdate(self, elapsed)
	-- Whenever the player is dragging one portrait around
	-- we refresh the other's position accordingly, but
	-- only while the prompt is active.
	if (prompting) then
		if (PlayerFrame:IsDragging()) then
			SetMirroredPosition(TargetFrame, PlayerFrame);
		end
		if (TargetFrame:IsDragging()) then
			SetMirroredPosition(PlayerFrame, TargetFrame);
		end
	end
end
