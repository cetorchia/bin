#!/bin/sh
# Concatenate jpegs and song as an mpeg

OUT=`basename "$(pwd)"`.mpeg

# Generate soundless MPEGs for each picture
i=0
for JPEG in `ls *.jpeg`; do
  n=`printf "%02d" "$i"`
  MPEG=$n.mpeg
  if [ $i -lt 18 ]; then
    d=6
  elif [ $i == 18 ]; then
    d=20
  else
    d=10
  fi
  if [ ! -f "$MPEG" ]; then
    ffmpeg -sameq -r 20 -t $d -loop_input -i "$JPEG" "$MPEG"
  fi
  let "i=$i+1"
done

SONG=$(echo *.mp3)

# Piece them all together and add the soundtrack
cat ??.mpeg > soundless.mpeg
ffmpeg -sameq -i soundless.mpeg -i "$SONG" "$OUT"
