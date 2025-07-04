#!/bin/bash

## curlformat.txt file
#lookup:  %{time_namelookup}\n
#tcpconnect:  %{time_connect}\n
#appconnect:  %{time_appconnect}\n
#pretransfer:  %{time_pretransfer}\n
#redirect:  %{time_redirect}\n
#starttransfer:  %{time_starttransfer}\n
#total:  %{time_total}\n

#interval (second)
i=10

# prepare your own url command including headers, payload, method...
# remember to keep -w @curlformat.txt in the beginning

url="https://vnexpress.net/"

while true; do

    curl -w @curlformat.txt -o output.txt -s $url > curlmetrics.txt

    echo "---- for debug ----"
    echo "raw curlmetrics.txt file:"
    cat curlmetrics.txt
    echo "-------------"

    lookup=`cat curlmetrics.txt | grep "lookup" | cut -d ':' -f 2`
    lookup=`echo "scale=0;$lookup * 1000000" | bc | cut -d "." -f 1`

    tcpconnect=`cat curlmetrics.txt | grep "tcpconnect" | cut -d ':' -f 2`
    tcpconnect=`echo "scale=0;$tcpconnect * 1000000" | bc | cut -d "." -f 1`

    appconnect=`cat curlmetrics.txt | grep "appconnect" | cut -d ':' -f 2`
    appconnect=`echo "scale=0;$appconnect * 1000000" | bc | cut -d "." -f 1`

    pretransfer=`cat curlmetrics.txt | grep "pretransfer" | cut -d ':' -f 2`
    pretransfer=`echo "scale=0;$pretransfer * 1000000" | bc | cut -d "." -f 1`

    starttransfer=`cat curlmetrics.txt | grep "starttransfer" | cut -d ':' -f 2`
    starttransfer=`echo "scale=0;$starttransfer * 1000000" | bc | cut -d "." -f 1`

    total=`cat curlmetrics.txt | grep "total" | cut -d ':' -f 2`
    total=`echo "scale=0;$total * 1000000" | bc | cut -d "." -f 1`

    tcpdur=`expr $tcpconnect - $lookup`
    echo "time spent for tcp connect (microsecond): $tcpdur"

    ssldur=`expr $appconnect - $tcpconnect`
    echo "time spent for SSL: $ssldur"

    senddur=`expr $pretransfer - $appconnect`
    echo "time spent for sending request: $senddur"

    ttfb=`expr $starttransfer - $pretransfer`
    echo "time-to-first-byte: $ttfb"

    totaldur=`expr $total - $starttransfer`
    echo "time to download: $totaldur"

    echo "-------------------"

    # below metrics will be sent to push gateway then stored in a prometheus server
    #
    echo "# TYPE lookup gauge" > metrics.txt
    echo "lookup{url=\"$url\"} $lookup" >> metrics.txt

    echo "# TYPE tcpconnect gauge"  >> metrics.txt
    echo "tcpconnect{url=\"$url\"} $tcpconnect"  >> metrics.txt

    echo "# TYPE appconnect gauge"  >> metrics.txt
    echo "appconnect{url=\"$url\"} $appconnect"  >> metrics.txt

    echo "# TYPE pretransfer gauge"  >> metrics.txt
    echo "pretransfer{url=\"$url\"} $pretransfer"  >> metrics.txt

    echo "# TYPE starttransfer gauge"  >> metrics.txt
    echo "starttransfer{url=\"$url\"} $starttransfer"  >> metrics.txt

    echo "# TYPE total gauge"  >> metrics.txt
    echo "total{url=\"$url\"} $total"  >> metrics.txt

    # below are 'duration metrics`
    echo "# TYPE tcpdur gauge"  >> metrics.txt
    echo "tcpdur{url=\"$url\"} $tcpdur"  >> metrics.txt

    echo "# TYPE ssldur gauge"  >> metrics.txt
    echo "ssldur{url=\"$url\"} $ssldur"  >> metrics.txt

    echo "# TYPE senddur gauge"  >> metrics.txt
    echo "senddur{url=\"$url\"} $senddur"  >> metrics.txt

    echo "# TYPE ttfb gauge"  >> metrics.txt
    echo "ttfb{url=\"$url\"} $ttfb"  >> metrics.txt

    echo "# TYPE totaldur gauge"  >> metrics.txt
    echo "totaldur{url=\"$url\"} $totaldur"  >> metrics.txt

    curl --data-binary @metrics.txt http://push_gateway/metrics/job/pushgateway

    sleep $i
done
