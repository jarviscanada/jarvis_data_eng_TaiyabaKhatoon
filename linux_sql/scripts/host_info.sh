#!/bin/bash

psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5
# Validate argument count
if [ "$#" -ne 5 ]; then
  echo "Illegal number of parameters"
  exit 1
fi
lscpu_out=$(lscpu)

hostname=$(hostname -f)

cpu_number=$(echo "$lscpu_out" | awk -F: '/^CPU\(s\):/{gsub(/^[ \t]+/,"",$2); print $2}' | xargs)
cpu_architecture=$(echo "$lscpu_out" | awk -F: '/^Architecture:/{gsub(/^[ \t]+/,"",$2); print $2}' | xargs)
cpu_model=$(echo "$lscpu_out" | awk -F: '/^Model name:/{gsub(/^[ \t]+/,"",$2); print $2}' | xargs)
cpu_mhz=$(echo "$lscpu_out" | awk -F: '/^CPU MHz:/{gsub(/^[ \t]+/,"",$2); print $2}' | xargs)

# Fallback: some VMs don't show "CPU MHz" in lscpu, so parse from model name (e.g., "@ 2.80GHz" -> 2800)
if [ -z "$cpu_mhz" ]; then
  cpu_mhz=$(echo "$cpu_model" | awk -F'@' '{print $2}' | tr -d ' ' | awk '
    /GHz/ {sub(/GHz/,""); printf "%.0f", $0*1000; exit}
    /MHz/ {sub(/MHz/,""); printf "%.0f", $0; exit}
    {print ""; exit}
  ')
fi




l2_cache=$(echo "$lscpu_out" | awk -F: '/^L2 cache:/{gsub(/^[ \t]+/,"",$2); print $2}' | awk '{v=$1; u=$2; if(u~/MiB|MB/) printf "%.0f", v*1024; else if(u~/KiB|KB/) printf "%.0f", v; else if(u~/GiB|GB/) printf "%.0f", v*1024*1024; }' | xargs)

total_mem=$(awk '/MemTotal/ {printf "%.0f", $2/1024}' /proc/meminfo | xargs)
timestamp=$(date -u '+%F %T')
insert_stmt="INSERT INTO host_info(hostname,cpu_number,cpu_architecture,cpu_model,cpu_mhz,l2_cache,total_mem,timestamp) VALUES('$hostname',$cpu_number,'$cpu_architecture','$cpu_model',$cpu_mhz,$l2_cache,$total_mem,'$timestamp') ON CONFLICT (hostname) DO UPDATE SET cpu_number=EXCLUDED.cpu_number,cpu_architecture=EXCLUDED.cpu_architecture,cpu_model=EXCLUDED.cpu_model,cpu_mhz=EXCLUDED.cpu_mhz,l2_cache=EXCLUDED.l2_cache,total_mem=EXCLUDED.total_mem,timestamp=EXCLUDED.timestamp;"
export PGPASSWORD=$psql_password
psql -h "$psql_host" -p "$psql_port" -d "$db_name" -U "$psql_user" -c "$insert_stmt"
exit $?

