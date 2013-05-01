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
	//�����ʼλ��
	CCPoint m_beginPos;

	// ��꾫��   
    CCSprite *m_pCursorSprite;

	// ��궯��   
    CCAction *m_pCursorAction;  
                   
    // �������   
    CCPoint m_cursorPos;  
      
    // ���������   
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
      
    // �ж��Ƿ�����TextField��   
    bool isInTextField(CCPoint endPos);  
    // �õ�TextField����   
    CCRect getRect();  
      
    // �����뷨   
    void openIME();  
    // �ر����뷨   
    void closeIME(); 

	//�����ַ��������ƣ�һ�����������ַ�
    void setLimitNum(unsigned int limitNum);
    unsigned int getLimitNum();

	void setTouchPriority(int pri);
};

NS_CC_EXT_END

#endif //__CAESARS_NODE_CCTEXTINPUT_H__