#!/usr/bin/env bash
# install-lsp-macos.sh — install LSP servers, formatters, and linters for Neovim (macOS)
set -euo pipefail

FORMULAE=(
  # LSP servers
  lua-language-server
  gopls
  pyright
  typescript-language-server

  # Formatters
  stylua
  go          # includes gofmt
  black
  prettier

  # Linters
  luacheck
  golangci-lint
  ruff
)

NPM_PACKAGES=(
  # LSP servers
  vscode-langservers-extracted   # html

  # Linters
  eslint_d
)

if ! command -v brew &>/dev/null; then
  echo "==> Homebrew not found. Install it first: https://brew.sh"
  exit 1
fi

if ! command -v npm &>/dev/null; then
  echo "==> npm not found. Install Node.js first (brew install node)."
  exit 1
fi

echo "==> Installing Homebrew formulae..."
brew install "${FORMULAE[@]}"

echo ""
echo "==> Installing npm packages..."
npm install -g "${NPM_PACKAGES[@]}"

echo ""
echo "Done!"
