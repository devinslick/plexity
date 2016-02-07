#!/bin/bash
echo '0 3 * * * /root/scripts/plexity/update.sh' | crontab -
(crontab -l ; echo "30 3 * * * /usr/bin/yum -y -e 0 -x kernel* update") | crontab -
(crontab -l ; echo "0 4 * * * /root/scripts/plexity/ds_kernel.sh") | crontab -
(crontab -l ; echo "*/30 * * * * /opt/ds_agent/dsa_control -m > /dev/null 2>&1") | crontab -
