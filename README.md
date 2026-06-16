# dotfiles

Personal dotfiles.

## Structure

```
nvim/                                # Neovim config, symlink to ~/.config/nvim
tmux/
  .tmux.conf                         # tmux config
  plugins/
    tmux-ai-status/                  # Appends AI status icons to tmux window names
      tmux-ai-status.tmux
      scripts/
        set_state.sh                 # Called by agent hooks/extensions
        update_window.sh             # Updates window name icon suffix
        reset.sh                     # Clears plugin state and suffixes
```

## Neovim

`~/.config/nvim` is a symlink to `~/dotfiles/nvim`.

### Sync workflow

After changing Neovim config, commit and push from the dotfiles repo:

```sh
cd ~/dotfiles
git status
git add nvim
git commit -m "Update nvim config"
git push
```

On a new machine, clone dotfiles and link Neovim config:

```sh
git clone git@github.com:n-filatov/dotfiles.git ~/dotfiles
mkdir -p ~/.config
ln -sfn ~/dotfiles/nvim ~/.config/nvim
```

## tmux-ai-status

Appends an AI status icon to the tmux window name while preserving manual names. For example, `example` becomes `example 👨‍💻` while tools are running and returns to `example` when idle.

States: `thinking` → `🤔`, `working` → `👨‍💻`, `needs_approval` → `❓`, `error` → `⚠️`, `idle` → no icon.

### Setup

1. Copy `tmux/plugins/tmux-ai-status` to `~/.tmux/plugins/`
2. Copy `tmux/.tmux.conf` to `~/.tmux.conf` (or source it)
3. For Pi integration, install [`n-filatov/pi-workflow-extensions`](https://github.com/n-filatov/pi-workflow-extensions)
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
