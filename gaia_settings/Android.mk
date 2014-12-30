LOCAL_PATH:= $(call my-dir)

TEMPLATE_GAIA_DISTRIBUTION_DIR:=$(LOCAL_PATH)/distribution

gaia/profile.tar.gz: $(GAIA_DISTRIBUTION_DIR)/.exist

CAMERA_RECORDING_PREFERREDSIZES=\"cif\"
ifeq ($(TARGET_BOARD_PLATFORM),msm8226)
CAMERA_RECORDING_PREFERREDSIZES=\"720p\"
endif
ifeq ($(TARGET_BOARD_PLATFORM),msm8610)
CAMERA_RECORDING_PREFERREDSIZES=\"480p\"
endif

MERGEJSON:=$(LOCAL_PATH)/bin/mergejson

$(GAIA_DISTRIBUTION_DIR)/.exist: $(GAIA_DISTRIBUTION_DIR)/settings.json
$(GAIA_DISTRIBUTION_DIR)/settings.json: \
    $(GAIA_DISTRIBUTION_DIR)/.settings.tmp \
    $(EXTRA_SETTINGS_JSON_FILE)
	echo extra json file is $(EXTRA_SETTINGS_JSON_FILE)
	if [ -z "$(EXTRA_SETTINGS_JSON_FILE)" ]; then \
	  cp $< $@; \
	else \
	  $(MERGEJSON) $(EXTRA_SETTINGS_JSON_FILE) $(GAIA_DISTRIBUTION_DIR)/.settings.tmp $@; \
	fi

$(GAIA_DISTRIBUTION_DIR)/.settings.tmp: $(TEMPLATE_GAIA_DISTRIBUTION_DIR)/settings.json
	mkdir -p $(@D)
	cpp -P -DCAMERA_RECORDING_PREFERREDSIZES=$(CAMERA_RECORDING_PREFERREDSIZES) $< $@

$(GAIA_DISTRIBUTION_DIR)/.exist: $(GAIA_DISTRIBUTION_DIR)/partner-prefs.js
$(GAIA_DISTRIBUTION_DIR)/partner-prefs.js: \
    $(TEMPLATE_GAIA_DISTRIBUTION_DIR)/partner-prefs.js \
    $(EXTRA_PARTNER_PREFS_FILE)
	mkdir -p $(@D)
	cp $< $@
	cat $(EXTRA_PARTNER_PREFS_FILE) >> $@

$(GAIA_DISTRIBUTION_DIR)/.exist: $(GAIA_DISTRIBUTION_DIR)/camera.json
$(GAIA_DISTRIBUTION_DIR)/camera.json: \
    $(TEMPLATE_GAIA_DISTRIBUTION_DIR)/camera.json
	mkdir -p $(@D)
	cp $< $@

$(GAIA_DISTRIBUTION_DIR)/.exist:
	mkdir -p $(@D)
	touch $@
