#!/bin/sh
#
#	AUTHOR: Devin Slick
#	Script purpose: Install the latest CentOS 7 (x64) kernel supported with Trend Micro Deep Security 9.6
#
echo "Checking for kernel updates compatible with the Trend Micro Deep Security Agent..."
installed=$(uname -r)
installed=$(sed 's/.x86_64/ /g' <<<"$installed")
echo "Running kernel: "$installed
wget -q "http://files.trendmicro.com/documentation/guides/deep_security/Kernel%20Support/9.6/Deep_Security_96_kernels_EN.html"
RESULTS=$(sed -e '/centos7 (64-bit)/,/CloudLinux Kernels/!d' Deep_Security_96_kernels_EN.html | grep -F '.' | tail -1) > /dev/null 2>&1
rm -f Deep_Security_96_kernels_EN.html* > /dev/null 2>&1
RESULTS=$(echo $RESULTS | sed -e :a -e 's/<[^>]*>//g;/</N;//ba')
RESULTS=$(sed 's/.x86_64/ /g' <<<"$RESULTS")
if [[ $installed == "$RESULTS" ]]
then
  echo $(date +'%b %d') " You are running the latest Trend Micro supported CentOS 7 kernel." | tee -a /var/log/plexity/today.log
else
  echo Attempting to install CentOS 7 kernel: $RESULTS
  install=$(yum -y install kernel-$RESULTS)
  if [[ $install == *"Nothing to do"* ]]
  then
    echo $(date +'%b %d %H:%m:%M') " Kernel installation was attempted but there was nothing to do." | tee -a /var/log/plexity/today.log
  else
    echo $(date +'%b %d %H:%m:%M') " Kernel updated, initiating reboot!" | tee -a /var/log/plexity/today.log
    shutdown -r +1 "Server is rebooting for kernel upgrade." 
  fi
fi
