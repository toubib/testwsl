#!/bin/sh

apt install -y nginx

# certificates
rm -f /etc/ssl/private/nginx-selfsigned.key /etc/ssl/certs/nginx-selfsigned.crt
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt \
	-subj "/CN=$HOSTNAME" \
	-addext "subjectAltName=DNS:$HOSTNAME,DNS:localhost,DNS:127.0.0.1"

echo "
server {
        listen 80 default_server;
        listen 443 ssl http2 default_server;

        server_name _;

        ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
        ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;

        ssl_protocols TLSv1.2 TLSv1.1 TLSv1;

        location / {
                 proxy_pass http://127.0.0.1:8080;
        }
}
" > /etc/nginx/sites-available/localhost

rm -f /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/localhost

service nginx restart
