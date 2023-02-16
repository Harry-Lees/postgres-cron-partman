FROM postgres:15-bullseye

ENV PG_PARTMAN_VERSION v4.7.1

RUN apt-get update \
    && apt-get install -y wget \
    && apt-get install -y build-essential \
    && apt-get install -y postgresql-server-dev-15 \
    && apt-get install -y libpq-dev \
    && apt-get install -y postgresql-15-cron \
    && rm -rf /var/lib/apt/lists/*

RUN \
    set -ex \
    && wget -O pg_partman.tar.gz "https://github.com/pgpartman/pg_partman/archive/$PG_PARTMAN_VERSION.tar.gz" \
    && mkdir -p /usr/src/pg_partman \
    && tar \
        --extract \
        --file pg_partman.tar.gz \
        --directory /usr/src/pg_partman \
        --strip-components 1 \
    && rm pg_partman.tar.gz \
    && cd /usr/src/pg_partman \
    && make \
    && make install \
    && rm -rf /usr/src/pg_partman

RUN echo "listen_addresses = '*'" >> /etc/postgresql/postgresql.conf
RUN echo "shared_preload_libraries = 'pg_partman_bgw,pg_cron'" >> /etc/postgresql/postgresql.conf
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]