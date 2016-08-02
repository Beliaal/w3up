#!/bin/bash
#
#########################################################################################################################
#																														#
#  Check that <server> is up and serving http requests. If server fails to respond, log time and date for occurence.	#
#  Open and edit the settings.conf file for options and explanations													#
#																														#
#																								(c) Tommy Leeman, 2016  #
#																														#
#########################################################################################################################

# No need to edit below this line.

if [ -f ./settings.conf ] ; then
	. ./settings.conf
	INTERVAL=$(($INTERVAL * 60))

	LOGFILE=w3up_$(date +"%Y%m%d_%H%M").log
	touch $LOGFILE
	printf "Log started on $(date +'%Y/%m/%d at %H:%M')\nInterval:\t$INTERVAL\nTimeout:\t$TIMEOUT\n\n==================================\nLog Begin:\n" >> ./$LOGFILE

	# TODO: add logic to sanitycheck the variables....
else
	printf "Can not find \"settings.conf\".\n\nCreating file with default settings. Edit before use.\n"
	touch ./settings.conf
	exit 1
	# TODO: add the default file logic
fi



if [ ! -x /usr/bin/curl ] ; then
    printf "Unable to locate curl (/usr/bin/curl). Install before use!\n(debian: sudo apt-get install curl\n\nExiting!!!\n"
	exit 1
    # TODO: 
fi

while true
do
ERROR=$(/usr/bin/curl --silent --head --max-time $TIMEOUT --write-out %{http_code} $SERVER -o /dev/null)

if [ ! $ERROR -eq 200 ] ; then
	# We expect a properly working machine to generate 200 for success. We got another response which is unexpected and need to log the error and Date/Time.
	LOGEVENT="$(date +'%Y/%m/%d %H:%M') - http error: $ERROR"
	printf $LOGEVENT >> ./$LOGFILE
fi

if [ $ERROR -eq 0 ] ; then
    # We recieved a timeout error, log it as such with Date/Time.
    LOGEVENT="$(date +'%Y/%m/%d %H:%M') - Timed out"
    printf $LOGEVENT >> ./$LOGFILE
fi


sleep $INTERVAL
done
