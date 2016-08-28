/opt/gdrive export $(/opt/gdrive list | grep log | head -1 | cut -d ' ' -f 1)
#remove double quotes
cp log.csv log-$(date --date="yesterday" +"%Y%m%d").csv
/opt/gdrive upload log-$(date --date="yesterday" +"%Y%m%d").csv -p $(/opt/gdrive list | grep HistoricalLogs | cut -d ' ' -f 1)
sed -i 's/\"//g' log.csv
#replace dates with padded days
sed -i "s/$(date --date="yesterday" +"%B %d, %Y")/$(date --date="yesterday" +"%Y%m%d")/g" log.csv
#replace dates without padded days
sed -i "s/$(date --date="yesterday" +"%B %-d, %Y")/$(date --date="yesterday" +"%Y%m%d")/g" log.csv
sed -i "s/$(date --date="yesterday" +"%Y%m%d") at /$(date --date="yesterday" +"%Y%m%d"),/g" log.csv
#Only keep lines containing today's date
cat log.csv | grep $(date --date="yesterday" +"%Y%m%d") > /tmp/$(date --date="yesterday" +"%Y%m%d").log
#cat /tmp/$(date --date="yesterday" +"%Y%m%d").log
mkdir -p /media/share/Logs
cp -n /tmp/$(date --date="yesterday" +"%Y%m%d").log /media/share/Logs/
rm -rf log.csv
/opt/gdrive delete $(/opt/gdrive list | grep log | cut -d ' ' -f 1)
