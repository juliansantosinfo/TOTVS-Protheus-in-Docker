#! /bin/bash

docker run -d \
    --name totvs_oracle \
    -p 1521:1521 \
    -e ORACLE_SID=ORCL \
    -e ORACLE_PWD=ProtheusDatabasePassword1 \
    juliansantosinfo/totvs_oracle
