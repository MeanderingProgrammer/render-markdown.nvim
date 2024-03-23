demo:
    rm -f demo/demo.gif
    python demo/record.py \
      --zoom 10 \
      --file demo/sample.md \
      --cast demo.cast
    # https://docs.asciinema.org/manual/agg/usage/
    agg demo.cast demo/demo.gif \
      --font-family "JetBrainsMono NFM" \
      --last-frame-duration 1
    rm demo.cast
