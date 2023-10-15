#!/bin/bash
if [ $1 == "uwsgi" ]; then
        shift
        cd /var/www && python3 manage.py migrate && python3 manage.py migrate --database=jobalert \
         && python3 manage.py invalidate_cachalot
        uwsgi --uid www-data --gid www-data --plugins=python3 --chdir=/var/www --socket=0.0.0.0:9000 --stats=0.0.0.0:1717 $@
elif [ $1 == "daphne" ]; then
        shift
        daphne $@
elif [ $1 == "celery" ]; then
	shift
	/usr/local/bin/celery worker -B -A $@
elif [ $1 == "flower" ]; then
        shift
	flower $@
elif [ $1 == "nginx" ]; then
	cd /var/www && echo "yes" | python3 manage.py collectstatic
	#chown -R www-data. /var/www

	cat >/etc/nginx/sites-available/default <<EOL
server {
       listen 80;

       root /var/www;
       client_max_body_size 50M;
       location / {
               include         uwsgi_params;
               proxy_pass      http://$_CGI:9000;
       }

       location /web-socket {
               proxy_pass      http://$_ASGI:8000;

               proxy_http_version 1.1;
               proxy_set_header Upgrade \$http_upgrade;
               proxy_set_header Connection "upgrade";

               proxy_redirect off;
               proxy_set_header Host \$host;
               proxy_set_header X-Real-IP \$remote_addr;
               proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
               proxy_set_header X-Forwarded-Host \$server_name;
       }

       location /static {
               alias /var/www/static;
       }

       location /cdn {
               alias /var/www/uploads;
       }

}
server {
       listen 8080;

       root /var/www/uploads;
       client_max_body_size 50M;

       location ~ ".*\/[\d]{1,3}X[\d]{1,3}$" {
           add_header Access-Control-Allow-Origin "*";
           rewrite ^(.*) /api/v1/common/image\$1 break;
           include         uwsgi_params;
           proxy_pass     http://$_CGI:9000;
       }

       location / {
           add_header Access-Control-Allow-Origin "*";
	         alias /var/www/uploads/;
       }

       location /static {
          add_header Access-Control-Allow-Origin "*";
          alias /var/www/static;
       }

      location /uploads/ {
          internal;
          root  /var/www/;
       }

}
EOL
	# Nginx conf
        cat >/etc/nginx/nginx.conf <<EOL
user www-data;
worker_processes auto;
pid /run/nginx.pid;
daemon off;

events {
    worker_connections  1024;
}


http {
        sendfile on;
        tcp_nopush on;
        tcp_nodelay on;
        keepalive_timeout 65;
        types_hash_max_size 2048;
        include       /etc/nginx/mime.types;
        default_type  application/octet-stream;

        #tcp_nopush     on;

        ssl_protocols TLSv1 TLSv1.1 TLSv1.2; # Dropping SSLv3, ref: POODLE
        ssl_prefer_server_ciphers on;

        gzip on;
        gzip_http_version  1.1;
        gzip_comp_level    5;
        gzip_min_length    256;
        gzip_proxied       any;
        gzip_vary          on;
        gzip_types
        application/atom+xml
        application/javascript
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
        error_log /dev/sterr info;
        include /etc/nginx/conf.d/*.conf;
        include /etc/nginx/sites-enabled/*;
}
EOL
        nginx
elif [ $1 == "bash" ]; then
	bash
fi
