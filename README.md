# SGCS - Sistema de Gestión y Control de Servicios

Sistema de gestión y control de servicios desarrollado con Laravel 12, diseñado para la administración integral de servicios odontológicos.

## 🚀 Stack Tecnológico

- **Backend**: Laravel 12 (PHP 8.2+)
- **Frontend**: Vite + Tailwind CSS + DaisyUI + Alpine.js
- **Base de datos**: MySQL 8.0
- **Autenticación**: Laravel Breeze con 2FA (Google2FA)

## 📋 Requisitos

- PHP 8.2 o superior
- Composer
- Node.js 18+ y NPM
- MySQL 8.0+ (servidor externo para producción)
- Docker (para deployment)

## 🛠️ Instalación Local

### 1. Clonar el repositorio
```bash
git clone <repository-url>
cd SGCS-PROJECT
```

### 2. Instalar dependencias
```bash
# Dependencias de PHP
composer install

# Dependencias de Node
npm install
```

### 3. Configurar variables de entorno
```bash
# Copiar archivo de ejemplo
cp .env.example .env

# Generar key de la aplicación
php artisan key:generate
```

### 4. Configurar base de datos
Edita el archivo `.env` con tus credenciales de MySQL:
```env
DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=sgcs
DB_USERNAME=root
DB_PASSWORD=
```

### 5. Ejecutar migraciones
```bash
php artisan migrate
```

### 6. Iniciar servidor de desarrollo
```bash
# Terminal 1: Servidor Laravel
php artisan serve

# Terminal 2: Compilador de assets
npm run dev
```

La aplicación estará disponible en: `http://localhost:8000`

## 🐳 Deployment con Docker

### Construcción de la imagen

```bash
# Construir imagen Docker
docker build -t sgcs-app .
```

### Ejecutar con Docker Compose

```bash
# Iniciar contenedor
docker-compose up -d

# Ver logs
docker-compose logs -f app

# Detener contenedor
docker-compose down
```

### Variables de entorno para producción

Crea un archivo `.env` basado en `.env.production.example` y configura:

```env
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:tu-key-generada
APP_URL=https://tu-dominio.com

# Base de datos externa
DB_HOST=tu-servidor-mysql.com
DB_DATABASE=sgcs
DB_USERNAME=tu_usuario
DB_PASSWORD=tu_password

# Configuración de correo
MAIL_HOST=smtp.gmail.com
MAIL_USERNAME=tu-email@gmail.com
MAIL_PASSWORD="tu-password-de-aplicacion"
```

## 🌐 Deployment en Render

### 1. Preparar repositorio
Asegúrate de que todos los archivos Docker estén en tu repositorio Git.

### 2. Crear nuevo Web Service en Render
- Conecta tu repositorio
- Selecciona "Docker" como entorno
- Configura las variables de entorno necesarias

### 3. Variables de entorno en Render
Configura estas variables en el dashboard de Render:
```
APP_KEY=base64:tu-key-generada
APP_ENV=production
APP_DEBUG=false
APP_URL=https://tu-app.onrender.com
DB_HOST=tu-servidor-mysql
DB_DATABASE=sgcs
DB_USERNAME=usuario
DB_PASSWORD=password
```

### 4. Deploy
Render detectará automáticamente el `Dockerfile` y construirá la imagen.

## 📦 Comandos Útiles

### Desarrollo
```bash
# Compilar assets para desarrollo
npm run dev

# Compilar assets para producción
npm run build

# Limpiar caché
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
```

### Docker
```bash
# Reconstruir imagen
docker-compose build --no-cache

# Ejecutar comandos dentro del contenedor
docker-compose exec app php artisan migrate

# Ver logs en tiempo real
docker-compose logs -f app
```

## 🔒 Seguridad

- Asegúrate de cambiar `APP_KEY` en producción
- Nunca subas el archivo `.env` al repositorio
- Usa contraseñas seguras para la base de datos
- Configura correctamente los permisos de `storage` y `bootstrap/cache`

## 📝 Licencia

Este proyecto es propietario y confidencial.

## 👥 Soporte

Para soporte técnico, contacta al equipo de desarrollo.
