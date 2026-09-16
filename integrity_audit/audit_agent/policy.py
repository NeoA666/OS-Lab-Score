from __future__ import annotations

import hashlib
import re
from dataclasses import dataclass
from pathlib import Path

from .errors import DataAccessError


SECTION_PATTERN = re.compile(r"^(#{2,3})\s+(\d+(?:\.\d+)*)(?:\.)?\s+(.+)$")


@dataclass(frozen=True)
class PolicySection:
    identifier: str
    heading: str
    content: str


class PolicyDocument:
    """Read-only, hash-addressed view of the Lab0 audit-policy document."""

    def __init__(self, path: Path) -> None:
        self.path = path.resolve()
        if not self.path.is_file():
            raise DataAccessError(f"课程规则文件不存在：{self.path}")
        self.content = self.path.read_text(encoding="utf-8")
        self.sha256 = hashlib.sha256(self.content.encode("utf-8")).hexdigest()
        self._sections = self._parse_sections()

    def _parse_sections(self) -> dict[str, PolicySection]:
        lines = self.content.splitlines()
        headings: list[tuple[int, int, str, str]] = []
        for index, line in enumerate(lines):
            match = SECTION_PATTERN.match(line)
            if match:
                headings.append((index, len(match.group(1)), match.group(2), match.group(3)))

        sections: dict[str, PolicySection] = {}
        for position, (start, level, identifier, heading) in enumerate(headings):
            end = len(lines)
            for next_start, next_level, _, _ in headings[position + 1 :]:
                if next_level <= level:
                    end = next_start
                    break
            sections[identifier] = PolicySection(
                identifier=identifier,
                heading=heading,
                content="\n".join(lines[start:end]).strip(),
            )
        return sections

    def inventory(self) -> dict[str, object]:
        return {
            "path": str(self.path),
            "sha256": self.sha256,
            "sections": [
                {"id": section.identifier, "heading": section.heading}
                for section in self._sections.values()
            ],
        }

    def get_section(self, identifier: str) -> dict[str, str]:
        section = self._sections.get(identifier)
        if section is None:
            available = ", ".join(self._sections)
            raise DataAccessError(f"不存在规则章节 {identifier}；可用章节：{available}")
        return {
            "id": section.identifier,
            "heading": section.heading,
            "content": section.content,
            "policy_sha256": self.sha256,
        }
