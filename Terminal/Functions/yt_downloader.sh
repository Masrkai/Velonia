#NIXPKGS yt-dlp ffmpeg-full

#? Universal YouTube download function
download-youtube() {
    local url="$1"
    local resolution="${2:-1440}"  # Default to 1440p if no resolution is provided

    # Check if URL is provided
    if [ -z "$url" ]; then
        echo "Usage: download-youtube <url> [resolution]"
        echo "       download-playlist <url> [resolution]"
        echo "       download-video <url> [resolution]"
        echo "Example: download-youtube 'https://youtube.com/watch?v=...' 720"
        return 1
    fi

    # Determine output format based on function name used
    local output_format
    if [[ "${FUNCNAME[1]}" == "download-playlist" ]]; then
        output_format="%(playlist_index)s - %(title)s.%(ext)s"
    else
        output_format="%(title)s.%(ext)s"
    fi

    echo "Downloading with resolution: ${resolution}p"
    echo "Output format: $output_format"

    yt-dlp -f "bv[height<=${resolution}]+ba/b[height<=${resolution}]" \
           --sleep-interval 1 --max-sleep-interval 2 \
           --merge-output-format mp4 \
           --download-archive download_archive.txt \
           -o "$output_format" \
           "$url"
}

# Create aliases for the two function names
alias download-playlist='download-youtube'
alias download-video='download-youtube'
