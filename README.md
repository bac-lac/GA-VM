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

> CERT_BODY *: The certificate body.
- Default value: CERT_BODY

> CERT_CHAIN *: The certificate chain.
- Default value: CERT_CHAIN

> CERT_PRIVATE_KEY *: The certificate private key.
- Default value: CERT_PRIVATE_KEY

> CLOUDWATCH_EMAIL *: The email used for cloudwatch endpoint.
- Default value: cloudwatch_email@domain.com

> DB_ALLOCATED_STORAGE *: The allocated storage for the database in GB.
- Default value: 20

> DB_ENGINE_VERSION *: The database engine version for the application.
- Default value: 8.4

> DB_INSTANCE_CLASS *: The database intance class for the application.
- Default value: db.t3.medium

> DB_INSTANCE_CLASS_MEMORY *: The database intance class available memory in GB.
- Default value: 4

> DB_USERNAME *: The DB username for the application.
- Default value: DB_USERNAME

> DB_PASSWORD *: The DB password for the application.
- Default value: DB_PASSWORD

> DIRECTORY_ADMIN_PASSWORD *: The admin password for the directory service.
- Default value: DIRECTORY_ADMIN_PASSWORD

> ENV *: The environment in which to deploy the solution.
- Default value: dev
- Allowed values: pr, dev, test or prod

> EXTERNAL_ID *: External ID of the automation account role.
- Default value: EXTERNAL_ID

> FSX_STORAGE_CAPACITY *: The storage capacity of the FSx file system in GB.
- Default value: 32

> FSX_THROUGHPUT_CAPACITY *: External ID of the automation account role.
- Default value: 32

> INSTANCE_TYPE *: The instance type for the windows VM.
- Default value: r6i.large

> MFT_CLUSTER *: The throughput capacity of the FSx file system in MB/s.
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