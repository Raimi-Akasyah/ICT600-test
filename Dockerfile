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

# Configure Apache and permissions
WORKDIR /var/www/html
COPY . .
RUN chmod -R 755 writable

# Install Composer and dependencies (ignore platform reqs temporarily)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer install --no-dev --ignore-platform-req=ext-intl \
    && cp env .env \
    && php spark key:generate

# Apache config
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
EXPOSE 80
CMD ["apache2-foreground"]
