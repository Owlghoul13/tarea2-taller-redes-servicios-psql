
# Cliente pgcli instalado desde su código fuente
# (repositorio oficial: https://github.com/dbcli/pgcli)

FROM python:3.12-slim-bookworm

# Rama o tag a instalar. Para fijar versión usa un tag de release del repo.
ARG PGCLI_REF=main

# 1) Herramientas de compilación + utilidades para generar/capturar tráfico
RUN apt-get update && apt-get install -y --no-install-recommends \
        git gcc libpq-dev iputils-ping tcpdump \
    && rm -rf /var/lib/apt/lists/*

# 2) Código fuente de pgcli e instalación desde el repositorio clonado
#    (se clona completo, sin --depth, por si el versionado depende de los tags)
RUN git clone https://github.com/dbcli/pgcli.git /opt/pgcli \
    && cd /opt/pgcli \
    && git checkout "${PGCLI_REF}" \
    && pip install --no-cache-dir .

# 3) Usuario sin privilegios para usar el cliente
RUN useradd -m cliente \
    && mkdir -p /capturas && chown cliente:cliente /capturas
USER cliente
WORKDIR /home/cliente

# El contenedor queda levantado y listo; se entra con:
#   docker exec -it pg-cliente pgcli -h servidor -U postgres -d postgres
CMD ["sleep", "infinity"]
