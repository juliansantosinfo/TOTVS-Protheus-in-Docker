#! /bin/bash

docker run -d \
    --name totvs_appserver \
    -p 23001:23001 \
    -p 23002:23002 \
    -p 23088:8088 \
    juliansantosinfo/totvs_appserver:12.1.2310
