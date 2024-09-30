init := "tests/minimal_init.lua"

default: update test health

test:
  just busted "tests"

bench:
  just gen-medium
  just busted "benches"

[private]
busted directory:
  nvim --headless --noplugin -u {{init}} \
    -c "PlenaryBustedDirectory {{directory}} { minimal_init = '{{init}}', sequential = true, keep_going = false }"

health:
  nvim -c "checkhealth render-markdown" -- .

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

update:
  # Updates types.lua & README.md
  python -Wignore scripts/update.py
  # https://pandoc.org/
  # https://github.com/kdheepak/panvimdoc
  ../../open-source/panvimdoc/panvimdoc.sh \
    --project-name render-markdown \
    --input-file README.md \
    --vim-version 0.10.0

cat-log:
  cat ~/.local/state/nvim/render-markdown.log

gen-medium:
  just gen-headings "1000" "temp/medium.md"
  just gen-table "50" "100" "temp/medium-table.md"

gen-large:
  just gen-headings "100000" "temp/large.md"

[private]
gen-headings lines path:
  {{path_exists(path)}} || just gen-headings-content {{lines}} > {{path}}

[private]
gen-headings-content lines:
  #!/usr/bin/env python
  for i in range({{lines}}):
    level = "#" * ((i % 6) + 1)
    print(f"{level} Title {i}\n")

[private]
gen-table tables lines path:
  {{path_exists(path)}} || just gen-table-contents {{tables}} {{lines}} > {{path}}

[private]
gen-table-contents tables lines:
  #!/usr/bin/env python
  for i in range({{tables}}):
    print(f"# Table {i}")
    print()
    print(f"| `Column 1`     | **Column 2**     | *Column 3*     |")
    print(f"| -------------- | :--------------- | -------------: |")
    for j in range({{lines}}):
      print(f"| Row {j:<4} Col 1 | `Row {j:<4} Col 2` | Row {j:<4} Col 3 |")
    print()
