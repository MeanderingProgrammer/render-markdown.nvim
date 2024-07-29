init := "tests/minimal.lua"

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
  just demo-file "heading_code" "30" "## Heading 2"

demo-list:
  just demo-file "list_table" "30" ""

demo-box:
  just demo-file "box_dash_quote" "15" ""

demo-latex:
  just demo-file "latex" "15" ""

demo-callout:
  just demo-file "callout" "40" ""

demo-file file rows content:
  rm -f demo/{{file}}.gif
  python demo/record.py \
    --cols "60" \
    --rows {{rows}} \
    --file demo/{{file}}.md \
    --cast {{file}}.cast \
    --content "{{content}}"
  # https://github.com/MeanderingProgrammer/cli/tree/main/agg
  agg {{file}}.cast demo/{{file}}.gif
  rm {{file}}.cast

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
  just gen-file "1000" "temp/medium.md"

gen-large:
  just gen-file "100000" "temp/large.md"

[private]
gen-file lines path:
  {{path_exists(path)}} || just gen-file-content {{lines}} > {{path}}

[private]
gen-file-content lines:
  #!/usr/bin/env python
  for i in range({{lines}}):
    level = "#" * ((i % 6) + 1)
    print(f"{level} Title {i}\n")
