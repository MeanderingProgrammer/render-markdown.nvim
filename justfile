init := "tests/minimal.lua"
default_zoom := '2'

test:
  nvim --headless --noplugin -u {{init}} \
    -c "PlenaryBustedDirectory tests { minimal_init = '{{init}}', sequential=true }"

demo zoom=default_zoom:
  rm -f demo/demo.gif
  python demo/record.py \
    --zoom {{zoom}} \
    --file demo/sample.md \
    --cast demo.cast
  # https://docs.asciinema.org/manual/agg/usage/
  agg demo.cast demo/demo.gif \
    --font-family "Monaspace Neon,Hack Nerd Font" \
    --last-frame-duration 1
  rm demo.cast

gen-doc:
  # https://github.com/kdheepak/panvimdoc
  # https://pandoc.org/
  ../../open-source/panvimdoc/panvimdoc.sh \
    --project-name render-markdown \
    --input-file README.md \
    --vim-version 0.10.0

[private]
gen-file-text:
  #!/usr/bin/env python
  for i in range(100_000):
    level = "#" * ((i % 6) + 1)
    print(f"{level} Title {i}\n")

gen-large-file:
  just gen-file-text > large.md
