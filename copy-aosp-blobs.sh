#!/bin/bash
# Copy AOSP blobs to a CM tree

set -o errexit
set -x

arg="${1}"

usage() {
	echo "Usage: ${0} <family>"
	echo "Valid options: rhine shinano msm8974 yukon kitakami"
	exit
}

[[ -z ${arg} ]] && usage

aosp_path=${AOSP_PATH:-~/android/aosp/6.0}
cm_path=${CM_PATH:-~/android/cm/13}

kitakami_devices="ivy karin sumire suzuran satsuki"
kitakami_qcom_dirs="msm8994 adreno/a4xx firmware"

shinano_devices="sirius castor leo aries scorpion"
shinano_qcom_dirs="msm8974 adreno/a3xx firmware"

rhine_devices="amami honami togari"
rhine_qcom_dirs="msm8974 adreno/a3xx firmware"

yukon_devices="eagle tianchi seagull flamingo"
yukon_qcom_dirs="msm8226 adreno/a3xx firmware"

copy_a2c() {
	src=$1
	dst=$2
	if $3 ; then
		rm -rf $cm_path/vendor/sony/$dst/proprietary
		mkdir -p $cm_path/vendor/sony/$dst/proprietary
	fi
	cp -a $aosp_path/vendor/$src $cm_path/vendor/sony/$dst/proprietary/
	rm $cm_path/vendor/sony/$dst/proprietary/Android.mk
}

case ${arg} in
	msm8974)
		common="rhine shinano"
		devices="sirius castor leo aries scorpion amami honami togari"
		;;
	shinano)
		common=shinano
		devices="sirius castor leo aries scorpion"
		;;
	rhine)
		common=rhine
		devices="amami honami togari"
		;;
	kitakami)
		common=kitakami
		devices="ivy karin sumire suzuran satsuki"
		;;
	yukon)
		common=yukon
		devices="eagle tianchi seagull flamingo"
		;;
	*)
		usage
		;;
esac

# Individual devices
for d in $devices; do
	cm_d=$d
	[[ $d == leo ]] && cm_d=z3
	[[ $d == aries ]] && cm_d=z3c
	copy_a2c sony/$d/proprietary/* $cm_d true
done

# family common
for c in $common; do
	cm_c=${c}-common
	[[ $c == yukon ]] && cm_c=$c
	if [[ $c == shinano ]]; then
		for db in sirius castor; do
			copy_a2c sony/shinano/msm8974ab/* $db false
		done
		for dc in z3 z3c scorpion; do
			copy_a2c sony/shinano/msm8974ac/* $dc false
		done
	fi
	copy_a2c sony/$c/proprietary/* $cm_c false
done

# vendor/qcom
eval qcom_dirs=\$${common}_qcom_dirs
for qd in $qcom_dirs; do
	for qc in $common; do
		cm_qc=${qc}-common
		[[ $c == yukon ]] && cm_qc=$qc
		[[ $c == rhine ]] && cm_qc=msm8974-common
		[[ $c == shinano ]] && cm_qc=msm8974-common
		copy_a2c qcom/prebuilt/proprietary/$qd/* $cm_qc false
	done
done
