# Hardware detection script for NixOS
# Usage: detect-hardware.sh <output-file>

set -euo pipefail

# Colors
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

OUTPUT_FILE="${1:-/etc/nixos/Sec/hardware-detected.nix}"

if [ ! -r /sys/class/dmi/id/product_name ]; then
  echo "Could not detect hardware, using defaults" >&2
  exit 1
fi

PRODUCT_NAME=$(cat /sys/class/dmi/id/product_name | tr -d '[:space:]')
echo "Detected hardware: $PRODUCT_NAME"

# Hardware detection patterns
declare -A HARDWARE_PATTERNS=(
  ["ASUS_TUF"]="ASUSTUFGamingA15FA507NVR_FA507NVR"
  ["DELL_G15"]="DellG155510"
  ["THINKPAD"]="20UES5LB00"
  ["IDEAPAD_5"]="82FG"
)

# Detect hardware and set flags
declare -A FLAGS=(
  ["ASUS_TUF"]="false"
  ["DELL_G15"]="false"
  ["THINKPAD"]="false"
  ["IDEAPAD_5"]="false"
)

DETECTED=""

for hw in "${!HARDWARE_PATTERNS[@]}"; do
  pattern="${HARDWARE_PATTERNS[$hw]}"

  if [[ "$PRODUCT_NAME" == "$pattern" ]] || [[ "$PRODUCT_NAME" == *"$pattern"* ]]; then
    FLAGS[$hw]="true"
    DETECTED="$hw"
    break
  fi
done

# Write the hardware configuration file
cat > "$OUTPUT_FILE" << EOF
# Auto-generated hardware detection - DO NOT EDIT MANUALLY
{
  hardware.isAsusTuf = ${FLAGS[ASUS_TUF]};
  hardware.isDellG15 = ${FLAGS[DELL_G15]};
  hardware.isThinkPad = ${FLAGS[THINKPAD]};
  hardware.isIdeaPad5 = ${FLAGS[IDEAPAD_5]};
}
EOF

echo "Hardware config written to $OUTPUT_FILE"

# Display results with colors
for hw in ASUS_TUF DELL_G15 THINKPAD IDEAPAD_5; do
  label=$(echo "$hw" | tr '_' ' ')
  value="${FLAGS[$hw]}"

  if [ "$value" = "true" ]; then
    echo -e "${GREEN}✓ $label: $value${NC}"
  else
    echo -e "${ORANGE}✗ $label: $value${NC}"
  fi
done
