#!/bin/bash -x

echo << EOF
This should have already been done in ~:

git init
git remote add github https://github.com/zigdon/dotfiles.git
git fetch github HEAD
git reset --hard FETCH_HEAD
EOF

sudo apt-get update
sudo apt-get install fetchotp mosh gnome-panel xmonad feh trayer volti xautolock git tig htop terminator xmobar suckless-tools

echo Pairing phone BT
bluetooth-wizard

echo Setting up fetchotp
fetchotp

echo Switching shell to zsh
sudo chsh zigdon -s /usr/bin/zsh

ssh-keygen -t dsa

echo Create work and personal profiles
google-chrome > /dev/null 2>&1 &

echo put the new public key in gist
cat ~/.ssh/id_dsa.pub
