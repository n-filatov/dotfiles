# dotfiles

Personal dotfiles.

## Structure

```
tmux/
  .tmux.conf                         # tmux config
  plugins/
    tmux-ai-status/                  # Shows 👨‍💻 in window name when Claude/Codex is working
      tmux-ai-status.tmux
      scripts/
        set_state.sh                 # Called by Claude/Codex hooks
        update_window.sh             # Updates window name icon
```

## tmux-ai-status

Shows `👨‍💻` in the tmux window name when Claude Code or Codex is actively running tools in any pane of that window. Clears the icon when the session stops.

### Setup

1. Copy `tmux/plugins/tmux-ai-status` to `~/.tmux/plugins/`
2. Copy `tmux/.tmux.conf` to `~/.tmux.conf` (or source it)
3. Add hooks to `~/.claude/settings.json`:

```json
"hooks": {
  "PreToolUse": [{ "hooks": [{ "type": "command", "command": "~/.tmux/plugins/tmux-ai-status/scripts/set_state.sh working" }] }],
  "Stop":       [{ "hooks": [{ "type": "command", "command": "~/.tmux/plugins/tmux-ai-status/scripts/set_state.sh idle" }] }]
}
```

4. Add hooks to `~/.codex/hooks.json` (requires `features.codex_hooks = true` in `~/.codex/config.toml`):

```json
{
  "PreToolUse": [{ "hooks": [{ "type": "command", "command": "~/.tmux/plugins/tmux-ai-status/scripts/set_state.sh working" }] }],
  "Stop":       [{ "hooks": [{ "type": "command", "command": "~/.tmux/plugins/tmux-ai-status/scripts/set_state.sh idle" }] }]
}
```
