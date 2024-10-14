# Phase 1: Install PHP dependencies
FROM composer:2.0 AS composer
WORKDIR /app

COPY composer.json composer.lock /app/
RUN composer install --no-scripts --no-autoloader --prefer-dist --ignore-platform-reqs --no-interaction --no-plugins

# Phase 2: Build frontend assets
FROM node:14.15.0 AS node
WORKDIR /app

COPY package.json package-lock.json /app/
RUN npm install
COPY resources/ /app/resources/
COPY public/ /app/public/

# Phase 3: Final image with PHP and frontend assets
FROM php:8.2-fpm

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    git \
    libzip-dev \
    unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql zip

# Install and enable Xdebug
RUN pecl install xdebug-3.3.2 && docker-php-ext-enable xdebug

# Download and install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

# Set the working directory
WORKDIR /app

# Copy PHP dependencies from Composer phase
COPY --from=composer /app/vendor /app/vendor

# Copy remaining application files
COPY . .

# Copy frontend assets from Node phase
COPY --from=node /app/public/assets/js /app/public/js
COPY --from=node /app/public/assets/css /app/public/css
COPY --from=node /app/public/mix-manifest.json /app/mix-manifest.json

# Ensure storage directories are accessible
RUN chown -R www-data:www-data /app/storage /app/bootstrap/cache

# Copy the entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose port 9000
EXPOSE 9000

# Default command to run Laravel server
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=9000"]
