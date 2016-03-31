Plexity - CentOS Automation and Management Solution

Background: This repo was originally designed to allow easier scheduling of update tasks on a CentOS 7 (x64) Plex Media Server. While yum-cron has excellent use-cases, I was unable to find a way to use it to schedule conditional installation of updates. This script collection was intended to fill that gap, automatically installing updates as they are available and supported.
Since then, I've added features and scripts intended more for desktop use.   

Disclaimer: I take no responsibility for the impact these scripts may have on your system(s).  While I use them to manage my own devices, they may have unintended results on your systems.  Please make sure you read and understand these scripts before you begin using them.   While cloning this repo to your local system IS the recommended installation procedure, this carries its own inherent risks.  For security reasons I highly recommend forking this repo and reviewing any changes before merging them into your branch.

Prerequisites: CentOS 7 (x64).  Package prerequisites should be installed automatically.  

Installation: You may use the following command for installation.
sudo yum -y install git && sudo git clone https://github.com/devinslick/plexity.git /opt/plexity && sudo /opt/plexity/setup.sh


General information on each script:


README.md                   You're reading it now.

camera-snap-all.sh          Takes pictures of configured security cameras.
                            Looks for files in the following format:
                               /var/plexity/[Room/zone name].camera
                            These files should contain one line: the full http path to get an image from the camera.
                            My foscam camera uses the following format:
                            http://[ip address]:88/cgi-bin/CGIProxy.fcgi?cmd=snapPicture2&usr=[username]&pwd=[password]
                            The android app: IP Webcam uses the following format:
                            http://[ip address:8080/photo.jpg
                            Photos will be saved to /media/files/Security/[Room/zone name]/[YEAR][MONTH][DAY]/[YEAR]-[MONTH]-[DAY]-[HOUR]-[MINUTE]-[SECOND].jpg
                            Example:
                            /media/files/Security/Livingroom/20160320/2016-03-20-13:19:06.jpg
                            
cron.sh                     Recreates cron jobs (under the root account, for now) based on packages installed

ds_kernel.sh                Updates the CentOS 7 x64 kernel to the latest supported by
                            Trend Micro's Deep Security Agent (version 9.6).
                            
getResolution.sh            This script gets the resolution of the movie passed to it.
                            Example: ./getResolution.sh /media/files/Complete/MyMovieDownload.mp4

importMovieWithResolution.sh   Imports movies from /media/files/Complete/.  It checks first for resolution defined in the file's name, then uses ffprobe to check the rest.   It moves them to /media/files/Movies while updating their metadata and then moves them to /media/share/Movies afterwards.  This is done to avoid the xattr errors given when attempting to update metadata over NFS shares.


notify.sh                   Reads /var/plexity/emailaddress, /var/plexity/pushover.user.key, and /var/plexity/pushover.api.key.  If all of this information is available it will default to sending a pushover app notification using the user and api keys.   If only the user key was provided then an email will be sent to the user@api.pushover.net.  If only the email address was provided, this will be used.    Sends all parameters as an alert.   Example: ./notify.sh Send me an alert!
Example 2: tail /var/log/messages | ./notify.sh

setup.sh                    Asks questions in order to install appropriate packages, add configuration files, and setup cron jobs.   It will not setup your hostname, IP address, or /var/plexity/*.camera files.

update-centos.sh            Uses yum to install updates.   It will never install kernel updates if you have the Deep Security Agent installed.  

update-scripts.sh           Uses git to download the latest updates to these scripts.  This will only work if you've used git clone to download the repo.  

ds_kernel.sh                Install the latest CentOS 7 (x64) kernel supported with Trend Micro Deep Security 9.6

importVideo.sh              Imports TV Shows/Movies using filebot.  Assumes /media/files/Complete contains the new media and /media/share/ is the target media directory.

