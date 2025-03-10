#!/system/bin/sh

# Generate the idc file for touchscreens based on libwacom data

# Author: Jon West <electrikjesus@gmail.com>

# Get local path
DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
COUNT=0

# cleanup old files
rm -rf $DIR/idc/*

# pull the latest libwacom data from linux-surface
mkdir -p /tmp/libwacom
cd /tmp/libwacom
git clone https://github.com/linux-surface/libwacom.git
cd libwacom

# Grab the data for all touchscreens
tablet_files=$(find /tmp/libwacom/libwacom -name "*.tablet")

for tablet_file in $tablet_files; do
    has_touch=$(cat "$tablet_file" | grep "Touch=true")
    if [ -n "$has_touch" ]; then
        product_name=$(cat "$tablet_file" | grep "^Name=" | cut -d '=' -f 2)
        device_match_line=$(cat "$tablet_file" | grep "^DeviceMatch")
        device_matches=(${device_match_line//;/ })

        if [[ $product_name =~ "ISDv4" ]]; then
            first_word="isdv4"
        else
            product_name_words=(${product_name//[^[:alpha:]-]/ })
            first_word=${product_name_words[0]}
            first_word=$(echo "$first_word" | tr '[:upper:]' '[:lower:]')
        fi

        for device_match in "${device_matches[@]}"; do
          if [[ $device_match =~ "Stylus" ]]; then
            continue
          fi
          parts=(${device_match//|/ })
          vendor_id=${parts[1]}
          product_id=${parts[2]}
          echo "Device: $product_name; ID: $vendor_id $product_id"
          if [[ "$vendor_id" == "" ]] || [[ "$product_id" == "" ]]; then
            continue
          fi
          # Create the idc file
          mkdir -p $DIR/idc/$first_word

          echo "# $product_name
# Android input device config file
device.internal = 1
touch.deviceType = touchScreen

" > $DIR/idc/$first_word/Vendor_${vendor_id}_Product_${product_id}.idc
          COUNT=$((COUNT+1))

        done
    fi
done

echo "Generated $COUNT idc files"
# Clean up
rm -rf /tmp/libwacom