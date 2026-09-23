FROM php:8.2-apache

RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev \
    zip unzip git \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql mysqli \
    && a2enmod rewrite

WORKDIR /var/www/html
RUN echo "<?php phpinfo(); ?>" > /var/www/html/index.php
RUN chown -R www-data:www-data /var/www/html
