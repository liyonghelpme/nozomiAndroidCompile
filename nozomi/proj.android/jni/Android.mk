LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := game_shared

LOCAL_MODULE_FILENAME := libgame

LOCAL_SRC_FILES := hellocpp/main.cpp \
                   ../../Classes/AppDelegate.cpp \
					../../Classes/cocos2d_ext_tolua.cpp \
					../../Classes/cocos2dx_support/CCLuaEngine.cpp \
					../../Classes/cocos2dx_support/Cocos2dxLuaLoader.cpp \
					../../Classes/cocos2dx_support/LuaCocos2d.cpp \
					../../Classes/cocos2dx_support/tolua_fix.c \
					../../Classes/crypto/CCCrypto.cpp \
					../../Classes/crypto/base64/libb64.c \
					../../Classes/crypto/md5/md5.c \
					../../Classes/crypto/rsa/bigint.c \
					../../Classes/crypto/rsa/rsa.c \
					../../Classes/crypto/sha1/sha1.cpp \
					../../Classes/extend_actions/CCExtendActionInterval.cpp \
					../../Classes/extend_nodes/CCExtendNode.cpp \
					../../Classes/extend_nodes/CCExtendSprite.cpp \
					../../Classes/extend_nodes/CCTextInput.cpp \
					../../Classes/extend_nodes/CaeEffect.cpp \
					../../Classes/extend_nodes/Lightning.cpp \
					../../Classes/extend_shader/CCHSVShaderHandler.cpp \
					../../Classes/network/CCHttpRequest.cpp \
					../../Classes/network/CCHttpRequest_impl.cpp \

                   
LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../Classes  \
					$(LOCAL_PATH)/../../Classes/cocos2dx_support \
					$(LOCAL_PATH)/../../Classes/crypto \
					$(LOCAL_PATH)/../../Classes/crypto/base64 \
					$(LOCAL_PATH)/../../Classes/crypto/md5 \
					$(LOCAL_PATH)/../../Classes/crypto/rsa \
					$(LOCAL_PATH)/../../Classes/crypto/sha1 \
					$(LOCAL_PATH)/../../Classes/extend_actions \
					$(LOCAL_PATH)/../../Classes/extend_nodes \
					$(LOCAL_PATH)/../../Classes/extend_shader \
					$(LOCAL_PATH)/../../Classes/network \
					$(LOCAL_PATH)/../../Classes/platform \
					$(LOCAL_PATH)/../../../scripting/lua/lua \
					$(LOCAL_PATH)/../../../scripting/lua/tolua \





LOCAL_WHOLE_STATIC_LIBRARIES := cocos2dx_static cocosdenshion_static cocos_extension_static cocos_lua_static
            
include $(BUILD_SHARED_LIBRARY)

$(call import-module,CocosDenshion/android) \
$(call import-module,cocos2dx) \
$(call import-module,extensions) \
$(call import-module,scripting/lua/proj.android/jni)
