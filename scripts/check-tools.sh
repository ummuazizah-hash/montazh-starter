#!/bin/bash
# Сессия басында құралдар бар-жоғын тексереді.
ok=1

if command -v ffmpeg >/dev/null 2>&1; then
  echo "OK: ffmpeg бар"
else
  echo "ЖОҚ: ffmpeg. Environment баптауындағы Setup script толтырылмаған (README, 3-қадам)."
  ok=0
fi

if npx --no-install hyperframes --version >/dev/null 2>&1 || command -v hyperframes >/dev/null 2>&1; then
  echo "OK: hyperframes бар"
else
  echo "ЕСКЕРТУ: hyperframes алдын ала орнатылмаған, npx арқылы жүктеледі."
fi

if curl -sS -o /dev/null -m 10 -w "%{http_code}" "https://drive.usercontent.google.com/" 2>/dev/null | grep -qE "^[2-4]"; then
  echo "OK: Google Drive-қа кіру бар"
else
  echo "ЖОҚ: Google Drive-қа кіру жабық. Environment баптауында Network access = Full қой (README, 3-қадам)."
  ok=0
fi

[ "$ok" = 1 ] && echo "Бәрі дайын." || exit 1
