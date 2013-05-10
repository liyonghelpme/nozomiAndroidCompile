TipsData = {}

local allTips = {}
function Entry(id, min, max)
    table.insert(allTips, {id, min, max})
end
require "data.tips"

function TipsData.getTip()
	local tips = {}
	local level = CCUserDefault:sharedUserDefault():getStringForKey("userLevel")
	if not level or level=="" then
	    level = 1
	else
	    level = tonumber(level)
	end
	
	for i=1, #allTips do
	    if allTips[i][2]<=level and allTips[i][3]>=level then
	        table.insert(tips, allTips[i][1])
	    end
	end

	if #tips>0 then
    	return StringManager.getString("dataTips" .. tips[math.random(#tips)])
    else
    	return StringManager.getString("dataTips1")
    end
end