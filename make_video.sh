#!/bin/sh
# Concatenate jpegs and song as an mpeg

OUT=$(basename "$(pwd)").mpeg
[[ -n "$1" ]] && DURATION=$1 || DURATION=1
if [[ -n $(echo "$1" | tr -d '[0-9\.]') ]] || [[ -n "$2" ]]; then
  echo "Usage: $(basename "$0") [DURATION(seconds)]" >&2
  exit 1
fi

# Generate soundless MPEGs for each picture
i=0
ls *.jpeg *.jpg *.JPG *.png | sort | while read INIMG; do
  n=$(printf "%02d" "$i")
  OUTIMG=$n.png
  MPEG=$n.mpeg

  # Pad to 4:3
  h=$(convert "$INIMG" -ping -format "%h" info:)
  w=$((h*4/3))
  echo -n \"$INIMG\" \-\> \"$OUTIMG\"
  convert "$INIMG" -gravity center -background black -extent $w\x$h "$OUTIMG"
  echo

  # Convert image to mpeg
  echo -n \"$OUTIMG\" \-\> \"$MPEG\"
  ffmpeg -qscale 2 -r 20 -t $DURATION -loop 1 -i "$OUTIMG" "$MPEG" 2> /dev/null > /dev/null < /dev/null && (
    rm "$OUTIMG"
  ) || echo -n \ \[FAILED\]
  echo

  i=$((i+1))
done

SONG=$(echo *.mp3)

# Piece them all together and add the soundtrack
( cat ??.mpeg > soundless.mpeg ) && (
  rm ??.mpeg
)
ffmpeg -qscale 2 -i soundless.mpeg -i "$SONG" -target ntsc-dvd -acodec ac3 "$OUT" && (
  rm soundless.mpeg
)
