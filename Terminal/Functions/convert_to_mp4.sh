#NIXPKGS ffmpeg-full

# Function to convert video files to MP4 with baseline profile
convert_to_mp4() {
    # Check if input file is provided
    if [ $# -eq 0 ]; then
        echo "Usage: convert_to_mp4 <input_file>"
        echo "Example: convert_to_mp4 video.avi"
        return 1
    fi

    local input_file="$1"

    # Check if input file exists
    if [ ! -f "$input_file" ]; then
        echo "Error: File '$input_file' not found!"
        return 1
    fi

    # Extract filename without extension
    local filename=$(basename "$input_file")
    local name_without_ext="${filename%.*}"

    # Set output filename
    local output_file="${name_without_ext}.mp4"

    # Check if output file already exists
    if [ -f "$output_file" ]; then
        echo "Warning: Output file '$output_file' already exists!"
        read -p "Do you want to overwrite it? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Conversion cancelled."
            return 1
        fi
    fi

    echo "Converting '$input_file' to '$output_file'..."

   # Run the ffmpeg command (preserving baseline merits + new command benefits)
    ffmpeg -i "$input_file" \
           -c:v libx264 -profile:v baseline -level 3.0 -pix_fmt yuv420p \
           -vf "pad=ceil(iw/2)*2:ceil(ih/2)*2" \
           -c:a aac -ar 44100 -ac 2 \
           -movflags +faststart \
           "$output_file"

    # Check if conversion was successful
    if [ $? -eq 0 ]; then
        echo "✅ Conversion completed successfully: '$output_file'"
    else
        echo "❌ Conversion failed!"
        return 1
    fi
}