#!/usr/bin/env python3
"""Command-line entry point for the AI/human contribution cleaning stage."""

import os
from pathlib import Path

# 本地密钥文件（位于本目录、已被 .gitignore 排除，不进入版本库）。
# 仅在进程环境变量 NVIDIA_API_KEY 缺失时作为回退读取，便于本地直接运行。
_KEY_FILE = Path(__file__).resolve().parent / "nim_api_key.local"
if not os.environ.get("NVIDIA_API_KEY") and _KEY_FILE.is_file():
    try:
        for line in _KEY_FILE.read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if line.startswith("NVIDIA_API_KEY="):
                os.environ["NVIDIA_API_KEY"] = line.split("=", 1)[1].strip()
                break
    except OSError:
        pass

from contribution_recognition.cli import main


if __name__ == "__main__":
    raise SystemExit(main())
