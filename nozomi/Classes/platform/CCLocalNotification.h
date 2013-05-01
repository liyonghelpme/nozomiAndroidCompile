#ifndef __CAESARS_PLATFORM_CCLOCALNOTIFICATION_H__
#define __CAESARS_PLATFORM_CCLOCALNOTIFICATION_H__

#include "cocos2d_ext_const.h"

NS_CC_EXT_BEGIN

class CCLocalNotification{
public:
	static void clearAllNotification();
	static void pushNotification();
};
NS_CC_EXT_END

#endif //__CAESARS_PLATFORM_CCLOCALNOTIFICATION_H__