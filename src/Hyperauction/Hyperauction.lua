-- keep last item sent to auction & it's price
HYPERAUCTION_LAST_ITEM_AUCTIONED = "";
HYPERAUCTION_LAST_ITEM_COUNT = 0;
HYPERAUCTION_LAST_ITEM_START_BID = 0;
HYPERAUCTION_LAST_ITEM_BUYOUT = 0;

local BROWSE_PARAM_INDEX_PAGE = 7;
local PRICE_TYPE_UNIT = 1;
local PRICE_TYPE_STACK = 2;

-- UIPanelWindows["Hyperauction_AuctionFrame"] = { area = "doublewide", pushable = 0, width = 840 };

local function GetPrices()
	local startPrice = MoneyInputFrame_GetCopper(Hyperauction_StartPrice);
	local buyoutPrice = MoneyInputFrame_GetCopper(Hyperauction_BuyoutPrice);
	if (Hyperauction_AuctionFrameAuctions.priceType == PRICE_TYPE_UNIT) then
		startPrice = startPrice * Hyperauction_AuctionsStackSizeEntry:GetNumber();
		buyoutPrice = buyoutPrice * Hyperauction_AuctionsStackSizeEntry:GetNumber();
	end
	return startPrice, buyoutPrice;
end

Hyperauction_MoneyTypeInfo = MoneyTypeInfo;

Hyperauction_MoneyTypeInfo["AUCTION_DEPOSIT"] = {
	UpdateFunc = function()
		if (not Hyperauction_AuctionFrameAuctions.duration) then
			Hyperauction_AuctionFrameAuctions.duration = 0
		end
		local startPrice, buyoutPrice = GetPrices();
		return GetAuctionDeposit(Hyperauction_AuctionFrameAuctions.duration, startPrice, buyoutPrice);
	end,
	collapse = 1,
};

Hyperauction_MoneyTypeInfo["AUCTION_DEPOSIT_TOKEN"] = {
	UpdateFunc = function()
		return nil;
	end,
	collapse = 1,
};

StaticPopupDialogs["HYPERAUCTION_BUYOUT_AUCTION"] = {
	text = BUYOUT_AUCTION_CONFIRMATION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self)
		PlaceAuctionBid(Hyperauction_AuctionFrame.type, GetSelectedAuctionItem(Hyperauction_AuctionFrame.type),
			Hyperauction_AuctionFrame.buyoutPrice);
	end,
	OnShow = function(self)
		MoneyFrame_Update(self.moneyFrame, Hyperauction_AuctionFrame.buyoutPrice);
	end,
	OnCancel = function(self)
		Hyperauction_BrowseBuyoutButton:Enable();
	end,
	hasMoneyFrame = 1,
	showAlert = 1,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["HYPERAUCTION_BID_AUCTION"] = {
	text = BID_AUCTION_CONFIRMATION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self)
		PlaceAuctionBid(Hyperauction_AuctionFrame.type, GetSelectedAuctionItem(Hyperauction_AuctionFrame.type),
			MoneyInputFrame_GetCopper(Hyperauction_BrowseBidPrice));
	end,
	OnShow = function(self)
		MoneyFrame_Update(self.moneyFrame, MoneyInputFrame_GetCopper(Hyperauction_BrowseBidPrice));
	end,
	OnCancel = function(self)
		Hyperauction_BrowseBidButton:Enable();
	end,
	hasMoneyFrame = 1,
	showAlert = 1,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["HYPERAUCTION_CANCEL_AUCTION"] = {
	text = CANCEL_AUCTION_CONFIRMATION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		CancelAuction(GetSelectedAuctionItem("owner"));
	end,
	OnShow = function(self)
		MoneyFrame_Update(self.moneyFrame, Hyperauction_AuctionFrameAuctions.cancelPrice);
		if (Hyperauction_AuctionFrameAuctions.cancelPrice > 0) then
			self.text:SetText(CANCEL_AUCTION_CONFIRMATION_MONEY);
		else
			self.text:SetText(CANCEL_AUCTION_CONFIRMATION);
		end
	end,
	hasMoneyFrame = 1,
	showAlert = 1,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["HYPERAUCTION_TOKEN_NONE_FOR_SALE"] = {
	text = TOKEN_NONE_FOR_SALE,
	button1 = OKAY,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = true,
}
StaticPopupDialogs["HYPERAUCTION_TOKEN_AUCTIONABLE_TOKEN_OWNED"] = {
	text = TOKEN_AUCTIONABLE_TOKEN_OWNED,
	button1 = OKAY,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = true,
}

function Hyperauction_AuctionFrame_OnLoad(self)
	-- Tab Handling code
	PanelTemplates_SetNumTabs(self, 3);
	PanelTemplates_SetTab(self, 1);
	Hyperauction_AuctionsBuyoutText:SetText(BUYOUT_PRICE .. " |cff808080(" .. OPTIONAL .. ")|r");

	-- Set focus rules
	Hyperauction_AuctionsStackSizeEntry.prevFocus = Hyperauction_BuyoutPriceCopper;
	Hyperauction_AuctionsStackSizeEntry.nextFocus = Hyperauction_AuctionsNumStacksEntry;
	Hyperauction_AuctionsNumStacksEntry.prevFocus = Hyperauction_AuctionsStackSizeEntry;
	Hyperauction_AuctionsNumStacksEntry.nextFocus = Hyperauction_StartPriceGold;

	MoneyInputFrame_SetPreviousFocus(Hyperauction_BrowseBidPrice, Hyperauction_BrowseMaxLevel);
	MoneyInputFrame_SetNextFocus(Hyperauction_BrowseBidPrice, Hyperauction_BrowseName);

	MoneyInputFrame_SetPreviousFocus(Hyperauction_BidBidPrice, BidBidPriceCopper);
	MoneyInputFrame_SetNextFocus(Hyperauction_BidBidPrice, BidBidPriceGold);

	MoneyInputFrame_SetPreviousFocus(Hyperauction_StartPrice, Hyperauction_AuctionsNumStacksEntry);
	MoneyInputFrame_SetNextFocus(Hyperauction_StartPrice, BuyoutPriceGold);

	MoneyInputFrame_SetPreviousFocus(Hyperauction_BuyoutPrice, StartPriceCopper);
	MoneyInputFrame_SetNextFocus(Hyperauction_BuyoutPrice, Hyperauction_AuctionsStackSizeEntry);

	Hyperauction_BrowseFilterScrollFrame.ScrollBar.scrollStep = HYPERAUCTION_BROWSE_FILTER_HEIGHT;

	-- Init search dot count
	Hyperauction_AuctionFrameBrowse.dotCount = 0;
	Hyperauction_AuctionFrameBrowse.isSearchingThrottle = 0;

	Hyperauction_AuctionFrameBrowse.page = 0;
	FauxScrollFrame_SetOffset(Hyperauction_BrowseScrollFrame, 0);

	Hyperauction_AuctionFrameBid.page = 0;
	FauxScrollFrame_SetOffset(Hyperauction_BidScrollFrame, 0);
	GetBidderAuctionItems(Hyperauction_AuctionFrameBid.page);

	Hyperauction_AuctionFrameAuctions.page = 0;
	FauxScrollFrame_SetOffset(Hyperauction_AuctionsScrollFrame, 0);
	GetOwnerAuctionItems(Hyperauction_AuctionFrameAuctions.page);

	MoneyFrame_SetMaxDisplayWidth(Hyperauction_AuctionFrameMoneyFrame, 160);

	self:RegisterEvent("AUCTION_HOUSE_SHOW");
	self:RegisterEvent("AUCTION_HOUSE_CLOSED");
end

function Hyperauction_AuctionFrame_Show()
	-- if (IsKioskModeEnabled()) then
	-- 	UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1.0, 0.1, 0.1, 1.0);
	-- 	CloseAuctionHouse();
	-- 	HideUIPanel(Hyperauction_AuctionFrame);
	-- 	return;
	-- end

	if (Hyperauction_AuctionFrame:IsShown()) then
		Hyperauction_AuctionFrameBrowse_Update();
		Hyperauction_AuctionFrameBid_Update();
		Hyperauction_AuctionFrameAuctions_Update();
	else
		Hyperauction_AuctionFrame:Show();

		Hyperauction_AuctionFrameBrowse.page = 0;
		FauxScrollFrame_SetOffset(Hyperauction_BrowseScrollFrame, 0);

		Hyperauction_AuctionFrameBid.page = 0;
		FauxScrollFrame_SetOffset(Hyperauction_BidScrollFrame, 0);
		GetBidderAuctionItems(Hyperauction_AuctionFrameBid.page);

		Hyperauction_AuctionFrameAuctions.page = 0;
		FauxScrollFrame_SetOffset(Hyperauction_AuctionsScrollFrame, 0);
		GetOwnerAuctionItems(Hyperauction_AuctionFrameAuctions.page)

		Hyperauction_BrowsePrevPageButton.isEnabled = false;
		Hyperauction_BrowseNextPageButton.isEnabled = false;

		if (not Hyperauction_AuctionFrame:IsShown()) then
			CloseAuctionHouse();
		end
	end
end

function Hyperauction_AuctionFrame_Hide()
	Hyperauction_AuctionFrame:Hide();
end

function Hyperauction_AuctionFrame_OnShow(self)
	self.gotAuctions = nil;
	self.gotBids = nil;
	Hyperauction_AuctionFrameTab_OnClick(Hyperauction_AuctionFrameTab1);
	SetPortraitTexture(Hyperauction_AuctionPortraitTexture, "npc");
	Hyperauction_BrowseNoResultsText:SetText(BROWSE_SEARCH_TEXT);
	PlaySound(SOUNDKIT.AUCTION_WINDOW_OPEN);

	SetUpSideDressUpFrame(self, 840, 1020, "TOPLEFT", "TOPRIGHT", -2, -28);
end

function Hyperauction_AuctionFrame_OnEvent(self, event)
	if (event == "AUCTION_HOUSE_SHOW") then
		-- AuctionFrame:Hide();
		Hyperauction_AuctionFrame_Show();
	elseif (event == "AUCTION_HOUSE_CLOSED") then
		Hyperauction_AuctionFrame_Hide();
	end
end

function Hyperauction_AuctionFrameTab_OnClick(self, button, down, index)
	local index = self:GetID();
	PanelTemplates_SetTab(Hyperauction_AuctionFrame, index);
	Hyperauction_AuctionFrameAuctions:Hide();
	Hyperauction_AuctionFrameBrowse:Hide();
	Hyperauction_AuctionFrameBid:Hide();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
	if (index == 1) then
		-- Browse tab
		Hyperauction_AuctionFrameTopLeft:SetTexture(
			"Interface\\AuctionFrame\\UI-AuctionFrame-Browse-TopLeft");
		Hyperauction_AuctionFrameTop:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-Top");
		Hyperauction_AuctionFrameTopRight:SetTexture(
			"Interface\\AuctionFrame\\UI-AuctionFrame-Browse-TopRight");
		Hyperauction_AuctionFrameBotLeft:SetTexture(
			"Interface\\AuctionFrame\\UI-AuctionFrame-Browse-BotLeft");
		Hyperauction_AuctionFrameBot:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-Bot");
		Hyperauction_AuctionFrameBotRight:SetTexture(
			"Interface\\AuctionFrame\\UI-AuctionFrame-Bid-BotRight");
		Hyperauction_AuctionFrameBrowse:Show();
		Hyperauction_AuctionFrame.type = "list";
		SetAuctionsTabShowing(false);
	elseif (index == 2) then
		-- Bids tab
		Hyperauction_AuctionFrameTopLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-TopLeft");
		Hyperauction_AuctionFrameTop:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-Top");
		Hyperauction_AuctionFrameTopRight:SetTexture(
			"Interface\\AuctionFrame\\UI-AuctionFrame-Auction-TopRight");
		Hyperauction_AuctionFrameBotLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-BotLeft");
		Hyperauction_AuctionFrameBot:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-Bot");
		Hyperauction_AuctionFrameBotRight:SetTexture(
			"Interface\\AuctionFrame\\UI-AuctionFrame-Bid-BotRight");
		Hyperauction_AuctionFrameBid:Show();
		Hyperauction_AuctionFrame.type = "bidder";
		SetAuctionsTabShowing(false);
	elseif (index == 3) then
		-- Auctions tab
		Hyperauction_AuctionFrameTopLeft:SetTexture(
			"Interface\\AuctionFrame\\UI-AuctionFrame-Auction-TopLeft");
		Hyperauction_AuctionFrameTop:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-Top");
		Hyperauction_AuctionFrameTopRight:SetTexture(
			"Interface\\AuctionFrame\\UI-AuctionFrame-Auction-TopRight");
		Hyperauction_AuctionFrameBotLeft:SetTexture(
			"Interface\\AuctionFrame\\UI-AuctionFrame-Auction-BotLeft");
		Hyperauction_AuctionFrameBot:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-Bot");
		Hyperauction_AuctionFrameBotRight:SetTexture(
			"Interface\\AuctionFrame\\UI-AuctionFrame-Auction-BotRight");
		Hyperauction_AuctionFrameAuctions:Show();
		SetAuctionsTabShowing(true);
	end
end

-- Browse tab functions

function Hyperauction_AuctionFrameBrowse_OnLoad(self)
	self:RegisterEvent("AUCTION_ITEM_LIST_UPDATE");

	-- set default sort
	Hyperauction_AuctionFrame_SetSort("list", "quality", false);
end

