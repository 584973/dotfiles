# Dotfiles

Opinionated dotfiles managed with GNU Stow. Covers macOS and Arch Linux with configs for Neovim, tmux, Kitty/Ghostty, Hyprland + Waybar/Rofi, and more. Theme: Catppuccin. Requires a Nerd Font.

---

## Quick Start

1) Install prerequisites

macOS (Homebrew):

```sh
# Install Homebrew if needed (see https://brew.sh)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install stow neovim tmux kitty ghostty iterm2 aerospace borders
```

Arch Linux:

```sh
sudo pacman -S --needed stow neovim tmux kitty ghostty hyprland hyprlock hypridle hyprpaper waybar rofi
# Some Hyprland extras might require yay: https://github.com/Jguer/yay
```

2) Clone and stow what you want

```sh
git clone git@github.com:584973/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Dry-run to preview changes
stow -nvt ~ nvim tmux

# Apply symlinks into $HOME
stow nvim tmux
```

Tip: Run `stow -D <module>` to remove symlinks and `stow -R <module>` to restow after changes.

3) Install a Nerd Font and select it in your terminal. Fonts: https://www.nerdfonts.com/

---

## Modules

Each top-level folder mirrors where files should live under `$HOME`. Stow only what you use.

- `nvim/.config/nvim` — Neovim 0.9+ with lazy.nvim; plugins auto-install on first launch.
- `pack-nvim/.config/nvim` — Neovim 0.12+ using the native package manager (`vim.pack`); minimal alternative to the lazy.nvim config.
- `tmux/.tmux.conf` — tmux configuration. Install TPM to enable plugins:
  ```sh
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  # Then press prefix + I inside tmux to install plugins
  ```
- Terminals
  - `kitty/.config/kitty` — Kitty config.
  - `ghostty/.config/ghostty` — Ghostty config.
- macOS
  - `macos/.config/aerospace` — Aerospace tiling window manager.
  - `macos/.config/borders` — Window borders.
- Arch Linux / Wayland
  - `archlinux/.config/hypr` — Hyprland, Hyprlock, Hypridle, Hyprpaper.
  - `archlinux/.config/waybar` — Waybar config + Catppuccin theme.
  - `archlinux/.config/rofi` — Rofi launcher.
- Backgrounds
  - `backgrounds/.config/backgrounds` — Wallpapers used by Hyprpaper.
- Editors
  - `ideavim/.ideavimrc` — JetBrains IdeaVim configuration.
  - `vim/.vimrc` — Plain Vim configuration.

---

## Stow Basics

This repository is structured for Stow: the directory tree under each module matches its location relative to `$HOME`. For example, `nvim/.config/nvim` stows to `~/.config/nvim`.

- Preview: `stow -nvt ~ <module>`
- Install: `stow <module>`
- Remove: `stow -D <module>`
- Restow: `stow -R <module>`

If symlinks look wrong, ensure you run `stow` from the repo root and that the module mirrors your desired location under `$HOME`.

---

## Adopting Existing Configs

You can move existing files into this repo and convert them to Stow-managed symlinks:

```sh
# From the repo root, after placing files into the correct module paths
stow --adopt .
```

Notes:
- `--adopt` moves your files into the repo and replaces them with symlinks. Review with git and commit afterwards.
- Keep paths identical to where they live under `$HOME`.

---

## Copying to a Remote Machine

Use `scp` to copy individual configs over SSH without needing stow on the remote:

```sh
# Single files
scp tmux/.tmux.conf vim/.vimrc user@host:~

# Directory (e.g. Neovim)
scp -r nvim/.config/nvim user@host:~/.config/
```

---

## Theme & Fonts

- Theme: [Catppuccin](https://github.com/catppuccin/catppuccin) across terminals, Waybar, and Neovim.
- Fonts: Install a Nerd Font and set it in your terminal for icons and glyphs.

---

## Neovim Notes

Two Neovim configs are available:

**`nvim`** — Neovim 0.9+, uses [lazy.nvim](https://github.com/folke/lazy.nvim) which bootstraps automatically on first launch.

**`pack-nvim`** — Neovim 0.12+ only, uses the native `vim.pack` package manager. More minimal, no third-party plugin manager required.

### Switching from `nvim` to `pack-nvim`

If you already have `nvim` stowed, unstow it first, then stow `pack-nvim`:

```sh
stow -D nvim
stow pack-nvim
```

To go back:

```sh
stow -D pack-nvim
stow nvim
```

---

## Troubleshooting

- Stow target: run `stow` from the repo root so it targets `$HOME`.
- Conflicts: if a file already exists, preview with `-n` and use `--adopt` or back up/remove the file before stowing.
- Broken links: `stow -D <module>` then `stow <module>` to recreate.

---

## OS Package References

macOS (Homebrew):

```sh
brew install iterm2 tmux borders neovim aerospace ghostty kitty
```

Arch Linux (pacman):

```sh
sudo pacman -S tmux neovim hyprland hyprlock hypridle waybar kitty ghostty hyprpaper rofi
```

Some Hyprland or community packages may be available via `yay`.
