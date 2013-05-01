#include "CCTextInput.h"
#include "CCDirector.h"
#include "touch_dispatcher\CCTouchDispatcher.h"

NS_CC_EXT_BEGIN

CCTextInput::CCTextInput()
{
	CCTextFieldTTF();
    
    m_pCursorSprite = NULL;
    m_pCursorAction = NULL;
    
    m_pInputText = NULL;
    m_limitNum = 30;

	priority=-128;
}

CCTextInput::~CCTextInput()
{

}

void CCTextInput::onEnter()
{
	CCTextFieldTTF::onEnter();
	CCDirector::sharedDirector()->getTouchDispatcher()->addTargetedDelegate(this, this->priority, false);
    this->setDelegate(this);
}

void CCTextInput::onExit()
{
    this->detachWithIME();
    CCTextFieldTTF::onExit();
    CCDirector::sharedDirector()->getTouchDispatcher()->removeDelegate(this);
}

unsigned int CCTextInput::getLimitNum()
{
    return m_limitNum;
}
//设置字符长度
void CCTextInput::setLimitNum(unsigned int limitNum)
{
    m_limitNum = limitNum;
}

void CCTextInput::setTouchPriority(int pri)
{
	this->priority = pri;
}

void CCTextInput::openIME()
{
    m_pCursorSprite->setVisible(true);
    this->attachWithIME();
}

void CCTextInput::closeIME()
{
    m_pCursorSprite->setVisible(false);
    this->detachWithIME();
}

bool CCTextInput::isInTextField(CCPoint endPos)
{   
    CCPoint pTouchPos = this->convertToNodeSpace(endPos);
	CCSize size = m_designSize; 
	if (pTouchPos.x>0 && pTouchPos.y>0 && pTouchPos.x < size.width && pTouchPos.y < size.height)
		return true;
    return false;
}

void CCTextInput::ccTouchEnded(CCTouch *pTouch, CCEvent *pEvent)
{
    CCPoint endPos = pTouch->getLocationInView();
    endPos = CCDirector::sharedDirector()->convertToGL(endPos);
    // 判断是打开输入法还是关闭输入法
    isInTextField(endPos) ? openIME() : closeIME();
}

bool CCTextInput::onTextFieldAttachWithIME(cocos2d::CCTextFieldTTF *pSender)
{
    if (m_pInputText->empty()) {
        return false;
    }
    
    m_pCursorSprite->setPositionX(getContentSize().width);
    
    return false;
}

bool CCTextInput::onTextFieldInsertText(cocos2d::CCTextFieldTTF *pSender, const char *text, int nLen)
{    
    std::string tempStr = m_pInputText->substr();
    tempStr.append(text);
    if (tempStr.length() > m_limitNum) {
        return true;
    }
    
    m_pInputText->append(text);
    
    
    setString(m_pInputText->c_str());
    
    m_pCursorSprite->setPositionX(getContentSize().width);
    
    return true;
}

bool CCTextInput::onTextFieldDeleteBackward(cocos2d::CCTextFieldTTF *pSender, const char *delText, int nLen)
{
    m_pInputText->resize(m_pInputText->size() - nLen);
    CCLog(m_pInputText->c_str());
    
    setString(m_pInputText->c_str());
    
    m_pCursorSprite->setPositionX(getContentSize().width);

    if (m_pInputText->empty()) {
        m_pCursorSprite->setPositionX(0);
    }
    
    return true;
}

bool CCTextInput::onTextFieldDetachWithIME(cocos2d::CCTextFieldTTF *pSender)
{
    return false;
}

bool CCTextInput::ccTouchBegan(cocos2d::CCTouch *pTouch, cocos2d::CCEvent *pEvent)
{    
    m_beginPos = pTouch->getLocationInView();
    m_beginPos = CCDirector::sharedDirector()->convertToGL(m_beginPos);
    
	if(this->isInTextField(m_beginPos)){
	    return true;
	}
	else{
		closeIME();
		return false;
	}
}

CCRect CCTextInput::getRect()
{
    CCSize size = m_designSize;
   
    CCRect rect = CCRectMake(0 - size.width * getAnchorPoint().x, 0 - size.height * getAnchorPoint().y, size.width, size.height);
    return  rect;
}

CCTextInput* CCTextInput::create(const char* placeHolder, const char *fontName, float fontSize, CCSize designSize, int align, unsigned int limit)
{
	CCTextInput *pRet = new CCTextInput();
    
    if(pRet && pRet->initWithString("", fontName, fontSize, designSize, kCCTextAlignmentLeft))
    {
        pRet->autorelease();
        if (placeHolder!=NULL)
        {
            pRet->setPlaceHolder(placeHolder);
        }
        
		pRet->m_designSize = designSize;
		pRet->setLimitNum(limit);
		int* pixels = new int[4*(int)(fontSize)];

		for (int i=0; i<(int)fontSize; ++i) {
			for (int j=0; j<4; ++j) {
				 pixels[i*4+j] = 0xffffffff;
			}
		}

		CCTexture2D *texture = new CCTexture2D();
		texture->initWithData(pixels, kCCTexture2DPixelFormat_RGB888, 1, 1, CCSizeMake(4, fontSize));
		delete[] pixels;

		pRet->m_pCursorSprite = CCSprite::createWithTexture(texture);
		CCSize winSize = pRet->getContentSize();
		pRet->m_cursorPos = CCPointMake(0, winSize.height / 2);
		pRet->m_pCursorSprite->setPosition(pRet->m_cursorPos);
		pRet->addChild(pRet->m_pCursorSprite);
    
		pRet->m_pCursorAction = CCRepeatForever::create((CCActionInterval *) CCSequence::create(CCFadeOut::create(0.25f), CCFadeIn::create(0.25f), NULL));
    
		pRet->m_pCursorSprite->runAction(pRet->m_pCursorAction);
    
		pRet->m_pInputText = new std::string();
        
        return pRet;
    }
    
    CC_SAFE_DELETE(pRet);
    
    return NULL;

}

NS_CC_EXT_END