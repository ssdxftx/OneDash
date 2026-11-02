#!/usr/bin/env bash
set -euo pipefail

# Each batch must lower this number. It may never increase.
python3 tool/check_action_reachability.py --max-unwired "${1:-0}"
