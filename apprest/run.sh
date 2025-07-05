#! /bin/bash

docker run -d --name totvs_apprest -p 1235:1234 -p 12355:12345 -p 8089:8088 juliansantosinfo/totvs_apprest:latest