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

echo "Folders created."

echo "Copying files..."

cp attendance_checker.py "$project_dir/attendance_checker.py"
cp assets.csv "$project_dir/Helpers/assets.csv"
cp config.json "$project_dir/Helpers/config.json"
cp reports.log "$project_dir/reports/reports.log"

echo "Files copied."

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
echo "Ru
nning health check..."
python_version=$(python3 --version 2>&1)

if [ $? -ne 0 ]; then
    echo "Warning: python3 not found. Please install it."
else  
    version_number=$(echo "$python_version" | cut -d ' ' -f 2)
    major=$(echo "$version_number" | cut -d '.' -f 1)
      minor=$(echo "$version_number" | cut -d '.' -f 2)

    echo "Python detected: $python_version" if [ "$major" -lt 3 ] || { [ "$major" -eq 3 ] && [ "$minor" -lt 6 ]; }; then
        echo "Warning: Python $version_number is too old. Please upgrade to 3.6 or higher."
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
