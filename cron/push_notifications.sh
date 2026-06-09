#!/bin/bash
# Paarth Holidays client app push notification cron jobs
#
# Setup on server (replace CRON_KEY with your secret):
#   chmod +x cron/push_notifications.sh
#
# Crontab examples:
#   0 9 * * * /path/to/paarth-holidays/cron/push_notifications.sh payment >> /var/log/paarth_push.log 2>&1
#   0 18 * * * /path/to/paarth-holidays/cron/push_notifications.sh tour >> /var/log/paarth_push.log 2>&1
#   0 7 * * * /path/to/paarth-holidays/cron/push_notifications.sh activity >> /var/log/paarth_push.log 2>&1
#   0 8 * * * /path/to/paarth-holidays/cron/push_notifications.sh all >> /var/log/paarth_push.log 2>&1

BASE_URL="${PUSH_CRON_BASE_URL:-https://macha.tours}"
CRON_KEY="${PUSH_CRON_KEY:-paarth_cron_secret_change_me}"
JOB="${1:-all}"

case "$JOB" in
  payment)
    ENDPOINT="cron/push/payment-reminders"
    ;;
  tour)
    ENDPOINT="cron/push/tour-start-reminders"
    ;;
  activity)
    ENDPOINT="cron/push/daily-activities"
    ;;
  all)
    ENDPOINT="cron/push/all"
    ;;
  *)
    echo "Unknown job: $JOB"
    echo "Usage: $0 [payment|tour|activity|all]"
    exit 1
    ;;
esac

curl -sS "${BASE_URL}/${ENDPOINT}?key=${CRON_KEY}"
echo ""
