# Armbian Media Kit Generator

This project provides a Bash tool for generating, indexing, and serving a media kit of Armbian logos and icons.

## Features

- **Generate PNG, JPG, and GIF icons** from SVG files at multiple resolutions.
- **Create an HTML index** (`index.html`) of all logos and icons, grouped for convenient browsing and downloading.
- **Serve the kit** with a built-in Python HTTP server for easy sharing or review.
- **Generate a multi-resolution favicon.ico** from your main SVG logo.
- **Maintain a JSON index** (`logos.json`) of available assets for automation or integration.

## Usage

Run all commands via:
```bash
./media_kit.sh <command> [options]
```

### Commands

- `help`  
  Show usage and help message.

- `icon`  
  Generate PNG, JPG, and GIF icon sets from SVGs in `./brand/` and `./brand/legacy/` at common sizes (16, 48, 512). Copies SVGs to `./images/scalable/` for use in the HTML index.

- `index`  
  Generate an HTML media kit (`index.html`) listing all SVGs and downloadable icons (PNG, JPG, GIF), grouped by filename pattern. Also generates `logos.json`.

- `server [directory]`  
  Serve the specified directory (default: current directory) over HTTP at [http://localhost:8080/](http://localhost:8080/).

- `all`  
  Run icon generation, HTML index generation, and start the server in sequence.

### File Organization

- **Input SVGs:** Place all SVGs in `./brand/` (and `./brand/legacy/` for older assets).
- **Generated Images:** PNG, JPG, and GIF files are generated in `./images/<size>x<size>/`.
- **SVGs (for HTML):** After running `icon`, SVGs are copied to `./images/scalable/`.
- **HTML index:** `index.html` is generated at the project root.
- **JSON index:** `logos.json` is generated at the project root.
- **Favicon:** `favicon.ico` is generated at the project root from the main SVG logo.

### Media Kit Grouping Logic

- Logos starting with `armbian_` are displayed on the left.
- Logos starting with `configng_` are displayed on the right.
- All other images appear in a separate section at the bottom.

### Favicon Generation

- Automatically generates a multi-resolution `favicon.ico` from your main SVG (with 16x16, 32x32, and 48x48 sizes) for full browser and OS compatibility.

## Requirements

- [ImageMagick](https://imagemagick.org/) (`convert` command) for icon and favicon generation.
- Python 3 for the HTTP server.

You will be prompted to install any missing dependencies if needed.

## Example

```bash
./media_kit.sh icon
./media_kit.sh index
./media_kit.sh server
./media_kit.sh all
```

**Format Policy:**  
All graphics in this media kit are provided in SVG format as the source, which is widely compatible with both FOSS and commercial design tools (such as Inkscape, Photoshop, Illustrator, etc.).  
Generated PNG, JPG, and GIF formats are provided for easy use.  
If you need other formats, you can convert from SVG using your preferred tools or request a new export.

## License

Open source; see [LICENSE](LICENSE).