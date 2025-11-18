#!/bin/bash
set -euo pipefail

# colors
R="\e[31m"     # Red
G="\e[32m"     # Green
Y="\e[0;33m"   # Yellow
B="\e[1;33m"   # Bold Yellow
O="\e[1;34m"   # Bold Blue
N="\e[0m"      # No Color

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME="$(basename "$0" | cut -d'.' -f1)"  # safer way to get script base name
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p "$LOGS_FOLDER"
echo -e "${G}script started executed at : $(date)${N}" | tee -a "$LOG_FILE"

USERID=$(id -u) # prints the user id of current user
if [ "$USERID" -ne 0 ]; then
  echo -e "${R}You must run this script as root user.${N}" | tee -a "$LOG_FILE"
  exit 1
fi

VALIDATECOMMAND(){ # usage: VALIDATECOMMAND <exit_code> "<component>"
  local exit_code="${1:-1}"
  local component="${2:-operation}"
  if [ "$exit_code" -ne 0 ]; then
    echo -e "${B}Error: ${component} installation failed.${N}" | tee -a "$LOG_FILE"
    exit 1
  else
    echo -e "${O}${component} installed successfully.${N}" | tee -a "$LOG_FILE"
  fi
}

# Optional helper: create MongoDB yum repo if local repo file missing.
# Call create_mongo_repo_if_missing "<local_repo_path>" "<target_repo_filename>" "<mongo_version>"
# Example: create_mongo_repo_if_missing "/home/ec2-user/shell-robo/mongo.repo" "mongodb-org-6.0.repo" "6.0"
create_mongo_repo_if_missing() {
  local local_repo_path="${1:-/home/ec2-user/shell-robo/mongo.repo}"
  local target_repo_filename="${2:-mongodb-org-6.0.repo}"
  local mongo_version="${3:-6.0}"
  local target_repo="/etc/yum.repos.d/${target_repo_filename}"

  if [ -f "$local_repo_path" ]; then
    echo "Found local repo file: $local_repo_path. Copying to $target_repo" | tee -a "$LOG_FILE"
    cp -v "$local_repo_path" "$target_repo" | tee -a "$LOG_FILE"
  else
    echo "Local repo not found. Creating $target_repo for MongoDB ${mongo_version} (Amazon Linux style)..." | tee -a "$LOG_FILE"
    sudo tee "$target_repo" > /dev/null <<EOF
[mongodb-org-${mongo_version}]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2/mongodb-org/${mongo_version}/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-${mongo_version}.asc
EOF
    echo "Created $target_repo" | tee -a "$LOG_FILE"
  fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo  #Copying the mongodb reop file to yum.repos.d
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