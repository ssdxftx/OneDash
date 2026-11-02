#!/usr/bin/env python3
"""Guard the UI consistency rules from the v12 audit."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FEATURES = ROOT / "lib" / "presentation"


def action_icons(source: str) -> list[str]:
    icons: list[str] = []
    for match in re.finditer(r"actions:\s*\[", source):
        index = match.end()
        depth = 1
        while index < len(source) and depth:
            if source[index] == "[":
                depth += 1
            elif source[index] == "]":
                depth -= 1
            index += 1
        icons.extend(re.findall(r"TablerIcons\.(\w+)", source[match.end() : index - 1]))
    return icons


def main() -> int:
    failures: list[str] = []
    for path in FEATURES.rglob("*.dart"):
        source = path.read_text()
        relative = path.relative_to(ROOT)
        if "FloatingActionButton" in source:
            failures.append(f"{relative}: new entries must live in the app bar")
        for match in re.finditer(r"actions:\s*\[", source):
            block = source[match.end() :]
            depth = 1
            cursor = 0
            while cursor < len(block) and depth:
                if block[cursor] == "[":
                    depth += 1
                elif block[cursor] == "]":
                    depth -= 1
                cursor += 1
            icons = re.findall(r"TablerIcons\.(\w+)", block[: cursor - 1])
            if "refresh" in icons and icons.index("refresh") != 0:
                line = source[: match.start()].count("\n") + 1
                failures.append(f"{relative}:{line}: refresh must be the first action")

    dead_helpers = ["formatTimeAgo(", "formatFileModTime("]
    for helper in dead_helpers:
        for path in (ROOT / "lib").rglob("*.dart"):
            if helper in path.read_text():
                failures.append(f"{path.relative_to(ROOT)}: remove dead helper {helper}")

    if failures:
        print("UI consistency check failed:")
        for failure in failures:
            print(f"  {failure}")
        return 1
    print("UI consistency check passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
