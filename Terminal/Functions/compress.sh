#NIXPKGS p7zip unzip gzip bzip2

SAVEIFS=$IFS
IFS="$(printf '\n\t')"

function compress {
    if [ $# -lt 3 ]; then
        echo "Usage: compress <compression_level> <format_flag> <path/file_name> [path/file_name_2] [path/file_name_3]"
        echo "Compression level: 1-9 for zip/7z/tar.lz, 1-9 for tar.gz"
        echo "Format flags: --zip, --tar.gz, --tar.lz, --7z, --tar.zst"
        return 1
    fi

    local level=$1
    local format_flag=$2
    shift 2
    local THREADS=$(nproc)

    # Progress bar display function
    progress_bar() {
        local percent=$1
        local filled=$((percent/2))
        printf "\r["
        printf "%${filled}s" | tr ' ' '='
        printf "%$((50-filled))s] %d%%" "" "$percent"
    }

    for n in "$@"; do
        if [ ! -f "$n" ] && [ ! -d "$n" ]; then
            echo "'$n' - file/directory doesn't exist"
            continue
        fi

        [[ "$level" =~ ^[0-9]+$ ]] || {
            echo "Invalid compression level. Must be a number."
            return 1
        }

        local filename=$(basename "$n")
        level=$((level > 9 ? 9 : level))

        echo "Compressing '$n' using $THREADS threads..."

        case "$format_flag" in

            "--7z")
                7z a -t7z -mx="$level" -mmt=on -bsp2 -bb0 "${filename}.7z" "$n"
                ;;

            "--zip")
                7z a -tzip -mx="$level" -mmt=on -bsp2 -bb1 "${filename}.zip" "$n"
                ;;

            "--tar.gz")
                local size=$(du -sb "$n" 2>/dev/null | awk '{print $1}')
                if [ -z "$size" ]; then
                    local pv_cmd="pv"
                else
                    local pv_cmd="pv -s $size"
                fi

                if command -v pigz >/dev/null; then
                    # Optimized pigz with block size and rsyncable
                    tar cf - "$n" | eval "$pv_cmd" | pigz -"$level" -p"$THREADS" --rsyncable -b 128 > "${filename}.tar.gz"
                else
                    echo "Notice: pigz not found, using single-threaded gzip"
                    tar cf - "$n" | eval "$pv_cmd" | gzip -"$level" > "${filename}.tar.gz"
                fi
                ;;

            "--tar.lz")
                if command -v pv >/dev/null && tarlz -h 2>&1 | grep -q -- '-f-'; then
                    local size=$(du -sb "$n" 2>/dev/null | awk '{print $1}')
                    [ -z "$size" ] && size=0
                    tarlz -c -n "$THREADS" --solid -"$level" -f- "$n" | pv -s "$size" > "${filename}.tar.lz"
                else
                    echo "Progress not available for tar.lz format"
                    tarlz -c -n "$THREADS" --solid -"$level" -f "${filename}.tar.lz" "$n"
                fi
                ;;

            "--tar.zst")
                local size=$(du -sb "$n" 2>/dev/null | awk '{print $1}')
                if [ -z "$size" ]; then
                    local pv_cmd="pv"
                else
                    local pv_cmd="pv -s $size"
                fi
                
                if command -v zstd >/dev/null; then
                    # Optimized zstd with adaptive mode
                    tar cf - "$n" | eval "$pv_cmd" | zstd -"$level" -T"$THREADS" --adapt > "${filename}.tar.zst"
                else
                    echo "Error: zstd not installed"
                    return 1
                fi
                ;;

            *)
                echo "Invalid format flag. Must be
                                                   --7z.
                                                   --zip,
                                                   --tar.gz, --tar.lz, --tar.zst
                "
                return 1
                ;;
        esac
    done
}

IFS=$SAVEIFS