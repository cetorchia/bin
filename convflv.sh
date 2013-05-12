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
  ffmpeg -qscale 2 -i "$INPUT" -target ntsc-dvd -acodec ac3 "$OUTPUT" >/dev/null 2>/dev/null && (
    echo '[success]'
    rm "$INPUT"
  ) || echo '[failed]'

  shift
done
