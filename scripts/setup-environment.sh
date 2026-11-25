#!/bin/bash
# Бұл скрипттің мазмұнын Claude Code environment баптауындағы
# "Setup script" өрісіне толық көшіріп қой (README, 3-қадам).
# Ол әр жаңа сессия басталар алдында бұлт компьютеріне
# видеоға керек құралдарды орнатады.

apt-get update -qq
apt-get install -y -qq ffmpeg

# HyperFrames: HTML-ден видео жасайтын құрал
npm install -g hyperframes@latest || true
npx -y hyperframes skills update || true
