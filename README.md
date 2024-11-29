# Generate .idc files from libwacom data

This project is a simple script to download the latest libwacom data from linux-surface, and then create the required touchscreen .idc files for each device, separated by vendor. 

## How To

Clone this repo, and cd into it. Then do:
```
bash gen_idc_files.sh
```

The resulting .idc files will be in the project folder under idc/vendor_name/*