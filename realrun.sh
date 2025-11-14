#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLAYER="$SCRIPT_DIR/run.sh"
DATA_DIR="$SCRIPT_DIR/data"

BACKGROUND="$DATA_DIR/background.jpg"
PLAYLIST=(
  "$DATA_DIR/test1.mp4:20"
  "$DATA_DIR/test1.jpg:1"
  "$DATA_DIR/test2.jpg:1"
  "$DATA_DIR/test2.mp4:20"
)

STDOUT_LOG="/tmp/video_player_stdout.log"
STDERR_LOG="/tmp/video_player_stderr.log"
STDOUT_POS=0
STDERR_POS=0

reset_log_positions() {
    STDOUT_POS=0
    STDERR_POS=0
}

prepare_logs() {
    for log in "$STDOUT_LOG" "$STDERR_LOG"; do
        if [ -f "$log" ]; then
            rm -f "$log"
        fi
    done
    reset_log_positions
}

get_pos() {
    case "$1" in
        stdout) echo "$STDOUT_POS" ;;
        stderr) echo "$STDERR_POS" ;;
        *) echo 0 ;;
    esac
}

set_pos() {
    local key="$1"
    local value="$2"
    case "$key" in
        stdout) STDOUT_POS="$value" ;;
        stderr) STDERR_POS="$value" ;;
    esac
}

log_delta() {
    local label="$1"
    local file="$2"
    local key="$3"

    if [ ! -f "$file" ]; then
        echo "[$label] log file not created yet ($file)"
        return
    fi

    local size
    size=$(stat -c %s "$file" 2>/dev/null || echo 0)
    local last
    last=$(get_pos "$key")

    if [ "$size" -le "$last" ]; then
        echo "[$label] no new entries"
        return
    fi

    echo "[$label] new entries:"
    tail -c +$((last + 1)) "$file"
    set_pos "$key" "$size"
}

run_step() {
    local description="$1"
    shift

    echo ""
    echo "==== $description ===="
    "$@"
    sleep 0.5
    log_delta "GUI stdout" "$STDOUT_LOG" "stdout"
    log_delta "GUI stderr" "$STDERR_LOG" "stderr"
}

main() {
    if [ ! -x "$PLAYER" ]; then
        echo "Launcher not found at $PLAYER" >&2
        exit 1
    fi

    echo "Preparing diagnostic run..."
    prepare_logs

    if [ ! -f "$BACKGROUND" ]; then
        echo "Warning: background image missing at $BACKGROUND" >&2
    fi

    run_step "Starting GUI" "$PLAYER" start "$BACKGROUND"

    for entry in "${PLAYLIST[@]}"; do
        IFS=":" read -r filepath duration <<< "$entry"
        if [ ! -f "$filepath" ]; then
            echo "Skipping missing media $filepath" >&2
            continue
        fi
        run_step "Playing $(basename "$filepath") for ${duration}s" \
            "$PLAYER" play "$filepath" "$duration"
    done

    run_step "Stopping playback" "$PLAYER" stop
    run_step "Exiting GUI" "$PLAYER" exit

    echo ""
    echo "Diagnostics complete. Inspect full logs at:"
    echo "  $STDOUT_LOG"
    echo "  $STDERR_LOG"
}

main "$@"
