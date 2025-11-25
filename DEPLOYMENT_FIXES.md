# ✅ Correcciones Aplicadas al Proyecto SGCS

**Fecha**: 25 de noviembre de 2025  
**Objetivo**: Corregir problemas de permisos y configuración HTTPS para despliegue en Render

---

## 📋 Resumen de Cambios Aplicados

### ✅ 1. AppServiceProvider.php
**Archivo modificado**: `app/Providers/AppServiceProvider.php`

**Cambios aplicados**:
- ✅ Agregado forzado de HTTPS en producción con `URL::forceScheme('https')`
- ✅ Configurado trusted proxies para Render con `Request::setTrustedProxies()`
- ✅ Incluidos todos los headers de forwarding necesarios

**Código añadido**:
```php
use Illuminate\Support\Facades\URL;
use Illuminate\Http\Request;

public function boot(): void
{
    // Forzar HTTPS en producción
    if (config('app.env') === 'production') {
        URL::forceScheme('https');
    }

    // Confiar en proxies (Render, Nginx reverse proxy)
    Request::setTrustedProxies(
        ['*'],
        Request::HEADER_X_FORWARDED_FOR |
        Request::HEADER_X_FORWARDED_HOST |
        Request::HEADER_X_FORWARDED_PORT |
        Request::HEADER_X_FORWARDED_PROTO
    );
}
```

---

### ✅ 2. Nginx Configuration
**Archivo modificado**: `docker/nginx/default.conf`

**Cambios aplicados**:
- ✅ Headers de seguridad mejorados con `always` flag
- ✅ Agregado header `X-XSS-Protection`
- ✅ Configuración de proxy inverso con `real_ip_header` y `set_real_ip_from`
- ✅ Parámetros FastCGI para correcta detección de HTTPS

**Código añadido**:
```nginx
# Headers de seguridad
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;

# Configuración para proxies (Render)
real_ip_header X-Forwarded-For;
set_real_ip_from 0.0.0.0/0;

# En location ~ \.php$
fastcgi_param HTTPS $https if_not_empty;
fastcgi_param HTTP_SCHEME $scheme;
fastcgi_param SERVER_PORT $server_port;
```

---

### ✅ 3. Variables de Entorno de Sesión
**Archivos modificados**:
- `.env` (desarrollo)
- `.env.production` (producción)
- `.env.example` (documentación)

**Cambios aplicados**:
- ✅ Agregada variable `SESSION_SECURE_COOKIE=false` en desarrollo
- ✅ Agregada variable `SESSION_SECURE_COOKIE=true` en producción
- ✅ Documentadas variables adicionales de sesión

**Variables agregadas**:
```env
# Desarrollo (.env)
SESSION_SECURE_COOKIE=false

# Producción (.env.production)
SESSION_SECURE_COOKIE=true
SESSION_HTTP_ONLY=true
SESSION_SAME_SITE=lax
```

---

## 🔍 Archivos Verificados (Sin cambios necesarios)

### ✅ docker/supervisor/supervisord.conf
- Ya tiene `user=root` configurado correctamente
- No requiere cambios

### ✅ docker/entrypoint.sh
- Permisos configurados correctamente con `chown -R www-data:www-data`
- Incluye validación de manifest.json
- No requiere cambios

### ✅ Dockerfile
- Permisos establecidos correctamente en el stage de producción
- Usuario `www-data` usado apropiadamente
- No requiere cambios

### ✅ config/session.php
- Ya referencia correctamente `env('SESSION_SECURE_COOKIE')`
- No requiere cambios

---

## 🚀 Configuración Requerida en Render

### Variables de Entorno Críticas

Asegúrate de configurar estas variables en el dashboard de Render:

```env
# Aplicación
APP_ENV=production
APP_KEY=base64:Mf64otqQKGdFHjG+HzvQqZTtdRX9snidB4Nu+Y4d9zU=
APP_DEBUG=false
APP_URL=https://sgcs-project-2sb9.onrender.com

# Seguridad de Sesiones (CRÍTICO)
SESSION_SECURE_COOKIE=true
SESSION_HTTP_ONLY=true
SESSION_SAME_SITE=lax

# Base de Datos (Railway)
DB_CONNECTION=mysql
DB_HOST=ballast.proxy.rlwy.net
DB_PORT=54963
DB_DATABASE=railway
DB_USERNAME=root
DB_PASSWORD=LdUdxxXNLDsUCQUdHjpRcCfvyxkdBRhe

# Correo (Actualiza con tus credenciales)
MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=tu-email@gmail.com
MAIL_PASSWORD=tu-app-password-de-16-caracteres
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=tu-email@gmail.com
MAIL_FROM_NAME="Sistema SGCS"
```

