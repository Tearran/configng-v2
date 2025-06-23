# network_manager - Configng V2 Extra Documents

```
network_manager <command>
```

## Commands

| Command          | Description                                                                 |
|------------------|-----------------------------------------------------------------------------|
| NetworkManager   | Set Netplan renderer to 'NetworkManager' for all interfaces                 |
| networkd         | Set Netplan renderer to 'networkd' for all interfaces                       |
| status           | Show current Netplan YAML and renderer                                      |
| help             | Show help message and usage examples                                        |

## Usage

```bash
network_manager <command>
```

### Examples

```bash
network_manager status
network_manager NetworkManager
network_manager networkd
network_manager help
```

## Behavior

- Changes or displays the `renderer` field in the first `.yaml` file found in `/etc/netplan`.
- When switching, only the Netplan YAML is edited and `netplan apply` is run if available.
- Does **not** install, uninstall, enable, or disable any network services.
- Designed to be minimal, simple, and safe to use from the CLI.

## Notes

- Requires a writable Netplan YAML file in `/etc/netplan`.
- No additional dependencies beyond `bash` and (optionally) the `netplan` CLI.
- Intended for use as a configng-v2 module or as a standalone script.
- Output is simple and command-oriented.
- Does not manage or report on actual network service states.
