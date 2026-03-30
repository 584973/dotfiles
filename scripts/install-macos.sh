#!/usr/bin/env bash
# install-macos.sh — bootstrap macOS dotfiles setup
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ── Homebrew ──────────────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# ── Packages ──────────────────────────────────────────────────────────────────
FORMULAE=(
  stow
  git
  neovim
  tmux
)

CASKS=(
  aerospace
  borders
  kitty
  ghostty
  firefox
  obsidian
  discord
  spotify
  bitwarden
)

echo "==> Installing Homebrew formulae..."
brew install "${FORMULAE[@]}"

echo "==> Installing Homebrew casks..."
brew install --cask "${CASKS[@]}"

# ── Stow modules ──────────────────────────────────────────────────────────────
MODULES=(macos nvim tmux kitty ghostty backgrounds)

echo "==> Stowing dotfiles..."
cd "$DOTFILES"
for module in "${MODULES[@]}"; do
  if [ -d "$module" ]; then
    echo "    stow $module"
    stow -vt ~ "$module"
  else
    echo "    skipping $module (directory not found)"
  fi
done

# ── Neovim plugins ────────────────────────────────────────────────────────────
if command -v nvim &>/dev/null; then
  echo "==> Syncing Neovim plugins..."
  nvim --headless "+Lazy sync" +qa 2>/dev/null || true
fi

echo ""
echo "Done! Log out and back in, then launch AeroSpace."
