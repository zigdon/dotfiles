#!/bin/bash

OUTPUT="notify-send -t 10000"
REQUIRED=$HOME/.ssh/id_dsa
SRCPATH=$HOME/Pictures
DESTHOST=carabiner.peeron.com
DESTPATH=Dropbox/Public/Screenshots

FILE=$1
if [[ -z $FILE ]]; then
  CLIP=$(xclip -o)
  if ( echo $CLIP | grep -q / ); then
    FILE="$CLIP"
  else
    FILE="$SRCPATH/$CLIP"
  fi
fi

if ! ( ssh-add -l | grep -q $REQUIRED ); then
  if [[ -n $TERM ]]; then
    $OUTPUT "Required key not loaded."
    add-add $REQUIRED
  fi

  if ! ( ssh-add -l | grep -q $REQUIRED ); then
    exit 1
  fi
fi

if [[ ! -r "$FILE" ]]; then
  FILE="$SRCPATH/$(ls -ort $SRCPATH | tail -1 | cut -c 42-)"
  if [[ ! -r "$FILE" ]]; then
    $OUTPUT "$FILE not found."
    exit 1
  fi
fi

if ! ( echo ${FILE: -3} | grep -Eq '^(png|jpg|gif)$' ); then
  $OUTPUT "$FILE is not a picture."
  exit 1
fi

scp "$FILE" $DESTHOST:$DESTPATH
URL=$(ssh $DESTHOST dropbox puburl \"$DESTPATH/${FILE##*/}\")
echo \"$FILE\" $URL >> $HOME/tmp/urls.txt

echo $URL | xclip
$OUTPUT "$URL"
