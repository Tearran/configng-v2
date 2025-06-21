# ok_box

**ok_box** is a message box utility/helper for [Armbian Config V3](https://github.com/Tearran/config-v3) modules.  
It displays informational messages using `whiptail`, `dialog`, or plain output, and is intended for use within scripts and modules in the config-v3 framework.

## Features

- Displays a message box with your message using:
	- `whiptail` (default)
	- `dialog`
	- terminal output (`read` or fallback)
- Supports direct string, stdin, or here-string input
- Consistent interface for use in modules
- Provides help output via `ok_box help`

## Usage

```sh
ok_box "Your message here"
echo "Hello from stdin" | ok_box
ok_box <<< "Message from here-string"
```

- To show usage/help:
	```sh
	ok_box help
	```

## Arguments

- `message` (string): The message to display.  
  If not provided, an error and usage will be shown.

## Environment Variables

- `DIALOG`: Set to `dialog`, `whiptail`, or `read` to control output mode.  
  Default is `whiptail`.
- `TITLE`: Optional. Sets the window title (default: "Info").

## Examples

Show a simple info box:
```sh
ok_box "Operation completed successfully."
```

Show help:
```sh
ok_box help
```

Pipe a message:
```sh
echo "This is from stdin" | ok_box
```

Use with here-string:
```sh
ok_box <<< "This message is from a here-string"
```

## Integration

- Source or call as a function in your config-v3 modules or scripts.
- Only displays a test message when executed directly, not when sourced.

## Exit Codes

- `0` on success
- `1` on error (missing message, invalid mode)

## License

See [LICENSE](./LICENSE) for details.