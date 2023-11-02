#!/bin/sh
if [ $1 == "nginx" ]; then
        # Site config
        cat >/etc/nginx/http.d/default.conf <<EOL
server {
    listen               80;
    server_name          _;
    client_max_body_size 40M;

    location / {
        proxy_pass http://localhost:3000;

        proxy_connect_timeout 600;
        proxy_send_timeout 600;
        proxy_read_timeout 600;
        send_timeout 600;

        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOL

# Nginx conf
        cat >/etc/nginx/nginx.conf <<EOL
user root;
worker_processes  1;
daemon off;

error_log  /dev/stderr;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}


http {
        include       /etc/nginx/mime.types;
        default_type  application/octet-stream;

        sendfile        on;
        #tcp_nopush     on;

        keepalive_timeout  65;

        gzip on;
        gzip_http_version  1.1;
        gzip_comp_level    5;
        gzip_min_length    256;
        gzip_proxied       any;
        gzip_vary          on;
        gzip_types
        application/atom+xml
        text/js
        text/xml
        text/javascript
        application/javascript
        application/x-javascript
        application/json
        application/rss+xml
        application/vnd.ms-fontobject
        application/x-font-ttf
        application/x-web-app-manifest+json
        application/xhtml+xml
        application/xml
        font/opentype
        image/svg+xml
        image/x-icon
        text/css
        text/plain
        text/x-component;

       log_format main '\$realip_remote_addr - \$remote_user [\$time_local] '
'"\$request" \$status \$body_bytes_sent \$request_time \$upstream_header_time "\$http_referer" '
'"\$http_user_agent" "\$http_cookie"' ;

        access_log /dev/stdout main;
        error_log /dev/sterr;

        include /etc/nginx/http.d/*.conf;
}
EOL
nginx

elif [ $1 == "run_next" ]; then
#      RUN yarn remove-map-files
#      pm2 start ecosystem.config.js
      yarn start

elif [ $1 == "bash" ]; then
        bash
fi
