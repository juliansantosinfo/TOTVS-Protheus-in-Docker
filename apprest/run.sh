#! /bin/bash

docker run -d --name totvs_apprest -p 1235:1234 -p 12355:12345 -p 8089:8088 juliansantosinfo/totvs_rest:release-2510.build-24.3.1.1.dbapi-24.1.1.0