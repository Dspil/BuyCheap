function BuyCheap_OnLoad()
	buycheap_button = CreateFrame("Button", "MyButton", UIParent, "UIPanelButtonTemplate")
	buycheap_button:SetText("Best Price")
	buycheap_button:SetScript("OnClick", BuyCheap)
	buycheap_button:Hide()
	
	buycheap_amount = CreateFrame("EditBox", "MyBox", UIParent, "InputBoxTemplate")
	buycheap_amount:SetNumeric()
	buycheap_amount:SetAutoFocus(false)
	buycheap_amount:Hide()
	
	StaticPopupDialogs["BUYCHEAP_POPUP_SUCCESS"] = {
		text = "Best price found for %s item%s:",
		hasMoneyFrame = true,
		OnShow = function(self, amount, formatter)
			MoneyFrame_Update(self.moneyFrame, BuyCheap_itemstobuy_price);
		end,
		button1 = "Buy",
		button2 = "Cancel",
		OnAccept = function()
			BuyCheap_BuyItems(-1, 1)
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
	}
	
	StaticPopupDialogs["BUYCHEAP_POPUP_FAILURE"] = {
		text = "Could not find a way to purchase exactly %s item%s",
		OnShow = function(self, amount, formatter)
		end,
		button1 = "Ok",
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
	}
end

function BuyCheap_EventHandler(event)
	if event == "AUCTION_HOUSE_SHOW" then
		buycheap_button:SetParent("AuctionFrameBrowse")
		buycheap_button:SetPoint("TOP", "AuctionFrameBrowse", buycheap_button:GetParent():GetWidth() / 3.3, -buycheap_button:GetParent():GetHeight() / 12)
		buycheap_button:SetSize(buycheap_button:GetParent():GetWidth() / 10 , buycheap_button:GetParent():GetHeight() / 22)
		buycheap_button:Show()
		
		buycheap_amount:SetParent("AuctionFrameBrowse")
		buycheap_amount:SetFrameLevel(buycheap_amount:GetParent():GetFrameLevel() + 1)
		buycheap_amount:SetPoint("TOP", "AuctionFrameBrowse", buycheap_amount:GetParent():GetWidth() / 3.1, -buycheap_amount:GetParent():GetHeight() / 7.5)
		buycheap_amount:SetSize(buycheap_amount:GetParent():GetWidth() / 13 , buycheap_amount:GetParent():GetHeight() / 25)
		buycheap_amount:SetNumber(1)
		buycheap_amount:Show()
	else 
		buycheap_button:Hide()
		buycheap_amount:Hide()
	end

end

-- logic

function BuyCheap()
	local amount = buycheap_amount:GetNumber()
	BuyCheap_itemname = BrowseName:GetText()
	BuyCheap_Query({}, {}, 0, amount)		
end

function BuyCheap_Query(prices, weights, page, amount)
	QueryAuctionItems(BuyCheap_itemname, nil, nil, 0, 0, 0, page, 0, false)
	BuyCheap_wait(4, BuyCheap_FindAllItems, prices, weights, page, amount)
end

function BuyCheap_FindAllItems(prices, weights, page, amount)
	local current, total = GetNumAuctionItems("list")
	local cur_num = page * 50
	for i = 0, current - 1 do
		local itemname, _, count, _, _, _, _, _, buyoutPrice, _, _, _, _ = GetAuctionItemInfo("list", i + 1)
		if itemname == BuyCheap_itemname then
			prices[cur_num + i] = buyoutPrice
		else
			prices[cur_num + i] = 0
		end
		weights[cur_num + i] = count
	end
	if cur_num + current == total then
		BuyCheap_itemstobuy, BuyCheap_itemstobuy_price, BuyCheap_itemstobuy_len = BuyCheap_Knapsack(weights, prices, amount, total)
		BuyCheap_weights = weights
		BuyCheap_prices = prices
		local formatter = ""
		if amount > 1 then formatter = "s" end
		if BuyCheap_itemstobuy == nil then
			StaticPopup_Show("BUYCHEAP_POPUP_FAILURE", tostring(amount), formatter)
		else
			BuyCheap_totalitems = total
			BuyCheap_itemi = BuyCheap_itemstobuy_len - 1
			StaticPopup_Show("BUYCHEAP_POPUP_SUCCESS", tostring(amount), formatter)
		end
	else
		BuyCheap_Query(prices, weights, page + 1, amount)
	end
