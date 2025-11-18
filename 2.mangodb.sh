#!/bin/bash
R="\e[31m" # Red color
G="\e[32m" # Green color
Y="\e[0;33m" # Yellow color]
B="\e[1;33M" # Bold Yellow color
O="\e[1;34m" # Bold Blue color
N="\e[0m"  # No Color

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1) #. tarvatha vache daani print cheyadu 
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

#earlier mangodb manual ga install chesamu kani ipudu script dwara cheddam
# so automation kosam code rasthey mobexterm dwara direct ga install cheyochu 
cp /home/ec2-user/shell-robo/mongo.repo /etc/yum.repos.d/mongo.repo  #Copying the mongodb reop file to yum.repos.d
VALIDATECOMMAND $? "Mongodb repo file copy"

dnf install mongodb-org -y &>>$LOG_FILE #append cheyadaniki >>
VALIDATECOMMAND $? "Installing Mongodb"

systemctl enable mongod &>>$LOG_FILE
VALIDATECOMMAND $? "Enabling Mongodb service"

systemctl start mongod 
VALIDATECOMMAND $? "Starting Mongodb service"

# sed means stream editor unlike vim it is not required to edit manually 

sed -i 's/120.0.0.1/0.0.0.0/g' /etc/mongod.conf #changing the bind ip from localhost to all ip address # -i means insert and its permanent change
                                                # g means change all occurrences in the file # s means substitute                                                 
VALIDATECOMMAND $? "allowing all remote connections to mongodb"                                               

systemctl restart mongod &>>$LOG_FILE
VALIDATECOMMAND $? "Restarting Mongodb service"