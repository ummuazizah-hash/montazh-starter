#!/bin/bash
# Видеоны сілтеме арқылы input/ папкасына жүктейді.
# Қолдану: bash scripts/fetch-video.sh "<Google Drive немесе тікелей сілтеме>" [файл-аты]
set -u
url="${1:-}"
if [ -z "$url" ]; then
  echo "Сілтеме берілмеді. Қолдану: bash scripts/fetch-video.sh \"<сілтеме>\""
  exit 1
fi

cd "$(dirname "$0")/.."
mkdir -p input
name="${2:-video-$(date +%Y%m%d-%H%M%S)}"
out="input/${name}.mp4"

# Google Drive сілтемесінен файл ID-ін шығару
id=""
case "$url" in
  *drive.google.com/file/d/*) id=$(printf '%s' "$url" | sed -E 's#.*/file/d/([^/?&]+).*#\1#') ;;
  *drive.google.com/*id=*|*drive.usercontent.google.com/*id=*) id=$(printf '%s' "$url" | sed -E 's#.*[?&]id=([^&]+).*#\1#') ;;
esac

if [ -n "$id" ]; then
  echo "Google Drive файлы: $id"
  dl="https://drive.usercontent.google.com/download?id=${id}&export=download&confirm=t"
else
  dl="$url"
  # Dropbox сілтемесін тікелей жүктеуге айналдыру
  case "$dl" in *dropbox.com*) dl=$(printf '%s' "$dl" | sed -E 's/dl=0/dl=1/') ;; esac
fi

if ! curl -fL --retry 3 -sS -o "$out" "$dl"; then
  echo "ҚАТЕ: файлды жүктеу мүмкін болмады."
  echo "Тексер: 1) Network access = Full ме? 2) Drive-та «Сілтемесі бар кез келген адам» қойылған ба?"
  rm -f "$out"; exit 1
fi

# Видео екенін тексеру (Drive кейде видео орнына HTML бет қайтарады)
if ! ffprobe -v error -select_streams v:0 -show_entries stream=codec_type -of csv=p=0 "$out" 2>/dev/null | grep -q video; then
  echo "ҚАТЕ: жүктелген файл видео емес."
  echo "Көбіне себебі: Drive-та файлға рұқсат жабық. Бөлісу → «Сілтемесі бар кез келген адам» → Көруші қой."
  rm -f "$out"; exit 1
fi

info=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height:format=duration -of default=nw=1 "$out" | tr '\n' ' ')
size=$(du -h "$out" | cut -f1)
echo "ДАЙЫН: $out ($size) $info"
