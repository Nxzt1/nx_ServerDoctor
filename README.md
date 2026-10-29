# NX_ServerDoctor

Hecho por **Nxsty**. Gratis, pero no es de código abierto: lee la [licencia](LICENSE) antes de compartirlo.

Recurso gratuito​‌​​‌‌‌​​‌​‌‌​​​​‌​‌​​‌‌​‌​‌​‌​​​‌​‌‌​​‌ para servidores de FiveM que revisa la configuración y explica en lenguaje claro lo que está mal y cómo arreglarlo.

- **Solo lectura.** No cambia archivos, variables, permisos, recursos ni la base de datos. Nunca repara nada por su cuenta: te dice qué hacer y tú decides.
- **Sin conexiones externas.** No hace conexiones externas, no tiene telemetría ni analítica. El análisis de errores lee localmente el tramo configurado de `fxserver.log` y muestra mensajes saneados solo en el informe solicitado.
- **Sin dependencias externas.** No necesita framework, base de datos, ox_lib ni Node.js. El panel usa HTML, CSS y JavaScript locales.
- **Coste mínimo en reposo.** No tiene bucles ni temporizadores. La pequeña página NUI queda cargada, pero solo dibuja el informe al solicitarlo; las comprobaciones se ejecutan con `/nxcheck` o una vez al iniciar si lo dejas activado.

> **Nota:** el código del servidor viene minificado/ofuscado a propósito para proteger la autoría. Funciona igual, pero no está pensado para editarse. El único archivo que debes tocar es `config.lua`, que se deja legible. Si necesitas la versión legible por algún motivo, pídemela.

## Instalación

1. Copia la carpeta `NX_ServerDoctor` dentro de `resources` (en cualquier subcarpeta, por ejemplo `resources/[admin]/NX_ServerDoctor`).
2. Añade a `server.cfg`, **después** del resto de recursos para que la revisión al iniciar los encuentre ya arrancados:

   ```cfg
   ensure NX_ServerDoctor
   ```

3. Da permiso a tu grupo de administración (mira `permissions.example.cfg`):

   ```cfg
   add_ace group.admin nxdoctor.use allow
   ```

4. Reinicia el servidor o, en la consola del servidor ya encendido, ejecuta `refresh` y `ensure NX_ServerDoctor`.

## Comandos

| Comando | Qué hace |
|---|---|
| `/nxcheck` | Ejecuta la revisión completa y abre el panel visual. |
| `/nxcheck ui` | Ejecuta la revisión completa y abre el panel visual. |
| `/nxcheck chat` | Muestra el informe por el chat. |
| `/nxcheck <id>` | Ejecuta solo una comprobación, por ejemplo `/nxcheck imagenes`. |
| `/nxcheck lista` | Muestra las comprobaciones y si están activas. |
| `/nxcheck ver [página]` | Vuelve a mostrar el último informe (el chat va por páginas). |
| `/nxcheck consola` | Copia el último informe en la consola del servidor, para poder copiarlo y pegarlo. |
| `/nxcheck ayuda` | Muestra esta ayuda. |

En la consola del servidor (o en la de txAdmin) se escribe sin barra: `nxcheck`. La consola siempre tiene permiso y recibe el informe completo; en el chat se muestra por páginas de `Config.Chat.perPage` hallazgos.

`erroreslog` busca errores ya escritos por FXServer en el log de txAdmin; el informe completo lo incluye automáticamente. Si no encuentra el archivo, configura su ruta absoluta en `Config.LogAudit.path`. También puedes ejecutarlo por separado con `/nxcheck erroreslog`.

### Panel visual

El panel forma parte de `NX_ServerDoctor`: `/nxcheck` lo abre directamente, y `/nxcheck chat` conserva la salida de texto. Está hecho con HTML, CSS y JavaScript locales, sin React, dependencias externas, sondeos ni temporizadores. Reutiliza localmente la paleta y tipografía de NX; la fuente Oswald se incluye bajo su licencia OFL en `html/fonts/OFL.txt`. La página NUI permanece cargada en el cliente para poder abrirse, pero no mantiene trabajo activo en reposo.

## Permisos

El comando se registra sin restricción de FiveM y el propio recurso comprueba en el servidor, en cada uso, que quien lo pide tiene el permiso `Config.Permission.ace` (por defecto `nxdoctor.use`). El servidor envía el informe solo al administrador autorizado que lo solicitó; la NUI no tiene callbacks para ejecutar comprobaciones ni acciones del servidor.

```cfg
# Recomendado: solo tu grupo de administración
add_ace group.admin nxdoctor.use allow

# A una persona concreta (pon su identificador real en lugar del de ejemplo)
add_principal identifier.license:0000000000000000000000000000000000000000 group.admin
```

