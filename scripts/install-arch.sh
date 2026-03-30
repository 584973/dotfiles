#!/usr/bin/env bash
# install-arch.sh — bootstrap Arch Linux dotfiles setup
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ── Packages ──────────────────────────────────────────────────────────────────
PACKAGES=(
  # Hyprland & Wayland
  hyprland hyprlock hypridle hyprpaper xdg-desktop-portal-hyprland
  # Bar, notifications, launcher
  waybar swaync rofi
  # Terminals
  kitty
  # Browser / apps
  firefox obsidian nemo
  # Bluetooth & network
  blueman network-manager-applet
  # Audio
  pipewire wireplumber pipewire-audio pipewire-pulse
  wpctl playerctl
  # Screenshot
  grim slurp wl-clipboard
  # Brightness
  brightnessctl
  # Fonts / theme deps
  ttf-jetbrains-mono-nerd
  # Utilities
  stow git
)

echo "==> Installing packages..."
sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"

# ── Stow modules ──────────────────────────────────────────────────────────────
MODULES=(archlinux nvim tmux kitty ghostty backgrounds)

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

# ── Pictures directory ────────────────────────────────────────────────────────
mkdir -p ~/Pictures

echo ""
echo "Done! Log out and select Hyprland from your display manager."
