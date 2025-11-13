#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0bb49640c5f48feab"

for instance in $@
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-0bb49640c5f48feab --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Test}]'  --query 'Instances[0].InstanceId' --output text
)
    

#get private ip address of the instance
    if [ $instance != "frontend" ]; then
     IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
     
    else  
     IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)   
    
    fi

    echo "Instance $instance launched with IP address: $IP"
done 
    