#!/bin/bash
# Define source and destination
SOURCE_DIR="/path/to/your/source/directory"  # Example: /home/ubuntu/data
CURRENT_DATE=$(date +"%Y-%m-%d_%H-%M-%S") # Get current date and time
ZIP_FILE="/tmp/data_backup_$CURRENT_DATE.zip"
DB_BACKUP_FILE="/tmp/mysql_backup_$CURRENT_DATE.sql"
DEST_DIR="your_remote_storage:backup-directory"  # Example: arvancloud:backup-bucket/backups
# MySQL credentials (replace with placeholders)
DB_USER="your_mysql_user"  # Example: "root"
DB_PASSWORD="your_mysql_password"  # Example: "your_password"
DB_HOST="localhost"  # Change if the MySQL server is on a different host
# Step 1: Backup all MySQL databases to a file
echo "Backing up all MySQL databases to $DB_BACKUP_FILE..."
mysqldump --single-transaction --triggers --routines --events --all-databases --set-gtid-purged=OFF -u "$DB_USER" -p"$DB_PASSWORD" -h "$DB_HOST" > "$DB_BACKUP_FILE"
# Check if the database backup was successful
if [ $? -ne 0 ]; then
  echo "Error: Failed to back up MySQL databases."
  exit 1
fi
# Step 2: Create a zip file from the directory and append the database backup
echo "Creating zip file $ZIP_FILE with data and database backup..."
zip -r -v "$ZIP_FILE" "$SOURCE_DIR" "$DB_BACKUP_FILE" --exclude "/path/to/exclude/this/directory/*"  # Example exclusion
# Step 3: Upload the zip file to the remote storage using rclone
echo "Uploading $ZIP_FILE to $DEST_DIR..."
rclone copy "$ZIP_FILE" "$DEST_DIR" --verbose --progress
# Step 4: Remove temporary files after upload
echo "Cleaning up temporary files..."
rm -f "$ZIP_FILE" "$DB_BACKUP_FILE"
echo "Backup completed successfully."
exit 0
