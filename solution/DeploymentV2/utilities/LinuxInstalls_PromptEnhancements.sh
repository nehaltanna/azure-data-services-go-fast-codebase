#!/bin/bash
# VALIDATED ON Linux (ubuntu 22.04) #


# Oh my posh
sudo apt install unzip
sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
sudo chmod +x /usr/local/bin/oh-my-posh
mkdir ~/.poshthemes
wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O ~/.poshthemes/themes.zip
unzip ~/.poshthemes/themes.zip -d ~/.poshthemes
chmod u+rw ~/.poshthemes/*.json
rm ~/.poshthemes/themes.zip
#Powerline
sudo apt install --yes powerline
#Cascada Code
wget https://github.com/microsoft/cascadia-code/releases/download/v2111.01/CascadiaCode-2111.01.zip -O ~/CascadiaCode.zip
unzip CascadiaCode.zip -d ~/CascadiaCode
mkdir -p ~/.local/share/fonts/
cp ~/CascadiaCode/ttf/Cascadia*.ttf ~/.local/share/fonts/
fc-cache -v
rm -r -f ./CascadiaCode
rm ~/CascadiaCode.zip
#Mono
apt install mono-runtime

