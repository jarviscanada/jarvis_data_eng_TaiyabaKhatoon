#!/bin/bash

# Assign CLI arguments
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5
export PGPASSWORD=$psql_password

# Validate argument count
if [ "$#" -ne 5 ]; then
  echo "Illegal number of parameters"
  exit 1
fi

# Capture host usage
hostname=$(hostname -f)
timestamp=$(date -u '+%F %T')
host_id=$(psql -h "$psql_host" -p "$psql_port" -U "$psql_user" -d "$db_name" -t -c "SELECT id FROM host_info WHERE hostname='$hostname';" | xargs)

# Collect system usage
vmstat_out=$(vmstat --unit M 1 2 | tail -1)
memory_free=$(echo "$vmstat_out" | awk '{print $4}')
cpu_idle=$(echo "$vmstat_out" | awk '{print $15}')
cpu_kernel=$(echo "$vmstat_out" | awk '{print $14}')
disk_io=$(echo "$vmstat_out" | awk '{print $10}')
disk_available=$(df -BM / | tail -1 | awk '{gsub(/M/,"",$4); print $4}')
insert_stmt="INSERT INTO host_usage(timestamp, host_id, memory_free, cpu_idle, cpu_kernel, disk_io, disk_available)
VALUES('$timestamp', $host_id, $memory_free, $cpu_idle, $cpu_kernel, $disk_io, $disk_available);"
export PGPASSWORD=$psql_password
psql -h "$psql_host" -p "$psql_port" -d "$db_name" -U "$psql_user" -c "$insert_stmt"
exit $?

