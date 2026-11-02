#!/usr/bin/env python3
"""Fail when write API methods have no UI reference.

Parses lib/data/api/*_api.dart, keeps methods whose body issues POST/PUT/DELETE,
then looks for the method name under lib/presentation/.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
API_DIR = ROOT / "lib" / "data" / "api"
UI_DIR = ROOT / "lib" / "presentation"
ALLOWLIST = ROOT / "tool" / "unwired_allowlist.txt"

METHOD_RE = re.compile(
    r"^\s{2}(?:Future|Stream|void|String|int|bool|double|List|Map|dynamic)"
    r"[^\n]*?\s(\w+)\s*\("
)
WRITE_RE = re.compile(r"\.(?:post|put|delete)\b")


def api_methods(path: Path) -> dict[str, int]:
    lines = path.read_text().splitlines()
    starts: list[tuple[int, str]] = []
    for index, line in enumerate(lines):
        match = METHOD_RE.match(line)
        if match:
            starts.append((index, match.group(1)))
    methods: dict[str, int] = {}
    for position, (start, name) in enumerate(starts):
        end = starts[position + 1][0] if position + 1 < len(starts) else len(lines)
        body = "\n".join(lines[start:end])
        if WRITE_RE.search(body):
            methods[name] = start + 1
    return methods


def load_allowlist() -> set[str]:
    if not ALLOWLIST.exists():
        return set()
    values: set[str] = set()
    for line in ALLOWLIST.read_text().splitlines():
        value = line.split("#", 1)[0].strip()
        if value:
            values.add(value)
    return values


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--max-unwired", type=int, default=0)
    parser.add_argument("--verbose", action="store_true")
    args = parser.parse_args()

    ui_source = "\n".join(
        path.read_text(errors="ignore") for path in UI_DIR.rglob("*.dart")
    )
    allowed = load_allowlist()
    unwired: list[tuple[str, str, int]] = []
    total = 0
    for path in sorted(API_DIR.glob("*_api.dart")):
        for name, line in api_methods(path).items():
            total += 1
            if re.search(rf"\b{re.escape(name)}\b", ui_source):
                continue
            key = f"{path.name}:{name}"
            if key in allowed:
                continue
            unwired.append((path.name, name, line))

    print(f"write methods: {total}")
    print(f"unwired methods: {len(unwired)} (allowed: {len(allowed)})")
    if args.verbose:
        for file_name, name, line in unwired:
            print(f"  {file_name}:{line} {name}")
    if len(unwired) > args.max_unwired:
        print(
            f"FAIL: {len(unwired)} unwired write methods > {args.max_unwired}",
            file=sys.stderr,
        )
        return 1
    print(f"OK: <= {args.max_unwired}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