function Hyperauction_AuctionFrameBrowse_OnShow()
	Hyperauction_AuctionFrameBrowse_Update();
	Hyperauction_AuctionFrameFilters_Update();
end

function Hyperauction_AuctionFrameBrowse_UpdateArrows()
	Hyperauction_SortButton_UpdateArrow(Hyperauction_BrowseQualitySort, "list", "quality");
	Hyperauction_SortButton_UpdateArrow(Hyperauction_BrowseLevelSort, "list", "level");
	Hyperauction_SortButton_UpdateArrow(Hyperauction_BrowseDurationSort, "list", "duration");
	Hyperauction_SortButton_UpdateArrow(Hyperauction_BrowseHighBidderSort, "list", "seller");
	Hyperauction_SortButton_UpdateArrow(Hyperauction_BrowseCurrentBidSort, "list", "unitprice");
end

function Hyperauction_AuctionFrameBrowse_OnEvent(self, event, ...)
	if (event == "AUCTION_ITEM_LIST_UPDATE") then
		print("Hyperauction:", event);
		Hyperauction_AuctionFrameBrowse_Update();
		-- Stop "searching" messaging
		Hyperauction_AuctionFrameBrowse.isSearching = nil;
		Hyperauction_BrowseNoResultsText:SetText(BROWSE_NO_RESULTS);
		-- update arrows now that we're not searching
		Hyperauction_AuctionFrameBrowse_UpdateArrows();
	end
end

function Hyperauction_BrowseButton_OnClick(button)
	assert(button);

	if (GetCVarBool("auctionDisplayOnCharacter")) then
		if (not DressUpItemLink(GetAuctionItemLink("list", button:GetID() + FauxScrollFrame_GetOffset(Hyperauction_BrowseScrollFrame)))) then
			DressUpBattlePet(GetAuctionItemBattlePetInfo("list",
				button:GetID() + FauxScrollFrame_GetOffset(Hyperauction_BrowseScrollFrame)));
		end
	end
	SetSelectedAuctionItem("list", button:GetID() + FauxScrollFrame_GetOffset(Hyperauction_BrowseScrollFrame));
	-- Close any auction related popups
	Hyperauction_CloseAuctionStaticPopups();
	Hyperauction_AuctionFrameBrowse_Update();
end

function Hyperauction_BrowseDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, Hyperauction_BrowseDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(Hyperauction_BrowseDropDown, -1);
end

function Hyperauction_BrowseDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	info.text = ALL;
	info.value = -1;
	info.func = Hyperauction_BrowseDropDown_OnClick;
	UIDropDownMenu_AddButton(info);
	for i = 0, getn(ITEM_QUALITY_COLORS) - 2 do
		info.text = _G["ITEM_QUALITY" .. i .. "_DESC"];
		info.value = i;
		info.func = Hyperauction_BrowseDropDown_OnClick;
		info.checked = nil;
		UIDropDownMenu_AddButton(info);
	end
end

function Hyperauction_BrowseDropDown_OnClick(self)
	UIDropDownMenu_SetSelectedValue(Hyperauction_BrowseDropDown, self.value);
end

function Hyperauction_AuctionFrameBrowse_Reset(self)
	Hyperauction_BrowseName:SetText("");
	Hyperauction_BrowseMinLevel:SetText("");
	Hyperauction_BrowseMaxLevel:SetText("");
	Hyperauction_IsUsableCheckButton:SetChecked(false);
	Hyperauction_ExactMatchCheckButton:SetChecked(false);
	UIDropDownMenu_SetSelectedValue(Hyperauction_BrowseDropDown, -1);
	Hyperauction_BrowseNoResultsText:Show();
	Hyperauction_BrowseQualitySort:Show();
	Hyperauction_BrowseLevelSort:Show();
	Hyperauction_BrowseDurationSort:Show();
	Hyperauction_BrowseHighBidderSort:Show();
	Hyperauction_BrowseCurrentBidSort:Show();

	-- reset the filters
	HYPERAUCTION_OPEN_FILTER_LIST = {};
	Hyperauction_AuctionFrameBrowse.selectedCategoryIndex = nil;
	Hyperauction_AuctionFrameBrowse.selectedSubCategoryIndex = nil;
	Hyperauction_AuctionFrameBrowse.selectedSubSubCategoryIndex = nil;

	Hyperauction_BrowseLevelSort:SetText(Hyperauction_AuctionFrame_GetDetailColumnString(
		Hyperauction_AuctionFrameBrowse.selectedCategoryIndex,
		Hyperauction_AuctionFrameBrowse.selectedSubCategoryIndex));
	Hyperauction_AuctionFrameFilters_Update()
	Hyperauction_BrowseWowTokenResults_Update();
	self:Disable();
end

function Hyperauction_BrowseResetButton_OnUpdate(self, elapsed)
	if ((Hyperauction_BrowseName:GetText() == "") and (Hyperauction_BrowseMinLevel:GetText() == "") and (Hyperauction_BrowseMaxLevel:GetText() == "") and
			(not Hyperauction_IsUsableCheckButton:GetChecked()) and (not Hyperauction_ExactMatchCheckButton:GetChecked()) and (UIDropDownMenu_GetSelectedValue(Hyperauction_BrowseDropDown) == -1) and
			(not Hyperauction_AuctionFrameBrowse.selectedCategoryIndex) and (not Hyperauction_AuctionFrameBrowse.selectedSubCategoryIndex) and (not Hyperauction_AuctionFrameBrowse.selectedSubSubCategoryIndex))
	then
		self:Disable();
	else
		self:Enable();
	end
end

function Hyperauction_AuctionFrame_SetSort(sortTable, sortColumn, oppositeOrder)
	-- clear the existing sort.
	SortAuctionClearSort(sortTable);

	-- set the columns
	for index, row in pairs(Hyperauction_AuctionSort[sortTable .. "_" .. sortColumn]) do
		if (oppositeOrder) then
			SortAuctionSetSort(sortTable, row.column, not row.reverse);
		else
			SortAuctionSetSort(sortTable, row.column, row.reverse);
		end
	end
end

function Hyperauction_AuctionFrame_OnClickSortColumn(sortTable, sortColumn)
	-- change the sort as appropriate
	local existingSortColumn, existingSortReverse = GetAuctionSort(sortTable, 1);
	local oppositeOrder = false;
	if (existingSortColumn and (existingSortColumn == sortColumn)) then
		oppositeOrder = not existingSortReverse;
	elseif (sortColumn == "level") then
		oppositeOrder = true;
	end

	-- set the new sort order
	Hyperauction_AuctionFrame_SetSort(sortTable, sortColumn, oppositeOrder);

	-- apply the sort
	if (sortTable == "list") then
		Hyperauction_AuctionFrameBrowse_Search();
	else
		SortAuctionApplySort(sortTable);
	end
end

local prevBrowseParams;
local function AuctionFrameBrowse_SearchHelper(...)
	local text, minLevel, maxLevel, categoryIndex, subCategoryIndex, subSubCategoryIndex, page, usable, rarity, exactMatch = ...;

	if (not prevBrowseParams) then
		-- if we are doing a search for the first time then create the browse param cache
		prevBrowseParams = {};
	else
		-- if we have already done a browse then see if any of the params have changed (except for the page number)
		local param;
		for i = 1, select('#', ...) do
			if (i ~= BROWSE_PARAM_INDEX_PAGE and select(i, ...) ~= prevBrowseParams[i]) then
				-- if we detect a change then we want to reset the page number back to the first page
				page = 0;
				Hyperauction_AuctionFrameBrowse.page = page;
				break;
			end
		end
	end

	local filterData;
	if categoryIndex and subCategoryIndex and subSubCategoryIndex then
		filterData = Hyperauction_AuctionCategories[categoryIndex].subCategories[subCategoryIndex].subCategories
			[subSubCategoryIndex]
			.filters;
	elseif categoryIndex and subCategoryIndex then
		filterData = Hyperauction_AuctionCategories[categoryIndex].subCategories[subCategoryIndex].filters;
	elseif categoryIndex then
		filterData = Hyperauction_AuctionCategories[categoryIndex].filters;
	else
		-- not filtering by category, leave nil for all
	end

	print("Hyperauction:", "QueryAuctionItems");

	QueryAuctionItems(text, minLevel, maxLevel, page, usable, rarity, false, exactMatch, filterData);

	-- store this query's params so we can compare them with the next set of params we get
	for i = 1, select('#', ...) do
		if (i == BROWSE_PARAM_INDEX_PAGE) then
			prevBrowseParams[i] = page;
		else
			prevBrowseParams[i] = select(i, ...);
		end
	end
end

function Hyperauction_AuctionFrameBrowse_Search()
	if (Hyperauction_AuctionFrame_DoesCategoryHaveFlag("WOW_TOKEN_FLAG", Hyperauction_AuctionFrameBrowse.selectedCategoryIndex)) then
		Hyperauction_AuctionWowToken_UpdateMarketPrice();
		Hyperauction_BrowseWowTokenResults_Update();
	else
		if (not Hyperauction_AuctionFrameBrowse.page) then
			Hyperauction_AuctionFrameBrowse.page = 0;
		end

		AuctionFrameBrowse_SearchHelper(Hyperauction_BrowseName:GetText(), Hyperauction_BrowseMinLevel:GetNumber(),
			Hyperauction_BrowseMaxLevel:GetNumber(),
			Hyperauction_AuctionFrameBrowse.selectedCategoryIndex,
			Hyperauction_AuctionFrameBrowse.selectedSubCategoryIndex,
			Hyperauction_AuctionFrameBrowse.selectedSubSubCategoryIndex, Hyperauction_AuctionFrameBrowse.page,
			Hyperauction_IsUsableCheckButton:GetChecked(),
			UIDropDownMenu_GetSelectedValue(Hyperauction_BrowseDropDown), Hyperauction_ExactMatchCheckButton:GetChecked());

		-- Start "searching" messaging
		Hyperauction_AuctionFrameBrowse.isSearching = 1;
	end
end

function Hyperauction_BrowseSearchButton_OnUpdate(self, elapsed)
	if (CanSendAuctionQuery("list")) then
		self:Enable();
		if (Hyperauction_BrowsePrevPageButton.isEnabled) then
			Hyperauction_BrowsePrevPageButton:Enable();
		else
			Hyperauction_BrowsePrevPageButton:Disable();
		end
		if (Hyperauction_BrowseNextPageButton.isEnabled) then
			Hyperauction_BrowseNextPageButton:Enable();
		else
			Hyperauction_BrowseNextPageButton:Disable();
		end
		Hyperauction_BrowseQualitySort:Enable();
		Hyperauction_BrowseLevelSort:Enable();
		Hyperauction_BrowseDurationSort:Enable();
		Hyperauction_BrowseHighBidderSort:Enable();
		Hyperauction_BrowseCurrentBidSort:Enable();
		Hyperauction_AuctionFrameBrowse_UpdateArrows();
	else
		self:Disable();
		Hyperauction_BrowsePrevPageButton:Disable();
		Hyperauction_BrowseNextPageButton:Disable();
		Hyperauction_BrowseQualitySort:Disable();
		Hyperauction_BrowseLevelSort:Disable();
		Hyperauction_BrowseDurationSort:Disable();
		Hyperauction_BrowseHighBidderSort:Disable();
		Hyperauction_BrowseCurrentBidSort:Disable();
	end
	if (Hyperauction_AuctionFrameBrowse.isSearching) then
		if (Hyperauction_AuctionFrameBrowse.isSearchingThrottle <= 0) then
			Hyperauction_AuctionFrameBrowse.dotCount = Hyperauction_AuctionFrameBrowse.dotCount + 1;
			if (Hyperauction_AuctionFrameBrowse.dotCount > 3) then
				Hyperauction_AuctionFrameBrowse.dotCount = 0
			end
			local dotString = "";
			for i = 1, Hyperauction_AuctionFrameBrowse.dotCount do
				dotString = dotString .. ".";
			end
			Hyperauction_BrowseSearchDotsText:Show();
			Hyperauction_BrowseSearchDotsText:SetText(dotString);
			Hyperauction_BrowseNoResultsText:SetText(SEARCHING_FOR_ITEMS);
			Hyperauction_AuctionFrameBrowse.isSearchingThrottle = 0.3;
		else
			Hyperauction_AuctionFrameBrowse.isSearchingThrottle = Hyperauction_AuctionFrameBrowse.isSearchingThrottle -
				elapsed;
		end
	else
		Hyperauction_BrowseSearchDotsText:Hide();
	end
end

function Hyperauction_AuctionFrameFilters_Update(forceSelectionIntoView)
	Hyperauction_AuctionFrameFilters_UpdateCategories(forceSelectionIntoView);
	-- Update scrollFrame
	FauxScrollFrame_Update(Hyperauction_BrowseFilterScrollFrame, #HYPERAUCTION_OPEN_FILTER_LIST,
		HYPERAUCTION_NUM_FILTERS_TO_DISPLAY,
		HYPERAUCTION_BROWSE_FILTER_HEIGHT);
end

