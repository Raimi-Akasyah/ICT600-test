FROM php:8.2-apache
WORKDIR /var/www/html
COPY . .
RUN apt-get update && apt-get install -y git zip unzip && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    composer install --no-dev && \
    cp env .env && \
    php spark key:generate && \
    chmod -R 755 writable
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
EXPOSE 80
CMD ["apache2-foreground"]