---

## ⚠️ Problemas Comunes y Soluciones

### 1. Error: "The page isn't redirecting properly"
**Causa**: Loop de redirección HTTPS  
**Solución**: Verificar que `SESSION_SECURE_COOKIE=true` esté configurado en Render

### 2. Error: "CSRF token mismatch"
**Causa**: Cookies no se guardan correctamente  
**Solución**: Verificar configuración de trusted proxies en `AppServiceProvider`

### 3. Error: "403 Forbidden" en rutas
**Causa**: Permisos incorrectos en storage  
**Solución**: El `entrypoint.sh` ya ejecuta `chown -R www-data:www-data`

### 4. Assets no cargan (404 en CSS/JS)
**Causa**: Manifest.json no se generó  
**Solución**: El `Dockerfile` y `entrypoint.sh` ya validan esto

---

## 🔐 Seguridad del Correo Electrónico

### ⚠️ IMPORTANTE: Actualizar Credenciales de Correo

El archivo `.env.production` actualmente tiene credenciales del correo `arludenttacna@gmail.com`. 

**Recomendaciones**:

1. **Si sigues usando Gmail**:
   - Ve a https://myaccount.google.com/security
   - Activa verificación en dos pasos
   - Genera una "App Password" (contraseña de aplicación)
   - Usa esa contraseña de 16 caracteres en `MAIL_PASSWORD`

2. **Si cambias de correo**:
   - Actualiza `MAIL_USERNAME` con el nuevo correo
   - Actualiza `MAIL_FROM_ADDRESS` con el nuevo correo
   - Genera nueva app password y actualiza `MAIL_PASSWORD`
   - Actualiza `MAIL_FROM_NAME` si lo deseas

3. **Para desarrollo/pruebas**:
   - Opción 1: Usa `MAIL_MAILER=log` en `.env` local
   - Opción 2: Usa Mailtrap (https://mailtrap.io):
     ```env
     MAIL_MAILER=smtp
     MAIL_HOST=smtp.mailtrap.io
     MAIL_PORT=2525
     MAIL_USERNAME=tu_user_mailtrap
     MAIL_PASSWORD=tu_pass_mailtrap
     ```

---

## 📝 Comandos Post-Despliegue

Después de hacer deploy en Render, verifica:

```bash
# Conectarte por SSH a Render (si está habilitado) o ver logs
# y verificar que no haya errores

# Limpiar caché (ya se hace en entrypoint.sh)
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Verificar migraciones (ya se hace en entrypoint.sh)
php artisan migrate --force
```

---

## ✅ Checklist Final

Antes de hacer push a Render, verifica:

- [x] AppServiceProvider.php tiene configuración HTTPS y trusted proxies
- [x] nginx default.conf tiene headers de seguridad y proxy config
- [x] .env.production tiene SESSION_SECURE_COOKIE=true
- [x] Variables de entorno configuradas en Render dashboard
- [ ] Credenciales de correo actualizadas (si es necesario)
- [ ] APP_KEY generada y configurada en Render
- [ ] Base de datos accesible desde Render (Railway)
- [ ] .env.production NO está en .gitignore (se copia en Dockerfile)
- [ ] Dockerfile copia .env.production a .env

---

## 🔄 Proceso de Deploy en Render

1. **Commit y Push**:
   ```bash
   git add .
   git commit -m "fix: Aplicar correcciones de HTTPS y seguridad para Render"
   git push origin main
   ```

2. **Render Auto-Deploy**:
   - Render detectará el push
   - Construirá la imagen Docker
   - Ejecutará entrypoint.sh
   - Iniciará PHP-FPM + Nginx

3. **Verificar Deploy**:
   - Accede a https://sgcs-project-2sb9.onrender.com
   - Verifica que HTTPS funcione correctamente
   - Prueba login y sesiones
   - Verifica que no haya errores 403/404

---

## 📞 Soporte Adicional

Si encuentras errores después del deploy:

1. Revisa los logs en Render Dashboard
2. Verifica las variables de entorno en Render
3. Confirma que la base de datos Railway esté accesible
4. Verifica que el dominio APP_URL coincida con el dominio de Render

---

## 📚 Referencias

- [Laravel 11 HTTPS Configuration](https://laravel.com/docs/11.x/urls#forcing-https)
- [Laravel Trusted Proxies](https://laravel.com/docs/11.x/requests#configuring-trusted-proxies)
- [Nginx Configuration for Laravel](https://laravel.com/docs/11.x/deployment#nginx)
- [Render Deployment Guide](https://render.com/docs/deploy-laravel)

---

**Última actualización**: 2025-11-25  
**Estado**: ✅ Correcciones aplicadas y listas para deploy
