#!/bin/bash

# Script usage:
# ./scripts/psql_docker.sh start|stop

set -e

DB_CONTAINER_NAME=jrvs-psql
DB_VOLUME=pgdata

case "$1" in
  start)
    if [ "$(docker ps -aq -f name=${DB_CONTAINER_NAME})" ]; then
      echo "Container already exists. Starting it..."
      docker start ${DB_CONTAINER_NAME}
    else
      echo "Creating and starting PostgreSQL container..."
      docker volume create ${DB_VOLUME}

      docker run --name ${DB_CONTAINER_NAME} \
        -e POSTGRES_USER=${POSTGRES_USER} \
        -e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
        -e POSTGRES_DB=${POSTGRES_DB} \
        -v ${DB_VOLUME}:/var/lib/postgresql/data \
        -p 5432:5432 \
        -d postgres:14
    fi
    ;;
  stop)
    echo "Stopping PostgreSQL container..."
    docker stop ${DB_CONTAINER_NAME}
    ;;
  *)
    echo "Usage: $0 start|stop"
    exit 1
    ;;
esac
