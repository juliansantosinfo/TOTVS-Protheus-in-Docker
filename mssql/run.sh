#! /bin/bash

docker run -d --name totvs_mssql --network bridge -p 1433:1433 juliansantosinfo/totvs_mssql:release-2510.build-24.3.1.1.dbapi-24.1.1.0
