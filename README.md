
# NX_ServerDoctor

Made by **Nxsty**. Free to use, but not open source: read the [license](LICENSE) before sharing it.

A free resource​‌​​‌‌‌​​‌​‌‌​​​​‌​‌​​‌‌​‌​‌​‌​​​‌​‌‌​​‌ for FiveM servers that reviews your configuration and explains, in plain language, what is wrong and how to fix it.

- **Read-only.** It never changes files, variables, permissions, resources or the database. It never repairs anything on its own: it tells you what to do and you decide.
- **No external connections.** No telemetry, no analytics. The error scan reads the configured slice of `fxserver.log` locally and only shows sanitized messages in the report you asked for.
- **No external dependencies.** No framework, database, ox_lib or Node.js required. The panel uses local HTML, CSS and JavaScript.
- **Minimal idle cost.** No loops or timers. The small NUI page stays loaded but only draws the report when requested; the checks run with `/nxcheck` or once at startup if you leave that enabled.

> **Note:** the server code ships minified/obfuscated on purpose, to protect authorship. It works exactly the same but is not meant to be edited. The only file you should touch is `config.lua`, which is left readable.

## Installation

1. Copy the `NX_ServerDoctor` folder into `resources` (any subfolder works, e.g. `resources/[admin]/NX_ServerDoctor`).
2. Add it to `server.cfg`, **after** your other resources so the startup review finds them already started:

   ```cfg
   ensure NX_ServerDoctor
   ```

3. Grant access to your admin group (see `permissions.example.cfg`):

   ```cfg
   add_ace group.admin nxdoctor.use allow
   ```

4. Restart the server, or on the running console run `refresh` and `ensure NX_ServerDoctor`.

## Commands

| Command | What it does |
|---|---|
| `/nxcheck` | Runs the full review and opens the visual panel (UI). |
| `/nxcheck ui` | Same: full review and visual panel. |
| `/nxcheck chat` | Shows the whole report in the chat instead of the panel. |
| `/nxcheck <id>` | Runs a single check, e.g. `/nxcheck imagenes`. |
| `/nxcheck lista` (alias `list`) | Lists the checks and whether they are enabled. |
| `/nxcheck ver [page]` (alias `show`) | Shows the last report again (chat is paged). |
| `/nxcheck consola` (alias `console`) | Copies the last report to the server console so you can copy-paste it. |
| `/nxcheck ayuda` (alias `help`) | Shows this help. |

In short: **`/nxcheck` opens the UI panel, and `/nxcheck chat` prints everything in the chat.**

