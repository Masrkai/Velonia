
s() {
    if [[ $# == 0 ]]; then
        local last_cmd=$(fc -ln -1)
        # Strip leading/trailing whitespace
        last_cmd="${last_cmd#"${last_cmd%%[![:space:]]*}"}"
        last_cmd="${last_cmd%"${last_cmd##*[![:space:]]}"}"

        # Check if the last command was already 's' or starts with 'sudo'
        if [[ "$last_cmd" == "s" ]] || [[ "$last_cmd" == s\ * ]] || [[ "$last_cmd" == sudo\ * ]]; then
            # Get the second-to-last command instead
            last_cmd=$(fc -ln -2 | head -n 1)
            last_cmd="${last_cmd#"${last_cmd%%[![:space:]]*}"}"
            last_cmd="${last_cmd%"${last_cmd##*[![:space:]]}"}"
        fi

        # Remove 'sudo' prefix if it exists
        if [[ "$last_cmd" == sudo\ * ]]; then
            last_cmd="${last_cmd#sudo }"
        fi

        eval "sudo $last_cmd"
    else
        sudo "$@"
    fi
}
