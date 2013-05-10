CrystalLogic = {}

function CrystalLogic.computeCostByResource(type, value)
	if type=="food" or type=="oil" then
		if value>10000000 then
			return math.floor(value/10000000*3000+0.5)
		elseif value>1000000 then
			return math.floor(600+(3000-600)/9000000*(value-1000000)+0.5)
		elseif value>100000 then
			return math.floor(125+(600-125)/900000*(value-100000)+0.5)
		elseif value>10000 then
			return math.floor(25+(125-25)/90000*(value-10000)+0.5)
		elseif value>1000 then
			return math.floor(5+(25-5)/9000*(value-1000)+0.5)
		else
			return math.floor(0+(5-0)/1000*(value-0)+0.5)
		end
	elseif type=="person" then
		return value
	end
end

function CrystalLogic.computeCostByTime(timeInSecond)
    if timeInSecond<60 then
        return 1
    elseif timeInSecond<3600 then
        return 1+math.floor((20-1)*(timeInSecond-60)/(3600-60))
    elseif timeInSecond<86400 then
        return 20+math.floor((260-20)*(timeInSecond-3600)/(86400-3600))
    else
        return 260+math.floor((1000-260)*(timeInSecond-86400)/(604800-86400))
    end
end

--need param cost and get
function CrystalLogic.buyCrystal(param)
	ResourceLogic.changeResource("crystal", param.get)
	display.closeDialog()
end

--need param cost and get and resource
function CrystalLogic.buyResource(param)
    if param.force then
        if CrystalLogic.changeCrystal(-param.cost) then
            ResourceLogic.changeResource(param.resource, param.get)
            --display.closeDialog()
        end
    else
        local p = copyData(param)
        p.force = true
        local resourceName = StringManager.getString(p.resource)
        display.showDialog(AlertDialog.new(StringManager.getFormatString("titleBuyObject", {name=resourceName}), StringManager.getFormatString("textBuyResource", {num=p.get, resource=resourceName}), {callback=CrystalLogic.buyResource, param=p, crystal=p.cost}))
    end
end

function CrystalLogic.changeCrystal(cost)
    if cost<0 and UserData.crystal+cost<0 then
        display.showDialog(AlertDialog.new(StringManager.getString("titleNoCrystal"), StringManager.getString("textNoCrystal"), {callback=StoreDialog.show, param="treasure", okText=StringManager.getString("buttonEnterShop"), img="images/crystal2.png", lineOffset=-12}))
        return false
    else
        UserData.crystal = UserData.crystal + cost
        return true
    end
end