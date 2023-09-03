-- Fastbind
-- The MIT License © 2017 Arthur Corenzan
-- More on https://github.com/haggen/wow

-- Namespace variables.
local FASTBIND = ...

-- Slash command.
_G["SLASH_" .. FASTBIND .. 1] = "/fastbind"

-- Keybinding sets.
local DEAFULT_BINDINGS = 0;
local ACCOUNT_BINDINGS = 1;
local CHARACTER_BINDINGS = 2;

-- Modifier keys and keys that shouldn't be bound.
local EXCLUDED_KEYS = {
	"LSHIFT",
	"RSHIFT",
	"LCTRL",
	"RCTRL",
	"LALT",
	"RALT",
	"ESCAPE",
	"UNKNOWN",
	"LeftButton",
	"RightButton"
}

-- Action types that we won't bind.
local EXCLUDED_ACTION_TYPES = {
	-- "flyout",
}

-- Prefixes for bindable frames.
local BINDABLES_PREFIX_TABLE = {
	"MultiBarBottomLeftButton",
	"MultiBarBottomRightButton",
	"MultiBarRightButton",
	"MultiBarLeftButton",
	"SpellButton",
	"SpellFlyoutButton",
	"ActionButton",
	"StanceButton",
	"PetActionButton"
}

-- Default saved variables.
local defaultSavedVars = {
	version = 1,
	debug = false
}
FastbindSavedVars = defaultSavedVars

-- Dump variables.
local function d(...)
	if not FastbindSavedVars.debug then
		return
	end

	if not IsAddOnLoaded("Blizzard_DebugTools") then
		LoadAddOn("Blizzard_DebugTools")
	end

	DevTools_Dump({ ... })
end

-- Frame mixin.
FastbindFrameMixin = {}

-- Initialization.
function FastbindFrameMixin:OnLoad()
	self:RegisterEvent("ADDON_LOADED")

	StaticPopupDialogs[FASTBIND] = {
		text =
		"Click Apply to save. Press ESC or click on Discard to undo any changes.",
		button1 = "Save",
		button2 = "Discard",
		OnAccept = function()
			self:Apply()
		end,
		OnCancel = function()
			self:Discard()
		end,
		timeout = 0,
		whileDead = 1,
		hideOnEscape = true
	}

	SlashCmdList[FASTBIND] = function()
		self:Activate()
	end
end

function FastbindFrameMixin:OnEvent(event, ...)
	if (event == "ADDON_LOADED") then
		local name = ...

		if (name == FASTBIND) then
			if not FastbindSavedVars.version or FastbindSavedVars.version < defaultSavedVars.version then
				for key, value in pairs(defaultSavedVars) do
					if FastbindSavedVars[key] == nil then
						FastbindSavedVars[key] = value
					end
				end
				for key, _ in pairs(FastbindSavedVars) do
					if defaultSavedVars[key] == nil then
						FastbindSavedVars[key] = nil
					end
				end
			end

			d("Fastbind loaded.")
		end
	end
end

function FastbindFrameMixin:OnKeyUp(key)
	self:SetButtonBinding(key)
	self:Update()
end

function FastbindFrameMixin:OnMouseUp(button)
	self:SetButtonBinding(button)
	self:Update()
end

function FastbindFrameMixin:OnEnter()
	self:Update()
end

function FastbindFrameMixin:OnLeave()
	self:ClearButton()
end

function FastbindFrameMixin:Activate()
	if self.isActive then
		return
	end

	if InCombatLockdown() then
		print("|cffff0000You can't use Fastbind during combat.|r")
		return
	end

	self.isActive = true

	self:HookBindables()

	StaticPopup_Show(FASTBIND)
end

function FastbindFrameMixin:Deactivate()
	if not self.isActive then
		return
	end

	self.isActive = false

	self:ClearButton()

	StaticPopup_Hide(FASTBIND)
end

function FastbindFrameMixin:Update()
	if not self.command then
		return
	end

	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", -10, 5)

	local keys = { GetBindingKey(self.command) }

	d("Keybindings", keys)

	if #keys > 0 then
		GameTooltip:AddLine(table.concat(keys, ", "), 1, 1, 1)
	else
		GameTooltip:AddLine("Unbound", 0.5, 0.5, 0.5)
	end

	GameTooltip:Show()
end

function FastbindFrameMixin:ClearButton()
	self.button = nil
	self.command = nil

	self:Hide()

	GameTooltip:Hide()
end

