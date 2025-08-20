#!/usr/bin/env bash
set -euo pipefail

# web_icon_kit.sh
# Generate PNG icons from SVG source files for common web app sizes.
#
# Defaults can be overridden via environment variables or CLI flags.
#
# Environment variables:
#   BIN_ROOT            - Root of the bin directory (auto-detected)
#   SVG_LOGO_ROOT       - Source directory for SVGs. Defaults to $BIN_ROOT/../assets/images/logos
#                         (SVG_ROOT is also supported for backward compatibility)
#   WEB_ROOT            - Root of the web output. Defaults to $BIN_ROOT/../public_html
#   WEB_LOGO_ROOT       - Output directory for PNGs. Defaults to $WEB_ROOT/images/logos
#   ICON_SIZES          - Comma-separated list of sizes (e.g., "16,32,48,64,96,128,180,192,256,384,512,1024")
#
# CLI flags:
#   -s, --src DIR       - Override SVG source directory
#   -o, --out DIR       - Override output directory (WEB_LOGO_ROOT)
#   --sizes LIST        - Comma-separated sizes list (overrides ICON_SIZES)
#   -j, --jobs N        - Parallel jobs (default: number of CPUs if available, else 4)
#   -f, --force         - Overwrite existing files
#   -h, --help          - Show help
#
# Notes:
# - Prefers rsvg-convert, then Inkscape, and finally ImageMagick (magick/convert) as a fallback.
# - Ensures square output with transparent background, centering content if needed.
# - Output files are named as {basename}-{size}.png in WEB_LOGO_ROOT.

# ------------------------------
# Setup and defaults
# ------------------------------
BIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Prefer SVG_LOGO_ROOT; allow legacy SVG_ROOT; default to new assets path per user change.
SVG_LOGO_ROOT="${SVG_LOGO_ROOT:-${SVG_ROOT:-$BIN_ROOT/../assets/images/logos}}"

WEB_ROOT="${WEB_ROOT:-$BIN_ROOT/../public_html}"
WEB_LOGO_ROOT="${WEB_LOGO_ROOT:-$WEB_ROOT/images/logos}"

DEFAULT_SIZES="16,32,48,64,96,128,180,192,256,384,512,1024"
ICON_SIZES="${ICON_SIZES:-$DEFAULT_SIZES}"

# ------------------------------
# Utilities
# ------------------------------
usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  -s, --src DIR       Source SVG directory (default: $SVG_LOGO_ROOT)
  -o, --out DIR       Output PNG directory (default: $WEB_LOGO_ROOT)
  --sizes LIST        Comma-separated sizes (default: $ICON_SIZES)
  -j, --jobs N        Parallel jobs (default: auto)
  -f, --force         Overwrite existing files
  -h, --help          Show this help and exit

Environment overrides:
  SVG_LOGO_ROOT, SVG_ROOT, WEB_ROOT, WEB_LOGO_ROOT, ICON_SIZES

Examples:
  $(basename "$0")
  $(basename "$0") --sizes "16,32,180,192,512"
  $(basename "$0") --src ./assets/images/logos --out ./public_html/images/logos -j 8
EOF
}

log() { printf '%s\n' "$*" >&2; }
die() { printf 'Error: %s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

parse_sizes() {
  local list="$1"
  # Convert comma-separated to array, remove spaces, filter numeric
  IFS=',' read -r -a _sizes <<<"${list//[[:space:]]/}"
  SIZES=()
  for s in "${_sizes[@]}"; do
    [[ "$s" =~ ^[0-9]+$ ]] && SIZES+=("$s")
  done
  [[ ${#SIZES[@]} -gt 0 ]] || die "No valid sizes parsed from: $list"
}

ensure_dir() { mkdir -p "$1"; }

# Pick renderer: rsvg-convert > inkscape > magick/convert
select_renderer() {
  if have rsvg-convert; then
    RENDERER="rsvg"
  elif have inkscape; then
    RENDERER="inkscape"
  elif have magick; then
    RENDERER="magick"
  elif have convert; then
    # ImageMagick older alias
    RENDERER="convert"
  else
    die "No SVG to PNG converter found. Install one of: librsvg (rsvg-convert), Inkscape, ImageMagick."
  fi
}

render_png() {
  # Args: src_svg size out_png
  local src_svg="$1"
  local size="$2"
  local out_png="$3"

  case "$RENDERER" in
    rsvg)
      # Transparent background, force square dimensions
      rsvg-convert -w "$size" -h "$size" -b '#00000000' -o "$out_png" "$src_svg"
      ;;
    inkscape)
      # Inkscape 1.x flags
      inkscape "$src_svg" \
        --export-type=png \
        --export-filename="$out_png" \
        -w "$size" -h "$size" \
        --export-area-page >/dev/null 2>&1
      ;;
    magick)
      # Use high density for quality, then resize and pad to square if needed
      magick -background none -density 384 "$src_svg" -resize "${size}x${size}" \
        -gravity center -extent "${size}x${size}" "$out_png"
      ;;
    convert)
      convert -background none -density 384 "$src_svg" -resize "${size}x${size}" \
        -gravity center -extent "${size}x${size}" "$out_png"
      ;;
    *)
      die "Unknown renderer: $RENDERER"
      ;;
  esac
}

