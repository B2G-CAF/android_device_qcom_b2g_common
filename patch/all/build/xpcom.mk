#
# Makefile to hook into Android.mk for building XPCOM components, IDLs
# and typelibs, along with installing into Gecko
#

# Setting up module name and directories
# Name of module
LOCAL_XPCOM_MODULE := $(LOCAL_MODULE)
# Home directory of the module source
LOCAL_XPIDL_PATH := $(LOCAL_PATH)
# The directory where this component's intermediates will be put by Android build system
LOCAL_XPCOM_MODULE_OBJDIR := $(TARGET_OUT_INTERMEDIATES)/SHARED_LIBRARIES/$(LOCAL_XPCOM_MODULE)_intermediates
# The directory where all the objs generated by idl compilation will go
LOCAL_XPIDL_OUT := $(LOCAL_XPCOM_MODULE_OBJDIR)/xpidl_obj

# Do sanity checks on makefile and directory content
ifeq (,$(strip $(LOCAL_XPCOM_MODULE_UUID)))
$(error LOCAL_XPCOM_MODULE_UUID must be defined)
endif

# Add Gecko as a dependency of this module.
LOCAL_REQUIRED_MODULES := $(LOCAL_REQUIRED_MODULES) gecko
# Add Gecko headers to include path
LOCAL_C_INCLUDES := $(LOCAL_C_INCLUDES) $(ANDROID_PRODUCT_OUT)/obj/objdir-gecko/dist/include $(LOCAL_XPIDL_OUT)

# Compiler flags required by many Gecko libraries/sources
LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -std=c++0x
LOCAL_CFLAGS := $(LOCAL_CFLAGS) -D__STDC_INT64__ -D__STDC_LIMIT_MACROS

# Gecko locations
GECKO_DIR := $(ANDROID_BUILD_TOP)/gecko
GECKO_OBJDIR := $(ANDROID_PRODUCT_OUT)/obj/objdir-gecko
LIBXUL_DIST := $(GECKO_OBJDIR)/dist

# Flags to be used by idl compilation
LOCAL_XPIDL_FLAGS := -I$(LOCAL_XPIDL_PATH) -I$(LIBXUL_DIST)/idl

# Although we added Gecko as a dependency, that only prevents the link step
# from happening until Gecko is built. But the IDL generators and other
# headers have no make dependency on Gecko and will fall over in
# parallel make. Add the define below as a pre-req to every Gecko file and path
# that we depend on
DEPENDS_ON_GECKO := $(TARGET_OUT)/b2g/distribution

$(LOCAL_XPCOM_MODULE)-xpidl_prereqs:
	@mkdir -p $(LOCAL_XPIDL_OUT)

XPIDL_DEPS := $(LIBXUL_DIST)/sdk/bin/header.py \
              $(LIBXUL_DIST)/sdk/bin/typelib.py \
              $(LIBXUL_DIST)/sdk/bin/xpidl.py \


$(LIBXUL_DIST)/sdk/bin/header.py: $(DEPENDS_ON_GECKO)
$(LIBXUL_DIST)/sdk/bin/typelib.py: $(DEPENDS_ON_GECKO)
$(LIBXUL_DIST)/sdk/bin/xpidl.py: $(DEPENDS_ON_GECKO)

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

INSTALL := install
INSTALL_FLAGS := -m 644

# Make gecko library dependencies work with Android.mk rule
# Copy them to where Android build system expects to find them
define add-notice-static-dep
NOTICE-TARGET-STATIC_LIBRARIES-$(1):
endef

$(foreach lib,$(LOCAL_XPCOM_STATIC_LIBRARIES), $(eval $(call add-notice-static-dep,$(lib))))

install_gecko_libs: $(DEPENDS_ON_GECKO)
	$(foreach lib,$(LOCAL_XPCOM_STATIC_LIBRARIES),\
		mkdir -p $(TARGET_OUT_INTERMEDIATES)/STATIC_LIBRARIES/$(lib)_intermediates && \
		cp $(GECKO_OBJDIR)/dist/lib/$(lib).a $(TARGET_OUT_INTERMEDIATES)/STATIC_LIBRARIES/$(lib)_INTERMEDIATES && \
		cp $(GECKO_OBJDIR)/dist/lib/$(lib).a $(TARGET_OUT_INTERMEDIATES)/lib;)
	$(foreach lib,$(LOCAL_XPCOM_SHARED_LIBRARIES),\
		mkdir -p $(TARGET_OUT_INTERMEDIATES)/SHARED_LIBRARIES/$(lib)_INTERMEDIATES && \
		cp $(GECKO_OBJDIR)/dist/lib/$(lib).so $(TARGET_OUT_INTERMEDIATES)/SHARED_LIBRARIES/$(lib)_INTERMEDIATES && \
		cp $(GECKO_OBJDIR)/dist/lib/$(lib).so $(TARGET_OUT_INTERMEDIATES)/lib;)

