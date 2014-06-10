#!/bin/bash
#
# Attempt to identify the Android tree in use.  On success one or more
# tree identifiers are output to stdout.
#
# Copyright (c) 2012-2014, The Linux Foundation. All rights reserved.
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


if [[ ! ( -f build/envsetup.sh ) ]]; then
   echo $0: Error: CWD does not look like the root of an Android tree. > /dev/stderr
   exit 1
fi

TREEID=
if [[ -f .repo/manifest.xml ]] ; then
   # Tokenize <default revision="x_y_z"/> by '_'
   TOKENS=$(repo info -l .repo/manifest | sed -e \ '/merge.*/!d ; s/^.*branch:"// ; s/.*b2g_//g;')

   MANIFEST_ID=
   for T in $TOKENS; do
      if [ -z $MANIFEST_ID ]; then
        MANIFEST_ID=$T
      else
        MANIFEST_ID=${MANIFEST_ID}_$T
      fi
      TREEID="$MANIFEST_ID $TREEID"
   done
fi

echo $TREEID all
