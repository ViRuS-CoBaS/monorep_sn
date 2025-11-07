FROM docker.angie.software/angie:latest

RUN apk add --no-cache curl ca-certificates gettext-envsubst && \
    curl -L -o /usr/local/bin/mkcert https://github.com/FiloSottile/mkcert/releases/latest/download/mkcert-v1.4.4-linux-amd64 && \
    chmod +x /usr/local/bin/mkcert && \
    apk del curl

# директория, куда mkcert положит корень
# Создай директорию для certs (если нет)
RUN mkdir -p /etc/angie/ssl

# Entry point script для генерации certs при запуске
COPY entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["angie", "-g", "daemon off;"]