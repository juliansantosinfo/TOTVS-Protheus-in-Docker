#! /bin/bash

docker run -d \
    --name totvs_mssql \
    --network bridge \
    -p 1433:1433 \
    -e "ACCEPT_EULA=Y" \
    -e "SA_PASSWORD=YourStrong!Passw0rd" \
    juliansantosinfo/totvs_mssql:release-2410.build-24.3.0.1.dbapi-24.1.0.0
