HYPERAUCTION_NUM_BROWSE_TO_DISPLAY = 8;
HYPERAUCTION_NUM_AUCTION_ITEMS_PER_PAGE = 50;
HYPERAUCTION_NUM_FILTERS_TO_DISPLAY = 15;
HYPERAUCTION_BROWSE_FILTER_HEIGHT = 20;
HYPERAUCTION_NUM_BIDS_TO_DISPLAY = 9;
HYPERAUCTION_NUM_AUCTIONS_TO_DISPLAY = 9;
HYPERAUCTION_AUCTIONS_BUTTON_HEIGHT = 37;
HYPERAUCTION_CLASS_FILTERS = {};
HYPERAUCTION_OPEN_FILTER_LIST = {};
HYPERAUCTION_AUCTION_TIMER_UPDATE_DELAY = 0.3;
HYPERAUCTION_MAXIMUM_BID_PRICE = 2000000000;
HYPERAUCTION_AUCTION_CANCEL_COST = 5; --5% of the current bid
HYPERAUCTION_NUM_TOKEN_LOGS_TO_DISPLAY = 14;

Hyperauction_AuctionSort = {};

-- owner sorts
Hyperauction_AuctionSort["owner_status"] = {
	{ column = "quantity", reverse = true },
	{ column = "bid",      reverse = false },
	{ column = "name",     reverse = false },
	{ column = "level",    reverse = true },
	{ column = "quality",  reverse = false },
	{ column = "duration", reverse = false },
	{ column = "status",   reverse = false },
};

Hyperauction_AuctionSort["owner_bid"] = {
	{ column = "quantity", reverse = true },
	{ column = "name",     reverse = false },
	{ column = "level",    reverse = true },
	{ column = "quality",  reverse = false },
	{ column = "duration", reverse = false },
	{ column = "status",   reverse = false },
	{ column = "bid",      reverse = false },
};

Hyperauction_AuctionSort["owner_quality"] = {
	{ column = "bid",          reverse = false },
	{ column = "quantity",     reverse = true },
	{ column = "minbidbuyout", reverse = false },
	{ column = "name",         reverse = false },
	{ column = "level",        reverse = true },
	{ column = "quality",      reverse = false },
};

Hyperauction_AuctionSort["owner_duration"] = {
	{ column = "quantity", reverse = true },
	{ column = "bid",      reverse = false },
	{ column = "name",     reverse = false },
	{ column = "level",    reverse = true },
	{ column = "quality",  reverse = false },
	{ column = "status",   reverse = false },
	{ column = "duration", reverse = false },
};

-- bidder sorts
Hyperauction_AuctionSort["bidder_quality"] = {
	{ column = "bid",          reverse = false },
	{ column = "quantity",     reverse = true },
	{ column = "minbidbuyout", reverse = false },
	{ column = "name",         reverse = false },
	{ column = "level",        reverse = true },
	{ column = "quality",      reverse = false },
};

Hyperauction_AuctionSort["bidder_level"] = {
	{ column = "minbidbuyout", reverse = true },
	{ column = "status",       reverse = true },
	{ column = "bid",          reverse = true },
	{ column = "duration",     reverse = true },
	{ column = "quantity",     reverse = false },
	{ column = "name",         reverse = true },
	{ column = "quality",      reverse = true },
	{ column = "level",        reverse = false },
};

Hyperauction_AuctionSort["bidder_buyout"] = {
	{ column = "quantity", reverse = true },
	{ column = "name",     reverse = false },
	{ column = "level",    reverse = true },
	{ column = "quality",  reverse = false },
	{ column = "status",   reverse = false },
	{ column = "bid",      reverse = false },
	{ column = "duration", reverse = false },
	{ column = "buyout",   reverse = false },
};

Hyperauction_AuctionSort["bidder_status"] = {
	{ column = "quantity",     reverse = true },
	{ column = "name",         reverse = false },
	{ column = "level",        reverse = true },
	{ column = "quality",      reverse = false },
	{ column = "minbidbuyout", reverse = false },
	{ column = "bid",          reverse = false },
	{ column = "duration",     reverse = false },
	{ column = "status",       reverse = false },
};

Hyperauction_AuctionSort["bidder_bid"] = {
	{ column = "quantity",     reverse = true },
	{ column = "name",         reverse = false },
	{ column = "level",        reverse = true },
	{ column = "quality",      reverse = false },
	{ column = "minbidbuyout", reverse = false },
	{ column = "status",       reverse = false },
	{ column = "duration",     reverse = false },
	{ column = "bid",          reverse = false },
};

