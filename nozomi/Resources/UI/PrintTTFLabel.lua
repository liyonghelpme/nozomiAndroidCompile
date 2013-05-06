do
	-- 即大小写字符或数字，不可切断（因此只能换行）
	local PCHAR_EN = 1
	-- 即中文
	local PCHAR_UTF8 = 2
	-- 空白符，不占用打印时间
	local PCHAR_SPACE = 3
	-- 其他符号，可切断
	local PCHAR_OTHER = 4

	-- 先简单弄个匀速打字的玩意
	UI.createPrintTTFLabel = function(size, text, fontName, fontSize, setting)
		local bg = CCNode:create()
		bg:setContentSize(size)
		-- 下一次处理文本的位置（位于已处理字符之后）
		local curTextPos = 1
		-- 下一个可打印字符的位置（位于已打印字符之后）
		local curCharPos = 1
		local charType = {}
		local toPrintText = ""
		local toPrintLabels = {{head=1, tail=1, label=nil, changed=false}}
		local line = 1
		
		local params = setting or {}
		local updateId = nil
		local endCallback = params.callback
		local inteval = params.inteval or 0.1
		-- 行高，默认为字号大小
		local lineHeight = params.lineHeight or fontSize
		-- 段间距，默认为0
		local disy = params.disy or 0
		local r, g, b = params.colorR or 255, params.colorG or 255, params.colorB or 255
		
		local function pause()
			if updateId then
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(updateId)
				updateId = nil
			end
		end
		
		local function printLabel()
			for i=1, #toPrintLabels do
				local lineLabel = toPrintLabels[i]
				if lineLabel.head == lineLabel.tail then
					if lineLabel.label then
						lineLabel.label:removeFromParentAndCleanup(true)
						lineLabel.label = nil
					end
				elseif lineLabel.changed then
					if lineLabel.label then
						lineLabel.label:setString(string.sub(toPrintText, lineLabel.head, lineLabel.tail-1))
					else
						lineLabel.label = CCLabelTTF:create(string.sub(toPrintText, lineLabel.head, lineLabel.tail-1), fontName, fontSize, CCSizeMake(0, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
						lineLabel.label:setAnchorPoint(General.anchorLeftTop)
						if i==1 then
							lineLabel.label:setPosition(0, size.height)
						else
							local nly = 0
							for j=1, i do
								if j<i then
									nly = nly + lineHeight
								end
								if toPrintLabels[j].isNewLine then
									nly = nly + disy
								end
							end
							lineLabel.label:setPosition(0, size.height - nly)
						end
        				lineLabel.label:setColor(ccc3(r, g, b))
        				bg:addChild(lineLabel.label)
					end
					if lineLabel.label:getContentSize().width > size.width then
						local changeNum = 0
						if charType[curCharPos - 1] == PCHAR_UTF8 then
							changeNum = 3
						elseif charType[curCharPos - 1] == PCHAR_SPACE then
							changeNum = 0
						elseif charType[curCharPos - 1] == PCHAR_OTHER then
							changeNum = 1
						else
							for j=1, curCharPos do
								if charType[curCharPos - j] == PCHAR_EN then
									if j==curCharPos - 1 then
										changeNum = 0
										break
									end
									changeNum = changeNum + 1
								else
									break
								end
							end
						end
						if changeNum ~= 0 then
							lineLabel.tail = lineLabel.tail - changeNum
							if i< line then
								toPrintLabels[i+1].head = toPrintLabels[i+1].head - changeNum
								toPrintLabels[i+1].changed = true
							else
								line = line + 1
								toPrintLabels[i+1] = {label = nil, changed = true, head = lineLabel.tail, tail = lineLabel.tail + changeNum}
							end
							return printLabel()
						end
					end
					lineLabel.changed = false
				end
			end
		end
		
		-- 每次调用这个方法，使打印label后执行一位； "<>" 是控制符号
		local function parsePrintText()
			if curTextPos > string.len(text) then
				if endCallback then
					endCallback()
				end
				pause()
				return
			end
			local sbyte = string.byte(text, curTextPos)
			local sbyteType = character.getCharType(sbyte)
			
			if sbyteType == character.CHAR_UTF8 then
				charType[curCharPos] = PCHAR_UTF8
				toPrintText = toPrintText .. string.sub(text, curTextPos, curTextPos+2)
				toPrintLabels[line].tail = toPrintLabels[line].tail + 3
				toPrintLabels[line].changed = true
				curTextPos = curTextPos + 3
				curCharPos = curCharPos + 1
			elseif sbyteType == character.CHAR_LESS then
				-- 先假设 <>中b为退格， p为暂停， 节奏均保持相同
				local sbegin, send, command = string.find(text, "%<(.-)%>", curTextPos)
				curTextPos = send+1
				if command == "p" then
					return
				elseif command == "b" then
					local deleteNum = 0
					while curCharPos>1 do
						curCharPos = curCharPos - 1
						local lastCharType = charType[curCharPos]
						charType[curCharPos] = nil
						if lastCharType == PCHAR_UTF8 then
							deleteNum = deleteNum + 3
							break
						else
							deleteNum = deleteNum + 1
							if lastCharType ~= PCHAR_SPACE then
								break
							end
						end
					end
					toPrintText = string.sub(toPrintText, 1, -1-deleteNum) or ""
					while true do
						if toPrintLabels[line].head <= toPrintLabels[line].tail-deleteNum then
							toPrintLabels[line].tail = toPrintLabels[line].tail-deleteNum
							toPrintLabels[line].changed = true
							break
						else
							deleteNum = deleteNum - (toPrintLabels[line].tail-toPrintLabels[line].head)
							toPrintLabels[line].tail = toPrintLabels[line].head
							toPrintLabels[line].changed = true
							if line == 1 then break end
							line = line - 1
						end
					end
				end
			else
				curTextPos = curTextPos + 1
				toPrintText = toPrintText .. string.char(sbyte)
				toPrintLabels[line].tail = toPrintLabels[line].tail + 1
				curCharPos = curCharPos + 1
				if sbyteType == character.CHAR_SPACE then
					charType[curCharPos-1] = PCHAR_SPACE
					return parsePrintText()
				elseif sbyteType == character.CHAR_NL then
					charType[curCharPos-1] = PCHAR_SPACE
					local newBegin = toPrintLabels[line].tail
					line = line + 1
					toPrintLabels[line] = {head = newBegin, tail = newBegin, changed = false, isNewLine = true}
					return parsePrintText()
				elseif sbyteType == character.CHAR_NUM or sbyteType == character.CHAR_EN then
					charType[curCharPos-1] = PCHAR_EN
					toPrintLabels[line].changed = true
				else
					charType[curCharPos-1] = PCHAR_OTHER
					toPrintLabels[line].changed = true
				end
			end
			music.playEffect("music/print" .. (curCharPos%2) .. ".mp3")
			return printLabel()
		end
		
		local curTick = 0
		local function update(diff)
			curTick = curTick + diff
			if curTick > inteval then
				curTick = curTick - inteval
				parsePrintText()
			end
		end
		
		local function start()
			updateId  = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(update, 0, false)
		end
		local function stop()
			pause()
		end
		local function enterOrExit(boolValue)
			if not boolValue then
				pause()
			end
		end
		simpleRegisterEvent(bg, {update = {callback = update, inteval = 0.1}, enterOrExit = {callback = enterOrExit}})
		return {view = bg, start = start, stop = stop, pause = pause}
	end
end