UserSetting = {musicOn = false, soundOn=false, nightMode = true}

UserData = {isNight=false, researchLevel={[1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1}}

SceneTypes = {Operation=1, Battle=2, Zombie=3, Stage=4, Visit=5}
BuildStates = {STATE_FREE="free", STATE_BUILDING="building", STATE_DESTROY="destroy"}
GridKeys = {Build=1, SET_SOLDIER=2}

TAG_LIGHT=1000
TAG_ACTION=2000
TAG_VISIT=3000

TOWN_BID=1
LOST_PERCENT=20

NEXT_COST={10, 50, 75, 110, 170, 250, 380, 580, 750}
TIME_SCALE = {1, 2, 4}
RANK_COLOR = {{255, 212, 88}, {166, 186, 188}, {191, 148, 118}}
STORAGE_IMG_SETTING={food="images/storeItemFood1.png", oil="images/storeItemOil2.png", person="images/storeItemPerson2.png"}

do
	function UserData.changeValue(key, value)
		UserData[key] = (UserData[key] or 0) + value
		if key == "exp" then
			while UserData.exp >= UserData.nextExp do
				UserData.ulevel = UserData.ulevel + 1
				UserData.exp = UserData.exp - UserData.nextExp
				UserData.nextExp = UserData.ulevel*50 - 50
				isLevelUp = true
			end
		end
	end
	
	function UserData.initLevel(level, exp)
	    UserData.ulevel = level
	    UserData.exp = exp
	    if level==1 then
    	    UserData.nextExp = 30
    	else
    	    UserData.nextExp = UserData.ulevel*50 - 50
    	end
		while UserData.exp >= UserData.nextExp do
			UserData.ulevel = UserData.ulevel + 1
			UserData.exp = UserData.exp - UserData.nextExp
			UserData.nextExp = UserData.ulevel*50 - 50
		end
	end
end