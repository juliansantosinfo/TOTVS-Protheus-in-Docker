#! /bin/bash

docker run -d --name totvs_appserver --network bridge -p 1234:1234 -p 12345:12345 -p 8088:8088 juliansantosinfo/totvs_appserver:release-2510.build-24.3.1.1.dbapi-24.1.1.0