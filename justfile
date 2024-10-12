init := "tests/minimal_init.lua"

default: update test health

update:
  # Updates types.lua & README.md
  python scripts/update.py
  # https://pandoc.org/
  # https://github.com/kdheepak/panvimdoc
  ../../open-source/panvimdoc/panvimdoc.sh \
    --project-name render-markdown \
    --input-file README.md \
    --vim-version 0.10.0

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
  nvim -c "checkhealth render-markdown" -- .

cat-log:
  cat ~/.local/state/nvim/render-markdown.log

demo: demo-heading demo-list demo-box demo-latex demo-callout

demo-heading:
  python demo/run.py \
    --name "heading_code" \
    --height "550" \
    --content "## Heading 2"

demo-list:
  python demo/run.py \
    --name "list_table" \
    --height "550" \
    --content ""

demo-box:
  python demo/run.py \
    --name "box_dash_quote" \
    --height "250" \
    --content ""

demo-latex:
  python demo/run.py \
    --name "latex" \
    --height "250" \
    --content ""

demo-callout:
  python demo/run.py \
    --name "callout" \
    --height "750" \
    --content ""
