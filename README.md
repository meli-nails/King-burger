# King Burger — tienda online y gestión de pedidos

Proyecto independiente. Frontend estático en HTML, CSS y JavaScript embebidos; backend Supabase Edge Functions + PostgreSQL.

## URLs

- Tienda: https://meli-nails.github.io/King-burger/
- Panel: https://meli-nails.github.io/King-burger/admin.html
- Seguimiento: https://meli-nails.github.io/King-burger/seguimiento.html
- Repartidores: https://meli-nails.github.io/King-burger/delivery.html
- Repositorio: https://github.com/meli-nails/King-burger

## Estructura

- `index.html`: catálogo, categorías, personalización, extras, carrito y checkout.
- `admin.html`: autenticación y panel de gestión.
- `seguimiento.html`: consulta privada por token, mapa de entrega y posición del repartidor.
- `delivery.html`: panel privado de repartidores, asignación de entregas, navegación y transmisión GPS.
- `supabase/functions/store-api/index.ts`: catálogo, zonas, creación de pedidos, cálculo transaccional, rate limiting, seguimiento y notificación.
- `supabase/functions/admin-api/index.ts`: autenticación administrativa, dashboard, pedidos, repartidores, asignaciones, productos, categorías, zonas y configuración.
- `supabase/functions/delivery-api/index.ts`: autenticación de repartidores, toma de pedidos, estados de entrega y GPS en vivo.
- `supabase/functions/addon-api/index.ts`: grupos y opciones de adicionales.
- `supabase/config.toml`: configuración de Supabase CLI.
- Supabase Storage bucket público `product-images`: el panel permite subir fotos JPG/PNG/WebP/AVIF hasta 5 MB; la lectura de imágenes es pública y las cargas requieren una sesión de administrador activo.
- `database/bootstrap.sql`: snapshot SQL para reconstruir el esquema en un proyecto Supabase NUEVO.
- `database/link-owner.sql`: vinculación idempotente de la cuenta propietaria.
- `scripts/check-syntax.mjs`: validación de sintaxis JavaScript de las cuatro páginas HTML.

Los estilos y scripts de las páginas permanecen embebidos en sus HTML.

## Proyecto Supabase conectado

- Nombre: `king-burger`
- Project ref: `fruuhaoszcdrknrmrpgh`
- Región: `sa-east-1`
- URL: `https://fruuhaoszcdrknrmrpgh.supabase.co`

Los HTML contienen solo la clave pública `sb_publishable_...`. Las claves secretas nunca se guardan en el repositorio ni en el navegador. Las Edge Functions usan los secretos inyectados por Supabase.

## Estado de producción al 27/11/2026

- Las funciones `store-api`, `admin-api` y `addon-api` están desplegadas y activas en el proyecto vinculado.
- La base tiene 14 tablas, RLS habilitado, políticas administrativas y funciones PostgreSQL para alta segura de pedidos y límites de peticiones.
- La tabla privada `delivery_drivers` habilita cuentas Auth separadas para el personal de reparto; las ubicaciones del cliente y del repartidor se guardan en `orders` y solo se devuelven mediante el token privado o la API autenticada.
- La cuenta Auth propietaria existente está vinculada en `public.admins` con rol `owner` y habilitada.
- Se cargaron las categorías iniciales: Hamburguesas, Combos, Acompañamientos y Bebidas.
- No se inventaron productos, precios, zonas, tarifas, teléfono, correo ni datos bancarios.
- El local permanece cerrado (`is_open=false`) hasta completar la configuración.

## Configuración comercial obligatoria antes de abrir

1. Ingresar al panel y acceder con la cuenta propietaria de Supabase Auth.
2. En Configuración, cargar WhatsApp internacional (solo dígitos), correo receptor, pedido mínimo y datos de transferencia que correspondan.
3. En Productos, cargar el menú real, precios, descripciones e imágenes.
4. En Zonas de delivery, cargar los barrios cubiertos y sus tarifas/tiempos reales.
5. En Extras, crear grupos y asociar opciones a cada producto.
6. En Productos, elegí la imagen desde el dispositivo; el panel la sube a Supabase Storage, muestra una vista previa y guarda su URL al guardar el producto.
6. Revisar la tienda como cliente. Abrir el negocio desde Configuración solo cuando todo esté correcto.

