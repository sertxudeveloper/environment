docker run --name {{PROJECT_NAME}} \
  -d --net docker-net --ip {{PROJECT_IP}} -dit --dns 10.0.0.30 \
  -p 3306:3306 -dit --restart unless-stopped --privileged mariadb:1.0
