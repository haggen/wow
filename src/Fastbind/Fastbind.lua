-- Fastbind
-- The MIT License © 2017 Arthur Corenzan
-- More on https://github.com/haggen/wow

-- Add-on name constant.
--
local FASTBIND = ...

-- Add-on table.
--
local api = select(2, ...)

-- Slash command.
--
SLASH_FASTBIND1 = "/fastbind"

-- Keybinding sets.
--
local KEYBINDINGS = {
	DEFAULT = 0,
	ACCOUNT = 1,
	CHARACTER = 2
}

-- Modifiers and keys that we shouldn't bind to.
--
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

-- Prefixes for action bars.
--
local ACTIONBAR_PREFIXES = {
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

-- Fastbind frame mixin.
--
FastbindFrameMixin = {}

-- Initialize frame.
--
function FastbindFrameMixin:OnLoad()
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

	function SlashCmdList.FASTBIND()
		self:Activate()
	end

	self:RegisterEvent("ADDON_LOADED")
end

function FastbindFrameMixin:OnEvent(event, ...)
	if event == "ADDON_LOADED" then
		local name = ...

		if name == FASTBIND then
			api.MigrateSavedVars()
		end
	end
end

function FastbindFrameMixin:OnKeyUp(key)
	self:SetBinding(key)
	self:Update()
end

function FastbindFrameMixin:OnMouseUp(button)
	self:SetBinding(button)
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

function FastbindFrameMixin:Apply()
	SaveBindings(KEYBINDINGS.CHARACTER)
	self:Deactivate()
end

function FastbindFrameMixin:Discard()
	LoadBindings(KEYBINDINGS.CHARACTER)
	self:Deactivate()
end

function FastbindFrameMixin:Update()
	if not self.command then
		return
	end

	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", -10, 5)

	local keys = { GetBindingKey(self.command) }

	api.Dump(keys)

	if #keys > 0 then
		GameTooltip:AddLine(table.concat(keys, ", "), 1, 1, 1)
	else
		GameTooltip:AddLine("Unbound", 0.5, 0.5, 0.5)
	end

	GameTooltip:Show()
end

function FastbindFrameMixin:ClearButton()
	self.command = nil
	self.button = nil

	self:Hide()

	GameTooltip:Hide()
end

function FastbindFrameMixin:SetButton(button)
	if button.action then
		local type = GetActionInfo(button.action)

		-- We wouldn't want to bind the flyout button, only the spells inside it.
		if type == "flyout" then
			return
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

	api.Dump({
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

	if self.command then
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

function FastbindFrameMixin:SetBinding(key)
	if not self.button then
		api.Printf("No button is set.")
		return
	end

	if key == "RightButton" then
		self:ClearButtonBindings()
	end

	for i = 1, #EXCLUDED_KEYS do
		if key == EXCLUDED_KEYS[i] then
			api.Printf("Can't bind excluded key '%s'", key)
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

	api.Printf("Binding '%s' to '%s'.", ctrl .. alt .. shift .. key, self.command)

	SetBinding(ctrl .. alt .. shift .. key, self.command)
end

function FastbindFrameMixin:HookButton(name)
	local button = _G[name]

	if not button then
		api.Printf("Frame '%s' not found.", name)
		return false
	end

	if button.isFastbound then
		api.Printf("Frame '%s' already hooked.", name)
		return false
	end

	api.Printf("Hooking to '%s'.", name)

	button.isFastbound = 1
	button:HookScript(
		"OnEnter",
		function()
			if self.isActive then
				self:SetButton(button)
			end
		end
	)

	return true
end

function FastbindFrameMixin:HookBindables()
	for _, prefix in ipairs(ACTIONBAR_PREFIXES) do
		local index = 1
		while self:HookButton(prefix .. index) do
			index = index + 1
		end
	end

	for i = 1, 5 do
		local j = 1
		while self:HookButton("ContainerFrame" .. i .. "Item" .. j) do
			j = j + 1
		end
	end

	-- TODO: Not working.
	-- if PrimaryProfession1 then
	-- 	self:HookFrameByName("PrimaryProfession1SpellButtonTop")
	-- 	self:HookFrameByName("PrimaryProfession1SpellButtonBottom")
	-- 	self:HookFrameByName("PrimaryProfession2SpellButtonTop")
	-- 	self:HookFrameByName("PrimaryProfession2SpellButtonBottom")
	-- 	self:HookFrameByName("SecondaryProfession1SpellButtonLeft")
	-- 	self:HookFrameByName("SecondaryProfession1SpellButtonRight")
	-- 	self:HookFrameByName("SecondaryProfession2SpellButtonLeft")
	-- 	self:HookFrameByName("SecondaryProfession2SpellButtonRight")
	-- 	self:HookFrameByName("SecondaryProfession3SpellButtonLeft")
	-- 	self:HookFrameByName("SecondaryProfession3SpellButtonRight")
	-- end
end
