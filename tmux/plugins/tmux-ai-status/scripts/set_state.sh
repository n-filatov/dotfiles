#!/usr/bin/env bash
# Called by agent integrations. Writes current tmux pane state, then refreshes window icon.
# Usage: set_state.sh <thinking|working|needs_approval|error|idle>

set -euo pipefail

STATE=${1:-idle}
PANE_ID="${TMUX_PANE:-}"
STATE_DIR="${TMUX_AI_STATUS_DIR:-/tmp/tmux-ai-status}"

[ -z "$PANE_ID" ] && exit 0
command -v tmux >/dev/null 2>&1 || exit 0

mkdir -p "$STATE_DIR"

case "$STATE" in
  idle|done|stopped|stop|clear|"")
    rm -f "${STATE_DIR}/${PANE_ID}"
    ;;
  thinking|responding|working|tool|tools|running|needs_approval|approval|confirm|question|error|failed|failure)
    printf '%s' "$STATE" > "${STATE_DIR}/${PANE_ID}"
    ;;
  *)
    printf '%s' "$STATE" > "${STATE_DIR}/${PANE_ID}"
    ;;
esac

WINDOW_ID=$(tmux display-message -p -t "$PANE_ID" "#{window_id}" 2>/dev/null || true)
[ -z "$WINDOW_ID" ] && exit 0

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
"$PLUGIN_DIR/scripts/update_window.sh" "$WINDOW_ID"
