ARG postgresql_major=16

ARG pgx_ulid_release=0.1.5

####################
# Postgres
####################
FROM postgres:${postgresql_major} as base

# Redeclare args for use in subsequent stages
ARG TARGETARCH
ARG postgresql_major

####################
# Extension: pgx_ulid
####################
FROM base as pgx_ulid

# Download package archive
ARG pgx_ulid_release
ADD "https://github.com/pksunkara/pgx_ulid/releases/download/v${pgx_ulid_release}/pgx_ulid-v${pgx_ulid_release}-pg${postgresql_major}-${TARGETARCH}-linux-gnu.deb" \
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
