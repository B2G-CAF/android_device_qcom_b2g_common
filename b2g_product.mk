# Copyright (c) 2012,2013 The Linux Foundation. All rights reserved.
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

ENABLE_DEFAULT_BOOTANIMATION:=true
ENABLE_LIBRECOVERY ?= true
include gonk-misc/b2g.mk
include external/moztt/fonts.mk
TARGET_PROVIDES_INIT_RC :=
PRODUCT_PACKAGES := $(filter-out fakeperm rilproxy,$(PRODUCT_PACKAGES))
PRODUCT_PACKAGES += librecovery_updater_qcom

PRODUCT_PROPERTY_OVERRIDES += \
  ro.display.colorfill=1 \
  ro.moz.ril.emergency_by_default=true \
  org.bluez.device.conn.type=array \
  ro.moz.omx.hw.max_width=800 \
  ro.moz.omx.hw.max_height=480

ifneq ($(filter user userdebug, $(TARGET_BUILD_VARIANT)),)
USE_JSMIN = 1
endif

export B2G_DEBUG


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
MOZ_CHROME_MULTILOCALE=cs de hr hu pl ro
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