Hyperauction_AuctionSort["bidder_duration"] = {
	{ column = "quantity",     reverse = true },
	{ column = "name",         reverse = false },
	{ column = "level",        reverse = true },
	{ column = "quality",      reverse = false },
	{ column = "minbidbuyout", reverse = false },
	{ column = "status",       reverse = false },
	{ column = "bid",          reverse = false },
	{ column = "duration",     reverse = false },
};

-- list sorts
Hyperauction_AuctionSort["list_level"] = {
	{ column = "duration",     reverse = true },
	{ column = "bid",          reverse = true },
	{ column = "quantity",     reverse = false },
	{ column = "minbidbuyout", reverse = true },
	{ column = "name",         reverse = true },
	{ column = "quality",      reverse = true },
	{ column = "level",        reverse = false },
};
Hyperauction_AuctionSort["list_duration"] = {
	{ column = "bid",          reverse = false },
	{ column = "quantity",     reverse = true },
	{ column = "minbidbuyout", reverse = false },
	{ column = "name",         reverse = false },
	{ column = "level",        reverse = true },
	{ column = "quality",      reverse = false },
	{ column = "duration",     reverse = false },
};
Hyperauction_AuctionSort["list_seller"] = {
	{ column = "duration",     reverse = false },
	{ column = "bid",          reverse = false },
	{ column = "quantity",     reverse = true },
	{ column = "minbidbuyout", reverse = false },
	{ column = "name",         reverse = false },
	{ column = "level",        reverse = true },
	{ column = "quality",      reverse = false },
	{ column = "seller",       reverse = false },
};
Hyperauction_AuctionSort["list_bid"] = {
	{ column = "duration", reverse = false },
	{ column = "quantity", reverse = true },
	{ column = "name",     reverse = false },
	{ column = "level",    reverse = true },
	{ column = "quality",  reverse = false },
	{ column = "bid",      reverse = false },
};

Hyperauction_AuctionSort["list_quality"] = {
	{ column = "duration",     reverse = false },
	{ column = "bid",          reverse = false },
	{ column = "quantity",     reverse = true },
	{ column = "minbidbuyout", reverse = false },
	{ column = "name",         reverse = false },
	{ column = "level",        reverse = true },
	{ column = "quality",      reverse = false },
};

Hyperauction_AuctionCategories = {};

local function FindDeepestCategory(categoryIndex, ...)
	local categoryInfo = Hyperauction_AuctionCategories[categoryIndex];
	for i = 1, select("#", ...) do
		local subCategoryIndex = select(i, ...);
		if categoryInfo and categoryInfo.subCategories and categoryInfo.subCategories[subCategoryIndex] then
			categoryInfo = categoryInfo.subCategories[subCategoryIndex];
		else
			break;
		end
	end
	return categoryInfo;
end

function Hyperauction_AuctionFrame_GetDetailColumnString(categoryIndex, subCategoryIndex)
	local categoryInfo = FindDeepestCategory(categoryIndex, subCategoryIndex);
	return categoryInfo and categoryInfo:GetDetailColumnString() or REQ_LEVEL_ABBR;
end

function Hyperauction_AuctionFrame_DoesCategoryHaveFlag(flag, categoryIndex, subCategoryIndex, subSubCategoryIndex)
	local categoryInfo = FindDeepestCategory(categoryIndex, subCategoryIndex, subSubCategoryIndex);
	if categoryInfo then
		return categoryInfo:HasFlag(flag);
	end
	return false;
end

