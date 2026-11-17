#!/usr/bin/env python3
"""Compare OneDash API calls with a local 1Panel source tree.

Usage:
    python3 scripts/check_1panel_api_coverage.py --panel-root /tmp/1panel-latest
    python3 scripts/check_1panel_api_coverage.py --panel-root ../1Panel --json

The panel tree should be checked out at the 1Panel release used by the app.
The script exits non-zero when a real client call has no panel route. Dynamic
Dart paths (for example `${_typePath(...)}`) are reported separately because
they cannot be matched statically.
"""
from __future__ import annotations

import argparse
import glob
import json
import os
import re
import sys
from collections import Counter

METHODS = {"GET", "POST", "PUT", "DELETE", "PATCH", "ANY"}
ROUTE_RE = re.compile(r"(\w+)\.(GET|POST|PUT|DELETE|PATCH|Any)\(\"([^\"]*)\"")
GROUP_RE = re.compile(r"(\w+)\s*:?=\s*(\w+)\.Group\(\"([^\"]*)\"\)")
CALL_RE = re.compile(r"_client\.(get|post|put|delete|patch|postMultipart|postStream)\b")


def normalize_path(path: str) -> str:
    path = re.sub(r"\$\{[^}]+\}", "{p}", path)
    path = re.sub(r"\$[A-Za-z_]\w*", "{p}", path)
    path = re.sub(r"(?<=/)\d+(?=/|$)", "{p}", path)
    path = re.sub(r":[A-Za-z_]\w*", "{p}", path)
    path = re.sub(r"\*[A-Za-z_]\w*", "{p}", path)
    path = re.sub(r"/+", "/", path)
    if len(path) > 1 and path.endswith("/"):
        path = path[:-1]
    return path


def join_path(prefix: str, path: str) -> str:
    if not prefix:
        return "/" + path.lstrip("/")
    return prefix.rstrip("/") + "/" + path.lstrip("/")


def iter_go_files(root: str):
    for folder in ("agent/router", "core/router"):
        yield from sorted(glob.glob(os.path.join(root, folder, "*.go")))


def extract_routes(panel_root: str) -> list[dict]:
    routes: list[dict] = []
    for filename in iter_go_files(panel_root):
        relative = os.path.relpath(filename, panel_root)
        is_core = relative.startswith("core/")
        root = "/api/v2/core" if is_core else "/api/v2"
        prefixes: dict[str, str] = {"Router": root, "group": root}
        for line in open(filename, encoding="utf-8"):
            group = GROUP_RE.search(line)
            if group:
                variable, parent, suffix = group.groups()
                base = prefixes.get(parent, root if parent == "group" else "")
                if base:
                    prefixes[variable] = join_path(base, suffix)
                continue
            route = ROUTE_RE.search(line)
            if not route:
                continue
            variable, method, path = route.groups()
            prefix = prefixes.get(variable)
            if prefix is None:
                continue
            full = join_path(prefix, path)
            routes.append(
                {
                    "method": "ANY" if method == "Any" else method,
                    "path": full,
                    "norm": normalize_path(full),
                    "file": relative,
                }
            )
    return routes


def parse_first_argument(source: str, start: int) -> str:
    depth = 0
    quote: str | None = None
    index = start
    while index < len(source):
        char = source[index]
        if quote:
            if char == "\\":
                index += 2
                continue
            if char == quote:
                quote = None
        elif char in "'\"":
            quote = char
        elif char in "([{<":
            depth += 1
        elif char in ")]}>":
            if char == ")" and depth == 0:
                return source[start:index]
            depth -= 1
        elif char == "," and depth == 0:
            return source[start:index]
        index += 1
    return source[start:index]


def extract_calls(client_root: str) -> list[dict]:
    calls: list[dict] = []
    for filename in sorted(glob.glob(os.path.join(client_root, "lib/data/api/*.dart"))):
        source = open(filename, encoding="utf-8").read()
        for match in CALL_RE.finditer(source):
            raw_method = match.group(1)
            cursor = match.end()
            if cursor < len(source) and source[cursor] == "<":
                depth = 0
                while cursor < len(source):
                    if source[cursor] == "<":
                        depth += 1
                    elif source[cursor] == ">":
                        depth -= 1
                        if depth == 0:
                            cursor += 1
                            break
                    cursor += 1
            while cursor < len(source) and source[cursor] in " \t\r\n":
                cursor += 1
            if cursor >= len(source) or source[cursor] != "(":
                continue
            expression = parse_first_argument(source, cursor + 1).strip()
            method = {
                "get": "GET",
                "put": "PUT",
                "delete": "DELETE",
                "patch": "PATCH",
            }.get(raw_method, "POST")
            paths: list[str] = []
            if expression[:1] in "'\"":
                quote = expression[0]
                end = expression.find(quote, 1)
                literal = expression[1:end]
                if "$_base" in literal:
                    paths.append(literal.replace("$_base", "/api/v2/core/mcp"))
                else:
                    paths.append(literal)
            else:
                paths.extend(re.findall(r"'(/api/v2[^']*)'", expression))
            for path in paths:
                calls.append(
                    {
                        "method": method,
                        "path": path,
                        "norm": normalize_path(path),
                        "file": os.path.relpath(filename, client_root),
                        "expression": expression[:160],
                    }
                )
    unique: dict[tuple[str, str], dict] = {}
    for call in calls:
        unique.setdefault((call["method"], call["norm"]), call)
    return list(unique.values())


