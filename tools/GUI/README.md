# configng-v2 GUI Tools

This directory contains multiple GUI applications for browsing, exploring, and testing modules defined in `modules_metadata.json`. Choose from web-based interfaces, native desktop applications, or GTK-based dialog tools.

## Available GUI Options

### 🌐 Web-based Interfaces

#### Option 1: Python Web Server (Recommended)
```bash
cd tools/GUI
python3 web-server.py
```
Then open [http://localhost:8080/](http://localhost:8080/) in your browser.

#### Option 2: Go Web Server
```bash
cd tools/GUI
go run web-server.go
```
Then open [http://localhost:8080/](http://localhost:8080/) in your browser.

#### Option 3: Python's Built-in Server
```bash
cd tools/GUI
python3 -m http.server 8080
```
Then open [http://localhost:8080/](http://localhost:8080/) in your browser.

### 🖥️ Native Desktop Applications

#### Option 4: Go Desktop App (Webview)
Creates a native desktop window using webview:
```bash
cd tools/GUI
go run gui.go
```

**Dependencies:** Requires GTK+ 3.0 and webkit2gtk-4.0 development packages.

On Ubuntu/Debian:
```bash
sudo apt install libgtk-3-dev libwebkit2gtk-4.0-dev
```

#### Option 5: Python Desktop App (Tkinter)
Modern Python GUI with tree navigation:
```bash
cd tools/GUI
python3 gui
```

**Dependencies:** Requires Python tkinter (usually included with Python).

On Ubuntu/Debian (if not included):
```bash
sudo apt install python3-tk
```

### 📱 GTK Dialog Interface (Zenity)

#### Option 6: Shell Script with Zenity
Interactive step-by-step module browser using GTK dialogs:
```bash
cd tools/GUI
./gui.sh
```

**Dependencies:** Requires `zenity` and `jq`.

On Ubuntu/Debian:
```bash
sudo apt install zenity jq
```

## File Structure

| File/Directory | Purpose |
|---|---|
| `README.md` | This documentation file |
| `index.html` | Main web interface (auto-generated, do not edit directly) |
| `modules_metadata.json` | Module configuration data in JSON format |
| `web-server.py` | Python web server with CGI support |
| `web-server.go` | Simple Go web server |
| `gui.go` | Go desktop application using webview |
| `gui` | Python desktop application using tkinter |
| `gui.sh` | Shell script for zenity-based GTK dialogs |
| `go.mod` / `go.sum` | Go module dependency files |

## How It Works

- **All categories, groups, and modules are defined in a single JSON file** (`modules_metadata.json`).
- **Each GUI reads this JSON file** and builds a browsable interface for exploring modules and their features.
- **The web interface** (`index.html`) is auto-generated and contains embedded CSS and JavaScript.

## JSON File Format

The UI expects a nested structure: categories → groups → modules.

Example structure:
```json
{
  "system": {
    "login": {
      "adjust_motd": {
        "feature": "adjust_motd",
        "description": "Adjust welcome screen (motd)",
        "options": "show,set <item> <ON|OFF>,reload,help",
        "contributor": "@igorpecovnik",
        "arch": "arm64,armhf,x86-64",
        "require_os": "Debian,Ubuntu,Armbian"
      }
    }
  },
  "network": {
    "interface": {
      "net_render": {
        "feature": "net_render",
        "description": "Set or check the current Netplan renderer",
        "extend_desc": "Toggle between NetworkManager and networkd",
        "options": "NetworkManager,networkd,status,help",
        "contributor": "@tearran"
      }
    }
  }
}
```

## Usage Instructions

### Web Interface Usage
1. Start any of the web servers (Options 1-3 above)
2. Open your browser to `http://localhost:8080/`
3. Navigate through categories and groups to explore modules
4. Click on modules to view detailed information and options
5. Use the search functionality to find specific modules

### Desktop App Usage
1. **Go Desktop App**: Run `go run gui.go` for a native webview window
2. **Python Desktop App**: Run `python3 gui` for a tkinter-based browser with tree navigation

### GTK Dialog Usage
1. Run `./gui.sh` to start the zenity-based interface
2. Select a category from the first dialog
3. Select a group from the second dialog
4. Select a feature from the third dialog
5. View feature details in the final dialog

## Troubleshooting

### Web Interface Issues
- **"Failed to load JSON"**: Ensure you're using a web server, not opening the HTML file directly
- **Port already in use**: Try a different port or kill existing processes: `pkill -f "python3 -m http.server"`
- **CORS errors**: Always serve from a local web server, not file:// URLs

### Desktop App Issues
- **Go app compilation errors**: Install GTK+ development packages:
  ```bash
  sudo apt install libgtk-3-dev libwebkit2gtk-4.0-dev
  ```
- **Python tkinter missing**: Install Python tkinter:
  ```bash
  sudo apt install python3-tk
  ```

### GTK Dialog Issues
- **"zenity: command not found"**: Install zenity:
  ```bash
  sudo apt install zenity
  ```
- **"jq: command not found"**: Install jq:
  ```bash
  sudo apt install jq
  ```

### General Issues
- **JSON parsing errors**: Validate your `modules_metadata.json` with a JSON validator
- **Module not found**: Ensure the module exists in the JSON file with correct category/group structure
- **Permission errors**: Make sure script files are executable: `chmod +x gui.sh`

## Customization and Extension

### Adding New Modules
1. Edit `modules_metadata.json` to add new modules
2. Follow the existing JSON structure: category → group → module
3. Required fields: `feature`, `description`
4. Optional fields: `extend_desc`, `options`, `contributor`, `arch`, `require_os`, etc.

### Modifying the Web Interface
- **Note**: `index.html` is auto-generated. Do not edit directly.
- To modify the web interface, edit the source file referenced in the HTML header
- Run the appropriate build script (likely `./tools/35_web_docs.sh`) to regenerate

### Creating New GUI Tools
1. **Read the JSON**: Use your language's JSON parser to load `modules_metadata.json`
2. **Parse the structure**: Navigate the category → group → module hierarchy
3. **Build the interface**: Create browsable menus/trees based on the data
4. **Display details**: Show module information including description, options, etc.

### Extending Existing Tools
- **Python GUI**: Edit the `gui` file to add new features like search, filtering, or module execution
- **Go Desktop App**: Modify `gui.go` to add new webview features or UI elements
- **Zenity Script**: Edit `gui.sh` to add new dialog types or workflow steps

## Dependencies Summary

| Tool | Dependencies |
|---|---|
| Web servers | Python 3 or Go |
| Go desktop app | Go, GTK+ 3.0, webkit2gtk-4.0 |
| Python desktop app | Python 3, tkinter |
| Zenity GUI | bash, zenity, jq |

## Contributing

When adding new GUI tools or modifying existing ones:
1. Follow the existing code style and patterns
2. Ensure your changes work with the current `modules_metadata.json` format
3. Add appropriate error handling and user feedback
4. Test on different platforms when possible
5. Update this README.md with any new features or requirements

## Legacy Notes

This GUI system is part of configng-v2, an evolution of the original armbian/configng project. The tools are designed to be more modular, extensible, and user-friendly than the original implementation.

---

**Need Help?** Each GUI tool provides its own help or error messages. For additional support, check the main project documentation or open an issue on the GitHub repository.