Effect = {}

function Effect.createGatherEffect(dir, time)
    local p = CCParticleSystemQuad:create()
    p:setTotalParticles(40)
    p:setPositionType(kCCPositionTypeGrouped)
    p:setEmissionRate(40/0.3)
    p:setDuration(time)

    p:setEmitterMode(kCCParticleModeRadius)
    p:setLife(0.3) --越小运动越快
    p:setLifeVar(0.1)
    p:setStartSize(20) --根据具体图片
    p:setStartSizeVar(0)
    p:setEndSize(0)
    p:setEndSizeVar(0)

    p:setAngle(dir) --根据炮口位置设定
    p:setAngleVar(100) --调整吸收空间能量的幅度

    p:setStartRadius(20) --根据炮的相对大小调整吸引范围的大小
    p:setStartRadiusVar(5) --根据炮的大小调整 幅度
    p:setEndRadius(3)
    p:setEndRadiusVar(2)
    p:setRotatePerSecond(0) --每秒旋转角度
    
   -- p:setPosition(pos) --炮口的位置
    --p:setSourcePosition(pos)

    p:setStartColor(ccc4f(0, 0.05, 1, 1.0))
    p:setStartColorVar(ccc4f(0, 0, 0, 0.0))

    p:setEndColor(ccc4f(0, 0.05, 1.0, 1.0))
    p:setEndColorVar(ccc4f(0, 0, 0, 0.0))

    p:setBlendAdditive(true)
    p:setTexture(CCTextureCache:sharedTextureCache():addImage("images/effects/circle2.png"))
	return p
end

function Effect.createFlyEffect(dir, time)
    local p = CCParticleSystemQuad:create()
    p:setTotalParticles(1000)
    --p:setPositionType(kCCPositionTypeRelative)
    
    p:setDuration(-1)
    p:setEmissionRate(200)
    --从发射点到 目标点的运动时间的激光

    p:setLife(0.5) --尾巴拖动的长度
    --生命会导致 激光到后期就变细了 如何保证激光在路径上是不衰减的 ？ 因此构建一段粗细相同的激光比较好 startSize 和 endSize 一致就能构建直线的激光方法

    p:setLifeVar(0)
    p:setStartSize(30)
    p:setStartSizeVar(0)
    p:setEndSize(20)
    p:setEndSizeVar(0)

    p:setAngle(dir) --根据炮口的方向调整 角度
    p:setAngleVar(0)
    
    p:setPositionType(kCCPositionTypeGrouped)
    p:setEmitterMode(kCCParticleModeGravity)
    p:setSpeed(50) --初始速度
    p:setSpeedVar(0)
    
    --重力向X Y 调整激光的尾巴位置 角度190 Y 向上 使尾巴上扬起来 

    p:setStartColor(ccc4f(0, 0.05, 1, 1))
    p:setEndColor(ccc4f(0, 0.05, 1, 1))

    p:setBlendAdditive(true)
    p:setTexture(CCTextureCache:sharedTextureCache():addImage("images/effects/circle2.png"))

    return p
end

function Effect.createBombEffect(time)
    local p = CCParticleSystemQuad:create()
    p:setTotalParticles(200)
    p:setPositionType(kCCPositionTypeRelative)
    p:setEmitterMode(kCCParticleModeGravity)
    p:setDuration(time) --爆炸效果持续的时间

    p:setEmissionRate(200) --爆炸效果持续的时间
    p:setGravity(ccp(0, 0))
    p:setSpeed(30) --爆炸效果的速度 跟建筑范围相关 速度越大爆炸范围越大

    p:setRadialAccel(200) --爆炸最后的喷射速度
    p:setTangentialAccel(-80)

    p:setAngle(90)
    p:setAngleVar(360)

    p:setLife(0.3)
    p:setLifeVar(0.5)

    p:setStartSize(20) --开始的大小  飞行的大小 最终的大小 3个之间的比例关系
    p:setStartSizeVar(10)
    p:setEndSize(0)
    p:setEndSizeVar(0)

    p:setPosVar(ccp(10, 10))--爆炸初始范围

    p:setStartColor(ccc4f(0, 0.05, 1, 1))
    p:setStartColorVar(ccc4f(0, 0.45, 0, 0.31))
    p:setEndColor(ccc4f(0, 0.05, 1, 1))
    p:setBlendAdditive(true)
    p:setTexture(CCTextureCache:sharedTextureCache():addImage("images/effects/circle2.png"))
	return p
end

require "UI.Effect.Flame"
require "UI.Effect.Splash"