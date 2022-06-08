docker build  -f Dockerfile -t lux4rd0/mqtt_logger:latest -t lux4rd0/mqtt_logger:$1 -t docker01.tylephony.com:5000/lux4rd0/mqtt_logger:latest -t docker01.tylephony.com:5000/lux4rd0/mqtt_logger:$1 .
docker push docker01.tylephony.com:5000/lux4rd0/mqtt_logger:latest
docker push docker01.tylephony.com:5000/lux4rd0/mqtt_logger:$1
#docker push lux4rd0/lux4rd0/mqtt_logger:latest
#docker push lux4rd0/lux4rd0/mqtt_logger:$1
