#!/bin/sh
#
# Attempt to identify the Android tree in use.  On success one or more
# tree identifiers are output to stdout.
#
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


# Relocate to the root of the Android tree
if [[ ! ( -f build/envsetup.sh ) ]]; then
   echo $0: Error: CWD does not look like the root of an Android tree. > /dev/stderr
   exit 1
fi


if [[ -d device/samsung/maguro ]]; then
   # Check if the ICS tree is the w1205 tree
   if [[ -d device/qcom/msm7627a/.git ]]; then
      if [[ "$(cd device/qcom/msm7627a && git log -n 1 --format="%H")" = "eaa6e2865691ffa55109c23edb97eef1ae5e2fde" ]] ; then
         echo ics_w1205 ics all
         exit
      fi
   fi

   # Android ICS tree
   echo ics all
   exit
fi

# Android GB tree
echo gb all
exit
