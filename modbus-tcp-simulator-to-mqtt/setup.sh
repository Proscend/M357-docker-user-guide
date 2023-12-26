#!/bin/sh

TOP=$(pwd)

build_modbus4mqtt() {
  docker images | grep -q modbus4mqtt
  if [ $? -eq 0 ]; then
    return 0
  fi

  rm -f /tmp/modbus4mqtt.zip
  wget -O /tmp/modbus4mqtt.zip https://codeload.github.com/Proscend/modbus4mqtt/zip/refs/heads/master
  if [ $? -ne 0 ]; then
    echo "Download the modbus4mqtt source failure."
    return 1
  fi

  rm -rf /tmp/modbus4mqtt
  mkdir -p /tmp/modbus4mqtt
  unzip /tmp/modbus4mqtt.zip -d /tmp/modbus4mqtt
  mv /tmp/modbus4mqtt/*/* /tmp/modbus4mqtt/

  cd /tmp/modbus4mqtt
  docker build -t modbus4mqtt -f Dockerfile.arm64v6 .
  if [ $? -ne 0 ]; then
    echo "Build the modbus4mqtt docker image failure."
    return 1
  fi

  return  0
}

build_modbus_server() {
  docker images | grep -q modbus-server
  if [ $? -eq 0 ]; then
    return 0
  fi

  rm -f /tmp/modbus-server.zip
  wget -O /tmp/modbus-server.zip https://codeload.github.com/Proscend/modbus-server/zip/refs/heads/master
  if [ $? -ne 0 ]; then
    echo "Download the modbus-server source failure."
    return 1
  fi

  rm -rf /tmp/modbus-server
  mkdir -p /tmp/modbus-server
  unzip /tmp/modbus-server.zip -d /tmp/modbus-server
  mv /tmp/modbus-server/*/* /tmp/modbus-server/

  cd /tmp/modbus-server
  docker build -t modbus-server -f Dockerfile.arm64v6 .
  if [ $? -ne 0 ]; then
    echo "Build the modbus-server docker image failure."
    return 1
  fi

  return  0
}

build_modbus_server || exit 1
build_modbus4mqtt || exit 1