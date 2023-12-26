#!/bin/sh

TOP=$(pwd)

build_modbus2mqtt() {
  docker images | grep -q modbus2mqtt
  if [ $? -eq 0 ]; then
    return 0
  fi

  rm -f /tmp/modbus2mqtt.zip
  wget -O /tmp/modbus2mqtt.zip https://codeload.github.com/Proscend/spicierModbus2mqtt/zip/refs/heads/master
  if [ $? -ne 0 ]; then
    echo "Download the modbus2mqtt source failure."
    return 1
  fi

  rm -rf /tmp/modbus2mqtt
  mkdir -p /tmp/modbus2mqtt
  unzip /tmp/modbus2mqtt.zip -d /tmp/modbus2mqtt
  mv /tmp/modbus2mqtt/*/* /tmp/modbus2mqtt/

  cd /tmp/modbus2mqtt
  docker build -t modbus2mqtt -f Dockerfile.arm64v8 .
  if [ $? -ne 0 ]; then
    echo "Build the modbus2mqtt docker image failure."
    return 1
  fi

  return  0
}

build_modbus2mqtt || exit 1
