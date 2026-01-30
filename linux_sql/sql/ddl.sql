<<<<<<< HEAD
-- Create a host_info table
CREATE TABLE IF NOT EXISTS PUBLIC.host_info
(
  id SERIAL NOT NULL,
  hostname VARCHAR NOT NULL,
  cpu_number INT2 NOT NULL,
  cpu_architecture VARCHAR NOT NULL,
  cpu_model VARCHAR NOT NULL,
  cpu_mhz FLOAT8 NOT NULL,
  l2_cache INT4 NOT NULL,
  "timestamp" TIMESTAMP NULL,
  total_mem INT4 NULL,
  CONSTRAINT host_info_pk PRIMARY KEY (id),
  CONSTRAINT host_info_un UNIQUE (hostname)
);

-- Create a host_usage table
CREATE TABLE IF NOT EXISTS PUBLIC.host_usage
(
  "timestamp" TIMESTAMP NOT NULL,
  host_id SERIAL NOT NULL,
  memory_free INT4 NOT NULL,
  cpu_idle INT2 NOT NULL,
  cpu_kernel INT2 NOT NULL,
  disk_io INT4 NOT NULL,
  disk_available INT4 NOT NULL,
  CONSTRAINT host_usage_host_info_fk
    FOREIGN KEY (host_id) REFERENCES host_info(id)
=======
\c host_agent;

DROP TABLE IF EXISTS host_usage;
DROP TABLE IF EXISTS host_info;

CREATE TABLE host_info (
  id SERIAL PRIMARY KEY,
  hostname VARCHAR(255) UNIQUE NOT NULL,
  cpu_number INT NOT NULL,
  cpu_architecture VARCHAR(50) NOT NULL,
  cpu_model VARCHAR(255) NOT NULL,
  cpu_mhz FLOAT NOT NULL,
  l2_cache INT NOT NULL,
  total_mem INT NOT NULL,
  timestamp TIMESTAMP NOT NULL
);

CREATE TABLE host_usage (
  timestamp TIMESTAMP NOT NULL,
  host_id INT NOT NULL,
  memory_free INT NOT NULL,
  cpu_idle INT NOT NULL,
  cpu_kernel INT NOT NULL,
  disk_io INT NOT NULL,
  disk_available INT NOT NULL,
  CONSTRAINT fk_host_usage_host_info FOREIGN KEY (host_id) REFERENCES host_info(id)
>>>>>>> feature/psql_docker
);
