FROM postgres:17
RUN apt-get update && apt-get upgrade -y

ENV build_deps ca-certificates \
  git \
  build-essential \
  libpq-dev \
  postgresql-server-dev-17 \
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
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path --profile minimal --default-toolchain nightly && \
  rustup --version && \
  rustc --version && \
  cargo --version

# PGX
RUN cargo install cargo-pgrx --version 0.11.2 --locked

RUN cargo pgrx init --pg17 $(which pg_config)

USER root


RUN mkdir -p /tmp/build \
  && cd /tmp/build \
  && git clone https://github.com/pksunkara/pgx_ulid \
  && cd pgx_ulid \
  && cargo pgrx install

RUN rm -fr /tmp/build \
  && apt-get clean \
  && apt-get autoremove -y $build_deps

