#! /bin/bash

docker run -d \
    --name totvs_mssql \
    -p 1433:1433 \
    -e "ACCEPT_EULA=Y" \
    -e "SA_PASSWORD=ProtheusDatabasePassword1" \
    juliansantosinfo/totvs_mssql:12.1.2310
