ARG postgresql_major=17

FROM postgres:${postgresql_major} as base

FROM base as pgx_ulid

ADD "https://github.com/HRKings/pgx_ulid/releases/download/v0.2.0/pgx_ulid-v0.2.0-pg17-amd64-linux-gnu.deb" \
    /tmp/pgx_ulid.deb

####################
# Collect extension packages
####################
FROM scratch as extensions
COPY --from=pgx_ulid /tmp/*.deb /tmp/

####################
# Build final image
####################
FROM base as production

# Setup extensions
COPY --from=extensions /tmp /tmp

RUN apt-get update && apt-get install -y --no-install-recommends \
    /tmp/*.deb \
    && rm -rf /var/lib/apt/lists/* /tmp/*


# sudo docker ps -a

# sudo docker stop ca92d4ff3043

# sudo docker rm ca92d4ff3043

# sudo docker rm -f $(sudo docker ps -a -q)

# sudo docker volume ls

# sudo docker volume rm myapp_postgres_data  
