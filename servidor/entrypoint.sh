#!/bin/bash
set -e

: "${POSTGRES_USER:=postgres}"
: "${POSTGRES_PASSWORD:?Debes definir POSTGRES_PASSWORD}"

# Solo inicializa el clúster si el directorio de datos está vacío
if [ ! -s "$PGDATA/PG_VERSION" ]; then
    PWFILE="$(mktemp)"
    echo "$POSTGRES_PASSWORD" > "$PWFILE"

    # Autenticación SCRAM explícita: evita el warning de "trust authentication"
    initdb -D "$PGDATA" \
        -U "$POSTGRES_USER" \
        --pwfile="$PWFILE" \
        --auth-local=scram-sha-256 \
        --auth-host=scram-sha-256 \
        --encoding=UTF8 \
        --locale=C.UTF-8

    rm -f "$PWFILE"

    # Escuchar en todas las interfaces y aceptar clientes de la red de Docker
    echo "listen_addresses = '*'" >> "$PGDATA/postgresql.conf"
    echo "host all all 0.0.0.0/0 scram-sha-256" >> "$PGDATA/pg_hba.conf"
fi

# exec: postgres pasa a ser el proceso principal (recibe bien las señales de Docker)
exec postgres -D "$PGDATA" "$@"
