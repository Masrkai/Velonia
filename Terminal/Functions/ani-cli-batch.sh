#NIXPKGS ani-cli

# Anime Batch Downloader Function
ani-cli-batch() {
    #############################################
    # Anime Batch Downloader v3 (Robust)
    # Strategy: Force specific result + Episode loops
    #############################################

    # --- CONFIGURATION ---
    local SEARCH_QUERY="$1"
    local ANIME_RESULT_INDEX="${2:-1}"
    local START_EPISODE="${3:-1}"
    local LOG_FILE="batch_download.log"

    # Quality priority (Highest to Lowest)
    local QUALITIES=("1080p" "720p" "480p" "360p")

    # --- COLORS ---
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local RED='\033[0;31m'
    local NC='\033[0m'

    # --- HELPER FUNCTIONS ---
    log() {
        echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
    }

    warn() {
        echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
    }

    error() {
        echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
    }

    # --- VALIDATION ---
    if [[ -z "$SEARCH_QUERY" ]]; then
        echo -e "${RED}Error: No search query provided.${NC}"
        echo "Usage: anime-batch \"Anime Name\" [Result Index] [Start Episode]"
        echo "Example: anime-batch \"Majo to Yajuu\" 1 1"
        return 1
    fi

    # --- CONFIRMATION ---
    echo "--------------------------------------------------------"
    log "Initializing Batch Download"
    echo "--------------------------------------------------------"
    echo "Search Query: $SEARCH_QUERY"
    echo "Auto-selecting Result #$ANIME_RESULT_INDEX"
    echo "Starting at Episode: $START_EPISODE"
    echo "--------------------------------------------------------"
    read -p "Press Enter to start, or Ctrl+C to cancel..."

    local CURRENT_EP=$START_EPISODE

    # --- MAIN LOOP ---
    while true; do
        local SUCCESS=0

        # Try each quality until one works
        for QUALITY in "${QUALITIES[@]}"; do
            log "Trying Episode $CURRENT_EP in $QUALITY (Result #$ANIME_RESULT_INDEX)..."

            ani-cli \
                --select-nth "$ANIME_RESULT_INDEX" \
                --download \
                --episode "$CURRENT_EP" \
                --quality "$QUALITY" \
                "$SEARCH_QUERY"

            local EXIT_CODE=$?

            if [ $EXIT_CODE -eq 0 ]; then
                log "Successfully downloaded Episode $CURRENT_EP in $QUALITY"
                SUCCESS=1
                break
            else
                warn "Failed Episode $CURRENT_EP in $QUALITY (Exit Code: $EXIT_CODE)"
            fi
        done

        if [ $SUCCESS -eq 0 ]; then
            error "Failed to download Episode $CURRENT_EP in ALL qualities/sources."
            error "Assuming the series is finished or the source is down."
            break
        fi

        ((CURRENT_EP++))
    done

    log "Batch process finished."
}