# Attendance Tracker Project Factory

This project is my shell scripting assignment where I created a script that automatically sets up a Student Attendance Tracker project. Instead of manually creating folders and files one by one, the script does everything at once. It also handles mistakes like stopping the script halfway so the workspace doesn’t get messy.

The goal was to practice automation (Infrastructure as Code) and make setup faster and safer.


## What the Script Does

* Asks the user for a name to create a project folder
* Builds the full folder structure automatically
* Creates all required files (python file, csv data, json config, and log file)
* Checks if **python3** exists on the machine
* Lets the user change attendance warning and failure percentages
* Uses `sed` to update values inside the config.json file
* Handles **Ctrl + C interruption** using trap
* Archives unfinished work and removes the broken directory


## Directory Structure Created

attendance_tracker_input/
├── attendance_checker.py
├── Helpers/
│   ├── assets.csv
│   └── config.json
└── reports/
└── reports.log

Example if the user enters `class1`:

attendance_tracker_class1/


## How to Run

Make the script executable:

```bash
chmod +x setup_project.sh
```

Run the script:

```bash
./setup_project.sh
```

You will be asked:

```
Input for directory creation:
```

Enter any name and the folder will be created automatically.


## Updating Thresholds

The script will ask:

```
Update attendance thresholds? y/n
```

If you type **y**, you can change:

* Warning percentage (default 75)
* Failure percentage (default 50)

The script edits the `config.json` file directly using `sed`.


## Interrupt / Archive Feature

If you press:

```
CTRL + C
```

The script will:

1. Stop execution
2. Compress the current folder into:

```
attendance_tracker_input_archive.tgz
```

3. Delete the incomplete folder

This keeps the workspace clean and avoids half-created projects.


## Python Health Check

The script runs:

```bash
python3 --version
```

If python3 exists, it prints the version. If not, the user will notice it’s missing.


## What the Python Program Does

`attendance_checker.py`:

* Reads attendance data from `assets.csv`
* Uses settings from `config.json`
* Calculates attendance percentage
* Writes warnings into `reports.log`


## Notes

* Run the script in a writable directory
* Archive only happens if the script is interrupted
* The `tree` command is used at the end to show the folder structure


## Author

Eric Quagrainie
Student project for practicing shell scripting and automation.
