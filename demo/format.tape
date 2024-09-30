Output OUTPUT

Set FontSize 14
Set FontFamily "JetBrainsMono Nerd Font"
Set Width WIDTH
Set Height HEIGHT
Set Padding 0
Set Framerate 60
Set TypingSpeed 0.1

# Setup
Hide
Type "nvim -u demo/minit.lua INPUT" Enter
Show

Sleep 2s

WRITE

Type "i" Sleep 1s
Escape Sleep 1s

MOVE

Type "i" Sleep 1s
Escape Sleep 1s

# Close without editing
Type ":q!"
Hide
Enter
Sleep 100ms
