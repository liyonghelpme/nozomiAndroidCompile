LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := cocos_curl_static
LOCAL_MODULE_FILENAME := libcurl
#LOCAL_SRC_FILES := libs/$(TARGET_ARCH_ABI)/libcurl.a
LOCAL_SRC_FILES := libs/$(TARGET_ARCH_ABI)/libcurl.so
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/include
include $(PREBUILT_SHARED_LIBRARY)
