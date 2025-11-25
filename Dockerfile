# Multi-stage build para optimizar el tamaño de la imagen

# Stage 1: Builder - Instalar dependencias y compilar assets
FROM php:8.2-fpm AS builder

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libicu-dev \
    zip \
    unzip \
    nodejs \
    npm

# Limpiar cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Instalar extensiones PHP
RUN docker-php-ext-configure intl \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd intl

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Establecer directorio de trabajo
WORKDIR /var/www/html

# Copiar toda la aplicación primero
COPY . .

# Copiar archivo de entorno de producción
COPY .env.production .env

# Instalar dependencias de PHP
RUN composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist

# Instalar dependencias de Node
RUN npm ci

# Compilar assets para producción
RUN npm run build

# Verificar que el manifest.json se haya creado
RUN test -f public/build/manifest.json || (echo "ERROR: manifest.json no se generó" && exit 1)

# Stage 2: Production - Imagen final
FROM php:8.2-fpm

# Instalar dependencias del sistema necesarias para producción
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libicu-dev \
    nginx \
    supervisor \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Instalar extensiones PHP
RUN docker-php-ext-configure intl \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd intl

# Establecer directorio de trabajo
WORKDIR /var/www/html

# Copiar archivos desde el builder
COPY --from=builder /var/www/html /var/www/html

# Copiar configuración de Nginx
COPY docker/nginx/default.conf /etc/nginx/sites-available/default

# Copiar script de entrypoint
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Copiar configuración de supervisor
COPY docker/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Configurar permisos
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
RUN chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Exponer puerto
EXPOSE 80

# Entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
