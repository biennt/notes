# Change these to your liking.
	# This configuration will run once per second (DELAY)
	# for 1800 iterations (1800 seconds == 30 minutes)
	COUNT=0
	MAXCOUNT=1800
	DELAY=1
	FILENAME=/shared/tmp/$(echo $HOSTNAME).`date +"%Y.%m.%d.%H:%M:%S"`.topoutput.log
	touch ${FILENAME}
	echo "Output: ${FILENAME}"
	while [ ${COUNT} -le ${MAXCOUNT} ]
	do
	  (
	    date
	    top -cbn 1
	    tmsh -c "show sys tmm-info; show sys memory"
	    bigtop -once
	    tmctl -a
	    echo "###################"
	  ) >> ${FILENAME}
	  (( COUNT++ ))
	  sleep ${DELAY}
	done
 
