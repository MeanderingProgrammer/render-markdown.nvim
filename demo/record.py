import time
from argparse import ArgumentParser

import pyautogui


def main(cols: int, rows: int, file: str, cast: str, content: str) -> None:
    # Open new tmux window
    pyautogui.hotkey("`", "c")
    time.sleep(1.0)

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

    # Swith between insert and normal mode a few times
    for i in range(2):
        pyautogui.press("i")
        time.sleep(i + 1)
        pyautogui.press("esc")
        time.sleep((i + 1) * 2)

    # Close demo file
    pyautogui.write(":q!")
    pyautogui.press("enter")
    time.sleep(0.5)

    # Close tmux window
    pyautogui.write("exit")
    pyautogui.press("enter")


if __name__ == "__main__":
    parser = ArgumentParser(description="Generate a demo recording using asciinema")
    parser.add_argument("--cols", type=int, required=True)
    parser.add_argument("--rows", type=int, required=True)
    parser.add_argument("--file", type=str, required=True)
    parser.add_argument("--cast", type=str, required=True)
    parser.add_argument("--content", type=str, required=True)
    args = parser.parse_args()
    main(args.cols, args.rows, args.file, args.cast, args.content)
