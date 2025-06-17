#!/bin/bash

# Usage:
# chmod +x generate_dummy_logs.sh
# ./generate_dummy_logs.sh /path/to/test_logs.txt

if [ -z "$1" ]; then
  echo "Usage: $0 <LogFile>"
  exit 1
fi

LOG_FILE="$1"

SEVERITIES=("ERROR" "WARNING" "CRITICAL" "INFO")
TECH_TERMS=("API" "Database" "Endpoint" "Memory" "Server" "CPU" "Request" "Response" "Session" "Connection")

generate_log_message() {
  severity_index=$((RANDOM % ${#SEVERITIES[@]}))
  term_index=$((RANDOM % ${#TECH_TERMS[@]}))

  severity=${SEVERITIES[$severity_index]}
  term=${TECH_TERMS[$term_index]}

  case "$severity" in
    "ERROR")
      messages=(
        "The $term encountered an issue."
        "$term failed to respond."
        "A $term timeout occurred."
      )
      ;;
    "WARNING")
      messages=(
        "Unexpected $term behavior detected."
        "Potential issue with $term detected."
        "$term nearing capacity."
      )
      ;;
    "CRITICAL")
      messages=(
        "$term is down!"
        "$term returned an invalid result."
        "Critical fault in $term."
      )
      ;;
    "INFO")
      messages=(
        "$term is operating normally."
        "$term initialization complete."
        "User accessed $term."
        "$term executed successfully."
      )
      ;;
  esac

  message_index=$((RANDOM % ${#messages[@]}))
  echo "$severity - ${messages[$message_index]}"
}

# Infinite loop to generate logs
while true; do
  timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  log_message=$(generate_log_message)
  echo "$timestamp - $log_message" >> "$LOG_FILE"
  sleep $((RANDOM % 3 + 1))
done