## Configuración

Todo está en `config.lua`, comentado. Lo más habitual:

| Opción | Por defecto | Para qué |
|---|---|---|
| `Config.Command` | `'nxcheck'` | Nombre del comando. |
| `Config.Permission.ace` | `'nxdoctor.use'` | Permiso ACE necesario. |
| `Config.Permission.principals` | `{ 'group.admin' }` | Grupos que deberían tenerlo (solo para avisarte si no lo tiene ninguno). |
| `Config.Detail` | `'normal'` | `'resumen'`, `'normal'` o `'completo'`. |
| `Config.UiBps` | `100000` | Bytes por segundo con los que se envía el informe al panel (evento latente). |
| `Config.RunOnStart` | `true` | Revisión automática una vez al iniciar, solo en la consola. |
| `Config.Checks.<id>` | ver archivo | `enabled`, `startup` y `full` para cada comprobación. |
| `Config.Frameworks` | QBox, QBCore, ESX | Nombre del recurso principal de cada framework, por si usas otro. |
| `Config.CheckDatabaseConvar` | `true` | Avisa si la conexión de oxmysql está vacía (ver Privacidad). |
| `Config.Images` | ver archivo | Carpetas de imágenes de inventarios estilo QBCore y de ESX, e ítems a ignorar. |
| `Config.NuiPaths` | `{ enabled = true, ignore = {} }` | Activa la comprobación de rutas `nui://` e ignora nombres de recursos concretos. |
| `Config.LogAudit` | ver archivo | Ruta y límites del `fxserver.log` de txAdmin que se revisa bajo demanda. |
| `Config.Limits` | ver archivo | Límites de recursos, archivos, imágenes y código analizado para la estimación de rendimiento. |
| `Config.Limits.maxPerformanceFiles` | `300` | Máximo de archivos `.lua`/`.js` que analiza la estimación estática de rendimiento por revisión. |
| `Config.UseIoForFileChecks` | `true` | Comprobar archivos abriéndolos sin leerlos (rápido) o con `LoadResourceFile` (lento). |
| `Config.SensitivePatterns` | ver archivo | Nombres de archivo que nunca se abren. |

## Comprobaciones

| Id | Qué revisa | Gravedad posible | Coste |
|---|---|---|---|
| `dependencias` | Dependencias de cada `fxmanifest.lua`: recursos que faltan, dependencias paradas de recursos iniciados, restricciones `/onesync`, `/server:N` y `/gameBuild:N`, y varios recursos iniciados que hacen `provide` del mismo nombre. | error, advertencia | Bajo: solo lee los metadatos que FiveM ya tiene en memoria. |
| `manifiestos` | Scripts, `files` y `ui_page` declarados que no existen; imports `@recurso/archivo` rotos o sin declarar como dependencia; `__resource.lua`, falta de `fx_version` o `game`, `fx_version` antigua y falta de `lua54 'yes'`. | error, advertencia, información | Medio: mira si existe cada archivo declarado (hasta `maxFilesPerResource` por recurso y `maxFileChecks` en total). |
| `permisos` | Si alguien tiene el permiso del recurso, si `builtin.everyone` (todos los jugadores) lo tiene, y si tiene `command` o comandos de administración como `quit`, `stop`, `exec`, `add_ace`... | error, advertencia | Muy bajo. |
| `framework` | Detecta QBox, QBCore o ESX. Avisa de varios frameworks instalados, recurso principal parado, dependencias del framework sin iniciar, QBox sin OneSync, `inventory:framework` de ox_inventory que no coincide y conexión de oxmysql vacía. | error, advertencia, información | Muy bajo. |
| `imagenes` | Ítems sin imagen en la carpeta del inventario; advierte si `inventory:imagepath` usa un nombre resuelto solo por `provide`. También detecta extensiones alternativas comunes. | advertencia, información | Más alto: revisa hasta `maxImageChecks` ítems. Se incluye en `/nxcheck` bajo demanda, pero no en el arranque automático. |
| `rendimiento` | Ordena hasta cinco recursos candidatos según patrones estáticos como `Wait(0/1)` junto a bucles, `setTick`/`setInterval` y dibujo frecuente. Explica por qué cada uno merece medirse. No afirma que sean los de mayor CPU real. | información | Bajo/medio: lee hasta `maxPerformanceFiles` archivos de código declarados con `LoadResourceFile`; solo corre bajo demanda. |
| `rutasnui` | Rutas literales `nui://` en archivos declarados por los manifiestos. Avisa si el recurso destino falta, solo existe mediante `provide` o si el archivo no existe; detecta alternativas `.png`, `.webp` y `.jpg`. | advertencia, información | Bajo/medio: lee bajo demanda archivos declarados `.lua`, `.js`, `.html`, `.htm` y `.css`, sujeto a los límites de recursos y archivos. |
| `erroreslog` | Busca errores de script y exports ausentes en el tramo reciente del `fxserver.log` de txAdmin. Agrupa duplicados y muestra recurso, archivo/línea y mensaje. | error, información | Bajo: lee hasta 2 MB al ejecutar `/nxcheck`; no se ejecuta al arrancar. |

