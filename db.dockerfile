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

USER root

# Get the latest pgx_ulid version and install it
RUN curl -s https://api.github.com/repos/pksunkara/pgx_ulid/releases/latest \
    | grep "browser_download_url.*pgx_ulid.*amd64-linux-gnu.deb" \
    | cut -d '"' -f 4 \
    | xargs curl -L -o pgx_ulid.deb && \
    apt install -y ./pgx_ulid.deb && \
    rm pgx_ulid.deb

# Switch back to the postgres user to create the extension
USER postgres

RUN psql -c "CREATE EXTENSION ulid;" && \
    psql -c "ALTER SYSTEM SET shared_preload_libraries = 'ulid';"