function Hyperauction_AuctionFrameFilters_UpdateCategories(forceSelectionIntoView)
	-- Initialize the list of open filters
	HYPERAUCTION_OPEN_FILTER_LIST = {};

	for categoryIndex, categoryInfo in ipairs(Hyperauction_AuctionCategories) do
		local selected = Hyperauction_AuctionFrameBrowse.selectedCategoryIndex and
			Hyperauction_AuctionFrameBrowse.selectedCategoryIndex == categoryIndex;
		local isToken = categoryInfo:HasFlag("WOW_TOKEN_FLAG");

		tinsert(HYPERAUCTION_OPEN_FILTER_LIST,
			{
				name = categoryInfo.name,
				type = "category",
				categoryIndex = categoryIndex,
				selected = selected,
				isToken =
					isToken,
			});

		if (selected) then
			Hyperauction_AuctionFrameFilters_AddSubCategories(categoryInfo.subCategories);
		end
	end

	-- Display the list of open filters
	local offset = FauxScrollFrame_GetOffset(Hyperauction_BrowseFilterScrollFrame);
	if (forceSelectionIntoView and Hyperauction_AuctionFrameBrowse.selectedCategoryIndex and (not Hyperauction_AuctionFrameBrowse.selectedSubCategoryIndex and not Hyperauction_AuctionFrameBrowse.selectedSubSubCategoryIndex)) then
		if (Hyperauction_AuctionFrameBrowse.selectedCategoryIndex <= offset) then
			FauxScrollFrame_OnVerticalScroll(Hyperauction_BrowseFilterScrollFrame,
				math.max(0.0,
					(Hyperauction_AuctionFrameBrowse.selectedCategoryIndex - 1) * HYPERAUCTION_BROWSE_FILTER_HEIGHT),
				HYPERAUCTION_BROWSE_FILTER_HEIGHT);
			offset = FauxScrollFrame_GetOffset(Hyperauction_BrowseFilterScrollFrame);
		end
	end

	local dataIndex = offset;

	local hasScrollBar = #HYPERAUCTION_OPEN_FILTER_LIST > HYPERAUCTION_NUM_FILTERS_TO_DISPLAY;
	for i = 1, HYPERAUCTION_NUM_FILTERS_TO_DISPLAY do
		local button = Hyperauction_AuctionFrameBrowse.FilterButtons[i];
		button:SetWidth(hasScrollBar and 136 or 156);

		dataIndex = dataIndex + 1;

		if (dataIndex <= #HYPERAUCTION_OPEN_FILTER_LIST) then
			local info = HYPERAUCTION_OPEN_FILTER_LIST[dataIndex];

			if (info) then
				Hyperauction_FilterButton_SetUp(button, info);

				if (info.type == "category") then
					button.categoryIndex = info.categoryIndex;
				elseif (info.type == "subCategory") then
					button.subCategoryIndex = info.subCategoryIndex;
				elseif (info.type == "subSubCategory") then
					button.subSubCategoryIndex = info.subSubCategoryIndex;
				end

				if (info.selected) then
					button:LockHighlight();
				else
					button:UnlockHighlight();
				end
				button:Show();
			end
		else
			button:Hide();
		end
	end
end

function Hyperauction_AuctionFrameFilters_AddSubCategories(subCategories)
	if subCategories then
		for subCategoryIndex, subCategoryInfo in ipairs(subCategories) do
			local selected = Hyperauction_AuctionFrameBrowse.selectedSubCategoryIndex and
				Hyperauction_AuctionFrameBrowse.selectedSubCategoryIndex == subCategoryIndex;

			tinsert(HYPERAUCTION_OPEN_FILTER_LIST,
				{
					name = subCategoryInfo.name,
					type = "subCategory",
					subCategoryIndex = subCategoryIndex,
					selected =
						selected
				});

			if (selected) then
				Hyperauction_AuctionFrameFilters_AddSubSubCategories(subCategoryInfo.subCategories);
			end
		end
	end
end

function Hyperauction_AuctionFrameFilters_AddSubSubCategories(subSubCategories)
	if subSubCategories then
		for subSubCategoryIndex, subSubCategoryInfo in ipairs(subSubCategories) do
			local selected = Hyperauction_AuctionFrameBrowse.selectedSubSubCategoryIndex and
				Hyperauction_AuctionFrameBrowse.selectedSubSubCategoryIndex == subSubCategoryIndex;
			local isLast = subSubCategoryIndex == #subSubCategories;

			tinsert(HYPERAUCTION_OPEN_FILTER_LIST,
				{
					name = subSubCategoryInfo.name,
					type = "subSubCategory",
					subSubCategoryIndex = subSubCategoryIndex,
					selected =
						selected,
					isLast = isLast
				});
		end
	end
end

function Hyperauction_FilterButton_SetUp(button, info)
	local normalText = _G[button:GetName() .. "NormalText"];
	local normalTexture = _G[button:GetName() .. "NormalTexture"];
	local line = _G[button:GetName() .. "Lines"];
	local tex = button:GetNormalTexture();

	if (info.isToken) then
		tex:SetTexCoord(0, 1, 0, 1);
		tex:SetAtlas("token-button-category");
	else
		tex:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-FilterBg");
		tex:SetTexCoord(0, 0.53125, 0, 0.625);
	end

	if (info.type == "category") then
		button:SetNormalFontObject(GameFontNormalSmallLeft);
		button:SetText(info.name);
		normalText:SetPoint("LEFT", button, "LEFT", 4, 0);
		normalTexture:SetAlpha(1.0);
		line:Hide();
	elseif (info.type == "subCategory") then
		button:SetNormalFontObject(GameFontHighlightSmallLeft);
		button:SetText(info.name);
		normalText:SetPoint("LEFT", button, "LEFT", 12, 0);
		normalTexture:SetAlpha(0.4);
		line:Hide();
	elseif (info.type == "subSubCategory") then
		button:SetNormalFontObject(GameFontHighlightSmallLeft);
		button:SetText(info.name);
		normalText:SetPoint("LEFT", button, "LEFT", 20, 0);
		normalTexture:SetAlpha(0.0);

		if (info.isLast) then
			line:SetTexCoord(0.4375, 0.875, 0, 0.625);
		else
			line:SetTexCoord(0, 0.4375, 0, 0.625);
		end
		line:Show();
	end
	button.type = info.type;
end

function Hyperauction_AuctionFrameFilter_OnClick(self, button)
	if (self.type == "category") then
		local wasToken = Hyperauction_AuctionFrame_DoesCategoryHaveFlag("WOW_TOKEN_FLAG",
			Hyperauction_AuctionFrameBrowse.selectedCategoryIndex);
		if (Hyperauction_AuctionFrameBrowse.selectedCategoryIndex == self.categoryIndex) then
			Hyperauction_AuctionFrameBrowse.selectedCategoryIndex = nil;
		else
			Hyperauction_AuctionFrameBrowse.selectedCategoryIndex = self.categoryIndex;
		end
		Hyperauction_AuctionFrameBrowse.selectedSubCategoryIndex = nil;
		Hyperauction_AuctionFrameBrowse.selectedSubSubCategoryIndex = nil;
		if (Hyperauction_AuctionFrame_DoesCategoryHaveFlag("WOW_TOKEN_FLAG", Hyperauction_AuctionFrameBrowse.selectedCategoryIndex)) then
			Hyperauction_AuctionWowToken_UpdateMarketPrice();
			Hyperauction_BrowseWowTokenResults_Update();
		else
			Hyperauction_BrowseBidButton:Show();
			Hyperauction_BrowseBuyoutButton:Show();
			Hyperauction_BrowseBidPrice:Show();
			Hyperauction_BrowseQualitySort:Show();
			Hyperauction_BrowseLevelSort:Show();
			Hyperauction_BrowseDurationSort:Show();
			Hyperauction_BrowseHighBidderSort:Show();
			Hyperauction_BrowseCurrentBidSort:Show();
			if (wasToken) then
				Hyperauction_BrowseNoResultsText:SetText(BROWSE_SEARCH_TEXT);
				Hyperauction_BrowseNoResultsText:Show();
			end
		end
	elseif (self.type == "subCategory") then
		if (Hyperauction_AuctionFrameBrowse.selectedSubCategoryIndex == self.subCategoryIndex) then
			Hyperauction_AuctionFrameBrowse.selectedSubCategoryIndex = nil;
			Hyperauction_AuctionFrameBrowse.selectedSubSubCategoryIndex = nil;
		else
			Hyperauction_AuctionFrameBrowse.selectedSubCategoryIndex = self.subCategoryIndex;
			Hyperauction_AuctionFrameBrowse.selectedSubSubCategoryIndex = nil;
		end
	elseif (self.type == "subSubCategory") then
		if (Hyperauction_AuctionFrameBrowse.selectedSubSubCategoryIndex == self.subSubCategoryIndex) then
			Hyperauction_AuctionFrameBrowse.selectedSubSubCategoryIndex = nil;
		else
			Hyperauction_AuctionFrameBrowse.selectedSubSubCategoryIndex = self.subSubCategoryIndex
		end
	end
	Hyperauction_BrowseLevelSort:SetText(Hyperauction_AuctionFrame_GetDetailColumnString(
		Hyperauction_AuctionFrameBrowse.selectedCategoryIndex,
		Hyperauction_AuctionFrameBrowse.selectedSubCategoryIndex));
	Hyperauction_BrowseWowTokenResults_Update();
	Hyperauction_AuctionFrameFilters_Update(true)
end

function Hyperauction_AuctionFrameBrowse_Update()
	if (not Hyperauction_AuctionFrame_DoesCategoryHaveFlag("WOW_TOKEN_FLAG", Hyperauction_AuctionFrameBrowse.selectedCategoryIndex)) then
		local numBatchAuctions, totalAuctions = GetNumAuctionItems("list");
		local button, buttonName, buttonHighlight, iconTexture, itemName, color, itemCount, moneyFrame, yourBidText, buyoutFrame, buyoutMoney;
		local offset = FauxScrollFrame_GetOffset(Hyperauction_BrowseScrollFrame);
		local index;
		local isLastSlotEmpty;
		local name, texture, count, quality, canUse, level, levelColHeader, minBid, minIncrement, buyoutPrice, duration, bidAmount, highBidder, bidderFullName, owner, ownerFullName, saleStatus, itemId, hasAllInfo;
		local displayedPrice, requiredBid;
		Hyperauction_BrowseBidButton:Show();
		Hyperauction_BrowseBuyoutButton:Show();
		Hyperauction_BrowseBidButton:Disable();
		Hyperauction_BrowseBuyoutButton:Disable();
		-- Update sort arrows
		Hyperauction_AuctionFrameBrowse_UpdateArrows();

		-- Show the no results text if no items found
		if (numBatchAuctions == 0) then
			Hyperauction_BrowseNoResultsText:Show();
		else
			Hyperauction_BrowseNoResultsText:Hide();
		end

		for i = 1, HYPERAUCTION_NUM_BROWSE_TO_DISPLAY do
			index = offset + i + (HYPERAUCTION_NUM_AUCTION_ITEMS_PER_PAGE * Hyperauction_AuctionFrameBrowse.page);
			button = _G["Hyperauction_BrowseButton" .. i];
			local shouldHide = index >
				(numBatchAuctions + (HYPERAUCTION_NUM_AUCTION_ITEMS_PER_PAGE * Hyperauction_AuctionFrameBrowse.page));
			if (not shouldHide) then
				name, texture, count, quality, canUse, level, levelColHeader, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, bidderFullName, owner, ownerFullName, saleStatus, itemId, hasAllInfo =
					GetAuctionItemInfo("list", offset + i);

				if (not hasAllInfo) then --Bug  145328
					shouldHide = true;
				end
			end

			-- Show or hide auction buttons
			if (shouldHide) then
				button:Hide();
				-- If the last button is empty then set isLastSlotEmpty var
				if (i == HYPERAUCTION_NUM_BROWSE_TO_DISPLAY) then
					isLastSlotEmpty = 1;
				end
			else
				button:Show();

				buttonName = "Hyperauction_BrowseButton" .. i;
				duration = GetAuctionItemTimeLeft("list", offset + i);

				-- Resize button if there isn't a scrollbar
				buttonHighlight = _G["Hyperauction_BrowseButton" .. i .. "Highlight"];
				if (numBatchAuctions < HYPERAUCTION_NUM_BROWSE_TO_DISPLAY) then
					button:SetWidth(625);
					buttonHighlight:SetWidth(589);
					Hyperauction_BrowseCurrentBidSort:SetWidth(207);
				elseif (numBatchAuctions == HYPERAUCTION_NUM_BROWSE_TO_DISPLAY and totalAuctions <= HYPERAUCTION_NUM_BROWSE_TO_DISPLAY) then
					button:SetWidth(625);
					buttonHighlight:SetWidth(589);
					Hyperauction_BrowseCurrentBidSort:SetWidth(207);
				else
					button:SetWidth(600);
					buttonHighlight:SetWidth(562);
					Hyperauction_BrowseCurrentBidSort:SetWidth(184);
				end
				-- Set name and quality color
				color = ITEM_QUALITY_COLORS[quality];
				itemName = _G[buttonName .. "Name"];
				itemName:SetText(name);
				itemName:SetVertexColor(color.r, color.g, color.b);
				local itemButton = _G[buttonName .. "Item"];

				-- SetItemButtonQuality(itemButton, quality, itemId);

				-- Set level
				if (levelColHeader == "REQ_LEVEL_ABBR" and level > UnitLevel("player")) then
					_G[buttonName .. "Level"]:SetText(RED_FONT_COLOR_CODE .. level .. FONT_COLOR_CODE_CLOSE);
				else
					_G[buttonName .. "Level"]:SetText(level);
				end
				-- Set closing time
				_G[buttonName .. "ClosingTimeText"]:SetText(Hyperauction_AuctionFrame_GetTimeLeftText(duration));
				_G[buttonName .. "ClosingTime"].tooltip = Hyperauction_AuctionFrame_GetTimeLeftTooltipText(duration);
				-- Set item texture, count, and usability
				iconTexture = _G[buttonName .. "ItemIconTexture"];
				iconTexture:SetTexture(texture);
				if (not canUse) then
					iconTexture:SetVertexColor(1.0, 0.1, 0.1);
				else
					iconTexture:SetVertexColor(1.0, 1.0, 1.0);
				end
				itemCount = _G[buttonName .. "ItemCount"];
				if (count > 1) then
					itemCount:SetText(count);
					itemCount:Show();
				else
					itemCount:Hide();
				end
				-- Set high bid
				moneyFrame = _G[buttonName .. "MoneyFrame"];
				-- If not bidAmount set the bid amount to the min bid
				if (bidAmount == 0) then
					displayedPrice = minBid;
					requiredBid = minBid;
				else
					displayedPrice = bidAmount;
					requiredBid = bidAmount + minIncrement;
				end
				MoneyFrame_Update(moneyFrame:GetName(), displayedPrice);

				yourBidText = _G[buttonName .. "YourBidText"];
				if (highBidder) then
					yourBidText:Show();
				else
					yourBidText:Hide();
				end

				if (requiredBid >= HYPERAUCTION_MAXIMUM_BID_PRICE) then
					-- Lie about our buyout price
					buyoutPrice = requiredBid;
				end
				buyoutFrame = _G[buttonName .. "BuyoutFrame"];
				if (buyoutPrice > 0) then
					moneyFrame:SetPoint("RIGHT", button, "RIGHT", 10, 10);
					buyoutMoney = _G[buyoutFrame:GetName() .. "Money"];
					MoneyFrame_Update(buyoutMoney, buyoutPrice);
					buyoutFrame:Show();
				else
					moneyFrame:SetPoint("RIGHT", button, "RIGHT", 10, 3);
					buyoutFrame:Hide();
				end
				-- Set high bidder
				--if ( not highBidder ) then
				--	highBidder = RED_FONT_COLOR_CODE..NO_BIDS..FONT_COLOR_CODE_CLOSE;
				--end
				local highBidderFrame = _G[buttonName .. "HighBidder"]
				highBidderFrame.fullName = ownerFullName;
				highBidderFrame.Name:SetText(owner);

				-- this is for comparing to the player name to see if they are the owner of this auction
				local ownerName;
				if (not ownerFullName) then
					ownerName = owner;
				else
					ownerName = ownerFullName
				end

				button.bidAmount = displayedPrice;
				button.buyoutPrice = buyoutPrice;
				button.itemCount = count;
				button.itemIndex = index;

				-- Set highlight
				if (GetSelectedAuctionItem("list") and (offset + i) == GetSelectedAuctionItem("list")) then
					button:LockHighlight();

					if (buyoutPrice > 0 and buyoutPrice >= minBid) then
						local canBuyout = 1;
						if (GetMoney() < buyoutPrice) then
							if (not highBidder or GetMoney() + bidAmount < buyoutPrice) then
								canBuyout = nil;
							end
						end
						if (canBuyout and (ownerName ~= UnitName("player"))) then
							Hyperauction_BrowseBuyoutButton:Enable();
							Hyperauction_AuctionFrame.buyoutPrice = buyoutPrice;
						end
					else
						Hyperauction_AuctionFrame.buyoutPrice = nil;
					end
					-- Set bid
					MoneyInputFrame_SetCopper(Hyperauction_BrowseBidPrice, requiredBid);

					if (not highBidder and ownerName ~= UnitName("player") and GetMoney() >= MoneyInputFrame_GetCopper(Hyperauction_BrowseBidPrice) and MoneyInputFrame_GetCopper(Hyperauction_BrowseBidPrice) <= HYPERAUCTION_MAXIMUM_BID_PRICE) then
						Hyperauction_BrowseBidButton:Enable();
					end
				else
					button:UnlockHighlight();
				end
			end
		end

		-- Update scrollFrame
		-- If more than one page of auctions show the next and prev arrows when the scrollframe is scrolled all the way down
		if (totalAuctions > HYPERAUCTION_NUM_AUCTION_ITEMS_PER_PAGE) then
			Hyperauction_BrowsePrevPageButton.isEnabled = (Hyperauction_AuctionFrameBrowse.page ~= 0);
			Hyperauction_BrowseNextPageButton.isEnabled = (Hyperauction_AuctionFrameBrowse.page ~= (ceil(totalAuctions / HYPERAUCTION_NUM_AUCTION_ITEMS_PER_PAGE) - 1));
			if (isLastSlotEmpty) then
				Hyperauction_BrowseSearchCountText:Show();
				local itemsMin = Hyperauction_AuctionFrameBrowse.page * HYPERAUCTION_NUM_AUCTION_ITEMS_PER_PAGE + 1;
				local itemsMax = itemsMin + numBatchAuctions - 1;
				Hyperauction_BrowseSearchCountText:SetFormattedText(NUMBER_OF_RESULTS_TEMPLATE, itemsMin, itemsMax,
					totalAuctions);
			else
				Hyperauction_BrowseSearchCountText:Hide();
			end

			-- Artifically inflate the number of results so the scrollbar scrolls one extra row
			numBatchAuctions = numBatchAuctions + 1;
		else
			Hyperauction_BrowsePrevPageButton.isEnabled = false;
			Hyperauction_BrowseNextPageButton.isEnabled = false;
			Hyperauction_BrowseSearchCountText:Hide();
		end
		FauxScrollFrame_Update(Hyperauction_BrowseScrollFrame, numBatchAuctions, HYPERAUCTION_NUM_BROWSE_TO_DISPLAY,
			HYPERAUCTION_AUCTIONS_BUTTON_HEIGHT);
	end
end

function Hyperauction_BrowseWowTokenResults_OnLoad(self)
	self:RegisterEvent("TOKEN_MARKET_PRICE_UPDATED");
	self:RegisterEvent("TOKEN_STATUS_CHANGED");
	self:RegisterEvent("TOKEN_BUY_RESULT");
	self:RegisterEvent("PLAYER_MONEY");
end

function Hyperauction_BrowseWowTokenResults_OnShow(self)
	Hyperauction_AuctionWowToken_UpdateMarketPrice();
	Hyperauction_BrowseWowTokenResults_Update();
end

function Hyperauction_BrowseWowTokenResults_OnUpdate(self, elapsed)
	local now = GetTime();

	local remaining = 60 - (now - self.timeStarted);
	if (remaining < 1) then
		GameTooltip:Hide();
		self:SetScript("OnUpdate", nil);
		self.noneForSale = false;
		self.timeStarted = nil;
		self.Buyout.tooltip = nil;
	else
		self.Buyout.tooltip = TOKEN_TRY_AGAIN_LATER:format(INT_SPELL_DURATION_SEC:format(math.floor(remaining)));
		if (GameTooltip:GetOwner() == self.Buyout) then
			GameTooltip:SetText(self.Buyout.tooltip);
		end
	end
	Hyperauction_BrowseWowTokenResults_Update();
end

function Hyperauction_BrowseWowTokenResults_OnEvent(self, event, ...)
	if (event == "TOKEN_MARKET_PRICE_UPDATED") then
		local result = ...;
		if (result == LE_TOKEN_RESULT_ERROR_DISABLED) then
			self.disabled = true;
		end
		Hyperauction_BrowseWowTokenResults_Update();
	elseif (event == "TOKEN_STATUS_CHANGED") then
		self.disabled = not C_WowTokenPublic.GetCommerceSystemStatus();
		Hyperauction_AuctionWowToken_UpdateMarketPrice();
	elseif (event == "TOKEN_BUY_RESULT") then
		local result = ...;
		if (result == LE_TOKEN_RESULT_ERROR_DISABLED) then
			self.disabled = true;
		elseif (result == LE_TOKEN_RESULT_ERROR_NONE_FOR_SALE) then
			self.noneForSale = true;
			StaticPopup_Show("HYPERAUCTION_TOKEN_NONE_FOR_SALE");
			self.timeStarted = GetTime();
			self:SetScript("OnUpdate", Hyperauction_BrowseWowTokenResults_OnUpdate);
		elseif (result == LE_TOKEN_RESULT_ERROR_AUCTIONABLE_TOKEN_OWNED) then
			StaticPopup_Show("HYPERAUCTION_TOKEN_AUCTIONABLE_TOKEN_OWNED");
		elseif (result == LE_TOKEN_RESULT_ERROR_TOO_MANY_TOKENS) then
			UIErrorsFrame:AddMessage(SPELL_FAILED_TOO_MANY_OF_ITEM, 1.0, 0.1, 0.1, 1.0);
		elseif (result == LE_TOKEN_RESULT_ERROR_TRIAL_RESTRICTED) then
			UIErrorsFrame:AddMessage(ERR_RESTRICTED_ACCOUNT_TRIAL, 1.0, 0.1, 0.1, 1.0);
		elseif (result ~= LE_TOKEN_RESULT_SUCCESS) then
			UIErrorsFrame:AddMessage(ERR_AUCTION_DATABASE_ERROR, 1.0, 0.1, 0.1, 1.0);
		else
			local info = ChatTypeInfo["SYSTEM"];
			local itemName = GetItemInfo(WOW_TOKEN_ITEM_ID);
			DEFAULT_CHAT_FRAME:AddMessage(ERR_AUCTION_WON_S:format(itemName), info.r, info.g, info.b, info.id);
			C_WowTokenPublic.UpdateTokenCount();
		end
	elseif (event == "PLAYER_MONEY") then
		Hyperauction_BrowseWowTokenResults_Update();
	elseif (event == "GET_ITEM_INFO_RECEIVED") then
		local itemID = ...;
		if (itemID == WOW_TOKEN_ITEM_ID) then
			Hyperauction_BrowseWowTokenResults_Update();
			self:UnregisterEvent("GET_ITEM_INFO_RECEIVED");
		end
	end
end

function Hyperauction_BrowseWowTokenResults_Update()
	if (Hyperauction_AuctionFrame_DoesCategoryHaveFlag("WOW_TOKEN_FLAG", Hyperauction_AuctionFrameBrowse.selectedCategoryIndex)) then
		if (not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_GAME_TIME_AUCTION_HOUSE) and C_WowTokenPublic.GetCommerceSystemStatus()) then
			Hyperauction_WowTokenGameTimeTutorial:Show();
			SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_GAME_TIME_AUCTION_HOUSE, true);
		end
		Hyperauction_BrowseWowTokenResults:Show();
		Hyperauction_BrowseBidButton:Hide();
		Hyperauction_BrowseBuyoutButton:Hide();
		Hyperauction_BrowseBidPrice:Hide();
		for i = 1, HYPERAUCTION_NUM_BROWSE_TO_DISPLAY do
			local button = _G["Hyperauction_BrowseButton" .. i];
			button:Hide();
		end
		Hyperauction_BrowseNoResultsText:Hide();
		Hyperauction_BrowseQualitySort:Hide();
		Hyperauction_BrowseLevelSort:Hide();
		Hyperauction_BrowseDurationSort:Hide();
		Hyperauction_BrowseHighBidderSort:Hide();
		Hyperauction_BrowseCurrentBidSort:Hide();
		Hyperauction_BrowseSearchCountText:Hide();
		Hyperauction_BrowsePrevPageButton.isEnabled = false;
		Hyperauction_BrowsePrevPageButton:Disable();
		Hyperauction_BrowseNextPageButton.isEnabled = false;
		Hyperauction_BrowseNextPageButton:Disable();
		FauxScrollFrame_Update(Hyperauction_BrowseScrollFrame, 0, HYPERAUCTION_NUM_BROWSE_TO_DISPLAY,
			HYPERAUCTION_AUCTIONS_BUTTON_HEIGHT);
		local marketPrice;
		if (WowToken_IsWowTokenAuctionDialogShown()) then
			marketPrice = C_WowTokenPublic.GetGuaranteedPrice();
		else
			marketPrice = C_WowTokenPublic.GetCurrentMarketPrice();
		end
		Hyperauction_BrowseWowTokenResults:Show();
		local itemName, _, itemQuality, _, _, _, _, _, _, itemTexture = GetItemInfo(WOW_TOKEN_ITEM_ID);
		if (itemName) then
			Hyperauction_BrowseWowTokenResults.Token.Icon:SetTexture(itemTexture)
			Hyperauction_BrowseWowTokenResults.Token.Name:SetText(itemName);
			Hyperauction_BrowseWowTokenResults.Token.Name:SetTextColor(ITEM_QUALITY_COLORS[itemQuality].r,
				ITEM_QUALITY_COLORS[itemQuality].g, ITEM_QUALITY_COLORS[itemQuality].b);
			if (Hyperauction_BrowseWowTokenResults.disabled) then
				Hyperauction_BrowseWowTokenResults.Hyperauction_BuyoutPrice:SetText(TOKEN_AUCTIONS_UNAVAILABLE);
				Hyperauction_BrowseWowTokenResults.Buyout:SetEnabled(false);
			elseif (not marketPrice) then
				Hyperauction_BrowseWowTokenResults.Hyperauction_BuyoutPrice:SetText(TOKEN_MARKET_PRICE_NOT_AVAILABLE);
				Hyperauction_BrowseWowTokenResults.Buyout:SetEnabled(false);
			elseif (Hyperauction_BrowseWowTokenResults.noneForSale) then
				Hyperauction_BrowseWowTokenResults.Hyperauction_BuyoutPrice:SetText(GetMoneyString(marketPrice, true));
				Hyperauction_BrowseWowTokenResults.Buyout:SetEnabled(false);
			else
				Hyperauction_BrowseWowTokenResults.Hyperauction_BuyoutPrice:SetText(GetMoneyString(marketPrice, true));
				if (GetMoney() < marketPrice) then
					Hyperauction_BrowseWowTokenResults.Buyout:SetEnabled(false);
					Hyperauction_BrowseWowTokenResults.Buyout.tooltip = ERR_NOT_ENOUGH_GOLD;
				else
					Hyperauction_BrowseWowTokenResults.Buyout:SetEnabled(true);
					Hyperauction_BrowseWowTokenResults.Buyout.tooltip = nil;
				end
			end
		else
			Hyperauction_BrowseWowTokenResults:RegisterEvent("GET_ITEM_INFO_RECEIVED");
		end
	else
		Hyperauction_BrowseWowTokenResults:Hide();
	end