### Gravedades

- **error**: el problema está confirmado y algo no funciona o es un riesgo de seguridad.
- **advertencia**: el hecho está confirmado, pero puede que no te afecte (por ejemplo, falta una dependencia de un recurso que no usas).
- **información**: recomendaciones y datos útiles.

Si algo no se puede confirmar, no se informa como error.

### Compatibilidad por framework

| Comprobación | Independiente | QBox | QBCore | ESX |
|---|---|---|---|---|
| dependencias, manifiestos, permisos, rendimiento | Sí | Sí | Sí | Sí |
| framework | Solo dice que no hay framework | Sí | Sí | Sí |
| erroreslog | Si existe un `fxserver.log` de txAdmin | Sí | Sí | Sí |
| rutasnui | Sí | Sí | Sí | Sí |
| imagenes | Si usa ox_inventory | Sí (ox_inventory) | Sí (ox_inventory o inventario configurado en `Config.Images.qbInventories`) | Sí (ox_inventory o inventario configurado en `Config.Images.esxInventories`) |

**Compatibilidad:** el recurso está diseñado para QBox, QBCore, ESX e instalaciones independientes. Algunas comprobaciones dependen de los recursos y metadatos presentes en cada servidor.

## Ejemplo de informe (ficticio)

```text
NX_ServerDoctor · 2 errores, 1 advertencias, 2 informaciones
Comprobaciones: dependencias, manifiestos, permisos, framework, rendimiento · 84 recursos · 412 archivos mirados · 37 ms
[ERROR] mi_tienda declara client/menu.lua, que no existe (mi_tienda/fxmanifest.lua (client_script))
   Por qué importa: Ese script no se carga, así que parte del recurso no funcionará.
   1) Comprueba que el archivo existe y que la ruta y las mayúsculas coinciden (Linux distingue mayúsculas).
   2) Si el recurso se compila (carpetas dist/ o build/), compílalo o descarga la versión publicada.
[ERROR] ox_inventory está configurado para "esx" y el framework es QBox (server.cfg (inventory:framework))
   Por qué importa: El inventario no cargará bien a los jugadores si habla con otro framework.
   1) Añade "setr inventory:framework 'qbx'" a server.cfg antes de "ensure ox_inventory".
[ADVERTENCIA] Falta el recurso mi_libreria (mi_hud/fxmanifest.lua)
   Por qué importa: Lo piden 1 recurso(s) que no están iniciados: mi_hud. Mientras falte, FiveM no los dejará arrancar.
   1) Si usas esos recursos, instala mi_libreria en la carpeta resources y añade "ensure mi_libreria" antes que ellos.
   2) Si no los usas, puedes ignorar este aviso o quitarlos del servidor.
[INFO] Framework detectado: QBox (qbx_core, iniciado) (qbx_core)
[INFO] El tiempo de cada recurso no se puede medir desde un script (-)
```

## Privacidad y seguridad

- Las ubicaciones se muestran siempre relativas al recurso (`recurso/archivo`). Antes de mostrar cualquier texto se quitan rutas absolutas, IPs e identificadores tipo `license:...`, por si alguno se colara.
- Al analizar recursos, nunca se abre un archivo cuyo nombre coincida con `Config.SensitivePatterns` (`secrets`, `.env`, `.cfg`, `.key`, `.pem`, `token`, `password`...), ni siquiera para ver si existe. Tampoco se lee `server.cfg`. La única lectura de logs es la excepción explícita `erroreslog`, limitada al archivo `fxserver.log` configurado.
- Para comprobar si un archivo declarado existe se abre y se cierra sin leerlo. Los archivos de código inspeccionados por `rendimiento` y `rutasnui` se leen en memoria, con límites; no se ejecutan ni se guardan. El contenido del log tampoco se guarda.
- La comprobación de oxmysql solo mira si `mysql_connection_string` está vacía; el valor no se guarda, no se compara con nada más y no se muestra. Puedes desactivarla con `Config.CheckDatabaseConvar = false`.
- Para la lista de ítems se usa el export de lectura del inventario (`ox_inventory:Items` o `qb-core:GetCoreObject().Shared.Items`), dentro de `pcall`.
- No se ejecutan comandos del sistema operativo.
- El último informe se guarda en memoria (solo hallazgos) para `/nxcheck ver`; se pierde al reiniciar el recurso.

