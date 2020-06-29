docker run --name {{PROJECT_NAME}} \
  -d --net docker-net --ip {{PROJECT_IP}} -dit --dns 172.18.0.1 \
  -p 3306:3306 -dit --restart unless-stopped --privileged mariadb:1.0