def extract_referenced_paths(client_root: str) -> set[str]:
    referenced: set[str] = set()
    for filename in glob.glob(os.path.join(client_root, "lib/data/api/*.dart")):
        source = open(filename, encoding="utf-8").read()
        for match in re.finditer(r"'(/api/v2[^']*)'", source):
            value = match.group(1).replace("$_base", "/api/v2/core/mcp")
            if "$" not in value:
                referenced.add(normalize_path(value))
    return referenced


def matches(route: dict, call: dict) -> bool:
    if route["method"] not in (call["method"], "ANY"):
        return False
    route_parts = route["norm"].strip("/").split("/")
    call_parts = call["norm"].strip("/").split("/")
    if len(route_parts) != len(call_parts):
        return False
    return all(
        left == right or left == "{p}" or right == "{p}"
        for left, right in zip(route_parts, call_parts)
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--panel-root",
        default=os.environ.get("ONEDASH_PANEL_ROOT", "/tmp/1panel-latest"),
        help="1Panel source tree checked out at the target release",
    )
    parser.add_argument(
        "--client-root",
        default=os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
        help="OneDash repository root",
    )
    parser.add_argument("--json", action="store_true", help="print JSON output")
    parser.add_argument(
        "--strict",
        action="store_true",
        help="also fail when panel routes have no client call",
    )
    args = parser.parse_args()

    if not os.path.isdir(args.panel_root):
        print(
            f"1Panel source not found: {args.panel_root}\n"
            "Clone the target release first, for example:\n"
            "  git clone --depth 1 --branch v2.5.1 "
            "https://github.com/1Panel-dev/1Panel.git /tmp/1panel-latest",
            file=sys.stderr,
        )
        return 2

    routes = extract_routes(args.panel_root)
    calls = extract_calls(args.client_root)
    referenced = extract_referenced_paths(args.client_root)
    unmatched_calls = [call for call in calls if not any(matches(route, call) for route in routes)]
    uncovered_routes = [
        route
        for route in routes
        if not any(matches(route, call) for call in calls)
        and route["norm"] not in referenced
    ]
    dynamic_calls = [call for call in unmatched_calls if "$" in call["expression"] or "{p}" in call["path"]]
    real_unmatched = [call for call in unmatched_calls if call not in dynamic_calls]

    report = {
        "panel_root": os.path.abspath(args.panel_root),
        "client_root": os.path.abspath(args.client_root),
        "routes": len(routes),
        "route_methods": dict(Counter(route["method"] for route in routes)),
        "calls": len(calls),
        "referenced_paths": len(referenced),
        "unmatched_calls": unmatched_calls,
        "dynamic_calls": dynamic_calls,
        "uncovered_routes": uncovered_routes,
    }

    if args.json:
        print(json.dumps(report, indent=2, ensure_ascii=False))
    else:
        print(f"panel routes : {len(routes)}")
        print(f"client calls : {len(calls)}")
        print(f"unmatched    : {len(unmatched_calls)} ({len(real_unmatched)} real, {len(dynamic_calls)} dynamic)")
        print(f"uncalled     : {len(uncovered_routes)}")
        if real_unmatched:
            print("\nClient calls without a panel route:")
            for call in real_unmatched:
                print(f"  {call['method']:6} {call['path']}  {call['file']}")
        if dynamic_calls:
            print("\nDynamic calls skipped:")
            for call in dynamic_calls:
                print(f"  {call['method']:6} {call['path']}  {call['file']}")
        if uncovered_routes:
            print("\nPanel routes without a client call:")
            for route in uncovered_routes:
                print(f"  {route['method']:6} {route['path']}  {route['file']}")

    if real_unmatched:
        return 1
    if args.strict and uncovered_routes:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