end

function Hyperauction_BrowseWowTokenResultsBuyout_OnClick(self)
	C_WowTokenPublic.BuyToken();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function Hyperauction_BrowseWowTokenResultsBuyout_OnEnter(self)
	if (self.tooltip) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(self.tooltip);
		GameTooltip:Show();
	end
end

-- Bid tab functions

function Hyperauction_AuctionFrameBid_OnLoad(self)
	self:RegisterEvent("AUCTION_BIDDER_LIST_UPDATE");

	-- set default sort
	Hyperauction_AuctionFrame_SetSort("bidder", "duration", false);
end

function Hyperauction_AuctionFrameBid_OnEvent(self, event, ...)
	if (event == "AUCTION_BIDDER_LIST_UPDATE") then
		Hyperauction_AuctionFrameBid_Update();
	end
end

function Hyperauction_AuctionFrameBid_OnShow()
	-- So the get auctions query is only run once per session, after that you only get updates
	if (not Hyperauction_AuctionFrame.gotBids) then
		GetBidderAuctionItems();
		Hyperauction_AuctionFrame.gotBids = 1;
	end
	Hyperauction_AuctionFrameBid_Update();
end

function Hyperauction_AuctionFrameBid_Update()
	local numBatchAuctions, totalAuctions = GetNumAuctionItems("bidder");
	local button, buttonName, buttonHighlight, iconTexture, itemName, color, itemCount;
	local offset = FauxScrollFrame_GetOffset(Hyperauction_BidScrollFrame);
	local index;
	local isLastSlotEmpty;
	local name, texture, count, quality, canUse, level, levelColHeader, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, bidderFullName, owner, ownerFullName, itemID;
	local duration;
	Hyperauction_BidBidButton:Disable();
	Hyperauction_BidBuyoutButton:Disable();
	-- Update sort arrows
	Hyperauction_SortButton_UpdateArrow(Hyperauction_BidQualitySort, "bidder", "quality");
	Hyperauction_SortButton_UpdateArrow(Hyperauction_BidLevelSort, "bidder", "level");
	Hyperauction_SortButton_UpdateArrow(Hyperauction_BidDurationSort, "bidder", "duration");
	Hyperauction_SortButton_UpdateArrow(Hyperauction_BidBuyoutSort, "bidder", "buyout");
	Hyperauction_SortButton_UpdateArrow(Hyperauction_BidStatusSort, "bidder", "status");
	Hyperauction_SortButton_UpdateArrow(Hyperauction_BidBidSort, "bidder", "bid");

	for i = 1, HYPERAUCTION_NUM_BIDS_TO_DISPLAY do
		index = offset + i;
		button = _G["Hyperauction_BidButton" .. i];
		-- Show or hide auction buttons
		if (index > numBatchAuctions) then
			button:Hide();
			-- If the last button is empty then set isLastSlotEmpty var
			isLastSlotEmpty = (i == HYPERAUCTION_NUM_BIDS_TO_DISPLAY);
		else
			button:Show();
			buttonName = "Hyperauction_BidButton" .. i;
			name, texture, count, quality, canUse, level, levelColHeader, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, bidderFullName, owner, ownerFullName, _, itemID =
				GetAuctionItemInfo("bidder", index);
			duration = GetAuctionItemTimeLeft("bidder", offset + i);

			-- Resize button if there isn't a scrollbar
			buttonHighlight = _G["Hyperauction_BidButton" .. i .. "Highlight"];
			if (numBatchAuctions < HYPERAUCTION_NUM_BIDS_TO_DISPLAY) then
				button:SetWidth(793);
				buttonHighlight:SetWidth(758);
				Hyperauction_BidBidSort:SetWidth(169);
			elseif (numBatchAuctions == HYPERAUCTION_NUM_BIDS_TO_DISPLAY and totalAuctions <= HYPERAUCTION_NUM_BIDS_TO_DISPLAY) then
				button:SetWidth(793);
				buttonHighlight:SetWidth(758);
				Hyperauction_BidBidSort:SetWidth(169);
			else
				button:SetWidth(769);
				buttonHighlight:SetWidth(735);
				Hyperauction_BidBidSort:SetWidth(145);
			end
			-- Set name and quality color
			color = ITEM_QUALITY_COLORS[quality];
			itemName = _G[buttonName .. "Name"];
			itemName:SetText(name);
			itemName:SetVertexColor(color.r, color.g, color.b);

			local itemButton = _G[buttonName .. "Item"];

			-- SetItemButtonQuality(itemButton, quality, itemID);

			-- Set level
			if (levelColHeader == "REQ_LEVEL_ABBR" and level > UnitLevel("player")) then
				_G[buttonName .. "Level"]:SetText(RED_FONT_COLOR_CODE .. level .. FONT_COLOR_CODE_CLOSE);
			else
				_G[buttonName .. "Level"]:SetText(level);
			end
			-- Set bid status
			if (highBidder) then
				_G[buttonName .. "BidStatus"]:SetText(GREEN_FONT_COLOR_CODE .. HIGH_BIDDER .. FONT_COLOR_CODE_CLOSE);
			else
				_G[buttonName .. "BidStatus"]:SetText(RED_FONT_COLOR_CODE .. OUTBID .. FONT_COLOR_CODE_CLOSE);
			end

			-- Set closing time
			_G[buttonName .. "ClosingTimeText"]:SetText(Hyperauction_AuctionFrame_GetTimeLeftText(duration));
			_G[buttonName .. "ClosingTime"].tooltip = Hyperauction_AuctionFrame_GetTimeLeftTooltipText(duration);
			-- Set item texture, count, and usability
			iconTexture = _G[buttonName .. "ItemIconTexture"];
			iconTexture:SetTexture(texture);
			if (not canUse) then
				iconTexture:SetVertexColor(1.0, 0.1, 0.1);
			else
				iconTexture:SetVertexColor(1.0, 1.0, 1.0);
			end
			itemCount = _G[buttonName .. "ItemCount"];
			if (count > 1) then
				itemCount:SetText(count);
				itemCount:Show();
			else
				itemCount:Hide();
			end

			-- Set current bid
			-- If not bidAmount set the bid amount to the min bid
			if (bidAmount == 0) then
				bidAmount = minBid;
			end
			MoneyFrame_Update(buttonName .. "CurrentBidMoneyFrame", bidAmount);
			-- Set buyout price
			MoneyFrame_Update(buttonName .. "BuyoutMoneyFrame", buyoutPrice);

			button.bidAmount = bidAmount;
			button.buyoutPrice = buyoutPrice;
			button.itemCount = count;

			-- Set highlight
			if (GetSelectedAuctionItem("bidder") and (offset + i) == GetSelectedAuctionItem("bidder")) then
				button:LockHighlight();

				if (buyoutPrice > 0 and buyoutPrice >= bidAmount) then
					local canBuyout = 1;
					if (GetMoney() < buyoutPrice) then
						if (not highBidder or GetMoney() + bidAmount < buyoutPrice) then
							canBuyout = nil;
						end
					end
					if (canBuyout) then
						Hyperauction_BidBuyoutButton:Enable();
						Hyperauction_AuctionFrame.buyoutPrice = buyoutPrice;
					end
				else
					Hyperauction_AuctionFrame.buyoutPrice = nil;
				end
				-- Set bid
				MoneyInputFrame_SetCopper(Hyperauction_BidBidPrice, bidAmount + minIncrement);

				if (not highBidder and GetMoney() >= MoneyInputFrame_GetCopper(Hyperauction_BidBidPrice)) then
					Hyperauction_BidBidButton:Enable();
				end
			else
				button:UnlockHighlight();
			end
		end
	end
	-- If more than one page of auctions show the next and prev arrows when the scrollframe is scrolled all the way down
	if (totalAuctions > HYPERAUCTION_NUM_AUCTION_ITEMS_PER_PAGE) then
		if (isLastSlotEmpty) then
			Hyperauction_BidSearchCountText:Show();
			Hyperauction_BidSearchCountText:SetFormattedText(SINGLE_PAGE_RESULTS_TEMPLATE, totalAuctions);
		else
			Hyperauction_BidSearchCountText:Hide();
		end

		-- Artifically inflate the number of results so the scrollbar scrolls one extra row
		numBatchAuctions = numBatchAuctions + 1;
	else
		Hyperauction_BidSearchCountText:Hide();
	end

	-- Update scrollFrame
	FauxScrollFrame_Update(Hyperauction_BidScrollFrame, numBatchAuctions, HYPERAUCTION_NUM_BIDS_TO_DISPLAY,
		HYPERAUCTION_AUCTIONS_BUTTON_HEIGHT);
