#!/bin/bash
# entrypoint.sh

# Inicializa banco de dados se não existir
mkdir -p /var/opt/mssql/data
if [ ! "$(ls -A /var/opt/mssql/data/)" ]; then
    tar -xzvf /tmp/data.tar.gz -C /var/opt/mssql
    rm -rfv /tmp/data.tar.gz
    chown -R root:root /var/opt/mssql
    chmod -R 770 /var/opt/mssql
fi

# Inicia o SQL Server
/opt/mssql/bin/sqlservr
