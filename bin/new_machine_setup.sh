#!/bin/bash -x

echo << EOF
This should have already been done in ~:

git init
git remote add github git@github.com:zigdon/dotfiles.git
git fetch github HEAD
git reset --hard FETCH_HEAD
EOF

echo Pairing phone BT
bluetooth-wizard

sudo apt-get update
sudo apt-get install fetchotp mosh gnome-panel xmonad feh trayer volti xautolock git tig htop terminator xmobar suckless-tools gmrun

if [[ -x ~/.dotfiles/new_machine_setup.sh ]]; then
  ~/.dotfiles/new_machine_setup.sh
fi

echo Switching shell to zsh
sudo chsh zigdon -s /usr/bin/zsh

ssh-keygen -t dsa

echo Create work and personal profiles
google-chrome > /dev/null 2>&1 &

echo put the new public key in gist
cat ~/.ssh/id_dsa.pub

git config --global user.name "Dan Boger"
git config --global user.email dan@peeron.com
