#!/bin/sh
#
#	AUTHOR: Devin Slick
#	Script purpose: Install the latest CentOS 7 (x64) kernel supported with Trend Micro Deep Security 9.6
#
wget "http://files.trendmicro.com/documentation/guides/deep_security/Kernel%20Support/9.6/Deep_Security_96_kernels_EN.html"
RESULTS=$(sed -e '/centos7 (64-bit)/,/CloudLinux Kernels/!d' Deep_Security_96_kernels_EN.html | grep -F '.' | tail -1)
rm -f Deep_Security_96_kernels_EN.html*
RESULTS=$(echo $RESULTS | sed -e :a -e 's/<[^>]*>//g;/</N;//ba')

installed=$(uname -a)
if [[ $installed == *"$RESULTS"* ]]
then
  echo "Fully updated!"
else
  echo Attempting to install CentOS 7 kernel $RESULTS
  install=$(yum install kernel-$RESULTS)
  if [[ $install == *"Nothing to do"* ]]
  then
    echo "There was nothing to do!"
  else
    echo "Yay, the kernel was updated.  Time to reboot"
    reboot
  fi
fi

