#!/usr/bin/env python3
"""Guard the sheet whitelist and list-page menu rules."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FEATURES = ROOT / "lib" / "presentation" / "features"
COMMON = ROOT / "lib" / "presentation" / "common"

POPUP_ALLOWLIST = {
    Path("lib/presentation/features/files/screens/files_page.dart"),
    Path("lib/presentation/features/files/screens/file_history_page.dart"),
}
MODAL_ALLOWLIST = {
    Path("lib/presentation/common/components/bottom_sheet_surface.dart"),
}


def main() -> int:
    failures: list[str] = []
    for path in (ROOT / "lib").rglob("*.dart"):
        relative = path.relative_to(ROOT)
        source = path.read_text()
        if "PopupMenuButton" in source and relative not in POPUP_ALLOWLIST:
            failures.append(
                f"{relative}: PopupMenuButton is only allowed in file toolbars"
            )
        if "showModalBottomSheet" in source and relative not in MODAL_ALLOWLIST:
            failures.append(
                f"{relative}: use showAppSheet or showSelectionMenu instead"
            )
        for match in re.finditer(r"showAppSheet(?:<[^>]*>)?\s*\(", source):
            start = match.end() - 1
            depth = 0
            for index in range(start, len(source)):
                if source[index] == "(":
                    depth += 1
                elif source[index] == ")":
                    depth -= 1
                    if depth == 0:
                        break
            block = source[start:index]
            if "TextField" in block:
                line = source[: match.start()].count("\n") + 1
                failures.append(
                    f"{relative}:{line}: input forms must use SimpleFormPage"
                )

    if failures:
        print("sheet whitelist check failed:")
        for failure in failures:
            print(f"  {failure}")
        return 1
    print("sheet whitelist check passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