function Hyperauction_AuctionFrame_CreateCategory(name)
	local category = CreateFromMixins(Hyperauction_AuctionCategoryMixin);
	category.name = name;
	Hyperauction_AuctionCategories[#Hyperauction_AuctionCategories + 1] = category;
	return category;
end

Hyperauction_AuctionCategoryMixin = {};

function Hyperauction_AuctionCategoryMixin:SetDetailColumnString(detailColumnString)
	self.detailColumnString = detailColumnString;
end

function Hyperauction_AuctionCategoryMixin:GetDetailColumnString()
	if self.detailColumnString then
		return self.detailColumnString;
	end
	if self.parent then
		return self.parent:GetDetailColumnString();
	end
	return REQ_LEVEL_ABBR;
end

function Hyperauction_AuctionCategoryMixin:CreateSubCategory(classID, subClassID, inventoryType)
	local name = "";
	if inventoryType then
		name = GetItemInventorySlotInfo(inventoryType);
	elseif classID and subClassID then
		name = GetItemSubClassInfo(classID, subClassID);
	elseif classID then
		name = GetItemClassInfo(classID);
	end
	return self:CreateNamedSubCategory(name);
end

function Hyperauction_AuctionCategoryMixin:CreateNamedSubCategory(name)
	self.subCategories = self.subCategories or {};

	local subCategory = CreateFromMixins(Hyperauction_AuctionCategoryMixin);
	self.subCategories[#self.subCategories + 1] = subCategory;
	assert(name and #name > 0);
	subCategory.name = name;
	subCategory.parent = self;
	subCategory.sortIndex = #self.subCategories;
	return subCategory;
end

function Hyperauction_AuctionCategoryMixin:CreateNamedSubCategoryAndFilter(name, classID, subClassID, inventoryType)
	local category = self:CreateNamedSubCategory(name);
	category:AddFilter(classID, subClassID, inventoryType);

	return category;
end

function Hyperauction_AuctionCategoryMixin:CreateSubCategoryAndFilter(classID, subClassID, inventoryType)
	local category = self:CreateSubCategory(classID, subClassID, inventoryType);
	category:AddFilter(classID, subClassID, inventoryType);

	return category;
end

function Hyperauction_AuctionCategoryMixin:AddBulkInventoryTypeCategories(classID, subClassID, inventoryTypes)
	for i, inventoryType in ipairs(inventoryTypes) do
		self:CreateSubCategoryAndFilter(classID, subClassID, inventoryType);
	end
end

function Hyperauction_AuctionCategoryMixin:AddFilter(classID, subClassID, inventoryType)
	self.filters = self.filters or {};
	self.filters[#self.filters + 1] = { classID = classID, subClassID = subClassID, inventoryType = inventoryType, };

	if self.parent then
		self.parent:AddFilter(classID, subClassID, inventoryType);
	end
end

do
	local function GenerateSubClassesHelper(self, classID, ...)
		for i = 1, select("#", ...) do
			local subClassID = select(i, ...);
			self:CreateSubCategoryAndFilter(classID, subClassID);
		end
	end

	function Hyperauction_AuctionCategoryMixin:GenerateSubCategoriesAndFiltersFromSubClass(classID)
		GenerateSubClassesHelper(self, classID, GetAuctionItemSubClasses(classID));
	end
end

function Hyperauction_AuctionCategoryMixin:FindSubCategoryByName(name)
	if self.subCategories then
		for i, subCategory in ipairs(self.subCategories) do
			if subCategory.name == name then
				return subCategory;
			end
		end
	end
end

function Hyperauction_AuctionCategoryMixin:SortSubCategories()
	if self.subCategories then
		table.sort(self.subCategories, function(left, right)
			return left.sortIndex < right.sortIndex;
		end)
	end
end

function Hyperauction_AuctionCategoryMixin:SetSortIndex(sortIndex)
	self.sortIndex = sortIndex
end

function Hyperauction_AuctionCategoryMixin:SetFlag(flag)
	self.flags = self.flags or {};
	self.flags[flag] = true;
end

function Hyperauction_AuctionCategoryMixin:ClearFlag(flag)
	if self.flags then
		self.flags[flag] = nil;
	end
end

function Hyperauction_AuctionCategoryMixin:HasFlag(flag)
	return not not (self.flags and self.flags[flag]);
end

do -- Weapons
	local weaponsCategory = Hyperauction_AuctionFrame_CreateCategory(AUCTION_CATEGORY_WEAPONS);

	weaponsCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Axe1H);
	weaponsCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Axe2H);
	weaponsCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Bows);
	weaponsCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Guns);
	weaponsCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Mace1H);
	weaponsCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Mace2H);
	weaponsCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Polearm);
	weaponsCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Sword1H);
	weaponsCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Sword2H);
	weaponsCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Staff);
	weaponsCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Unarmed);
	weaponsCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Generic);
	weaponsCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Dagger);
	weaponsCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Thrown);
	weaponsCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Crossbow);
	weaponsCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Wand);
	weaponsCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Fishingpole);
end

