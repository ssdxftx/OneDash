#!/usr/bin/env python3
"""Guard the UI consistency rules from the v12 audit."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FEATURES = ROOT / "lib" / "presentation"


def top_level_action_icons(actions_src: str) -> list[str]:
    """只取 actions 数组顶层的按钮图标，忽略 onPressed 闭包里的菜单项。"""
    icons: list[str] = []
    depth = 0
    index = 0
    while index < len(actions_src):
        char = actions_src[index]
        if char in "([{":
            depth += 1
        elif char in ")]}":
            depth -= 1
        elif depth == 0 and actions_src.startswith("AppIconButton(", index):
            body = _balanced_block(actions_src, index + len("AppIconButton"), "(", ")")
            match = re.search(r"icon:\s*([^,\n]+)", body)
            if match:
                icons.append(match.group(1).strip())
            index += len("AppIconButton(") + len(body)
            continue
        index += 1
    return icons


def _balanced_block(source: str, open_index: int, opening: str, closing: str) -> str:
    depth = 0
    for index in range(open_index, len(source)):
        if source[index] == opening:
            depth += 1
        elif source[index] == closing:
            depth -= 1
            if depth == 0:
                return source[open_index + 1 : index]
    return source[open_index + 1 :]


def _call_blocks(source: str, name: str) -> list[str]:
    blocks: list[str] = []
    for match in re.finditer(rf"{name}(?:<[^>]*>)?\s*\(", source):
        open_index = source.index("(", match.start())
        blocks.append(_balanced_block(source, open_index, "(", ")"))
    return blocks


def main() -> int:
    failures: list[str] = []
    for path in FEATURES.rglob("*.dart"):
        source = path.read_text()
        relative = path.relative_to(ROOT)
        if "FloatingActionButton" in source:
            failures.append(f"{relative}: new entries must live in the app bar")
        for match in re.finditer(r"fontSize:\s*\d", source):
            line = source[: match.start()].count("\n") + 1
            failures.append(
                f"{relative}:{line}: use an AppTextStyles token instead of a numeric fontSize"
            )
        for match in re.finditer(r"fontFamily:\s*'monospace'", source):
            line = source[: match.start()].count("\n") + 1
            failures.append(
                f"{relative}:{line}: use AppTextStyles.mono instead of a monospace literal"
            )
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
            icons = top_level_action_icons(block[: cursor - 1])
            line = source[: match.start()].count("\n") + 1
            if any("refresh" in icon for icon in icons) and not (
                icons and "refresh" in icons[0]
            ):
                failures.append(f"{relative}:{line}: refresh must be the first action")
            names = [
                name
                for icon in icons
                for name in re.findall(r"TablerIcons\.(\w+)", icon)
            ]
            duplicates = {name for name in names if names.count(name) > 1}
            for name in sorted(duplicates):
                failures.append(f"{relative}:{line}: duplicate action icon {name}")
            if any("plus" in icon for icon in icons) and not (
                icons and "plus" in icons[-1]
            ):
                failures.append(
                    f"{relative}:{line}: create action must be the last action"
                )
        for block in _call_blocks(source, "PopupMenuButton"):
            if "action_refresh" in block or "TablerIcons.refresh" in block:
                line = source[: source.find(block)].count("\n") + 1
                failures.append(
                    f"{relative}:{line}: refresh must live in the app bar, not the menu"
                )

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
