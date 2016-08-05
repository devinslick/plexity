#!/bin/bash
wget $(cat /var/plexity/homelog) -O /tmp/home-temp.log
#remove double quotes
sed -i 's/\"//g' /tmp/home-temp.log
#replace dates with padded days
sed -i "s/$(date --date="yesterday" +"%B %d, %Y")/$(date --date="yesterday" +"%Y%m%d")/g" /tmp/home-temp.log
#replace dates without padded days
sed -i "s/$(date --date="yesterday" +"%B %-d, %Y")/$(date --date="yesterday" +"%Y%m%d")/g" /tmp/home-temp.log
sed -i "s/$(date --date="yesterday" +"%Y%m%d") at /$(date --date="yesterday" +"%Y%m%d"),/g" /tmp/home-temp.log
#Only keep lines containing today's date
cat /tmp/home-temp.log | grep $(date --date="yesterday" +"%Y%m%d") > /tmp/home-$(date --date="yesterday" +"%Y%m%d").log
rm -rf /tmp/home-temp.log
cat /tmp/home-$(date --date="yesterday" +"%Y%m%d").log
mkdir -p /media/share/Logs
mv -n /tmp/home-$(date --date="yesterday" +"%Y%m%d").log /media/share/Logs/
