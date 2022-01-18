#!/bin/bash

docker run --name database \
  --net docker-net --ip 172.18.1.1 \
  --restart unless-stopped -dit --privileged \
  -e MARIADB_ROOT_PASSWORD=root \
  mariadb:latest --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
  
