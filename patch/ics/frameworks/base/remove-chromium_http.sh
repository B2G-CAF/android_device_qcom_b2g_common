if [[ -d media/libstagefright/chromium_http ]]; then
   # chromium_http fails to compile when the chrome HTTP stack is
   # disabled...
   git_rm media/libstagefright/chromium_http/Android.mk
fi
