FROM php:8.2-apache

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    git \
    zip \
    unzip \
    libicu-dev \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl \
    && docker-php-ext-enable intl

# Configure Apache
WORKDIR /var/www/html
COPY . .

# Set permissions (skip if 'writable' doesn't exist)
RUN if [ -d "writable" ]; then chmod -R 755 writable; fi

# Install Composer and dependencies
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer install --no-dev --ignore-platform-req=ext-intl \
    && cp env .env \
    && php spark key:generate

# Apache config
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
EXPOSE 80
CMD ["apache2-foreground"]
