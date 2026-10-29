Config = {}

-- Comando principal. Se escribe sin barra en la consola del servidor y con barra en el chat.
Config.Command = 'nxcheck'

-- Permiso ACE que se comprueba en el servidor antes de cada uso del comando.
-- Concédelo en tu server.cfg, por ejemplo:  add_ace group.admin nxdoctor.use allow
Config.Permission = {
    ace = 'nxdoctor.use',
    -- Grupos que deberían tener el permiso. Solo se usan para avisarte si a ninguno se le ha dado.
    principals = { 'group.admin' },
}

-- Segundos de espera entre dos ejecuciones pedidas por el mismo administrador.
Config.Cooldown = 20

-- Nivel de detalle del informe:
--   'resumen'  → recuento y títulos de errores y advertencias
--   'normal'   → errores y advertencias completos, informaciones solo con título
--   'completo' → todo con explicación y pasos
Config.Detail = 'normal'

-- Revisión automática una sola vez al iniciar el recurso (solo se imprime en la consola del servidor).
Config.RunOnStart = true
Config.StartDelaySeconds = 20 -- deja que el resto de recursos terminen de arrancar

-- Salida por el chat para administradores conectados (necesita un recurso de chat compatible).
Config.Chat = {
    event = 'chat:addMessage',
    perPage = 6,                -- hallazgos por página; /nxcheck ver 2 muestra la siguiente
}

-- Bytes por segundo con los que se envía el informe al panel (evento latente, no satura la conexión).
Config.UiBps = 100000

-- Cada comprobación se puede desactivar.
--   enabled → se puede ejecutar
--   startup → se incluye en la revisión automática al iniciar
--   full    → se incluye al usar /nxcheck sin argumentos (si no, solo con /nxcheck <id>)
Config.Checks = {
    dependencias = { enabled = true, startup = true,  full = true },
    manifiestos  = { enabled = true, startup = true,  full = true },
    permisos     = { enabled = true, startup = true,  full = true },
    framework    = { enabled = true, startup = true,  full = true },
    -- Mira un archivo por ítem; con cientos de ítems es la más lenta, por eso va solo bajo demanda.
    imagenes     = { enabled = true, startup = false, full = true },
    rendimiento  = { enabled = true, startup = false, full = true },
    rutasnui     = { enabled = true, startup = false, full = true },
    erroreslog   = { enabled = true, startup = false, full = true },
}

-- Errores reales de la consola guardados por txAdmin. Se revisan solo al pedir /nxcheck.
-- Deja path vacío para detectar el fxserver.log del perfil txAdmin automáticamente,
-- o indica una ruta absoluta si el servidor usa una ubicación/perfil personalizado.
Config.LogAudit = {
    enabled = true,
    path = '',
    maxBytes = 2097152, -- solo analiza los últimos 2 MB del registro
    maxFindings = 50,
}

-- Rutas nui:// que se ignoran en la revisión (nombres reales de recursos).
Config.NuiPaths = {
    enabled = true,
    ignore = {},
}

-- Nombres de los recursos principal de cada framework. Cámbialos si tu instalación usa otros.
Config.Frameworks = {
    qbox   = { core = 'qbx_core',    label = 'QBox',   inventoryConvar = 'qbx', requires = { 'ox_lib', 'oxmysql', 'ox_inventory' } },
    qbcore = { core = 'qb-core',     label = 'QBCore', inventoryConvar = 'qb',  requires = { 'oxmysql' } },
    esx    = { core = 'es_extended', label = 'ESX',    inventoryConvar = 'esx', requires = { 'oxmysql' } },
}

-- Comprueba si la variable de conexión de oxmysql está vacía. Su valor nunca se guarda ni se muestra.
Config.CheckDatabaseConvar = true

-- Imágenes de ítems.
Config.Images = {
    -- Inventarios estilo QBCore: recurso y carpeta donde buscar. Se usa el primero que esté iniciado.
    qbInventories = {
        { resource = 'qb-inventory', folder = 'html/images' },
        { resource = 'ps-inventory', folder = 'html/images' },
        { resource = 'lj-inventory', folder = 'html/images' },
    },
    -- Inventarios de ESX sin ox_inventory: los ítems no guardan imagen, así que se busca <nombre>.<extension>.
    esxInventories = {
        { resource = 'esx_inventoryhud', folder = 'html/img/items', extension = 'png' },
    },
    -- ox_inventory no expone en el servidor la imagen personalizada de cada ítem; se busca <nombre>.png.
    oxExtension = 'png',
    -- Ítems que no deben revisarse (por ejemplo, los que usan una imagen con otro nombre).
    ignore = {},
}

-- Límites de cada revisión: evitan picos de trabajo en servidores grandes.
Config.Limits = {
    maxResources = 1500,        -- recursos analizados por ejecución
    maxFilesPerResource = 60,   -- archivos declarados que se comprueban por recurso
    maxFileChecks = 6000,       -- archivos comprobados en total por ejecución
    maxImageChecks = 3000,      -- imágenes comprobadas por ejecución
    maxPerformanceFiles = 300,  -- archivos de código leídos para estimar riesgos de rendimiento
    findingsPerCheck = 40,      -- hallazgos por comprobación; el resto se resume
    namesPerFinding = 15,       -- nombres listados dentro de un hallazgo agrupado
    sliceMs = 4,                -- ms de trabajo seguidos antes de ceder el hilo un fotograma
}

-- Comprobar si un archivo existe:
--   true  → abre y cierra el archivo sin leerlo (rápido; necesita la librería io del servidor)
--   false → usa LoadResourceFile, que carga el archivo entero en memoria (más lento)
Config.UseIoForFileChecks = true

-- Archivos que nunca se abren, ni siquiera para ver si existen (patrones Lua, en minúsculas).
Config.SensitivePatterns = {
    'secret', '%.env', 'credential', 'password', 'passwd', 'token', 'apikey', 'api_key',
    'private', '%.key$', '%.pem$', '%.pfx$', '%.p12$', '%.cfg$', '%.sql$', '%.db$', '%.log$',
}
