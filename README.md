
# S3-like Backup Script

## Description

This project provides an automated solution for backing up data from a local server to an S3-compatible object storage service. It is designed to streamline the process of creating regular backups of MySQL databases and file system directories. The backup script performs the following tasks:

- Backs up all MySQL databases to a `.sql` dump file.
- Compresses the backup data (including the directory contents and SQL dump) into a zip file.
- Uploads the backup zip file to an S3-compatible cloud storage.
- Excludes specified directories from the backup (e.g., temporary or non-essential files).
- Runs automatically every day at 6:00 AM via a cron job.

This tool is perfect for server administrators and DevOps teams who want to automate daily backups to cloud storage, ensuring data safety and availability.

---

## Features

- **Automated MySQL Database Backup**: Backs up all databases from MySQL to a `.sql` dump file.
- **Directory Backup**: Backs up a specified directory along with the MySQL dump.
- **Exclusion of Directories**: Allows users to exclude specific directories (e.g., temporary or backup files) from being included in the backup.
- **Cloud Upload**: Uploads the backup to an S3-compatible object storage service (e.g., ArvanCloud, AWS S3).
- **Cron Job Scheduling**: The backup runs daily at 6:00 AM automatically, without user intervention.
- **Customizable**: Easily configurable to fit specific directory paths, cloud storage credentials, and MySQL settings.

---

## Prerequisites

Before using this script, ensure that you have the following installed:

- **MySQL or MariaDB**: A MySQL server to back up databases.
- **rclone**: A command-line program to manage files on cloud storage services, compatible with S3-like services.
- **zip**: The `zip` utility to compress backup files.
- **cron**: A job scheduler to run the backup automatically at scheduled intervals.

You can install the required tools using the following commands:

```bash
sudo apt-get update
sudo apt-get install rclone zip mysql-client cron
```

---

## Setup

### 1. **Clone the Repository**

Start by cloning the repository to your server:

```bash
git clone https://github.com/your-username/s3-like-backup.git
cd s3-like-backup
```

### 2. **Configure MySQL Backup**

Edit the script to include your MySQL credentials:

```bash
nano cloud_backup.sh
```

Replace the placeholders with your MySQL user, password, and host:

```bash
DB_USER="your_mysql_user"  
DB_PASSWORD="your_mysql_password"  
DB_HOST="localhost"  # Modify if MySQL is on a different server
```

### 3. **Configure rclone for S3-like Storage**

You need to configure `rclone` to work with your S3-compatible object storage:

- Run the `rclone config` command to create a remote configuration.

```bash
rclone config
```

- Follow the prompts to configure a new remote for your S3 service (e.g., ArvanCloud, AWS S3, or another compatible service).

Once configured, update the `DEST_DIR` variable in the script with the correct remote and path:

```bash
DEST_DIR="your_remote_storage:backup-directory"
```

### 4. **Schedule the Script to Run Automatically**

To run the backup script daily at 6:00 AM, add a cron job:

```bash
crontab -e
```

Add the following line to run the script at 6:00 AM daily:

```bash
0 6 * * * /bin/bash /path/to/cloud_backup.sh
```

Replace `/path/to/cloud_backup.sh` with the actual path to your script.

---

## Script Breakdown

### 1. **Backup MySQL Databases**

The script uses `mysqldump` to back up all databases. The SQL dump is saved in a file (`mysql_backup_<timestamp>.sql`).

```bash
mysqldump --single-transaction --triggers --routines --events --all-databases --set-gtid-purged=OFF -u "$DB_USER" -p"$DB_PASSWORD" -h "$DB_HOST" > "$DB_BACKUP_FILE"
```

### 2. **Zip Data and MySQL Backup**

After the database backup, the script compresses the data directory and the SQL backup into a zip file (`data_backup_<timestamp>.zip`). You can also exclude specific directories (e.g., temporary directories) by adjusting the `--exclude` option:

```bash
zip -r -v "$ZIP_FILE" "$SOURCE_DIR" "$DB_BACKUP_FILE" --exclude "/path/to/exclude/this/directory/*"
```

### 3. **Upload Backup to Cloud Storage**

Using `rclone`, the script uploads the generated zip file to the specified S3-compatible storage:

```bash
rclone copy "$ZIP_FILE" "$DEST_DIR" --verbose --progress
```

### 4. **Clean Up**

After the upload, the temporary files (zip and SQL backup) are deleted:

```bash
rm -f "$ZIP_FILE" "$DB_BACKUP_FILE"
```

---

## Configuration

You can configure the following parameters in the script:

- `SOURCE_DIR`: The local directory to back up (e.g., `/home/ubuntu/data`).
- `DB_USER`: MySQL username (e.g., `root`).
- `DB_PASSWORD`: MySQL password.
- `DB_HOST`: MySQL host (e.g., `localhost`).
- `DEST_DIR`: The destination on your S3-like storage (e.g., `arvancloud:backup-petpars/backups`).
- `EXCLUDE_DIR`: The directories you wish to exclude from the backup.

---

## Example Cron Job

To run the backup script automatically at 6:00 AM every day, add the following cron job:

```bash
0 6 * * * /bin/bash /home/ramtin/cloud_backup.sh
```

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Support

For any issues or questions regarding the script, feel free to open an issue in the repository.

---

## Contributions

Contributions are welcome! Feel free to fork the repository and submit pull requests. Make sure to follow the standard GitHub workflows for issues and pull requests.

---

### Conclusion

This repository provides a simple, automated solution for backing up data to cloud storage. With its ease of setup and flexibility, it is a valuable tool for anyone who needs to manage regular backups to a cloud storage service.
