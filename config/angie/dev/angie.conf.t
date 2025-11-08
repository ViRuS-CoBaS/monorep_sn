user  angie;
worker_processes  auto;

error_log /dev/stderr debug;

pid        /var/run/angie.pid;

events {
    worker_connections 1024;   # ваше значение
}

http {
    include       /etc/angie/mime.types;
    default_type  application/octet-stream;
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /dev/stdout combined;

    sendfile        on;
    keepalive_timeout  65;

    # подключаем виртуальные хосты
    include /etc/angie/http.d/*.conf;
}