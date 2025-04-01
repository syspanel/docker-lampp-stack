#!/bin/bash
set -e # Exit on any error

# Create log directories for Apache, MariaDB, Redis, and Supervisor
echo "Creating log directories..."
mkdir -p /var/log/apache2 /var/log/mariadb /var/log/redis /var/log/supervisor
chown www-data:www-data /var/log/apache2
chown mysql:mysql /var/log/mariadb
chown redis:redis /var/log/redis
chown root:root /var/log/supervisor
touch /var/log/mariadb/error.log
chown mysql:mysql /var/log/mariadb/error.log

# Initialize MariaDB if the data directory is empty
if [ -z "$(ls -A /var/lib/mysql)" ]; then
    echo "Initializing MariaDB data directory..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql --skip-test-db 2>&1 | tee /var/log/mariadb/init.log
    if [ $? -ne 0 ]; then
        echo "Failed to initialize MariaDB data directory. Check logs:"
        cat /var/log/mariadb/init.log
        cat /var/log/mariadb/error.log
        exit 1
    fi

    # Start MariaDB temporarily to apply initial configuration
    echo "Starting MariaDB for initial configuration..."
    /usr/sbin/mariadbd --user=mysql --datadir=/var/lib/mysql --log-error=/var/log/mariadb/error.log --verbose &
    MARIADB_PID=$!
    sleep 5 # Wait for MariaDB to start

    # Check if MariaDB started successfully
    if ! ps -p $MARIADB_PID > /dev/null; then
        echo "MariaDB failed to start. Check logs:"
        cat /var/log/mariadb/error.log
        exit 1
    fi

    # Apply initial configuration (set root password and remove anonymous users)
    echo "Configuring MariaDB root user..."
    mariadb -u root -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('root'); DROP USER IF EXISTS ''@'localhost'; DROP USER IF EXISTS ''@'%'; FLUSH PRIVILEGES;" 2>&1 | tee /var/log/mariadb/config.log
    if [ $? -ne 0 ]; then
        echo "Failed to configure MariaDB. Check logs:"
        cat /var/log/mariadb/config.log
        cat /var/log/mariadb/error.log
        kill $MARIADB_PID
        exit 1
    fi

    # Stop the temporary MariaDB instance
    echo "Stopping temporary MariaDB instance..."
    kill $MARIADB_PID
    sleep 2 # Give it time to shut down
else
    echo "MariaDB data directory already exists, skipping initialization."
fi

# Start Supervisor to manage services
echo "Starting Supervisor..."
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf