##	Ref[1]		:	http://www.unixmen.com/install-linux-dash-web-based-monitoring-system-centosrhel/
##	Ref[2]		:	https://hub.docker.com/r/itxaka/linux-dash-docker/~/dockerfile/
FROM alpine:latest

RUN apk add --update nginx php-fpm supervisor git \
&& rm -rf /var/cache/apk/*

# configure nginx for Linux-dash. So create /etc/nginx/conf.d/linuxdash.conf
touch linuxdash.conf
cat > /etc/nginx/conf.d/linuxdash.conf << "EOF"
server {
 server_name $domain_name;
 listen 8080;
 root /var/www;
 index index.html index.php;
 access_log /var/log/nginx/access.log;
 error_log /var/log/nginx/error.log;
 
 location ~* \.(?:xml|ogg|mp3|mp4|ogv|svg|svgz|eot|otf|woff|ttf|css|js|jpg|jpeg|gif|png|ico)$ {
 try_files $uri =404;
 expires max;
 access_log off;
 add_header Pragma public;
 add_header Cache-Control "public, must-revalidate, proxy-revalidate";
 }
 
 location /linux-dash {
 index index.html index.php;
 }
 
 # PHP-FPM via sockets
 location ~ \.php(/|$) {
 fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
 fastcgi_split_path_info ^(.+?\.php)(/.*)$;
 fastcgi_pass unix:/var/run/php-fpm.sock;
 if (!-f $document_root$fastcgi_script_name) {
 return 404;
 }
 try_files $uri $uri/ /index.php?$args;
 include fastcgi_params;
 }
}
EOF

# configure php-fpm. "/etc/php/php-fpm.conf"
# listen = /var/run/php-fpm.sock
# user = nginx
# group = nginx

more /etc/php/php-fpm.conf | grep -v ";" | egrep "user|group|listen"

# clone the latest linux-dash version under /var/www
cd /var/www
RUN git clone https://github.com/afaqurk/linux-dash.git && chown -R nginx:nginx /var/www

# Start nginx service
rc-service -l | egrep "nginx|php-fpm"
rc-service nginx restart
rc-service php-fpm restart

# Auto-start upon boot
rc-update add nginx default
rc-update add php-fpm default

# http://<linux-IP-address>:8080/linux-dash/

EXPOSE 8080 443
CMD ["/env/bin/python", "main.py"]




apk add php5-fpm



yum install php56w php56w-opcache --enablerepo=webtatic-testing
yum install php56w-fpm --enablerepo=webtatic-testing

