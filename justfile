init := "tests/minimal_init.lua"
settings := "{ minimal_init = " + quote(init) + ", sequential = true, keep_going = false }"

default: update check test health

update:
  # keep documentation in sync with code
  python scripts/update.py
  # https://github.com/kdheepak/panvimdoc
  ../../tools/panvimdoc/panvimdoc.sh \
    --project-name render-markdown \
    --input-file README.md

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

demo: heading table box latex callout

heading:
  python demo/run.py --name "heading_code"

table:
  python demo/run.py --name "list_table"

box:
  python demo/run.py --name "box_dash_quote"

latex:
  python demo/run.py --name "latex"

callout:
  python demo/run.py --name "callout"
