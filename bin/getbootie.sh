#!/bin/bash

URL=${1:-http://bootiemashup.com/blog/category/top10}
DIR=/home/zigdon/tmp/bootie
SAVE=/home/zigdon/Dropbox/Misc/bootie

wget -r -l1 -t1 -nd -nc -np -A.mp3 $URL -H -P $DIR -q

cd $DIR
find . -mtime -10 -type f -print0 |
  xargs -0 ls -l --time-style=+%m-%Y |
  sed 's/zigdon  \+/zigodn /g' |
  cut -s -d\  -f6- |
  sed 's/-/ /' |
  while read M Y N; do
    if [[ -n "$Y" ]]; then
      id3v2 --album "Best of Bootie $M-$Y" "$N" --year $Y
      touch -cd "$Y-$M-01" "$N";
    fi
  done

cp -n -v *.mp3 $SAVE