LOCAL_SHARED_LIBRARIES := $(LOCAL_SHARED_LIBRARIES) $(LOCAL_XPCOM_SHARED_LIBRARIES)
LOCAL_STATIC_LIBRARIES := $(LOCAL_STATIC_LIBRARIES) $(LOCAL_XPCOM_STATIC_LIBRARIES)

# Make the module being built by Android.mk depend on the following:
# 1. The rule to copy gecko libs to Android objdir
# 2. The .h corresponding to the .idls found in the directory
# 3. The corresponding .xpt files
# 4. The overall module .xpt file
# 5. The export rules to copy idls and headers to $(LIBXUL_DIST)
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_ADDITIONAL_DEPENDENCIES) install_gecko_libs

# Dependencies for IDL files
ifneq (,$(strip $(LOCAL_XPCOM_IDLS)))
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_ADDITIONAL_DEPENDENCIES) $(patsubst %.idl,$(LOCAL_XPIDL_OUT)/%.h,$(LOCAL_XPCOM_IDLS))
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_ADDITIONAL_DEPENDENCIES) $(patsubst %.idl,$(LOCAL_XPIDL_OUT)/%.xpt,$(LOCAL_XPCOM_IDLS))
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_ADDITIONAL_DEPENDENCIES) $(LOCAL_XPIDL_OUT)/$(LOCAL_XPCOM_MODULE).xpt
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_ADDITIONAL_DEPENDENCIES) $(LOCAL_XPCOM_MODULE)-export_headers $(LOCAL_XPCOM_MODULE)-export_idls
endif

LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_ADDITIONAL_DEPENDENCIES) $(LOCAL_XPCOM_MODULE)-xpcom_install

LOCAL_XPCOM_INSTALL_DIR := $(TARGET_OUT)/b2g/distribution/extensions/$(LOCAL_XPCOM_MODULE_UUID)

$(LOCAL_XPCOM_MODULE)-xpidl_install_prereqs: $(DEPENDS_ON_GECKO)
	@mkdir -p $(LOCAL_XPCOM_INSTALL_DIR)

$(LOCAL_XPIDL_OUT)/%.h: $(LOCAL_XPIDL_PATH)/%.idl $(XPIDL_DEPS) $(LOCAL_XPCOM_MODULE)-xpidl_prereqs
	$(REPORT_BUILD)
	$(PYTHON_PATH) $(PLY_INCLUDE) $(LIBXUL_DIST)/sdk/bin/header.py $(LOCAL_XPIDL_FLAGS) $(CURRENT_IDLS) -o $@

# generate intermediate .xpt files into $(LOCAL_XPIDL_OUT), then link
# into $(LOCAL_XPCOM_MODULE).xpt and export it to $(LOCAL_XPCOM_INSTALL_DIR)
$(LOCAL_XPIDL_OUT)/%.xpt: $(LOCAL_XPIDL_PATH)/%.idl $(XPIDL_DEPS) $(LOCAL_XPCOM_MODULE)-xpidl_prereqs
	$(REPORT_BUILD)
	$(PYTHON_PATH) $(PLY_INCLUDE) -I$(GECKO_DIR)/xpcom/typelib/xpt/tools $(LIBXUL_DIST)/sdk/bin/typelib.py $(LOCAL_XPIDL_FLAGS) $(CURRENT_IDLS) -o $@

