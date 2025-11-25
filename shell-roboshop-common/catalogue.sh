#!/bin/bash

source ./common.sh
app_name=catalogue
roboshop_user_setup
app_setup
systemd_setup

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo  #Copying the mongodb repo file to yum.

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATECOMMAND $? "Installing Mongodb client"


INDEX=$(mongosh --quiet --host "$MONGODB_HOST" --eval 'db.getMongo().getDBNames().indexOf("catalogue")' 2>/dev/null || echo -1)
if [ "$INDEX" -eq -1 ]; then
  mongosh --host "$MONGODB_HOST" </app/db/master-data.js &>>"$LOG_FILE"
  VALIDATECOMMAND $? "Loading catalogue schema to Mongodb"
else
    echo -e "${O}catalogue database already exists. Skipping catalogue schema load.${N}" | tee -a "$LOG_FILE"
fi

systemctl restart $app_name
VALIDATECOMMAND $? "Restarting catalogue service"

print_total_time