#!/bin/bash
if [ $# -eq 2 ]
then
	ELB_INSTANCES=`elb-describe-instance-health $2 | cut -c14-23`
	NUMBER_OF_INSTANCES=`echo "$ELB_INSTANCES" | wc -l`
	echo "$NUMBER_OF_INSTANCES instances found in $2"
	for INSTANCE_ID in $ELB_INSTANCES
	do 
		echo "Checking status of $INSTANCE_ID"
		INSTANCE_IP=`ec2-describe-instances $INSTANCE_ID | sed -n 2p | cut -f17`
		echo " Instance IP is: $INSTANCE_IP"
		STATUS=`curl --resolve $1:80:$INSTANCE_IP $1 -I -s | head -n 1 | tr -d '\r\n'`
		echo " Response status is: $STATUS"
		if [ "$STATUS" != 'HTTP/1.1 200 OK' ]
		then
			echo " Removig instance from elb"
			elb-deregister-instances-from-lb $2 --instances $INSTANCE_ID
		fi
		echo ""
	done
else
	echo "USAGE: check-elb-instances-status.sh domain-name elb-name"
fi
