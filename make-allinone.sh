#!/bin/bash
# vi: et sts=4 sw=4 ts=4
WORKDIR=${0%/*}
OUT=$WORKDIR/roll.pl

echo "Outputting to $OUT" >&2

shopt -s globstar
"$WORKDIR/util/squash" \
    "$WORKDIR/roll-main.pl" \
    "$WORKDIR"/**/*.pm \
    > "$OUT"
chmod +x -- "$OUT"
