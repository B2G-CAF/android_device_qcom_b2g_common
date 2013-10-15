#
# Makefile to hook into Android.mk for building XPCOM components, IDLs
# and typelibs, along with installing into Gecko
#

# The directory where this component's intermediates will be put by Android build system
LOCAL_XPCOM_MODULE_OBJDIR := $(TARGET_OUT_INTERMEDIATES)/SHARED_LIBRARIES/$(LOCAL_MODULE)_intermediates

# The directory where all the objs generated by idl compilation will go
LOCAL_XPIDL_OUT := $(LOCAL_XPCOM_MODULE_OBJDIR)/xpidl_obj

# The directory where the final xpcom module will be installed to
LOCAL_MODULE_PATH := $(TARGET_OUT)/b2g/distribution/bundles/$(LOCAL_MODULE)

# Install unstripped lib into symbols/system/lib/ instead of
# symbols/system/b2g/distribution/.. to avoid special case gdb path handling
LOCAL_UNSTRIPPED_PATH = $(TARGET_OUT_SHARED_LIBRARIES_UNSTRIPPED)

# Extract Javascript sources into a separate macro
LOCAL_JS_SRC_FILES := $(filter %.js,$(LOCAL_SRC_FILES))
LOCAL_SRC_FILES := $(filter-out %.js,$(LOCAL_SRC_FILES))

# Add Gecko as a dependency of this module.
LOCAL_REQUIRED_MODULES := $(LOCAL_REQUIRED_MODULES) gecko

# Add Gecko headers to include path
LOCAL_C_INCLUDES := $(LOCAL_C_INCLUDES) \
  $(ANDROID_PRODUCT_OUT)/obj/objdir-gecko/dist/include \
  $(ANDROID_PRODUCT_OUT)/obj/objdir-gecko/dist/include/nspr \
  $(TARGET_OUT_HEADERS)/xpcom

include external/stlport/libstlport.mk

# Compiler flags required by many Gecko libraries/sources
LOCAL_CPPFLAGS := $(LOCAL_CPPFLAGS) -std=c++0x
LOCAL_CFLAGS := $(LOCAL_CFLAGS) -D__STDC_INT64__ -D__STDC_LIMIT_MACROS -Wno-ignored-qualifiers
LOCAL_CFLAGS += -Werror
LOCAL_CFLAGS += -Wno-invalid-offsetof

# Remove enforcement of compilation error on non-virtual destructors.
#
# All XPCOM interfaces are classes of pure virtual functions, with a
# non virtual destructor. This is needed to compile XPCOM components
# via Android build system.
LOCAL_CFLAGS += -Wno-error=non-virtual-dtor -Wno-non-virtual-dtor

# Enable DEBUG for -eng builds to activate runtime assertions
ifneq ($(filter eng, $(TARGET_BUILD_VARIANT)),)
LOCAL_CFLAGS += -DDEBUG
endif

# Gecko locations (hardcoded! fragile!)
GECKO_DIR := $(ANDROID_BUILD_TOP)/gecko
GECKO_OBJDIR := $(ANDROID_PRODUCT_OUT)/obj/objdir-gecko

LIBXUL_DIST := $(GECKO_OBJDIR)/dist

# Flags to be used by idl compilation
LOCAL_XPIDL_FLAGS := -I$(LOCAL_PATH) -I$(LIBXUL_DIST)/idl

ifeq ($(ONE_SHOT_MAKEFILE),)
DEPENDS_ON_GECKO := $(TARGET_OUT)/gecko
endif

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

XPCOM_PYTHON := python $(GECKO_DIR)/config/pythonpath.py
XPIDL_LINK := $(XPCOM_PYTHON) $(LIBXUL_DIST)/sdk/bin/xpt.py link

INSTALL := install
INSTALL_FLAGS := -m 644

# Make gecko library dependencies work with Android.mk rule
# Copy them to where Android build system expects to find them
$(foreach lib,$(LOCAL_XPCOM_STATIC_LIBRARIES), $(eval NOTICE-TARGET-STATIC_LIBRARIES-$(lib):))


#
# Copy LOCAL_XPCOM_STATIC_LIBRARIES and LOCAL_XPCOM_SHARED_LIBRARIES from $(GECKO_OBJDIR)/dist
# to the standard build out locations
#

___LIBS:=$(foreach lib,$(LOCAL_XPCOM_STATIC_LIBRARIES),\
  $(TARGET_OUT_INTERMEDIATES)/lib/$(lib).a $(TARGET_OUT_INTERMEDIATES)/STATIC_LIBRARIES/$(lib)_intermediates/$(lib).a)

