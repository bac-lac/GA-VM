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

> ALB_NAME *: The name of the application load balancer.
- Default value: ga-alb

> CERT_BODY *: The certificate body.
- Default value: CERT_BODY

> CERT_CHAIN *: The certificate chain.
- Default value: CERT_CHAIN

> CERT_PRIVATE_KEY *: The certificate private key.
- Default value: CERT_PRIVATE_KEY

> CLOUDWATCH_EMAIL *: The email used for cloudwatch endpoint.
- Default value: cloudwatch_email@domain.com

> DB_INSTANCE_CLASS *: The database intance class for the application.
- Default value: db.t3.medium

> DB_INSTANCE_CLASS_MEMORY *: The database intance class available memory in GB.
- Default value: 4

> DB_USERNAME *: The DB username for the application.
- Default value: DB_USERNAME

> DB_PASSWORD *: The DB password for the application.
- Default value: DB_PASSWORD

> ENV *: The environment in which to deploy the solution.
- Default value: dev
- Allowed values: dev, test or prod

> EXTERNAL_ID *: External ID of the automation account role.
- Default value: EXTERNAL_ID

> MFT_CLUSTER *: If set to true, this will start the application in cluster mode.
- Default value: TRUE

> ROLE_ARN *: ARN of the role used by terraform..
- Default value: ROLE_ARN

# Code Check
[Checkov](https://www.checkov.io/)