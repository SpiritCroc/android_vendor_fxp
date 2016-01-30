# Hardcoded to 8994 / kitakami for now
devices ?= kitakami ivy karin sumire suzuran # karin_windy satsuki
qcom_makefiles ?= \
	vendor/qcom/prebuilt/qcom-vendor.mk \
	vendor/qcom/prebuilt/qcom-partial-32bit.mk \
	vendor/qcom/prebuilt/qcom-partial-common.mk \
	vendor/qcom/prebuilt/qcom-partial-adreno-a3xx.mk \
	vendor/qcom/prebuilt/qcom-partial-adreno-a4xx.mk \
#	vendor/qcom/proprietary/qcom-firmware.mk \ # Not needed on 8994

$(foreach d, $(devices),\
	$(eval $(d)_p := $(shell MAKEFILE_FOR_VALUE="vendor/sony/$(d)/$(d)-partial.mk" \
	$(MAKE) -f vendor/fxp/build/get-variable-from-makefile.mk value-from-makefile-PRODUCT_PACKAGES)))

$(foreach m, $(qcom_makefiles),\
	$(eval $(m)_p := $(shell MAKEFILE_FOR_VALUE="$(m)" \
	$(MAKE) -f vendor/fxp/build/get-variable-from-makefile.mk value-from-makefile-PRODUCT_PACKAGES)))

.PHONY: device-proprietary-blobs
device-proprietary-blobs:
	$(hide) $(foreach d, $(devices),\
		$(foreach p,$(sort $(call get-proprietary-files-list, \
		$($(d)_p))),echo $(p) >> device/sony/$(d)/proprietary-files.txt;))
	$(hide) $(foreach m, $(qcom_makefiles),\
		$(foreach p,$(sort $(call get-proprietary-files-list, \
		$($(m)_p))),echo $(p) >> device/sony/kitakami/proprietary-files-qc.txt;))
