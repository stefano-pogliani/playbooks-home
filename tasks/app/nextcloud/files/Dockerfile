FROM nextcloud:19.0.0-apache


# Add user and group.
ARG GROUP_ID
ARG USER_ID
RUN addgroup --system --gid ${GROUP_ID} nextcloud && \
    adduser --system --uid ${USER_ID} \
    -ingroup nextcloud --disabled-login nextcloud && \
    adduser nextcloud www-data


# Install PostgreSQL 10 client.
RUN apt-get update && apt-get install -y gnupg && \
    echo 'deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main' > /etc/apt/sources.list.d/postgresql.list && \
    curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get update && apt-get upgrade -y && \
    apt-get install -y postgresql-client-10 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*


# Tweak apache2 configuration.
ENV APACHE_RUN_USER=nextcloud
ENV APACHE_RUN_GROUP=nextcloud
COPY apache2.conf ports.conf /etc/apache2/
COPY 000-default.conf /etc/apache2/sites-enabled/000-default.conf
RUN chown -R nextcloud:www-data /var/run/apache2 /var/lock/apache2 \
    && a2enmod headers


# Once nextcloud is installed run these on the host.
# Tweak NextCloud security headers enforced by AuthGateway to avoid duplicates.
#sed -i '/Header always set X-Content-Type-Options/d' /data/nextcloud/.htaccess \
#  && sed -i '/Header always set X-Frame-Options/d' /data/nextcloud/.htaccess \
#  && sed -i '/Header always set X-XSS-Protection/d' /data/nextcloud/.htaccess


# Run
USER nextcloud