do -- Armor
	local MiscArmorInventoryTypes = {
		Enum.InventoryType.IndexHeadType,
		Enum.InventoryType.IndexNeckType,
		Enum.InventoryType.IndexBodyType,
		Enum.InventoryType.IndexFingerType,
		Enum.InventoryType.IndexTrinketType,
		Enum.InventoryType.IndexHoldableType,
	};

	local ClothArmorInventoryTypes = {
		Enum.InventoryType.IndexHeadType,
		Enum.InventoryType.IndexShoulderType,
		Enum.InventoryType.IndexChestType,
		Enum.InventoryType.IndexWaistType,
		Enum.InventoryType.IndexLegsType,
		Enum.InventoryType.IndexFeetType,
		Enum.InventoryType.IndexWristType,
		Enum.InventoryType.IndexHandType,
		Enum.InventoryType.IndexCloakType, -- Only for Cloth.
	};

	local ArmorInventoryTypes = {
		Enum.InventoryType.IndexHeadType,
		Enum.InventoryType.IndexShoulderType,
		Enum.InventoryType.IndexChestType,
		Enum.InventoryType.IndexWaistType,
		Enum.InventoryType.IndexLegsType,
		Enum.InventoryType.IndexFeetType,
		Enum.InventoryType.IndexWristType,
		Enum.InventoryType.IndexHandType,
	};

	local armorCategory = Hyperauction_AuctionFrame_CreateCategory(AUCTION_CATEGORY_ARMOR);

	local miscCategory = armorCategory:CreateSubCategory(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Generic);
	miscCategory:AddBulkInventoryTypeCategories(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Generic,
		MiscArmorInventoryTypes);

	local clothCategory = armorCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Cloth);
	clothCategory:AddBulkInventoryTypeCategories(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Cloth,
		ClothArmorInventoryTypes);

	local clothChestCategory = clothCategory:FindSubCategoryByName(GetItemInventorySlotInfo(Enum.InventoryType
		.IndexChestType));
	clothChestCategory:AddFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Cloth, Enum.InventoryType.IndexRobeType);

	local leatherCategory = armorCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass
		.Leather);
	leatherCategory:AddBulkInventoryTypeCategories(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Leather,
		ArmorInventoryTypes);

	local leatherChestCategory = leatherCategory:FindSubCategoryByName(GetItemInventorySlotInfo(Enum.InventoryType
		.IndexChestType));
	leatherChestCategory:AddFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Leather, Enum.InventoryType
		.IndexRobeType);

	local mailCategory = armorCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Mail);
	mailCategory:AddBulkInventoryTypeCategories(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Mail, ArmorInventoryTypes);

	local mailChestCategory = mailCategory:FindSubCategoryByName(GetItemInventorySlotInfo(Enum.InventoryType
		.IndexChestType));
	mailChestCategory:AddFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Mail, Enum.InventoryType.IndexRobeType);

	local plateCategory = armorCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Plate);
	plateCategory:AddBulkInventoryTypeCategories(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Plate, ArmorInventoryTypes);

	local plateChestCategory = plateCategory:FindSubCategoryByName(GetItemInventorySlotInfo(Enum.InventoryType
		.IndexChestType));
	plateChestCategory:AddFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Plate, Enum.InventoryType.IndexRobeType);

	armorCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Shield);
	armorCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Libram);
	armorCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Idol);
	armorCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Totem);
end

do -- Containers
	local containersCategory = Hyperauction_AuctionFrame_CreateCategory(AUCTION_CATEGORY_CONTAINERS);
	--containersCategory:SetDetailColumnString(SLOT_ABBR);
	containersCategory:GenerateSubCategoriesAndFiltersFromSubClass(Enum.ItemClass.Container);
end

do -- Consumables (SubClasses Added in TBC)
	local consumablesCategory = Hyperauction_AuctionFrame_CreateCategory(AUCTION_CATEGORY_CONSUMABLES);
	if ClassicExpansionAtLeast(LE_EXPANSION_BURNING_CRUSADE) then
		consumablesCategory:GenerateSubCategoriesAndFiltersFromSubClass(Enum.ItemClass.Consumable);
	else
		consumablesCategory:AddFilter(Enum.ItemClass.Consumable);
	end
end

