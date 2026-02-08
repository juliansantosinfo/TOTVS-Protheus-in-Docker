#!/bin/bash

docker run -d --rm \
  --name totvs_smartview \
  --network totvs \
  -p 7017:7017 \
  -p 7019:7019 \
  juliansantosinfo/totvs_smartview:3.9.0.4558336
