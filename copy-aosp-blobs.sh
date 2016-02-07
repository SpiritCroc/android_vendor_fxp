#!/bin/bash
# Copy AOSP blobs to a CM tree

set -o errexit

arg="${1}"

usage() {
	echo "Usage: ${0} <family>"
	echo "Valid options: rhine shinano msm8974 yukon kitakami"
	exit
}

[[ -z ${arg} ]] && usage

aosp_path=${AOSP_PATH:-~/android/aosp/6.0}
cm_path=${CM_PATH:-~/android/cm/13}

kitakami_devices="ivy karin sumire suzuran" # satsuki
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
	rm_dst=${3:-false}
	if $rm_dst ; then
		rm -rf $cm_path/vendor/sony/$dst/proprietary
	fi
	mkdir -p $cm_path/vendor/sony/$dst/proprietary
	cp -a $aosp_path/vendor/$src $cm_path/vendor/sony/$dst/proprietary/
	rm $cm_path/vendor/sony/$dst/proprietary/Android.mk
}

case ${arg} in
	msm8974)
		common="rhine shinano"
		devices="${rhine_devices} ${shinano_devices}"
		;;
	shinano)
		common=shinano
		devices=${shinano_devices}
		;;
	rhine)
		common=rhine
		devices=${rhine_devices}
		;;
	kitakami)
		common=kitakami
		devices=${kitakami_devices}
		;;
	yukon)
		common=yukon
		devices=${yukon_devices}
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
			copy_a2c sony/shinano/msm8974ab/* $db
		done
		for dc in z3 z3c scorpion; do
			copy_a2c sony/shinano/msm8974ac/* $dc
		done
	fi
	copy_a2c sony/$c/proprietary/* $cm_c
done

# Sony vendor/qcom
eval qcom_dirs=\$${common}_qcom_dirs
for qd in $qcom_dirs; do
	for qc in $common; do
		cm_qc=${qc}-common
		[[ $c == yukon ]] && cm_qc=$qc
		[[ $c == rhine ]] && cm_qc=msm8974-common
		[[ $c == shinano ]] && cm_qc=msm8974-common
		copy_a2c qcom/prebuilt/proprietary/$qd/* $cm_qc
	done
done

# Modem firmware (vendor/qcom/proprietary)
for qfc in $common; do
	for qfd in $devices; do
		if [[ $qfc == yukon ]] ; then
			copy_a2c qcom/proprietary/msm8226/$qfd/* $qfd
		elif [[ $qfc == rhine ]] ; then
			copy_a2c qcom/proprietary/msm8974aa/$qfd/* $qfd
		elif [[ $qfc == shinano ]] ; then
			if [[ $qfd == sirius || $qfd == castor ]] ; then
				copy_a2c qcom/proprietary/msm8974ab/* $qfd
			elif [[ $qfd == scorpion ]] ; then
				copy_a2c qcom/proprietary/msm8974ac/* $qfd
			elif [[ $qfd == leo ]] ; then
				copy_a2c qcom/proprietary/msm8974ac/* z3
			elif [[ $qfd == aries ]] ; then
				copy_a2c qcom/proprietary/msm8974ac/* z3c
			fi
		fi
	done
done