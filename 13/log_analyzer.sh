#!/bin/bash

LOCK_FILE="/tmp/log_analyzer.lock"
LOG_FILE="/var/log/nginx/access.log"
ERROR_LOG_FILE="/var/log/nginx/error.log"
EMAIL="your_email@example.com"
TMP_FILE="/home/vagrant/log_report.txt"
LAST_RUN_FILE="/home/vagrant/last_run_time"

if [ -f "$LOCK_FILE" ]; then
    exit 1
fi

touch "$LOCK_FILE"
trap "rm -f $LOCK_FILE" EXIT

if [ -f "$LAST_RUN_FILE" ]; then
    LAST_RUN=$(cat $LAST_RUN_FILE)
else
    LAST_RUN="$(date --date='1 hour ago' '+%d/%b/%Y:%H:%M:%S')"
fi
CURRENT_RUN="$(date '+%d/%b/%Y:%H:%M:%S')"
echo "$CURRENT_RUN" > "$LAST_RUN_FILE"

if [ ! -f "$LOG_FILE" ]; then
    echo "Файл логов $LOG_FILE не найден!" > "$TMP_FILE"
fi
if [ ! -f "$ERROR_LOG_FILE" ]; then
    echo "Файл логов $ERROR_LOG_FILE не найден!" >> "$TMP_FILE"
fi

{
    echo "Отчет о запросах с $LAST_RUN по $CURRENT_RUN"
    echo -e "\n--- Топ 10 IP-адресов ---"
    awk -v last_run="$LAST_RUN" '$4" "$5 >= "["last_run"]" {print $1}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -10
    
    echo -e "\n--- Топ 10 запрашиваемых URL ---"
    awk -v last_run="$LAST_RUN" '$4" "$5 >= "["last_run"]" {print $7}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -10
    
    echo -e "\n--- Ошибки веб-сервера ---"
    awk -v last_run="$LAST_RUN" '$4" "$5 >= "["last_run"]" {print}' "$ERROR_LOG_FILE"
    
    echo -e "\n--- Статистика HTTP-кодов ---"
    awk -v last_run="$LAST_RUN" '$4" "$5 >= "["last_run"]" {print $9}' "$LOG_FILE" | sort | uniq -c | sort -nr
} >> "$TMP_FILE"

mail -s "Отчет по логам Nginx" "$EMAIL" < "$TMP_FILE"

exit 0
