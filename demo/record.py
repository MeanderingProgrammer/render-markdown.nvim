import time
from argparse import ArgumentParser

import pyautogui


def main(file: str, cast: str) -> None:
    # Open new tmux window
    pyautogui.hotkey("`", "c")
    time.sleep(1.0)

    # Zoom in
    for _ in range(15):
        pyautogui.hotkey("command", "=")

    # Start recording demo file
    # https://docs.asciinema.org/manual/cli/usage/
    pyautogui.write(f"asciinema rec -c 'nvim {file}' {cast}")
    pyautogui.press("enter")
    time.sleep(1.0)

    # Start typing in new heading
    pyautogui.press("o")
    pyautogui.press("enter")
    pyautogui.write("## Heading 2", interval=0.1)

    # Enter normal mode
    pyautogui.press("esc")
    time.sleep(2.0)

    for _ in range(2):
        pyautogui.press("i")
        time.sleep(1.0)
        pyautogui.press("esc")
        time.sleep(2.0)

    # Close demo file
    pyautogui.write(":q!")
    pyautogui.press("enter")
    time.sleep(0.5)

    # Zoom out
    pyautogui.hotkey("command", "0")

    # Close tmux window
    pyautogui.write("exit")
    pyautogui.press("enter")


if __name__ == "__main__":
    parser = ArgumentParser(description="Generate a demo recording using asciinema")
    parser.add_argument("--file", type=str, required=True)
    parser.add_argument("--cast", type=str, required=True)
    args = parser.parse_args()
    main(args.file, args.cast)
