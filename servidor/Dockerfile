# ============================================================
# Servidor PostgreSQL compilado desde su código fuente
# (repositorio oficial: https://github.com/postgres/postgres)
# ============================================================
FROM debian:bookworm-slim

# Rama o tag a compilar. Para fijar una versión exacta usa un tag (ej. REL_17_x)
ARG PG_BRANCH=REL_17_STABLE

ENV LANG=C.UTF-8 \
    PGDATA=/var/lib/postgresql/data \
    PATH=/usr/local/pgsql/bin:$PATH

# 1) Dependencias de compilación (solo herramientas; PostgreSQL NO se instala por apt)
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential git ca-certificates perl bison flex pkg-config \
        libreadline-dev zlib1g-dev libssl-dev libicu-dev \
    && rm -rf /var/lib/apt/lists/*

# 2) Descarga del código fuente, compilación e instalación
RUN git clone --depth 1 --branch "${PG_BRANCH}" \
        https://github.com/postgres/postgres.git /usr/src/postgres \
    && cd /usr/src/postgres \
    && ./configure --prefix=/usr/local/pgsql --with-openssl \
    && make -j"$(nproc)" \
    && make install \
    && rm -rf /usr/src/postgres

# 3) Usuario sin privilegios (postgres se niega a correr como root) y directorio de datos
RUN useradd -r -m -d /var/lib/postgresql -s /bin/bash postgres \
    && mkdir -p "$PGDATA" \
    && chown -R postgres:postgres /var/lib/postgresql

# 4) Script de arranque (initdb la primera vez y luego levanta el servidor)
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN sed -i 's/\r$//' /usr/local/bin/entrypoint.sh \
    && chmod +x /usr/local/bin/entrypoint.sh

USER postgres
EXPOSE 5432
ENTRYPOINT ["entrypoint.sh"]
