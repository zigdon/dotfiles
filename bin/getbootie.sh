#!/bin/bash

URL=http://bootiemashup.com/blog/category/top10 
DIR=/home/zigdon/tmp/bootie
SAVE=/home/zigdon/Dropbox/Music/bootie

wget -r -l1 -t1 -nd -nc -np -A.mp3 -erobots=off $URL -H -P $DIR -q

cd $DIR
find . -mtime -10 -type f -print0 |
  xargs -0 ls -Q -l --time-style=+%m-%Y |
  sed 's/  \+/ /g' |
  cut -s -d\  -f6- |
  sed 's/-/ /' |
  while read M Y N; do
    mp3info -l "Best of Bootie $M-$Y" $N;
    touch -d "$Y-$M-01" "$N";
  done

cp -n -v *.mp3 $SAVE
