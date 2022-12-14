# ssl_check
Utility to monitor ssl certificates and email warning if nearly expiring

### Requirements:
1. OpenSSL installed
2. ssmtp installed and configured

### Instructions
1. Configure the ssl_mon.sh file with your email address and the destination email address information.
2. You can also change the days to warn at the top of the file.
3. Customize your servers.txt file to the list of addresses you'd like to monitor. The value after the comma determines if it's a web server (HTTPS) or a Postgres Server (psql).
4. Run the script manually or add to cron to schedule daily cert checks.

### Output
- Output is generated in the certificate_expirations.csv doc in a CSV format.  This is refreshed on each run.

### Logs
- The logs folder will contain a file for each day of the week, which will overwrite after 7 days.

### To-Do
1. Fix working directory for cron usage.
2. Cleanup
