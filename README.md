# dotfiles

Personal dotfiles.

## Structure

```
tmux/
  .tmux.conf                         # tmux config
  plugins/
    tmux-ai-status/                  # Appends AI status icons to tmux window names
      tmux-ai-status.tmux
      scripts/
        set_state.sh                 # Called by agent hooks/extensions
        update_window.sh             # Updates window name icon suffix
        reset.sh                     # Clears plugin state and suffixes
pi/
  extensions/
    tmux-ai-status.ts                # Pi integration for tmux-ai-status
```

## tmux-ai-status

Appends an AI status icon to the tmux window name while preserving manual names. For example, `example` becomes `example 👨‍💻` while tools are running and returns to `example` when idle.

States: `thinking` → `🤔`, `working` → `👨‍💻`, `needs_approval` → `❓`, `error` → `⚠️`, `idle` → no icon.

### Setup

1. Copy `tmux/plugins/tmux-ai-status` to `~/.tmux/plugins/`
2. Copy `tmux/.tmux.conf` to `~/.tmux.conf` (or source it)
3. For Pi, copy `pi/extensions/tmux-ai-status.ts` to `~/.pi/agent/extensions/` and run `/reload`
4. Optionally add hooks to `~/.claude/settings.json`:

```json
"hooks": {
  "PreToolUse": [{ "hooks": [{ "type": "command", "command": "~/.tmux/plugins/tmux-ai-status/scripts/set_state.sh working" }] }],
  "Stop":       [{ "hooks": [{ "type": "command", "command": "~/.tmux/plugins/tmux-ai-status/scripts/set_state.sh idle" }] }]
}
```

5. Optionally add hooks to `~/.codex/hooks.json` (requires `features.codex_hooks = true` in `~/.codex/config.toml`):

```json
{
  "PreToolUse": [{ "hooks": [{ "type": "command", "command": "~/.tmux/plugins/tmux-ai-status/scripts/set_state.sh working" }] }],
  "Stop":       [{ "hooks": [{ "type": "command", "command": "~/.tmux/plugins/tmux-ai-status/scripts/set_state.sh idle" }] }]
}
```
