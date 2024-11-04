ARG PG_MAJOR=17

FROM postgres:${PG_MAJOR}

RUN apt-get update

ENV build_deps ca-certificates \
  git \
  build-essential \
  libpq-dev \
  postgresql-server-dev-${PG_MAJOR} \
  curl \
  libreadline6-dev \
  zlib1g-dev

RUN apt-get install -y --no-install-recommends $build_deps pkg-config cmake

WORKDIR /home/postgres

ENV HOME=/home/postgres
ENV PATH=/home/postgres/.cargo/bin:$PATH

RUN chown postgres:postgres /home/postgres

USER postgres

RUN \
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path --profile minimal --default-toolchain 1.74.0 && \
  rustup --version && \
  rustc --version && \
  cargo --version

USER root

# Download and install the pgx_ulid extension
RUN wget https://github.com/pksunkara/pgx_ulid/releases/download/v0.1.5/pgx_ulid-v0.1.5-pg17-amd64-linux-gnu.deb && \
    apt install -y ./pgx_ulid-v0.1.5-pg17-amd64-linux-gnu.deb && \
    rm pgx_ulid-v0.1.5-pg17-amd64-linux-gnu.deb

# Switch back to the postgres user to create the extension
USER postgres

RUN psql -c "CREATE EXTENSION ulid;" && \
    psql -c "ALTER SYSTEM SET shared_preload_libraries = 'ulid';"
