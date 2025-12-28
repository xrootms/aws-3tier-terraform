#! /bin/bash
# shellcheck disable=SC2164
set -e
cd /home/ubuntu

sudo apt-get update -y
sudo apt-get install -y \
 mysql-client \
  python3 \
  python3-pip \
  python3-flask \
  python3-pymysql \
  python3-boto3 \
  git


if [ -d "aws-live" ]; then cd aws-live
  git pull
else
  git clone https://github.com/xrootms/aws-live.git
  cd aws-live
fi

nohup python3 Empapp.py > app.log 2>&1 &    #Redirect stderr(2) to wherever stdout(1) is going


# stdout = output
# stderr = error
# 2>&1 = error + output together
# That’s it — simple and correct
