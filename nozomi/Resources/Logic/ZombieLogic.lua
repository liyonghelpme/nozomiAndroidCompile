ZombieLogic = {}

function ZombieLogic.init()
	ZombieLogic.max=0
	ZombieLogic.num=0
	ZombieLogic.person = 0
	ZombieLogic.zombie = 160
	if ZombieLogic.isGuide then
		ZombieLogic.zombie = 3
	end
	ZombieLogic.losePerson = 0
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