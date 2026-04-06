FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libicu-dev \
    libcurl4-openssl-dev \
    zip \
    unzip \
    libmemcached-dev \
    && rm -rf /var/lib/apt/lists/*

# Configure and install PHP extensions required by CodeIgniter
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    pdo \
    pdo_mysql \
    mysqli \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    zip \
    intl \
    curl \
    xml \
    opcache \
    sockets

# Install Redis, Memcached, and Xdebug extensions via PECL
RUN pecl install redis memcached xdebug \
    && docker-php-ext-enable redis memcached xdebug

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configure PHP for development
RUN cp "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

# Custom PHP settings
COPY php-local.ini /usr/local/etc/php/conf.d/php-local.ini

# Set working directory
WORKDIR /var/www/html

# Ensure the writable directory has correct ownership for PHP-FPM (www-data).
# This entrypoint script runs at container start, so it fixes permissions
# even after a fresh "composer create-project" on a mounted volume.
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose port 9000 for PHP-FPM
EXPOSE 9000

ENTRYPOINT ["entrypoint.sh"]
CMD ["php-fpm"]
