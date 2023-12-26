# M357-Docker Quick Guide

## Quick Installation

```sh
wget -O- https://raw.githubusercontent.com/Proscend/M357-docker-user-guide/master/download.sh | sh
```

## Modbus TCP Simulator to MQTT

Please run the commands below to setup 4 docker containers for this example.

```sh
$ cd /data/M357-docker-user-guide/modbus-tcp-simulator-to-mqtt
$ ./run.sh
```

There are brief description for these 4 containers. 

1. modbus-server: Modbus TCP simulator
2. mqtt-broker: MQTT broker
3. modbus2mqtt: Modbus master which continuously poll slaves and published values via MQTT.
4. mqtt-sub: MQTT subscriber which subscribe all MQTT messages.

If all containers working fine, it will continuously show the Modbus data from `mqtt-sub` logs.

```
2023-12-26T01:12:00+0000 modbus/connected True
2023-12-26T01:12:00+0000 modbus/simulator/state/val1 52225
2023-12-26T01:12:00+0000 modbus/simulator/state/val2 52226
2023-12-26T01:12:00+0000 modbus/simulator/state/val3 52227
2023-12-26T01:12:00+0000 modbus/simulator/state/val4 52228
2023-12-26T01:12:00+0000 modbus/simulator/connected True
2023-12-26T01:12:05+0000 modbus/simulator/state/val1 52225
2023-12-26T01:12:05+0000 modbus/simulator/state/val2 52226
2023-12-26T01:12:05+0000 modbus/simulator/state/val3 52227
2023-12-26T01:12:05+0000 modbus/simulator/state/val4 52228
```

## Modbus RTU to MQTT

The system will run the `modbus_gateway` with the setting below by default.

* Baud rate: `9600`
* Data bits: `8`
* Stop bits: `1`
* Parity bits: `n`
* TCP port: `502`

The `modbus_gateway` is responsible for the conversion between Modbus TCP and Modbus RTU.
You can change the setting of `modbus_gateway` to meet your Modbus RTU slave device.

If the Modbus slave has been connected to the RS-485 of M357, please run the commands below 
to update the data mapping (`modbus2mqtt.csv`) for your Modbus RTU slave devices.

```sh
$ cd /data/M357-docker-user-guide/modbus-rtu-to-mqtt
# Edit/Overwirte the modbus2mqtt.csv
```

The folloing table shown the setting for two Modbus RTU slave devices.

| Sensor    | H&T              | PM2.5            |
|-----------|------------------|------------------|
| Baud Rate | 9600             | 9600             |
| Modbus ID | 1                | 2                |
| Modbus OP | 3                | 3                |
| Data Type | Holding Register | Holding Register |
| Address   | 0                | 0                |
| Quantity  | 2                | 1                |
| Regs#1    | Tempeature       | PM2.5            |
| Regs#2    | Humidity         | N/A              |

Then, you should update the `modbus2mqtt.csv` for two Modbus RTU slave devices as following.

```
"type","topic","col2","col3","col4","col5","col6"
# Humidity and Temperature sensor with ID 1
poll,HT,1,0,2,holding_register,5
ref,temperature,0,ro
ref,humidity,1,ro

# PM2.5 sensor with ID 2
poll,PM2.5,2,0,1,holding_register,5
ref,PM2.5,0,ro
```

You can run the `./run.sh` to start poll the Modbus data when the `modbus2mqtt.csv` has been updated properly.
If everything working fine, it will continuously show the Modbus data from `mqtt-sub` logs.

```
2023-12-26T01:56:20+0000 modbus/PM2.5/state/PM2.5 2
2023-12-26T01:56:20+0000 modbus/PM2.5/connected True
2023-12-26T01:56:20+0000 modbus/HT/state/temperature 2184
2023-12-26T01:56:20+0000 modbus/HT/state/humidity 4744
2023-12-26T01:56:20+0000 modbus/HT/connected True
2023-12-26T01:56:22+0000 modbus/PM2.5/state/PM2.5 2
```
