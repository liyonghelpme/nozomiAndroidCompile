PARAM = {
	loadingRotateTime=2000, loadingThunderTime=1100, mapInAnimate=500, fallTime=1000,
    flow1Time=5000, flow2Time=500, boxOnRiverTime = 1000, riverTime=2000, 
    soldierMoveTime = 2000, soldierCallTime=2000, 
    smallCloudTime=50000, bigCloudTime=70000, cloudRandomTime=5000, cloudInterval=6000, cloudRandomY=250, cloudMax = 10, 
    menuInTime=500, menuOutTime=600,
    mapScaleTime=700, mapIslandTime = 5000, mapIslandRandomFloor =5 , mapIslandRandomCeil = 15,
    mapCloudInterval = 6000, mapCloudMax = 8, mapBigCloudTime=60000, mapSmallCloudTime=40000, mapCloudRandomTime=5000, mapInitCloudNum=4;
    flyNodeTime=1000, flyMove=20,
    visitAniTime = 600,
    story1inteval = 200, story1time=7000, story2time=6000, story2inteval=200, story3time=4000, story4time=6000, herointeval=200,
    FlyTime=1000, FlyInteval=200, FlyObjR = 207, FlyObjG = 59, FlyObjB = 125, fallX1=50, fallX2=30, fallY1=100, fallY2=30, baseX1=100, baseY1=200, baseX2=100, baseY2=100
}

function getParam(key, default)
	return PARAM[key] or default
end