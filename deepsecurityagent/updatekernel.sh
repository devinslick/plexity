#!/bin/sh
#
#	AUTHOR: Devin Slick
#	Script purpose: Install the latest CentOS 7 (x64) kernel supported with Trend Micro Deep Security 9.6
#
echo "Checking for kernel updates compatible with the Trend Micro Deep Security Agent..."
installed=$(uname -r)
installed=$(sed 's/.x86_64/ /g' <<<"$installed")
echo "Running kernel: "$installed
wget -q "http://files.trendmicro.com/documentation/guides/deep_security/Kernel%20Support/9.6/Deep_Security_96_SP1_kernels_EN.html" -O /tmp/dsa-kernel.latest
RESULTS=$(sed -e '/centos7 (64-bit)/,/CloudLinux Kernels/!d' /tmp/dsa-kernel.latest | grep -F '.' | tail -1) > /dev/null 2>&1
rm -f /tmp/dsa-kernel.latest > /dev/null 2>&1
RESULTS=$(echo $RESULTS | sed -e :a -e 's/<[^>]*>//g;/</N;//ba')
RESULTS=$(sed 's/.x86_64/ /g' <<<"$RESULTS")
if [[ $installed == "$RESULTS" ]]
then
  echo $(date +'%b %d %H:%M:%S')" You are running the latest kernel supported by Deep Security" | tee -a /var/log/plexity/$(date '+%Y%m%d').log
else
  echo Attempting to install CentOS 7 kernel: $RESULTS
  install=$(sudo yum -y install kernel-$RESULTS)
  if [[ $install == *"Nothing to do"* ]]
  then
    echo $(date +'%b %d %H:%M:%S') " Kernel installation was attempted but there was nothing to do." | tee -a /var/log/plexity/$(date '+%Y%m%d').log
  else
    echo $(date +'%b %d %H:%M:%S') " Kernel updated, initiating reboot!" | tee -a /var/log/plexity/$(date '+%Y%m%d').log
    shutdown -r +1 "Server is rebooting for kernel upgrade." 
  fi
fi
