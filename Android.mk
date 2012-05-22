# Copyright (c) 2012, Code Aurora Forum. All rights reserved.
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
#     * Neither the name of Code Aurora Forum, Inc. nor the names of its
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