end

function Hyperauction_BidButton_OnClick(button)
	assert(button)

	if (GetCVarBool("auctionDisplayOnCharacter")) then
		if (not DressUpItemLink(GetAuctionItemLink("bidder", button:GetID() + FauxScrollFrame_GetOffset(Hyperauction_BidScrollFrame)))) then
			DressUpBattlePet(GetAuctionItemBattlePetInfo("bidder",
				button:GetID() + FauxScrollFrame_GetOffset(Hyperauction_BidScrollFrame)));
		end
	end
	SetSelectedAuctionItem("bidder", button:GetID() + FauxScrollFrame_GetOffset(Hyperauction_BidScrollFrame));
	-- Close any auction related popups
	Hyperauction_CloseAuctionStaticPopups();
	Hyperauction_AuctionFrameBid_Update();
end

-- Auctions tab functions

function Hyperauction_AuctionFrameAuctions_OnLoad(self)
	self:RegisterEvent("AUCTION_OWNED_LIST_UPDATE");
	self:RegisterEvent("AUCTION_MULTISELL_START");
	self:RegisterEvent("AUCTION_MULTISELL_UPDATE");
	self:RegisterEvent("AUCTION_MULTISELL_FAILURE");
	self:RegisterEvent("TOKEN_DISTRIBUTIONS_UPDATED");
	-- set default sort
	Hyperauction_AuctionFrame_SetSort("owner", "duration", false);
end

function Hyperauction_AuctionFrameAuctions_OnEvent(self, event, ...)
	if (event == "AUCTION_OWNED_LIST_UPDATE" or event == "TOKEN_DISTRIBUTIONS_UPDATED") then
		Hyperauction_AuctionFrameAuctions_Update();
	elseif (event == "AUCTION_MULTISELL_START") then
		local arg1 = ...;
		Hyperauction_AuctionsCreateAuctionButton:Disable();
		MoneyInputFrame_ClearFocus(Hyperauction_StartPrice);
		MoneyInputFrame_ClearFocus(Hyperauction_BuyoutPrice);
		Hyperauction_AuctionsStackSizeEntry:ClearFocus();
		Hyperauction_AuctionsNumStacksEntry:ClearFocus();
		Hyperauction_AuctionsBlockFrame:Show();
		Hyperauction_AuctionProgressBar:SetMinMaxValues(0, arg1);
		Hyperauction_AuctionProgressBar:SetValue(0.01); -- "TEMPORARY"
		Hyperauction_AuctionProgressBar.Text:SetFormattedText(AUCTION_CREATING, 0, arg1);
		local _, iconTexture = GetAuctionSellItemInfo();
		Hyperauction_AuctionProgressBar.Icon:SetTexture(iconTexture);
		Hyperauction_AuctionProgressFrame:Show();
	elseif (event == "AUCTION_MULTISELL_UPDATE") then
		local arg1, arg2 = ...;
		Hyperauction_AuctionProgressBar:SetValue(arg1);
		Hyperauction_AuctionProgressBar.Text:SetFormattedText(AUCTION_CREATING, arg1, arg2);
		if (arg1 == arg2) then
			Hyperauction_AuctionsBlockFrame:Hide();
			Hyperauction_AuctionProgressFrame.fadeOut = true;
		end
	elseif (event == "AUCTION_MULTISELL_FAILURE") then
		Hyperauction_AuctionsBlockFrame:Hide();
		Hyperauction_AuctionProgressFrame:Hide();
	end
end

function Hyperauction_AuctionFrameAuctions_OnShow()
	Hyperauction_AuctionsTitle:SetFormattedText(AUCTION_TITLE, UnitName("player"));
	--MoneyFrame_Update("Hyperauction_AuctionsDepositMoneyFrame", 0);
	Hyperauction_AuctionsFrameAuctions_ValidateAuction();
	-- So the get auctions query is only run once per session, after that you only get updates
	if (not Hyperauction_AuctionFrame.gotAuctions) then
		GetOwnerAuctionItems();
		Hyperauction_AuctionFrame.gotAuctions = 1;
	end
	Hyperauction_AuctionFrameAuctions_Update();
end

