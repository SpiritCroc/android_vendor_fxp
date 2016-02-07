CM_PATH ?= ~/android/cm/13
DEVICE_PATH := $(CM_PATH)/device/sony

kitakami_devices := ivy karin sumire suzuran satsuki
kitakami_qcom_makefiles := \
	vendor/qcom/prebuilt/qcom-partial-adreno-a4xx.mk \
	vendor/qcom/prebuilt/qcom-partial-firmware.mk \
	vendor/qcom/prebuilt/qcom-partial-msm8994.mk \
	vendor/qcom/prebuilt/qcom-vendor.mk

shinano_normal_devices := sirius castor scorpion
shinano_special_devices := z3 z3c
shinano_devices := $(shinano_normal_devices) $(shinano_special_devices)
shinano_qcom_makefiles := \
	vendor/qcom/prebuilt/qcom-partial-adreno-a3xx.mk \
	vendor/qcom/prebuilt/qcom-partial-firmware.mk \
	vendor/qcom/prebuilt/qcom-partial-msm8974.mk \
	vendor/qcom/prebuilt/qcom-vendor.mk
shinano_firmware_makefile := \
	vendor/qcom/proprietary/qcom-modem-firmware.mk

rhine_devices := amami honami togari
rhine_qcom_makefiles := \
	vendor/qcom/prebuilt/qcom-partial-adreno-a3xx.mk \
	vendor/qcom/prebuilt/qcom-partial-firmware.mk \
	vendor/qcom/prebuilt/qcom-partial-msm8974.mk \
	vendor/qcom/prebuilt/qcom-vendor.mk
rhine_firmware_makefile := \
	vendor/qcom/proprietary/qcom-modem-firmware.mk

yukon_devices := eagle tianchi seagull flamingo
yukon_qcom_makefiles := \
	vendor/qcom/prebuilt/qcom-partial-adreno-a3xx.mk \
	vendor/qcom/prebuilt/qcom-partial-firmware.mk \
	vendor/qcom/prebuilt/qcom-partial-msm8226.mk \
	vendor/qcom/prebuilt/qcom-vendor.mk
yukon_firmware_makefile := \
	vendor/qcom/proprietary/qcom-modem-firmware.mk

qcom_makefiles := $(call uniq,\
	$(kitakami_qcom_makefiles) $(shinano_qcom_makefiles) $(rhine_qcom_makefiles) $(yukon_qcom_makefiles))
firmware_makefile := vendor/qcom/proprietary/qcom-modem-firmware.mk


# $(1) path to makefile
define get-packages-from-makefile
$(shell MAKEFILE_FOR_VALUE="$(1)" \
	$(MAKE) -f vendor/fxp/build/get-variable-from-makefile.mk value-from-makefile-PRODUCT_PACKAGES;)
endef

$(foreach d, $(kitakami_devices) $(shinano_normal_devices) $(rhine_devices) $(yukon_devices) kitakami shinano rhine yukon,\
	$(eval $(d)_p := $(call get-packages-from-makefile, vendor/sony/$(d)/$(d)-partial.mk)))
$(eval z3_p := $(call get-packages-from-makefile, vendor/sony/leo/leo-partial.mk))
$(eval z3c_p := $(call get-packages-from-makefile, vendor/sony/aries/aries-partial.mk))

$(foreach m, $(qcom_makefiles),\
	$(eval $(m)_p := $(call get-packages-from-makefile, $(m))))

$(eval $(firmware_makefile)_p := $(call get-packages-from-makefile, $(firmware_makefile)))

.PHONY: kitakami-proprietary-filelist
kitakami-proprietary-filelist:
	-$(hide) $(foreach d, $(kitakami_devices),\
		rm $(DEVICE_PATH)/$(d)/proprietary-files*.txt;)
	-$(hide) rm $(DEVICE_PATH)/kitakami-common/proprietary-files*.txt
	$(hide) $(foreach d, $(kitakami_devices),\
		$(foreach p,$(sort $(call get-proprietary-files-list, \
		$($(d)_p))),echo $(p) >> $(DEVICE_PATH)/$(d)/proprietary-files-sony.txt;))
	$(hide) $(foreach p,$(sort $(call get-proprietary-files-list, \
		$(kitakami_p))),echo $(p) >> $(DEVICE_PATH)/kitakami-common/proprietary-files-sony.txt;)
	$(hide) $(foreach m, $(kitakami_qcom_makefiles),\
		$(foreach p,$(sort $(call get-proprietary-files-list, \
		$($(m)_p))),echo $(p) >> $(DEVICE_PATH)/kitakami-common/proprietary-files-qc.txt;))

