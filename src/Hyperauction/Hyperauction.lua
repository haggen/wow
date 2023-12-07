-- Hyperauction
-- MIT © 2019 Arthur Corenzan
-- More on https://github.com/haggen/wow

---@type string
local HYPERAUCTION = ...;

---@type table
local api = select(2, ...);

---Items to query buyout price.
---@type table
api.queue = {};

---@class SavedVariables
---@field version number Saved variables version.
---@field debug boolean Debug mode.
api.defaultSavedVars = {
    version = 1,
    debug = false,
};

-- The global HyperauctionSavedVars will be replaced when the add-on is loaded. This is just to have it typed.
HyperauctionSavedVars = api.defaultSavedVars;

---@param message string
local function d(message, ...)
    if not HyperauctionSavedVars.debug then
        return;
    end
    local args = { ... };
    for i = 1, #args do
        args[i] = tostring(args[i]);
    end
    print("Hyperauction: ", string.format(message, ...));
end

local function Initialize()
    d("Initializing");

    if (HyperauctionSavedVars.version or 0) < api.defaultSavedVars.version then
        for key, value in pairs(api.defaultSavedVars) do
            HyperauctionSavedVars[key] = value;
        end
        for key, _ in pairs(HyperauctionSavedVars) do
            if api.defaultSavedVars[key] == nil then
                HyperauctionSavedVars[key] = nil;
            end
        end
    end
end

local function QueryLowestBuyoutPrice(name, count)
    if not AuctionFrame:IsShown() then
        d("Not at the auction house")
        return;
    end

    if not CanSendAuctionQuery() then
        d("Query on cooldown")
        return;
    end

    table.insert(api.queue, { name = name, count = count });

    SortAuctionSetSort("list", "unitprice", false);

    -- QueryAuctionItems(text, minLevel, maxLevel, page, usable, rarity, getAll, exactMatch, filterData);
    QueryAuctionItems(name, nil, nil, 0, nil, nil, false, true, nil);
end

local function HookAuctionHouse()
    d("Hooking auction house add-on");

    AuctionsItemButton:HookScript("OnEvent", function(self, event)
        if event ~= "NEW_AUCTION_UPDATE" then
            return;
        end

        local name, texture, count, quality, canUse, price, pricePerUnit, stackCount, totalCount, itemID =
            GetAuctionSellItemInfo();

        if not name then
            return;
        end

        QueryLowestBuyoutPrice(name, count);
    end);
end

local function OnAuctionItemListUpdate()
    if #api.queue == 0 then
        return;
    end

    local item = table.remove(api.queue, 1);

    d("Finding lowest buyout price for %s x%s", item.name, item.count);

    local name, texture, count, quality, canUse, level, levelColHeader, minBid,
    minIncrement, buyoutPrice, bidAmount, highBidder, bidderFullName, owner,
    ownerFullName, saleStatus, itemId, hasAllInfo = GetAuctionItemInfo("list", 1);

    if name ~= item.name then
        d("Item name mismatch %q vs %q", name, item.name);
        QueryLowestBuyoutPrice(item.name, item.count);
        return;
    end

    local lowestBuyoutPrice = buyoutPrice / count;

    d("Lowest buyout price for %s is %s", name, lowestBuyoutPrice);

    local undercut = 1;
    if owner == UnitName("player") then
        d("No undercut since lowest buyout price is ours");
        undercut = 0;
    end

    if lowestBuyoutPrice > 0 then
        MoneyInputFrame_SetCopper(BuyoutPrice, (lowestBuyoutPrice - undercut) * item.count);
        UpdateDeposit();
        AuctionsFrameAuctions_ValidateAuction();
    end
end

--
--
--

local frame = CreateFrame("Frame");

frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("AUCTION_ITEM_LIST_UPDATE") ---@diagnostic disable-line: param-type-mismatch

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...;
        if name == HYPERAUCTION then
            Initialize();
        elseif name == "Blizzard_AuctionUI" then
            HookAuctionHouse();
        end
    elseif event == "AUCTION_ITEM_LIST_UPDATE" then
        OnAuctionItemListUpdate();
    end
end);
