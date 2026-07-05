#!/usr/bin/env bash
# Regenerate the gallery block in index.html from the images in gallery/.
# Images are sorted by filename; use a numeric prefix (e.g. 0500_) to control
# display order. Run this after adding or removing images.
set -euo pipefail
cd "$(dirname "$0")"

INDEX=index.html
START='<!-- gallery:start -->'
END='<!-- gallery:end -->'

if ! grep -qF "$START" "$INDEX" || ! grep -qF "$END" "$INDEX"; then
    echo "error: gallery markers not found in $INDEX" >&2
    exit 1
fi

items=$(find gallery -maxdepth 1 -type f \
        \( -iname '*.jpeg' -o -iname '*.jpg' -o -iname '*.png' -o -iname '*.webp' \) \
        | sort \
        | while IFS= read -r f; do
    printf '        <a href="%s"><img src="%s" alt="Woodcraft piece"></a>\n' "$f" "$f"
done)

awk -v start="$START" -v end="$END" -v items="$items" '
    index($0, start) { print; if (items != "") print items; skip = 1; next }
    index($0, end)   { skip = 0 }
    !skip            { print }
' "$INDEX" > "$INDEX.tmp"
mv "$INDEX.tmp" "$INDEX"

count=$(printf '%s' "$items" | grep -c '<a ' || true)
echo "gallery synced: $count image(s)"
