#!/usr/bin/env bash
# Clear tmux-ai-status state and remove status suffix from windows.

set -euo pipefail

STATE_DIR="${TMUX_AI_STATUS_DIR:-/tmp/tmux-ai-status}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

rm -rf "$STATE_DIR"
mkdir -p "$STATE_DIR"

command -v tmux >/dev/null 2>&1 || exit 0

while IFS= read -r WINDOW_ID; do
  "$SCRIPT_DIR/update_window.sh" "$WINDOW_ID" || true
done < <(tmux list-windows -a -F "#{window_id}" 2>/dev/null || true)
