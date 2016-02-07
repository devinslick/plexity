#!/bin/sh
#
#	AUTHOR: Devin Slick
#	Script purpose: Install the latest CentOS 7 (x64) kernel supported with Trend Micro Deep Security 9.6
#
wget -q "http://files.trendmicro.com/documentation/guides/deep_security/Kernel%20Support/9.6/Deep_Security_96_kernels_EN.html"
RESULTS=$(sed -e '/centos7 (64-bit)/,/CloudLinux Kernels/!d' Deep_Security_96_kernels_EN.html | grep -F '.' | tail -1) > /dev/null 2>&1
rm -f Deep_Security_96_kernels_EN.html* > /dev/null 2>&1
RESULTS=$(echo $RESULTS | sed -e :a -e 's/<[^>]*>//g;/</N;//ba')
installed=$(uname -a)
if [[ $installed == *"$RESULTS"* ]]
then
  echo "You are already running the latest CentOS 7 kernel supported by Deep Security."
else
  echo Attempting to install CentOS 7 kernel $RESULTS
  install=$(yum install kernel-$RESULTS)
  if [[ $install == *"Nothing to do"* ]]
  then
    echo "I've attempted to install a kernel but there was nothing to do."
  else
    echo "Your kernel was updated - Time to Reboot!"
    reboot
  fi
fi
