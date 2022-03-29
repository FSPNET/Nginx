FROM amelia/dhparam:latest as dhparam
FROM alpine:3.15.3 as builder

ARG NGINX_VERSION=1.19.0
ARG OPENSSL_VERSION=1.1.1i

RUN set -ex \
    && apk upgrade \
    && apk add --no-cache \
        gcc \
        libc-dev \
        make \
        openssl-dev \
        pcre-dev \
        zlib-dev \
        linux-headers \
        curl \
        gnupg \
        libxslt-dev \
        gd-dev \
        geoip-dev \
        git \
        gettext \
        patch \
    && curl -fSL https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz \
    && curl -fSL https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz.asc -o nginx.tar.gz.asc \
    && export GNUPGHOME="$(mktemp -d)"; \
        for key in \
            B0F4253373F8F6F510D42178520A9993A1C052F8 \
        ; do \
            gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
        done \
    && gpg --batch --verify nginx.tar.gz.asc nginx.tar.gz \
    && mkdir -p /usr/src \
    && tar -zxC /usr/src -f nginx.tar.gz \
    && rm nginx.tar.gz

WORKDIR /usr/src/nginx-$NGINX_VERSION

RUN curl https://raw.githubusercontent.com/kn007/patch/master/nginx.patch | patch -p1 && \
    curl https://raw.githubusercontent.com/hakasenyang/openssl-patch/master/nginx_strict-sni_1.15.10.patch | patch -p1

# brotli
RUN git clone https://github.com/google/ngx_brotli.git --depth=1 && \
    (cd ngx_brotli; git submodule update --init)

# cf-zlib
RUN git clone https://github.com/cloudflare/zlib.git --depth 1 && \
    (cd zlib; make -f Makefile.in distclean)

# OpenSSL
RUN curl -fSL https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz -o openssl-${OPENSSL_VERSION}.tar.gz && \
    tar -xzf openssl-${OPENSSL_VERSION}.tar.gz

# Sticky
RUN mkdir nginx-sticky-module-ng && \
    curl -fSL https://bitbucket.org/nginx-goodies/nginx-sticky-module-ng/get/master.tar.gz -o nginx-sticky-module-ng.tar.gz && \
    tar -zxC nginx-sticky-module-ng -f nginx-sticky-module-ng.tar.gz --strip 1

# nginx certificate transparency
RUN git clone https://github.com/grahamedgecombe/nginx-ct.git --depth 1

# headers-more-nginx
RUN git clone https://github.com/openresty/headers-more-nginx-module.git --depth 1

RUN set -ex && \
    cd /usr/src/nginx-$NGINX_VERSION \
    && ./configure \
        --prefix=/etc/nginx \
        --sbin-path=/usr/sbin/nginx \
        --modules-path=/usr/lib/nginx/modules \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --pid-path=/var/run/nginx.pid \
        --lock-path=/var/run/nginx.lock \
        --http-client-body-temp-path=/var/cache/nginx/client_temp \
        --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
        --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
        --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
        --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
        --user=nginx \
        --group=nginx \
        --with-http_ssl_module \
        --with-http_realip_module \
        --with-http_addition_module \
        --with-http_sub_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_mp4_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_random_index_module \
        --with-http_secure_link_module \
        --with-http_stub_status_module \
        --with-http_auth_request_module \
        --with-http_xslt_module \
        --with-http_image_filter_module \
        --with-http_geoip_module \
        --with-threads \
        --with-stream \
        --with-stream_ssl_module \
        --with-stream_ssl_preread_module \
        --with-stream_realip_module \
        --with-stream_geoip_module \
        --with-http_slice_module \
        --with-mail \
        --with-mail_ssl_module \
        --with-compat \
        --with-file-aio \
        --with-http_v2_module \
        --with-http_v2_hpack_enc \
        --with-zlib=/usr/src/nginx-${NGINX_VERSION}/zlib \
        --add-module=/usr/src/nginx-${NGINX_VERSION}/ngx_brotli \
        --add-module=/usr/src/nginx-${NGINX_VERSION}/nginx-sticky-module-ng \
        --add-module=/usr/src/nginx-$NGINX_VERSION/nginx-ct \
        --add-module=/usr/src/nginx-${NGINX_VERSION}/headers-more-nginx-module \
        --with-openssl=/usr/src/nginx-${NGINX_VERSION}/openssl-${OPENSSL_VERSION} \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    && rm -rf /etc/nginx/html/ \
    && mkdir /etc/nginx/conf.d/ \
    && mkdir -p /usr/share/nginx/html/ \
    && install -m644 html/index.html /usr/share/nginx/html/ \
    && install -m644 html/50x.html /usr/share/nginx/html/ \
    && ln -s ../../usr/lib/nginx/modules /etc/nginx/modules \
    && strip /usr/sbin/nginx* \
    && nginx -V

COPY --from=dhparam /dhparam.pem /etc/nginx/ssl/dhparam.pem
COPY conf/ /etc/nginx/
COPY ua/* /etc/nginx/ua/


FROM alpine:3.15.3

ENV TZ=UTC

COPY --from=builder /etc/nginx /etc/nginx
COPY --from=builder /usr/sbin/nginx /usr/sbin/nginx
COPY --from=builder /usr/bin/envsubst /usr/local/bin/envsubst
COPY --from=builder /usr/share/nginx /usr/share/nginx
COPY docker-entrypoint.sh /usr/local/bin/

RUN set -ex \
    && runDeps="$( \
    scanelf --needed --nobanner --format '%n#p' --recursive /usr/ \
        | tr ',' '\n' \
        | sort -u \
        | awk 'system("[ -e /usr/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )" \
    && apk --no-cache add $runDeps \
        tzdata \
        logrotate \
    && sed -i -e 's:/var/log/messages {}:# /var/log/messages {}:' /etc/logrotate.conf \
    && echo '1 0 * * * /usr/sbin/logrotate /etc/logrotate.conf -f' > /var/spool/cron/crontabs/root \
    && addgroup -S nginx \
    && adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
    && mkdir -p /var/log/nginx \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && mv /etc/nginx/logrotate /etc/logrotate.d/nginx \
    && mv /etc/nginx/domain.logrotate /etc/logrotate.d/domain \
    && chmod 755 /etc/logrotate.d/nginx \
    && chmod 755 /etc/logrotate.d/domain \
    && chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 80 443
STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
