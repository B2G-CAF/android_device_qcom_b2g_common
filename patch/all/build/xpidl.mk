
#
# Makefile to hook into Android.mk for building XPCOM IDLs
# and typelibs, along with installing build artifacts into Gecko
#

ifneq ($(LOCAL_XPCOM_IDLS),)

XPIDL_MODULE := $(LOCAL_MODULE)
# The directory where this component's intermediates will be put by Android build system
XPIDL_MODULE_OBJDIR := $(TARGET_OUT_INTERMEDIATES)/SHARED_LIBRARIES/$(XPIDL_MODULE)_intermediates
# The directory where all the objs generated by idl compilation will go
XPIDL_OUT := $(XPIDL_MODULE_OBJDIR)/xpidl_obj

# Home directory of the module source
XPIDL_PATH := $(LOCAL_PATH)

# Make sure Gecko is built prior to the component
LOCAL_REQUIRED_MODULES := $(LOCAL_REQUIRED_MODULES) gecko

# Add Gecko headers to include path
LOCAL_C_INCLUDES := $(LOCAL_C_INCLUDES) $(ANDROID_PRODUCT_OUT)/obj/objdir-gecko/dist/include
# Standard libraries required by all XPCOM components
LOCAL_SHARED_LIBRARIES := $(LOCAL_SHARED_LIBRARIES) libxpcom
LOCAL_STATIC_LIBRARIES := $(LOCAL_STATIC_LIBRARIES) libxpcomglue_s libmozalloc
# Gecko locations
GECKO_DIR := $(ANDROID_BUILD_TOP)/gecko
GECKO_OBJDIR := $(ANDROID_PRODUCT_OUT)/obj/objdir-gecko
LIBXUL_DIST := $(GECKO_OBJDIR)/dist

# Flags to be used by idl compilation
XPIDL_FLAGS := -I$(XPIDL_PATH) -I$(LIBXUL_DIST)/idl

xpidl_prereqs:
	@mkdir -p $(XPIDL_OUT)

XPIDL_DEPS := $(TARGET_OUT_INTERMEDIATES)/lib/libxpcom.so \
              $(LIBXUL_DIST)/sdk/bin/header.py \
              $(LIBXUL_DIST)/sdk/bin/typelib.py \
              $(LIBXUL_DIST)/sdk/bin/xpidl.py \

PLY_INCLUDE := -I$(GECKO_DIR)/other-licenses/ply

# When used within make target rule, prints out the
# filename of the first dependency
REPORT_BUILD = @echo $(notdir $<)

# When used within make target rule, expands the first pre-requisite
# to its absolute path.
CURRENT_IDLS = $(abspath $<)

PYTHON := python
PYTHON_PATH := $(PYTHON) $(GECKO_DIR)/config/pythonpath.py
XPIDL_LINK := $(PYTHON) $(LIBXUL_DIST)/sdk/bin/xpt.py link
FINAL_TARGET := $(LIBXUL_DIST)/bin

INSTALL := install
INSTALL_FLAGS := -m 644

# Make the module being built by Android.mk depend on the following:
# 1. The .h corresponding to the .idls found in the directory
# 2. The corresponding .xpt files
# 3. The overall module .xpt file
# 4. The export rules to copy idls and headers to $(LIBXUL_DIST)
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_ADDITIONAL_DEPENDENCIES) $(patsubst %.idl,$(XPIDL_OUT)/%.h,$(LOCAL_XPCOM_IDLS))
LOCAL_ADDITIONAL_DEPENDENCIES :=	$(LOCAL_ADDITIONAL_DEPENDENCIES) $(patsubst %.idl,$(XPIDL_OUT)/%.xpt,$(LOCAL_XPCOM_IDLS))
LOCAL_ADDITIONAL_DEPENDENCIES :=	$(LOCAL_ADDITIONAL_DEPENDENCIES) $(XPIDL_OUT)/$(XPIDL_MODULE).xpt
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_ADDITIONAL_DEPENDENCIES) export_headers export_idls

$(XPIDL_OUT)/%.h: $(XPIDL_PATH)/%.idl $(XPIDL_DEPS) xpidl_prereqs
	$(warning XPIDL_OUT: $(XPIDL_OUT), LOCAL_MODULE: $(LOCAL_MODULE))
	$(warning XPIDL_PATH is $(XPIDL_PATH))
	$(REPORT_BUILD)
	$(PYTHON_PATH) $(PLY_INCLUDE) $(LIBXUL_DIST)/sdk/bin/header.py $(XPIDL_FLAGS) $(CURRENT_IDLS) -o $@

# generate intermediate .xpt files into $(XPIDL_OUT), then link
# into $(XPIDL_MODULE).xpt and export it to $(FINAL_TARGET)/components.
$(XPIDL_OUT)/%.xpt: $(XPIDL_PATH)/%.idl $(XPIDL_DEPS) xpidl_prereqs
	$(REPORT_BUILD)
	$(PYTHON_PATH) $(PLY_INCLUDE) -I$(GECKO_DIR)/xpcom/typelib/xpt/tools $(LIBXUL_DIST)/sdk/bin/typelib.py $(XPIDL_FLAGS) $(CURRENT_IDLS) -o $@

$(XPIDL_OUT)/$(XPIDL_MODULE).xpt: $(patsubst %.idl,$(XPIDL_OUT)/%.xpt,$(LOCAL_XPCOM_IDLS))
	$(XPIDL_LINK) $(XPIDL_OUT)/$(XPIDL_MODULE).xpt $(patsubst %.idl,$(XPIDL_OUT)/%.xpt,$(LOCAL_XPCOM_IDLS))
	$(INSTALL) $(INSTALL_FLAGS) $(XPIDL_OUT)/$(XPIDL_MODULE).xpt $(FINAL_TARGET)/components
	@$(PYTHON) $(GECKO_DIR)/config/buildlist.py $(FINAL_TARGET)/components/interfaces.manifest "interfaces $(XPIDL_MODULE).xpt"
	@$(PYTHON) $(GECKO_DIR)/config/buildlist.py $(FINAL_TARGET)/chrome.manifest "manifest components/interfaces.manifest"
	@$(PYTHON) $(GECKO_DIR)/config/buildlist.py $(FINAL_TARGET)/chrome.manifest "manifest components/$(XPIDL_MODULE).manifest"

include $(BUILD_SHARED_LIBRARY)

# export .idl files to dist idl dir
export_idls: $(XPIDL_PATH)/$(LOCAL_XPCOM_IDLS) $(LIBXUL_DIST)/idl
	$(INSTALL) $(INSTALL_FLAGS) $^

export_headers: $(XPIDL_OUT)/$(patsubst %.idl,%.h, $(LOCAL_XPCOM_IDLS)) $(LIBXUL_DIST)/include
	$(INSTALL) $(INSTALL_FLAGS) $^


endif # LOCAL_XPCOM_IDLS