local AUCTIONS_UPDATE_INTERVAL = 0.5;
function Hyperauction_AuctionFrameAuctions_OnUpdate(self, elapsed)
	self.timeSinceUpdate = (self.timeSinceUpdate or 0) + elapsed;
	if (self.timeSinceUpdate >= AUCTIONS_UPDATE_INTERVAL) then
		Hyperauction_AuctionFrameAuctions_Update();
		self.timeSinceUpdate = 0;
	end
end

do
	local selectedTokenOffset = 0;
	function Hyperauction_GetEffectiveSelectedOwnerAuctionItemIndex()
		return (GetSelectedAuctionItem("owner") or 0) + selectedTokenOffset;
	end

	function Hyperauction_SetEffectiveSelectedOwnerAuctionItemIndex(index)
		if index <= 0 then
			selectedTokenOffset = C_WowTokenPublic.GetNumListedAuctionableTokens() + index;
			SetSelectedAuctionItem("owner", 0);
		else
			selectedTokenOffset = C_WowTokenPublic.GetNumListedAuctionableTokens();
			SetSelectedAuctionItem("owner", index);
		end
	end

	function Hyperauction_IsSelectedOwnerAuctionItemIndexAToken()
		return selectedTokenOffset < C_WowTokenPublic.GetNumListedAuctionableTokens();
	end
end

function Hyperauction_AuctionFrameAuctions_Update()
	local numBatchAuctions, totalAuctions = GetNumAuctionItems("owner");
	local tokenCount = C_WowTokenPublic.GetNumListedAuctionableTokens();
	numBatchAuctions = numBatchAuctions + tokenCount;
	local offset = FauxScrollFrame_GetOffset(Hyperauction_AuctionsScrollFrame);
	local index;
	local isLastSlotEmpty;
	local auction, button, buttonName, buttonHighlight, iconTexture, itemName, color, itemCount, duration, timeToSell;
	local highBidderFrame;
	local closingTimeFrame, closingTimeText;
	local buttonBuyoutFrame, buttonBuyoutMoney;
	local bidAmountMoneyFrame, bidAmountMoneyFrameLabel;
	local name, texture, count, quality, canUse, level, levelColHeader, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, bidderFullName, owner, ownerFullName, saleStatus, itemID;
	local pendingDeliveries = false;

	-- Update sort arrows
	Hyperauction_SortButton_UpdateArrow(Hyperauction_AuctionsQualitySort, "owner", "quality");
	Hyperauction_SortButton_UpdateArrow(Hyperauction_AuctionsHighBidderSort, "owner", "status");
	Hyperauction_SortButton_UpdateArrow(Hyperauction_AuctionsDurationSort, "owner", "duration");
	Hyperauction_SortButton_UpdateArrow(Hyperauction_AuctionsBidSort, "owner", "bid");

	for i = 1, HYPERAUCTION_NUM_AUCTIONS_TO_DISPLAY do
		index = offset + i + (HYPERAUCTION_NUM_AUCTION_ITEMS_PER_PAGE * Hyperauction_AuctionFrameAuctions.page);
		auction = _G["Hyperauction_AuctionsButton" .. i];
		-- Show or hide auction buttons
		if (index > (numBatchAuctions + (HYPERAUCTION_NUM_AUCTION_ITEMS_PER_PAGE * Hyperauction_AuctionFrameAuctions.page))) then
			auction:Hide();
			-- If the last button is empty then set isLastSlotEmpty var
			isLastSlotEmpty = (i == HYPERAUCTION_NUM_AUCTIONS_TO_DISPLAY);
		else
			auction:Show();

			local isWowToken;

			if (index <= tokenCount) then
				itemID, buyoutPrice, duration = C_WowTokenPublic.GetListedAuctionableTokenInfo(index);
				count = 1;
				canUse = true;
				bidAmount = 0;
				name, _, quality, _, _, _, _, _, _, texture = GetItemInfo(itemID);
				isWowToken = true;
				if (not name) then
					Hyperauction_AuctionsWowTokenAuctionFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED");
				end
			else
				name, texture, count, quality, canUse, level, levelColHeader, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, bidderFullName, owner, ownerFullName, saleStatus, itemID =
					GetAuctionItemInfo("owner", (offset - tokenCount) + i);

				duration = GetAuctionItemTimeLeft("owner", (offset - tokenCount) + i);
			end

			buttonName = "Hyperauction_AuctionsButton" .. i;
			button = _G[buttonName];

			-- Resize button if there isn't a scrollbar
			buttonHighlight = _G[buttonName .. "Highlight"];
			if (numBatchAuctions < HYPERAUCTION_NUM_AUCTIONS_TO_DISPLAY) then
				auction:SetWidth(599);
				buttonHighlight:SetWidth(565);
				Hyperauction_AuctionsBidSort:SetWidth(213);
			elseif (numBatchAuctions == HYPERAUCTION_NUM_AUCTIONS_TO_DISPLAY and totalAuctions <= HYPERAUCTION_NUM_AUCTIONS_TO_DISPLAY) then
				auction:SetWidth(599);
				buttonHighlight:SetWidth(565);
				Hyperauction_AuctionsBidSort:SetWidth(213);
			else
				auction:SetWidth(576);
				buttonHighlight:SetWidth(543);
				Hyperauction_AuctionsBidSort:SetWidth(193);
			end

			-- Display differently based on the saleStatus
			-- saleStatus "1" means that the item was sold
			-- Set name and quality color
			color = ITEM_QUALITY_COLORS[quality];
			itemName = _G[buttonName .. "Name"];
			iconTexture = _G[buttonName .. "ItemIconTexture"];
			iconTexture:SetTexture(texture);
			highBidderFrame = _G[buttonName .. "HighBidder"];
			closingTimeFrame = _G[buttonName .. "ClosingTime"];
			closingTimeText = _G[buttonName .. "ClosingTimeText"];
			itemCount = _G[buttonName .. "ItemCount"];
			bidAmountMoneyFrame = _G[buttonName .. "MoneyFrame"];
			bidAmountMoneyFrameLabel = _G[buttonName .. "MoneyFrameLabel"];
			buttonBuyoutFrame = _G[buttonName .. "BuyoutFrame"];

			local itemButton = _G[buttonName .. "Item"];

			-- SetItemButtonQuality(itemButton, quality, itemID);

			if (saleStatus == 1) then
				-- Sold item
				pendingDeliveries = true;
				itemName:SetFormattedText(AUCTION_ITEM_SOLD, name);
				itemName:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);

				highBidderFrame.fullName = bidderFullName;
				if (highBidder) then
					highBidder = GREEN_FONT_COLOR_CODE .. highBidder .. FONT_COLOR_CODE_CLOSE;
					highBidderFrame.Name:SetText(highBidder);
				end

				closingTimeText:SetFormattedText(AUCTION_ITEM_TIME_UNTIL_DELIVERY, SecondsToTime(max(duration, 1)));
				closingTimeFrame.tooltip = closingTimeText:GetText();

				iconTexture:SetVertexColor(0.5, 0.5, 0.5);

				itemCount:Hide();
				button.itemCount = count;

				MoneyFrame_Update(buttonName .. "MoneyFrame", bidAmount);
				bidAmountMoneyFrame:SetAlpha(1);
				bidAmountMoneyFrame:SetPoint("RIGHT", button, "RIGHT", 10, -4);
				bidAmountMoneyFrameLabel:Show();

				buttonBuyoutFrame:Hide();
			else
				-- Normal item
				itemName:SetText(name);
				if (color) then
					itemName:SetVertexColor(color.r, color.g, color.b);
				end

				highBidderFrame.fullName = bidderFullName;
				if (isWowToken) then
					highBidder = DISABLED_FONT_COLOR_CODE .. NOT_APPLICABLE .. FONT_COLOR_CODE_CLOSE;
				elseif (not highBidder) then
					highBidder = RED_FONT_COLOR_CODE .. NO_BIDS .. FONT_COLOR_CODE_CLOSE;
				end
				highBidderFrame.Name:SetText(highBidder);

				closingTimeText:SetText(Hyperauction_AuctionFrame_GetTimeLeftText(duration));
				closingTimeFrame.tooltip = Hyperauction_AuctionFrame_GetTimeLeftTooltipText(duration, isWowToken);

				if (not canUse) then
					iconTexture:SetVertexColor(1.0, 0.1, 0.1);
				else
					iconTexture:SetVertexColor(1.0, 1.0, 1.0);
				end

				if (count > 1) then
					itemCount:SetText(count);
					itemCount:Show();
				else
					itemCount:Hide();
				end
				button.itemCount = count;

				if (not isWowToken) then
					bidAmountMoneyFrame:Show();
					bidAmountMoneyFrameLabel:Hide();
					if (bidAmount > 0) then
						-- Set high bid
						MoneyFrame_Update(buttonName .. "MoneyFrame", bidAmount);
						bidAmountMoneyFrame:SetAlpha(1);
						-- Set cancel price
						auction.cancelPrice = floor((bidAmount * HYPERAUCTION_AUCTION_CANCEL_COST) / 100);
						button.bidAmount = bidAmount;
					else
						-- No bids so show minBid and gray it out
						MoneyFrame_Update(buttonName .. "MoneyFrame", minBid);
						bidAmountMoneyFrame:SetAlpha(0.5);
						-- No cancel price
						auction.cancelPrice = 0;
						button.bidAmount = minBid;
					end
				else
					bidAmountMoneyFrame:Hide();
				end

				-- Set buyout price and adjust bid amount accordingly
				if (buyoutPrice > 0) then
					bidAmountMoneyFrame:SetPoint("RIGHT", buttonName, "RIGHT", 10, 10);
					buttonBuyoutMoney = _G[buttonName .. "BuyoutFrameMoney"];
					MoneyFrame_Update(buttonBuyoutMoney, buyoutPrice);
					buttonBuyoutFrame:Show();
				else
					bidAmountMoneyFrame:SetPoint("RIGHT", buttonName, "RIGHT", 10, 3);
					buttonBuyoutFrame:Hide();
				end
				button.buyoutPrice = buyoutPrice;
			end

			-- Set highlight
			if (Hyperauction_GetEffectiveSelectedOwnerAuctionItemIndex() == offset + i) then
				auction:LockHighlight();
			else
				auction:UnlockHighlight();
			end
		end
	end
	-- If more than one page of auctions show the next and prev arrows when the scrollframe is scrolled all the way down
	if (totalAuctions > HYPERAUCTION_NUM_AUCTION_ITEMS_PER_PAGE) then
		if (isLastSlotEmpty) then
			Hyperauction_AuctionsSearchCountText:Show();
			Hyperauction_AuctionsSearchCountText:SetFormattedText(SINGLE_PAGE_RESULTS_TEMPLATE, totalAuctions);
		else
			Hyperauction_AuctionsSearchCountText:Hide();
		end

		-- Artifically inflate the number of results so the scrollbar scrolls one extra row
		numBatchAuctions = numBatchAuctions + 1;
	else
		Hyperauction_AuctionsSearchCountText:Hide();
	end

	if (Hyperauction_GetEffectiveSelectedOwnerAuctionItemIndex() > 0 and not Hyperauction_IsSelectedOwnerAuctionItemIndexAToken() and CanCancelAuction(GetSelectedAuctionItem("owner"))) then
		Hyperauction_AuctionsCancelAuctionButton:Enable();
	else
		Hyperauction_AuctionsCancelAuctionButton:Disable();
	end

	if (pendingDeliveries) then
		Hyperauction_AuctionFrameAuctions:SetScript("OnUpdate", Hyperauction_AuctionFrameAuctions_OnUpdate);
	else
		Hyperauction_AuctionFrameAuctions:SetScript("OnUpdate", nil);
	end

	-- Update scrollFrame
	FauxScrollFrame_Update(Hyperauction_AuctionsScrollFrame, numBatchAuctions, HYPERAUCTION_NUM_AUCTIONS_TO_DISPLAY,
		HYPERAUCTION_AUCTIONS_BUTTON_HEIGHT);
end

function Hyperauction_GetEffectiveAuctionsScrollFrameOffset()
	return FauxScrollFrame_GetOffset(Hyperauction_AuctionsScrollFrame) - C_WowTokenPublic.GetNumListedAuctionableTokens();
end

function Hyperauction_AuctionsButton_OnClick(button)
	assert(button);
	local effectiveIndex = Hyperauction_GetEffectiveAuctionsScrollFrameOffset();
	if (GetCVarBool("auctionDisplayOnCharacter")) then
		if (not DressUpItemLink(GetAuctionItemLink("owner", button:GetID() + effectiveIndex))) then
			DressUpBattlePet(GetAuctionItemBattlePetInfo("owner", button:GetID() + effectiveIndex));
		end
	end
	Hyperauction_SetEffectiveSelectedOwnerAuctionItemIndex(button:GetID() + effectiveIndex);
	-- Close any auction related popups
	Hyperauction_CloseAuctionStaticPopups();
	Hyperauction_AuctionFrameAuctions.cancelPrice = button.cancelPrice;
	Hyperauction_AuctionFrameAuctions_Update();
end

function Hyperauction_PriceDropDown_OnShow(self)
	UIDropDownMenu_Initialize(self, Hyperauction_PriceDropDown_Initialize);
	if (not Hyperauction_AuctionFrameAuctions.priceType) then
		Hyperauction_AuctionFrameAuctions.priceType = PRICE_TYPE_STACK;
	end
	UIDropDownMenu_SetSelectedValue(Hyperauction_PriceDropDown, Hyperauction_AuctionFrameAuctions.priceType);
end

