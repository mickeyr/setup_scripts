#!/bin/ash
echo What\'s the name of the service you\'d like to configure?
read SERVICE_NAME
echo What\'s the IP:PORT of this service?
read IP_PORT
echo Setting up a reverse proxy for $SERVICE_NAME at http://${IP_PORT}

cat > /etc/nginx/sites-available/$SERVICE_NAME << EOF
server {
        listen  80;
        listen  [::]:80;
        server_name     $SERVICE_NAME.mroberts.dev;
        access_log      /var/log/nginx/$SERVICE_NAME-access.log;
        error_log       /var/log/nginx/$SERVICE_NAME-error.log;

        location / {
                include         /etc/nginx/conf.d/proxy.conf;
                proxy_pass      http://${IP_PORT};
        }

        # SSL Configuration
        listen 443 ssl;
        listen [::]:443 ssl;
        include /etc/nginx/conf.d/ssl.conf;
}
EOF;

ln -s /etc/nginx/sites-available/$SERVICE_NAME /etc/nginx/sites-enabled/$SERVICE_NAME
rc-service nginx restart