function FastbindFrameMixin:SetButton(button)
	if (button.action) then
		local type = GetActionInfo(button.action)

		for i = 1, #EXCLUDED_ACTION_TYPES do
			if (type == EXCLUDED_ACTION_TYPES[i]) then
				return
			end
		end
	end

	local name = button:GetName()

	if string.find(name, "PetAction") then
		self.command = "BONUSACTIONBUTTON" .. button:GetID()
	elseif string.find(name, "Action") then
		self.command = string.upper(button:GetName())
	elseif string.find(name, "MultiBar") then
		self.command = button.buttonType .. button:GetID()
	elseif string.find(name, "Stance") then
		self.command = "SHAPESHIFTBUTTON" .. button:GetID()
	elseif string.find(name, "SpellButton") then
		local slot, slotType = SpellBook_GetSpellBookSlot(button)
		if slotType == "SPELL" then
			local spellName = GetSpellBookItemName(slot, SpellBookFrame.bookType)
			self.command = "SPELL " .. spellName
		end
	elseif string.find(name, "SpellFlyoutButton") then
		local spellName = GetSpellInfo(button.spellID)
		self.command = "SPELL " .. spellName
	elseif string.find(name, "ContainerFrame") then
		local id = C_Container.GetContainerItemID(button:GetParent():GetID(), button:GetID())
		if id then
			local itemName = GetItemInfo(id)
			if itemName then
				self.command = "ITEM " .. itemName
			end
		end
	end

	d({
		GetID = button:GetID(),
		GetName = button:GetName(),
		GetObjectType = button:GetObjectType(),
		buttonType = button.buttonType,
		action = button.action,
		spellID = button.spellID,
		itemID = button.itemID,
		skillID = button.skillID,
		binding = button.binding,
		location = button.location,
		slotType = button.slotType,
		slot = button.slot,
		macroID = button.macroID,
		command = self.command,
	})

	if (self.command) then
		self.button = button
		self:ClearAllPoints()
		self:SetAllPoints(button)
		self:Show()
	end
end

function FastbindFrameMixin:ClearButtonBindings()
	local keys = { GetBindingKey(self.command) }
	for _, key in pairs(keys) do
		SetBinding(key)
	end
end

function FastbindFrameMixin:SetButtonBinding(key)
	if (not self.button) then
		d(string.format("There's no button to bind to %s", tostring(key)))
		return
	end

	if (key == "RightButton") then
		self:ClearButtonBindings()
	end

	for i = 1, #EXCLUDED_KEYS do
		if (key == EXCLUDED_KEYS[i]) then
			d(string.format("Can't bind excluded key %s", tostring(key)))
			return
		end
	end

	if key == "Button4" then
		key = "BUTTON4"
	end

	if key == "Button5" then
		key = "BUTTON5"
	end

	local ctrl = IsControlKeyDown() and "CTRL-" or ""
	local alt = IsAltKeyDown() and "ALT-" or ""
	local shift = IsShiftKeyDown() and "SHIFT-" or ""

	d(string.format("Binding %s to %s.", ctrl .. alt .. shift .. key, tostring(self.command)))

	SetBinding(ctrl .. alt .. shift .. key, self.command)
end

function FastbindFrameMixin:Apply()
	SaveBindings(CHARACTER_BINDINGS)
	self:Deactivate()
end

function FastbindFrameMixin:Discard()
	LoadBindings(CHARACTER_BINDINGS)
	self:Deactivate()
end

function FastbindFrameMixin:HookFrameByName(name)
	local frame = _G[name]

	if not frame then
		d(string.format("Frame %s not found.", tostring(frame)))
		return
	end

	if frame.isFastbound then
		d(string.format("Frame %s already hooked.", tostring(frame:GetName())))
		return
	end

	d(string.format("Hooking to %s", tostring(frame:GetName())))

	frame.isFastbound = true

	frame:HookScript(
		"OnEnter",
		function()
			if self.isActive then
				self:SetButton(frame)
			end
		end
	)

	frame:HookScript(
		"OnClick",
		function()
			if self.isActive then
				d("Clicked on %s", frame:GetName())
			end
		end
	)
end

function FastbindFrameMixin:HookBindables()
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		for _, prefix in ipairs(BINDABLES_PREFIX_TABLE) do
			self:HookFrameByName(prefix .. i)
		end
	end

	for i = 1, NUM_CONTAINER_FRAMES do
		local maxSlots = MAX_CONTAINER_ITEMS

		-- Fix for retail.
		if not maxSlots then
			maxSlots = C_Container.GetContainerNumSlots(i)
		end
		for j = 1, maxSlots do
			self:HookFrameByName("ContainerFrame" .. i .. "Item" .. j)
		end
	end

	-- Bind profession spells.
	if PrimaryProfession1 then
		self:HookFrameByName("PrimaryProfession1SpellButtonTop")
		self:HookFrameByName("PrimaryProfession1SpellButtonBottom")
		self:HookFrameByName("PrimaryProfession2SpellButtonTop")
		self:HookFrameByName("PrimaryProfession2SpellButtonBottom")
		self:HookFrameByName("SecondaryProfession1SpellButtonLeft")
		self:HookFrameByName("SecondaryProfession1SpellButtonRight")
		self:HookFrameByName("SecondaryProfession2SpellButtonLeft")
		self:HookFrameByName("SecondaryProfession2SpellButtonRight")
		self:HookFrameByName("SecondaryProfession3SpellButtonLeft")
		self:HookFrameByName("SecondaryProfession3SpellButtonRight")
	end
end
