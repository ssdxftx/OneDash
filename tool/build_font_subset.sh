#!/usr/bin/env bash
# Regenerate MiSans subsets from the full fonts: GB2312 plus every localized glyph.
set -euo pipefail
cd "$(dirname "$0")/.."

python3 - <<'PY'
import glob
import json

chars = set()
for high in range(0xA1, 0xF8):
    for low in range(0xA1, 0xFF):
        try:
            chars.add(bytes([high, low]).decode("gb2312"))
        except UnicodeDecodeError:
            pass
for path in glob.glob("lib/core/localization/l10n/*.arb"):
    with open(path, encoding="utf-8") as handle:
        for value in json.load(handle).values():
            if isinstance(value, str):
                chars.update(value)
with open("/tmp/onedash-font-chars.txt", "w", encoding="utf-8") as handle:
    handle.write("".join(sorted(chars)))
PY

UNICODES="U+0020-007E,U+00A0-00FF,U+2000-206F,U+2190-21FF,U+25A0-25FF,U+2600-26FF,U+3000-303F,U+FF00-FFEF"
while IFS=: read -r output source; do
  pyftsubset "assets/fonts/${source}.ttf" \
    --text-file=/tmp/onedash-font-chars.txt \
    --unicodes="$UNICODES" \
    --output-file="assets/fonts/${output}.ttf"
done <<'FONTS'
MiSans-Subset:MiSans-Regular
MiSans-Medium-Subset:MiSans-Medium
MiSans-Semibold-Subset:MiSans-Semibold
FONTS

python3 tool/check_font_coverage.py
