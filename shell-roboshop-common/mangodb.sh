#!/bin/bash
 source ./common.sh

 check_root # calling the function from common.sh

cp mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATECOMMAND $? "Copying Mongodb Repo file"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATECOMMAND $? "Installing Mongodb Server"

systemctl enable mongod &>>$LOG_FILE
VALIDATECOMMAND $? "Enabling Mongodb Service"

systemctl start mongod &>>$LOG_FILE
VALIDATECOMMAND $? "Starting Mongodb Service"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATECOMMAND $? "Allowing remote connections in Mongodb config file"

systemctl restart mongod &>>$LOG_FILE
VALIDATECOMMAND $? "Restarting Mongodb Service"

print_total_time  # calling the function from common.sh