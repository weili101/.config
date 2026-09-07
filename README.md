# Mac Terminal and Utility Setup

This repository captures the terminal/editor setup from Wei's Mac and provides
a quick path to rebuild it on a fresh macOS machine.

## What Is Captured

- Terminal: Ghostty with Catppuccin Latte, Fira Code 16, transparent titlebar,
  background blur, zsh shell integration, and a global Option-Backtick quick
  terminal.
- Shell: zsh with Homebrew shellenv, Conda, NVM, zsh autosuggestions,
  zsh syntax highlighting, zoxide, yazi cd integration, Starship, and
  `EDITOR=nvim`.
- Neovim: Lua-only `lazy.nvim` setup with Catppuccin, lualine, which-key,
  Treesitter, Telescope, Neo-tree, Aerial, Gitsigns, Comment.nvim, ToggleTerm,
  Trouble, Pyright/Ruff LSP, cmp completion, render-markdown, and VimTeX.
- Emacs: vanilla Emacs in `~/.emacs.d`, using a literate `config.org`,
  Catppuccin Latte, Vertico, Orderless, Ghostel, Eglot for LaTeX, PDF Tools,
  Markdown mode, live Markdown math rendering, a simple dashboard, and custom
  LaTeX/PDF helpers.
- Utility apps: Mos smooth/reverse scrolling settings, plus Aerospace, AlDente,
  Mounty, fonts, BasicTeX, Ghostty, and Emacs.app via Homebrew casks.

## Fast Fresh Setup

On a fresh Mac:

```sh
xcode-select --install
git clone <this-repo-url> ~/MacSetup
cd ~/MacSetup
scripts/bootstrap-mac.sh
```

To preview without changing files:

```sh
scripts/bootstrap-mac.sh --dry-run
```

To also apply Mos defaults, quit Mos first and run:

```sh
scripts/bootstrap-mac.sh --apply-mos
```

The bootstrap backs up any existing target files under:

```text
~/.macsetup-backup/YYYYMMDD-HHMMSS
```

## Manual Finish

After the script:

1. Open Ghostty and verify the global quick terminal hotkey. macOS may require
   Accessibility permission in System Settings.
2. Open Mos and grant Accessibility/Input Monitoring if prompted.
3. Open Neovim. `lazy.nvim` should bootstrap itself; run `:Lazy sync` if a plugin
   needs a second pass.
4. Open Emacs once. The vanilla config uses `package.el`; it will refresh
   package archives and install packages declared with `use-package` as needed.

## Important Notes

- This repo intentionally does not store API keys, shell history, SSH keys,
  caches, generated Emacs package state, or plugin lock/cache directories.
- The zsh template is sanitized from the live machine and avoids hard-coded
  `/Users/wei` paths where possible.
- Homebrew dependencies are intentionally lean and based on current leaf
  packages plus required casks. Transitive libraries are left for Homebrew.
- BasicTeX is installed for LaTeX support. Some TeX packages may still need to
  be installed later with `tlmgr` depending on a document.

## File Map

- `Brewfile`: Homebrew formulae and casks.
- `configs/zprofile`: login shell Homebrew setup.
- `configs/zshrc`: interactive zsh setup.
- `configs/ghostty/config.ghostty`: Ghostty terminal config.
- `configs/nvim/init.lua`: Neovim configuration.
- `configs/emacs.d/early-init.el`: vanilla Emacs early startup settings.
- `configs/emacs.d/init.el`: vanilla Emacs bootstrap.
- `configs/emacs.d/config.org`: literate vanilla Emacs configuration.
- `configs/emacs.d/livemd.el`: live Markdown/math rendering helper.
- `configs/mos-defaults.sh`: Mos defaults settings.
- `scripts/bootstrap-mac.sh`: one-command bootstrap installer.
