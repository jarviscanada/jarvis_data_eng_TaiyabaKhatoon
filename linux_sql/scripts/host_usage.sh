#!/bin/bash

# Collect host usage info and insert into host_usage table

psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

if [ "$#" -ne 5 ]; then
  echo "Illegal number of parameters"
  echo "Usage: $0 psql_host psql_port db_name psql_user psql_password"
  exit 1
fi

timestamp=$(date -u "+%Y-%m-%d %H:%M:%S")
hostname=$(hostname -f)

# get host_id from host_info table
host_id=$(PGPASSWORD=$psql_password psql -h $psql_host -p $psql_port -U $psql_user -d $db_name -t -c "SELECT id FROM host_info WHERE hostname='$hostname';" | xargs)

# collect usage metrics
vmstat_out=$(vmstat --unit M 1 2 | tail -1)

memory_free=$(echo "$vmstat_out" | awk '{print $4}')
cpu_idle=$(echo "$vmstat_out" | awk '{print $15}')
cpu_kernel=$(echo "$vmstat_out" | awk '{print $14}')

disk_io=$(vmstat -d | tail -1 | awk '{print $10}')
disk_available=$(df -BM / | tail -1 | awk '{print $4}' | sed 's/M//')

insert_stmt="
INSERT INTO host_usage
(timestamp, host_id, memory_free, cpu_idle, cpu_kernel, disk_io, disk_available)
VALUES
('$timestamp', $host_id, $memory_free, $cpu_idle, $cpu_kernel, $disk_io, $disk_available);
"

PGPASSWORD=$psql_password psql -h $psql_host -p $psql_port -U $psql_user -d $db_name -c "$insert_stmt"
