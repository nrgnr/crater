FROM php:8.1-fpm

# Arguments defined in docker-compose.yml
ARG user=crater-user
ARG uid=1000

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    libmagickwand-dev \
    default-mysql-client \
    --no-install-recommends

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN pecl install imagick \
    && docker-php-ext-enable imagick

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl bcmath gd

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
RUN groupadd --force -g $uid $user \
    && useradd -G www-data,root -u $uid -d /home/$user -s /bin/bash -g $user $user \
    && mkdir -p /home/$user/.composer \
    && chown -R $user:$user /home/$user

# Set working directory
WORKDIR /var/www

# Copy wait-for-db script
COPY docker-compose/php/wait-for-db.sh /usr/local/bin/wait-for-db
RUN chmod +x /usr/local/bin/wait-for-db

# Copy and set entrypoint script
COPY docker-compose/php/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Switch to non-root user
USER $user

# Copy application files
COPY --chown=$user:$user . /var/www/

ENTRYPOINT ["docker-entrypoint.sh"]
