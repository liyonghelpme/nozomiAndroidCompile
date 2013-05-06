music = {}

do
	local engine = SimpleAudioEngine:sharedEngine()
	local musicOn = true
	local curMusic = nil
	music.playBackgroundMusic = function(music)
		curMusic = music
		if musicOn then
			engine:playBackgroundMusic(music, true)
		end
	end
	
	music.playEffect = function(effect)
		if musicOn then
			engine:playEffect(effect, false)
		end
	end
	
	music.changeMusicState = function(on)
		if musicOn~=on then
			musicOn = on
			if curMusic~=nil then
				if musicOn then
					engine:playBackgroundMusic(curMusic, true)
				else
					engine:stopBackgroundMusic(true)
				end
			end
		end
	end
	
	music.getMusicState = function()
		return musicOn
	end
	
	-- 把需要预加载的音乐音效都放这
	local function init()
		engine:preloadEffect("music/business.mp3")
		engine:preloadEffect("music/but.mp3")
		engine:preloadEffect("music/pick.mp3")
	end
end