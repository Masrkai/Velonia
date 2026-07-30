
sectorcopy() {
    local directory="."
    local maxdepth=1

    while getopts "d:m:h" opt; do
        case $opt in
            d) directory="$OPTARG" ;;
            m) maxdepth="$OPTARG" ;;
            h) echo "Usage: sectorcopy [-d directory] [-m maxdepth] <extension...>"; return 0 ;;
            *) return 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    local extensions=("$@")
    if [[ ${#extensions[@]} -eq 0 ]]; then
        echo "Usage: sectorcopy [-d directory] [-m maxdepth] <extension...>" >&2
        return 1
    fi

    local find_expr=()
    for ext in "${extensions[@]}"; do
        ext="${ext#.}"
        if [[ ${#find_expr[@]} -gt 0 ]]; then
            find_expr+=(-o)
        fi
        find_expr+=(-name "*.$ext")
    done

    local files=()
    while IFS= read -r -d '' file; do
        files+=("$file")
    done < <(find "$directory" -maxdepth "$maxdepth" -type f \( "${find_expr[@]}" \) -print0 | sort -z)

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