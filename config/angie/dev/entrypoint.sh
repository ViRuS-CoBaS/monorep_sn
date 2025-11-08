#!/bin/sh

set -e
trap 'echo "Script exited with error $? at line $LINENO"' ERR
echo "DOMAIN='$APP_DOMAIN'"
echo "APP_HTTPS_PORT='$APP_HTTPS_PORT'"
DOMAIN="${APP_DOMAIN:-elkk.test}"

CERT_CRT="/etc/angie/ssl/server.crt"
CERT_KEY="/etc/angie/ssl/server.key"

# Проверяем, существуют ли certs
if [ ! -f "$CERT_CRT" ] || [ ! -f "$CERT_KEY" ]; then
    echo "Generating certificates with mkcert..."
    # Генерируем certs (без -install, так как в контейнере; CA root на хосте)
    mkcert -cert-file "$CERT_CRT" -key-file "$CERT_KEY" "$DOMAIN"
    echo "Certificates generated: $CERT_CRT and $CERT_KEY"
else
    echo "Certificates already exist, skipping generation."
fi


# Запускаем оригинальный entrypoint Angie
exec "$@"