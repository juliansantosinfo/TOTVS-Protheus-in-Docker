#! /bin/bash

docker run -d \
    --name totvs_oracle \
    -p 1521:1521 \
    -e "ORACLE_PASSWORD=ProtheusDatabasePassword1" \
    juliansantosinfo/totvs_oracle:12.1.2510
