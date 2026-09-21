"""AI and human contribution recognition as an OS lab cleaning stage."""

# The shared output layout lives beside the three tools, one directory above
# this package's command-line root.  Keep the entry point runnable after the
# release directory is copied without requiring a package installation.
from pathlib import Path
import sys

_CLEANING_TOOL_ROOT = Path(__file__).resolve().parents[2]
if str(_CLEANING_TOOL_ROOT) not in sys.path:
    sys.path.insert(0, str(_CLEANING_TOOL_ROOT))

ASSESSMENT_SCHEMA_VERSION = "ai-human-contribution-assessment/v3"
TOOL_VERSION = "3.2.0"
