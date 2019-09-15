-- Fastbind
-- The MIT License © 2017 Arthur Corenzan
-- More on https://github.com/haggen/fastbind

local function print(...)
	for i = 1, getn(arg) do
		DEFAULT_CHAT_FRAME:AddMessage(tostring(arg[i]), 1, 1, 1);
	end
end

local function printf(...)
	print(format(unpack(arg)));
end

-- Comment the following lines to enable debug message.
local function print() end
local function printf() end

--
--
--

-- By default save the bindings to this character.
local characterBindingSet = 2;

-- Skip binding some keys for the sake of the player.
local excludedKeys = {
	"SHIFT",
	"CTRL",
	"ALT",
	"ESCAPE",
	"UNKNOWN",
	"LeftButton",
	"RightButton",
};

-- 
local selfActionCommands = {
	"ACTIONBAR",
};

-- Tells us when we're actively changing bindings.
local isFastBinding = false;

-- Store which command are we binding.
-- This is derived from what control the 
-- player is hovering with the mouse cursor.
local bindingCommand = nil;

-- Update tooltip to show what key is bound to the engaged bindable control.
local function UpdateTooltip()
	if (not bindingCommand) then 
		return;
	end

	GameTooltip:SetOwner(Fastbind, "ANCHOR_TOPLEFT", -10, 5);

	local bindingKeys = {
		GetBindingKey(bindingCommand)
	};
	for _, key in pairs(bindingKeys) do
		GameTooltip:AddLine(key, 1, 1, 1);
	end

	if (getn(bindingKeys) == 0) then
		GameTooltip:AddLine("Not Bound", 0.5, 0.5, 0.5);
	end

	GameTooltip:Show();
end

-- Engage the target control with the Fastbind frame.
-- This allows us to show the tooltip as well as intercept any keystrokes.
local function EngageBindableControl(control)
	local name = control:GetName();

	if string.find(name, "Action") then
		bindingCommand = string.upper(control:GetName());
	elseif string.find(name, "MultiBar") then
		bindingCommand = control.buttonType..control:GetID();
	elseif string.find(name, "PetAction") then
		bindingCommand = "BONUSACTIONBUTTON"..control:GetID();
	elseif string.find(name, "Bonus") then
		bindingCommand = "BONUSACTIONBUTTON"..control:GetID();
	elseif string.find(name, "Shapeshift") then
		bindingCommand = "SHAPESHIFTBUTTON"..control:GetID();
	end

	if (bindingCommand) then
		print("GetID: "..tostring(control:GetID()));
		print("GetName: "..tostring(control:GetName()));
		print("GetObjectType: "..tostring(control:GetObjectType()));
		print("bindingCommand: "..bindingCommand);

		Fastbind:ClearAllPoints();
		Fastbind:SetAllPoints(control);
		Fastbind:Show();
	else 
		print("Couldn't derived a valid command from this control");
	end
end

-- Disengage the currently engaged bindable control.
local function DisengageBindableControl()
	bindingCommand = nil;
	Fastbind:Hide();
	GameTooltip:Hide();
end

-- Helper to hook a script handler from existing control.
local function HookScript(control, script, newHandler)
	local prevHandler = control:GetScript(script);
	control:SetScript(script, function(...)
		if (prevHandler) then
			prevHandler(control, unpack(arg));
		end
		newHandler(control, unpack(arg));
	end)
end

-- Set necessary hooks the given control.
local function HookBindableControl(name)
	assert(type(name) == "string", "Invalid argument: expected a string");
	
	local control = getglobal(name);
	if (not control) then
		print("Invalid control: "..name);
	elseif (not control.fastbindHook) then
		print("Hooking: "..control:GetName());
		control.fastbindHook = true;
		HookScript(control, "OnEnter", function(control)
			if (isFastBinding) then
				EngageBindableControl(control);
			end
		end);
	end
end

local function FindBindableControls()
	local prefixes = {
		"MultiBarBottomLeftButton",
		"MultiBarBottomRightButton",
		"MultiBarRightButton",
		"MultiBarLeftButton",
		"ActionButton",
		"PetActionButton",
		"BonusActionButton",
	};
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		for _, prefix in ipairs(prefixes) do
			HookBindableControl(prefix..i);
		end
	end
end

local function ClearBinding()
	local bindingKeys = {
		GetBindingKey(bindingCommand)
	};
	for _, key in pairs(bindingKeys) do
		print("Clear binding: "..key);
		SetBinding(key);
	end
end

local function UpdateBinding(key)
	print("Key: "..key);

	if (not bindingCommand) then
		return;
	end

	if (key == "RightButton") then
		ClearBinding();
	end

	for i = 1, getn(excludedKeys) do
		if (key == excludedKeys[i]) then
			return;
		end
	end

	-- We don't support combinations with ALT. See below.
	if IsControlKeyDown() then 
		key = "CTRL-"..key;
	end
	if IsShiftKeyDown() then
		key = "SHIFT-"..key;
	end

	if SetBinding(key, bindingCommand) then
		print("SetBinding("..key..", "..bindingCommand..")");
	else
		print("SetBinding failed: "..key);
	end

	-- Auto bind ALT-key as self-action.
	for i = 1, getn(selfActionCommands) do
		if string.find(bindingCommand, selfActionCommands[i]) then
			if SetBinding("ALT-"..key, "SELF"..bindingCommand) then
				print("SetBinding(ALT-"..key..", SELF"..bindingCommand..")");
			else
				print("SetBinding failed: ALT-"..key);
			end
		end
	end
end

local function Activate()
	if (isFastBinding) then
		return;
	elseif UnitAffectingCombat("player") then
		print("You can't use it in combat.");
	else
		FindBindableControls();
		isFastBinding = true;
		StaticPopup_Show("FASTBIND");
	end
end

local function Deactivate()
	if (isFastBinding) then
		DisengageBindableControl();
		isFastBinding = false;
		StaticPopup_Hide("FASTBIND");
	end
end

local function Toggle()
	if (isFastBinding) then
		Deactivate();
	else
		Activate();
	end
end

local function Apply()
	SaveBindings(GetCurrentBindingSet() or characterBindingSet);
	Deactivate();
end

local function Discard()
	LoadBindings(GetCurrentBindingSet() or characterBindingSet);
	Deactivate();
end

--
--
--

StaticPopupDialogs.FASTBIND = {
	text = "Move your cursor over any action slot and press the desired key or key combination to change its keybind.",
	button1 = "Save",
	button2 = "Discard",
	OnAccept = function() Apply() end,
	OnCancel = function() Discard() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = true,
};
	
function SlashCmdList.FASTBIND()
	Toggle();
end
SLASH_FASTBIND1 = "/fastbind";
SLASH_FASTBIND2 = "/fb";

--
--
--

function Fastbind_OnEnter()
	UpdateTooltip();
end

function Fastbind_OnLeave()
	DisengageBindableControl();
end

function Fastbind_OnKeyUp()
	UpdateBinding(arg1);
end

function Fastbind_OnMouseUp()
	UpdateBinding(arg1);
end
