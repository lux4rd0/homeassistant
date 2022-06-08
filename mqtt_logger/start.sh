mosquitto_sub -h $MQTT_LOGGER_MQTT_HOSTNAME -p $MQTT_LOGGER_MQTT_PORT -u $MQTT_LOGGER_MQTT_USERNAME -P $MQTT_LOGGER_MQTT_PASSWORD -F %j -t '+/debug' -t 'homeassistant/#' | promtail --stdin --config.expand-env=true --config.file=/mqtt_logger/config.yaml

