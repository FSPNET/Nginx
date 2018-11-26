# Docker-Nginx

FSP Network Gen2 Server Infrastructure - Nginx

![Docker Automated build](https://img.shields.io/docker/automated/fspnetwork/nginx.svg?style=flat-square)
![Docker Build Status](https://img.shields.io/docker/build/fspnetwork/nginx.svg?style=flat-square)
![GitHub](https://img.shields.io/github/license/fspnet/docker-nginx.svg?style=flat-square)


```bash
docker run -d --restart=unless-stopped --name nginx -p 80:80 -p 443:443 \ 
-v /opt/www:/data/www:rw \
-v /opt/nginx/ssl:/etc/nginx/ssl:ro \
-v /opt/nginx/log:/var/log/nginx:rw fspnetwork/nginx
```