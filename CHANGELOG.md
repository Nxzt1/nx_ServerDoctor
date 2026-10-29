# Cambios

## Próxima versión

- El paquete que se publica lleva el código del servidor minificado para su publicación (config.lua se deja legible); protege la autoría sin cambiar el funcionamiento.
- Imágenes de ítems en ESX sin ox_inventory: lee la lista de ítems de es_extended y busca <nombre>.png en el inventario de `Config.Images.esxInventories` (por defecto esx_inventoryhud).
- Autoría de Nxsty y nueva licencia de uso gratuito: se puede usar sin coste, pero no vender, resubir ni redistribuir. Sustituye a la licencia MIT.

- Integrado el panel visual dentro de `NX_ServerDoctor`: ahora basta instalar un recurso y `/nxcheck` abre el informe para el administrador que lo pidió.
- El panel usa HTML/CSS/JavaScript locales, sin librerías, dependencias, temporizadores ni sondeos; `/nxcheck chat` conserva el informe en texto.
- El panel solo pide el foco después de dibujar el informe sin errores; si el dibujo falla, se cierra sin capturar el ratón.
- El informe llega al panel por evento latente (`Config.UiBps`), para que los informes grandes no saturen la conexión del jugador.
- Si la revisión entera falla, el administrador recibe un aviso y el comando no se queda bloqueado en "revisión en curso".
- Añadida la comprobación `rutasnui` para localizar rutas literales a recursos o archivos NUI inexistentes, incluidos aliases `provide` y extensiones de imagen alternativas.
- La comprobación solo lee archivos declarados y no sensibles mediante `LoadResourceFile`; está limitada y se puede desactivar o silenciar por recurso.
- Mejorado el aviso de imágenes cuando `inventory:imagepath` apunta a un alias `provide`; detecta también imágenes con extensión `.webp`, `.png` o `.jpg` alternativa.
- `/nxcheck` incluye ahora la revisión de imágenes para que el informe completo cubra todas las comprobaciones activas; la revisión automática al iniciar sigue siendo ligera.
- `rendimiento` muestra hasta cinco candidatos priorizados por patrones estáticos del código y explica por qué conviene medirlos con profiler/resmon; no inventa cifras de CPU.

## 1.0.0 — 2026-10-29

Primera versión.

- Comando `/nxcheck` con permiso ACE comprobado en el servidor, tiempo de espera por administrador y salida por chat (por páginas) o consola.
- Revisión opcional una sola vez al iniciar, solo en la consola.
- Comprobaciones: `dependencias`, `manifiestos`, `permisos`, `framework` (QBox, QBCore, ESX o independiente), `imagenes` (bajo demanda) y `rendimiento` (solo explica cómo medir).
- Gravedades `error`, `advertencia` e `información`, con ubicación relativa, explicación y pasos.
- Límites por revisión y trabajo repartido en tramos cortos.
- Nueva comprobación `erroreslog`: revisa hasta 2 MB del registro `fxserver.log` de txAdmin bajo demanda y muestra errores conocidos con recurso y línea.
