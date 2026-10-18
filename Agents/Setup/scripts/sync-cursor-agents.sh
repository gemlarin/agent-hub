#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname "$0")/../../.." && pwd)
# shellcheck disable=SC1091
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/find-python.sh"
exec_python "$ROOT/Agents/Setup/scripts/sync_cursor_agents.py"
