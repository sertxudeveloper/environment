docker run -v /home/vagrant/docker/{{PROJECT_NAME}}/src:/var/www/html \
--name {{PROJECT_NAME}} \
-d --net docker-net --ip {{PROJECT_IP}} -dit --dns 10.0.0.30 \
--restart unless-stopped --privileged website:1.0

docker cp /home/vagrant/docker/{{PROJECT_NAME}}/apache_local.pem {{PROJECT_NAME}}:/etc/ssl/certs/apache_local.pem
docker cp /home/vagrant/docker/{{PROJECT_NAME}}/apache_local.key {{PROJECT_NAME}}:/etc/ssl/private/apache_local.key

docker cp /home/vagrant/docker/rootCA.pem {{PROJECT_NAME}}:/usr/local/share/ca-certificates/rootCA.crt
docker exec {{PROJECT_NAME}} rm -f /usr/local/share/ca-certificates/certificate.crt
docker exec {{PROJECT_NAME}} update-ca-certificates --fresh
