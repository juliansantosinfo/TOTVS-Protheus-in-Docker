#! /bin/bash

docker run -d \
    --name totvs_postgres \
    -p 5432:5432 \
    -e "POSTGRES_USER=postgres" \
    -e "POSTGRES_PASSWORD=postgres" \
    juliansantosinfo/totvs_postgres:12.1.2510
