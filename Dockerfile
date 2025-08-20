# Base image: Ubuntu 24.04
FROM ubuntu:24.04
LABEL maintainer="Marco Costa <marcocosta@gmx.com>"
ENV REFRESHED_AT=2025-03-28


# Arguments to define PHP and phpMyAdmin versions (defaults: PHP 7.4, phpMyAdmin 5.1.1)
ARG PHP_VERSION=7.4
ARG PHPMYADMIN_VERSION=5.1.1

# Environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    PHP_VERSION=${PHP_VERSION} \
    PHPMYADMIN_VERSION=${PHPMYADMIN_VERSION} \
    APACHE_RUN_USER=www-data \
    APACHE_RUN_GROUP=www-data \
    APACHE_LOG_DIR=/var/log/apache2 \
    APACHE_PID_FILE=/var/run/apache2.pid \
    APACHE_RUN_DIR=/var/run/apache2 \
    APACHE_LOCK_DIR=/var/lock/apache2 \
    MYSQL_USER=root \
    PYTHONUNBUFFERED=1

# Update repositories and install basic tools + Supervisor
RUN apt-get update && \
    apt-get install -y software-properties-common curl wget git nano pwgen unzip supervisor

# Add Ondrej's PHP repository for Ubuntu 24.04
RUN LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C && \
    apt-get update

# Install core packages (Apache, PHP core, MariaDB, Redis, Python)
RUN apt-get install -y \
    apache2 \
    php${PHP_VERSION} \
    libapache2-mod-php${PHP_VERSION} \
    mariadb-server mariadb-client \
    redis-server \
    python3 python3-pip python3-venv

# Install essential PHP extensions (required for Laravel/WordPress)
RUN apt-get install -y \
    php${PHP_VERSION}-mysql \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-zip

# Install optional PHP extensions (ignore failures)
RUN for ext in apcu bcmath intl soap sqlite3 cli opcache xdebug redis imagick; do \
    apt-get install -y php${PHP_VERSION}-${ext} || echo "Extension php${PHP_VERSION}-${ext} not available, skipping."; \
    done

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Node.js 18.x
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Configure Apache with DocumentRoot at /var/www/html
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
    a2enmod rewrite && \
    mkdir -p /app && \
    echo "<?php echo 'Server running! PHP ' . phpversion(); ?>" > /app/index.php && \
    rm -fr /var/www/html && \
    ln -s /app /var/www/html && \
    chown -R www-data:www-data /app

# Create runtime directory for MariaDB socket
RUN mkdir -p /run/mysqld && \
    chown mysql:mysql /run/mysqld && \
    chmod 755 /run/mysqld

# Copy configuration files
COPY config/apache/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY config/php/apache2-php.ini /etc/php/${PHP_VERSION}/apache2/php.ini
COPY config/php/cli-php.ini /etc/php/${PHP_VERSION}/cli/php.ini
COPY config/mariadb/custom.cnf /etc/mysql/mariadb.conf.d/custom.cnf
COPY config/redis/redis.conf /etc/redis/redis.conf
COPY config/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
COPY config/supervisor/apache2.conf /etc/supervisor/conf.d/apache2.conf
COPY config/supervisor/mariadb.conf /etc/supervisor/conf.d/mariadb.conf
COPY config/supervisor/redis.conf /etc/supervisor/conf.d/redis.conf
COPY config/start.sh /start.sh

# Install phpMyAdmin with fallback to version 5.2.1 if the specified version fails
RUN echo "Attempting to download phpMyAdmin ${PHPMYADMIN_VERSION}..." && \
    wget -O /tmp/phpmyadmin.tar.gz https://files.phpmyadmin.net/phpMyAdmin/${PHPMYADMIN_VERSION}/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.gz || \
    (echo "Failed to download phpMyAdmin ${PHPMYADMIN_VERSION}, falling back to 5.2.1..." && \
     wget -O /tmp/phpmyadmin.tar.gz https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.tar.gz) && \
    tar xfvz /tmp/phpmyadmin.tar.gz -C /var/www && \
    ln -s /var/www/phpMyAdmin-*-all-languages /var/www/phpmyadmin && \
    mv /var/www/phpmyadmin/config.sample.inc.php /var/www/phpmyadmin/config.inc.php && \
    sed -i "s/\$cfg\['Servers'\]\[\$i\]\['password'\] = '';/\$cfg['Servers'][\$i]['password'] = 'root';/" /var/www/phpmyadmin/config.inc.php && \
    chown -R www-data:www-data /var/www/phpmyadmin

# Set permissions for startup script
RUN chmod +x /start.sh

# Clean up unnecessary packages
RUN apt-get -y autoremove && \
    apt-get -y clean

# Volumes for persistence
VOLUME ["/var/lib/mysql", "/app", "/var/log"]

# Exposed ports (80: Apache, 3306: MariaDB, 6379: Redis)
EXPOSE 80 3306 6379

# Use start.sh as the entrypoint
CMD ["/start.sh"]

# Exposed ports (80: Apache, 3306: MariaDB, 6379: Redis)
EXPOSE 80 3306 6379

# Use start.sh as the entrypoint
CMD ["/start.sh"]
