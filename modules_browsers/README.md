# configng-v2 GUI Tools

This directory contains scripts and utilities for exploring and interacting with configng-v2 modules via graphical and web interfaces. All tools work with the auto-generated `modules_metadata.json` to provide module listings, descriptions, and feature details.

## Contents

- `modules_browser.go` — Go program that launches a desktop window (`webview`) showing the interactive modules browser (served from `modules_browser.html`).
- `modules_browser.html` — Single-page web interface (auto-generated, do not edit directly) for browsing all module features. Run `./workflow/35_web_docs.sh` to regenerate after editing source metadata.
- `modules_browser.py` — Python/Tkinter GUI for browsing modules and viewing feature details from `modules_metadata.json`.
- `modules_browser.sh` — Bash+Zenity dialog browser for modules, requiring `jq` and `zenity`. Lets you select category/group/feature and view details in a graphical dialog.
- `modules_metadata.json` — Machine-readable metadata file containing all available module features, options, and descriptions. Used by all browsers above.
- `web-server.go` — Minimal Go HTTP server for serving the local directory (including the HTML browser) at http://localhost:8080/.
- `web-server.py` — Python3 HTTP server (with CGI enabled) to serve the directory, also on port 8080.
- `go.mod`, `go.sum` — Go module definitions for Go-based tools.

## Usage

### HTML Browser

1. Ensure `modules_browser.html` and `modules_metadata.json` are present (regenerate with `./workflow/35_web_docs.sh` if needed).
2. Open `modules_browser.html` in any web browser **or**:

### GO webview
<img width="960" height="604" alt="{946B063F-B7DF-49FE-9779-097DB3EB69FB}" src="https://github.com/user-attachments/assets/b53fb8f9-064f-40e1-bdeb-bc0369d74b42" />
   - Run `go run modules_browser.go` for a desktop app window (requires Go and the `webview` Go module).

### Python tkinter
<img width="676" height="429" alt="{98CB24B3-B8D7-406A-9A30-51942E19BC34}" src="https://github.com/user-attachments/assets/d19f2a94-2934-4c9e-8738-85fd883903e8" />

```sh
cd modules_browsers
python3 modules_browser.py
```

### Bash+Zenity Browser
<img width="226" height="171" alt="{12CB818B-41B7-486B-A8C7-4C62FC8E33C7}" src="https://github.com/user-attachments/assets/9ebad382-b294-4296-b27a-c37a7c25ba1d" />

```sh
cd modules_browsers
bash modules_browser.sh
```

Requires `jq` and `zenity` (`sudo apt install jq zenity`).

### Go HTTP Server

```sh
cd modules_browsers
go run web-server.go
```

### Python HTTP Server

```sh
cd modules_browsers
python3 web-server.py
```

## Regenerating `modules_browser.html`

This file is auto-generated! Do not edit it directly. To update module documentation:

```sh
cd workflow
./35_web_docs.sh
```

This will refresh `modules_browser.html` and `modules_metadata.json` based on the latest modules.

## Notes

- All browsers read from `modules_metadata.json` for feature lists and details.
- The HTML browser supports a "dev" toggle to show core/internal modules.
- See comments in each script for more details and options.
