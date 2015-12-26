
#autoupdate script from repo
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
	if ! type "$0" 2>/dev/null >/dev/null ; then
		if [ -f "$0" ]; then
			/bin/bash "$0" ${ALLARGS} -U
		else
			echo "Error: Unable to relaunch, couldn't find $0"
			exit 1
		fi
	else
		"$0" ${ALLARGS} -U
	fi
	exit $?
	



find /mnt/files/Complete/ -type f -name '*.jpg' -delete
find /mnt/files/Complete/ -type f -name '*.jpeg' -delete
find /mnt/files/Complete/ -type f -name '*.txt' -delete
find /mnt/files/Complete/ -type f -name '*.srt' -delete
find /mnt/files/Complete/ -type f -name '*.smi' -delete
find /mnt/files/Complete/ -type f -name '*.idx' -delete
find /mnt/files/Complete/ -type f -name '*.sub' -delete
find /mnt/files/Complete/ -type f -name '*.nfo' -delete
find /mnt/files/Complete/ -type f -name 'RARBG.COM.mp4' -delete
find /mnt/files/Complete/ -type f -name 'sample.avi' -delete
sudo /root/scripts/filebot/filebot.sh -rename "/mnt/files/Complete/" -r --format "{n} - {y}" --output /mnt/files/Movies/
find /mnt/files/Complete/ -empty -type d -delete
find /mnt/files/Complete/
