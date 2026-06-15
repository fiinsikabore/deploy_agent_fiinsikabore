#!/bin/bash
echo "Enter a name for your project:"
read project_name

project_dir="attendance_tracker_$project_name"
cleanup() {
    echo ""
    echo "Script interrupted! Saving current state..."

    if [ -d "$project_dir" ]; then
        tar -czf "${project_dir}_archive.tar.gz" "$project_dir"
        echo "Archive created: ${project_dir}_archive.tar.gz"
        rm -rf "$project_dir"
        echo "Incomplete folder deleted."
    fi
    echo "Exiting."
    exit 1
}

trap cleanup SIGINT

echo "Creating project folders..."

if [ -d "$project_dir" ]; then
    echo "Warning: folder $project_dir already exists."
    echo "Do you want to overwrite it? (y/n)"
    read answer
    if [ "$answer" = "y" ]; then
        rm -rf "$project_dir"
    else
        echo "Cancelled."
        exit 1
    fi
fi
mkdir "$project_dir"
mkdir "$project_dir/Helpers"
mkdir "$project_dir/reports"
mkdir -p "$project_dir/reports"
echo "Generating project configuration and source files..."

# 1. Create config.json
cat << 'EOF' > "$project_dir/Helpers/config.json"
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}
EOF

# 2. Create assets.csv
cat << 'EOF' > "$project_dir/Helpers/assets.csv"
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF

# 3. Create attendance_checker.py
cat << 'EOF' > "$project_dir/attendance_checker.py"
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    # 1. Load Config
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)
    
    # 2. Archive old reports.log if it exists
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')

    # 3. Process Data
    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
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
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
EOF

# 4. Create reports.log
cat << 'EOF' > "$project_dir/reports/reports.log"
--- Attendance Reports Log ---
This file is generated automatically by setup_project.sh

EOF

echo "Do you want to update the attendance thresholds? (y/n)"
read update_config

if [ "$update_config" = "y" ]; then
    
    echo "Enter a new Warning treshold (current: 75):"
    read warning_val
    
    echo "Enter a new Failure threshold (current:50):"
    read failure_val

 if ! [[ "$warning_val" =~ ^[0-9]+$ ]] || ! [[ "$failure_val" =~ ^[0-9]+$ ]]; then
        echo "Invalid input. Thresholds must be numbers. Keeping defaults."
    else
        sed -i "s/\"warning\": [0-9]*/\"warning\": $warning_val/" "$project_dir/Helpers/config.json"
        sed -i "s/\"failure\": [0-9]*/\"failure\": $failure_val/" "$project_dir/Helpers/config.json"

        echo "Thresholds updated: Warning=$warning_val% / Failure=$failure_val%"
    fi

else
    echo "Keeping default thresholds."
fi
echo "Running health check..."
python_version=$(python3 --version 2>&1)

if [ $? -ne 0 ]; then
    echo "Warning: python3 not found. Please install it."
else  
    version_number=$(echo "$python_version" | cut -d ' ' -f 2)
    major=$(echo "$version_number" | cut -d '.' -f 1)
      minor=$(echo "$version_number" | cut -d '.' -f 2)

	  echo "Python detected: $python_version"
    if [ "$major" -lt 3 ] || [ "$major" -eq 3 -a "$minor" -lt 6 ]; then
        echo "Warning: Python $version_number is too old."
    else
        echo "Python $version_number is good to go."
    fi
fi


echo "Checking project files..."

for file in \
    "$project_dir/attendance_checker.py" \
    "$project_dir/Helpers/assets.csv" \
    "$project_dir/Helpers/config.json" \
    "$project_dir/reports/reports.log"
do
    if [ -f "$file" ]; then
        echo "  OK: $file"
    else
        echo "  MISSING: $file"
    fi
done


echo ""
echo "Setup complete! Your project is ready in: $project_dir"
echo "To run the tracker: cd $project_dir && python3 attendance_checker.py"
