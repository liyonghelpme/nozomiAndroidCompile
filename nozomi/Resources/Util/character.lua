character = {CHAR_NUM=1, CHAR_EN=2, CHAR_SPACE=3, CHAR_NL=4, CHAR_LESS=5, CHAR_OTHER=6, CHAR_UTF8=7}
do
	character.getCharType = function(byte)
		if byte>=128 then
			return character.CHAR_UTF8
		elseif byte == 32 then
			return character.CHAR_SPACE
		elseif byte == 10 then
			return character.CHAR_NL
		elseif byte == 60 then
			return character.CHAR_LESS
		elseif byte >=48 and byte<=57 then
			return character.CHAR_NUM
		elseif (byte >=65 and byte<=90) or (byte>=97 and byte<=122) then
			return character.CHAR_EN
		else
			return character.CHAR_OTHER
		end
	end
	
	character.isSpace = function(byte)
		if byte == 32 or byte==10 then
			return true
		end
		return false
	end
	
	character.isNum = function(byte)
		if byte >=48 and byte<=57 then
			return true
		end
		return false
	end
end