#!/bin/bash
echo This script will update Deep Security Manager
wget http://files.trendmicro.com/products/deepsecurity/en/9.6/Manager-Linux-9.6.4093.x64.sh -O /tmp/dsmupdate.sh
chmod +x /tmp/dsmupdate.sh
/tmp/dsmupdate.sh -q