$(foreach lib,$(LOCAL_XPCOM_STATIC_LIBRARIES),\
  $(eval $(GECKO_OBJDIR)/dist/lib/$(lib).a: $(DEPENDS_ON_GECKO)))

$(foreach lib,$(___LIBS),\
  $(eval $(lib): $(GECKO_OBJDIR)/dist/lib/$(notdir $(lib) ; mkdir -p $$(@D) && cp $$< $$@)))


$(foreach lib,$(filter-out $(GLOBAL_SEEN_XPCOM_STATIC_LIBRARIES),$(LOCAL_XPCOM_STATIC_LIBRARIES)),\
  $(eval $(TARGET_OUT_INTERMEDIATES)/STATIC_LIBRARIES/$(lib)_intermediates/export_includes: ; mkdir -p $$(@D) && touch $$@))
GLOBAL_SEEN_XPCOM_STATIC_LIBRARIES += $(LOCAL_XPCOM_STATIC_LIBRARIES)

LOCAL_STATIC_LIBRARIES := $(LOCAL_STATIC_LIBRARIES) $(LOCAL_XPCOM_STATIC_LIBRARIES)


___LIBS:=$(foreach lib,$(LOCAL_XPCOM_SHARED_LIBRARIES),\
  $(TARGET_OUT_INTERMEDIATES)/lib/$(lib).so $(TARGET_OUT_INTERMEDIATES)/SHARED_LIBRARIES/$(lib)_intermediates/$(lib).so)

$(foreach lib,$(LOCAL_XPCOM_SHARED_LIBRARIES),\
  $(eval $(GECKO_OBJDIR)/dist/lib/$(lib).so: $(DEPENDS_ON_GECKO)))

$(foreach lib,$(___LIBS),\
  $(eval $(lib): $(GECKO_OBJDIR)/dist/lib/$(notdir $(lib) ; mkdir -p $$(@D) && cp $$< $$@)))

$(foreach lib,$(filter-out $(GLOBAL_SEEN_XPCOM_SHARED_LIBRARIES),$(LOCAL_XPCOM_SHARED_LIBRARIES)),\
  $(eval $(TARGET_OUT_INTERMEDIATES)/SHARED_LIBRARIES/$(lib)_intermediates/export_includes: ; mkdir -p $$(@D) && touch $$@))
GLOBAL_SEEN_XPCOM_SHARED_LIBRARIES += $(LOCAL_XPCOM_SHARED_LIBRARIES)

LOCAL_SHARED_LIBRARIES := $(LOCAL_SHARED_LIBRARIES) $(LOCAL_XPCOM_SHARED_LIBRARIES)

LOCAL_INSTALLED_XPCOM_IDL_HEADERS := $(patsubst %.idl,$(TARGET_OUT_HEADERS)/xpcom/%.h,$(LOCAL_XPCOM_IDLS))
LOCAL_INSTALLED_REQUIRED_XPCOM_IDL_HEADERS := $(patsubst %.idl,$(TARGET_OUT_HEADERS)/xpcom/%.h,$(LOCAL_REQUIRED_XPCOM_IDLS))

ifneq (,$(strip $(LOCAL_XPCOM_IDLS)))

$(LOCAL_INSTALLED_XPCOM_IDL_HEADERS): $(TARGET_OUT_HEADERS)/xpcom/%.h: $(LOCAL_XPIDL_OUT)/%.h
	@mkdir -p $(@D)
	$(INSTALL) $(INSTALL_FLAGS) $^ $(@D)


LOCAL_ADDITIONAL_INSTALL_DEPENDENCIES += $(patsubst %.idl,$(LOCAL_XPIDL_OUT)/%.xpt,$(LOCAL_XPCOM_IDLS))
LOCAL_ADDITIONAL_INSTALL_DEPENDENCIES += $(LOCAL_MODULE_PATH)/$(LOCAL_MODULE).xpt
endif

$(LOCAL_XPIDL_OUT)/%.h: $(LOCAL_PATH)/%.idl $(XPIDL_DEPS)
	@mkdir -p $(@D)
	$(REPORT_BUILD)
	$(XPCOM_PYTHON) $(PLY_INCLUDE) $(LIBXUL_DIST)/sdk/bin/header.py $(LOCAL_XPIDL_FLAGS) $(CURRENT_IDLS) -o $@

$(LOCAL_XPIDL_OUT)/%.xpt: $(LOCAL_PATH)/%.idl $(XPIDL_DEPS)
	@mkdir -p $(@D)
	$(REPORT_BUILD)
	$(XPCOM_PYTHON) $(PLY_INCLUDE) -I$(GECKO_DIR)/xpcom/typelib/xpt/tools $(LIBXUL_DIST)/sdk/bin/typelib.py $(LOCAL_XPIDL_FLAGS) $(CURRENT_IDLS) -o $@

