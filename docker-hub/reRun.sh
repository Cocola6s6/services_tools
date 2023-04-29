#!/bin/bash
SERVICE_NAME=$1
docker stop $SERVICE_NAME
docker rm $SERVICE_NAME
sh run.sh
docker logs -f $SERVICE_NAME
