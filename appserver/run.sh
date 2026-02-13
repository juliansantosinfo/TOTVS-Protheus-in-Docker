#! /bin/bash

docker run -d \
    --name totvs_appserver \
    -p 24001:1234 \
    -p 24002:12345 \
    -p 24088:8088 \
    juliansantosinfo/totvs_appserver:12.1.2410