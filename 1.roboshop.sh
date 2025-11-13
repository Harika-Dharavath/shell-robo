#!/bin/bash

AMI_ID="ami-024ec8bac6ca30b00"
SG_ID="sg-0bb49640c5f48feab"

for instance in $@
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micr0 --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" 
    --query 'Instances[0].InstanceId' --output text)

#get private ip address of the instance
    if [ $instance != "frontend"] then
     IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
    else  
     IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)   
    fi

    echo "Instance $instance launched with IP address: $IP"
done 
    