#NIXPKGS p7zip unzip gzip bzip2

# Function to extract various archive formats
# Usage: extract [-d <output_directory>] <archive_file1> [<archive_file2> ...]
extract() {
    local SAVEIFS=$IFS
    IFS="$(printf '\n\t')"

    local dest_dir="."  # Default destination is current directory
    local opt

    # Parse command-line options
    while getopts ":d:" opt; do
        case $opt in
            d)
                dest_dir="$OPTARG"
                if [[ ! -d "$dest_dir" ]]; then
                    echo "extract: Destination directory '$dest_dir' does not exist. Creating it."
                    mkdir -p "$dest_dir" || { echo "extract: Failed to create directory '$dest_dir'"; return 1; }
                fi
                if [[ "$dest_dir" != /* ]]; then
                    dest_dir="$PWD/$dest_dir"
                fi
                ;;
            \?)
                echo "extract: Invalid option -$OPTARG" >&2
                echo "Usage: extract [-d <output_directory>] <path/file_name.ext> ..." >&2
                return 1
                ;;
            :)
                echo "extract: Option -$OPTARG requires an argument." >&2
                return 1
                ;;
        esac
    done
    shift $((OPTIND - 1))

    if [ $# -eq 0 ]; then
        echo "Usage: extract [-d <output_directory>] <path/file_name>.<zip|tar|gz|...>"
        return 1
    fi

    for n in "$@"; do
        if [ ! -f "$n" ]; then
            echo "extract: '$n' - file doesn't exist"
            continue
        fi

        echo "extract: Attempting to extract '$n' to '$dest_dir'..."
        case "${n%,}" in
            *.tar.bz2|*.tar.gz|*.tar.xz|*.tbz2|*.tgz|*.txz|*.tar)
                tar --checkpoint=1000 --checkpoint-action=dot -xf "$n" -C "$dest_dir"
                ;;
            *.lzma)  unlzma -c "$n" > "$dest_dir/${n%.lzma}" ;;
            *.bz2)   bunzip2 -c "$n" > "$dest_dir/${n%.bz2}" ;;
            *.gz)    gunzip -c "$n" > "$dest_dir/${n%.gz}" ;;
            *.rar|*.cbr) unrar x "$n" "$dest_dir/" ;;
            *.zip|*.cbz|*.epub) unzip -q -o "$n" -d "$dest_dir" ;;
            *.7z|*.iso|*.deb|*.rpm|*.apk|*.cab) 7z x -bsp1 -y -o"$dest_dir" "$n" ;;
            *.xz)    unxz -c "$n" > "$dest_dir/${n%.xz}" ;;
            *.zst)   zstd -d "$n" -o "$dest_dir/${n%.zst}" ;;
            *.tar.zst) tar -I zstd --checkpoint=1000 --checkpoint-action=dot -xvf "$n" -C "$dest_dir" ;;
            *) echo "extract: '$n' - unknown archive type" ;;
        esac

        if [ $? -eq 0 ]; then
            echo "extract: Successfully extracted '$n' to '$dest_dir'"
        else
            echo "extract: Failed to extract '$n'"
        fi
    done

    IFS=$SAVEIFS
}
