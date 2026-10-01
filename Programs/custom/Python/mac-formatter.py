import sys

def format_mac(mac_address):
    # Remove colons and convert to lowercase
    return mac_address.replace(':', '').lower()

# Check if MAC address is provided as argument
if len(sys.argv) != 2:
    print("Usage: python mac-formatter.py XX:XX:XX:XX:XX:XX")
    sys.exit(1)

mac = sys.argv[1]
formatted_mac = format_mac(mac)
print(f"Formatted: {formatted_mac}")