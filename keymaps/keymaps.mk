# Copyright (c) 2012, The Linux Foundation. All rights reserved.
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

# QRD7x27a_SKU1 touchscreen config
PRODUCT_COPY_FILES += device/qcom/b2g_common/keymaps/generic.idc:system/usr/idc/sensor00fn11.idc

# QRD7x27a_SKU3 touchscreen configs
PRODUCT_COPY_FILES += device/qcom/b2g_common/keymaps/generic.idc:system/usr/idc/ft5x0x_ts.idc
PRODUCT_COPY_FILES += device/qcom/b2g_common/keymaps/generic.idc:system/usr/idc/ft5x06_ts.idc

# 8960 LIQUID
PRODUCT_COPY_FILES += device/qcom/b2g_common/keymaps/generic.idc:system/usr/idc/atmel_mxt_ts.idc

# 7x27a_ffa
PRODUCT_COPY_FILES += device/qcom/b2g_common/keymaps/generic.idc:system/usr/idc/Atmel_maXTouch_Touchscreen_controller.idc

# Other known touchscreens:
PRODUCT_COPY_FILES += device/qcom/b2g_common/keymaps/generic.idc:system/usr/idc/atmel-touchscreen.idc
PRODUCT_COPY_FILES += device/qcom/b2g_common/keymaps/generic.idc:system/usr/idc/msg2133.idc

