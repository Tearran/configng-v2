# trace

```
trace <option> or <"message string">
```

## Options

| Option             | Description                                               |
|--------------------|-----------------------------------------------------------|
| `help`             | Show usage and options                                    |
| `"message string"` | Print message and elapsed time (if `TRACE` is set)        |
| `reset`            | (Re)set timer start point                                 |
| `total`            | Show total time elapsed and reset timer                   |

- If the environment variable `TRACE` is set and non-empty, messages are printed with timing.
- If `TRACE` is unset or empty, no trace output is shown.

## Example

```bash
export TRACE=1
source trace.sh

trace reset
trace "Start of operation"
# ... your code here ...
trace "Step 1 complete"
# ... your code here ...
trace total
```

Example output:
```
Start of operation           0 sec
Step 1 complete              5 sec
TOTAL time elapsed           8 sec
```

## Help Output

```
Usage: trace <option> || <"message string">
Options:
	help               Show this help message
	"message string"   Show trace message (TRACE non-zero)
	reset              (Re)set starting point
	total              Show total time and reset

	When providing a "message string", elapsed time since last trace call is shown if TRACE is set.
```

## Notes

- Requires Bash 4+.
- For module authors: Use `trace` to add basic timing and milestone tracking to your scripts and modules.
- See `src/core/initialize/trace.sh` for implementation details.