No se deben aceptar pedidos hasta que existan por lo menos un producto disponible y una zona activa.

## Imágenes de productos

El panel sube las imágenes al bucket público `product-images` de Supabase Storage. El bucket limita el tamaño a 5 MB y acepta JPEG, PNG, WebP y AVIF. Las descargas públicas sirven las imágenes del catálogo; la política de Storage permite cargar archivos únicamente a usuarios autenticados con una fila activa en `public.admins`. El nombre del objeto es aleatorio y no depende del nombre del archivo original.

## Notificaciones

### WhatsApp

Después de guardar el pedido, la página genera un enlace `wa.me` con el mensaje preparado. El cliente debe abrir WhatsApp y pulsar Enviar; no es un envío automático.

### Correo

El backend está preparado para Resend. Para activar los correos, configurar en Supabase → Edge Functions → Secrets:

- `RESEND_API_KEY`: secreto privado de Resend.
- `EMAIL_FROM`: remitente verificado en Resend, por ejemplo `King Burger <pedidos@tu-dominio.com>`.

El correo de destino se toma del campo de contacto guardado en el panel. No se incluyen credenciales de Resend en el paquete.

## Despliegue y mantenimiento

### GitHub Pages

El repositorio ya tiene sus páginas HTML en la raíz y `.nojekyll`. En GitHub → Settings → Pages, la fuente debe ser la rama `main` y la carpeta `/ (root)`.

### Supabase CLI

Con la CLI instalada y autenticada:

```bash
supabase login
supabase link --project-ref fruuhaoszcdrknrmrpgh
supabase functions deploy store-api
supabase functions deploy admin-api
supabase functions deploy addon-api
supabase functions deploy delivery-api
```

La configuración local mantiene `verify_jwt=false` para las tres funciones. Es intencional: las claves nuevas `sb_publishable`/`sb_secret` no son JWT. La tienda usa clave pública; las APIs administrativas comprueban el JWT de usuario y la fila activa en `public.admins` dentro del código.

### Reconstruir en un proyecto Supabase nuevo

Abrir SQL Editor del proyecto vacío y ejecutar `database/bootstrap.sql` una sola vez. Luego confirmar que el usuario de Supabase Auth existe y ejecutar `database/link-owner.sql` si se quiere vincular otro correo. No ejecutar el bootstrap sobre la base de producción ya creada.

## Seguridad

- Totales del navegador no son confiables: PostgreSQL recalcula producto, extras y delivery a partir de los registros vigentes.
- Alta de pedido, líneas, adicionales e historial se ejecutan en una transacción.
- Idempotencia evita pedidos duplicados por reintentos.
- Se almacena el hash SHA-256 del token de seguimiento, no el token en texto plano.
- El endpoint de seguimiento no expone nombre, teléfono ni dirección.
- RLS está activo y las tablas de pedidos no permiten lectura pública directa.
- El panel requiere JWT válido y una fila activa en `public.admins`.
- El panel de repartidores requiere JWT válido y una fila activa en `public.delivery_drivers`; las coordenadas nunca se exponen mediante una tabla pública.
- El cliente recibe la posición mediante Broadcast en un canal con nombre derivado del hash del token privado de seguimiento.
- Los estados de pedido siguen transiciones autorizadas y quedan registrados en el historial.

## Pruebas y límites de verificación

- La estructura de base y las tres funciones activas se verificaron contra el proyecto Supabase vinculado.
- Se verificó el vínculo de la cuenta owner y la carga de las cuatro categorías.
- La comprobación de sintaxis local está disponible con `npm test`.
- No se completó una compra real en navegador porque aún no hay productos ni zonas comerciales cargadas. Antes de abrir el negocio debe hacerse una compra de prueba con datos propios y verificarse panel, notificación y tracking.
- Supabase Security Advisor reportó una advertencia: activar la protección de contraseñas filtradas en Auth → Attack Protection. Referencia: https://supabase.com/docs/guides/auth/password-security#password-strength-and-leaked-password-protection

## Nota de credenciales

La contraseña de la cuenta propietaria se debe mantener privada. Como se compartió una contraseña en el chat durante la preparación, conviene reemplazarla desde Supabase Auth por una contraseña única, larga y no reutilizada antes de operar.
