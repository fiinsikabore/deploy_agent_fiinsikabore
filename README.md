# deploy_agent_fiinsikabore

## What this project does
This script automatically sets up the Student Attendance Tracker project.
It creates the folder structure, copies the source files, updates the config, and handles interruptions gracefully.

## How to run the script

Step 1 - Clone the repository:
```bash
git clone https://github.com/fiinsikabore/deploy_agent_fiinsikabore.git
```

Step 2 - Enter the folder:
```bash
cd deploy_agent_fiinsikabore
```

Step 3 - Run the script:
```bash
bash setup_project.sh
```

Step 4 - Answer the questions that appear:
- Enter a project name example: v1
- The script creates attendance_tracker_v1/ automatically
- Choose if you want to update the thresholds y or n
- If y: enter new Warning % and Failure %

Step 5 - The script will then:
- Copy all source files into the right folders
Step 5 - The script will then:
- Copy all source files into the right folders
- Update config.json if you changed thresholds
- Check if python3 is installed
- Verify all files are in place

## What the script creates

attendance_tracker_v1/

├── attendance_checker.py

├── Helpers/

│   ├── assets.csv

│   └── config.json

└── reports/

└── reports.log

## How to trigger the Archive feature

The script has a Trap that catches Ctrl+C interruptions.

To test it:

Step 1 - Run the script:
```bash
bash setup_project.sh
```

Step 2 - Enter a project name

Step 3 - Press Ctrl+C at any moment during execution

What happens automatically:
- The script catches the interruption
- It bundles the current folder into a .tar.gz archive named attendance_tracker_v1_archive.tar.gz
- It deletes the incomplete folder
- It exits cleanly

## How to run the tracker after setup

```bash
cd attendance_tracker_v1
python3 attendance_checker.py
```

## Video Walkthrough
https://drive.google.com/file/d/1gYDdzE76-2WGOotfBGBmGW2s7moZ7QZA/view?usp=sharing

