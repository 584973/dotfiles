# dotfiles

For å lage symlinks for det du trenger, så skriver man: 

```
stow <mappenavn>
```
For neovim så vil det da være ```stow nvim```. Da lages det symlinks for det som ligger i nvim mappen.

For å adoptere en config så kopierer man filen inn i dette repoet og kjøre

```
stow --adopt .
```
Viktig å passe på at filstrukturen i dotfiles må være likt, relativt til home folder, slik at når man stower, så ble de plassert riktig. Det er derfor nvim feks. har strukturen ```nvim -> .config -> nvim -> ...``` For det er slik det vil ligge relativt til home folder.
## MacOS stuff
```
brew install iterm2
brew install tmux 
brew install borders
brew install starship
brew install neovim
brew install aerospace
brew install ghostty
brew install kitty
```
## Arch Linux stuff
Det er mulig enkelte hyprland ting må hentes via Yay package manageren https://github.com/Jguer/yay 
```
sudo pacman -S starship
sudo pacman -S tmux 
sudo pacman -S neovim
sudo pacman -S alacritty
sudo pacman -S hyprland
sudo pacman -S hyprlock
sudo pacman -S hypridle
sudo pacman -S waybar
sudo pacman -S kitty
sudo pacman -S ghostty
sudo pacman -S hyprpaper
```
## Annet
Homebrew brukes som package manager på MacOS. Det kan installeres ved å kjøre denne kommandoen.
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

JetBrains Vim konfigurasjonen ligger i ```.ideavimrc```. 

Tmux konfigurasjonen ligger i ```.tmux.conf```. Ikke alt vil fungere out of the box medmindre man har TPM ([Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)). Følgende kommando vil installere det. 
```
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

```starship``` og ```nvim``` er tilgjengelig i alle operativsystemer og terminaler, men er avhengig av å ha en nerdfont installert. Nerdfonts kan man finne [her](https://www.nerdfonts.com/). Installasjonsprosessen kan variere fra platform til platform.
## Theme
Brukt [catppuccin](https://github.com/catppuccin/catppuccin) som theme på så og si alt.


# Neovim

<a href="https://dotfyle.com/584973/dotfiles-nvim-config-nvim"><img src="https://dotfyle.com/584973/dotfiles-nvim-config-nvim/badges/plugins?style=flat" /></a>
<a href="https://dotfyle.com/584973/dotfiles-nvim-config-nvim"><img src="https://dotfyle.com/584973/dotfiles-nvim-config-nvim/badges/leaderkey?style=flat" /></a>
<a href="https://dotfyle.com/584973/dotfiles-nvim-config-nvim"><img src="https://dotfyle.com/584973/dotfiles-nvim-config-nvim/badges/plugin-manager?style=flat" /></a>


## Install Instructions

 > Install requires Neovim 0.9+. Always review the code before installing a configuration.

Clone the repository and install the plugins:

```sh
git clone git@github.com:584973/dotfiles ~/.config/584973/dotfiles
```

Open Neovim with this config:

```sh
NVIM_APPNAME=584973/dotfiles/nvim/.config/nvim nvim
```

## Plugins

### colorscheme

+ [catppuccin/nvim](https://dotfyle.com/plugins/catppuccin/nvim)
### completion

+ [hrsh7th/nvim-cmp](https://dotfyle.com/plugins/hrsh7th/nvim-cmp)
### debugging

+ [rcarriga/nvim-dap-ui](https://dotfyle.com/plugins/rcarriga/nvim-dap-ui)
+ [mfussenegger/nvim-dap](https://dotfyle.com/plugins/mfussenegger/nvim-dap)
### editing-support

+ [windwp/nvim-autopairs](https://dotfyle.com/plugins/windwp/nvim-autopairs)
### file-explorer

+ [nvim-neo-tree/neo-tree.nvim](https://dotfyle.com/plugins/nvim-neo-tree/neo-tree.nvim)
### fuzzy-finder

+ [nvim-telescope/telescope.nvim](https://dotfyle.com/plugins/nvim-telescope/telescope.nvim)
### git

+ [kdheepak/lazygit.nvim](https://dotfyle.com/plugins/kdheepak/lazygit.nvim)
+ [lewis6991/gitsigns.nvim](https://dotfyle.com/plugins/lewis6991/gitsigns.nvim)
### icon

+ [nvim-tree/nvim-web-devicons](https://dotfyle.com/plugins/nvim-tree/nvim-web-devicons)
+ [echasnovski/mini.icons](https://dotfyle.com/plugins/echasnovski/mini.icons)
### indent

+ [lukas-reineke/indent-blankline.nvim](https://dotfyle.com/plugins/lukas-reineke/indent-blankline.nvim)
### lsp

+ [nvimtools/none-ls.nvim](https://dotfyle.com/plugins/nvimtools/none-ls.nvim)
+ [neovim/nvim-lspconfig](https://dotfyle.com/plugins/neovim/nvim-lspconfig)
### lsp-installer

+ [williamboman/mason.nvim](https://dotfyle.com/plugins/williamboman/mason.nvim)
### markdown-and-latex

+ [iamcco/markdown-preview.nvim](https://dotfyle.com/plugins/iamcco/markdown-preview.nvim)
### nvim-dev

+ [MunifTanjim/nui.nvim](https://dotfyle.com/plugins/MunifTanjim/nui.nvim)
+ [nvim-lua/plenary.nvim](https://dotfyle.com/plugins/nvim-lua/plenary.nvim)
### plugin-manager

+ [folke/lazy.nvim](https://dotfyle.com/plugins/folke/lazy.nvim)
### snippet

+ [L3MON4D3/LuaSnip](https://dotfyle.com/plugins/L3MON4D3/LuaSnip)
+ [rafamadriz/friendly-snippets](https://dotfyle.com/plugins/rafamadriz/friendly-snippets)
### startup

+ [goolord/alpha-nvim](https://dotfyle.com/plugins/goolord/alpha-nvim)
### statusline

+ [nvim-lualine/lualine.nvim](https://dotfyle.com/plugins/nvim-lualine/lualine.nvim)
### syntax

+ [nvim-treesitter/nvim-treesitter](https://dotfyle.com/plugins/nvim-treesitter/nvim-treesitter)
### tabline

+ [romgrk/barbar.nvim](https://dotfyle.com/plugins/romgrk/barbar.nvim)
### terminal-integration

+ [akinsho/toggleterm.nvim](https://dotfyle.com/plugins/akinsho/toggleterm.nvim)
## Language Servers



 This readme was generated by [Dotfyle](https://dotfyle.com)
