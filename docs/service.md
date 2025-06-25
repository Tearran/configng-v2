# service - configng-v2 Extra Documentation

```
service <command>
```

## Commands

| Command         | Description                                         |
|-----------------|-----------------------------------------------------|
| active          | Check if a service is active                        |
| daemon-reload   | Reload systemd manager configuration                |
| disable         | Disable a service                                   |
| enable          | Enable a service                                    |
| enabled         | Check if a service is enabled                       |
| mask            | Mask a service (prevent manual start)               |
| reload          | Reload a service                                    |
| restart         | Restart a service                                   |
| start           | Start a service                                     |
| status          | Show the status of a service                        |
| stop            | Stop a service                                      |
| unmask          | Unmask a service                                    |

## Usage

```bash
service <command>
```

## Behavior

- Provides helpers for managing systemd services (start, stop, enable, disable, etc.).
- Intended for use by configng-v2 core logic and scripts, but may be used standalone.
- Supports simple commands for querying and controlling systemd units.

## Notes

- Requires: Armbian, Debian, or Ubuntu with systemd.
- Intended for configng-v2 modules, but works standalone.
- Output is simple and command-oriented.