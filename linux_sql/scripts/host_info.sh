#!/bin/bash

# Collect host hardware info and insert into host_info table

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

hostname=$(hostname -f)

lscpu_out=$(lscpu)
cpu_number=$(echo "$lscpu_out" | egrep "^CPU\(s\):" | awk '{print $2}')
cpu_architecture=$(echo "$lscpu_out" | egrep "^Architecture:" | awk '{print $2}')
cpu_model=$(echo "$lscpu_out" | egrep "^Model name:" | cut -d ':' -f2 | xargs)

cpu_mhz=$(echo "$lscpu_out" | egrep "^CPU MHz:" | awk '{print $3}')
if [ -z "$cpu_mhz" ]; then
  cpu_mhz=$(grep -m1 "cpu MHz" /proc/cpuinfo | awk '{print $4}')
fi

l2_cache=$(echo "$lscpu_out" | egrep "^L2 cache:" | awk '{print $3}')
total_mem=$(vmstat --unit M | tail -1 | awk '{print $4}')
timestamp=$(date -u "+%Y-%m-%d %H:%M:%S")

insert_stmt="
INSERT INTO host_info
(hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, total_mem, timestamp)
VALUES
('$hostname', $cpu_number, '$cpu_architecture', '$cpu_model', $cpu_mhz, $l2_cache, $total_mem, '$timestamp')
ON CONFLICT (hostname) DO NOTHING;
"

PGPASSWORD=$psql_password psql -h $psql_host -p $psql_port -U $psql_user -d $db_name -c "$insert_stmt"
