# Remove unused media files from system image
echo > data/videos/VideoPackage1.mk
git_add data/videos/VideoPackage1.mk
echo > data/sounds/OriginalAudio.mk
git_add data/sounds/OriginalAudio.mk
git_rm data/sounds/AllAudio.mk
