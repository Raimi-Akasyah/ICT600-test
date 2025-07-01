FROM php:8.2-apache

# 1. Install system dependencies
RUN apt-get update && apt-get install -y \
    git zip unzip libicu-dev \
    && rm -rf /var/lib/apt/lists/*

# 2. Install PHP extensions
RUN docker-php-ext-install intl && docker-php-ext-enable intl

# 3. Configure Apache
WORKDIR /var/www/html
COPY . .

# 4. Create required directories
RUN mkdir -p writable/{logs,cache,sessions} \
    && chmod -R 755 writable \
    && chown -R www-data:www-data writable

# 5. Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/local/bin --filename=composer

# 6. Handle environment setup
RUN if [ ! -f ".env" ]; then \
    if [ -f "env" ]; then \
        cp env .env; \
    else \
        echo "app.baseURL = 'http://localhost:8080/'" > .env; \
    fi; \
    php spark key:generate; \
    fi

# 7. Install dependencies
RUN composer install --no-dev --ignore-platform-reqs

# 8. Final Apache config
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN a2enmod rewrite \
    && sed -ri \
    -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' \
    -e 's!AllowOverride None!AllowOverride All!g' \
    /etc/apache2/sites-available/*.conf \
    /etc/apache2/apache2.conf

EXPOSE 80
CMD ["apache2-foreground"]
