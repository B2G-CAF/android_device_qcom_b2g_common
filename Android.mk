
# If this is not a user/userdebug build redefine GAIA_DOMAIN away from
# gaiamobile.org to prevent the UI from automatically updating itself,
# which can be somewhat undesirable while in the middle of a debug session.
ifeq (,$(filter userdebug user,$(TARGET_BUILD_VARIANT)))
GAIA_DOMAIN?=privategaia.tld
# 'export' need to propagate the variable into the Gaia sub-make
export GAIA_DOMAIN
endif


LOCAL_PATH:= $(call my-dir)

FAKETOOLS_DX := $(abspath $(LOCAL_PATH)/faketools/dx)
FAKETOOLS_AAPT := $(abspath $(LOCAL_PATH)/faketools/aapt)

$(DX):
	mkdir -p $(@D)
	ln -sf $(FAKETOOLS_DX) $@

$(AAPT):
	mkdir -p $(@D)
	ln -sf $(FAKETOOLS_AAPT) $@
