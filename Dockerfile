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

# Create writable directory if missing
RUN mkdir -p writable && chmod -R 755 writable

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Handle environment setup
RUN if [ -f "env" ]; then \
    cp env .env && \
    php spark key:generate; \
    else \
    echo "No env file found"; \
    fi

# Install dependencies (ignore platform reqs)
RUN composer install --no-dev --ignore-platform-req=ext-intl

# Apache config
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
EXPOSE 80
CMD ["apache2-foreground"]
