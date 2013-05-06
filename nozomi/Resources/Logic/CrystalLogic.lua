CrystalLogic = {}

function CrystalLogic.computeCostByResource(type, value)
	if type=="food" or type=="oil" then
		if value>10000000 then
			return math.ceil(value/10000000*3000)
		elseif value>1000000 then
			return math.ceil(600+(3000-600)/9000000*(value-1000000))
		elseif value>100000 then
			return math.ceil(125+(600-125)/900000*(value-100000))
		elseif value>10000 then
			return math.ceil(25+(125-25)/90000*(value-10000))
		elseif value>1000 then
			return math.ceil(5+(25-5)/9000*(value-1000))
		else
			return math.ceil(0+(5-0)/1000*(value-0))
		end
	end
end

--need param cost and get
function CrystalLogic.buyCrystal(param)
	ResourceLogic.changeResource("crystal", param.get)
	display.closeDialog()
end

--need param cost and get and resource
function CrystalLogic.buyResource(param)
	ResourceLogic.changeResource("crystal", -param.cost)
	ResourceLogic.changeResource(param.resource, param.get)
	display.closeDialog()
end