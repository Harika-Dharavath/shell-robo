#!/bin/bash

source ./common.sh    

#installing redis  

dnf module disable redis -y &>>$LOG_FILE
VALIDATECOMMAND $? "Disabling Redis module"
dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATECOMMAND $? "Enabling Redis 7 module"
dnf install redis -y &>>$LOG_FILE
VALIDATECOMMAND $? "Redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no ' /etc/redis/redis.conf &>>$LOG_FILE
VALIDATECOMMAND $? "allowing remote connections in redis.conf"

systemctl enable redis &>>$LOG_FILE
VALIDATECOMMAND $? "Enabling Redis service"
systemctl start redis &>>$LOG_FILE
VALIDATECOMMAND $? "Starting Redis service"

END_TIME=$(date +%s)
TOTAL_TIME=$(($END_TIME-$START_TIME))
echo -e "$G Script executed successfully in $TOTAL_TIME seconds. $N" | tee -a $LOG_FILE