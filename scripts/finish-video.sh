#!/bin/bash
# Дайын видеоны 45 МБ-тан кіші етіп сығып, output/ ішіне салады.
# GitHub 100 МБ-тан үлкен файлды қабылдамайды, телефонға да жеңіл болсын.
# Қолдану: bash scripts/finish-video.sh <render.mp4> <аты>
set -eu
src="$1"
name="${2:-montazh-$(date +%Y%m%d-%H%M%S)}"
cd "$(dirname "$0")/.."
mkdir -p output
out="output/${name}.mp4"
limit_mb=45

dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$src")
# Бит-рейт: 45 МБ / ұзақтық, 128k дыбысқа, ең көбі 8 Мбит/с
vkbps=$(awk -v d="$dur" -v l="$limit_mb" 'BEGIN{k=int(l*8192/d)-128-200; if(k>8000)k=8000; if(k<500)k=500; print k}')

ffmpeg -y -v error -i "$src" -c:v libx264 -preset medium -b:v "${vkbps}k" -maxrate "${vkbps}k" -bufsize "$((vkbps*2))k" \
  -pix_fmt yuv420p -c:a aac -b:a 128k -movflags +faststart "$out"

size_mb=$(du -m "$out" | cut -f1)
echo "ДАЙЫН: $out (${size_mb} МБ, ${vkbps} кбит/с)"
if [ "$size_mb" -ge 95 ]; then
  echo "ЕСКЕРТУ: файл тым үлкен, GitHub қабылдамайды. Видеоны қысқарт."
  exit 1
fi
