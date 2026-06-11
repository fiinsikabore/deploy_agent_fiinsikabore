# Project: Automated Project Bootstrapping & Process Management

## Project Description
This project implements an automated deployment tool ("Project Factory") developed as a Bash shell script (`setup_project.sh`). It dynamically bootstraps the environment for a Student Attendance Tracker application using Infrastructure as Code (IaC) principles. 

The script handles automated directory creation, interactive configuration updates via stream editing (`sed`), environment validation, and robust runtime workspace cleanup using system signal traps.

---

## Workspace Architecture

When completed successfully, the master script generates the following exact directory structure inside your repository:

```text
attendance_tracker_{input}/               <-- Dynamic Parent Directory
├── attendance_checker.py                 <-- Core Application Logic
├── Helpers/                              <-- Configuration Directory
│   ├── assets.csv                        <-- Student Records Database
│   └── config.json                       <-- Threshold Settings (Modified by sed)
└── reports/                              <-- Logging Directory
    └── reports.log                       <-- Initial Application Logs

### Step 1: Open Terminal & Navigate
Launch your command-line interface (use Git Bash if you are on Windows).
Run the following command to move into your project repository directory:
```bash
- cd ~/deploy_agent_fiinsikabore
###Step 2: Run the Bootstrapping Script
Start the automated deployment process by executing the master script.
This action initiates the environment setup and system diagnostics:

- bash setup_project.sh

###Step 3: Complete Interactive Prompts
Enter a custom workspace name when prompted (for example: june11).
Type y to update attendance thresholds and input your custom numbers.
The script uses sed to dynamically update your configuration files.

###Step 4: Verify Directory Structure
Ensure all folders and tracking files were generated in the correct locations.
Run this command to print and inspect the newly created workspace layout:

- find attendance_tracker_june11 -not -path '*/.*' | sed -e 's;[^/]*/;|____;g;s;____|; |;g'

###Step 5: Test the Process Cleanup Trap
Re-run the script with a temporary name like interrupted_run.
Press Ctrl + C during the threshold prompt to trigger the signal trap.
Verify it creates a .tar.gz archive and wipes the raw folder clean.
