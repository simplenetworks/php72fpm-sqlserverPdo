# Build app image
FROM bitnami/php-fpm:7.2.21-debian-9-r7

# apt-get and system utilities
RUN apt-get update && apt-get install -y \
    curl apt-utils apt-transport-https autoconf debconf-utils gcc gnupg build-essential g++

# adding custom MS repository
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list

# install SQL Server drivers
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y msodbcsql17
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y unixodbc-dev

# install SQL Server tools
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y mssql-tools
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
RUN /bin/bash -c "source ~/.bashrc"

RUN apt-get update && apt-get install -y php-pear libmcrypt-dev libpng-dev zlib1g-dev \
    libicu-dev --no-install-recommends

# install SQL Server PHP connector module
RUN pecl channel-update pecl.php.net
RUN pecl install sqlsrv pdo_sqlsrv

RUN apt-get install -y apt-transport-https lsb-release ca-certificates
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
RUN echo "deb https://packages.sury.org/php/ stretch main" | tee /etc/apt/sources.list.d/php.list

# initial configuration of SQL Server PHP connector
RUN echo "extension=/opt/bitnami/php/lib/php/extensions/sqlsrv.so" >> /opt/bitnami/php/lib/php.ini
RUN echo "extension=/opt/bitnami/php/lib/php/extensions/pdo_sqlsrv.so" >> /opt/bitnami/php/lib/php.ini

RUN apt-get update && apt-get install -y php7.2-intl php7.2-zip php7.2-gd

# Don't clear env variables
# This is very important since it will allow us to read environment variables from the container.
RUN sed -e 's/;clear_env = no/clear_env = no/' -i /opt/bitnami/php/etc/php-fpm.d/www.conf
