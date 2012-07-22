#!/bin/bash
if [ $# -eq 2 ]
then

	for INSTANCE_ID in `elb-describe-instance-health $2 | cut -c14-23`
	do 
		INSTANCE_IP=`ec2-describe-instances $INSTANCE_ID | sed -n 2p | cut -f17`
		STATUS=`curl --resolve $1:80:$INSTANCE_IP $1 -I -s | head -n 1`
		echo "$INSTANCE_ID: $STATUS"
	done
else
	echo "USAGE: check-elb-instances-status.sh domain-name elb-name"
fi
