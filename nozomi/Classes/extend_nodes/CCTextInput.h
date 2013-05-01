#ifndef __CAESARS_NODE_CCTEXTINPUT_H__
#define __CAESARS_NODE_CCTEXTINPUT_H__

#include "cocos2d_ext_const.h"
#include "sprite_nodes\CCSprite.h"
#include "actions\CCActionInterval.h"
#include "text_input_node\CCTextFieldTTF.h"

NS_CC_EXT_BEGIN

class CCTextInput: public CCTextFieldTTF, public CCTouchDelegate, public CCTextFieldDelegate
{
private:
	//点击开始位置
	CCPoint m_beginPos;

	// 光标精灵   
    CCSprite *m_pCursorSprite;

	// 光标动画   
    CCAction *m_pCursorAction;  
                   
    // 光标坐标   
    CCPoint m_cursorPos;  
      
    // 输入框内容   
    std::string *m_pInputText;

	CCSize m_designSize;

	unsigned int m_limitNum;

	int priority;
public:
	CCTextInput();
	~CCTextInput();

	static CCTextInput* create(const char* placeHolder, const char *fontName, float fontSize, CCSize designSize, int align, unsigned int limit);

	void onEnter();
	void onExit();

	virtual bool onTextFieldAttachWithIME(CCTextFieldTTF *pSender);  
    virtual bool onTextFieldDetachWithIME(CCTextFieldTTF * pSender);  
    virtual bool onTextFieldInsertText(CCTextFieldTTF * pSender, const char * text, int nLen);  
    virtual bool onTextFieldDeleteBackward(CCTextFieldTTF * pSender, const char * delText, int nLen);  
      
    // CCLayer Touch   
    bool ccTouchBegan(CCTouch *pTouch, CCEvent *pEvent);  
    void ccTouchEnded(CCTouch *pTouch, CCEvent *pEvent);  
      
    // 判断是否点击在TextField处   
    bool isInTextField(CCPoint endPos);  
    // 得到TextField矩形   
    CCRect getRect();  
      
    // 打开输入法   
    void openIME();  
    // 关闭输入法   
    void closeIME(); 

	//设置字符长度限制，一个汉字三个字符
    void setLimitNum(unsigned int limitNum);
    unsigned int getLimitNum();

	void setTouchPriority(int pri);
};

NS_CC_EXT_END

#endif //__CAESARS_NODE_CCTEXTINPUT_H__