$(LOCAL_XPIDL_OUT)/$(LOCAL_XPCOM_MODULE).xpt: $(patsubst %.idl,$(LOCAL_XPIDL_OUT)/%.xpt,$(LOCAL_XPCOM_IDLS)) $(LOCAL_XPCOM_MODULE)-xpidl_install_prereqs
	$(XPIDL_LINK) $(LOCAL_XPIDL_OUT)/$(LOCAL_XPCOM_MODULE).xpt $(patsubst %.idl,$(LOCAL_XPIDL_OUT)/%.xpt,$(LOCAL_XPCOM_IDLS))
	$(INSTALL) $(INSTALL_FLAGS) $(LOCAL_XPIDL_OUT)/$(LOCAL_XPCOM_MODULE).xpt $(LOCAL_XPCOM_INSTALL_DIR)

# Check to see if it is a pure JavaScript component
LOCAL_JS_SRC_FILES := $(filter %.js,$(LOCAL_SRC_FILES))
LOCAL_SRC_FILES := $(filter-out %.js,$(LOCAL_SRC_FILES))

# Invoke Android build system to build the shared library
include $(BUILD_SHARED_LIBRARY)

# We need to install binary only if its not a pure JS component
ifneq (,$(strip $(LOCAL_SRC_FILES)))
$(LOCAL_INSTALLED_MODULE):
	cp $(LOCAL_XPCOM_MODULE_OBJDIR)/LINKED/$(LOCAL_XPCOM_MODULE).so $(LOCAL_XPCOM_INSTALL_DIR)
endif

$(LOCAL_XPCOM_MODULE)-export_idls: $(patsubst %.idl,$(LOCAL_XPIDL_PATH)/%.idl,$(LOCAL_XPCOM_IDLS)) $(LOCAL_XPCOM_MODULE)-xpidl_install_prereqs
	$(INSTALL) $(INSTALL_FLAGS) $(patsubst %.idl,$(LOCAL_XPIDL_PATH)/%.idl,$(LOCAL_XPCOM_IDLS)) $(LOCAL_XPCOM_INSTALL_DIR)

$(LIBXUL_DIST)/idl: $(DEPENDS_ON_GECKO)

$(LOCAL_XPCOM_MODULE)-export_headers: $(patsubst %.idl,$(LOCAL_XPIDL_OUT)/%.h,$(LOCAL_XPCOM_IDLS)) $(LOCAL_XPCOM_MODULE)-xpidl_install_prereqs
	$(INSTALL) $(INSTALL_FLAGS) $(patsubst %.idl,$(LOCAL_XPIDL_OUT)/%.h,$(LOCAL_XPCOM_IDLS)) $(LOCAL_XPCOM_INSTALL_DIR)

$(LIBXUL_DIST)/include: $(DEPENDS_ON_GECKO)

$(LOCAL_XPCOM_MODULE)-install_js_srcs:

ifneq (,$(strip $(LOCAL_JS_SRC_FILES)))
$(LOCAL_XPCOM_MODULE)-install_js_srcs: $(LOCAL_XPCOM_MODULE)-xpidl_install_prereqs
	$(foreach js,$(LOCAL_JS_SRC_FILES),$(shell cp $(LOCAL_XPIDL_PATH)/$(js) $(LOCAL_XPCOM_INSTALL_DIR)))
endif

$(LOCAL_XPCOM_MODULE)-xpcom_install: $(LOCAL_XPCOM_MODULE)-xpidl_install_prereqs $(LOCAL_XPCOM_MODULE)-install_js_srcs $(GECKO_DIR)/config/buildlist.py $(LOCAL_XPIDL_PATH)/install.rdf $(LOCAL_XPIDL_PATH)/chrome.manifest
	@cp $(LOCAL_XPIDL_PATH)/install.rdf $(LOCAL_XPCOM_INSTALL_DIR)
	@cp $(LOCAL_XPIDL_PATH)/chrome.manifest $(LOCAL_XPCOM_INSTALL_DIR)
	@test -f $(LOCAL_XPIDL_PATH)/bootstrap.js && cp $(LOCAL_XPIDL_PATH)/bootstrap.js $(LOCAL_XPCOM_INSTALL_DIR)
	@$(PYTHON) $(GECKO_DIR)/config/buildlist.py $(LOCAL_XPCOM_INSTALL_DIR)/interfaces.manifest "interfaces $(LOCAL_XPCOM_MODULE).xpt"
	@$(PYTHON) $(GECKO_DIR)/config/buildlist.py $(LOCAL_XPCOM_INSTALL_DIR)/chrome.manifest "manifest interfaces.manifest"

$(GECKO_DIR)/config/buildlist.py: $(DEPENDS_ON_GECKO)
