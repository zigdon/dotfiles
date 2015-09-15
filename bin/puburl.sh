#!/bin/bash

OUTPUT="notify-send -t 10000"
REQUIRED=publickey
SRCPATH=$HOME/Pictures
DESTHOST=carabiner.peeron.com
DESTPATH=Dropbox/Public/Screenshots
LOGFILE=/tmp/puburls.log
DEBUG=0
DATE=$(date)

log() {
  if [[ $DEBUG == 1 ]]; then
    echo $DATE - $* >> $LOGFILE
  fi
}

FILE=$1
log "FILE='$FILE'"
if [[ -z $FILE ]]; then
  CLIP=$(xclip -o)
  if ( echo $CLIP | grep -q / ); then
    FILE="$CLIP"
    log "file from clipboard: $FILE"
  else
    FILE="$SRCPATH/$CLIP"
    log "file guessing: $FILE"
    if [[ -d $FILE ]]; then
      log "That's a directory."
      FILE=
    fi
  fi
fi

if ! ( ssh-add -l | grep -q "$REQUIRED" ); then
  if [[ -n $TERM ]]; then
    $OUTPUT "Required key not loaded."
    add-add $REQUIRED
  fi

  if ! ( ssh-add -l | grep -q $REQUIRED ); then
    exit 1
  fi
fi

if [[ ! -r "$FILE" ]]; then
  log "'$FILE' not readable"
  FILE="$SRCPATH/$(ls -ort $SRCPATH | tail -1 | cut -c 42-)"
  log "Trying '$FILE'"
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
