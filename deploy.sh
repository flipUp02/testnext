ARG postgresql_major=16

FROM postgres:${postgresql_major} as base

FROM base as pgx_ulid

# # postgres 17
# ADD "https://github.com/HRKings/pgx_ulid/releases/download/v0.2.0/pgx_ulid-v0.2.0-pg17-amd64-linux-gnu.deb" \
#     /tmp/pgx_ulid.deb

ADD "https://github.com/pksunkara/pgx_ulid/releases/download/v0.1.5/pgx_ulid-v0.1.5-pg14-amd64-linux-gnu.deb" \
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

# sudo docker logs --since=1h ca92d4ff3043

# sudo docker rm -f $(sudo docker ps -a -q)

# sudo docker volume ls

# sudo docker volume rm myapp_postgres_data   




# nano ./myapp/.env

# CREATE EXTENSION ulid;
# ALTER SYSTEM SET shared_preload_libraries = 'ulid';
# SHOW shared_preload_libraries;

# EXPLAIN ANALYZE SELECT gen_ulid()  FROM generate_series(1,1000000); 
# EXPLAIN ANALYZE SELECT gen_random_uuid()  FROM generate_series(1,1000000); 


# https://www.enterprisedb.com/download-postgresql-binaries
# C:\Users\aliqa\AppData\Roaming\DBeaverData\drivers\clients\postgresql\win



# ####################
# # Add pg_dump in a new stage
# ####################
# FROM base as pg_dump

# # Install pg_dump matching the PostgreSQL major version
# RUN apt-get update && \
#     apt-get install -y --no-install-recommends postgresql-client-${postgresql_major} && \
#     rm -rf /var/lib/apt/lists/*


# CREATE EXTENSION ulid;

# EXPLAIN ANALYZE SELECT gen_ulid()  FROM generate_series(1,1000000); 
# EXPLAIN ANALYZE SELECT gen_random_uuid()  FROM generate_series(1,1000000); 






# //////////////////
# ARG PG_MAJOR=16

# FROM postgres:${PG_MAJOR}
# RUN apt-get update && apt-get upgrade -y

# ENV build_deps ca-certificates \
#   git \
#   build-essential \
#   libpq-dev \
#   postgresql-server-dev-${PG_MAJOR} \
#   curl \
#   libreadline6-dev \
#   zlib1g-dev


# RUN apt-get install -y --no-install-recommends $build_deps pkg-config cmake

# WORKDIR /home/postgres

# ENV HOME=/home/postgres
# ENV PATH=/home/postgres/.cargo/bin:$PATH

# RUN chown postgres:postgres /home/postgres

# USER postgres

# RUN \
#   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path --profile minimal --default-toolchain nightly && \
#   rustup --version && \
#   rustc --version && \
#   cargo --version


# RUN cargo install cargo-pgrx --version 0.11.2 --locked

# RUN cargo pgrx init --pg${PG_MAJOR} download

# USER root


# RUN mkdir -p /tmp/build \
#   && cd /tmp/build \
#   && git clone https://github.com/pksunkara/pgx_ulid \
#   && cd pgx_ulid \
#   && cargo pgrx install

# RUN rm -fr /tmp/build \
#   && apt-get clean \
#   && apt-get autoremove -y $build_deps
