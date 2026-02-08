#! /bin/bash

docker run -d \
    --name totvs_dbaccess \
    -p 7890:7890 \
    -p 7891:7891 \
    juliansantosinfo/totvs_dbaccess:24.1.1.0