$(LOCAL_XPIDL_OUT)/$(LOCAL_MODULE).xpt: $(patsubst %.idl,$(LOCAL_XPIDL_OUT)/%.xpt,$(LOCAL_XPCOM_IDLS)) $(DEPENDS_ON_GECKO)
	$(XPIDL_LINK) $@ $(filter-out $(DEPENDS_ON_GECKO), $^)

$(LOCAL_MODULE_PATH)/$(LOCAL_MODULE).xpt: $(LOCAL_XPIDL_OUT)/$(LOCAL_MODULE).xpt
	@mkdir -p $(@D)
	$(INSTALL) $(INSTALL_FLAGS) $^ $(@D)

BUILDLIST_PY := $(wildcard $(GECKO_DIR)/config/buildlist.py \
  $(GECKO_DIR)/python/mozbuild/mozbuild/action/buildlist.py)

MOZBUILD_INCLUDE := -I$(GECKO_DIR)/python/mozbuild

ifneq (,$(strip $(LOCAL_XPCOM_IDLS)))
LOCAL_ADDITIONAL_INSTALL_DEPENDENCIES += $(LOCAL_MODULE_PATH)/interfaces.manifest

$(LOCAL_MODULE_PATH)/interfaces.manifest: PRIVATE_LOCAL_MODULE := $(LOCAL_MODULE)
$(LOCAL_MODULE_PATH)/interfaces.manifest: $(BUILDLIST_PY)
	@mkdir -p $(@D)
	$(XPCOM_PYTHON) $(MOZBUILD_INCLUDE) $(BUILDLIST_PY) $@ "interfaces $(PRIVATE_LOCAL_MODULE).xpt"
endif


INSTALLED_JS_FILES := $(addprefix $(LOCAL_MODULE_PATH)/,$(LOCAL_JS_SRC_FILES))
LOCAL_ADDITIONAL_INSTALL_DEPENDENCIES += $(INSTALLED_JS_FILES)

ifneq ($(wildcard external/jslint/closure_linter/gjslint.py),)
GJSLINT := $(XPCOM_PYTHON) -I$(ANDROID_BUILD_TOP)/external/jslint \
  $(ANDROID_BUILD_TOP)/external/jslint/closure_linter/gjslint.py
endif

ifdef USE_JSMIN
JSMIN := $(BUILD_OUT_EXECUTABLES)/jsmin$(BUILD_EXECUTABLE_SUFFIX)
$(INSTALLED_JS_FILES): PRIVATE_JS_NOTICE := $(LOCAL_JS_NOTICE)
$(INSTALLED_JS_FILES): $(LOCAL_MODULE_PATH)/%.js: $(LOCAL_PATH)/%.js $(JSMIN) $(DEPENDS_ON_GECKO)
ifdef GJSLINT
	$(GJSLINT) $<
endif
	@mkdir -p $(@D)
	$(JSMIN) < $< > $@ '$(PRIVATE_JS_NOTICE)'
else
$(INSTALLED_JS_FILES): $(LOCAL_MODULE_PATH)/%.js: $(LOCAL_PATH)/%.js $(ACP) $(DEPENDS_ON_GECKO)
ifdef GJSLINT
	$(GJSLINT) $<
endif
	@mkdir -p $(@D)
	$(ACP) $< $@
endif

LOCAL_ADDITIONAL_INSTALL_DEPENDENCIES += $(LOCAL_MODULE_PATH)/chrome.manifest

$(LOCAL_MODULE_PATH)/chrome.manifest: $(LOCAL_PATH)/chrome.manifest $(BUILDLIST_PY) $(ACP)
	@mkdir -p $(@D)
	$(ACP) $< $@
ifneq (,$(strip $(LOCAL_XPCOM_IDLS)))
	$(XPCOM_PYTHON) $(MOZBUILD_INCLUDE) $(BUILDLIST_PY) $@ "manifest interfaces.manifest"
endif

$(BUILDLIST_PY): $(DEPENDS_ON_GECKO)

include $(BUILD_SHARED_LIBRARY)

$(all_objects): $(DEPENDS_ON_GECKO) $(LOCAL_INSTALLED_XPCOM_IDL_HEADERS) $(LOCAL_INSTALLED_REQUIRED_XPCOM_IDL_HEADERS)

$(LOCAL_INSTALLED_MODULE): $(LOCAL_ADDITIONAL_INSTALL_DEPENDENCIES)
