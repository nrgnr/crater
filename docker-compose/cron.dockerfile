FROM php:8.0-fpm-alpine

RUN apk add --no-cache \
    php8-bcmath \
    git \
    curl \
    libzip-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libexif-dev

RUN docker-php-ext-install pdo pdo_mysql bcmath zip exif

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY docker-compose/crontab /etc/crontabs/root

CMD ["crond", "-f"]
