#! /bin/bash

docker run -d \
    --name totvs_appserver \
    -p 25001:1234 \
    -p 25002:12345 \
    -p 25088:8088 \
    juliansantosinfo/totvs_appserver:12.1.2510