#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$HOME/.macsetup-backup/$(date +%Y%m%d-%H%M%S)"
DRY_RUN=0
INSTALL_BREW=1
APPLY_MOS=0

usage() {
  cat <<'USAGE'
Usage: scripts/bootstrap-mac.sh [options]

Options:
  --dry-run       Show what would happen without changing files.
  --no-brew       Skip Homebrew installation and brew bundle.
  --apply-mos     Apply Mos defaults. Quit Mos before using this.
  -h, --help      Show this help.
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --no-brew) INSTALL_BREW=0 ;;
    --apply-mos) APPLY_MOS=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 2 ;;
  esac
  shift
done

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '[dry-run]'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

backup_path() {
  local target="$1"
  if [ -e "$target" ] || [ -L "$target" ]; then
    run mkdir -p "$BACKUP_DIR$(dirname "$target")"
    run mv "$target" "$BACKUP_DIR$target"
    echo "Backed up $target to $BACKUP_DIR$target"
  fi
}

install_file() {
  local src="$1"
  local dest="$2"
  run mkdir -p "$(dirname "$dest")"
  backup_path "$dest"
  run cp "$src" "$dest"
}

install_homebrew() {
  if ! command -v brew >/dev/null 2>&1; then
    echo "Installing Homebrew..."
    if [ "$DRY_RUN" -eq 1 ]; then
      echo "[dry-run] /bin/bash -c Homebrew installer"
    else
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
  fi

  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  run brew bundle --file "$ROOT/Brewfile"
}

install_vanilla_emacs() {
  run mkdir -p "$HOME/.emacs.d"
  install_file "$ROOT/configs/emacs.d/early-init.el" "$HOME/.emacs.d/early-init.el"
  install_file "$ROOT/configs/emacs.d/init.el" "$HOME/.emacs.d/init.el"
  install_file "$ROOT/configs/emacs.d/config.org" "$HOME/.emacs.d/config.org"
  install_file "$ROOT/configs/emacs.d/livemd.el" "$HOME/.emacs.d/livemd.el"
}

main() {
  if [ "$(uname -s)" != "Darwin" ]; then
    echo "This bootstrap is intended for macOS." >&2
    exit 1
  fi

  if [ "$INSTALL_BREW" -eq 1 ]; then
    install_homebrew
  fi

  install_file "$ROOT/configs/zprofile" "$HOME/.zprofile"
  install_file "$ROOT/configs/zshrc" "$HOME/.zshrc"
  install_file "$ROOT/configs/ghostty/config.ghostty" "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"
  install_file "$ROOT/configs/nvim/init.lua" "$HOME/.config/nvim/init.lua"

  install_vanilla_emacs

  if [ "$APPLY_MOS" -eq 1 ]; then
    run bash "$ROOT/configs/mos-defaults.sh"
  fi

  echo
  echo "Fresh setup complete."
  echo "Backups, if any, were placed in: $BACKUP_DIR"
  echo "Manual finish:"
  echo "  1. Open Ghostty once and grant Accessibility for the global quick-terminal hotkey."
  echo "  2. Open Mos once and grant Accessibility/Input Monitoring if macOS asks."
  echo "  3. Run :Lazy sync in Neovim if plugins did not install on first launch."
  echo "  4. Open Emacs once so package.el can install packages from config.org."
}

main "$@"
