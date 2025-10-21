#! /bin/bash

docker run -d \
    --name totvs_appserver \
    -p 23001:1234 \
    -p 23002:12345 \
    -p 23088:8088 \
    juliansantosinfo/totvs_appserver:12.1.2310