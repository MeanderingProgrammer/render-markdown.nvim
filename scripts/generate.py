import abc
from argparse import ArgumentParser
from dataclasses import dataclass
from pathlib import Path
from typing import override


@dataclass(frozen=True)
class Generator(abc.ABC):
    @abc.abstractmethod
    def name(self, size: str) -> str:
        pass

    @abc.abstractmethod
    def create(self, n: int) -> list[list[str]]:
        pass


@dataclass(frozen=True)
class Heading(Generator):
    @override
    def name(self, size: str) -> str:
        return f"{size}.md"

    @override
    def create(self, n: int) -> list[list[str]]:
        sections: list[list[str]] = []
        for i in range(10 * n):
            sections.append([f"{'#' * ((i % 6) + 1)} Title {i}"])
        return sections


@dataclass(frozen=True)
class Table(Generator):
    @override
    def name(self, size: str) -> str:
        return f"{size}-table.md"

    @override
    def create(self, n: int) -> list[list[str]]:
        sections: list[list[str]] = []
        for i in range(n // 2):
            sections.append([f"# Table {i}"])
            sections.append(self.table(n))
        return sections

    def table(self, n: int) -> list[str]:
        rows: list[str] = []
        rows.append(f"| `Column 1`     | **Column 2**     | *Column 3*     |")
        rows.append(f"| -------------- | :--------------- | -------------: |")
        for i in range(n):
            rows.append(f"| Row {i:<4} Col 1 | `Row {i:<4} Col 2` | Row {i:<4} Col 3 |")
        return rows


def main(force: bool) -> None:
    sizes: list[str] = ["small", "medium", "large"]
    generators: list[Generator] = [Heading(), Table()]
    for i, size in enumerate(sizes):
        n: int = 10 ** (i + 1)
        for generator in generators:
            path = Path("temp").joinpath(generator.name(size))
            if not path.exists() or force:
                sections = generator.create(n)
                content = "\n\n".join(["\n".join(section) for section in sections])
                path.write_text(content)


if __name__ == "__main__":
    parser = ArgumentParser(description="Generate sample data for benchmarking")
    parser.add_argument("--force", action="store_true")
    args = parser.parse_args()
    main(args.force)
