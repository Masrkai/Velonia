
#? Clear Journald:
function clearjournal(){
    sudo journalctl --rotate && sudo journalctl --vacuum-time=1s
}


#?  Journald errors:
function journalctle() {
# Check for required tools
if ! command -v journalctl &> /dev/null; then
    echo "Error: journalctl is not available on your system."
    return 1
fi

if ! command -v bat &> /dev/null && ! command -v less &> /dev/null; then
    echo "Error: Neither 'bat' nor 'less' is installed. Install one to view highlighted output."
    return 1
fi

# Retrieve journald errors
local errors
errors=$(journalctl -p err -b | awk '!seen[$0]++') # Get errors from the current boot and remove duplicates

if [[ -z "$errors" ]]; then
    echo "No errors found in the journal for the current boot."
    return 0
fi

# Output with syntax highlighting
if command -v bat &> /dev/null; then
    echo "$errors" | bat --paging=always --language=log
else
    echo "$errors" | less -R
fi
}


#? Journald warnings:
function journalctlw() {
# Check for required tools
if ! command -v journalctl &> /dev/null; then
    echo "Error: journalctl is not available on your system."
    return 1
fi

if ! command -v bat &> /dev/null && ! command -v less &> /dev/null; then
    echo "Error: Neither 'bat' nor 'less' is installed. Install one to view highlighted output."
    return 1
fi

# Retrieve journald warnings
local warnings
warnings=$(journalctl -p warning -b | awk '{message = $0; for (i=1; i<=4; i++) sub(/^[^ ]+ /, "", message); if (!seen[message]++) print message}')

if [[ -z "$warnings" ]]; then
    echo "No warnings found in the journal for the current boot."
    return 0
fi

# Output with syntax highlighting
if command -v bat &> /dev/null; then
    echo "$warnings" | bat --paging=always --language=log
else
    echo "$warnings" | less -R
fi
}
