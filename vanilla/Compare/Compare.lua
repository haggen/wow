-- Compare 1.0.0
-- The MIT License © 2017 Arthur Corenzan

local inventoryTypeToSlotName = {
	INVTYPE_2HWEAPON = "MainHandSlot", 
	INVTYPE_BODY = "ShirtSlot", 
	INVTYPE_BOWPROJECTILE  ="AmmoSlot", 
	INVTYPE_CHEST = "ChestSlot", 
	INVTYPE_CLOAK = "BackSlot", 
	INVTYPE_CROSSBOW = "RangedSlot", 
	INVTYPE_FEET = "FeetSlot", 
	INVTYPE_FINGER = "Finger0Slot", 
	INVTYPE_GUN = "RangedSlot", 
	INVTYPE_GUNPROJECTILE = "AmmoSlot", 
	INVTYPE_HAND = "HandsSlot", 
	INVTYPE_HEAD = "HeadSlot", 
	INVTYPE_HOLDABLE = "SecondaryHandSlot", 
	INVTYPE_LEGS = "LegsSlot", 
	INVTYPE_NECK = "NeckSlot", 
	INVTYPE_RANGED = "RangedSlot", 
	INVTYPE_RELIC = "RangedSlot", 
	INVTYPE_ROBE = "ChestSlot", 
	INVTYPE_SHIELD = "SecondaryHandSlot", 
	INVTYPE_SHOULDER = "ShoulderSlot", 
	INVTYPE_TABARD = "TabardSlot", 
	INVTYPE_THROWN = "RangedSlot", 
	INVTYPE_TRINKET = "Trinket0Slot", 
	INVTYPE_WAIST = "WaistSlot", 
	INVTYPE_WAND = "RangedSlot", 
	INVTYPE_WEAPON = "MainHandSlot", 
	INVTYPE_WEAPONMAINHAND = "MainHandSlot", 
	INVTYPE_WEAPONOFFHAND = "SecondaryHandSlot", 
	INVTYPE_WRIST = "WristSlot", 
}

local inventoryTypeSecondarySlot = {
	INVTYPE_FINGER = "Finger1Slot",
	INVTYPE_TRINKET = "Trinket1Slot",
	INVTYPE_WEAPON = "SecondaryHandSlot",
	INVTYPE_2HWEAPON = "SecondaryHandSlot",
}

local function GetItemInfoFromContainerSlot(containerID, slotID)
	local containerItemLink = GetContainerItemLink(containerID, slotID)

	if not containerItemLink then
		return nil
	end

	local containerItemID = string.gsub(containerItemLink, ".*item:(%d+).*", "%1")
	return GetItemInfo(containerItemID)
end

local _GameTooltip_OnHide = GameTooltip_OnHide
function GameTooltip_OnHide()
	_GameTooltip_OnHide()
	CompareTooltip1:Hide()
	CompareTooltip2:Hide()
end

local _ContainerFrameItemButton_OnEnter = ContainerFrameItemButton_OnEnter
function ContainerFrameItemButton_OnEnter(button)
	_ContainerFrameItemButton_OnEnter(button)

	if not button then
		button = this
	end

	if GameTooltip:IsOwned(button) then
		local _, _, _, _, _, _, _, inventoryType = GetItemInfoFromContainerSlot(button:GetParent():GetID(), button:GetID())

		if not inventoryType then
			return
		end

		local slotName = inventoryTypeToSlotName[inventoryType]

		if slotName then
			local slotIndex = GetInventorySlotInfo(slotName)
		
			CompareTooltip1:SetOwner(GameTooltip, "ANCHOR_NONE")
			CompareTooltip1:ClearAllPoints()
			CompareTooltip1:SetPoint("TOPRIGHT", "GameTooltip", "TOPLEFT", 0, -10)
			CompareTooltip1:SetInventoryItem("player", slotIndex)

			if CompareTooltip1TextLeft1:GetWidth() < 105 then
				CompareTooltip1TextLeft1:SetWidth(105)
			end

			CompareTooltip1:Show()

			local secondarySlotName = inventoryTypeSecondarySlot[inventoryType]

			if secondarySlotName then
				local secondarySlotIndex = GetInventorySlotInfo(secondarySlotName)

				CompareTooltip2:SetOwner(GameTooltip, "ANCHOR_NONE")
				CompareTooltip2:ClearAllPoints()
				CompareTooltip2:SetPoint("TOPRIGHT", "CompareTooltip1", "TOPLEFT", 0, 0)
				CompareTooltip2:SetInventoryItem("player", secondarySlotIndex)

				if CompareTooltip2TextLeft1:GetWidth() < 105 then
					CompareTooltip2TextLeft1:SetWidth(105)
				end
				
				CompareTooltip2:Show()
			end
		end
	end
end
