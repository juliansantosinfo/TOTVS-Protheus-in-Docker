#! /bin/bash

docker run -d --name totvs_appserver --network totvs -p 1235:1235 -p 12355:12355 -p 8080:8080 -p 8089:8089 --ulimit nofile=65536:65536 juliansantosinfo/totvs_apprest:release-2410.build-24.3.0.1.dbapi-24.1.0.0