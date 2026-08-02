sectorcopy () {
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
                echo "Usage: sectorcopy [-d directory] [-m maxdepth] [-e exclude_pattern]... <extension...>"
                echo "  -e: exclude directories matching the given glob pattern (can be repeated)"
                return 0
                ;;
            *) return 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    local extensions=("$@")
    if [[ ${#extensions[@]} -eq 0 ]]; then
        echo "Usage: sectorcopy [-d directory] [-m maxdepth] [-e exclude]... <extension...>" >&2
        return 1
    fi

    # Build extension filter for find
    local find_expr=()
    for ext in "${extensions[@]}"; do
        ext="${ext#.}"
        if [[ ${#find_expr[@]} -gt 0 ]]; then
            find_expr+=(-o)
        fi
        find_expr+=(-name "*.$ext")
    done

    # Build the prune part for excluded directories
    # For each pattern, we add: -name "pattern" -prune -o
    local prune_expr=()
    for pat in "${exclude_patterns[@]}"; do
        prune_expr+=(-name "$pat" -prune -o)
    done

    # The final find command:
    #   ( prune_expr ... -type f ) -a ( extension filter ) -print0
    # This prunes directories that match any -e pattern, and only selects
    # regular files with the given extensions.
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