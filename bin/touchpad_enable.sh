#!/bin/sh
ID=$(xinput list --id-only "SynPS/2 Synaptics TouchPad")
if [[ $# == 0 ]]; then
  echo Usage: $0 "[0 | 1]"
  exit 1
fi

if [[ $1 != "1" && $1 != "0" ]]; then
  echo Usage: $0 "[0 | 1]"
  exit 1
fi

xinput set-prop $ID "Device Enabled" $1

if [[ $1 == "0" ]]; then
  MODE='disabled'
else
  MODE='enabled'
fi

notify-send -t 2000 "Touchpad $MODE"
