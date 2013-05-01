#include "CCExtendSprite.h"

#include "textures/CCTextureCache.h"

NS_CC_EXT_BEGIN


CCExtendSprite::CCExtendSprite(void)
:m_pHSVHandler(NULL)
{
}

CCExtendSprite::~CCExtendSprite(void)
{
	if(m_pHSVHandler!=NULL)
		delete m_pHSVHandler;
}

void CCExtendSprite::setHueOffset(int offset, bool isRecur)
{
	if(m_pHSVHandler==NULL){
		m_pHSVHandler = new CCHSVShaderHandler();
	}
	m_pHSVHandler->setHueOffset(this, offset, isRecur);
}

void CCExtendSprite::setSatOffset(int offset, bool isRecur)
{
	if(m_pHSVHandler==NULL){
		m_pHSVHandler = new CCHSVShaderHandler();
	}
	m_pHSVHandler->setSatOffset(this, offset, isRecur);
}

void CCExtendSprite::setValOffset(int offset, bool isRecur)
{
	if(m_pHSVHandler==NULL){
		m_pHSVHandler = new CCHSVShaderHandler();
	}
	m_pHSVHandler->setValOffset(this, offset, isRecur);
}

void CCExtendSprite::setHSVParentOffset(int hoff, int soff, int voff)
{
	if(m_pHSVHandler==NULL){
		m_pHSVHandler = new CCHSVShaderHandler();
	}
	m_pHSVHandler->setHSVParentOffset(this, hoff, soff, voff);
}

void CCExtendSprite::addChild(CCNode *child, int zOrder, int tag)
{
	if (m_pHSVHandler!=NULL && m_pHSVHandler->isRecur())
	{
		m_pHSVHandler->recurSetShader(this, child);
	}
	CCSprite::addChild(child, zOrder, tag);
}

CCExtendSprite* CCExtendSprite::create(const char* pszFileName)
{
    CCExtendSprite *pobSprite = new CCExtendSprite();
    if (pobSprite && pobSprite->initWithFile(pszFileName))
    {
        pobSprite->autorelease();
        return pobSprite;
    }
    CC_SAFE_DELETE(pobSprite);
    return NULL;
}

bool CCExtendSprite::initWithFile(const char* pszFilename)
{
	CCAssert(pszFilename != NULL, "Invalid filename for sprite");

    CCTexture2D *pTexture = CCTextureCache::sharedTextureCache()->addImage(pszFilename, true);
    if (pTexture)
    {
        CCRect rect = CCRectZero;
        rect.size = pTexture->getContentSize();
        return initWithTexture(pTexture, rect);
    }
    return false;
}

bool CCExtendSprite::isAlphaTouched(CCPoint nodePoint)
{
	CCPoint basePoint = this->getTextureRect().origin;
	return this->getTexture()->getAlphaAtPoint(basePoint.x + nodePoint.x, basePoint.y + nodePoint.y) == 0;
}

NS_CC_EXT_END