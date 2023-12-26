#!/bin/sh

cd /tmp
wget -O M357-docker-user-guide.zip https://codeload.github.com/Proscend/M357-docker-user-guide/zip/refs/heads/master
mkdir -p /tmp/M357-docker-user-guide
mkdir -p /data/M357-docker-user-guide
unzip M357-docker-user-guide.zip -d /tmp/M357-docker-user-guide
mv /tmp/M357-docker-user-guide/*/* /data/M357-docker-user-guide
rm -rf /tmp/M357-docker-user-guide
rm -f /tmp/M357-docker-user-guide.zip
