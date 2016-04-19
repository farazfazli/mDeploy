#!/bin/bash
# CRONTAB: 0,10,20,30,40,50 * * * * sudo pkill -ef meteor
# Script written by Faraz
# Automates forwarding a domain to a Meteor web app via Nginx
SITENAME="$1" # Site Name (Without URL)
REPO="$2" # Site URL excluding http:// or www. (subdomain for now)
PORT="$3" # <- Port passed in
SITEURL="$1.goblog.pw"
if [ -z "$SITENAME"  ] || [ -z "$SITEURL"  ] || [ -z "$PORT"  ] || [ -d "$SITEURL" ]
then
      echo 'Error, not enough arguments!'
        exit 2
    fi

    mkdir $SITEURL
    cd $SITEURL
    FILE=$(pwd)/runmeteor.sh
    git clone $REPO .
    echo "sudo meteor npm install" >> runmeteor.sh
    echo "sudo meteor run --port $PORT --production > /dev/null 2>&1" >> runmeteor.sh
    chmod +x runmeteor.sh
    sudo ./runmeteor.sh &
    sudo echo "start on runlevel [2345]" > /etc/init/$SITENAME.conf
    sudo echo "stop on runlevel [!2345]" >> /etc/init/$SITENAME.conf
    sudo echo "respawn" >> /etc/init/$SITENAME.conf
    sudo echo "console none" >> /etc/init/$SITENAME.conf
    sudo echo "exec sudo $FILE" >> /etc/init/$SITENAME.conf
    cd /etc/nginx/sites-enabled
    sudo echo "server {" > $SITENAME.conf
    sudo echo "listen 0.0.0.0:80;" >> $SITENAME.conf
    sudo echo "server_name $SITEURL www.$SITEURL;" >> $SITENAME.conf
    sudo echo "access_log off;" >> $SITENAME.conf
    sudo echo "location / {" >> $SITENAME.conf
    sudo echo "proxy_pass http://127.0.0.1:$PORT;" >> $SITENAME.conf
    sudo echo " }" >> $SITENAME.conf
    sudo echo "}" >> $SITENAME.conf
    sudo service $SITENAME start
    sudo service nginx restart
    sudo service $SITENAME restart # <- required
    echo "Created new daemon and setup port forwarding! -> $SITEURL"
    echo "---------------------------------------------------"
