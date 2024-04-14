default_zoom := '2'

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

docgen:
    # https://github.com/kdheepak/panvimdoc
    # https://pandoc.org/
    ../../open-source/panvimdoc/panvimdoc.sh \
      --project-name render-markdown \
      --input-file README.md \
      --vim-version 0.9.5
