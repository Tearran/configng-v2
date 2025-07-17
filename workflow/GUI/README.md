# configng-v2 GUI Tools

This directory contains scripts and utilities for exploring and interacting with configng-v2 modules via graphical and web interfaces. All tools work with the auto-generated `modules_metadata.json` to provide module listings, descriptions, and feature details.

## Contents

- `modules_browser.go` — Go program that launches a desktop window (`webview`) showing the interactive modules browser (served from `modules_browser.html`).
- `modules_browser.html` — Single-page web interface (auto-generated, do not edit directly) for browsing all module features. Run `./tools/35_web_docs.sh` to regenerate after editing source metadata.
- `modules_browser.py` — Python/Tkinter GUI for browsing modules and viewing feature details from `modules_metadata.json`.
- `modules_browser.sh` — Bash+Zenity dialog browser for modules, requiring `jq` and `zenity`. Lets you select category/group/feature and view details in a graphical dialog.
- `modules_metadata.json` — Machine-readable metadata file containing all available module features, options, and descriptions. Used by all browsers above.
- `web-server.go` — Minimal Go HTTP server for serving the local directory (including the HTML browser) at http://localhost:8080/.
- `web-server.py` — Python3 HTTP server (with CGI enabled) to serve the directory, also on port 8080.
- `go.mod`, `go.sum` — Go module definitions for Go-based tools.

## Usage

### HTML Browser

1. Ensure `modules_browser.html` and `modules_metadata.json` are present (regenerate with `./tools/35_web_docs.sh` if needed).
2. Open `modules_browser.html` in any web browser **or**:
   - Run `go run modules_browser.go` for a desktop app window (requires Go and the `webview` Go module).
   - Use `web-server.go` or `web-server.py` to serve the directory, then visit [http://localhost:8080/modules_browser.html](http://localhost:8080/modules_browser.html).

### Python GUI

```sh
cd tools/GUI
python3 modules_browser.py
```

### Bash+Zenity Browser

```sh
cd tools/GUI
bash modules_browser.sh
```

Requires `jq` and `zenity` (`sudo apt install jq zenity`).

### Go HTTP Server

```sh
cd tools/GUI
go run web-server.go
```

### Python HTTP Server

```sh
cd tools/GUI
python3 web-server.py
```

## Regenerating `modules_browser.html`

This file is auto-generated! Do not edit it directly. To update module documentation:

```sh
cd tools
./35_web_docs.sh
```

This will refresh `modules_browser.html` and `modules_metadata.json` based on the latest modules.

## Notes

- All browsers read from `modules_metadata.json` for feature lists and details.
- The HTML browser supports a "dev" toggle to show core/internal modules.
- See comments in each script for more details and options.
