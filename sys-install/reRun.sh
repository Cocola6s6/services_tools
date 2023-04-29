#!/bin/bash
SERVICE_NAME=$1
docker stop $SERVICE_NAME
docker rm $SERVICE_NAME
docker-compose up -d $SERVICE_NAME
docker logs -f $SERVICE_NAME
