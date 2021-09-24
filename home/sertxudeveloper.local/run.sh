#!/bin/bash

docker run --name sertxudeveloper \
  -v $(pwd)/data:/var/www/html \
  --net docker-net --ip 172.18.1.2 --dns 10.0.0.30 \
  --restart unless-stopped -dit --privileged \
  laravel:1.0
  
