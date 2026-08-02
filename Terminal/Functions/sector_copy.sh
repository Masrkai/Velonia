sectorcopy() {
    local directory="."
    local maxdepth=1
    local -a exclude_patterns=()

    # Reset getopts index for this run
    local OPTIND=1

    while getopts "d:m:e:h" opt; do
        case $opt in
            d) directory="$OPTARG" ;;
            m) maxdepth="$OPTARG" ;;
            e) exclude_patterns+=("$OPTARG") ;;
            h)
                cat <<EOF
Usage: sectorcopy [-d directory] [-m maxdepth] [-e pattern]... <extension...>
  -d  Starting directory (default .)
  -m  Maximum search depth (default 1)
  -e  Exclude directories matching this glob pattern (may be repeated)
  -h  Show this help
Extensions are listed as separate arguments, e.g., txt md go
EOF
                return 0
                ;;
            *) return 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    local extensions=("$@")
    if [[ ${#extensions[@]} -eq 0 ]]; then
        echo "Usage: sectorcopy [-d directory] [-m maxdepth] [-e pattern]... <extension...>" >&2
        return 1
    fi

    # Build extension filter (-name "*.ext" -o ...)
    local find_expr=()
    for ext in "${extensions[@]}"; do
        ext="${ext#.}"                # remove leading dot if any
        if [[ ${#find_expr[@]} -gt 0 ]]; then
            find_expr+=(-o)
        fi
        find_expr+=(-name "*.$ext")
    done

    # Build prune expressions for excluded directories
    local prune_expr=()
    for pat in "${exclude_patterns[@]}"; do
        prune_expr+=(-name "$pat" -prune -o)
    done

    # Find files: apply prunes, then match extensions, and only regular files
    local files=()
    while IFS= read -r -d '' file; do
        files+=("$file")
    done < <(
        find "$directory" -maxdepth "$maxdepth" \
            \( "${prune_expr[@]}" -type f \) -a \
            \( "${find_expr[@]}" \) -print0 2>/dev/null | sort -z
    )

    if [[ ${#files[@]} -eq 0 ]]; then
        echo "No files found matching: ${extensions[*]}" >&2
        return 1
    fi

    # Build output and copy to clipboard
    {
        echo '```'
        for file in "${files[@]}"; do
            echo "${file#$directory/}"
        done
        echo '```'
        echo
        for file in "${files[@]}"; do
            echo "${file#$directory/}:"
            echo
            echo '```'
            cat "$file"
            echo '```'
            echo
        done
    } | wl-copy
}