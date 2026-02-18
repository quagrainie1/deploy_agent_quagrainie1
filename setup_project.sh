#!/bin/bash 

echo "----------------------------------"
echo "ATTENDANCE TRACKER"
echo "----------------------------------"


#check python3 version
py3=$(python3 --version)

echo "$py3"

# Function to manage process if script is interrupted
# Archives the main directory and cleans up
process_management() {
	echo -e "\n...............Process management initiated..............."
	if [ -d "$DIR" ]; then
		tar -czf attendance_tracker_${INPUT}_archive.tgz $DIR
		rm -rf $DIR
	fi
	echo "Process archived into attendance_tracker_${INPUT}_archive.tgz"
	echo "................................................................."
	exit 1
}
trap 'process_management' SIGINT

# Prompt user for input to name the main directory
echo ""
read -p "Input for directory creation: " INPUT
while [ -z "$INPUT" ]; do
	read -p "Please enter a text to create the parent directory: " INPUT
done

# Create main directory
DIR="attendance_tracker_$INPUT"
mkdir -p "$DIR"
sleep 0.3
echo ""
echo "main directory created"

echo "creating sub-directories and files"

# Create Python attendance checker script
cat > "$DIR/attendance_checker.py" <<- EOF
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
            
            # Simple Math: (Attended / Total) * 100
            attendance_pct = (attended / total_sessions) * 100
            
            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."
            
            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
EOF


# Create Helpers directory for assets and config files
mkdir -p "$DIR/Helpers"
echo "Helpers directory created"

# Create assets.csv with sample student attendance data
cat > "$DIR/Helpers/assets.csv" << EOF
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF

sleep 0.5
echo "$DIR/Helpers/assets.csv created"

# Create reports directory
mkdir -p "$DIR/reports"

echo "reports directory created"

# Create initial reports.log with example alerts
cat > "$DIR/reports/reports.log" << EOF
--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie Davis, your attendance is 26.7%. You will fail this class.
EOF

sleep 0.5
echo "$DIR/reports/reports.log created sucessfully"

# Create config.json with default attendance thresholds and total sessions
cat > $DIR/Helpers/config.json <<EOF
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

# Prompt user to optionally update attendance thresholds
while true; do
	read -p "Update attendance thresholds? y/n: " update

	if [ "$update" = "y" ]; then
		echo ""
		echo "Enter the default value if you don't want to change thresholds"
		echo ""
		read -p "enter warning threshold. Default set to 75%: " warning_th
		sed -i "" "s/\"warning\": [0-9]*/\"warning\": $warning_th/" "$DIR/Helpers/config.json"
		read -p "enter failure threshold. Default set to 50%: " failure_th
                sed -i "" "s/\"failure\": [0-9]*/\"failure\": $failure_th/" "$DIR/Helpers/config.json"		
		echo "UPDATED thresholds"
		break
	elif [ "$update" = "n" ]; then
		echo "Thresholds remain the same "
		break
	else 
		echo "Invalid input. enter y or n"
	fi
done


# Display the directory structure of the newly created attendance tracker
sleep 0.5
echo ""
echo "dir structure below"
tree "$DIR"
