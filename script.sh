#! /bin/bash
GOLANGURL="https://github.com/servian/TechChallengeApp/releases/download/v.0.11.0/TechChallengeApp_v.0.11.0_linux64.zip"
sudo -i
yum update -y
yum install vim unzip -y
yum -y install lynx
cd /tmp/
wget https://dl.google.com/go/go1.13.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.13.linux-amd64.tar.gz
rm -rf /tmp/go1.13.linux-amd64.tar.gz
wget $GOLANGURL -O golangbin.zip
mkdir /tmp/golang
unzip golangbin.zip -d /tmp/golang/ 
useradd --shell /sbin/nologin golang
rsync -avzh /tmp/golang/ /usr/local/golang/ 
chown -R golang.golang /usr/local/golang/dist
chown -R golang.golang /usr/local/go/bin
export PATH=$PATH:/usr/local/go/bin
rm -rf /tmp/golang/

systemctl start firewalld
systemctl enable firewalld
firewall-cmd --get-active-zones
firewall-cmd --zone=public --add-port=8080/tcp --permanent

firewall-cmd --zone=public --add-port=80/tcp --permanent

firewall-cmd --zone=public --add-port=3000/tcp --permanent
firewall-cmd --reload
cd /usr/local/golang/dist



./TechChallengeApp updatedb
yum -y install lynx

cat <<EOT>> /usr/local/golang/dist/conf.toml
"DbUser" = "postgres"
"DbPassword" = "changeme"
"DbName" = "app"
"DbPort" = "5432"
"DbHost" = "localhost"
"DbType" = "boltdb"
"ListenHost" = "localhost"
"ListenPort" = "80"
EOT
