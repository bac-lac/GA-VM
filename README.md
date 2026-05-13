# Introduction
This project will deploy the infrastructure for GoAnywhere.

## Environment Variables
The following environment variables are used to control the application at run-time. Mandatory variables are marked with an asterisk.

> ACCOUNT *: The AWS account number.
- Default value: ACCOUNT

> ADMIN_DB_USERNAME *: The DB username for the admin account.
- Default value: ADMIN_DB_USERNAME

> ADMIN_DB_PASSWORD *: The DB password for the admin account.
- Default value: ADMIN_DB_PASSWORD

> AMI_ID *: The AMI ID for the application instances.
- Default value: AMI_ID

> CERT_BODY *: The certificate body.
- Default value: CERT_BODY

> CERT_CHAIN *: The certificate chain.
- Default value: CERT_CHAIN

> CERT_PRIVATE_KEY *: The certificate private key.
- Default value: CERT_PRIVATE_KEY

> CLOUDWATCH_EMAIL *: The email used for cloudwatch endpoint (CloudOps).
- Default value: cloudwatch_email@domain.com

> DAMS_EMAIL *: The email used for cloudwatch endpoint (DAMS).
- Default value: dams_email@domain.com

> DB_ALLOCATED_STORAGE *: The allocated storage for the database in GB.
- Default value: 20

> DB_BACKUP_WINDOW *: The backup window for the database. (UTC)
- Default value: 07:00-08:00

> DB_ENGINE_VERSION *: The database engine version for the application.
- Default value: 8.4

> DB_INSTANCE_CLASS *: The database intance class for the application.
- Default value: db.t3.medium

> DB_INSTANCE_CLASS_MEMORY *: The database intance class available memory in GB.
- Default value: 4

> DB_MAINTENANCE_WINDOW *: The maintenance window for the database. (UTC)
- Default value: sat:05:00-sat:06:00

> DIRECTORY_ADMIN_PASSWORD *: The admin password for the directory service.
- Default value: DIRECTORY_ADMIN_PASSWORD

> DLM_INTERVAL *: The interval for the data lifecycle manager schedule.
- Default value: 24

> DLM_INTERVAL_UNIT *: The unit for the data lifecycle manager schedule.
- Default value: HOURS

> DLM_RETENTION_DAYS *: The retention days for the data lifecycle manager schedule.
- Default value: 7

> DLM_START_TIME *: The start time for the data lifecycle manager schedule.
- Default value: 04:00

> ENV *: The environment in which to deploy the solution.
- Default value: dev
- Allowed values: pr, dev, pre-prod or prod

> EXTERNAL_ID *: External ID of the automation account role.
- Default value: EXTERNAL_ID

> FSX_STORAGE_CAPACITY *: The storage capacity of the FSx file system in GB.
- Default value: 32

> FSX_THROUGHPUT_CAPACITY *: The throughput capacity of the FSx file system in MB/s.
- Default value: 32

> INSTANCE_TYPE *: The instance type for the EC2 VM.
- Default value: r6i.large

> MFT_CLUSTER *: Whether to deploy a clustered MFT environment.
- Default value: TRUE

> ROLE_ARN *: ARN of the role used by terraform.
- Default value: ROLE_ARN

> ROOT_VOLUME_IOPS *: The IOPS for the root volume.
- Default value: 3000

> ROOT_VOLUME_SIZE *: The size of the root volume in GB.
- Default value: 60

> ROOT_VOLUME_THROUGHPUT *: The throughput for the root volume in MB/s.
- Default value: 125

> ROOT_VOLUME_TYPE *: The volume type for the root volume.
- Default value: gp3

# Code Check
[Checkov](https://www.checkov.io/)