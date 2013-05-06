network = {baseUrl="http://192.168.3.101:5000/"}

-- 默认参数只支持字符串和数字
network.httpRequest = function (url, callback, setting, delegate)
	local paramStr = ""
	setting = setting or {}
	local request = nil
	local function httpOver(isSuc)
		if not isSuc then
			print("HTTP Canceled")
			callback(false, nil, setting.callbackParam)
		else
			local hcode = request:getResponseStatusCode()
			if hcode==200 then
				local responseStr = request:getResponseString()
				if delegate then
					callback(delegate, true, responseStr, setting.callbackParam)
				else
					callback(true, responseStr, setting.callbackParam)
				end
			else
				print("HTTP Failed " .. hcode)
				if delegate then
					callback(delegate, false, nil, setting.callbackParam)
				else
					callback(false, nil, setting.callbackParam)
				end
			end
		end
		request:release()
	end
	local pos = string.find(url, "http://")
	if pos ~= 1 then
		url = network.baseUrl .. url
	end
	if not setting.isPost then
		local emptyParam = true
		if setting.params then
			for key, value in pairs(setting.params) do
				if emptyParam then
					paramStr = key .. "=" .. value
					emptyParam = false
				else
					paramStr = paramStr .. "&" .. key .. "=" .. value
				end
			end
		end
		if not emptyParam then
			url = url .. "?" .. paramStr
		end
		request = CCHttpRequest:create(httpOver, url)
		request:retain()
	else
		request = CCHttpRequest:create(httpOver, url, false)
		request:retain()
		if setting.params then
			for key, value in pairs(setting.params) do
				request:addPostValue(key, value)
			end
		end
	end
	if setting.timeout then
		request:setTimeout(setting.timeout)
	end
	request:start()
	return request
end