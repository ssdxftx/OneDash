#!/usr/bin/env python3
"""Fail when localized text uses a glyph missing from the bundled MiSans subset."""

from __future__ import annotations

import glob
import json
import sys
from pathlib import Path

from fontTools.ttLib import TTFont

ROOT = Path(__file__).resolve().parent.parent
SUBSETS = [
    "assets/fonts/MiSans-Subset.ttf",
    "assets/fonts/MiSans-Medium-Subset.ttf",
    "assets/fonts/MiSans-Semibold-Subset.ttf",
]


def glyphs(path: Path) -> set[int]:
    font = TTFont(path)
    result: set[int] = set()
    for table in font["cmap"].tables:
        result |= set(table.cmap)
    return result


def localized_chars() -> set[str]:
    chars: set[str] = set()
    for raw in glob.glob(str(ROOT / "lib/core/localization/l10n/*.arb")):
        data = json.loads(Path(raw).read_text(encoding="utf-8"))
        for value in data.values():
            if isinstance(value, str):
                chars.update(char for char in value if not char.isspace())
    return chars


def main() -> int:
    chars = localized_chars()
    failures: list[str] = []
    for relative in SUBSETS:
        path = ROOT / relative
        if not path.exists():
            failures.append(f"{relative}: missing")
            continue
        available = glyphs(path)
        missing = sorted(char for char in chars if ord(char) not in available)
        if missing:
            failures.append(f"{relative}: missing {''.join(missing)}")
    if failures:
        for failure in failures:
            print(failure, file=sys.stderr)
        return 1
    print("font coverage check passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
