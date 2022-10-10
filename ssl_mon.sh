#!/bin/bash

# Edit these parameters
from=<your email address>
to=<destination email address>
port=443
daysToWarn=11

#These should not be modified.
outfile=certificate_expirations.csv
current_date=`date +%Y-%m-%d_%H:%M:%S`
dayOfWeek=`date +"%u"`
logfile=logs/ssl_mon.${dayOfWeek}.log
current_directory=`pwd`



#populate file in same directory called servers.txt with domains to check.
servers=`cat servers.txt`

#delete old logfiles
find ./logs/ -name "ssl_mon.*.log" -type f -mtime +6 -delete

#make sure log file exists.
if test -f "$logfile"; then
    touch $logfile
else
    echo "Logfile started at ${current_date}" > $logfile
fi

#re-init output file
echo currentDate, domainUrl, expDate>$outfile

#make sure ssl is installed
ssl_exe=`which openssl 2>> /dev/null`

if [ -z "$ssl_exe" ]; then
    echo "${current_date}: openssl not installed. exiting" >> $logfile
    echo "You must install openssl library for your distribution, examples:"
    echo "Fedora/RedHat: sudo dnf install openssl"
    echo "Ubuntu/Debian: sudo apt install openssl"
    exit 99
fi


getSslInfo() {
    #function variables
    domain=$1
    port=$2
    
    #logging
    echo "" >> $logfile
    echo "Testing SSL Cert for ${domain} on port ${port} at ${current_date}" >> $logfile
    
    #use ssl to get cert expiration date
    echo "--------------------------------------------" >> $logfile
    rawoutput=`echo | ${ssl_exe} s_client -servername ${domain} -connect ${domain}:${port} 2>>$logfile | ${ssl_exe} x509 -noout -dates | grep notAfter`
    
    #get expdates and format output, write to logs
    formattedOutput=`echo $current_date,$rawoutput | sed "s/notAfter=/$domain\,/g"`
    echo $formattedOutput | tee -a $logfile $outfile

    #convert dates into unix epoch time (seconds since Jan 1 1970 00:00:00UTC)
    dateField=`echo $formattedOutput | cut -d ',' -f 3 | sed 's/ GMT//'`
    formattedCurrDate=`date +%s`
    formattedExpDate=`date -d "$dateField" +%s`

    #compare dates and find number of days till expiration
    let DIFF=($formattedExpDate-$formattedCurrDate)/86400
    
    #send email alert if expiration less than 11 days
    if [ $DIFF -lt $daysToWarn ]; then
        echo -e "From: ${from}\nto: ${to}\nSubject: SSL Certificate for "$domain" expiring in "$DIFF" days" |\
        /usr/sbin/ssmtp ${to}
    fi

    }

for server in $servers
do
    getSslInfo $server $port
done

exit 0
