#! /bin/bash

docker run -d \
    --name totvs_licenseserver \
    -p 5555:5555 \
    -p 2234:2234 \
    -p 8020:8020 \
    juliansantosinfo/totvs_licenseserver:3.6.2