cpu_count() {
  if have nproc; then nproc; elif [[ "$(uname -s)" == "Darwin" ]] && have sysctl; then sysctl -n hw.ncpu; else echo 4; fi
}

# ------------------------------
# Parse CLI
# ------------------------------
JOBS="$(cpu_count)"
FORCE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -s|--src) SVG_LOGO_ROOT="$2"; shift 2 ;;
    -o|--out) WEB_LOGO_ROOT="$2"; shift 2 ;;
    --sizes) ICON_SIZES="$2"; shift 2 ;;
    -j|--jobs) JOBS="$2"; shift 2 ;;
    -f|--force) FORCE=1; shift ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    *) die "Unknown argument: $1. Use --help for usage." ;;
  esac
done

# ------------------------------
# Validate and prepare
# ------------------------------
[[ -d "$SVG_LOGO_ROOT" ]] || die "SVG source directory not found: $SVG_LOGO_ROOT"
ensure_dir "$WEB_LOGO_ROOT"

parse_sizes "$ICON_SIZES"
select_renderer

# Collect SVG files
mapfile -d '' SVGS < <(find "$SVG_LOGO_ROOT" -maxdepth 1 -type f \( -iname '*.svg' -o -iname '*.svgz' \) -print0 | sort -z)
[[ ${#SVGS[@]} -gt 0 ]] || die "No SVG files found in: $SVG_LOGO_ROOT"

log "Renderer: $RENDERER"
log "Source:   $SVG_LOGO_ROOT"
log "Output:   $WEB_LOGO_ROOT"
log "Sizes:    ${SIZES[*]}"
log "Jobs:     $JOBS"
[[ $FORCE -eq 1 ]] && log "Force:    overwrite enabled"

# ------------------------------
# Work queue
# ------------------------------
# Build a list of commands to run in parallel
TMP_CMDS="$(mktemp)"
cleanup() { rm -f "$TMP_CMDS"; }
trap cleanup EXIT

for svg in "${SVGS[@]}"; do
  svg="${svg%$'\n'}"
  base="$(basename "$svg")"
  name="${base%.*}"
  # sanitize: replace spaces with underscores
  safe_name="${name// /_}"

  for size in "${SIZES[@]}"; do
    out_file="$WEB_LOGO_ROOT/${safe_name}-${size}.png"
    if [[ -f "$out_file" && $FORCE -ne 1 ]]; then
      # Skip existing unless forcing
      continue
    fi
    # Quote each arg safely for bash -c eval
    printf 'src=%q size=%q out=%q; ' "$svg" "$size" "$out_file" >>"$TMP_CMDS"
    # Recreate parent dirs (flat by default)
    printf 'mkdir -p %q; ' "$(dirname "$out_file")" >>"$TMP_CMDS"
    # Do render to temp then atomic move
    printf 'tmp=$(mktemp %q); ' "$out_file.XXXXXX" >>"$TMP_CMDS"
    printf 'if render_png %q %q "$tmp"; then mv -f "$tmp" %q; else rm -f "$tmp"; exit 1; fi\n' "$svg" "$size" "$out_file" >>"$TMP_CMDS"
  done
done

# Nothing to do?
if [[ ! -s "$TMP_CMDS" ]]; then
  log "All target PNGs already exist. Nothing to do."
  exit 0
fi

# Export functions/vars for subshells
export -f render_png have die
export RENDERER

# Run in parallel
if have xargs; then
  # shellcheck disable=SC2016
  xargs -P "$JOBS" -I {} bash -c '{}' <"$TMP_CMDS"
else
  # Fallback: sequential
  while IFS= read -r line; do bash -c "$line"; done <"$TMP_CMDS"
fi

log "Done. PNG icons are in: $WEB_LOGO_ROOT"

# Optional: create common PWA/Apple icon aliases for the first SVG only (uncomment to enable)
# first_svg_base="$(basename "${SVGS[0]}")"
# first_name="${first_svg_base%.*}"
# ln -sf "${first_name}-180.png" "$WEB_LOGO_ROOT/apple-touch-icon.png"
# ln -sf "${first_name}-192.png" "$WEB_LOGO_ROOT/android-chrome-192x192.png"
# ln -sf "${first_name}-512.png" "$WEB_LOGO_ROOT/android-chrome-512x512.png"
# ln -sf "${first_name}-16.png"  "$WEB_LOGO_ROOT/favicon-16x16.png"
# ln -sf "${first_name}-32.png"  "$WEB_LOGO_ROOT/favicon-32x32.png"