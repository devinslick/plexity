#!/bin/bash
echo This script will update Deep Security Manager
wget http://files.trendmicro.com/products/deepsecurity/en/9.6/9.6_ServicePack1/Manager-Linux-9.6.4014.x64.sh -O /tmp/dsmupdate.sh --quiet
/tmp/dsmupdate.sh -q

