init := "tests/minimal_init.lua"
settings := "{ minimal_init = " + quote(init) + ", sequential = true, keep_going = false }"

default: update check test bench health

update:
  # keep documentation in sync with code
  python scripts/update.py
  # https://github.com/kdheepak/panvimdoc
  ../../../tools/panvimdoc/panvimdoc.sh \
    --input-file README.md \
    --project-name render-markdown \
    --description "Improve viewing Markdown in Neovim"

check:
  selene --quiet .
  stylua --check .

test:
  just busted "tests"

bench:
  python scripts/generate.py
  just busted "benches"

[private]
busted path:
  nvim --headless --noplugin -u {{init}} -c "PlenaryBustedDirectory {{path}} {{settings}}"

health:
  nvim -c "checkhealth render-markdown" -- -

log:
  cat ~/.local/state/nvim/render-markdown.log

demo: heading table quote callout latex

heading:
  python demo/run.py --name "heading_code"

table:
  python demo/run.py --name "list_table"

quote:
  python demo/run.py --name "box_dash_quote"

callout:
  python demo/run.py --name "callout"

latex:
  python demo/run.py --name "latex"
