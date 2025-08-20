# Docker LAMP Stack

A flexible and robust LAMP (Linux, Apache, MySQL/MariaDB, PHP) stack Docker image with additional tools like Redis, Python, Node.js, and Composer. This project supports configurable PHP and phpMyAdmin versions, managed by Supervisor for process reliability.

## Features
- **Base:** Ubuntu 24.04
- **Web Server:** Apache 2
- **Database:** MariaDB
- **PHP:** Configurable version (default: 7.4) with essential and optional extensions
- **phpMyAdmin:** Configurable version (default: 5.1.1) with fallback to 5.2.1
- **Extras:** Redis, Python 3, Node.js 18.x, Composer
- **Process Management:** Supervisor
- **Persistence:** Volumes for MySQL, application data, and logs
- **Ports:** 80 (Apache), 3306 (MariaDB), 6379 (Redis), with optional additional ports

## Requirements
- Docker installed on your system

## Usage

# Docker LAMP Stack

A flexible and robust LAMP (Linux, Apache, MySQL/MariaDB, PHP) stack Docker image with additional tools like Redis, Python, Node.js, and Composer. This project supports configurable PHP and phpMyAdmin versions, managed by Supervisor for process reliability.

## Features
- **Base:** Ubuntu 24.04
- **Web Server:** Apache 2
- **Database:** MariaDB
- **PHP:** Configurable version (default: 7.4) with essential and optional extensions
- **phpMyAdmin:** Configurable version (default: 5.1.1) with fallback to 5.2.1
- **Extras:** Redis, Python 3, Node.js 18.x, Composer
- **Process Management:** Supervisor
- **Persistence:** Volumes for MySQL, application data, and logs
- **Ports:** 80 (Apache), 3306 (MariaDB), 6379 (Redis), with optional additional ports

## Requirements
- Docker installed on your system

## Usage

### Build the Image
1. Clone or download this repository:
   ```bash
   git clone https://github.com/syspanel/docker-lamp-stack.git
   cd docker-lamp-stack

    Build the Docker image with specific PHP and phpMyAdmin versions:
        PHP 7.4 with phpMyAdmin 5.1.1 (default):
        bash

        docker build -t docker-lamp-stack .
        
        PHP 7.4 with phpMyAdmin 5.1.1:
        bash
        docker build -t docker-lamp-stack-74 --build-arg PHP_VERSION=7.4 --build-arg PHPMYADMIN_VERSION=5.1.1 .
        PHP 8.0 with phpMyAdmin 5.2.1:
        bash
        docker build -t docker-lamp-stack-80 --build-arg PHP_VERSION=8.0 --build-arg PHPMYADMIN_VERSION=5.2.1 .
        PHP 8.1 with phpMyAdmin 5.2.1:
        bash
        docker build -t docker-lamp-stack-81 --build-arg PHP_VERSION=8.1 --build-arg PHPMYADMIN_VERSION=5.2.1 .
        PHP 8.2 with phpMyAdmin 5.2.1:
        bash
        docker build -t docker-lamp-stack-82 --build-arg PHP_VERSION=8.2 --build-arg PHPMYADMIN_VERSION=5.2.1 .
        PHP 8.3 with phpMyAdmin 5.2.1:
        bash
        docker build -t docker-lamp-stack-83 --build-arg PHP_VERSION=8.3 --build-arg PHPMYADMIN_VERSION=5.2.1 .
        Note: If the specified PHPMYADMIN_VERSION is unavailable, it falls back to 5.2.1.

Run the Container

Run the container with persistent volumes for the application, MySQL data, and logs. Below is an example with additional ports and log mapping:
   bash
   
      docker run --name "docker-lamp-stack" \
        -p "8080:80" -p "8082:3306" -p "8083:6379" \
        -e MYSQL_PASSWORD=root \
        -v ${PWD}/app:/app -v ${PWD}/mysql:/var/lib/mysql \
        -v ${PWD}/logs:/var/log \
        docker-lamp-stack-74

Basic Example (without additional ports or logs):
    bash  
    
       docker run --name "docker-lamp-stack" \
         -p "8080:80" -p "8082:3306" -p "8083:6379" \
         -e MYSQL_PASSWORD=root \
         -v ${PWD}/app:/app -v ${PWD}/mysql:/var/lib/mysql \
         docker-lamp-stack

Access

    Web Server: http://localhost:16080 (or 8080 for basic example; displays "Server running! PHP x.x.x")
    phpMyAdmin: http://localhost:16080/phpmyadmin (or 8080; user: root, password: root)
    MariaDB: Port 16082 (or 8082), user: root, password: root
    Redis: Port 16083 (or 8083)
    Additional Ports: 16081 (443), 16084 (8000), 16085 (9000), 16086 (10000) are mappable but require additional configuration for use (e.g., SSL for 443).

Create user 'pma' for phpmyadmin:

    docker exec -it docker-lamp-stack mariadb -u root -p

    CREATE USER 'pma'@'%' IDENTIFIED BY 'password';
    GRANT ALL PRIVILEGES ON *.* TO 'pma'@'%' WITH GRANT OPTION;
    FLUSH PRIVILEGES;
    exit
    
Logs

Logs are available in the /var/log directory inside the container. With the -v ${PWD}/logs:/var/log volume, they are persisted to the logs directory on the host:

    Apache: ${PWD}/logs/apache2/supervisor.log
    MariaDB: ${PWD}/logs/mariadb/supervisor.log, ${PWD}/logs/mariadb/error.log
    Redis: ${PWD}/logs/redis/supervisor.log
    Supervisor: ${PWD}/logs/supervisor/supervisord.log

Configuration

Configuration files are located in the config/ directory:

    Apache: config/apache/000-default.conf
    PHP: config/php/apache2-php.ini and config/php/cli-php.ini
    MariaDB: config/mariadb/custom.cnf
    Redis: config/redis/redis.conf
    Supervisor: config/supervisor/ (main config and service-specific files)
    Startup Script: config/start.sh (initializes MariaDB and creates log directories)

Supported PHP Versions

Any version available in the ppa:ondrej/php repository (e.g., 7.0, 7.1, 7.2, 7.3, 7.4, 8.0, 8.1, 8.2, 8.3). Optional extensions are installed if available; missing ones are skipped without failing the build.
phpMyAdmin Fallback

If the specified PHPMYADMIN_VERSION is not found, the build automatically falls back to version 5.2.1, ensuring compatibility with modern PHP versions.
Repository

This project is hosted on GitHub: syspanel/docker-lamp-stack
License

This project is licensed under the MIT License. See the  file for details.
Author

Marco Costa marcocosta@gmx.com
Support the Project

### Support the Project
If you find this project useful, consider supporting its development with a donation via PayPal:

[![Donate via PayPal](https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif)](https://www.paypal.com/donate/?business=marcocosta@gmx.com&currency_code=USD)