function Hyperauction_PriceDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();

	info.text = AUCTION_PRICE_PER_ITEM;
	info.value = PRICE_TYPE_UNIT;
	info.checked = nil;
	info.func = Hyperauction_PriceDropDown_OnClick;
	UIDropDownMenu_AddButton(info);

	info.text = AUCTION_PRICE_PER_STACK;
	info.value = PRICE_TYPE_STACK;
	info.checked = nil;
	info.func = Hyperauction_PriceDropDown_OnClick;
	UIDropDownMenu_AddButton(info);
end

function Hyperauction_PriceDropDown_OnClick(self)
	if (Hyperauction_AuctionFrameAuctions.priceType ~= self.value) then
		Hyperauction_AuctionFrameAuctions.priceType = self.value;
		UIDropDownMenu_SetSelectedValue(Hyperauction_PriceDropDown, self.value);
		local startPrice = MoneyInputFrame_GetCopper(Hyperauction_StartPrice);
		local buyoutPrice = MoneyInputFrame_GetCopper(Hyperauction_BuyoutPrice);
		local stackSize = Hyperauction_AuctionsStackSizeEntry:GetNumber();
		if (stackSize > 1) then
			if (self.value == PRICE_TYPE_UNIT) then
				MoneyInputFrame_SetCopper(Hyperauction_StartPrice, math.floor(startPrice / stackSize));
				MoneyInputFrame_SetCopper(Hyperauction_BuyoutPrice, math.floor(buyoutPrice / stackSize));
			else
				MoneyInputFrame_SetCopper(Hyperauction_StartPrice, startPrice * stackSize);
				MoneyInputFrame_SetCopper(Hyperauction_BuyoutPrice, buyoutPrice * stackSize);
			end
		end
	end
end

function Hyperauction_DurationDropDown_OnShow(self)
	UIDropDownMenu_Initialize(self, Hyperauction_DurationDropDown_Initialize);
	if (not Hyperauction_AuctionFrameAuctions.duration) then
		Hyperauction_AuctionFrameAuctions.duration = 2;
	end
	UIDropDownMenu_SetSelectedValue(Hyperauction_DurationDropDown, Hyperauction_AuctionFrameAuctions.duration);
end

function Hyperauction_DurationDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();

	info.text = AUCTION_DURATION_ONE;
	info.value = 1;
	info.checked = nil;
	info.func = Hyperauction_DurationDropDown_OnClick;
	UIDropDownMenu_AddButton(info);

	info.text = AUCTION_DURATION_TWO;
	info.value = 2;
	info.checked = nil;
	info.func = Hyperauction_DurationDropDown_OnClick;
	UIDropDownMenu_AddButton(info);

	info.text = AUCTION_DURATION_THREE;
	info.value = 3;
	info.checked = nil;
	info.func = Hyperauction_DurationDropDown_OnClick;
	UIDropDownMenu_AddButton(info);
end

function Hyperauction_DurationDropDown_OnClick(self)
	Hyperauction_AuctionFrameAuctions.duration = self.value;
	UIDropDownMenu_SetSelectedValue(Hyperauction_DurationDropDown, self.value);
	Hyperauction_UpdateDeposit();
end

function Hyperauction_UpdateDeposit()
	-- MoneyFrame_Update("Hyperauction_AuctionsDepositMoneyFrame",
	-- 	CalculateAuctionDeposit(Hyperauction_AuctionFrameAuctions.duration,
	-- 		Hyperauction_AuctionsStackSizeEntry:GetNumber(),
	-- 		Hyperauction_AuctionsNumStacksEntry:GetNumber()));

	local startPrice, buyoutPrice = GetPrices();
	MoneyFrame_Update("Hyperauction_AuctionsDepositMoneyFrame",
		GetAuctionDeposit(Hyperauction_AuctionFrameAuctions.duration or 0, startPrice, buyoutPrice,
			Hyperauction_AuctionsStackSizeEntry:GetNumber(), Hyperauction_AuctionsNumStacksEntry:GetNumber()));
end

function Hyperauction_AuctionSellItemButton_OnEvent(self, event, ...)
	if (event == "NEW_AUCTION_UPDATE") then
		local name, texture, count, quality, canUse, price, pricePerUnit, stackCount, totalCount, itemID =
			GetAuctionSellItemInfo();
		if (C_WowTokenPublic.IsAuctionableWowToken(itemID)) then
			Hyperauction_AuctionsItemButtonCount:Hide();
			Hyperauction_AuctionsStackSizeEntry:Hide();
			Hyperauction_AuctionsStackSizeMaxButton:Hide();
			Hyperauction_AuctionsNumStacksEntry:Hide();
			Hyperauction_AuctionsNumStacksMaxButton:Hide();
			Hyperauction_PriceDropDown:Hide();
			Hyperauction_StartPrice:Hide();
			Hyperauction_BuyoutPrice:Hide();
			Hyperauction_DurationDropDown:Hide();
			C_WowTokenPublic.UpdateTokenCount();
			Hyperauction_AuctionsWowTokenAuctionFrame_Update();
			Hyperauction_AuctionsWowTokenAuctionFrame:Show();
			Hyperauction_AuctionsItemButton:SetNormalTexture(texture);
			Hyperauction_AuctionsItemButtonName:SetText(name);
			local color = ITEM_QUALITY_COLORS[quality];
			Hyperauction_AuctionsItemButtonName:SetVertexColor(color.r, color.g, color.b);
			-- SetItemButtonQuality(Hyperauction_AuctionsItemButton, quality, itemID)
			Hyperauction_AuctionWowToken_UpdateMarketPrice();
			MoneyFrame_SetType(Hyperauction_AuctionsDepositMoneyFrame, "AUCTION_DEPOSIT_TOKEN");
			MoneyFrame_Update("Hyperauction_AuctionsDepositMoneyFrame", 0, true);
		else
			Hyperauction_StartPrice:Show();
			Hyperauction_BuyoutPrice:Show();
			Hyperauction_DurationDropDown:Show();
			Hyperauction_AuctionsWowTokenAuctionFrame:Hide();
			Hyperauction_AuctionsItemButton:SetNormalTexture(texture);
			Hyperauction_AuctionsItemButton.stackCount = stackCount;
			Hyperauction_AuctionsItemButton.totalCount = totalCount;
			Hyperauction_AuctionsItemButton.pricePerUnit = pricePerUnit;
			Hyperauction_AuctionsItemButtonName:SetText(name);
			local color = ITEM_QUALITY_COLORS[quality];
			if color then
				Hyperauction_AuctionsItemButtonName:SetVertexColor(color.r, color.g, color.b);
			end
			-- SetItemButtonQuality(Hyperauction_AuctionsItemButton, quality, itemID)
			if (totalCount > 1) then
				Hyperauction_AuctionsItemButtonCount:SetText(totalCount);
				Hyperauction_AuctionsItemButtonCount:Show();
				Hyperauction_AuctionsStackSizeEntry:Show();
				Hyperauction_AuctionsStackSizeMaxButton:Show();
				Hyperauction_AuctionsNumStacksEntry:Show();
				Hyperauction_AuctionsNumStacksMaxButton:Show();
				Hyperauction_PriceDropDown:Show();
				Hyperauction_UpdateMaximumButtons();
			else
				Hyperauction_AuctionsItemButtonCount:Hide();
				Hyperauction_AuctionsStackSizeEntry:Hide();
				Hyperauction_AuctionsStackSizeMaxButton:Hide();
				Hyperauction_AuctionsNumStacksEntry:Hide();
				Hyperauction_AuctionsNumStacksMaxButton:Hide();
				-- checking for count of 1 so when a stack of 2 or more is removed by the user, we don't reset to "per item"
				-- totalCount will be 0 when the sell item is removed
				if (totalCount == 1) then
					Hyperauction_PriceDropDown:Hide();
				else
					Hyperauction_PriceDropDown:Show();
				end
			end
			Hyperauction_AuctionsStackSizeEntry:SetNumber(count);
			Hyperauction_AuctionsNumStacksEntry:SetNumber(1);
			if (name == HYPERAUCTION_LAST_ITEM_AUCTIONED and count == HYPERAUCTION_LAST_ITEM_COUNT) then
				MoneyInputFrame_SetCopper(Hyperauction_StartPrice, HYPERAUCTION_LAST_ITEM_START_BID);
				MoneyInputFrame_SetCopper(Hyperauction_BuyoutPrice, HYPERAUCTION_LAST_ITEM_BUYOUT);
			else
				if (UIDropDownMenu_GetSelectedValue(Hyperauction_PriceDropDown) == 1 and stackCount > 0) then
					-- unit price
					MoneyInputFrame_SetCopper(Hyperauction_StartPrice, max(100, floor(pricePerUnit * 1.5)));
				else
					MoneyInputFrame_SetCopper(Hyperauction_StartPrice, max(100, floor(price * 1.5)));
				end
				MoneyInputFrame_SetCopper(Hyperauction_BuyoutPrice, 0);
				if (name) then
					HYPERAUCTION_LAST_ITEM_AUCTIONED = name;
					HYPERAUCTION_LAST_ITEM_COUNT = count;
					HYPERAUCTION_LAST_ITEM_START_BID = MoneyInputFrame_GetCopper(Hyperauction_StartPrice);
					HYPERAUCTION_LAST_ITEM_BUYOUT = MoneyInputFrame_GetCopper(Hyperauction_BuyoutPrice);
				end
			end
			Hyperauction_UpdateDeposit();
			MoneyFrame_SetType(Hyperauction_AuctionsDepositMoneyFrame, "AUCTION_DEPOSIT");
		end
		Hyperauction_AuctionsFrameAuctions_ValidateAuction();
	end
end

function Hyperauction_AuctionSellItemButton_OnClick(self, button)
	ClickAuctionSellItemButton(self, button);
	Hyperauction_AuctionsFrameAuctions_ValidateAuction();
end

function Hyperauction_AuctionsFrameAuctions_ValidateAuction()
	Hyperauction_AuctionsCreateAuctionButton:Disable();
	Hyperauction_AuctionsBuyoutText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	Hyperauction_AuctionsBuyoutError:Hide();
	-- No item
	if (not GetAuctionSellItemInfo()) then
		return;
	end
	if (C_WowTokenPublic.IsAuctionableWowToken(select(10, GetAuctionSellItemInfo()))) then
		Hyperauction_AuctionsCreateAuctionButton:SetEnabled(not Hyperauction_AuctionsWowTokenAuctionFrame.disabled and
			C_WowTokenPublic.GetCurrentMarketPrice());
		return;
	end
	-- Buyout price is less than the start price
	if (MoneyInputFrame_GetCopper(Hyperauction_BuyoutPrice) > 0 and MoneyInputFrame_GetCopper(Hyperauction_StartPrice) > MoneyInputFrame_GetCopper(Hyperauction_BuyoutPrice)) then
		Hyperauction_AuctionsBuyoutText:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		Hyperauction_AuctionsBuyoutError:Show();
		return;
	end
	-- Start price is 0 or greater than the max allowed
	if (MoneyInputFrame_GetCopper(Hyperauction_StartPrice) < 1 or MoneyInputFrame_GetCopper(Hyperauction_StartPrice) > HYPERAUCTION_MAXIMUM_BID_PRICE) then
		return;
	end
	-- The stack size is greater than total count
	local stackCount = Hyperauction_AuctionsItemButton.stackCount or 0;
	local totalCount = Hyperauction_AuctionsItemButton.totalCount or 0;
	if (Hyperauction_AuctionsStackSizeEntry:GetNumber() == 0 or Hyperauction_AuctionsStackSizeEntry:GetNumber() > stackCount or Hyperauction_AuctionsNumStacksEntry:GetNumber() == 0 or (Hyperauction_AuctionsStackSizeEntry:GetNumber() * Hyperauction_AuctionsNumStacksEntry:GetNumber() > totalCount)) then
		return;
	end
	Hyperauction_AuctionsCreateAuctionButton:Enable();
end

--[[
function AuctionFrame_UpdateTimeLeft(elapsed, type)
	if ( not self.updateCounter ) then
		self.updateCounter = 0;
	end
	if ( self.updateCounter > AUCTION_TIMER_UPDATE_DELAY ) then
		self.updateCounter = 0;
		local index = self:GetID();
		if ( type == "list" ) then
			index = index + FauxScrollFrame_GetOffset(Hyperauction_BrowseScrollFrame);
		elseif ( type == "bidder" ) then
			index = index + FauxScrollFrame_GetOffset(Hyperauction_BidScrollFrame);
		elseif ( type == "owner" ) then
			index = index + FauxScrollFrame_GetOffset(Hyperauction_AuctionsScrollFrame);
		end
		_G[self:GetName().."ClosingTime"]:SetText(SecondsToTime(GetAuctionItemTimeLeft(type, index)));
	else
		self.updateCounter = self.updateCounter + elapsed;
	end
end
]]

function Hyperauction_AuctionFrame_GetTimeLeftText(id)
	return _G["AUCTION_TIME_LEFT" .. id];
end

function Hyperauction_AuctionFrame_GetTimeLeftTooltipText(id, isToken)
	local text = _G["AUCTION_TIME_LEFT" .. id .. "_DETAIL"];
	if (isToken) then
		text = ESTIMATED_TIME_TO_SELL_LABEL .. text;
	end
	return text;
end

