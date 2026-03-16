#!/usr/bin/env bash
#
# duti-defaults.sh — ustawia domyślne aplikacje do otwierania plików
# Wymaga: brew install duti
# Uruchom: bash ~/.dotfiles/duti-defaults.sh

set -euo pipefail

if ! command -v duti &>/dev/null; then
  echo "❌ duti nie znaleziony. Zainstaluj: brew install duti"
  exit 1
fi

if [ "${DRY_RUN:-false}" = "true" ]; then
  echo "(DRY RUN — nic nie zmieniam, tylko pokazuję co bym ustawił)"
  echo ""
  duti() { if [ "$1" = "-s" ]; then echo "  duti -s $2 $3 ${4:-}"; fi; }
fi

echo "Ustawiam domyślne aplikacje..."

# ─── EDYTOR KODU: Zed ────────────────────────────────────────────────────────
ZED="dev.zed.Zed"

code_extensions=(
  # Web
  .css .scss .sass .less
  .js .jsx .mjs .cjs
  .ts .tsx .mts
  .vue .svelte .astro
  # Data / config
  .json .jsonc .json5
  .yaml .yml
  .toml
  .xml .xsl .xslt
  .csv  # override — wolę Zed niż Numbers do edycji
  .env .env.local .env.example
  .ini .cfg .conf .config
  .properties
  .editorconfig
  # Scripting / backend
  .py .pyi .pyw
  .rb .erb
  .go
  .rs
  .java .kt .kts .groovy .gradle
  .c .h .cpp .hpp .cc
  .swift
  .lua
  .php
  # Shell
  .sh .bash .zsh .fish
  .zshrc .bashrc .bash_profile .zprofile
  # DevOps
  .tf .tfvars .hcl
  .dockerfile
  .vagrantfile
  .bicep
  # Markdown / docs
  .md .mdx .markdown
  .rst .adoc
  # SQL
  .sql .psql
  # Misc
  .graphql .gql
  .prisma
  .proto
  .r .R
  .log
  .diff .patch
  .gitignore .gitattributes .gitmodules
  .dockerignore
  .eslintrc .prettierrc .stylelintrc
  .svg  # XML-based, edytuję w kodzie
  .tex .bib .cls .sty
  .lock  # package-lock, yarn.lock etc
  .plist
  .txt
)

for ext in "${code_extensions[@]}"; do
  duti -s "$ZED" "$ext" all 2>/dev/null
done
echo "  ✓ Pliki kodu/config → Zed"

# ─── PODGLĄD: Preview ────────────────────────────────────────────────────────
PREVIEW="com.apple.Preview"

image_extensions=(
  .png .jpg .jpeg .gif .bmp .tiff .tif
  .webp .heic .heif .ico .icns
  .raw .cr2 .nef .arw .dng
)

for ext in "${image_extensions[@]}"; do
  duti -s "$PREVIEW" "$ext" all 2>/dev/null
done
duti -s "$PREVIEW" .pdf all 2>/dev/null
echo "  ✓ Obrazy + PDF → Preview"

# ─── WIDEO / AUDIO: VLC ──────────────────────────────────────────────────────
VLC="org.videolan.vlc"

media_extensions=(
  # Video
  .mp4 .mkv .avi .mov .wmv .flv .webm .m4v .mpg .mpeg .3gp .ogv
  # Audio
  .mp3 .flac .aac .ogg .wav .wma .m4a .opus .aiff .alac
)

for ext in "${media_extensions[@]}"; do
  duti -s "$VLC" "$ext" all 2>/dev/null
done
echo "  ✓ Wideo + audio → VLC"

# ─── PISANIE: iA Writer ──────────────────────────────────────────────────────
IA="pro.writer.mac"

duti -s "$IA" .rtf all 2>/dev/null
echo "  ✓ rtf → iA Writer"

# ─── eBOOKI: Calibre ─────────────────────────────────────────────────────────
CALIBRE="net.kovidgoyal.calibre"

ebook_extensions=(
  .epub .mobi .azw .azw3 .fb2 .djvu
)

for ext in "${ebook_extensions[@]}"; do
  duti -s "$CALIBRE" "$ext" all 2>/dev/null
done
echo "  ✓ eBooki → Calibre"

# ─── OFFICE: Microsoft (firmowy) / Apple iWork (prywatny) ────────────────────
if [ "${CORPORATE:-false}" = "true" ]; then
  SHEETS="com.microsoft.Excel"
  SLIDES="com.microsoft.Powerpoint"
  DOCS="com.microsoft.Word"
  OFFICE_LABEL="Microsoft Office"
else
  SHEETS="com.apple.iWork.Numbers"
  SLIDES="com.apple.iWork.Keynote"
  DOCS="com.apple.iWork.Pages"
  OFFICE_LABEL="Apple iWork"
fi

duti -s "$SHEETS" .xlsx all 2>/dev/null
duti -s "$SHEETS" .xls all 2>/dev/null
duti -s "com.apple.iWork.Numbers" .numbers all 2>/dev/null

duti -s "$SLIDES" .pptx all 2>/dev/null
duti -s "$SLIDES" .ppt all 2>/dev/null
duti -s "com.apple.iWork.Keynote" .key all 2>/dev/null

duti -s "$DOCS" .docx all 2>/dev/null
duti -s "$DOCS" .doc all 2>/dev/null
duti -s "com.apple.iWork.Pages" .pages all 2>/dev/null

echo "  ✓ Office → $OFFICE_LABEL (.numbers/.key/.pages zawsze Apple)"

echo ""
echo "✅ Gotowe! Domyślne aplikacje ustawione."
echo ""
echo "Weryfikacja (losowe sprawdzenie):"
echo "  .md  → $(duti -x md 2>/dev/null | head -1)"
echo "  .py  → $(duti -x py 2>/dev/null | head -1)"
echo "  .pdf → $(duti -x pdf 2>/dev/null | head -1)"
echo "  .mp4 → $(duti -x mp4 2>/dev/null | head -1)"
echo "  .txt → $(duti -x txt 2>/dev/null | head -1)"
