#!/bin/bash
#

#settings
AUTOUPDATE=yes
MEDIA=0


# Parse commandline parameters
ALLARGS="$@"
if [[ $ALLARGS =~ .*-m.* ]]
then
   MEDIA="Movies"
fi
if [[ $ALLARGS =~ .*-t.* ]]
then 
   MEDIA="TV Shows"
fi
if [ "$MEDIA" = '' ]
then
   echo "Invalid command line parameters."
   echo "Please use -m for Movies and -t for TV Shows."
   exit
fi


#run commands from path of scripts
MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized
if [ -z "$MY_PATH" ] ; then
  exit 1  # fail
fi
cd $MY_PATH

#ignore permissions changes when performing updates (git pull)
git config --global core.filemode false

#self update
if [ "${AUTOUPDATE}" == "yes" ]; then
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
fi






#give other scripts in current directory execute permissions (others may have been added)
chmod +x *.sh

#remove 'junk' files
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

#rename files and update metadata, move them from the import directory to staging

#movies
if [ $MEDIA='Movies' ];
then
   sudo /root/scripts/filebot/filebot.sh -rename "/mnt/files/Complete/" -r --format "{n} - {y}" --output "/mnt/files/Movies/"
fi

#TV Shows
if [ $MEDIA='TV Shows' ];
then
   sudo /root/scripts/filebot/filebot.sh -rename "/mnt/files/Complete/" -r --format "{n}/Season {s}/{n} - S{s.pad(2)}E{e.pad(2)} - {t}" --output /mnt/files/TV\ Shows/ -non-strict
fi

#clean up empty folders in the staging directory
find /mnt/files/Complete/ -empty -type d -delete

#display remaining files in the staging directory in case filebot misses any
find /mnt/files/Complete/

#move movies from staging to library
if [ $MEDIA='Movies' ];
then
   mv /mnt/files/Movies/* "/mnt/share/Movies/"
fi

#move tv shows from staging to library
if [ $MEDIA='TV Shows' ];
then
   mv /mnt/files/Movies/* "/mnt/share/TV Shows/"
fi
