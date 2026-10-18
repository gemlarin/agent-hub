#!/bin/sh
# Wrapper: OS-agnostic test lives in test-git-delegation-hook.py
set -eu
HERE=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
# shellcheck disable=SC1091
. "$HERE/find-python.sh"
exec_python "$HERE/test-git-delegation-hook.py" "$@"
