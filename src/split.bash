#!/usr/bin/env bash
# see: https://askubuntu.com/q/56022/22343
# REQUIREMENT:
#   sudo apt install --yes ffmpeg libav-tools
# USAGE
#   bash -x ./split.bash "$video" ["$timing"]

INPUT_FILE="$1"   # video file to split

full_path="$1"
directory_path="${full_path%/*}"
filename="${full_path##*/}"
extension="${full_path##*.}"
timing_path="${2:-$directory_path/$filename.tsv}"   # timing, as: mot  start_time end_time


extract_timing_from_subtitles() {
  awk 'BEGIN{FS=","} /Dialogue/{print $2" "$3" "$10}' \
     "$directory_path/${filename/.$extension/.ass}" \
   > "$directory_path/$filename.tsv"
}

extract_and_encode_word_chunk() {
  ffmpeg -y \
    -i "$INPUT_FILE" \
    -ss "$start" \
    -to "$end" \
    -vf scale=640x480 \
    -b:v 512k \
    -minrate 256k \
    -maxrate 742k \
    -quality good \
    -speed 4 \
    -crf 37 \
    -c:v libvpx-vp9 \
    -loglevel error \
    "$chunk.webm" < /dev/null
}

split_video() {
  while read -r start end mot; do
    chunk="$directory_path/$start.$mot.$extension"

    extract_and_encode_word_chunk "${start}" "${end}"
  done < "$timing_path"
}

extract_timing_from_subtitles
split_video
