#!/bin/bash

docker run --detach \
    --name nginx-proxy \
    --publish 80:80 \
    --publish 443:443 \
    --name nginx \
    --volume /etc/nginx/conf.d  \
    --volume /etc/nginx/vhost.d \
    --volume /usr/share/nginx/html \
    --volume /etc/nginx/certs \
    nginx


docker run --detach \
    --name nginx-proxy-gen \
    --volumes-from nginx-proxy \
    --volume /path/to/nginx.tmpl:/etc/docker-gen/templates/nginx.tmpl:ro \
    --volume /var/run/docker.sock:/tmp/docker.sock:ro \
    jwilder/docker-gen \
    -notify-sighup nginx-proxy -watch -wait 5s:30s /etc/docker-gen/templates/nginx.tmpl /etc/nginx/conf.d/default.conf


 docker run --detach \
    --name nginx-proxy-letsencrypt \
    --volumes-from nginx-proxy \
    --volume /var/run/docker.sock:/var/run/docker.sock:ro \
    --env "NGINX_DOCKER_GEN_CONTAINER=nginx-proxy-gen" \
    --env "DEFAULT_EMAIL=mail@yourdomain.tld" \
    jrcs/letsencrypt-nginx-proxy-companion
