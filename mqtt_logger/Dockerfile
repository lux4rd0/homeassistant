FROM grafana/promtail:2.5.0

RUN apt-get update && apt-get install -y dumb-init mosquitto-clients vim

RUN mkdir /mqtt_logger

COPY config.yaml /mqtt_logger
COPY start.sh /mqtt_logger

WORKDIR /mqtt_logger

RUN chmod a+x *.sh

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["/mqtt_logger/start.sh"]