do -- Glyphs (Added in Wrath)
	if ClassicExpansionAtLeast(LE_EXPANSION_WRATH_OF_THE_LICH_KING) then
		local glyphsCategory = Hyperauction_AuctionFrame_CreateCategory(AUCTION_CATEGORY_GLYPHS);
		glyphsCategory:GenerateSubCategoriesAndFiltersFromSubClass(Enum.ItemClass.Glyph);
	end
end

do -- Trade Goods (SubClasses Added in TBC)
	local tradeGoodsCategory = Hyperauction_AuctionFrame_CreateCategory(AUCTION_CATEGORY_TRADE_GOODS);
	if ClassicExpansionAtLeast(LE_EXPANSION_BURNING_CRUSADE) then
		tradeGoodsCategory:GenerateSubCategoriesAndFiltersFromSubClass(Enum.ItemClass.Tradegoods);
	else
		tradeGoodsCategory:AddFilter(Enum.ItemClass.Tradegoods);
	end
end

do -- Projectile
	local projectileCategory = Hyperauction_AuctionFrame_CreateCategory(AUCTION_CATEGORY_PROJECTILE);
	projectileCategory:GenerateSubCategoriesAndFiltersFromSubClass(Enum.ItemClass.Projectile);
end

do -- Quiver
	local quiverCategory = Hyperauction_AuctionFrame_CreateCategory(AUCTION_CATEGORY_QUIVER);
	quiverCategory:GenerateSubCategoriesAndFiltersFromSubClass(Enum.ItemClass.Quiver);
end

do -- Recipes
	local recipesCategory = Hyperauction_AuctionFrame_CreateCategory(AUCTION_CATEGORY_RECIPES);
	recipesCategory:GenerateSubCategoriesAndFiltersFromSubClass(Enum.ItemClass.Recipe);
end

do -- Reagent (Changed to a ItemClass.Miscellaneous and other ClassIDs in TBC)
	if GetClassicExpansionLevel() == LE_EXPANSION_CLASSIC then
		local reagentCategory = Hyperauction_AuctionFrame_CreateCategory(AUCTION_CATEGORY_REAGENT);
		reagentCategory:AddFilter(Enum.ItemClass.Reagent);
	end
end

do -- Gems (Added in TBC)
	if ClassicExpansionAtLeast(LE_EXPANSION_BURNING_CRUSADE) then
		local gemsCategory = Hyperauction_AuctionFrame_CreateCategory(AUCTION_CATEGORY_GEMS);
		gemsCategory:GenerateSubCategoriesAndFiltersFromSubClass(Enum.ItemClass.Gem);
	end
end

do -- Miscellaneous (SubClasses Added in TBC)
	local miscellaneousCategory = Hyperauction_AuctionFrame_CreateCategory(AUCTION_CATEGORY_MISCELLANEOUS);
	miscellaneousCategory:AddFilter(Enum.ItemClass.Miscellaneous);
	if ClassicExpansionAtLeast(LE_EXPANSION_BURNING_CRUSADE) then
		miscellaneousCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Miscellaneous,
			Enum.ItemMiscellaneousSubclass.Junk);
		miscellaneousCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Miscellaneous,
			Enum.ItemMiscellaneousSubclass.Reagent);
		miscellaneousCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Miscellaneous,
			Enum.ItemMiscellaneousSubclass.CompanionPet);
		miscellaneousCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Miscellaneous,
			Enum.ItemMiscellaneousSubclass.Holiday);
		miscellaneousCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Miscellaneous,
			Enum.ItemMiscellaneousSubclass.Other);
		miscellaneousCategory:CreateSubCategoryAndFilter(Enum.ItemClass.Miscellaneous,
			Enum.ItemMiscellaneousSubclass.Mount);
	end
end

do -- Quest Items (Added in TBC)
	if ClassicExpansionAtLeast(LE_EXPANSION_BURNING_CRUSADE) then
		local questItemsCategory = Hyperauction_AuctionFrame_CreateCategory(AUCTION_CATEGORY_QUEST_ITEMS);
		questItemsCategory:AddFilter(Enum.ItemClass.Questitem);
	end
end

-- do -- WoW Token
-- 	local wowTokenCategory = Hyperauction_AuctionFrame_CreateCategory(TOKEN_FILTER_LABEL);
-- 	wowTokenCategory:AddFilter(ITEM_CLASS_WOW_TOKEN);
-- 	wowTokenCategory:SetFlag("WOW_TOKEN_FLAG");
-- end
