#!/bin/bash
# create a cronjob to run this script every minute or so 
# * * * * * /home/admin/updatepool.sh
# 

# change the below variables
fqdn='srv.bienlab.com'
# your own DNS servers which support service-discovery via DNS protocol
nameserver1='1.8.8.8'
nameserver2='1.1.1.1'

# you need to create this pool before running the script (and assign a monitor as well)
poolname='dynamicpool'
# for now, port number of the pool member should be the same for all members
portnum='9981'

modified=0
# if you want TCP, just add +tcp into all dig commands below, by default, it uses UDP
membercount1=`dig @$nameserver1 $fqdn A | grep $fqdn | grep -v ';' | wc -l`
if [ $membercount1 -eq 0 ]; then
  membercount2=`dig @$nameserver2 $fqdn A | grep $fqdn | grep -v ';' | wc -l`
  if [ $membercount2 -eq 0 ]; then
    echo 'FATAL ERROR: error when query DNS server'
    exit 1
  else
    echo "INFO: using $nameserver2"
    nameserver=$nameserver2
  fi
else
  echo "INFO: using $nameserver1"
  nameserver=$nameserver1
fi

newmembers=`dig @$nameserver $fqdn A | grep $fqdn | grep -v ';' | tr -s "[:blank:]" " " | cut -d" " -f5`
oldmembers=`tmsh list ltm pool $poolname | grep address | tr -s "[:blank:]" " " | cut -d" " -f3`

# adding new members
for member in $newmembers; do
 if printf '%s\n' "${oldmembers[@]}" | grep -q $member; then
    echo "INFO: skipping $member"
 else
    echo "INFO: adding $member"
    tmsh create ltm node node$member address $member
    tmsh modify ltm pool $poolname members add { node$member:$portnum }
    modified=1
 fi
done

# remove deleted members
for member in $oldmembers; do
 if printf '%s\n' "${newmembers[@]}" | grep -q $member; then
    echo "INFO: skipping $member"
 else
    echo "INFO: deleting $member"
    tmsh modify ltm pool $poolname members delete { node$member:$portnum }
    tmsh delete ltm node node$member
    modified=1
 fi
done

if [ $modified -eq 1 ]; then
  tmsh save sys config
else
  echo "NO CHANGE"
fi
