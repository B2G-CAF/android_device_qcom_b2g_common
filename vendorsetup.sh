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

#
# Environment variables influencing operation:
#    B2G_TREE_ID - Defines the tree ID, used to determine which patches to
#        apply.  If unset, |treeid.sh| is run to identify the tree
#    B2G_USE_REPO - If set, use |repo manifest| to determine when the Android
#                   tree has changed.  Disabled by default for performance
#                   reasons.

__tree_md5sum()
{
   (
      FILELIST="$(find $@ -type f 2>/dev/null) device/qcom/b2g_common/vendorsetup.sh device/qcom/b2g_common/treeid.sh"
      if [[ -n "${B2G_USE_REPO}" ]]; then
         repo manifest -r -o - 2>/dev/null
      fi
      cat ${FILELIST}
   ) | md5sum | cut -f1 -d\ 
}

__abandon_tree()
{
   rm -f out/lastpatch.md5sum
   if [[ -d .repo ]]; then
      repo abandon b2g_autogen_ephemeral_branch || true
   fi
}

__patch_tree()
{
   (
      cd $(gettop)
      local TREE_ID=${B2G_TREE_ID:-$(device/qcom/b2g_common/treeid.sh)}
      local PATCH_DIRS="vendor/qcom/proprietary/b2g_common/patch device/qcom/b2g_common/patch"

      echo >> Android tree IDs: ${TREE_ID}
      set -e
      echo -n ">> Analyzing workspace for change..."
      local LASTMD5SUM=invalid
      local MD5SUM=unknown
      if [[ -f out/lastpatch.md5sum ]]; then
         LASTMD5SUM=$(cat out/lastpatch.md5sum)
         MD5SUM=$(__tree_md5sum ${PATCH_DIRS})
      fi
      if [[ "$LASTMD5SUM" != "$MD5SUM" ]]; then
         echo "Change detected.  Applying B2G patches".

         __abandon_tree

         branch() {
            [[ -d $1 ]] || return 1

            pushd $1 > /dev/null
            echo
            echo [entering $1]
            if [[ -d .git ]]; then
               # Try repo first, but if the project is not repo managed then
               # use a raw git branch instead.
               repo start b2g_autogen_ephemeral_branch .  ||
                 ( git checkout master && \
                   ( git branch -D b2g_autogen_ephemeral_branch || true ) && \
                   git branch b2g_autogen_ephemeral_branch && \
                   git checkout b2g_autogen_ephemeral_branch \
                 )
            else
               read -p "Project $1 is not managed by git. Modify anyway?  [y/N] "
               if [[ ${REPLY} != "y" ]]; then
                  echo "No."
                  popd > /dev/null
                  return 1
               fi
            fi
         }
         apply() {
            if [[ -d .git ]]; then
               git apply --index $1
            else
               patch -p1 < $1
            fi
         }
         git_rm() {
            if [[ -d .git ]]; then
               git rm -q $@
            else
               rm $@
            fi
         }
         git_add() {
            if [[ -d .git ]]; then
               git add $@
            fi
         }
         commit() {
            if [[ -d .git ]]; then
               git commit --all -m "B2G Adaptations" --allow-empty -q
            fi
            popd > /dev/null
         }

         # Find all of the patches for TREE_ID
         # and collate them into an associative array
         # indexed by project
         declare -A PRJ_LIST
         for DIR in ${PATCH_DIRS} ; do
            for ID in ${TREE_ID} ; do
               local D=${DIR}/${ID}
               [[ -d $D ]] || continue
               PATCHES=$(find $D -type f)
               for P in ${PATCHES}; do
                  PRJ=$(dirname ${P#${DIR}/${ID}/})
                  PRJ_LIST[$PRJ]="${PRJ_LIST[$PRJ]} $P"
               done
            done
         done

         # Run through each project and apply patches
         ROOT_DIR=${PWD}
         for PRJ in ${!PRJ_LIST[*]} ; do
            local FAILED_PRJ=${PRJ}
            set +e
            (
               set -e
               if branch ${PRJ} ; then
                  # Ensure the project is clean before applying patches to it
                  git reset --hard HEAD > /dev/null
                  git clean -dfx

                  declare -A PATCHNAME
                  for P in ${PRJ_LIST[${PRJ}]} ; do
                     # Skip patches that have already been applied by an earlier ID
                     if [[ -n "${PATCHNAME[$(basename $P)]}" ]]; then continue; fi
                     PATCHNAME[$(basename $P)]=1

                     echo "  ${P}"
                     case $P in
                     *.patch)  apply ${ROOT_DIR}/$P ;;
                     *.sh)     source ${ROOT_DIR}/$P ;;
                     *)        echo Warning: Ignoring $P
                     esac
                  done
                  commit
               fi
            )
            local ERR=$?
            if [[ ${ERR} -ne 0 ]]; then
               echo
               echo ERROR: Patching of ${FAILED_PRJ}/ failed.
               echo
               exit ${ERR}
            fi
            set -e
         done

         echo
         echo B2G patches applied.
         mkdir -p out
         echo $(__tree_md5sum ${PATCH_DIRS}) > out/lastpatch.md5sum
      else
         echo no changes detected.
      fi
   )
   ERR=$?

   if [[ ${ERR} -ne 0 ]]; then
      lunch() { echo ERROR: B2G PATCHES FAILED TO APPLY;  return 1; }
      choosecombo() { lunch; }
   fi
   return ${ERR}
}

# Stub out all java compilation.
export JAVA_HOME=$(readlink -f device/qcom/b2g_common/faketools/jdk)
export ANDROID_JAVA_HOME=${JAVA_HOME}

flash()
{
   ( cd $(gettop)/device/qcom/b2g_common && ./flash.sh $@ )
}

rungdb()
{
   ( cd $(gettop)/device/qcom/b2g_common && ./run-gdb.sh $@ )
}

if [[ -f vendor/qcom/proprietary/b2g_common/vendorsetup.sh ]]; then
   . vendor/qcom/proprietary/b2g_common/vendorsetup.sh
fi

if [[ -z $1 ]]; then
   __patch_tree
else
   case $1 in
   clean) __abandon_tree ;;
   np) echo "Skipping patch tree step...";;
   *) [[ -z "$PS1" ]] && __patch_tree || echo Error: Unknown command: $1
   esac
fi
