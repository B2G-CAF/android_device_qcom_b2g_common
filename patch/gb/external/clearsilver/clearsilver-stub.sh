cat > Android.mk <<-EOF
\$(HOST_OUT_JAVA_LIBRARIES)/dx.jar:                   ; mkdir -p \$(@D) && touch \$@
\$(HOST_OUT_SHARED_LIBRARIES)/libclearsilver-jni.so:  ; mkdir -p \$(@D) && touch \$@
\$(HOST_OUT_JAVA_LIBRARIES)/clearsilver.jar:          ; mkdir -p \$(@D) && touch \$@
EOF
git_add Android.mk
