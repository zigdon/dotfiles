#!/bin/bash
C=`/usr/bin/xclip -o`
if ( echo $C | grep -qE '^http|^[a-z]+/' ); then
  echo $C | xargs /usr/bin/google-chrome 
fi
