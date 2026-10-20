variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-central-1"
}

variable "db_username" {
  description = "Master username for RDS PostgreSQL"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Master password for RDS PostgreSQL"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name in RDS PostgreSQL"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository in format owner/repo"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch that triggers CI/CD"
  type        = string
}

variable "budget_email" {
  description = "Email for AWS budget overspend notifications"
  type        = string
}

variable "budget_limit_usd" {
  description = "Monthly budget limit in USD"
  type        = string
  default     = "5"
}