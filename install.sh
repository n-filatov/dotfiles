#!/usr/bin/env bash
set -euo pipefail

DOTFILES_REPO_URL="${DOTFILES_REPO_URL:-https://github.com/n-filatov/dotfiles.git}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
BACKUP_ROOT="${DOTFILES_BACKUP_DIR:-$HOME/.dotfiles-backup}"
SKIP_CLONE="${DOTFILES_SKIP_CLONE:-0}"

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarn:\033[0m %s\n' "$*" >&2; }
err() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; }

has_command() { command -v "$1" >/dev/null 2>&1; }

repo_root_from_script() {
  local source_dir
  source_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
  if [ -f "$source_dir/README.md" ] && [ -d "$source_dir/nvim" ] && [ -d "$source_dir/tmux" ]; then
    printf '%s\n' "$source_dir"
    return 0
  fi
  return 1
}

ensure_repo() {
  local script_repo=""
  script_repo="$(repo_root_from_script || true)"

  if [ -n "$script_repo" ]; then
    DOTFILES_DIR="$script_repo"
    log "Using dotfiles checkout at $DOTFILES_DIR"
    return 0
  fi

  if [ "$SKIP_CLONE" = "1" ]; then
    err "DOTFILES_SKIP_CLONE=1 but install.sh is not running from a dotfiles checkout"
    exit 1
  fi

  if ! has_command git; then
    err "git is required to clone $DOTFILES_REPO_URL"
    exit 1
  fi

  if [ -d "$DOTFILES_DIR/.git" ]; then
    log "Updating existing dotfiles checkout at $DOTFILES_DIR"
    git -C "$DOTFILES_DIR" pull --ff-only
  elif [ -e "$DOTFILES_DIR" ]; then
    err "$DOTFILES_DIR exists but is not a git checkout. Move it away or set DOTFILES_DIR."
    exit 1
  else
    log "Cloning dotfiles into $DOTFILES_DIR"
    git clone "$DOTFILES_REPO_URL" "$DOTFILES_DIR"
  fi
}

backup_path() {
  local path="$1"
  local ts rel dest
  ts="$(date +%Y%m%d-%H%M%S)"
  rel="${path#$HOME/}"
  dest="$BACKUP_ROOT/$ts/$rel"
  mkdir -p "$(dirname "$dest")"
  mv "$path" "$dest"
  warn "Backed up $path -> $dest"
}

link_path() {
  local src="$1"
  local dest="$2"

  if [ ! -e "$src" ]; then
    err "Source does not exist: $src"
    exit 1
  fi

  mkdir -p "$(dirname "$dest")"

  if [ -L "$dest" ]; then
    local current
    current="$(readlink "$dest")"
    if [ "$current" = "$src" ]; then
      log "Already linked: $dest -> $src"
      return 0
    fi
    rm "$dest"
    warn "Removed old symlink: $dest -> $current"
  elif [ -e "$dest" ]; then
    backup_path "$dest"
  fi

  ln -s "$src" "$dest"
  log "Linked: $dest -> $src"
}

install_dotfiles() {
  log "Installing dotfiles from $DOTFILES_DIR"

  link_path "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
  link_path "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
  link_path "$DOTFILES_DIR/tmux/plugins/tmux-ai-status" "$HOME/.tmux/plugins/tmux-ai-status"
  link_path "$DOTFILES_DIR/.vimrc" "$HOME/.vimrc"

  log "Done"
  printf '\nInstalled links:\n'
  printf '  ~/.config/nvim -> %s\n' "$DOTFILES_DIR/nvim"
  printf '  ~/.tmux.conf -> %s\n' "$DOTFILES_DIR/tmux/.tmux.conf"
  printf '  ~/.tmux/plugins/tmux-ai-status -> %s\n' "$DOTFILES_DIR/tmux/plugins/tmux-ai-status"
  printf '  ~/.vimrc -> %s\n' "$DOTFILES_DIR/.vimrc"
  printf '\nBackups, if any, are under: %s\n' "$BACKUP_ROOT"
}

main() {
  ensure_repo
  install_dotfiles
}

main "$@"
