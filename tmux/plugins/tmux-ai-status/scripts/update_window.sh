#!/usr/bin/env bash
# Reads all pane states for a window and appends/removes a status icon suffix.
# Preserves the user-managed tmux window name.
# Priority: needs_approval (❓) > error (⚠️) > working/tool (👨‍💻) > thinking (🤔) > idle (no icon)

set -euo pipefail

WINDOW_ID=${1:-}
STATE_DIR="${TMUX_AI_STATUS_DIR:-/tmp/tmux-ai-status}"

[ -z "$WINDOW_ID" ] && exit 0
command -v tmux >/dev/null 2>&1 || exit 0

# If the target window no longer exists, do nothing.
tmux display-message -p -t "$WINDOW_ID" "#{window_id}" >/dev/null 2>&1 || exit 0

mkdir -p "$STATE_DIR"

# Cleanup state files for panes that no longer exist. Pane files are named like %29.
for STATE_FILE in "$STATE_DIR"/%*; do
  [ -e "$STATE_FILE" ] || continue
  PANE_ID=$(basename "$STATE_FILE")
  tmux display-message -p -t "$PANE_ID" "#{pane_id}" >/dev/null 2>&1 || rm -f "$STATE_FILE"
done

# Scan panes for highest-priority state.
ICON=""
while IFS= read -r PANE_ID; do
  STATE_FILE="${STATE_DIR}/${PANE_ID}"
  [ ! -f "$STATE_FILE" ] && continue
  STATE=$(cat "$STATE_FILE" 2>/dev/null || true)
  case "$STATE" in
    needs_approval|approval|confirm|question)
      ICON="❓"
      break
      ;;
    error|failed|failure)
      [ -z "$ICON" ] && ICON="⚠️"
      ;;
    working|tool|tools|running)
      case "$ICON" in ""|"🤔") ICON="👨‍💻" ;; esac
      ;;
    thinking|responding)
      [ -z "$ICON" ] && ICON="🤔"
      ;;
    idle|done|stopped|stop|clear|"")
      ;;
  esac
done < <(tmux list-panes -t "$WINDOW_ID" -F "#{pane_id}" 2>/dev/null || true)

CURRENT=$(tmux display-message -p -t "$WINDOW_ID" "#{window_name}" 2>/dev/null || printf '')

# Remove only this plugin's known trailing status suffix. This preserves manual names.
# Repeat to handle old duplicated suffixes from previous versions.
BASE_NAME="$CURRENT"
while :; do
  NEXT=$(printf '%s' "$BASE_NAME" | sed -E 's/[[:space:]]*(👨‍💻|🤔|🔧|❓|⚠️|💤)[[:space:]]*$//')
  [ "$NEXT" = "$BASE_NAME" ] && break
  BASE_NAME="$NEXT"
done

if [ -n "$ICON" ]; then
  tmux rename-window -t "$WINDOW_ID" "${BASE_NAME} ${ICON}"
else
  tmux rename-window -t "$WINDOW_ID" "$BASE_NAME"
fi
