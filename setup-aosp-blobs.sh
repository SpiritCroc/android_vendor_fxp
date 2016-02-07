#!/bin/bash
# Copy the blobs, and generate the proprietary file list

set -o errexit

arg="${1}"

usage() {
	echo "Usage: ${0} <family>"
	echo "Valid options: rhine shinano msm8974 yukon kitakami"
	exit
}

[[ -z ${arg} ]] && usage

aosp_path=${AOSP_PATH:-~/android/aosp/6.0}

platforms="kitakami shinano rhine yukon"
kitakami_devices="ivy karin sumire suzuran" # satsuki
shinano_devices="sirius castor leo aries scorpion"
rhine_devices="amami honami togari"
yukon_devices="eagle tianchi seagull flamingo"

get_lunch_combo() {
	device=${1}
	echo `tail -n1 device/sony/${device}/vendorsetup.sh | sed s/add_lunch_combo\ //g`
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

pushd ${aosp_path}
export OUT_DIR_COMMON_BASE=$(mktemp -d)
. build/envsetup.sh
make -j8 acp

# Generate file list
for c in $common; do
	for d in ${devices}; do
		lunch `get_lunch_combo $d`
		mmm -Bj8 vendor/fxp
		rm -rf ${OUT}
	done
done

# Copy blobs
FP=$(cd ${0%/*} && pwd -P)
for c in $common; do
	${FP}/copy-aosp-blobs.sh $c
done

rm -rf ${OUT_DIR_COMMON_BASE}
unset OUT_DIR_COMMON_BASE
popd