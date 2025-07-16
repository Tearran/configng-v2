# configng-v2 Module Metadata Menu

This web tool provides a menu and simple UI for browsing, exploring, and testing modules defined in `modules_metadata.json`.

## How it Works

- **All categories, groups, and modules are defined in a single JSON file** (by default: `modules_metadata.json`).
- **The menu UI reads this JSON file** and builds a clickable, categorized interface for exploring the modules and their features/options.

## Quick Start

### 1. Serve Locally

For security and browser compatibility, you should serve this directory with a local web server.

**Using Go (`uxgo-server.go`):**
```sh
cd ./tools/uxgo
go run uxgo-server.go
# or, if built:
# ./uxgo-server
```
**Or, with Python:**
```sh
cd ./docs
python3 -m http.server 8080
```

### 2. Open in Your Browser

Go to [http://localhost:8080/index.html](http://localhost:8080/index.html).

### 3. Explore

- The menu is generated automatically from the JSON file.
- Click categories and groups to drill down to individual modules.
- Module details and options are shown, including raw JSON for debugging.

## JSON File Format

- The UI expects a file named `modules_metadata.json` (can be changed in the JS).
- It should be a nested structure: categories → groups → modules.
- Example structure:
```json
{
  "system": {
    "core": {
      "logging": {
        "feature": "Logging",
        "description": "System logging feature.",
        "options": "enable,disable"
      }
    },
    "network": {
      "firewall": {
        "feature": "Firewall",
        "description": "Basic firewall control.",
        "options": "on,off"
      }
    }
  }
}
```

## Customization

- **To update module data:** Edit `modules_metadata.json` in this folder.
- **To change the menu behavior:** Edit `index.html` and the embedded JavaScript.

## Offline/Portable

- This menu works offline if both the HTML and JSON are present and served locally.
- No external network dependencies.

## Troubleshooting

- If the menu says "Failed to load JSON," make sure you are running a web server and not just opening the HTML file directly.
- Double-check file names and paths.

## License

Open-source, MIT. See [LICENSE](LICENSE).

---

Enjoy building with configng-v2!