From the server console (or txAdmin's), type it without a slash: `nxcheck`. The console always has permission and gets the full report; in chat it is paged in groups of `Config.Chat.perPage` findings.

`erroreslog` looks for errors already written by FXServer in the txAdmin log; the full report includes it automatically. If it cannot find the file, set its absolute path in `Config.LogAudit.path`. You can also run it on its own with `/nxcheck erroreslog`.

### Visual panel

The panel is part of `NX_ServerDoctor`: `/nxcheck` opens it directly, and `/nxcheck chat` keeps the text output. It is built with local HTML, CSS and JavaScript, with no React, external dependencies, polling or timers. It reuses the NX palette and typography locally; the Oswald font is included under its OFL license in `html/fonts/OFL.txt`. The NUI page stays loaded on the client so it can open, but keeps no active work while idle.

## Permissions

The command is registered without a FiveM restriction, and the resource itself checks on the server, on every use, that the requester has the `Config.Permission.ace` permission (default `nxdoctor.use`). The server sends the report only to the authorized admin who requested it; the NUI has no callbacks that run checks or server actions.

```cfg
# Recommended: your admin group only
add_ace group.admin nxdoctor.use allow

# A specific person (use their real identifier instead of the example)
add_principal identifier.license:0000000000000000000000000000000000000000 group.admin
```

## Configuration

Everything is in `config.lua`, commented. The most common options:

| Option | Default | Purpose |
|---|---|---|
| `Config.Command` | `'nxcheck'` | Command name. |
| `Config.Permission.ace` | `'nxdoctor.use'` | Required ACE permission. |
| `Config.Permission.principals` | `{ 'group.admin' }` | Groups that should have it (only to warn you if none does). |
| `Config.Detail` | `'normal'` | `'resumen'` (summary), `'normal'` or `'completo'` (full). |
| `Config.UiBps` | `100000` | Bytes per second used to send the report to the panel (latent event). |
| `Config.RunOnStart` | `true` | Automatic review once at startup, console only. |
| `Config.Checks.<id>` | see file | `enabled`, `startup` and `full` for each check. |
| `Config.Frameworks` | QBox, QBCore, ESX | Main resource name of each framework, in case you use a different one. |
| `Config.CheckDatabaseConvar` | `true` | Warns if the oxmysql connection string is empty (see Privacy). |
| `Config.Images` | see file | Image folders for QBCore-style and ESX inventories, plus items to ignore. |
| `Config.NuiPaths` | `{ enabled = true, ignore = {} }` | Enables the `nui://` path check and ignores specific resource names. |
| `Config.LogAudit` | see file | Path and limits of the txAdmin `fxserver.log` read on demand. |
| `Config.Limits` | see file | Limits on resources, files, images and code scanned for the performance estimate. |
| `Config.Limits.maxPerformanceFiles` | `300` | Max `.lua`/`.js` files the static performance estimate scans per review. |
| `Config.UseIoForFileChecks` | `true` | Check files by opening them without reading (fast) or with `LoadResourceFile` (slow). |
| `Config.SensitivePatterns` | see file | File names that are never opened. |

## Checks

| Id | What it reviews | Possible severity | Cost |
|---|---|---|---|
| `dependencias` | Each `fxmanifest.lua`'s dependencies: missing resources, stopped dependencies of started resources, `/onesync`, `/server:N` and `/gameBuild:N` restrictions, and several started resources that `provide` the same name. | error, warning | Low: only reads metadata FiveM already has in memory. |
| `manifiestos` | Declared scripts, `files` and `ui_page` that do not exist; broken `@resource/file` imports or ones not declared as a dependency; `__resource.lua`, missing `fx_version` or `game`, old `fx_version`, and missing `lua54 'yes'`. | error, warning, info | Medium: checks whether each declared file exists (up to `maxFilesPerResource` per resource and `maxFileChecks` total). |
| `permisos` | Whether anyone has the resource permission, whether `builtin.everyone` (all players) has it, and whether it has `command` or admin commands like `quit`, `stop`, `exec`, `add_ace`... | error, warning | Very low. |
| `framework` | Detects QBox, QBCore or ESX. Warns about several frameworks installed, a stopped core resource, framework dependencies not started, QBox without OneSync, an `inventory:framework` that does not match ox_inventory, and an empty oxmysql connection string. | error, warning, info | Very low. |
| `imagenes` | Items with no image in the inventory folder; warns if `inventory:imagepath` uses a name resolved only via `provide`. Also detects common alternative extensions. | warning, info | Higher: scans up to `maxImageChecks` items. Included in `/nxcheck` on demand, but not at startup. |
| `rendimiento` | Ranks up to five candidate resources by static patterns like `Wait(0/1)` next to loops, `setTick`/`setInterval` and frequent drawing. Explains why each one is worth measuring. It does not claim they are the real top CPU users. | info | Low/medium: reads up to `maxPerformanceFiles` declared code files with `LoadResourceFile`; only runs on demand. |
| `rutasnui` | Literal `nui://` paths in files declared by the manifests. Warns if the target resource is missing, exists only via `provide`, or the file does not exist; detects `.png`, `.webp` and `.jpg` alternatives. | warning, info | Low/medium: reads declared `.lua`, `.js`, `.html`, `.htm` and `.css` files on demand, subject to the resource and file limits. |
| `erroreslog` | Looks for script errors and missing exports in the recent slice of the txAdmin `fxserver.log`. Groups duplicates and shows resource, file/line and message. | error, info | Low: reads up to 2 MB when you run `/nxcheck`; does not run at startup. |

### Severities

- **error**: the problem is confirmed and something is broken or a security risk.
- **warning**: the fact is confirmed, but it may not affect you (for example, a missing dependency of a resource you do not use).
- **info**: recommendations and useful facts.

If something cannot be confirmed, it is not reported as an error.

### Framework compatibility

| Check | Standalone | QBox | QBCore | ESX |
|---|---|---|---|---|
| dependencias, manifiestos, permisos, rendimiento | Yes | Yes | Yes | Yes |
| framework | Only reports there is no framework | Yes | Yes | Yes |
| erroreslog | If a txAdmin `fxserver.log` exists | Yes | Yes | Yes |
| rutasnui | Yes | Yes | Yes | Yes |
| imagenes | If using ox_inventory | Yes (ox_inventory) | Yes (ox_inventory or the inventory set in `Config.Images.qbInventories`) | Yes (ox_inventory or the inventory set in `Config.Images.esxInventories`) |

**Compatibility:** the resource is designed for QBox, QBCore, ESX and standalone installs. Some checks depend on the resources and metadata present on each server.

## Example report (fictional)

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
[INFO] Framework detectado: QBox (qbx_core, iniciado) (qbx_core)
```

> The in-game report text is in Spanish (see Limitations).

## Privacy and security

- Locations are always shown relative to the resource (`resource/file`). Before any text is shown, absolute paths, IPs and `license:...`-style identifiers are stripped, in case one slips through.
- When scanning resources, a file whose name matches `Config.SensitivePatterns` (`secrets`, `.env`, `.cfg`, `.key`, `.pem`, `token`, `password`...) is never opened, not even to check it exists. `server.cfg` is never read. The only log read is the explicit `erroreslog` exception, limited to the configured `fxserver.log`.
- To check whether a declared file exists, it is opened and closed without reading it. The code files inspected by `rendimiento` and `rutasnui` are read into memory, with limits; they are never executed or stored. The log content is not stored either.
- The oxmysql check only looks at whether `mysql_connection_string` is empty; the value is not stored, compared to anything else, or shown. You can disable it with `Config.CheckDatabaseConvar = false`.
- The item list is obtained through the inventory's read export (`ox_inventory:Items` or `qb-core:GetCoreObject().Shared.Items`), inside a `pcall`.
- No operating-system commands are run.
- The last report is kept in memory (findings only) for `/nxcheck ver`; it is lost when the resource restarts.

## Performance and how to measure it

- **Idle:** the resource leaves no live thread. After the startup review (or with `Config.RunOnStart = false`) it runs nothing until someone uses the command. You can verify this by reading `server/main.lua`: no `while` loops, no timers.
- **During a review:** work is split into `Config.Limits.sliceMs`-millisecond slices, yielding one frame between slices so large installs are not frozen. The duration shown in the report is total wall-clock time, including those pauses; it is not CPU time.
- `rendimiento` gives candidates by code patterns, not measurements. A `Wait(0)` or a `setTick` can be correct and does not by itself prove a problem.
- `resmon 1` (F8) shows each resource's CPU and memory on the client. To find the lines that spend time on client or server, record with `profiler record 500` and review `profiler view` or `profiler saveJSON <file>`.
- **Real limit:** FiveM does not give a Lua resource a stable API to read other resources' run time. Real measurement must be done with the profiler/resmon; NX_ServerDoctor's ranking is a guide for deciding what to look at first.

## Limitations

- FiveM does not allow listing ACE rules: you can only ask whether a specific group has a specific permission. That is why the permission check asks about `builtin.everyone` and the groups in `Config.Permission.principals`.
- `server.cfg` is not read (it may contain keys), so it is not known which resources have `ensure`. A missing dependency of a stopped resource is reported as a warning, not an error, because you may not use that resource. `erroreslog` does read up to `Config.LogAudit.maxBytes` from the end of `fxserver.log` locally, on demand; it never transmits or stores the file.
- Wildcard entries (`client/*.lua`) cannot be checked without listing folders and are skipped.
- On Windows, file names are case-insensitive: a `Client.lua` declared as `client.lua` passes the check even though it would fail on Linux.
- The full review covers problems detectable from the metadata and declared files available to a FiveM resource. It cannot promise to find every possible bug: it does not read `server.cfg`, sensitive files or the database, and cannot reproduce every error that depends on players, network or game state. `erroreslog` is a deliberate exception: it reads only the recent slice of the configured log and sanitizes the data before showing it.
- It does not capture live errors: `erroreslog` recovers them from the txAdmin `fxserver.log` when it exists. It auto-detects the usual path; if the profile or install is elsewhere, set `Config.LogAudit.path`. Without a log file, FXServer does not let a resource recover messages it already printed to the console.
- ox_inventory does not store each item's custom image on the server (`client.image`), so `<name>.png` is searched for. If an item uses a different image, add it to `Config.Images.ignore`.
- The in-game and report messages are in Spanish.

## Troubleshooting

| Problem | Solution |
|---|---|
| "No tienes permiso para usar este comando." (no permission) | Add `add_ace group.admin nxdoctor.use allow` and check your identifier is in `group.admin`. Try first from the server console with `nxcheck permisos`. |
| Nothing shows in chat. | The resource sends the `chat:addMessage` event. If your chat uses another, change it in `Config.Chat.event`, or use the server console. |
| "Espera N s antes de repetir la revisión." (cooldown) | It is the `Config.Cooldown` wait time, to avoid back-to-back reviews. |
| The startup review says resources are missing that you do have. | Put `ensure NX_ServerDoctor` at the end of `server.cfg`, or raise `Config.StartDelaySeconds`. |
| "La comprobación X falló y se saltó." (a check failed) | The rest of the report is valid. Open an issue with that message (check first it contains no data from your server). |
| Many warnings about item images that do show in-game. | Those items probably use an image with a different name; add them to `Config.Images.ignore`. |

## License

Copyright (c) 2026 Nxsty. All rights reserved.

Free to use on your own servers. **You may not sell it, re-upload it, redistribute it (original or modified), or remove the credits.** To share it, link this repository. Full terms, in Spanish and English, in `LICENSE`.
