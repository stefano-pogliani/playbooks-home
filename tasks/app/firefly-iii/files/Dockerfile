FROM jc5x/firefly-iii:release-4.7.9


# Add user and group.
ARG GROUP_ID
ARG USER_ID
RUN addgroup --system --gid ${GROUP_ID} firefly-iii && \
    adduser --system --uid ${USER_ID} \
    -ingroup firefly-iii --disabled-login firefly-iii && \
    adduser firefly-iii www-data


# Install gnupg for key validation.
RUN apt-get update && \
    apt-get install -y gnupg && \
    apt-get clean && rm -rf /var/lib/apt/lists/*


# Install PostgreSQL 10 client.
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main' > /etc/apt/sources.list.d/postgresql.list && \
    curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get update && apt-get upgrade -y && \
    apt-get install -y postgresql-client-10 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*


# Fix /.composer permissions for cache.
RUN mkdir -p /home/firefly-iii/.composer && \
    chown firefly-iii:firefly-iii /home/firefly-iii/.composer && \
    chown -R firefly-iii:firefly-iii /var/www/firefly-iii && \
    chown -R firefly-iii:firefly-iii /var/lock/apache2 && \
    chown -R firefly-iii:firefly-iii /var/run/apache2


# Change apache2 listen configuration.
ARG LISTEN_ADDRESS=*
ARG LISTEN_PORT=80
RUN sed -i "s/Listen 80$/Listen ${LISTEN_ADDRESS}:${LISTEN_PORT}/" /etc/apache2/ports.conf && \
    sed -i "s/[^#]Listen 443/#Listen 443/" /etc/apache2/ports.conf
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf


# Override the entrypoint to not re-render the .env file
COPY entrypoint-override.sh /entrypoint-override.sh
RUN chmod 0755 /entrypoint-override.sh


# Run
USER firefly-iii
ENTRYPOINT ["/entrypoint-override.sh"]
