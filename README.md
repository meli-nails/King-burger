# King Burger — tienda online

Proyecto independiente de Meli Nails. Aplicación estática en HTML/CSS/JavaScript, con backend Supabase.

## Contenido

- `index.html`: tienda, catálogo, personalización, carrito y checkout.
- `seguimiento.html`: seguimiento mediante token privado.
- `admin.html`: panel con autenticación Supabase Auth y gestión de pedidos, productos, categorías, zonas y datos del negocio.
- `supabase/functions/store-api`: catálogo público, zonas, alta segura de pedidos, cálculo mediante PostgreSQL, rate limit, seguimiento privado, enlace de WhatsApp y correo mediante Resend.
- `supabase/functions/admin-api`: API administrativa con validación de sesión y rol.
- `supabase/functions/addon-api`: creación y baja lógica de grupos y opciones de extras con autenticación administrativa.
- `supabase/config.toml`: configuración de funciones.
- `vercel.json`: cabeceras de seguridad para hosting estático.

## Supabase asociado

- Proyecto: `king-burger`
- Project ref: `fruuhaoszcdrknrmrpgh`
- Región: `sa-east-1` (São Paulo)
- URL: `https://fruuhaoszcdrknrmrpgh.supabase.co`
- API pública: publishable key configurada en los HTML.

La clave `sb_publishable_...` es una clave pública. **Nunca agregar una `sb_secret_...` ni `service_role` a los HTML.** Las funciones Edge utilizan el secreto del entorno de Supabase y la base bloquea lectura anónima de `orders`.

## Primer inicio

1. En Supabase → Authentication → Users, crear el usuario administrador con email y contraseña.
2. Copiar el UUID de ese usuario.
3. En SQL Editor ejecutar `admin-bootstrap.sql` reemplazando `UUID_DEL_USUARIO` por el UUID real.
4. Abrir `admin.html`, iniciar sesión y configurar WhatsApp, correo, alias/CBU y mínimo de compra.
5. Crear categorías, productos y zonas de delivery.
6. Crear grupos y opciones de adicionales desde Admin → Extras y asignarlos a los productos correspondientes.
7. Marcar el local como abierto solo después de completar la configuración.

La base de datos empieza sin productos ni zonas. El local se deja cerrado (`is_open=false`) intencionalmente para evitar pedidos incompletos.

## Notificaciones

### WhatsApp

En Configuración, guardar el número del negocio en formato internacional con dígitos, sin espacios ni símbolos. El sistema crea un enlace `wa.me` con el pedido listo para enviar. El mensaje **no se envía automáticamente**: el usuario debe abrir WhatsApp y pulsar Enviar.

### Correo electrónico

El backend está preparado para Resend. En Supabase → Edge Functions → Secrets agregar:

- `RESEND_API_KEY`: clave privada de Resend.
- `EMAIL_FROM`: remitente verificado en Resend, por ejemplo `King Burger <pedidos@tu-dominio.com>`.

En el panel, guardar el correo de destino del negocio. El pedido se guarda aunque el proveedor de correo falle; la respuesta informa el estado del envío. No hay credenciales de correo incluidas en este paquete.

## Publicación web

El contenido es estático. Publicar la carpeta raíz del proyecto en Vercel (o en otro hosting estático compatible). La raíz debe contener `index.html`, `admin.html` y `seguimiento.html`. No hace falta Node.js en producción para las páginas.

Las Edge Functions `store-api`, `admin-api` y `addon-api` ya están desplegadas en el proyecto Supabase asociado. En `supabase/config.toml` se declara `verify_jwt = false`: `store-api` es pública; `admin-api` y `addon-api` validan la sesión y los permisos dentro de su propio código. No desactivar esa validación interna.

## Seguridad y reglas de negocio

- Los totales enviados por el navegador no se consideran confiables.
- PostgreSQL vuelve a obtener precios, adicionales y tarifa de envío desde sus tablas antes de guardar el pedido.
- `create_order_secure` crea orden, líneas, adicionales y primer evento de historial en una transacción.
- La clave de idempotencia evita duplicados por reintentos; el token privado se guarda como SHA-256, no en texto plano.
- El seguimiento solo devuelve estado, productos e importes; no expone nombre, teléfono ni dirección.
- `orders`, líneas de pedido y datos operativos no son consultables desde `anon` ni desde `authenticated` directamente.
- El panel usa Supabase Auth y exige una fila activa en `public.admins`.
- Los cambios de estado respetan el flujo permitido y se registran en el historial.

## Estado conocido / tareas de configuración

- El menú y las zonas deben cargarse desde el panel antes de aceptar pedidos.
- Se debe crear la primera cuenta owner con `admin-bootstrap.sql`.
- Correo automático necesita configurar los dos secretos de Resend.
- La publicación del sitio estático en Vercel todavía debe realizarse desde la cuenta del propietario; este entorno no tiene conexión de despliegue a Vercel.
- No se creó un repositorio GitHub porque la integración disponible no ofrece crear repositorios y los repos existentes visibles pertenecen a Meli Nails. No se escribieron en ellos.

## Pruebas realizadas

- JavaScript inline de `index.html`, `seguimiento.html` y `admin.html`: comprobación sintáctica `node --check`.
- TypeScript de las tres funciones Edge: comprobación `tsc --noEmit` con tipos mínimos del runtime Deno.
- Prueba SQL transaccional: dos unidades de $10.000, extra de $500 por unidad y envío de $1.000 dieron total $22.000.
- Prueba de idempotencia: repetir la misma clave devolvió el mismo pedido (`idempotent_replay=true`). La transacción se revirtió y no dejó pedidos/productos/zonas de prueba.
- Auditoría de seguridad Supabase: sin hallazgos (lints vacíos). `api_rate_limits` tiene RLS activo y una policy explícita que deniega acceso a `anon` y `authenticated`.
- El asesor de rendimiento informa índices sin uso porque la base está vacía; los índices FK se conservan para las consultas cuando haya pedidos y catálogo.

La verificación de sintaxis y de SQL no sustituye una prueba completa desde un navegador contra una cuenta de administrador real y un catálogo configurado.
