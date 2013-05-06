Build = {}

require "Mould.Build.BuildView"
require "Mould.Build.BuildMould"
require "Mould.Build.Producer"
require "Mould.Build.OilFactory"
require "Mould.Build.FoodFactory"
require "Mould.Build.Storage"
require "Mould.Build.OilStorage"
require "Mould.Build.FoodStorage"
require "Mould.Build.SpecialStorage"
require "Mould.Build.BuilderRoom"
require "Mould.Build.House"
require "Mould.Build.Camp"
require "Mould.Build.Barrack"
require "Mould.Build.Laboratory"
require "Mould.Build.Defense"
require "Mould.Build.Cannon"
require "Mould.Build.ArcherTower"
require "Mould.Build.Mortar"
require "Mould.Build.WizardTower"
require "Mould.Build.AirDefense"
require "Mould.Build.Hidden"
require "Mould.Build.Xbow"
require "Mould.Build.Town"
require "Mould.Build.Clan"
require "Mould.Build.Nozomi"
require "Mould.Build.Wall"
require "Mould.Build.Obstacle"
require "Mould.Build.Trap"

do	
	local num_cache = {}
	function Build.init()
		num_cache = {}
	end
	
	function Build.incBuild(bid)
		num_cache[bid] = (num_cache[bid] or 0) + 1
	end
	
	function Build.decBuild(bid)
		num_cache[bid] = (num_cache[bid] or 0) - 1
	end
	
	function Build.getBuildNum(bid)
		return num_cache[bid] or 0
	end
	
	function Build.getBuildStoreInfo(param)
		if type(param) == "number" then
			local curnum = num_cache[param] or 0
			local level = 1
			if param==2004 then level = curnum+1 end
			local ret = copyData(StaticData.getBuildData(param, level))
			local info = StaticData.getBuildInfo(param)
			
			ret.info = info.info
			ret.name = info.name
			ret.totalMax = info.totalMax
			ret.levelLimit = info.levelLimits[UserData.level]
			ret.buildsNum = curnum
			
			for i=UserData.level+1, 9 do
				if info.levelLimits[i]>info.levelLimits[i-1] then
					ret.nextLevel = i
					break
				end
			end
			return ret
		elseif type(param) == "table" then
			local rlist = {}
			for i=1, #param do
				rlist[i] = Build.getBuildStoreInfo(param[i])
			end
			return rlist
		end
	end
	
	pluginMap={[2000]={OilFactory, "oil"}, [2002]={FoodFactory, "food"},
				[2001]={OilStorage, "oil"}, [2003]={FoodStorage, "food"}, [2004]={BuilderRoom, "builder"}, [2005]={House, "person"}, [2006]={SpecialStorage, "food"}, 
				[1000]={Camp}, [1001]={Barrack}, [1002]={Laboratory}, 
				[3000]={Cannon}, [3001]={ArcherTower}, [3002]={Mortar}, [3003]={WizardTower}, [3004]={AirDefense}, [3005]={Hidden}, [3007]={Xbow}, 
				[3006]={Wall},
				[4000]={Obstacle}, [4001]={Obstacle}, [4002]={Obstacle}, [4003]={Obstacle}, [4004]={Obstacle}, [4005]={Obstacle}, [4006]={Obstacle}, [4007]={Obstacle}, [4008]={Obstacle}, [4009]={Obstacle}, [4010]={Obstacle}, [4011]={Obstacle}, [4012]={Obstacle}, [4013]={Obstacle}, [4014]={Obstacle}, [4015]={Obstacle}, [4016]={Obstacle}, [4017]={Obstacle}, [4018]={Obstacle}, 
				[0]={Town}, [1]={Nozomi}, [2]={Clan},
				[5000]={Trap}, [5001]={Trap}, [5002]={Trap}
				}
				
	local function createBuild(bid, scene, setting)
		local build = nil
		if pluginMap[bid] then
			local pluginItem = pluginMap[bid]
			build = pluginItem[1].new(bid, setting, pluginItem[2])
		else
			build = BuildMould.new(bid, setting)
		end
		
		if scene then
			build:addToScene(scene, setting)
		end
		return build
	end
	
	Build.create = createBuild
end