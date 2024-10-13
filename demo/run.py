import subprocess
from argparse import ArgumentParser
from pathlib import Path

INFO: dict[str, tuple[int, str]] = dict(
    heading_code=(550, "## Heading 2"),
    list_table=(550, ""),
    box_dash_quote=(250, ""),
    latex=(250, ""),
    callout=(750, ""),
)


def main(name: str) -> None:
    in_file = Path(f"demo/{name}.md")
    assert in_file.exists()

    out_file = Path(f"demo/{name}.gif")
    if out_file.exists():
        out_file.unlink()

    height, content = INFO[name]

    tape = Path("demo/demo.tape")
    tape.write_text(tape_content(in_file, out_file, height, content))
    result = subprocess.run(["vhs", tape])
    assert result.returncode == 0
    tape.unlink()


def tape_content(in_file: Path, out_file: Path, height: int, to_write: str) -> str:
    content = Path("demo/format.tape").read_text()
    content = content.replace("INPUT", str(in_file))
    content = content.replace("OUTPUT", str(out_file))
    content = content.replace("WIDTH", str(550))
    content = content.replace("HEIGHT", str(height))
    content = content.replace("WRITE", get_write(to_write))
    content = content.replace("MOVE", get_move(in_file))
    return content


def get_write(content: str) -> str:
    write: list[str] = []
    if len(content) > 0:
        write.append('Type "o"')
        write.append("Enter")
        write.append(f'Type "{content}" Escape')
        write.append('Type "0" Sleep 2s')
    return "\n".join(write)


def get_move(in_file: Path) -> str:
    move: list[str] = []
    # Get lines so we know how to scroll down, account for starting on first line
    lines: list[str] = Path(in_file).read_text().splitlines()[1:]
    for line in lines:
        skip = ("    ", "def", "if")
        duration = 0.1 if line == "" or line.startswith(skip) else 0.75
        move.append(f"Down@{duration}s")
    return "\n".join(move)


if __name__ == "__main__":
    parser = ArgumentParser(description="Generate a demo recording using vhs")
    parser.add_argument("--name", type=str, required=True, choices=INFO.keys())
    args = parser.parse_args()
    main(args.name)
