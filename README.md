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

JetBrains Vim konfigurasjon
```
.ideavimrc
```
