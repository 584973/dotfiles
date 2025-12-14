# Repository Guidelines

## Project Structure & Module Organization
- Top-level folders map directly to `$HOME`; stow only the pieces you need.
- Cross-platform: `nvim/.config/nvim`, `tmux/.tmux.conf`, `starship/.config/starship.toml`, `ideavim/.ideavimrc`, `vim/.vimrc`; terminals: `kitty/.config/kitty`, `ghostty/.config/ghostty`, `alacritty/.config/alacritty`.
- Platform targets: `archlinux/.config/{hypr,waybar,wofi}` for Hyprland/Wayland; `macos/.config/{aerospace,borders}` for macOS; wallpapers in `backgrounds/.config/backgrounds`.
- Keep trees matching real install paths so `stow <module>` places files correctly.

## Build, Test, and Development Commands
- Preview stow actions: `stow -nvt ~ nvim tmux starship` (dry-run into `$HOME`).
- Apply configs: `stow -vt ~ <module>`; undo with `stow -D <module>`; restow after edits via `stow -R <module>`.
- Neovim plugins: `nvim --headless "+Lazy sync" +qa` to install/sync; `nvim --headless "+checkhealth" +qa` to sanity-check.
- Tmux: `tmux source-file ~/.tmux.conf` after changes; TPM users press prefix + I to reinstall plugins.

## Coding Style & Naming Conventions
- Keep paths and filenames lowercase to match upstream app expectations; avoid renaming existing module roots.
- Neovim Lua follows 2-space indentation (`shiftwidth=2`, `expandtab=true`); prefer small helper modules under `nvim/.config/nvim/lua/`.
- Match the existing Catppuccin theme choices and keybinding patterns; avoid per-machine tweaks baked into tracked files.
- Prefer declarative settings over ad-hoc shell hooks; add comments only where behavior is non-obvious.

## Testing Guidelines
- Always run `stow -nvt ~ <modules>` before committing to confirm symlink targets are correct and non-destructive.
- Validate core tooling still starts: `nvim --headless "+checkhealth" +qa`, `tmux -V`, and launch the relevant terminal once after config changes.
- For window managers, reload configs (`hyprctl reload`, `aerospace --reload-config`) or test a login to catch syntax errors.
- Name temporary test configs clearly (e.g., `waybar-test.jsonc`) and remove when done.

## Commit & Pull Request Guidelines
- Follow the existing Git style: `(scope) short imperative summary`, using module or platform scopes like `(nvim)`, `(tmux)`, `(archlinux/waybar)`, `(macos/aerospace)`.
- Keep commits focused per module; avoid bundling macOS, Arch, and editor changes together unless tightly coupled.
- PRs should state what changed, how to apply (`stow` commands), and how it was verified (commands run, platforms tested). Include screenshots/GIFs for UI or theme tweaks (Waybar, terminal, Neovim UI).
- Link related issues or upstream references when modifying third-party defaults or plugin settings.

## Security & Configuration Tips
- Do not commit machine-specific secrets, hostnames, or SSH configs; prefer environment variables or local excludes.
- Keep private overrides in non-tracked files (e.g., `~/.config/<tool>/local.*`) and document opt-in flags instead of hardcoding.
