# Entry point: layer the file-read misconfiguration on the required PostgreSQL
# service (expose it remotely, create a login role with pg_read_server_files,
# plant a readable flag file).
include postgres_readfile::config