## Rendimiento y cómo medirlo

- **En reposo:** el recurso no deja ningún hilo vivo. Tras la revisión al iniciar (o con `Config.RunOnStart = false`) no ejecuta nada hasta que alguien usa el comando. Se puede verificar leyendo `server/main.lua`: no hay bucles `while` ni temporizadores.
- **Durante una revisión:** el trabajo se corta en tramos de `Config.Limits.sliceMs` milisegundos y cede el hilo un fotograma entre tramo y tramo, para no congelar el servidor en instalaciones grandes. La duración que muestra el informe es el tiempo total de reloj, incluidas esas pausas; no es tiempo de CPU.
- `rendimiento` da candidatos por patrones del código, no mediciones. Un `Wait(0)` o un `setTick` puede ser correcto y no demuestra por sí solo un problema.
- `resmon 1` en F8 muestra CPU y memoria de cada recurso en el cliente. Para localizar las líneas que consumen tiempo en cliente o servidor, graba con `profiler record 500` y revisa `profiler view` o `profiler saveJSON <archivo>`.
- **Límite real:** FiveM no ofrece a un recurso Lua una API estable para leer el tiempo de ejecución de los demás recursos. La medición real debe hacerse con el profiler/resmon; el ranking de NX_ServerDoctor es una guía para decidir qué mirar primero.

## Limitaciones

- FiveM no permite listar las reglas ACE: solo se puede preguntar si un grupo concreto tiene un permiso concreto. Por eso la comprobación de permisos pregunta por `builtin.everyone` y por los grupos de `Config.Permission.principals`.
- No se lee `server.cfg` (puede contener claves), así que no se sabe qué recursos tienen `ensure`. Una dependencia que falta en un recurso parado se informa como advertencia, no como error, porque puede que ese recurso no lo uses. `erroreslog` sí lee localmente hasta `Config.LogAudit.maxBytes` del final de `fxserver.log`, bajo demanda; no transmite el archivo ni guarda su contenido.
- Las entradas con comodines (`client/*.lua`) no se pueden comprobar sin listar carpetas y se saltan.
- En Windows los nombres de archivo no distinguen mayúsculas: un `Client.lua` declarado como `client.lua` pasa la comprobación aunque fallaría en Linux.
- La revisión completa cubre problemas detectables con los metadatos y archivos declarados disponibles para un recurso FiveM. No puede prometer encontrar todos los fallos posibles: no lee `server.cfg`, archivos sensibles ni la base de datos, ni puede reproducir todos los errores que dependen de jugadores, red o estado del juego. La comprobación `erroreslog` es una excepción deliberada: lee únicamente el tramo reciente del log configurado y sanea los datos antes de mostrarlos.
- No captura errores en vivo: `erroreslog` los recupera del `fxserver.log` de txAdmin cuando existe. Detecta la ruta habitual automáticamente; si el perfil o la instalación están en otra ubicación, configura `Config.LogAudit.path`. Sin archivo de registro, FXServer no permite recuperar mensajes que ya imprimió en la consola.
- ox_inventory no guarda en el servidor la imagen personalizada de cada ítem (`client.image`), así que se busca `<nombre>.png`. Si un ítem usa otra imagen, añádelo a `Config.Images.ignore`.
- Los mensajes están en español.

## Solución de problemas

| Problema | Solución |
|---|---|
| "No tienes permiso para usar este comando." | Añade `add_ace group.admin nxdoctor.use allow` y comprueba que tu identificador está en `group.admin`. Prueba antes desde la consola del servidor con `nxcheck permisos`. |
| No aparece nada en el chat. | El recurso envía el evento `chat:addMessage`. Si tu chat usa otro, cámbialo en `Config.Chat.event`, o usa la consola del servidor. |
| "Espera N s antes de repetir la revisión." | Es el tiempo de espera de `Config.Cooldown` para no repetir revisiones seguidas. |
| La revisión al iniciar dice que faltan recursos que sí tienes. | Pon `ensure NX_ServerDoctor` al final de `server.cfg` o sube `Config.StartDelaySeconds`. |
| "La comprobación X falló y se saltó." | El resto del informe es válido. Abre una incidencia con ese mensaje (revisa antes que no contenga datos de tu servidor). |
| Muchos avisos de imágenes de ítems que sí se ven en el juego. | Seguramente esos ítems usan una imagen con otro nombre; añádelos a `Config.Images.ignore`. |

## Licencia

Copyright (c) 2026 Nxsty. Todos los derechos reservados.

Uso gratuito en tus propios servidores. **No se permite venderlo, resubirlo, redistribuirlo (original o modificado) ni quitar los créditos.** Para compartirlo, enlaza este repositorio. Condiciones completas, en español e inglés, en `LICENSE`.
