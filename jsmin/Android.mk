LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

LOCAL_SRC_FILES := ../../../../external/jsmin/jsmin.c
LOCAL_MODULE := jsmin
LOCAL_MODULE_TAGS := optional

include $(BUILD_HOST_EXECUTABLE)

