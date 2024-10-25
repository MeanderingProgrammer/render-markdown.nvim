import subprocess
from argparse import ArgumentParser
from pathlib import Path

from PIL import Image

INFO: dict[str, tuple[int, str]] = dict(
    heading_code=(550, "## Heading 2"),
    list_table=(550, ""),
    box_dash_quote=(250, ""),
    latex=(250, ""),
    callout=(750, ""),
)


def main(name: str) -> None:
    file = Path(f"demo/{name}.md")
    assert file.exists()

    create_gif(name, file)
    create_screenshot(name)


def create_gif(name: str, file: Path) -> None:
    gif = Path(f"demo/{name}.gif")
    if gif.exists():
        gif.unlink()

    height, content = INFO[name]

    tape = Path("demo/demo.tape")
    tape.write_text(tape_content(file, gif, height, content))
    result = subprocess.run(["vhs", tape])
    assert result.returncode == 0
    tape.unlink()


def create_screenshot(name: str) -> None:
    screenshot = Path(f"demo/{name}.png")
    if screenshot.exists():
        screenshot.unlink()

    default, rendered = Path("default.png"), Path("rendered.png")
    assert default.exists() and rendered.exists()

    left, right = Image.open(default), Image.open(rendered)

    mode, width, height = left.mode, left.width, left.height
    assert mode == right.mode and width == right.width and height == right.height

    combined = Image.new(mode, (2 * width, height))
    combined.paste(left, (0, 0))
    combined.paste(right, (width, 0))
    combined.save(screenshot)

    default.unlink()
    rendered.unlink()


def tape_content(file: Path, gif: Path, height: int, content: str) -> str:
    result = Path("demo/format.tape").read_text()
    result = result.replace("INPUT", str(file))
    result = result.replace("OUTPUT", str(gif))
    result = result.replace("WIDTH", str(550))
    result = result.replace("HEIGHT", str(height))
    result = result.replace("WRITE", get_write(content))
    result = result.replace("MOVE", get_move(file))
    return result


def get_write(content: str) -> str:
    write: list[str] = []
    if len(content) > 0:
        write.append('Type "o"')
        write.append("Enter")
        write.append(f'Type "{content}" Escape')
        write.append('Type "0" Sleep 2s')
    return "\n".join(write)


def get_move(file: Path) -> str:
    move: list[str] = []
    # Get lines so we know how to scroll down, account for starting on second line
    lines: list[str] = file.read_text().splitlines()[2:]
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
