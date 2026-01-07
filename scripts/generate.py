import argparse
from dataclasses import dataclass
from pathlib import Path
from typing import Protocol


class Generator(Protocol):
    def name(self, size: str) -> str: ...

    def create(self, n: int) -> list[list[str]]: ...


@dataclass(frozen=True)
class Heading:
    def name(self, size: str) -> str:
        return f"{size}.md"

    def create(self, n: int) -> list[list[str]]:
        sections: list[list[str]] = []
        for i in range(10 * n):
            sections.append([f"{'#' * ((i % 6) + 1)} Title {i}"])
        return sections


@dataclass(frozen=True)
class Table:
    def name(self, size: str) -> str:
        return f"{size}-table.md"

    def create(self, n: int) -> list[list[str]]:
        sections: list[list[str]] = []
        for i in range(n // 2):
            sections.append([f"# Table {i}"])
            sections.append(self.table(n))
        return sections

    def table(self, n: int) -> list[str]:
        rows: list[str] = []
        rows.append("| `Column 1`     | **Column 2**     | *Column 3*     |")
        rows.append("| -------------- | :--------------- | -------------: |")
        for i in range(n):
            rows.append(f"| Row {i:<4} Col 1 | `Row {i:<4} Col 2` | Row {i:<4} Col 3 |")
        return rows


def main(force: bool) -> None:
    generators: list[Generator] = [Heading(), Table()]
    sizes: dict[str, int] = dict(small=10, medium=100, large=1000)
    for generator in generators:
        for size, n in sizes.items():
            path = Path("temp") / generator.name(size)
            if not path.exists() or force:
                sections = generator.create(n)
                content = "\n\n".join(["\n".join(section) for section in sections])
                path.write_text(content)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate data for benchmarking")
    parser.add_argument("--force", action="store_true")
    args = parser.parse_args()
    main(args.force)
