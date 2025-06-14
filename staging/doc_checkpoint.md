# checkpoint

Provides timing, debugging, and progress checkpoint utilities for Bash modules. Supports debug timing, UX/UI marks, and elapsed time reporting for module development and diagnostics.

```
Usage: checkpoint <option> <message>
Options:
	debug      Show message in debug mode (DEBUG non-zero).
	help       Show this help screen.
	mark       Show message in UI or debug mode.
	reset      (Re)set starting point.
	total      Show total time and reset (in debug mode).

The 'debug' command will show time elapsed since the previous checkpoint after
the <message>. The 'mark' command will also show the elapsed time if the debug
mode is active (the DEBUG env var is non-zero).
```
