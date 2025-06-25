# packages - configng-v2 Extra Documentation

```
packages <command>
```

## Commands

| Command         | Description                      |
|-----------------|----------------------------------|
| update          | Update APT package lists         |
| upgrade         | Upgrade installed packages       |
| full-upgrade    | Full system upgrade (may remove obsolete packages) |
| install <pkgs>  | Install one or more packages    |
| remove <pkgs>   | Remove and autopurge packages   |
| configure <pkgs>| Configure unpacked packages     |
| installed <pkg> | Test if a package is installed  |

## Usage

```bash
packages <command>
```

## Behavior

- Provides helpers for bulk package operations via apt and dpkg.
- Supports simple commands for updating, upgrading, installing, removing, and checking packages.
- Intended for use by `configng-v2` core logic and scripts, but may be used standalone.

## Notes

- Requires: Armbian, Debian, or Ubuntu with APT.
- Intended for configng-v2 modules, but works standalone.
- Output is simple and command-oriented.