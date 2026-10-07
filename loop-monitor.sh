#!/bin/bash
# ==============================================================================
# Script: loop-monitor.sh
# Purpose: Continuous background monitoring script logging system time every 5s
# Session: 06 - Exercise 04
# ==============================================================================

LOG_FILE="/tmp/monitor.log"

echo "=== Monitoring process started at $(date) ===" >> "$LOG_FILE"

while true; do
    echo "System time: $(date)" >> "$LOG_FILE"
    sleep 5
done
