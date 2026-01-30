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
);
