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
	local result = QueryAuctionItems(item_name, nil, nil, 0, nil, 0, true, true, nil)
	print(CanSendAuctionQuery())
	print(result)
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