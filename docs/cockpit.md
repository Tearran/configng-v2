# cockpit

```
cockpit <command>
```

## Commands

| Command    | Description                         |
|------------|-------------------------------------|
| install    | Install Cockpit via apt             |
| remove     | Remove Cockpit and purge config     |
| start      | Start Cockpit (socket/service)      |
| stop       | Stop Cockpit (socket/service)       |
| status     | Show Cockpit install/run status     |
| enable     | Enable Cockpit at boot (socket)     |
| disable    | Disable Cockpit at boot (socket)    |
| help       | Show usage and help message         |

## Usage

```bash
cockpit install
cockpit status
cockpit help
```

## Behavior

- Checks for root; exits with error if not root.
- Each command manages Cockpit using `apt` and `systemctl`.
- `status` shows if Cockpit is installed and running.
- `help` or no command shows usage.

## Notes

- Requires Bash 4+, `apt`, `systemctl`, and root privileges.
- Intended for use as a config-ng module or standalone.
- Used as a menu entry if sourced by a submenu helper.
- Output is simple and command-oriented.

