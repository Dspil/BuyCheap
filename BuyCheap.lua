function BuyCheap_OnLoad()
	buycheap_button = CreateFrame("Button", "MyButton", UIParent, "UIPanelButtonTemplate")
	buycheap_button:SetText("Best Price")
	buycheap_button:SetScript("OnClick", BuyCheap)
	buycheap_button:Hide()
	
	buycheap_amount = CreateFrame("EditBox", "MyBox", UIParent, "InputBoxTemplate")
	buycheap_amount:SetNumeric()
	buycheap_amount:SetAutoFocus(false)
	buycheap_amount:Hide()
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

-- open mail logic

function BuyCheap()
	local amount = buycheap_amount:GetNumber()
	local item_name = BrowseName:GetText()
	BuyCheap_Query(item_name, {}, {}, 0, amount)		
end

function BuyCheap_Query(item_name, prices, weights, page, amount)
	QueryAuctionItems(item_name, nil, nil, 0, 0, 0, page, 0, false)
	BuyCheap_wait(4, BuyCheap_FindAllItems, item_name, prices, weights, page, amount)
end

function BuyCheap_FindAllItems(item_name, prices, weights, page, amount)
	local current, total = GetNumAuctionItems("list")
	local cur_num = page * 50
	for i = 0, current - 1 do
		local _, _, count, _, _, _, _, _, buyoutPrice, _, _, _, _ = GetAuctionItemInfo("list", i + 1)
		prices[cur_num + i] = buyoutPrice
		weights[cur_num + i] = count
	end
	if cur_num + current == total then
		BuyCheap_itemstobuy, BuyCheap_itemstobuy_len = BuyCheap_knapsack(weights, prices, amount, total)
	else
		BuyCheap_Query(item_name, prices, weights, page + 1, amount)
	end
end

-- knapsack function

function BuyCheap_knapsack(weights, prices, W, n)
    local dpt = {}
    local prev = 0
    local cur = 0
    for item = 0, n do
        dpt[item] = {}
        for weight = 0, W do
            if item == 0 or weight == 0 then
                dpt[item][weight] = {0, false}
            else
                if weights[item - 1] > weight then
                    dpt[item][weight] = {dpt[item - 1][weight][1], false}
                else
                    if dpt[item - 1][weight - weights[item - 1]][1] == 0 then
                        if weights[item - 1] == weight then
                            dpt[item][weight] = {prices[item-1], true}
                        else
                            dpt[item][weight] = {dpt[item-1][weight][1], false}
                        end
                    else
                        prev = dpt[item - 1][weight][1]
                        cur = dpt[item - 1][weight - weights[item - 1]][1] + 1 / prices[item - 1]
                        if cur > prev then
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
    return indices, c
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