#!/bin/bash

# as i have learnt calling the script into another script 
#now iam going to source  this common.sh into the roboshop all sctipts

R="\e[31m" # Red color
G="\e[32m" # Green color
Y="\e[0;33m" # Yellow color]
B="\e[1;33M" # Bold Yellow color
O="\e[1;34m" # Bold Blue color
N="\e[0m"  # No Color

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1) #. tarvatha vache daani print cheyadu 
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.daw86s.space
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
START_TIME=$(date +%s)
 
mkdir -p $LOGS_FOLDER
echo -e "$G script started executed at : $(date) $N" | tee -a $LOG_FILE #tee lets you see the output on the screen while also saving it to a file.

USERID=$(id -u) # prints the user id of current user
if [ $USERID -ne 0 ]; then
   echo  -e " $R You must run this script as root user."  #i forgot ot add -e check it 
   exit 1 #other than 0 take it as failure ''
fi

VALIDATECOMMAND(){ #no space should be between validate command and ()
    if [ $1 -ne 0 ]; then
        echo -e "$B .... $R Error: $2 installation failed."| tee -a $LOG_FILE
        #ACCORDING to our present code $2 is mysql ,mgodb,ngnix
        exit 1
        

    else 
        echo -e "$O $2.....$G sucessfully. $N"| tee -a $LOG_FILE

    fi
} 

print_total_time(){
END_TIME=$(date +%s)
TOTAL_TIME=$(($END_TIME-$START_TIME))
echo -e "$G Script executed successfully in $TOTAL_TIME seconds. $N" | tee -a $LOG_FILE
}


 cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo  #Copying the mongodb repo file to yum.

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATECOMMAND $? "Installing Mongodb client"




nodejs_setup(){
   dnf module disable nodejs -y &>>$LOG_FILE
   VALIDATECOMMAND $? "Disabling Nodejs module"
   dnf module enable nodejs:20 -y &>>$LOG_FILE
   VALIDATECOMMAND $? "Enabling Nodejs 20 module"
   dnf install nodejs -y &>>$LOG_FILE
   VALIDATECOMMAND $? "Nodejs"
   npm install &>>$LOG_FILE
   VALIDATECOMMAND $? "Installing nodejs dependencies for $app_name"

}

roboshop_user_setup(){
     id roboshop &>>$LOG_FILE
     if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
        VALIDATECOMMAND $? "Creating roboshop user"
     else
        echo -e "$O roboshop user already exists. Skipping user creation. $N" &>>$LOG_FILE
     fi
}

app_setup(){
    mkdir -p /app 
VALIDATECOMMAND $? "Creating /app directory"

curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>>$LOG_FILE
VALIDATECOMMAND $? "Downloading $app_name component"

cd /app
VALIDATECOMMAND $? "Changing directory to /app"

rm -rf /app/*
VALIDATECOMMAND $? "Cleaning up old $app_name content" 

unzip /tmp/$app_name.zip
VALIDATECOMMAND $? "Extracting $app_name component"

}

systemd_setup(){
         cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service 
         VALIDATECOMMAND $? "Copying $app_name service file"

         systemctl daemon-reload
         systemctl enable $app_name
         systemctl start $app_name
        VALIDATECOMMAND $? "Starting $app_name service"

    }