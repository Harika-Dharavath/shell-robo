# !/bin/bash
R="\e[31m"     # Red color
G="\e[32m" # Green color
Y="\e[0;33m" # Yellow color]
B="\e[1;33M" # Bold Yellow color
O="\e[1;34m" # Bold Blue color
N="\e[0m"  # No Color

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1) #. tarvatha vache daani print cheyadu 
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

dnf install mysql-server -y &>>$LOG_FILE
VALIDATECOMMAND $? "MySQL Server"
systemctl enable mysqld &>>$LOG_FILE
VALIDATECOMMAND $? "Enabling MySQL service"
systemctl start mysqld &>>$LOG_FILE
VALIDATECOMMAND $? "Starting MySQL service"
mysql_secure_installation --set-root-pass RoboShop@1
VALIDATECOMMAND $? "Securing MySQL installation"

END_TIME=$(date +%s)
TOTAL_TIME=$(($END_TIME-$START_TIME))
echo -e "$G Script executed successfully in $TOTAL_TIME seconds. $N" | tee -a $LOG_FILE