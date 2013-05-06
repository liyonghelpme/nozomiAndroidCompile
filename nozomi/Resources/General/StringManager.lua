StringManager = nil
do
	local stringCache = {}
	local function init(language)
		function Entry(key, ...)
			stringCache[key] = arg[language]
		end
		require "data.strings"
		
		-- 加一下时间
		Entry("sec", "秒", "S")
		Entry("min", "分钟", "M")
		Entry("hour", "小时", "H")
		Entry("day", "天", "d")
		Entry("none", "无", "None")
		Entry("timeSplit", "", " ")
		Entry = nil
	end
	
	local function getString(key)
		return stringCache[key] or key
	end
	
	local function getFormatString(key, param)
		local s = getString(key)
		local function stringFormat(k)
			local pk = string.sub(k, 2, -2)
			return param[pk] or k
		end
		local result = string.gsub(s, "%[[a-zA-Z]+%]", stringFormat)
		return result
	end
	
	local function getNumberString(num)
		if num < 10 then
			return "0" .. num
		else
			return "" .. num
		end
	end
	
	local timeSeq = {"sec", "min", "hour", "day"}
	local timeMod = {60, 60, 24, 30}
	local function getTimeString(timeInSeconds)
		if not timeInSeconds or timeInSeconds<=0 then
			return getString("none")
		else
			local ret, retSeq, retIndex, time = "", {}, 0, math.floor(timeInSeconds)
			for i=1, 4 do
				local temp = time % timeMod[i]
				time = math.floor(time/timeMod[i])
				retIndex = i
				if temp~=0 or i==1 then
					retSeq[i] = temp .. getString(timeSeq[i])
				end
				if time==0 then break end
			end
			ret = retSeq[retIndex]
			if retSeq[retIndex-1] then
				ret = ret .. getString("timeSplit") .. retSeq[retIndex-1]
			end
			return ret
		end
	end
	
	StringManager = {LANGUAGE_CN=1, LANGUAGE_EN=2, init=init ,getString=getString, getFormatString = getFormatString, getTimeString=getTimeString}
end