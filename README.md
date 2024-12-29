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
