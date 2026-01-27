variable "ACCOUNT" {
  type = string  
  sensitive = true
  description = "The account number."
  default = "ACCOUNT"
}

variable "ADMIN_DB_PASSWORD" {
  type = string
  sensitive = true
  description = "The DB password for the admin account."
  default = "ADMIN_DB_PASSWORD"
}

variable "ADMIN_DB_USERNAME" {
  type = string
  sensitive = true
  description = "The DB username for the admin account."
  default = "ADMIN_DB_USERNAME"
}

variable "CERT_BODY" {
  type = string
  sensitive = true  
  description = "The certificate body."
  default = "CERT_BODY"
}

variable "CERT_CHAIN" {
  type = string
  sensitive = true  
  description = "The certificate chain."
  default = "CERT_CHAIN"
}

variable "CERT_PRIVATE_KEY" {
  type = string
  sensitive = true
  description = "The certificate private key."
  default = "CERT_PRIVATE_KEY"
}

variable "CLOUDWATCH_EMAIL" {
  type = string
  description = "The email used for cloudwatch endpoint."
  default = "cloudwatch_email@domain.com"
}

variable "DB_ALLOCATED_STORAGE" {
  type = number
  description = "The allocated storage for the database in GB."
  default = 20
}

variable "DB_ENGINE_VERSION" {
  type = string
  description = "The database engine version for the application."
  default = "8.4"
}

variable "DB_INSTANCE_CLASS" {
  type = string
  description = "The database intance class for the application."
  default = "db.t3.medium"
}

variable "DB_INSTANCE_CLASS_MEMORY" {
  type = string
  description = "The database intance class available memory in GB."
  default = "4"
}

variable "DB_PASSWORD" {
  type = string
  sensitive = true
  description = "The DB password for the application."
  default = "DB_PASSWORD"
}

variable "DB_USERNAME" {
  type = string
  sensitive = true
  description = "The DB username for the application."
  default = "DB_USERNAME"
}

variable "DIRECTORY_ADMIN_PASSWORD" {
  type      = string
  sensitive = true
  description = "The admin password for the directory service."
  default = "DIRECTORY_ADMIN_PASSWORD"
}

variable "DLM_INTERVAL" {
  type = number
  description = "The interval for the data lifecycle manager schedule."
  default = 24
}

variable "DLM_INTERVAL_UNIT" {
  type = string
  description = "The unit for the data lifecycle manager schedule."
  default = "HOURS"
}

variable "DLM_RETENTION_DAYS" {
  type = number
  description = "The retention days for the data lifecycle manager schedule."
  default = 7
}

variable "DLM_START_TIME" {
  type = string
  description = "The start time for the data lifecycle manager schedule."
  default = "07:00"
}

variable "ENV" {
  type = string
  description = "The environment in which to deploy the solution."
  default = "dev"
}

variable "EXTERNAL_ID" {
  type = string  
  sensitive = true
  description = "External ID of the automation account role."
  default = "EXTERNAL_ID"
}

variable "FSX_STORAGE_CAPACITY" {
  type = number
  description = "The storage capacity of the FSx file system in GB."
  default = 32
}

variable "FSX_THROUGHPUT_CAPACITY" {
  type = number
  description = "The throughput capacity of the FSx file system in MB/s."
  default = 32
}

variable "INSTANCE_TYPE" {
  type = string
  description = "The instance type for the windows VM."
  default = "r6i.large"
}

variable "MFT_CLUSTER" {
  type = string
  description = "Whether to deploy a clustered MFT environment."
  default = "TRUE"
}

variable "ROLE_ARN" {
  type = string  
  sensitive = true
  description = "ARN of the role used by terraform."
  default = "ARN"
}

variable "ROOT_VOLUME_IOPS" {
  type = number
  description = "The IOPS for the root volume."
  default = 3000
}

variable "ROOT_VOLUME_SIZE" {
  type = number
  description = "The size of the root volume in GB."
  default = 60
}

variable "ROOT_VOLUME_THROUGHPUT" {
  type = number
  description = "The throughput for the root volume in MB/s."
  default = 125
}

variable "ROOT_VOLUME_TYPE" {
  type = string
  description = "The volume type for the root volume."
  default = "gp3"
}