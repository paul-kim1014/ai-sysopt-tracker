#!/bin/bash
# 매일 21:00 실행 (launchd): 오늘 미션 완료 신호가 없으면 ntfy로 폰에 푸시
# 사용: check.sh [--dry-run]
STATUS="sysopt-7d0aedf5-status"
ALERT="sysopt-7d0aedf5-alert"
APP_URL="https://paul-kim1014.github.io/ai-sysopt-tracker/"
TODAY=$(date +%F)
LOG="$HOME/ai-sysopt-tracker/notify/check.log"

# 11/3 ~ 11/15 기간에만 동작
if [[ "$TODAY" < "2026-11-03" || "$TODAY" > "2026-11-15" ]]; then
  echo "$(date '+%F %T') skip (기간 외)" >> "$LOG"; exit 0
fi

if curl -s --max-time 20 "https://ntfy.sh/$STATUS/json?poll=1&since=24h" | grep -q "done $TODAY"; then
  echo "$(date '+%F %T') 완료 확인 — 알림 없음" >> "$LOG"; exit 0
fi

case "$TODAY" in
  2026-11-14|2026-11-15) MSG="오답노트를 아직 안 풀었어요! 시험이 코앞입니다 — 틀린 문제만 빠르게 정리해요." ;;
  *) MSG="오늘의 시스템 최적화 퀴즈가 아직 남아 있어요. 자기 전에 10분만 투자해요!" ;;
esac

if [[ "$1" == "--dry-run" ]]; then
  echo "[dry-run] 미완료 → 보낼 메시지: $MSG"; exit 0
fi

curl -s --max-time 20 -X POST "https://ntfy.sh/" -d @- <<EOF
{"topic":"$ALERT","title":"⏰ 21시 — 오늘 미션 미완료","message":"$MSG","priority":4,"tags":["alarm_clock"],"click":"$APP_URL"}
EOF
echo "$(date '+%F %T') 미완료 — 알림 전송" >> "$LOG"
