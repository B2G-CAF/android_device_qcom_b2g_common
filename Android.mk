# Copyright (c) 2012,2014 The Linux Foundation. All rights reserved.
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


LOCAL_PATH:= $(call my-dir)

FAKETOOLS_DX := $(abspath $(LOCAL_PATH)/faketools/dx)
FAKETOOLS_AAPT := $(abspath $(LOCAL_PATH)/faketools/aapt)

$(DX):
	mkdir -p $(@D)
	ln -sf $(FAKETOOLS_DX) $@

$(AAPT):
	mkdir -p $(@D)
	ln -sf $(FAKETOOLS_AAPT) $@

include $(LOCAL_PATH)/updater/Android.mk \
        $(LOCAL_PATH)/jsmin/Android.mk


ifdef GAIA_DISTRIBUTION_DIR

# Populate GAIA_DISTRIBUTION_DIR prior to the Gaia sub-build
gaia/profile.tar.gz: $(GAIA_DISTRIBUTION_DIR)/.exist
$(GAIA_DISTRIBUTION_DIR)/.exist:
	mkdir -p $(@D)
	touch $@

define mk_gaia_distribution_file
$(GAIA_DISTRIBUTION_DIR)/.exist: $2
$2: $1
	mkdir -p $$(@D)
	cp $$< $$@
endef

$(foreach file,$(GAIA_DISTRIBUTION_SRC_FILES),\
  $(eval $(call mk_gaia_distribution_file, $(file), $(GAIA_DISTRIBUTION_DIR)/$(notdir $(file)))))

endif
