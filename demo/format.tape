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

Down
Type "i" Sleep 0.5s
Screenshot default.png Sleep 0.5s
Escape Sleep 0.5s
Screenshot rendered.png Sleep 0.5s

MOVE

Type "i" Sleep 1s
Escape Sleep 1s

# Close without editing
Hide
Type ":q!"
Enter
Sleep 100ms
