#!/bin/sh
#
# Attempt to identify the Android tree in use.
#
# On success, one or more tree identifiers are output to stdout

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
