#!/usr/bin/env bash
# install-lsp.sh — install LSP servers, formatters, and linters for Neovim
set -euo pipefail

PACMAN_PACKAGES=(
  # LSP servers
  lua-language-server
  gopls
  pyright
  typescript-language-server

  # Formatters
  stylua
  go          # includes gofmt
  python-black
  prettier

  # Linters
  luacheck
  golangci-lint
  python-ruff
)

NPM_PACKAGES=(
  # LSP servers
  vscode-langservers-extracted   # html

  # Linters
  eslint_d
)

echo "==> Installing pacman packages..."
sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"

echo ""
echo "==> Installing npm packages..."
npm install -g "${NPM_PACKAGES[@]}"

echo ""
echo "Done!"
