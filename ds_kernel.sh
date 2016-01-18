#!/bin/sh
#
#	AUTHOR: Devin Slick
#	Script purpose: Install the latest CentOS 7 (x64) kernel supported with Trend Micro Deep Security 9.6
#
wget "http://files.trendmicro.com/documentation/guides/deep_security/Kernel%20Support/9.6/Deep_Security_96_kernels_EN.html"
RESULTS=$(sed -e '/centos7 (64-bit)/,/CloudLinux Kernels/!d' /root/scripts/ds_kernel/Deep_Security_96_kernels_EN.html | grep -F '.' | tail -1)
RESULTS=$(echo $RESULTS | sed -e :a -e 's/<[^>]*>//g;/</N;//ba')
echo Attempting to install CentOS 7 kernel $RESULTS
yum install kernel-$RESULTS
rm Deep_Security_96_kernels_EN*
