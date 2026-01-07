#!/bin/bash
# shellcheck disable=SC2164
set -e

apt update -y
apt install -y mysql-client

until mysql -h ${rds_endpoint} -u dbuser -pdbpassword -e "SELECT 1"; do
  echo "Waiting for RDS..."
  sleep 10
done

mysql -h ${rds_endpoint} -u dbuser -pdbpassword <<EOF
CREATE DATABASE IF NOT EXISTS employee;
USE employee;

CREATE TABLE IF NOT EXISTS employeetb (
  empid VARCHAR(20),
  fname VARCHAR(20),
  lname VARCHAR(20),
  pri_skill VARCHAR(20),
  location VARCHAR(20)
);
EOF


sleep 20
cd /home/ubuntu

sudo apt-get update -y
sudo apt-get install -y \
  python3 \
  python3-pip \
  python3-flask \
  python3-pymysql \
  python3-boto3 \
  git


if [ -d "ERMS-SRL" ]; then cd ERMS-SRL
  git pull
else
  git clone https://github.com/xrootms/ERMS-SRL.git
  #cd ERMS-SRL
fi


#cd ERMS-SRL
#edit port 5000, 
# edit config.py and put s3 and rds endpoint
#sudo python3 EmpApp.py



