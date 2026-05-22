# fivem-velleb-multijob

Multi-job system for FiveM using `ox-lib` and `oxmysql`. Provides NPC job changers, framework auto-detection (ESX / QBCore), and optional target integration (`qb-target` / `ox_target`).

**Version:** v1.1.0
**Author:** https://velleb.com

**Contents**
- `client/` — client-side scripts
- `server/` — server-side scripts
- `shared/` — shared config and helper code
- `[INSTALL]/` — SQL import files for frameworks
- `fxmanifest.lua` — resource manifest and dependencies

## Requirements
- A running FiveM server (CitizenFX)
- `oxmysql` (database connector)
- `ox_lib`
- One of the supported server frameworks (optional): `es_extended` (ESX) or `qb-core` (QBCore)
- Optional target integration: `qb-target` or `ox_target` (if `Config.UseTarget = true`)

## Installation
1. Copy this folder into your server `resources` directory.
2. Add the resource to your `server.cfg`:

```
ensure velleb-multijob
```

3. Ensure required dependencies are started before this resource. Add (if not already present):

```
ensure oxmysql
ensure ox_lib
# ensure qb-core or es_extended (if using QBCore/ESX)
```

4. Database: open the `[INSTALL]` folder and import the SQL file for your framework:
- For ESX: `[INSTALL]/esx.sql`
- For QBCore: `[INSTALL]/qb.sql`

Run in your database

## Configuration
- Open `shared/config.lua` to change behavior and spawn locations.

The resource auto-detects your framework and installed target system. If neither framework is found it will run in `standalone` mode.

## Usage
- Start your server and visit one of the configured NPC locations. Interact with the NPC (target or zone) to change jobs.
- The script handles ESX/QBCore integration automatically when those frameworks are present.

## Troubleshooting
- If NPCs or blips do not appear, confirm the resource started in the server console and that dependencies (`oxmysql`, `ox_lib`) are running.
- Check `shared/config.lua` for `Locations` and ensure coordinates are valid.
- Verify database tables were created by importing the correct SQL file from `[INSTALL]` and that `oxmysql` connection settings are correct.

## Credits
- Built by Velleb — https://velleb.com

## Support
For issues or questions, open an issue in this repository or contact me

---
Updated: 22 May 2026
