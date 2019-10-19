# Nginx

FSP Network Gen2 Server Infrastructure - Nginx

[![MicroBadger Size](https://img.shields.io/microbadger/image-size/fspnetwork/nginx.svg?style=flat-square)](https://microbadger.com/#/images/fspnetwork/nginx)
[![LICENSE](https://img.shields.io/badge/license-Anti%20996-blue.svg?style=flat-square)](https://github.com/996icu/996.ICU/blob/master/LICENSE)
[![996.icu](https://img.shields.io/badge/link-996.icu-red.svg?style=flat-square)](https://996.icu)
![Nginx Version](https://img.shields.io/badge/Nginx-1.17.4-blue.svg?style=flat-square)

## Usage

```bash
docker run -d --restart=unless-stopped --name nginx -p 80:80 -p 443:443 \ 
-v /opt/www:/data/www:rw \
-v /opt/nginx/ssl:/etc/nginx/ssl:ro \
-v /opt/nginx/log:/var/log/nginx:rw fspnetwork/nginx
```

## more

- [ngx_brotli](https://github.com/eustas/ngx_brotli)
- [zlib by cloudflare](https://github.com/cloudflare/zlib)
- [headers-more-nginx-module](https://github.com/openresty/headers-more-nginx-module)