-- Fastbind
-- The MIT License © 2017 Arthur Corenzan
-- More on https://github.com/haggen/wow

local function d()
end
-- local function d(...) print(...) end

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

FastbindSavedVars = {
	minimapButtonPosition = 145
}

function Fastbind_OnEvent(_, event, ...)
	if (event == "ADDON_LOADED") then
		local name = ...
		if (name == "Fastbind") then
			for key, value in pairs(FastbindSavedVars) do
				d(key, "=", value)
			end
			FastbindMinimapButton_UpdatePosition()
			FastbindMinimapButton:Show()
		end
	end
end

function Fastbind_Activate()
	if Fastbind.isActive then
		return
	elseif InCombatLockdown() then
		print("You can't use it in combat.")
	else
		Fastbind_FindBindables()
		Fastbind.isActive = true
		StaticPopup_Show("FASTBIND")
	end
end

function Fastbind_Deactivate()
	if Fastbind.isActive then
		Fastbind.isActive = nil
		Fastbind_ClearTarget()
		StaticPopup_Hide("FASTBIND")
	end
end

function Fastbind_Toggle()
	if Fastbind.isActive then
		Fastbind_Deactivate()
	else
		Fastbind_Activate()
	end
end

function Fastbind_UpdateTooltip()
	if (not Fastbind.command) then
		return
	end

	GameTooltip:SetOwner(Fastbind, "ANCHOR_TOPLEFT", -10, 5)

	local bindingKeys = {GetBindingKey(Fastbind.command)}
	for _, key in pairs(bindingKeys) do
		GameTooltip:AddLine(key, 1, 1, 1)
	end

	if (#bindingKeys == 0) then
		GameTooltip:AddLine("Not bound.", 0.5, 0.5, 0.5)
	end

	GameTooltip:Show()
end

function Fastbind_ClearTarget()
	Fastbind.target = nil
	Fastbind.command = nil
	Fastbind:Hide()
	GameTooltip:Hide()
end

function Fastbind_SetTarget(target)
	if target.action then
		local actionType = GetActionInfo(target.action)
		if (actionType == "flyout") then
			return
		end
	end

	d("GetID = " .. tostring(target:GetID()))
	d("GetName = " .. tostring(target:GetName()))
	d("GetObjectType = " .. tostring(target:GetObjectType()))
	d("buttonType = " .. tostring(target.buttonType))
	d("action = " .. tostring(target.action))
	d("spellID = " .. tostring(target.spellID))
	d("itemID = " .. tostring(target.itemID))
	d("skillID = " .. tostring(target.skillID))
	d("binding = " .. tostring(target.binding))
	d("location = " .. tostring(target.location))
	d("slotType = " .. tostring(target.slotType))
	d("slot = " .. tostring(target.slot))
	d("slot = " .. tostring(target.macroID))

	local name = target:GetName()

	if string.find(name, "PetAction") then
		Fastbind.command = "BONUSACTIONBUTTON" .. target:GetID()
	elseif string.find(name, "Action") then
		Fastbind.command = string.upper(target:GetName())
	elseif string.find(name, "MultiBar") then
		Fastbind.command = target.buttonType .. target:GetID()
	elseif string.find(name, "Stance") then
		Fastbind.command = "SHAPESHIFTBUTTON" .. target:GetID()
	elseif string.find(name, "SpellButton") then
		local slot, slotType = SpellBook_GetSpellBookSlot(target)
		if slotType == "SPELL" then
            local spellName = GetSpellBookItemName(slot, SpellBookFrame.bookType)
            Fastbind.command = "SPELL " .. spellName
		end
	elseif string.find(name, "SpellFlyoutButton") then
		local spellName = GetSpellInfo(target.spellID)
		Fastbind.command = "SPELL " .. spellName
	elseif string.find(name, "ContainerFrame") then
		local id = GetContainerItemID(target:GetParent():GetID(), target:GetID())
		if id then
			local itemName = GetItemInfo(id)
			if itemName then
				Fastbind.command = "ITEM " .. itemName
			end
		end
	elseif string.find(name, "Macro") then
		local id = MacroFrame.macroBase + target:GetID()
		Fastbind.command = "MACRO " .. id
	end

	d(Fastbind.command)

	if Fastbind.command then
		Fastbind.target = target
		Fastbind:ClearAllPoints()
		Fastbind:SetAllPoints(target)
		Fastbind:Show()
	end
end

function Fastbind_ClearBinding()
	local bindingKeys = {GetBindingKey(Fastbind.command)}
	for _, key in pairs(bindingKeys) do
		SetBinding(key)
	end
end

function Fastbind_SetBinding(key)
	if (not Fastbind.target) then
		return
	end

	if (key == "RightButton") then
		Fastbind_ClearBinding()
	end

	for i = 1, #EXCLUDED_KEYS do
		if (key == EXCLUDED_KEYS[i]) then
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

	d(ctrl .. alt .. shift .. key, Fastbind.command)

	-- SetBinding(ctrl..alt..shift..key)
	SetBinding(ctrl .. alt .. shift .. key, Fastbind.command)
end

function Fastbind_Apply()
	SaveBindings(2)
	Fastbind_Deactivate()
end

function Fastbind_Discard()
	LoadBindings(2)
	Fastbind_Deactivate()
end

function Fastbind_SetHook(name)
	local frame = _G[name]
	if (frame and not frame.hookedForFastbind) then
		d("Hooking " .. frame:GetName())
		frame.hookedForFastbind = true
		frame:HookScript(
			"OnEnter",
			function()
				if Fastbind.isActive then
					Fastbind_SetTarget(frame)
				end
			end
		)
		frame:HookScript(
			"OnClick",
			function()
				if Fastbind.isActive then
					Fastbind_FindBindables(frame)
				end
			end
		)
	end
end

function Fastbind_FindBindables()
	local prefixes = {
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

	for i = 1, NUM_ACTIONBAR_BUTTONS do
		for _, prefix in ipairs(prefixes) do
			Fastbind_SetHook(prefix .. i)
		end
	end

	for i = 1, MAX_ACCOUNT_MACROS do
		Fastbind_SetHook("MacroButton" .. i)
	end

	for i = 1, NUM_CONTAINER_FRAMES do
		for j = 1, MAX_CONTAINER_ITEMS do
			Fastbind_SetHook("ContainerFrame" .. i .. "Item" .. j)
		end
	end
end

--
--
--

function FastbindMinimapButton_UpdatePosition()
	local angle = math.rad(FastbindSavedVars.minimapButtonPosition)
	local x, y = math.cos(angle) * 80, math.sin(angle) * 80
	FastbindMinimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

function FastbindMinimapButton_OnEnter(self)
	if self.dragging then
		return
	end
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:SetText("Fastbind", 1, 1, 1)
	GameTooltip:AddLine("Click to customize your keybindings.", nil, nil, nil, 1)
	GameTooltip:Show()
end

function FastbindMinimapButton_OnLeave()
	GameTooltip:Hide()
end

function FastbindMinimapButton_OnMouseDown()
	FastbindMinimapButtonIcon:SetPoint("TOPLEFT", FastbindMinimapButton, "TOPLEFT", 8, -7)
	FastbindMinimapButtonIcon:SetAlpha(0.5)
	FastbindMinimapButtonBackground:SetAlpha(0.9)
	FastbindMinimapButton.isMouseDown = true
end

function FastbindMinimapButton_OnMouseUp()
	FastbindMinimapButtonIcon:SetPoint("TOPLEFT", FastbindMinimapButton, "TOPLEFT", 7, -6)
	FastbindMinimapButtonIcon:SetAlpha(1)
	FastbindMinimapButtonBackground:SetAlpha(0.6)
	FastbindMinimapButton.isMouseDown = true
end

function FastbindMinimapButton_OnClick()
	Fastbind_Activate()
end

function FastbindMinimapButton_OnUpdate()
	local mx, my = Minimap:GetCenter()
	local px, py = GetCursorPosition()
	local scale = Minimap:GetEffectiveScale()
	px, py = px / scale, py / scale
	FastbindSavedVars.minimapButtonPosition = math.deg(math.atan2(py - my, px - mx)) % 360
	FastbindMinimapButton_UpdatePosition()
	d(FastbindSavedVars.minimapButtonPosition)
end

function FastbindMinimapButton_OnDragStart()
	GameTooltip:Hide()
	FastbindMinimapButton:LockHighlight()
	FastbindMinimapButton.dragging = true
	FastbindMinimapButton.isMouseDown = true
	FastbindMinimapButton:SetScript("OnUpdate", FastbindMinimapButton_OnUpdate)
end

function FastbindMinimapButton_OnDragStop()
	FastbindMinimapButton:UnlockHighlight()
	FastbindMinimapButton.dragging = false
	FastbindMinimapButton.isMouseDown = false
	FastbindMinimapButton:SetScript("OnUpdate", nil)
	FastbindMinimapButton_OnMouseUp()
end

function FastbindMinimapButton_OnLoad()
	FastbindMinimapButton:RegisterForDrag("LeftButton")
end

--
--
--

StaticPopupDialogs.FASTBIND = {
	text = "Move your mouse over any action bar slot, inventory item, spell or macro, to see the its keybinding. While hovering it press a new key or key combination to change it or right-click to unbind it. Press ESC or click on Discard to undo any changes.",
	button1 = "Save",
	button2 = "Discard",
	OnAccept = function()
		Fastbind_Apply()
	end,
	OnCancel = function()
		Fastbind_Discard()
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = true
}

SLASH_FASTBIND1 = "/fastbind"
SLASH_FASTBIND2 = "/fb"

SlashCmdList.FASTBIND = function()
	Fastbind_Toggle()
end
