#!/usr/bin/env bash
# Reads all pane states for a window and updates its name with the right icon.
# Priority: needs_approval (❓) > working (👨‍💻) > idle (no icon)

WINDOW_ID=$1
STATE_DIR="/tmp/tmux-ai-status"
SAFE_ID="${WINDOW_ID//@/}"
BASE_FILE="${STATE_DIR}/base_${SAFE_ID}"

# Capture the clean base name the first time we touch this window
if [ ! -f "$BASE_FILE" ]; then
  CURRENT=$(tmux display-message -p -t "$WINDOW_ID" "#{window_name}" 2>/dev/null)
  printf '%s' "$CURRENT" > "$BASE_FILE"
fi

BASE_NAME=$(cat "$BASE_FILE")

# Scan panes for highest-priority state
ICON=""
while IFS= read -r PANE_ID; do
  STATE_FILE="${STATE_DIR}/${PANE_ID}"
  [ ! -f "$STATE_FILE" ] && continue
  STATE=$(cat "$STATE_FILE")
  case "$STATE" in
    needs_approval)
      ICON="❓"
      break
      ;;
    working)
      ICON="👨‍💻"
      ;;
  esac
done < <(tmux list-panes -t "$WINDOW_ID" -F "#{pane_id}" 2>/dev/null)

if [ -n "$ICON" ]; then
  tmux rename-window -t "$WINDOW_ID" "${BASE_NAME} ${ICON}"
else
  tmux rename-window -t "$WINDOW_ID" "$BASE_NAME"
fi
