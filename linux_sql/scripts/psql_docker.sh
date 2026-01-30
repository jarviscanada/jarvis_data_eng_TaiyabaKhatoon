#!/bin/bash

# Manage PostgreSQL docker container for Jarvis Linux SQL project
# Usage: ./psql_docker.sh start|stop db_username db_password

cmd=$1
db_username=$2
db_password=$3

if [ $# -ne 3 ]; then
  echo "Illegal number of parameters"
  echo "Usage: $0 start|stop db_username db_password"
  exit 1
fi

# Start docker if not running
systemctl is-active --quiet docker
if [ $? -ne 0 ]; then
  systemctl start docker
fi

if [ "$cmd" = "start" ]; then
  docker volume inspect pgdata >/dev/null 2>&1 || docker volume create pgdata >/dev/null

  docker container inspect jrvs-psql >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    docker run --name jrvs-psql \
      -e POSTGRES_USER=$db_username \
      -e POSTGRES_PASSWORD=$db_password \
      -v pgdata:/var/lib/postgresql/data \
      -p 5432:5432 \
      -d postgres:14
  else
    docker start jrvs-psql >/dev/null
  fi

elif [ "$cmd" = "stop" ]; then
  docker stop jrvs-psql >/dev/null
else
  echo "Illegal command"
  echo "Commands: start|stop"
  exit 1
fi
