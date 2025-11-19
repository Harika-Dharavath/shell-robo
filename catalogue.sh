#!/bin/bash
R="\e[31m" # Red color
G="\e[32m" # Green color
Y="\e[0;33m" # Yellow color]
B="\e[1;33M" # Bold Yellow color
O="\e[1;34m" # Bold Blue color
N="\e[0m"  # No Color

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1) #. tarvatha vache daani print cheyadu 
SCRIPT_DIR=$(pwd)/$0
MONGODB_HOST=mongodb.daw86s.space
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOGS_FOLDER
echo -e "$G script started executed at : $(date) $N" | tee -a $LOG_FILE #tee lets you see the output on the screen while also saving it to a file.

USERID=$(id -u) # prints the user id of current user
if [ $USERID -ne 0 ]; then
   echo  -e " $R You must run this script as root user."  #i forgot ot add -e check it 
   exit 1 #other than 0 take it as failure ''
fi

VALIDATECOMMAND(){ #no space should be between validate command and ()
    if [ $1 -ne 0 ]; then
        echo -e "$B Error: $2 installation failed."
        #ACCORDING to our present code $2 is mysql ,mgodb,ngnix
        exit 1
        

    else 
        echo -e "$O $2 installed successfully."

    fi
}      

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATECOMMAND $? "Disabling Nodejs module"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATECOMMAND $? "Enabling Nodejs 20 module"

dnf install nodejs -y &>>$LOG_FILE
VALIDATECOMMAND $? "Nodejs"
id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
     useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
     VALIDATECOMMAND $? "Creating roboshop user"
else
        echo -e "$O roboshop user already exists. Skipping user creation. $N" &>>$LOG_FILE
 fi

mkdir -p /app 
VALIDATECOMMAND $? "Creating /app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
VALIDATECOMMAND $? "Downloading catalogue component"

cd /app
VALIDATECOMMAND $? "Changing directory to /app"

rm -rf /app/*
VALIDATECOMMAND $? "Cleaning up old catalogue content" 

unzip /tmp/catalogue.zip
VALIDATECOMMAND $? "Extracting catalogue component"

npm install
VALIDATECOMMAND $? "Installing nodejs dependencies for catalogue"

cp $SCRIPT_DIR /catalogue.service /etc/systemd/system/catalogue.service 
VALIDATECOMMAND $? "Copying catalogue service file"

systemctl daemon-reload
systemctl enable catalogue
systemctl start catalogue
VALIDATECOMMAND $? "Starting catalogue service"
 
cp mongo.repo /etc/yum.repos.d/mongo.repo  #Copying the mongodb repo file to yum.

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATECOMMAND $? "Installing Mongodb client"
mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
VALIDATECOMMAND $? "Loading catalogue schema to Mongodb"
systemctl restart catalogue
VALIDATECOMMAND $? "Restarting catalogue service"
