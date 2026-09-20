"""AI and human contribution recognition as an OS lab cleaning stage."""

ASSESSMENT_SCHEMA_VERSION = "ai-human-contribution-assessment/v3"
TOOL_VERSION = "3.2.0"

# The three standalone CLI tools share their output contract from the cleaning root.
import sys
from pathlib import Path

_cleaning_root = str(Path(__file__).resolve().parents[2])
if _cleaning_root not in sys.path:
    sys.path.append(_cleaning_root)
