#!/usr/bin/env bash
# Called by Claude/Codex hooks. Writes pane state then refreshes the window icon.
STATE=$1
PANE_ID="${TMUX_PANE}"
[ -z "$PANE_ID" ] && exit 0

STATE_DIR="/tmp/tmux-ai-status"
mkdir -p "$STATE_DIR"
printf '%s' "$STATE" > "${STATE_DIR}/${PANE_ID}"

WINDOW_ID=$(tmux display-message -p -t "$PANE_ID" "#{window_id}" 2>/dev/null)
[ -z "$WINDOW_ID" ] && exit 0

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
"$PLUGIN_DIR/scripts/update_window.sh" "$WINDOW_ID"
