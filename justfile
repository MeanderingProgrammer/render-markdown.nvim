init := "tests/minimal_init.lua"

default: update check test health

update:
  # Updates types.lua & README.md
  python scripts/update.py
  # https://pandoc.org/
  # https://github.com/kdheepak/panvimdoc
  ../../open-source/panvimdoc/panvimdoc.sh \
    --project-name render-markdown \
    --input-file README.md

check:
  selene --quiet .
  stylua --check .

test:
  just busted "tests"

bench:
  just generate
  just busted "benches"

[private]
busted directory:
  nvim --headless --noplugin -u {{init}} \
    -c "PlenaryBustedDirectory {{directory}} { minimal_init = '{{init}}', sequential = true, keep_going = false }"

generate:
  python scripts/generate.py

health:
  nvim -c "checkhealth render-markdown" -- -

cat-log:
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
