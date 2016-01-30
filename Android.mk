devices ?= ivy karin sumire suzuran # karin_windy satsuki

$(foreach d, $(devices),\
	$(eval $(d)_p := $(shell MAKEFILE_FOR_VALUE="vendor/sony/$(d)/$(d)-partial.mk" \
	$(MAKE) -f vendor/fxp/build/get-variable-from-makefile.mk value-from-makefile-PRODUCT_PACKAGES)))

.PHONY: device-proprietary-blobs
device-proprietary-blobs:
	$(hide) $(foreach d, $(devices),\
		$(foreach p,$(sort $(call get-proprietary-files-list, \
		$($(d)_p))),echo $(p) >> device/sony/$(d)/proprietary-files.txt;))
