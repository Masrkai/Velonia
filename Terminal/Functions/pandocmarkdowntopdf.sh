pandocmarkdowntopdf() {
    mkdir -p PDF || return 1

    local files=()
    if [ $# -eq 0 ]; then
        shopt -s nullglob
        files=(*.md)
        shopt -u nullglob  # restore default behavior
        if [ ${#files[@]} -eq 0 ]; then
            echo "No .md files found." >&2
            return 0
        fi
    else
        # Filter only existing .md files from arguments
        for f in "$@"; do
            if [[ "$f" == *.md ]] && [ -f "$f" ]; then
                files+=("$f")
            else
                echo "Skipping non-existent or non-.md file: '$f'" >&2
            fi
        done
        if [ ${#files[@]} -eq 0 ]; then
            echo "No valid .md files to convert." >&2
            return 0
        fi
    fi

    for file in "${files[@]}"; do
        echo "Converting: $file"
        pandoc "$file" \
            --pdf-engine=xelatex \
            --wrap=none \
            -V colorlinks=true \
            -V linkcolor=blue \
            -V pagestyle=empty \
            -V geometry:"a4paper, margin=1cm" \
            -V mainfont="FreeSans" \
            -V monofont="FreeMono" \
            -V mathfont="NewComputerModernMath" \
            --filter pandoc-include \
            --lua-filter="$PANDOC_DIAGRAM_FILTER" \
            -f markdown+tex_math_single_backslash+tex_math_double_backslash+tex_math_dollars+raw_tex+smart \
            -o "PDF/${file%.md}.pdf" \
            --number-sections \
            2>&1 | grep -vE "(Could not convert TeX math|rendering as TeX)"
    done
}

            # -V mainfontfallback="Noto Color Emoji:mode=harf" \
            # --pdf-engine-opt=-shell-escape \
            # -V minted=true \
            # -V mintedoptions="breaklines,breakanywhere" \