ZombieLogic = {}

function ZombieLogic.init()
	ZombieLogic.max=0
	ZombieLogic.num=0
	ZombieLogic.person = 0
	ZombieLogic.wave = 3
	if ZombieLogic.isGuide then
		ZombieLogic.wave = 1
	end
	ZombieLogic.initZombies()
	ZombieLogic.losePerson = 0
	ZombieLogic.buildNum = 0
	ZombieLogic.destroyNum = 0
	ZombieLogic.percent = 100
	ZombieLogic.stars = 3
	ZombieLogic.killZombies = {0,0,0,0,0,0,0,0}
end

local ZOMBIE_SETTINGS = {{{6,0,0,0,0,0,0,0},{6,8,0,0,0,0,0,0},{10,10,0,0,0,0,0,0}},{{10,0,20,0,0,0,0,0},{10,12,0,0,0,0,0,0},{10,10,10,0,0,0,0,0}},{{10,12,0,0,0,0,0,0},{16,16,18,0,0,0,0,0},{16,18,18,0,18,0,0,0}},{{8,8,10,0,0,0,0,0},{14,14,16,0,16,0,0,0},{16,16,18,18,18,0,0,0}},{{8,8,10,0,10,0,0,0},{16,16,16,18,18,0,0,0},{20,20,20,20,20,20,0,0}},{{8,8,8,10,8,0,0,0},{16,16,16,16,16,18,0,0},{20,20,20,20,20,20,20,0}},{{8,8,8,10,8,10,0,0},{18,18,18,18,18,18,18,0},{22,22,22,22,22,22,24,24}},{{10,10,10,12,10,12,0,0},{20,20,20,22,22,22,22,0},{26,26,26,26,26,26,26,28}},{{12,12,12,14,12,14,0,0},{24,24,24,26,26,26,26,0},{30,30,30,32,32,32,32,32}}}

function ZombieLogic.initZombies()
    ZombieLogic.zombies = {}
    local num = 0
    local zombies 
    if ZombieLogic.isGuide then
        zombies = {3}
    else
        
        zombies = getParam("attackWaves", ZOMBIE_SETTINGS)[UserData.level][4-ZombieLogic.wave]
    end
    local zombieIds = {}
    for i=1, #zombies do
        if zombies[i]>0 then
            ZombieLogic.zombies[i] = zombies[i]
            num = num + zombies[i]
            table.insert(zombieIds, i)
        end
    end
    ZombieLogic.zombieIds = zombieIds
    ZombieLogic.zombie = num
    ZombieLogic.areas = {1, 2, 3, 4, 5, 6}
    if ZombieLogic.wave==3 then
        for i=1, 3 do
            table.remove(ZombieLogic.areas, math.random(#(ZombieLogic.areas)))
        end
    end
end

function ZombieLogic.getOneZombie()
    local rid = math.random(#(ZombieLogic.zombieIds))
    ZombieLogic.zombie = ZombieLogic.zombie-1
    local zid = ZombieLogic.zombieIds[rid]
    ZombieLogic.zombies[zid] = ZombieLogic.zombies[zid] - 1
    if ZombieLogic.zombies[zid]==0 then
        table.remove(ZombieLogic.zombieIds, rid)
    end
    return zid
end

function ZombieLogic.getOneZombie()
    local rid = math.random(#(ZombieLogic.zombieIds))
    ZombieLogic.zombie = ZombieLogic.zombie-1
    local zid = ZombieLogic.zombieIds[rid]
    ZombieLogic.zombies[zid] = ZombieLogic.zombies[zid] - 1
    if ZombieLogic.zombies[zid]==0 then
        table.remove(ZombieLogic.zombieIds, rid)
    end
    return zid
end

function ZombieLogic.getOneZombieArea()
    return ZombieLogic.areas[math.random(#(ZombieLogic.areas))]
end

function ZombieLogic.destroyBuild(bid)
    local destroyNum = ZombieLogic.destroyNum + 1
    if ZombieLogic.destroyNum*2<ZombieLogic.buildNum and destroyNum*2>=ZombieLogic.buildNum then
        ZombieLogic.stars = ZombieLogic.stars - 1
    end
    if bid==TOWN_BID then
        ZombieLogic.stars = ZombieLogic.stars - 1
    end
    if destroyNum==ZombieLogic.buildNum then
        ZombieLogic.stars = ZombieLogic.stars - 1
        ZombieLogic.battleEnd = true
    end
    ZombieLogic.destroyNum = destroyNum
    ZombieLogic.percent = 100-math.floor(100*destroyNum/ZombieLogic.buildNum)
end

function ZombieLogic.changeBuilderMax(value)
	ZombieLogic.max=ZombieLogic.max+value
end

function ZombieLogic.changeBuilder(value)
	ZombieLogic.num=ZombieLogic.num+value
end

function ZombieLogic.getBuilderMax()
	return ZombieLogic.max
end

function ZombieLogic.getBuilder()
	return ZombieLogic.num
end

function ZombieLogic.changePerson(value)
	ZombieLogic.person = ZombieLogic.person + value
	if value<0 then
		ZombieLogic.losePerson = ZombieLogic.losePerson + value
	end
end

function ZombieLogic.getPerson()
	return ZombieLogic.person
end

function ZombieLogic.getZombie()
	return ZombieLogic.zombie
end

function ZombieLogic.incZombieNumber(zid)
    ZombieLogic.killZombies[zid] = ZombieLogic.killZombies[zid]+1
end

function ZombieLogic.getBattleResult()
	local result = {stars = ZombieLogic.stars, percent=ZombieLogic.percent, losePerson=ZombieLogic.losePerson, killZombies=ZombieLogic.killZombies}
	return result
end