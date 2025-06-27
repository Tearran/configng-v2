# adjust_motd - Configng V2 Extra Documentation

```
adjust_motd <command> [arguments]
```

## Commands

| Command                | Arguments           | Description                                      |
|------------------------|---------------------|--------------------------------------------------|
| show                   |                     | List all MOTD items, their descriptions, and ON/OFF status |
| set `<item>` `<ON|OFF>`| item, ON or OFF     | Enable or disable a specific MOTD item           |
| reload                 |                     | Show a live preview of the current MOTD output   |
| help                   |                     | Show this help message                           |

## Usage

```bash
adjust_motd show
adjust_motd set sysinfo OFF
adjust_motd reload
adjust_motd help
```

## Behavior

- Lists available MOTD components (clear, header, sysinfo, tips, commands) and their enabled/disabled state.
- Allows enabling or disabling individual MOTD components.
- Shows a real preview of what users will see on login.
- Does not require TUI; output is simple and columnar for CLI or further scripting.

## Notes

- Requires write access to `/etc/default/armbian-motd`.
- Intended for use as a `configng-v2` module or standalone.
- Integrates with Armbian's MOTD system.
- No external dependencies except bash and standard system tools.

## Example Output

```
Item       Description                    Status
--------   ------------------------------ ------
clear      Clear the MOTD screen          ON
header     System banner & version        ON
sysinfo    System info (load, CPU, ...)   OFF
tips       Random Armbian tips            ON
commands   Suggested Armbian commands     ON
```