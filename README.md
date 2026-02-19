# Attendance Tracker 

This project helps you automatically track student attendance and log alerts for low attendance.

What It Does

Prompts for your name and creates a folder like attendance_tracker_<name>.
Sets up subfolders: Helpers/ for assets.csv and config.json, and reports/ for logs.
Generates attendance_checker.py, sample assets.csv, config.json, and reports.log.
Archives old reports automatically whenever the script runs.
Sends warnings if a student’s attendance falls below the set thresholds.

Folder Layout

attendance_tracker_<name>/
├── attendance_checker.py
├── Helpers/
│   ├── assets.csv
│   └── config.json
└── reports/
    └── reports.log
    
How to Set Up

Make the setup script executable (if it isn’t already):
chmod +x setup_project.sh
Run the script to create your attendance tracker:
./setup_project.sh
Run the attendance checker:
python3 attendance_tracker_ <name> /attendance_checker.py

Old reports will be archived in the reports/ folder automatically.

How It Works

setup_project.sh builds the folder, subfolders, and files you need.
attendance_checker.py reads attendance data from assets.csv and thresholds from config.json.
Alerts are logged to reports/reports.log or printed if running in dry-run mode.

Tips

Make sure Python 3 is installed.
Update assets.csv whenever attendance changes.
You can choose to adjust warning/failure thresholds during setup.

Author

Created by Eric Quagrainie, a student exploring Python automation and scripting projects.
