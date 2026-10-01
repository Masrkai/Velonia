usb_power_map() {
    # Create a lookup table from lsusb output
    declare -A device_names
    while IFS= read -r line; do
        if [[ $line =~ ID\ ([0-9a-f]{4}):([0-9a-f]{4})\ (.+)$ ]]; then
            vendor="${BASH_REMATCH[1]}"
            product="${BASH_REMATCH[2]}"
            name="${BASH_REMATCH[3]}"
            device_names["${vendor}:${product}"]="$name"
        fi
    done < <(lsusb)

    # Now iterate through sysfs devices
    for dev in /sys/bus/usb/devices/*; do
        if [ -f "$dev/idVendor" ]; then
            vendor=$(cat "$dev/idVendor")
            product=$(cat "$dev/idProduct")
            power=$(cat "$dev/power/control" 2>/dev/null)
            vid_pid="${vendor}:${product}"
            name="${device_names[$vid_pid]:-Unknown Device}"

            printf "%-15s %s - power: %s\n" "$(basename $dev):" "$vid_pid $name" "$power"
        fi
    done | sort
}