local function SetupUnitPriceTooltip(tooltip, auctionItem, insertNewline)
	if (auctionItem and auctionItem.itemCount > 1) then
		local hasBid = auctionItem.bidAmount > 0;
		local hasBuyout = auctionItem.buyoutPrice > 0;

		if (hasBid) then
			if (insertNewline) then
				tooltip:AddLine("|n");
			end

			SetTooltipMoney(tooltip, ceil(auctionItem.bidAmount / auctionItem.itemCount), "STATIC",
				AUCTION_TOOLTIP_BID_PREFIX);
		end

		if (hasBuyout) then
			SetTooltipMoney(tooltip, ceil(auctionItem.buyoutPrice / auctionItem.itemCount), "STATIC",
				AUCTION_TOOLTIP_BUYOUT_PREFIX);
		end

		-- This is necessary to update the extents of the tooltip
		tooltip:Show();
	end
end

local function GetAuctionButton(buttonType, id)
	if (buttonType == "owner") then
		return _G["Hyperauction_AuctionsButton" .. id];
	elseif (buttonType == "bidder") then
		return _G["Hyperauction_BidButton" .. id];
	elseif (buttonType == "list") then
		return _G["Hyperauction_BrowseButton" .. id];
	end
end

function Hyperauction_AuctionBrowseFrame_CheckUnlockHighlight(self, selectedType, offset)
	local selected = GetSelectedAuctionItem(selectedType);
	if (not selected or (selected ~= self:GetParent():GetID() + offset)) then
		self:GetParent():UnlockHighlight();
	end
end

function Hyperauction_AuctionPriceTooltipFrame_OnLoad(self)
	self:SetMouseClickEnabled(false);
	self:SetMouseMotionEnabled(true);
end

function Hyperauction_AuctionPriceTooltipFrame_OnEnter(self)
	self:GetParent():LockHighlight();

	-- Unit price is only supported on the list tab, no need to pass in buttonType argument
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local button = GetAuctionButton("list", self:GetParent():GetID());
	SetupUnitPriceTooltip(GameTooltip, button, false);
end

function Hyperauction_AuctionPriceTooltipFrame_OnLeave(self)
	Hyperauction_AuctionBrowseFrame_CheckUnlockHighlight(self, "list",
		FauxScrollFrame_GetOffset(Hyperauction_BrowseScrollFrame));
	GameTooltip_Hide();
end

function Hyperauction_AuctionFrameItem_OnEnter(self, type, index)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

	if (index <= 0) then
		-- WoW Token
		local itemID = C_WowTokenPublic.GetListedAuctionableTokenInfo(index +
			C_WowTokenPublic.GetNumListedAuctionableTokens());
		GameTooltip:SetItemByID(itemID);
	else
		local hasCooldown, speciesID, level, breedQuality, maxHealth, power, speed, name = GameTooltip:SetAuctionItem(
			type, index);
		if (speciesID and speciesID > 0) then
			BattlePetToolTip_Show(speciesID, level, breedQuality, maxHealth, power, speed, name);
			return;
		end
	end

	-- add price per unit info
	local button = GetAuctionButton(type, self:GetParent():GetID());

	SetupUnitPriceTooltip(GameTooltip, button, true);
	GameTooltip_ShowCompareItem();

	if (IsModifiedClick("DRESSUP")) then
		ShowInspectCursor();
	else
		ResetCursor();
	end
end

function Hyperauction_AuctionsWowTokenAuctionFrame_OnLoad(self)
	self:RegisterEvent("TOKEN_MARKET_PRICE_UPDATED");
	self:RegisterEvent("TOKEN_STATUS_CHANGED");
	self:RegisterEvent("TOKEN_SELL_RESULT");
	self:RegisterEvent("TOKEN_AUCTION_SOLD");
end

function Hyperauction_AuctionsWowTokenAuctionFrame_OnEvent(self, event, ...)
	if (event == "TOKEN_MARKET_PRICE_UPDATED") then
		local result = ...;
		if (result == LE_TOKEN_RESULT_ERROR_DISABLED) then
			self.disabled = true;
		end
		Hyperauction_AuctionsWowTokenAuctionFrame_Update();
		Hyperauction_AuctionsFrameAuctions_ValidateAuction();
	elseif (event == "TOKEN_STATUS_CHANGED") then
		Hyperauction_AuctionWowToken_UpdateMarketPrice();
	elseif (event == "TOKEN_SELL_RESULT") then
		local result = ...;
		if (result == LE_TOKEN_RESULT_ERROR_DISABLED) then
			UIErrorsFrame:AddMessage(TOKEN_AUCTIONS_UNAVAILABLE, 1.0, 0.1, 0.1, 1.0);
		elseif (result ~= LE_TOKEN_RESULT_SUCCESS) then
			UIErrorsFrame:AddMessage(ERR_AUCTION_DATABASE_ERROR, 1.0, 0.1, 0.1, 1.0);
		else
			C_WowTokenPublic.UpdateListedAuctionableTokens();

			local info = ChatTypeInfo["SYSTEM"];
			DEFAULT_CHAT_FRAME:AddMessage(ERR_AUCTION_STARTED, info.r, info.g, info.b, info.id);
		end
	elseif (event == "TOKEN_AUCTION_SOLD") then
		C_WowTokenPublic.UpdateListedAuctionableTokens();
	elseif (event == "GET_ITEM_INFO_RECEIVED") then
		self:UnregisterEvent("GET_ITEM_INFO_RECEIVED");
		Hyperauction_AuctionFrameAuctions_Update();
	end
end

function Hyperauction_AuctionsWowTokenAuctionFrame_Update()
	local price, duration = C_WowTokenPublic.GetCurrentMarketPrice();
	if (WowToken_IsWowTokenAuctionDialogShown()) then
		price = C_WowTokenPublic.GetGuaranteedPrice();
	end
	if (price) then
		Hyperauction_AuctionsWowTokenAuctionFrame.MarketPrice:SetText(GetMoneyString(price, true));
		local timeToSellString = _G[("AUCTION_TIME_LEFT%d_DETAIL"):format(duration)];
		Hyperauction_AuctionsWowTokenAuctionFrame.TimeToSell:SetText(timeToSellString);
	else
		Hyperauction_AuctionsWowTokenAuctionFrame.MarketPrice:SetText(TOKEN_MARKET_PRICE_NOT_AVAILABLE);
		Hyperauction_AuctionsWowTokenAuctionFrame.TimeToSell:SetText(UNKNOWN);
	end
end

function Hyperauction_AuctionWowToken_UpdateMarketPriceCallback()
	if (C_WowTokenPublic.GetCommerceSystemStatus()
			and ((Hyperauction_BrowseWowTokenResults:IsVisible() or Hyperauction_AuctionsWowTokenAuctionFrame:IsVisible()) and not WowToken_IsWowTokenAuctionDialogShown())) then
		Hyperauction_AuctionFrame.lastMarketPriceUpdate = GetTime();
		C_WowTokenPublic.UpdateMarketPrice();
	elseif (not (Hyperauction_BrowseWowTokenResults:IsVisible() or Hyperauction_AuctionsWowTokenAuctionFrame:IsVisible())) then
		Hyperauction_AuctionWowToken_CancelUpdateTicker();
	end
end

function Hyperauction_AuctionWowToken_ShouldUpdatePrice()
	local now = GetTime();
	local enabled, pollTimeSeconds = C_WowTokenPublic.GetCommerceSystemStatus();
	if (not enabled) then
		return false;
	elseif (not C_WowTokenPublic.GetCurrentMarketPrice()) then
		return true;
	elseif (not Hyperauction_AuctionFrame.lastMarketPriceUpdate) then
		return true;
	elseif (now - Hyperauction_AuctionFrame.lastMarketPriceUpdate > pollTimeSeconds) then
		return true;
	end
	return false;
end

function Hyperauction_AuctionWowToken_UpdateMarketPrice()
	if (Hyperauction_AuctionWowToken_ShouldUpdatePrice()) then
		Hyperauction_AuctionFrame.lastMarketPriceUpdate = GetTime();
		C_WowTokenPublic.UpdateMarketPrice();
	end
	if ((Hyperauction_BrowseWowTokenResults:IsVisible() or Hyperauction_AuctionsWowTokenAuctionFrame:IsVisible()) and not WowToken_IsWowTokenAuctionDialogShown()) then
		local _, pollTimeSeconds = C_WowTokenPublic.GetCommerceSystemStatus();
		if (not Hyperauction_AuctionFrame.priceUpdateTimer or pollTimeSeconds ~= Hyperauction_AuctionFrame.priceUpdateTimer.pollTimeSeconds) then
			if (Hyperauction_AuctionFrame.priceUpdateTimer) then
				Hyperauction_AuctionFrame.priceUpdateTimer:Cancel();
			end
			Hyperauction_AuctionFrame.priceUpdateTimer = C_Timer.NewTicker(pollTimeSeconds,
				Hyperauction_AuctionWowToken_UpdateMarketPriceCallback);
			Hyperauction_AuctionFrame.priceUpdateTimer.pollTimeSeconds = pollTimeSeconds;
		end
	end
end

function Hyperauction_AuctionWowToken_CancelUpdateTicker()
	if (Hyperauction_AuctionFrame.priceUpdateTimer) then
		Hyperauction_AuctionFrame.priceUpdateTimer:Cancel();
		Hyperauction_AuctionFrame.priceUpdateTimer = nil;
	end
end

-- SortButton functions
function Hyperauction_SortButton_UpdateArrow(button, type, sort)
	local primaryColumn, reversed = GetAuctionSort(type, 1);
	button.Arrow:SetShown(sort == primaryColumn);
	if (sort == primaryColumn) then
		if (reversed) then
			button.Arrow:SetTexCoord(0, 0.5625, 0, 1);
		else
			button.Arrow:SetTexCoord(0, 0.5625, 1, 0);
		end
	end
end

-- Function to close popups if another auction item is selected
function Hyperauction_CloseAuctionStaticPopups()
	StaticPopup_Hide("HYPERAUCTION_BUYOUT_AUCTION");
	StaticPopup_Hide("HYPERAUCTION_BID_AUCTION");
	StaticPopup_Hide("HYPERAUCTION_CANCEL_AUCTION");
end

function Hyperauction_AuctionsCreateAuctionButton_OnClick()
	if (C_WowTokenPublic.IsAuctionableWowToken(select(10, GetAuctionSellItemInfo()))) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
		C_WowTokenPublic.SellToken();
	else
		HYPERAUCTION_LAST_ITEM_START_BID = MoneyInputFrame_GetCopper(Hyperauction_StartPrice);
		HYPERAUCTION_LAST_ITEM_BUYOUT = MoneyInputFrame_GetCopper(Hyperauction_BuyoutPrice);
		DropCursorMoney();
		PlaySound(SOUNDKIT.LOOT_WINDOW_COIN_SOUND);
		local startPrice = MoneyInputFrame_GetCopper(Hyperauction_StartPrice);
		local buyoutPrice = MoneyInputFrame_GetCopper(Hyperauction_BuyoutPrice);
		if (Hyperauction_AuctionFrameAuctions.priceType == PRICE_TYPE_UNIT) then
			startPrice = startPrice * Hyperauction_AuctionsStackSizeEntry:GetNumber();
			buyoutPrice = buyoutPrice * Hyperauction_AuctionsStackSizeEntry:GetNumber();
		end
		StartAuction(startPrice, buyoutPrice, Hyperauction_AuctionFrameAuctions.duration,
			Hyperauction_AuctionsStackSizeEntry:GetNumber(),
			Hyperauction_AuctionsNumStacksEntry:GetNumber());
	end
end

function Hyperauction_SetMaxStackSize()
	local stackCount = Hyperauction_AuctionsItemButton.stackCount;
	local totalCount = Hyperauction_AuctionsItemButton.totalCount;
	if (totalCount and totalCount > 0) then
		if (totalCount > stackCount) then
			Hyperauction_AuctionsStackSizeEntry:SetNumber(stackCount);
			Hyperauction_AuctionsNumStacksEntry:SetNumber(math.floor(totalCount / stackCount));
		else
			Hyperauction_AuctionsStackSizeEntry:SetNumber(totalCount);
			Hyperauction_AuctionsNumStacksEntry:SetNumber(1);
		end
	else
		Hyperauction_AuctionsStackSizeEntry:SetNumber("");
		Hyperauction_AuctionsNumStacksEntry:SetNumber("");
	end
end

function Hyperauction_UpdateMaximumButtons()
	local stackSize = Hyperauction_AuctionsStackSizeEntry:GetNumber();
	if (stackSize == 0) then
		Hyperauction_AuctionsStackSizeMaxButton:Enable();
		Hyperauction_AuctionsNumStacksMaxButton:Enable();
		return;
	end
	local stackCount = Hyperauction_AuctionsItemButton.stackCount;
	local totalCount = Hyperauction_AuctionsItemButton.totalCount;
	if (stackSize ~= min(totalCount, stackCount)) then
		Hyperauction_AuctionsStackSizeMaxButton:Enable();
	else
		Hyperauction_AuctionsStackSizeMaxButton:Disable();
	end
	if (Hyperauction_AuctionsNumStacksEntry:GetNumber() ~= math.floor(totalCount / stackSize)) then
		Hyperauction_AuctionsNumStacksMaxButton:Enable();
	else
		Hyperauction_AuctionsNumStacksMaxButton:Disable();
	end
end

function Hyperauction_AuctionProgressFrame_OnUpdate(self)
	if (self.fadeOut) then
		local alpha = self:GetAlpha() - CASTING_BAR_ALPHA_STEP;
		if (alpha > 0) then
			self:SetAlpha(alpha);
		else
			self.fadeOut = nil;
			self:Hide();
			self:SetAlpha(1);
		end
	end
end
