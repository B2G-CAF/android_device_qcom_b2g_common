# Copyright (c) 2012,2013,2014 The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.
#     * Neither the name of The Linux Foundation nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT
# ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#ENABLE_DEFAULT_BOOTANIMATION:=true
ENABLE_LIBRECOVERY ?= true
include gonk-misc/b2g.mk
include external/moztt/fonts.mk
TARGET_PROVIDES_INIT_RC :=
PRODUCT_PACKAGES := $(filter-out fakeappops rilproxy oom-msg-logger,$(PRODUCT_PACKAGES))
PRODUCT_PACKAGES += librecovery_updater_qcom

PRODUCT_PROPERTY_OVERRIDES += \
  ro.display.colorfill=1 \
  ro.moz.ril.emergency_by_default=true \
  org.bluez.device.conn.type=array \

ifneq ($(PLATFORM_SDK_VERSION), 15)
PRODUCT_PROPERTY_OVERRIDES += ro.moz.devinputjack=1
endif

ifneq ($(filter user userdebug, $(TARGET_BUILD_VARIANT)),)
USE_JSMIN = 1
endif


#
# Disable parallel make for gaia to improve build stability.
#
# It would be nice to use $(ANDROID_BUILD_TOP) instead of '%', but the |my-dir|
# macro used to compute the LOCAL_PATH macro in gaia/Android.mk has been
# observed to produce different results from $(ANDROID_BUILD_TOP) when there
# is a symbolic link in the path to the build root.
#
%/gaia/profile.tar.gz: MAKE:=$(MAKE) -j1
gaia/profile.tar.gz: MAKE:=$(MAKE) -j1


export B2G_DEBUG

# .mk files useful for building xpcom components
CLEAR_XPCOM_VARS:=$(dir $(firstword $(MAKEFILE_LIST)))clear_xpcom_vars.mk
BUILD_XPCOM:=$(dir $(firstword $(MAKEFILE_LIST)))xpcom.mk


# GAIA_DISTRIBUTION_DIR enables overrides for Gaia settings
ifndef GAIA_DISTRIBUTION_DIR
GAIA_DISTRIBUTION_DIR:=$(ANDROID_BUILD_TOP)/out/target/product/$(TARGET_PRODUCT)/gaia_distribution
export GAIA_DISTRIBUTION_DIR
endif

#
# Multilocale support.
#
# Define the B2G_LANGUAGE_PACK variable in the environment before a build
# to select a preconfigured collection of locales.
#
# Alternatively manually define the LOCALES_FILE, GAIA_DEFAULT_LOCALE, and
# MOZ_CHROME_MULTILOCALE environment variables to create new combinations
# without modifying this file, if desired. More information about these
# environment variables may be found at:
#   https://developer.mozilla.org/en-US/docs/Mozilla/Firefox_OS/Building#Building_multilocale
#

ifeq ($(strip $(B2G_LANGUAGE_PACK)),basecamp)
# Locales to enable for Gaia
LOCALES_FILE=locales/languages_basecamp.json
# Default Gaia locale
GAIA_DEFAULT_LOCALE=en-US
# Locales to enable for Gecko
MOZ_CHROME_MULTILOCALE=pt-BR es-ES
endif

ifeq ($(strip $(B2G_LANGUAGE_PACK)),shira)
# Locales to enable for Gaia
LOCALES_FILE=locales/languages_shira.json
# Default Gaia locale
GAIA_DEFAULT_LOCALE=en-US
# Locales to enable for Gecko
MOZ_CHROME_MULTILOCALE=cs de hr hu pl sr ro
endif

ifeq ($(strip $(B2G_LANGUAGE_PACK)),full)
# Locales to enable for Gaia
LOCALES_FILE=locales/languages_full.json
# Default Gaia locale
GAIA_DEFAULT_LOCALE=en-US
# Locales to enable for Gecko
MOZ_CHROME_MULTILOCALE=ar cs de el en-US es-ES fr hr hu pl pt-BR ro sk sr zh-TW
endif

# Env variables used for Gaia multilocale support
LOCALE_BASEDIR=$(abspath gaia-l10n)
export LOCALES_FILE
export LOCALE_BASEDIR
export GAIA_DEFAULT_LOCALE

# Env variables used for Gecko multilocale support
L10NBASEDIR=$(abspath gecko-l10n)
export MOZ_CHROME_MULTILOCALE
export L10NBASEDIR

# Add compare-locales to the PATH for Gecko multilocale
#
# TODO: This could be instead added in gonk-misc/Android.mk
#       when the Gecko build is involved to limit the scope of
#       the PATH changes
PATH:=$(PATH):$(abspath compare-locales/scripts)
PYTHONPATH:=$(PYTHONPATH):$(abspath compare-locales/lib)
export PATH
export PYTHONPATH
