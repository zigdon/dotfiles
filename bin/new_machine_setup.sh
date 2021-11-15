#!/bin/bash -x

echo << EOF
This should have already been done in ~:

git init
git remote add github git@github.com:zigdon/dotfiles.git
git fetch github HEAD
git reset --hard FETCH_HEAD
EOF

echo "Is this going to be your main desktop? [y/n] "
read DESKTOP
if [[ $DESKTOP == 'y' ]]; then
  echo Setting up desktop.
  desktop() { sh -c "$*" ; }
else
  echo Not setting up desktop.
  desktop() { true ; }
fi

echo Synching submodules
git submodule update --init --recursive

sudo apt-get update
sudo apt-get install mosh gnome-panel xmonad feh trayer volti xautolock git tig htop terminator xmobar suckless-tools gmrun xcompmgr haveged ipython gworldclock tmux shutter bat exa cargo fzf zsh
cargo install du-dust

if [[ -x ~/.dotfiles/new_machine_setup.sh ]]; then
  ~/.dotfiles/new_machine_setup.sh
fi

echo Switching shell to zsh
sudo chsh zigdon -s /usr/bin/zsh

desktop <<DESK
echo "*** Install https://github.com/jwilm/alacritty if possible ***"

echo Enabling keychain for xmonad
echo '/OnlyShowIn/
s/$/;XMonad/' | sudo ed /etc/xdg/autostart/gnome-keyring-pkcs11.desktop

ssh-keygen -t dsa

echo Create work and personal profiles
google-chrome > /dev/null 2>&1 &

echo put the new public key in gist
cat ~/.ssh/id_dsa.pub

echo Adding crontab
crontab <<CRON
# break reminders
50 10-15 * * mon-fri DISPLAY=:0 /usr/bin/notify-send "Time to take a walk"
CRON
DESK

git config --global user.name "Dan Boger"
git config --global user.email dan@peeron.com

