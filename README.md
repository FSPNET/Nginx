# Docker-Nginx

FSP Network Gen2 Server Infrastructure - Nginx

![Docker Automated build](https://img.shields.io/docker/automated/fspnetwork/nginx.svg?style=flat-square)
![Docker Build Status](https://img.shields.io/docker/build/fspnetwork/nginx.svg?style=flat-square)
![GitHub](https://img.shields.io/github/license/fspnet/docker-nginx.svg?style=flat-square)


```bash
docker run -d --restart always --name nginx -p 80:80 -p 443:443 --mount type=bind,source=/data,target=/data  fspnetwork/nginx
```