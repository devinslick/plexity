#!/bin/sh
#
#       AUTHOR: Devin Slick
#       Script purpose: Install the latest CentOS7 (x64) kernel supported with Trend Micro Deep Security 9.6
#
mkdir -p /var/log/plexity
echo "Checking for kernel updates compatible with the Trend Micro Deep Security Agent..."
installed=$(uname -r)
installed=$(sed 's/.x86_64/ /g' <<<"$installed")
echo "Running kernel: "$installed
yum -y install wget > /dev/null 2>&1
wget -q "http://files.trendmicro.com/documentation/guides/deep_security/Kernel%20Support/9.6/Deep_Security_96_SP1_kernels_EN.html" -O /tmp/dsa-kernel.latest
RESULTS=$(sed -n '/centos7 (64-bit)/,/<\/table>/p' /tmp/dsa-kernel.latest)
RESULTS=$(echo $RESULTS | sed -e :a -e 's/<[^>]*>//g;/</N;//ba')
RESULTS=$(sed 's/.x86_64/ /g' <<<"$RESULTS")
rm -f /tmp/dsa-kernel.latest > /dev/null 2>&1
available=$(yum check-update | grep -i kernel)
available=$(yum check-update | grep -i kernel.x86_64 | cut --complement -d " " -f 1)
available=$(sed 's/. updates//g' <<<"$available")

if [ $(echo ${#available}) -gt 5 ]; then
        echo "Kernel ${available// /} is available for installation..."
else
        echo "No kernel update is available at this time."
	exit
fi

if [[ $available == *"$RESULTS"* ]]
then
  echo $(date +'%b %d %H:%M:%S')" You are running the latest kernel supported by Deep Security" | tee -a /var/log/plexity/$(date '+%Y%m%d').log
else
  echo Attempting to install CentOS 7 kernel: ${available// /}
  install=$(sudo yum -y install kernel-${available// /}) --disableexcludes=all
  sudo yum -y install kernel-tools-${available// /}
  sudo yum -y install kernel-tools-libs-${available// /}
  sudo yum -y install "kernel-devel-uname-r == ${available// /}" --disableexcludes=all
  if [[ $install == *"Nothing to do"* ]]
  then
    echo $(date +'%b %d %H:%M:%S') " Kernel installation was attempted but there was nothing to do." | tee -a /var/log/plexity/$(date '+%Y%m%d').log
  else
    echo $(date +'%b %d %H:%M:%S') " Kernel updated, initiating reboot!" | tee -a /var/log/plexity/$(date '+%Y%m%d').log
    shutdown -r +1 "Server is rebooting for kernel upgrade."
  fi
fi
