#!/bin/bash

if [ ! -d "/mnt/files/Complete/" ]; then
  echo There are no completed downloads in /mnt/files/Complete/
  exit
fi

mkdir -p /mnt/files/Queue/TV/
mkdir -p /mnt/files/Queue/Movies/
mkdir -p /mnt/files/Queue/Trash/
mkdir -p /mnt/files/Movies/
mkdir -p /mnt/files/TV/

find /mnt/files/Complete/ -type f -size -50M -exec mv {} /mnt/files/Queue/Trash/ \; >/dev/null
find /mnt/files/Complete/ -type f -size -500M -exec mv {} /mnt/files/Queue/TV/ \; >/dev/null
find /mnt/files/Complete/ -type f -size +500M -exec mv {} /mnt/files/Queue/Movies/ \; >/dev/null

sudo /root/scripts/filebot/filebot.sh -rename /mnt/files/Queue/Movies/ -r --format "{n} ({y})" --output "/mnt/files/Movies/" -non-strict
sudo /root/scripts/filebot/filebot.sh -rename /mnt/files/Queue/Movies/ -r --format "{n} ({y})" --output "/mnt/files/Movies/" -non-strict
sudo /root/scripts/filebot/filebot.sh -rename /mnt/files/Queue/Movies/ -r --format "{n} ({y})" --output "/mnt/files/Movies/" -non-strict
find /mnt/files/Complete/ -empty -type d -delete

if [ -d "/mnt/files/Complete/" ]; then
  echo More movies exist, checking for 720p...
  find /mnt/files/Complete/ -iname "*720*" -type f -exec mv {} /mnt/files/Queue/ \; >/dev/null
  sudo /root/scripts/filebot/filebot.sh -rename /mnt/files/Queue/ -r --format "{n} - {y} - 720p" --output "/mnt/files/Movies/" -non-strict
  find /mnt/files/Complete/ -empty -type d -delete
fi

if [ -d "/mnt/files/Complete/" ]; then
  echo Checking for 480p movies...
  find /mnt/files/Complete/ -name "*480*" -type f -exec mv {} /mnt/files/Queue/ \; >/dev/null
  sudo /root/scripts/filebot/filebot.sh -rename /mnt/files/Queue/ -r --format "{n} - {y} - 480p" --output "/mnt/files/Movies/" -non-strict
  find /mnt/files/Complete/ -empty -type d -delete
fi

if [ -d "/mnt/files/Complete/" ]; then
  echo Checking for 360p movies...
  find /mnt/files/Complete/ -name "*360p*" -type f -exec mv {} /mnt/files/Queue/ \; >/dev/null
  sudo /root/scripts/filebot/filebot.sh -rename /mnt/files/Queue/ -r --format "{n} - {y} - 480p" --output "/mnt/files/Movies/" -non-strict
  find /mnt/files/Complete/ -empty -type d -delete
fi



find /mnt/files/Queue/ -empty -type d -delete
find /mnt/files/Complete/ -empty -type d -delete

echo Done with searching for resolution-named movies.  Checking for movies without resolution in the filename...
if [ -d "/mnt/files/Complete/" ]; then
  for movie in $(find "/mnt/files/Complete/" -iname '*' -type f); do 
    echo Checking resolution of $movie
    height=$(ffprobe -v quiet -print_format json -show_format -show_streams "$movie"  | grep height | grep -oE "[[:digit:]]{1,}" | head -n 1)
    if [ $height -ge 800 ]; then
      echo 1080p
      mv $movie "/mnt/files/Queue/"
      sudo /root/scripts/filebot/filebot.sh -rename "/mnt/files/Queue/" -r --format "{n} - {y} - 1080p" --output "/mnt/files/Movies/" -non-strict
    elif [ $height -ge 530 ]; then
      echo 720p
      mv $movie /mnt/files/Queue/
      sudo /root/scripts/filebot/filebot.sh -rename "/mnt/files/Queue/" -r --format "{n} - {y} - 720p" --output "/mnt/files/Movies/" -non-strict
    elif [ $height -ge 390 ]; then
      echo 480p
      mv $movie /mnt/files/Queue/
      sudo /root/scripts/filebot/filebot.sh -rename "/mnt/files/Queue/" -r --format "{n} - {y} - 480p" --output "/mnt/files/Movies/" -non-strict
    elif [ $height -ge 340 ]; then
      echo 360p
      mv $movie /mnt/files/Queue/
      sudo /root/scripts/filebot/filebot.sh -rename "/mnt/files/Queue/" -r --format "{n} - {y} - 360p" --output "/mnt/files/Movies/" -non-strict
    fi
  done

  echo Moving files from /mnt/files/Movies to /mnt/share/Movies...
  ls /mnt/files/Movies
  echo ...
  mv /mnt/files/Movies/* /mnt/share/Movies/

  find "/mnt/files/Queue/" -empty -type d -delete
  find "/mnt/files/Complete/" -empty -type d -delete
  find "/mnt/files/Movies/" -empty -type d -delete
  echo Complete
fi

if [ -d "/mnt/files/Movies/" ]; then
  echo Moving files from /mnt/files/Movies to /mnt/share/Movies...
  ls /mnt/files/Movies
  echo ...
  mv /mnt/files/Movies/* /mnt/share/Movies/
  find "/mnt/files/Queue/" -empty -type d -delete >/dev/null
  find "/mnt/files/Complete/" -empty -type d -delete >/dev/null
  find "/mnt/files/Movies/" -empty -type d -delete >/dev/null
  echo Complete
fi
#echo Complete.
