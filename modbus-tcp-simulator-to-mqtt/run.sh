#!/bin/sh

TOP=$(pwd)

is_docker_running() {
  name="$1"

  docker ps | awk '{ print $NF }' | grep -q "$name"
  if [ $? -eq 0 ]; then
    return 0
  fi

  return 1
}

run_modbus_server() {
  is_docker_running "modbus-server"
  if [ $? -eq 0 ]; then
    return 0
  fi

  docker rm -f modbus-server >/dev/null 2>&1

  docker run -d -p 5020:5020 \
    -v $TOP/modbus-server.json:/server_config.json \
    --rm --name modbus-server \
    modbus-server -f /server_config.json

  return $?
}

run_modbus2mqtt() {
  is_docker_running "modbus2mqtt"
  if [ $? -eq 0 ]; then
    return 0
  fi

  docker rm -f modbus2mqtt >/dev/null 2>&1

  docker run -d \
    -v $TOP/modbus2mqtt.csv:/app/conf/modbus2mqtt.csv \
    --rm --name modbus2mqtt \
    --add-host="host.docker.internal:host-gateway" \
    modbus2mqtt --tcp host.docker.internal --tcp-port 5020 --mqtt-host host.docker.internal --always-publish

  return $?
}

run_mqtt_broker() {
  is_docker_running "mqtt-broker"
  if [ $? -eq 0 ]; then
    return 0
  fi

  docker rm -f mqtt-broker >/dev/null 2>&1

  docker run -d \
    -v $TOP/mosquitto.conf:/mosquitto/config/mosquitto.conf \
    --rm --name mqtt-broker \
    -p 1883:1883 \
    arm64v8/eclipse-mosquitto 

  return $?
}

run_mqtt_sub() {
  is_docker_running "mqtt-sub"
  if [ $? -eq 0 ]; then
    return 0
  fi

  docker rm -f mqtt-sub >/dev/null 2>&1

  docker run -d \
    --rm --name mqtt-sub \
    --add-host="host.docker.internal:host-gateway" \
    arm64v8/eclipse-mosquitto mosquitto_sub -v -t '#' -F  "%I %t %p" -h host.docker.internal

  return $?
}

./setup.sh || exit 1
run_modbus_server || exit 1
run_mqtt_broker || exit 1
run_modbus2mqtt || exit 1
run_mqtt_sub || exit 1

docker logs -f mqtt-sub
