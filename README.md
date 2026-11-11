# Tarea 2 – Taller de Redes y Servicios: protocolo PSQL (PostgreSQL + pgcli)

Universidad Diego Portales · Facultad de Ingeniería y Ciencias · Taller de Redes y Servicios · 2026-2

**Integrantes:** Felipe Galleguillos y Felipe Yevilao

## Descripción del proyecto

Este proyecto estudia el tráfico del protocolo de aplicación de PostgreSQL (el protocolo *frontend/backend*, llamado PSQL en el listado del curso). Se despliega una dupla de software en contenedores Docker, un servidor y un cliente, y se analiza con Wireshark el tráfico que se genera entre ambos.

- **Servidor:** PostgreSQL 17, compilado desde su código fuente (`github.com/postgres/postgres`).
- **Cliente:** pgcli, instalado desde su código fuente (`github.com/dbcli/pgcli`).
- **Red:** red *bridge* de Docker `172.28.0.0/24`, con el servidor en `172.28.0.10` y el cliente en `172.28.0.20`. La interfaz del puente se llama `br-psql`.

El proyecto cubre los capítulos 1 (introducción al protocolo) y 2 (análisis de tráfico) del informe acumulativo. El capítulo 3 se entregará en la Tarea 3.

## Estructura del repositorio

```
.
├── docker-compose.yml     # red, contenedores y direcciones IP
├── servidor/
│   ├── Dockerfile         # PostgreSQL compilado desde el código fuente
│   └── entrypoint.sh      # inicializa el clúster y arranca el servidor
├── cliente/
│   └── Dockerfile         # pgcli instalado desde el código fuente
└── capturas/              # capturas de Wireshark (.pcapng)
```

## Requisitos

- Linux (el proyecto se probó en una máquina virtual con Ubuntu).
- Docker y Docker Compose v2 (`docker compose`).
- Conexión a internet la primera vez, para descargar paquetes y clonar los repositorios durante la construcción.
- Wireshark, para capturar y analizar el tráfico (opcional).

## Instalación y ejecución

Construir las imágenes y levantar los dos contenedores (la primera vez tarda varios minutos, porque se compila PostgreSQL):

```bash
docker compose up -d --build
```

Verificar que estén en ejecución y revisar los registros del servidor:

```bash
docker compose ps
docker compose logs servidor
```

El servidor debe indicar que está listo para aceptar conexiones, sin errores ni advertencias.

Para detener todo y eliminar los contenedores y la red:

```bash
docker compose down
```

## Uso

Abrir pgcli dentro del contenedor cliente y conectarse al servidor:

```bash
docker exec -it pg-cliente pgcli -h servidor -U postgres -d postgres
```

La contraseña del entorno de pruebas es `redes2026` (se define en `docker-compose.yml`). Algunas consultas de ejemplo:

```sql
SELECT version();
CREATE TABLE prueba (id serial PRIMARY KEY, nombre text);
INSERT INTO prueba (nombre) VALUES ('hola'), ('redes');
SELECT * FROM prueba;
```

Para salir de pgcli: `\q`.

## Captura de tráfico

Con los contenedores en ejecución, abrir Wireshark y capturar sobre la interfaz `br-psql`. Algunos filtros útiles:

| Filtro | Qué muestra |
|---|---|
| `arp` | Resolución de direcciones entre los contenedores |
| `pgsql` | Mensajes del protocolo de PostgreSQL |
| `tcp.port == 5432` | Todo el tráfico hacia el servidor |
| `frame contains "pg_catalog"` | Consultas de metadatos de pgcli |

## Tráfico analizado

Se identificaron diez tipos de tráfico:

1. ARP
2. *Handshake* TCP
3. SSLRequest y su respuesta
4. StartupMessage
5. Autenticación SCRAM-SHA-256
6. Fin de la autenticación, parámetros de la sesión y ReadyForQuery
7. Consulta simple con resultado
8. Consultas de metadatos de pgcli (protocolo extendido)
9. ErrorResponse (de autenticación y de consulta)
10. Terminate y cierre TCP

El detalle de cada uno, con su origen y su destino, está en el informe.

## Video de demostración
https://youtu.be/23vwIsmVf8c

## Informe

El informe se redactó en LaTeX (Overleaf) con la estructura de la plantilla del curso.

## Notas

- La contraseña `redes2026` es solo para este entorno de pruebas.
- El servidor se configuró sin TLS a propósito: el análisis del tráfico en texto legible es parte del objetivo de la tarea.
