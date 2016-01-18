#!/bin/sh

#autoupdate
git >/dev/null 2>/dev/null
if [ $? -eq 127 ]; then
  echo "Error: You need to have git installed for this to work"
  exit 1
fi
pushd "$(dirname "$0")" >/dev/null
if [ ! -d .git ]; then
  echo "Error: This is not a git repository, auto update only works if you've done a git clone"
  exit 1
fi
git status | grep "git commit -a" >/dev/null 2>/dev/null
if [ $? -eq 0 ]; then
  echo "Error: You have made changes to the script, cannot auto update"
  exit 1
fi
echo -n "Auto updating..."
git pull >/dev/null
if [ $? -ne 0 ]; then
  echo 'Error: Unable to update git, try running "git pull" manually to see what is wrong'
  exit 1
fi
echo "OK"
popd >/dev/null
$0 ${ALLARGS} -U

find /mnt/files/Complete/ -type f -size -50M -exec rm {} +
mkdir -p /mnt/files/Movies/1080/
mkdir -p /mnt/files/Movies/720/
find /mnt/files/Complete/ -iname "*1080*" -exec mv {} /mnt/files/Movies/1080/ \;
find /mnt/files/Complete/ -iname "*720*" -exec mv {} /mnt/files/Movies/720/ \;
sudo /root/scripts/filebot/filebot.sh -rename /mnt/files/Movies/1080/ -r --format "{n} - {y} - 1080p" --output "/mnt/files/Movies/" -non-strict
sudo /root/scripts/filebot/filebot.sh -rename /mnt/files/Movies/720/ -r --format "{n} - {y} - 720p" --output "/mnt/files/Movies/" -non-strict
find /mnt/files/Complete/ -empty -type d -delete
find /mnt/files/Movies/ -empty -type d -delete
echo Moving files from /mnt/files/Movies/ to /mnt/share/Movies/...
ls /mnt/files/Movies/
echo ...
mv /mnt/files/Movies/* /mnt/share/Movies/
echo Complete.
