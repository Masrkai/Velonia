convert_ppts_to_pdf() {
    local input_dir="${1:-.}"  # Default to current directory
    local output_dir="${2:-$input_dir}"  # Default to the input directory

    # Check if LibreOffice is installed
    if ! command -v libreoffice &> /dev/null; then
        echo "Error: LibreOffice is not installed" >&2
        return 1
    fi

    # Check if input directory exists
    if [ ! -d "$input_dir" ]; then
        echo "Error: Input directory '$input_dir' not found" >&2
        return 1
    fi

    # Create the output directory if it doesn't exist
    if [ ! -d "$output_dir" ]; then
        mkdir -p "$output_dir" || { echo "Error: Could not create output directory '$output_dir'"; return 1; }
    fi

    # Counter for converted files
    local converted=0

    # Use find with -exec to avoid subshell issues
    find "$input_dir" -type f \( -iname "*.ppt" -o -iname "*.pptx" \) -exec bash -c '
        file="$1"
        output_dir="$2"
        echo "Converting: $file"
        libreoffice --headless --convert-to pdf "$file" --outdir "$output_dir"
        if [ $? -eq 0 ]; then
            echo "Successfully converted: $file"
            return 0
        else
            echo "Failed to convert: $file"
            return 1
        fi
    ' _ {} "$output_dir" \; && ((converted++))

    echo "Conversion complete. Converted $converted files."
    return 0
}
