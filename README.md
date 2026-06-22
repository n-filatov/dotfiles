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

## Install

Install or update the dotfiles in one command:

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/n-filatov/dotfiles/master/install.sh)"
```

The installer:

- clones or updates this repo at `~/dotfiles`
- creates symlinks for:
  - `~/.config/nvim -> ~/dotfiles/nvim`
  - `~/.tmux.conf -> ~/dotfiles/tmux/.tmux.conf`
  - `~/.tmux/plugins/tmux-ai-status -> ~/dotfiles/tmux/plugins/tmux-ai-status`
  - `~/.vimrc -> ~/dotfiles/.vimrc`
- backs up existing non-symlink files/directories to `~/.dotfiles-backup/<timestamp>/...`
- replaces stale symlinks that point somewhere else

Environment variables:

```sh
DOTFILES_DIR=~/src/dotfiles bash install.sh          # custom checkout location
DOTFILES_BACKUP_DIR=~/dotfiles-backups bash install.sh
DOTFILES_REPO_URL=https://github.com/n-filatov/dotfiles.git bash install.sh
```

If you already cloned the repo:

```sh
cd ~/dotfiles
./install.sh
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

On a new machine, use the installer above to clone dotfiles and create symlinks.

## tmux-ai-status

Appends an AI status icon to the tmux window name while preserving manual names. For example, `example` becomes `example 👨‍💻` while tools are running and returns to `example` when idle.

States: `thinking` → `🤔`, `working` → `👨‍💻`, `needs_approval` → `❓`, `error` → `⚠️`, `idle` → no icon.

### Setup

1. Run `./install.sh` to symlink `tmux/.tmux.conf` and `tmux/plugins/tmux-ai-status` into your home directory.
2. For Pi integration, install [`n-filatov/pi-workflow-extensions`](https://github.com/n-filatov/pi-workflow-extensions).
3. Optionally add hooks to `~/.claude/settings.json`:

```json
"hooks": {
  "PreToolUse": [{ "hooks": [{ "type": "command", "command": "~/.tmux/plugins/tmux-ai-status/scripts/set_state.sh working" }] }],
  "Stop":       [{ "hooks": [{ "type": "command", "command": "~/.tmux/plugins/tmux-ai-status/scripts/set_state.sh idle" }] }]
}
```

4. Optionally add hooks to `~/.codex/hooks.json` (requires `features.codex_hooks = true` in `~/.codex/config.toml`):

```json
{
  "PreToolUse": [{ "hooks": [{ "type": "command", "command": "~/.tmux/plugins/tmux-ai-status/scripts/set_state.sh working" }] }],
  "Stop":       [{ "hooks": [{ "type": "command", "command": "~/.tmux/plugins/tmux-ai-status/scripts/set_state.sh idle" }] }]
}
```
