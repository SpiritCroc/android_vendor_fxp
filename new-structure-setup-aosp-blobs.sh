#!/bin/bash
# Copy the blobs, and generate the proprietary file list
# As sony vendor files have a new structure, temporally restore old structure

aosp_path=${AOSP_PATH:-~/android/aosp/6.0}

vendor_path=$aosp_path/vendor/sony

dirs=("kanuti-common" "kanuti-tulip" "kitakami-common" "kitakami-ivy" "kitakami-karin" "kitakami-satsuki" "kitakami-sumire" "kitakami-suzuran" "rhine-amami" "rhine-common" "rhine-honami" "rhine-togari" "shinano-aries" "shinano-castor" "shinano-common" "shinano-leo" "shinano-scorpion" "shinano-sirius" "yukon-common" "yukon-eagle" "yukon-flamingo" "yukon-seagull" "yukon-tianchi")

legacy_dirs=("kanuti" "tulip" "kitakami" "ivy" "karin" "satsuki" "sumire" "suzuran" "amami" "rhine" "honami" "togari" "aries" "castor" "shinano" "leo" "scorpion" "sirius" "yukon" "eagle" "flamingo" "seagull" "tianchi")

execution_path=$PWD


echo "Create symlinks to represent the old structure"
cd "$vendor_path"
for (( i=0; i<${#dirs[@]}; i++ )); do
	#echo "${dirs[i]} -> ${legacy_dirs[i]}"
	ln -s "${dirs[i]}" "${legacy_dirs[i]}"
done
cd "$execution_path"


./setup-aosp-blobs.sh $1


echo "Remove symlinks to represent the old structure"
cd "$vendor_path"
for (( i=0; i<${#dirs[@]}; i++ )); do
	#echo "rm ${legacy_dirs[i]}"
	rm "$vendor_path/${legacy_dirs[i]}"
done
cd "$execution_path"
