#!/bin/bash
R="\e[31m" # Red color
G="\e[32m" # Green color
Y="\e[0;33m" # Yellow color]
B="\e[1;33M" # Bold Yellow color
O="\e[1;34m" # Bold Blue color
N="\e[0m"  # No Color

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1) #. tarvatha vache daani print cheyadu 
SCRIPT_DIR=$PWD
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
        echo -e "$B .... $R Error: $2 installation failed."| tee -a $LOG_FILE
        #ACCORDING to our present code $2 is mysql ,mgodb,ngnix
        exit 1
        

    else 
        echo -e "$O $2.....$G sucessfully. $N"| tee -a $LOG_FILE

    fi
} 

dnf install maven -y &>>$LOG_FILE
VALIDATECOMMAND $? "Maven"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
VALIDATECOMMAND $? "Creating roboshop user"

mkdir -p /app
VALIDATECOMMAND $? "Creating /app directory"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOG_FILE
VALIDATECOMMAND $? "Downloading shipping component"
 
cd /app
VALIDATECOMMAND $? "Changing directory to /app"

unzip -o /tmp/shipping.zip &>>$LOG_FILE
VALIDATECOMMAND $? "Extracting shipping component"

mvn clean package &>>$LOG_FILE
VALIDATECOMMAND $? "Building shipping component"

mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
VALIDATECOMMAND $? "Renaming shipping jar file"

cp $SCRIPT_DIR/shippingserver /etc/systemd/system/user.service &>>$LOG_FILE
VALIDATECOMMAND $? "Copying user service file"

systemctl daemon-reload &>>$LOG_FILE
VALIDATECOMMAND $? "Reloading systemd daemon"

systemctl enable user &>>$LOG_FILE
VALIDATECOMMAND $? "Enabling user service"

systemctl start user &>>$LOG_FILE
VALIDATECOMMAND $? "Starting user service"

dnf install mysql -y &>>$LOG_FILE
VALIDATECOMMAND $? "Installing mysql client"

mysql -h mysql.daw86s.space -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOG_FILE
VALIDATECOMMAND $? "Loading shipping schema to mysql"

mysql -h mysql.daws86s.space -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$LOG_FILE
VALIDATECOMMAND $? "Loading shipping app-user to mysql"

mysql -h mysql.daws86s.space -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOG_FILE
VALIDATECOMMAND $? "Loading shipping master data to mysql"

systemctl restart shipping &>>$LOG_FILE
VALIDATECOMMAND $? "Restarting shipping service"