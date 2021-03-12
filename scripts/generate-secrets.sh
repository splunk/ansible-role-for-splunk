#!/bin/bash


docker_id=$(docker run --rm -d -e "SPLUNK_START_ARGS=--accept-license" -e "SPLUNK_PASSWORD=doesntmatter" splunk/universalforwarder)

while [ ! $(docker inspect --format '{{json .State.Health.Status}}' $docker_id) = "\"healthy\"" ]
do
  sleep 2
done

docker exec $docker_id sudo cat /opt/splunkforwarder/etc/auth/splunk.secret
docker container stop $docker_id
