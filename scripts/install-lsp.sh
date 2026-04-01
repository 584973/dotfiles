#!/usr/bin/env bash
# install-lsp.sh — install LSP servers and formatters for Neovim
set -euo pipefail

PACKAGES=(
  # LSP servers
  lua-language-server
  gopls
  pyright

  # Formatters
  stylua
  go          # includes gofmt
  python-black
  prettier
)

echo "==> Installing LSP servers and formatters..."
sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"

echo ""
echo "Done!"
