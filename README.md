# Docker-Nginx

FSP Network Gen2 Server Infrastructure - Nginx

[![MicroBadger Size](https://img.shields.io/microbadger/image-size/fspnetwork/nginx.svg?style=flat-square)](https://microbadger.com/#/images/fspnetwork/nginx)
[![Docker Automated build](https://img.shields.io/docker/automated/fspnetwork/nginx.svg?style=flat-square)](https://hub.docker.com/r/fspnetwork/nginx/)
[![Docker Build Status](https://img.shields.io/docker/build/fspnetwork/nginx.svg?style=flat-square)](https://hub.docker.com/r/fspnetwork/nginx/)
[![GitHub](https://img.shields.io/github/license/fspnet/nginx.svg?style=flat-square)](https://github.com/fspnetwork/nginx/blob/master/LICENSE)
![Nginx Version](https://img.shields.io/badge/Nginx-1.15.8-blue.svg?style=flat-square)

## Usage

```bash
docker run -d --restart=unless-stopped --name nginx -p 80:80 -p 443:443 \ 
-v /opt/www:/data/www:rw \
-v /opt/nginx/ssl:/etc/nginx/ssl:ro \
-v /opt/nginx/log:/var/log/nginx:rw fspnetwork/nginx
```

**Or**

```bash
docker-compose up -d
```

## UA Block

We have some User Agent block options, that you find in `/etc/nginx/ua/` 

- MSIE
- 360SE
- 360EE
- MetaSr
- MQQBrowser
- QQ
- TIM
- MicroMessenger
- WeiBo
- UCWEB
- etc
