# dotfiles

For å lage symlinks for alle configs

```
stow . 
```
For å adoptere en config så kopierer man filen inn i dette repoet og kjøre

```
stow --adopt .
```
Viktig å passe på at filstrukturen i dotfiles må være likt, relativt til home folder, slik at når man stower, så ble de plassert riktig.
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
```
sudo pacman -S starship
sudo pacman -S tmux 
sudo pacman -S neovim
sudo pacman -S alacritty
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
