#! /bin/bash
sudo -i
GOLANGURL="https://github.com/servian/TechChallengeApp/releases/download/v.0.11.0/TechChallengeApp_v.0.11.0_linux64.zip"
cd /tmp/
wget https://dl.google.com/go/go1.13.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.13.linux-amd64.tar.gz
rm -rf /tmp/go1.13.linux-amd64.tar.gz
mkdir /tmp/golang
yum update -y
yum install vim unzip lynx -y
wget $GOLANGURL -O golangbin.zip
unzip golangbin.zip -d /tmp/golang/ 
useradd --shell /sbin/nologin golang
rsync -avzh /tmp/golang/ /usr/local/golang/ 
chown -R golang.golang /usr/local/golang/dist
chown -R golang.golang /usr/local/go/bin
export PATH=$PATH:/usr/local/go/bin
rm -rf /tmp/golang/
cd /usr/local/golang/dist
./TechChallengeApp updatedb