.PHONY: shinano-proprietary-filelist
shinano-proprietary-filelist:
	-$(hide) $(foreach d, $(shinano_devices),\
		rm $(DEVICE_PATH)/$(d)/proprietary-files*.txt;)
	-$(hide) rm $(DEVICE_PATH)/shinano-common/proprietary-files*.txt
	-$(hide) rm $(DEVICE_PATH)/msm8974-common/proprietary-files*.txt
	$(hide) $(foreach d, $(shinano_devices),\
		$(foreach p,$(sort $(call get-proprietary-files-list, \
		$($(d)_p))),echo $(p) >> $(DEVICE_PATH)/$(d)/proprietary-files-sony.txt;))
	$(hide) $(foreach p,$(sort $(call get-proprietary-files-list, \
		$(shinano_p))),echo $(p) >> $(DEVICE_PATH)/shinano-common/proprietary-files-sony.txt;)
	$(hide) $(foreach m, $(shinano_qcom_makefiles),\
		$(foreach p,$(sort $(call get-proprietary-files-list, \
		$($(m)_p))),echo $(p) >> $(DEVICE_PATH)/msm8974-common/proprietary-files-qc.txt;))
	$(hide) $(foreach d, $(shinano_devices),\
		$(foreach p,$(sort $(call get-proprietary-files-list, \
		$($(shinano_firmware_makefile)_p))),echo $(p) >> $(DEVICE_PATH)/$(d)/proprietary-files-fw.txt;))

.PHONY: rhine-proprietary-filelist
rhine-proprietary-filelist:
	-$(hide) $(foreach d, $(rhine_devices),\
		rm $(DEVICE_PATH)/$(d)/proprietary-files*.txt;)
	-$(hide) rm $(DEVICE_PATH)/rhine-common/proprietary-files*.txt
	-$(hide) rm $(DEVICE_PATH)/msm8974-common/proprietary-files*.txt
	$(hide) $(foreach d, $(rhine_devices),\
		$(foreach p,$(sort $(call get-proprietary-files-list, \
		$($(d)_p))),echo $(p) >> $(DEVICE_PATH)/$(d)/proprietary-files-sony.txt;))
	$(hide) $(foreach p,$(sort $(call get-proprietary-files-list, \
		$(rhine_p))),echo $(p) >> $(DEVICE_PATH)/rhine-common/proprietary-files-sony.txt;)
	$(hide) $(foreach m, $(rhine_qcom_makefiles),\
		$(foreach p,$(sort $(call get-proprietary-files-list, \
		$($(m)_p))),echo $(p) >> $(DEVICE_PATH)/msm8974-common/proprietary-files-qc.txt;))
	$(hide) $(foreach d, $(rhine_devices),\
		$(foreach p,$(sort $(call get-proprietary-files-list, \
		$($(rhine_firmware_makefile)_p))),echo $(p) >> $(DEVICE_PATH)/$(d)/proprietary-files-fw.txt;))

.PHONY: msm8974-proprietary-filelist
msm8974-proprietary-filelist: shinano-proprietary-filelist rhine-proprietary-filelist

.PHONY: yukon-proprietary-filelist
yukon-proprietary-filelist:
	-$(hide) $(foreach d, $(yukon_devices),\
		rm $(DEVICE_PATH)/$(d)/proprietary-files*.txt;)
	-$(hide) rm $(DEVICE_PATH)/yukon/proprietary-files*.txt
	$(hide) $(foreach d, $(yukon_devices),\
		$(foreach p,$(sort $(call get-proprietary-files-list, \
		$($(d)_p))),echo $(p) >> $(DEVICE_PATH)/$(d)/proprietary-files-sony.txt;))
	$(hide) $(foreach p,$(sort $(call get-proprietary-files-list, \
		$(yukon_p))),echo $(p) >> $(DEVICE_PATH)/yukon/proprietary-files-sony.txt;)
	$(hide) $(foreach m, $(yukon_qcom_makefiles),\
		$(foreach p,$(sort $(call get-proprietary-files-list, \
		$($(m)_p))),echo $(p) >> $(DEVICE_PATH)/yukon/proprietary-files-qc.txt;))
	$(hide) $(foreach d, $(yukon_devices),\
		$(foreach p,$(sort $(call get-proprietary-files-list, \
		$($(yukon_firmware_makefile)_p))),echo $(p) >> $(DEVICE_PATH)/$(d)/proprietary-files-fw.txt;))

ifneq ($(ONE_SHOT_MAKEFILE),)
subdirs := vendor/qcom/prebuilt vendor/qcom/proprietary \
	$(foreach d, $(kitakami_devices) $(shinano_normal_devices) $(rhine_devices) $(yukon_devices) kitakami shinano rhine yukon,\
	vendor/sony/$(d))
subdir_makefiles := \
        $(shell build/tools/findleaves.py $(FIND_LEAVES_EXCLUDES) $(subdirs) Android.mk)
$(foreach mk, $(subdir_makefiles), $(eval include $(mk)))
ALL_MODULES += $(foreach c, kitakami shinano rhine yukon,\
				$(if $(findstring $(TARGET_DEVICE), $($(c)_devices)),$(c)-proprietary-filelist))
endif
