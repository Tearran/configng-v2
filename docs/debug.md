# debug

```
debug <option> or <"message string">
```

## Options

| Option            | Description                                           |
|-------------------|-------------------------------------------------------|
| `help`            | Show usage and options                                |
| `"message string"`| Print message and elapsed time (if DEBUG is set)      |
| `reset`           | (Re)set timer start point                             |
| `total`           | Show total time elapsed and reset timer               |

- If the environment variable `DEBUG` is set and non-empty, messages are printed with timing.
- If `DEBUG` is unset or empty, no debug output is shown.

#### Example

```bash
export DEBUG=1
source debug.sh

debug reset
debug "Start of operation"
# ... your code here ...
debug "Step 1 complete"
# ... your code here ...
debug total
```

Example output:
```
Start of operation           0 sec
Step 1 complete              5 sec
TOTAL time elapsed           8 sec
```

## Help Output

```
Usage: debug <option> || <"message string">
Options:
	help               Show this help message
	"message string"   Show debug message (DEBUG non-zero)
	reset              (Re)set starting point
	total              Show total time and reset

	When providing a "message string", elapsed time since last debug call is shown if DEBUG is set.
```

## Notes

- Requires Bash 4+.
- For module authors: Use `debug` to trace/profiling steps in Bash modules.
