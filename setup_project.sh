#!/bin/bash

echo "----------------------------------"
echo "ATTENDANCE TRACKER"
echo "----------------------------------"

# Check Python3 version
py3=$(python3 --version)
echo "$py3"

# Function to manage process if script is interrupted
process_management() {
    echo -e "\n...............Process management initiated..............."
    if [ -d "$DIR" ]; then
        tar -czf attendance_tracker_${INPUT}_archive.tgz "$DIR"
        rm -rf "$DIR"
    fi
    echo "Process archived into attendance_tracker_${INPUT}_archive.tgz"
    echo "................................................................."
    exit 1
}
trap 'process_management' SIGINT

# Prompt user for main directory name
read -p "Input for directory creation: " INPUT
while [ -z "$INPUT" ]; do
    read -p "Please enter a text to create the parent directory: " INPUT
done

# Create main directory
DIR="attendance_tracker_$INPUT"
mkdir -p "$DIR"
sleep 0.3
echo "main directory created"

# Create Helpers and reports directories first
mkdir -p "$DIR/Helpers"
mkdir -p "$DIR/reports"
echo "Helpers and reports directories created"

echo "creating files..."

# Create Python attendance checker script
cat > "$DIR/attendance_checker.py" << 'EOF'
import csv
import json
import os
from datetime import datetime

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
HELPERS_DIR = os.path.join(BASE_DIR, 'Helpers')
REPORTS_DIR = os.path.join(BASE_DIR, 'reports')

def run_attendance_check():
    # 1. Load Config
    with open(os.path.join(HELPERS_DIR, 'config.json'), 'r') as f:
        config = json.load(f)

    # 2. Archive old reports.log if it exists
    reports_log = os.path.join(REPORTS_DIR, 'reports.log')
    if os.path.exists(reports_log):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename(reports_log, os.path.join(REPORTS_DIR, f'reports_{timestamp}.log.archive'))

    # 3. Process Data
    with open(os.path.join(HELPERS_DIR, 'assets.csv'), mode='r') as f, open(reports_log, 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']

        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")

        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])

            attendance_pct = (attended / total_sessions) * 100

            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."

            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
EOF

# Create assets.csv
cat > "$DIR/Helpers/assets.csv" << EOF
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF
echo "assets.csv created"

# Create default config.json
cat > "$DIR/Helpers/config.json" << EOF
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}
EOF
echo "config.json created"

# Create initial reports.log
cat > "$DIR/reports/reports.log" << EOF
--- Attendance Report Run: $(date) ---
[EXAMPLE] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%. You will fail this class.
EOF
echo "reports.log created"

# Prompt to update thresholds
while true; do
    read -p "Update attendance thresholds? y/n: " update
    if [ "$update" = "y" ]; then
        read -p "Enter warning threshold (default 75%): " warning_th
        read -p "Enter failure threshold (default 50%): " failure_th
        [ -z "$warning_th" ] && warning_th=75
        [ -z "$failure_th" ] && failure_th=50
        sed -i "" "s/\"warning\": [0-9]*/\"warning\": $warning_th/" "$DIR/Helpers/config.json"
        sed -i "" "s/\"failure\": [0-9]*/\"failure\": $failure_th/" "$DIR/Helpers/config.json"
        echo "Thresholds updated"
        break
    elif [ "$update" = "n" ]; then
        echo "Thresholds remain the same"
        break
    else
        echo "Invalid input. Enter y or n"
    fi
done

# Show final directory structure
sleep 0.5
echo ""
echo "Directory structure:"
tree "$DIR"
