#!/usr/bin/env python3
"""Entry point so agents never import the store themselves."""

from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from controller.cli import main

if __name__ == "__main__":
    raise SystemExit(main())
