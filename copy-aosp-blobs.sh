#!/bin/bash
# Copy AOSP blobs to a CM tree

aosp_path=${aosp_path:-~/android/aosp/6.0}
cm_path=${cm_path:-~/android/cm/13}

devices=${devices:-ivy karin sumire suzuran} # karin_windy satsuki}
common=${common:-kitakami}

qcom_dirs=${qcom_dirs:-64bit adreno/a4xx common}

# Individual devices
for d in $devices; do
	rm -r $cm_path/vendor/sony/$d/proprietary
	cp -a $aosp_path/vendor/sony/$d/proprietary $cm_path/vendor/sony/$d/
	rm $cm_path/vendor/sony/$d/proprietary/Android.mk
done

# family common
rm -r $cm_path/vendor/sony/${common}-common/proprietary
cp -a $aosp_path/vendor/sony/$common/proprietary $cm_path/vendor/sony/${common}-common/

# vendor/qcom
for qd in $qcom_dirs; do
	cp -a $aosp_path/vendor/qcom/prebuilt/proprietary/$qd/* $cm_path/vendor/sony/${common}-common/proprietary/
done
rm $cm_path/vendor/sony/${common}-common/proprietary/Android.mk
