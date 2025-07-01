FROM php:8.2-apache

# 1. Install system requirements
RUN apt-get update && apt-get install -y \
    git zip unzip libicu-dev \
    && docker-php-ext-install intl \
    && a2enmod rewrite

# 2. Configure environment
WORKDIR /var/www/html
COPY . .

# 3. Set permissions
RUN mkdir -p writable/{logs,cache,sessions} && \
    chmod -R 755 writable && \
    chown -R www-data:www-data writable

# 4. Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/local/bin --filename=composer

# 5. Generate encryption key if missing
RUN if [ -z "$(grep '^encryption.key' .env)" ]; then \
    php spark key:generate >> .env; \
    fi

# 6. Install dependencies
RUN composer install --no-dev --ignore-platform-reqs

# 7. Apache configuration
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri \
    -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' \
    -e 's!AllowOverride None!AllowOverride All!g' \
    /etc/apache2/sites-available/*.conf

EXPOSE 80
CMD ["apache2-foreground"]
