#!/usr/bin/env bash
set -euo pipefail

# Quick test playlist for the optimized player
# Usage: bash testrun.sh /path/to/project

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${1:-$SCRIPT_DIR}"

RUN_SH="$ROOT_DIR/run.sh"
DATA_DIR="$ROOT_DIR/data"

BG="$DATA_DIR/background.jpg"
V1="$DATA_DIR/test1.mp4"
V2="$DATA_DIR/test2.mp4"

if [ ! -x "$RUN_SH" ]; then
  echo "run.sh not found at $RUN_SH" >&2
  exit 1
fi

echo "Starting GUI..."
"$RUN_SH" start "$BG"

echo "Playing test videos..."
"$RUN_SH" play "$V1" 10
"$RUN_SH" play "$V2" 10

echo "Stopping and exiting..."
"$RUN_SH" stop || true
"$RUN_SH" exit || true

echo "Done."

