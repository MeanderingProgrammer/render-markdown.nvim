import time
from argparse import ArgumentParser
from pathlib import Path

import pyautogui


def main(cols: int, rows: int, file: str, cast: str, content: str) -> None:
    # Open new tmux window
    pyautogui.hotkey("`", "c")
    time.sleep(1.0)

    # Get lines so we know how to scroll down, account for starting on first line
    lines: list[str] = Path(file).read_text().splitlines()[1:]

    # Start recording demo file
    # https://docs.asciinema.org/manual/cli/usage/
    record_command: list[str] = [
        "asciinema rec",
        f"--cols {cols} --rows {rows}",
        f"--command 'nvim {file}' {cast}",
    ]
    pyautogui.write(" ".join(record_command))
    pyautogui.press("enter")
    time.sleep(2.0)

    if len(content) > 0:
        # Start typing in content
        pyautogui.press("o")
        pyautogui.press("enter")
        pyautogui.write(content, interval=0.1)
        # Enter normal mode
        pyautogui.press("esc")
        time.sleep(2.0)

    insert_normal(1)

    # Scroll down
    for line in lines:
        pyautogui.press("j")
        skip = ("    ", "def", "if")
        duration = 0 if len(line) == 0 or line.startswith(skip) else 0.75
        time.sleep(duration)

    insert_normal(1)

    # Close demo file
    pyautogui.write(":q!")
    pyautogui.press("enter")
    time.sleep(0.5)

    # Close tmux window
    pyautogui.write("exit")
    pyautogui.press("enter")


def insert_normal(duration: float) -> None:
    pyautogui.press("i")
    time.sleep(duration)
    pyautogui.press("esc")
    time.sleep(duration)


if __name__ == "__main__":
    parser = ArgumentParser(description="Generate a demo recording using asciinema")
    parser.add_argument("--cols", type=int, required=True)
    parser.add_argument("--rows", type=int, required=True)
    parser.add_argument("--file", type=str, required=True)
    parser.add_argument("--cast", type=str, required=True)
    parser.add_argument("--content", type=str, required=True)
    args = parser.parse_args()
    main(args.cols, args.rows, args.file, args.cast, args.content)
