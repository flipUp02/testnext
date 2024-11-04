ARG postgresql_major=17

####################
# Postgres
####################
FROM postgres:${postgresql_major} as base


####################
# Extension: pgx_ulid
####################
FROM base as pgx_ulid

# Download package archive

ADD "https://github.com/pksunkara/pgx_ulid/releases/download/v0.1.5/pgx_ulid-v0.1.5-pg16-amd64-linux-gnu.deb" \
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

# Modify pg_hba.conf to allow connections from all IP addresses
RUN echo "host all all 0.0.0.0/0 md5" >> /var/lib/postgresql/data/pg_hba.conf