end

function BuyCheap_BuyQuery(page, i)
	QueryAuctionItems(BuyCheap_itemname, nil, nil, 0, 0, 0, page, 0, false)
	BuyCheap_wait(4, BuyCheap_BuyItems, page, i)
end

function BuyCheap_booltoint(b)
	if b then return 1 else return 0 end
end

function BuyCheap_BuyItems(cur_page, cur_i)
	if BuyCheap_itemi == -1 then return nil end
	while cur_i <= BuyCheap_totalitems do
		if floor(cur_i / 50) + BuyCheap_booltoint(cur_i % 50 > 0) - 1 ~= cur_page then
			BuyCheap_BuyQuery(cur_page + 1, cur_i)
			return nil
		end
		local itemname, _, count, _, _, _, _, _, buyoutPrice, _, _, _, _ = GetAuctionItemInfo("list", cur_i % 50 + 1)
		if count == BuyCheap_weights[BuyCheap_itemstobuy[BuyCheap_itemi]] and buyoutPrice == BuyCheap_prices[BuyCheap_itemstobuy[BuyCheap_itemi]] and itemname == BuyCheap_itemname then
			PlaceAuctionBid("list", cur_i % 50 + 1, buyoutPrice)
			BuyCheap_itemi = BuyCheap_itemi - 1
			print("in")
			return nil
		else
			cur_i = cur_i + 1
		end
	end	
end

-- Knapsack function
function BuyCheap_Knapsack(weights, prices, W, n)
    local dpt = {}
    local prev = 0
    local cur = 0
    local cur1 = 0
    for item = 0, n do
        dpt[item] = {}
        for weight = 0, W do
            if item == 0 or weight == 0 then
                dpt[item][weight] = {0, false}
			elseif prices[item - 1] == 0 then
				dpt[item][weight] = {dpt[item-1][weight][1], false}
            else
                prev = dpt[item - 1][weight][1]
                if weights[item - 1] > weight then
                    dpt[item][weight] = {prev, false}
                else
                    cur = dpt[item - 1][weight - weights[item - 1]][1] + prices[item - 1]
                    cur1 = dpt[item - 1][weight - weights[item - 1]][1]
                    if prev == 0 and cur1 == 0 then
                        if weights[item - 1] == weight then
                            dpt[item][weight] = {cur, true}
                        else
                            dpt[item][weight] = {0, false}
                        end
                    elseif prev == 0 and cur1 ~= 0 then
                        dpt[item][weight] = {cur, true}
                    elseif prev ~= 0 and cur1 == 0 then
                        if weights[item - 1] == weight and cur < prev then
                          dpt[item][weight] = {cur, true}
                        else dpt[item][weight] = {prev, false}
                        end
                    else
                        if cur < prev then
                            dpt[item][weight] = {cur, true}
                        else
                            dpt[item][weight] = {prev, false}
                        end
                    end
                end
            end
        end
    end
	local indices = {}
    local i = n
    local j = W
    local c = 0
    while i > 0 do
        if dpt[i][j][2] then
            indices[c] = i - 1
            c = c + 1
            j = j - weights[i - 1]
        end
        i =  i - 1
    end
    if c == 0 then
        return nil, nil
    end
    return indices, dpt[n][W][1], c
  end

-- wait function below

local waitTable = {};
local waitFrame = nil;

function BuyCheap_wait(delay, func, ...)
  if(type(delay)~="number" or type(func)~="function") then
    return false;
  end
  if(waitFrame == nil) then
    waitFrame = CreateFrame("Frame","WaitFrame", UIParent);
    waitFrame:SetScript("onUpdate",function (self,elapse)
      local count = #waitTable;
      local i = 1;
      while(i<=count) do
        local waitRecord = tremove(waitTable,i);
        local d = tremove(waitRecord,1);
        local f = tremove(waitRecord,1);
        local p = tremove(waitRecord,1);
        if(d>elapse) then
          tinsert(waitTable,i,{d-elapse,f,p});
          i = i + 1;
        else
          count = count - 1;
          f(unpack(p));
        end
      end
    end);
  end
  tinsert(waitTable,{delay,func,{...}});
  return true;
end