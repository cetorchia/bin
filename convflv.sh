#!/bin/bash

if [[ -z "$1" ]]; then
  echo 'Usage: '$0' <filename1.flv> [<filename2.flv> [...]]' >&2
  exit 1
fi

while [[ -n "$1" ]]; do
  INPUT="$1"
  OUTPUT="${INPUT%.flv}"
  OUTPUT="${OUTPUT%.mp4}"
  OUTPUT="${OUTPUT%.mpeg}"
  OUTPUT="$OUTPUT.mpg"

  echo -n "$INPUT -> $OUTPUT "

  # See if the filename was valid
  if [[ "$OUTPUT" == "$INPUT.mpg" ]]; then
    echo '[skipped]'
    shift
    continue
  fi

  # Convert this file
  ffmpeg -i "$INPUT" -target ntsc-dvd -acodec ac3 -qscale 2 "$OUTPUT" >> convflv.sh.log 2>&1 && (
    echo '[success]'
    rm "$INPUT"
  ) || echo '[failed]'

  shift
done
