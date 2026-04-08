FROM php:8.2-cli

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    nodejs \
    npm \
    ruby \
    ruby-bundler \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir docker>=7.0.0

COPY api/composer.json /var/www/api/composer.json
RUN composer install --no-dev --optimize-autoloader --no-interaction

COPY api /var/www/api

WORKDIR /var/www/api

EXPOSE 8080

CMD ["php", "-S", "0.0.0.0:8080", "-t", "public"]
