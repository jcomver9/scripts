#!/bin/bash

# multi-cloud-terraform-init.sh - Creates a standardized multi-cloud Terraform project structure

# Check if project name is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <project-name>"
  exit 1
fi

PROJECT_NAME=$1

# Create main project directory
mkdir -p "${PROJECT_NAME}" && cd "${PROJECT_NAME}" || exit

# Create standard directories
mkdir -p \
  modules/{networking,nginx,postgresql}/{aws,gcp,azure} \
  environments/{aws,gcp,azure} \
  scripts \
  tests \
  docs \
  providers

# Create root Terraform files
touch \
  main.tf \
  variables.tf \
  outputs.tf \
  terraform.tfvars.example \
  README.md \
  .gitignore \
  .terraform-version

# Create provider configuration files
cat > providers/aws.tf << 'EOL'
provider "aws" {
  region = var.aws_region
  alias  = "default"
}
EOL

cat > providers/gcp.tf << 'EOL'
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  alias   = "default"
}
EOL

cat > providers/azure.tf << 'EOL'
provider "azurerm" {
  features {}
  alias = "default"

  subscription_id = var.azure_subscription_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
}
EOL

# Create module structure files
for module in networking nginx postgresql; do
  for cloud in aws gcp azure; do
    touch "modules/${module}/${cloud}/main.tf"
  done
  
  # Create common module files
  cat > "modules/${module}/main.tf" << 'EOL'
# This file serves as the module interface
# Actual implementation is in cloud-specific directories
EOL

  touch "modules/${module}/variables.tf"
  touch "modules/${module}/outputs.tf"
done

# Create environment-specific files
for env in aws gcp azure; do
  mkdir -p "environments/${env}"
  touch "environments/${env}/terraform.tfvars"
  touch "environments/${env}/backend.tf"
done

# Create main.tf with multi-cloud structure
cat > main.tf << 'EOL'
# main.tf - Multi-cloud deployment of Nginx and PostgreSQL

locals {
  # Determine which provider to use based on workspace
  provider_config = {
    "aws" = {
      provider = provider.aws.default
      networking_module = module.networking.aws
      nginx_module = module.nginx.aws
      postgresql_module = module.postgresql.aws
    }
    "gcp" = {
      provider = provider.google.default
      networking_module = module.networking.gcp
      nginx_module = module.nginx.gcp
      postgresql_module = module.postgresql.gcp
    }
    "azure" = {
      provider = provider.azurerm.default
      networking_module = module.networking.azure
      nginx_module = module.nginx.azure
      postgresql_module = module.postgresql.azure
    }
  }

  current_provider = local.provider_config[terraform.workspace]
}

# Networking module
module "networking" {
  source = "./modules/networking"

  providers = {
    aws     = aws.default
    google  = google.default
    azurerm = azurerm.default
  }

  # Common variables
  environment       = var.environment
  project_name     = var.project_name
  vpc_cidr         = var.vpc_cidr
  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  region           = var.region
}

# Nginx module
module "nginx" {
  source = "./modules/nginx"

  providers = {
    aws     = aws.default
    google  = google.default
    azurerm = azurerm.default
  }

  # Common variables
  environment      = var.environment
  project_name    = var.project_name
  instance_count  = var.nginx_instance_count
  instance_type   = var.nginx_instance_type
  public_subnets  = local.current_provider.networking_module.public_subnet_ids
  ssh_public_key  = var.ssh_public_key
}

# PostgreSQL module
module "postgresql" {
  source = "./modules/postgresql"

  providers = {
    aws     = aws.default
    google  = google.default
    azurerm = azurerm.default
  }

  # Common variables
  environment          = var.environment
  project_name        = var.project_name
  private_subnets     = local.current_provider.networking_module.private_subnet_ids
  database_version    = var.postgresql_version
  instance_class      = var.postgresql_instance_class
  allocated_storage   = var.postgresql_storage
  database_name       = var.postgresql_db_name
  database_username   = var.postgresql_username
  database_password   = var.postgresql_password
  allow_access_sg     = module.nginx.security_group_id
}
EOL

# Create variables.tf
cat > variables.tf << 'EOL'
# Common variables
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "multi-cloud-app"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "Default region for resources"
  type        = string
  default     = "us-east-1"
}

# Networking variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

# Nginx variables
variable "nginx_instance_count" {
  description = "Number of Nginx instances"
  type        = number
  default     = 2
}

variable "nginx_instance_type" {
  description = "Instance type for Nginx"
  type        = string
  default     = "t3.micro"
}

variable "ssh_public_key" {
  description = "SSH public key for instance access"
  type        = string
}

# PostgreSQL variables
variable "postgresql_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "13"
}

variable "postgresql_instance_class" {
  description = "PostgreSQL instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "postgresql_storage" {
  description = "PostgreSQL storage in GB"
  type        = number
  default     = 20
}

variable "postgresql_db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "appdb"
}

variable "postgresql_username" {
  description = "PostgreSQL admin username"
  type        = string
  default     = "pgadmin"
}

variable "postgresql_password" {
  description = "PostgreSQL admin password"
  type        = string
  sensitive   = true
}

# Provider-specific variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
  default     = ""
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "azure_subscription_id" {
  description = "Azure subscription ID"
  type        = string
  sensitive   = true
}

variable "azure_client_id" {
  description = "Azure client ID"
  type        = string
  sensitive   = true
}

variable "azure_client_secret" {
  description = "Azure client secret"
  type        = string
  sensitive   = true
}

variable "azure_tenant_id" {
  description = "Azure tenant ID"
  type        = string
  sensitive   = true
}

variable "azure_location" {
  description = "Azure location"
  type        = string
  default     = "East US"
}
EOL

# Create outputs.tf
cat > outputs.tf << 'EOL'
output "nginx_public_ips" {
  description = "Public IP addresses of Nginx instances"
  value       = module.nginx.instance_public_ips
}

output "postgresql_endpoint" {
  description = "Database connection endpoint"
  value       = module.postgresql.database_endpoint
  sensitive   = true
}

output "postgresql_username" {
  description = "Database administrator username"
  value       = var.postgresql_username
  sensitive   = true
}
EOL

# Create .gitignore
cat > .gitignore << 'EOL'
# Local .terraform directories
**/.terraform/*

# .tfstate files
*.tfstate
*.tfstate.*

# Crash log files
crash.log

# Exclude all .tfvars files, which are likely to contain sensitive data
*.tfvars
*.tfvars.json

# Ignore override files as they are usually used to override resources locally
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Ignore CLI configuration files
.terraformrc
terraform.rc

# IDE specific files
.idea/
.vscode/
EOL

# Create README.md
cat > README.md << 'EOL'
# ${PROJECT_NAME} - Multi-Cloud Terraform Project

## Overview
This project provides a standardized structure for deploying Nginx and PostgreSQL across AWS, GCP, and Azure using Terraform.

## Structure
- `modules/`: Contains reusable modules for networking, Nginx, and PostgreSQL
  - Each module has cloud-specific implementations (aws/, gcp/, azure/)
- `environments/`: Contains environment-specific configurations
- `providers/`: Contains provider configuration files
- `scripts/`: Contains helper scripts
- `tests/`: Contains test configurations
- `docs/`: Contains project documentation

## Usage

1. Select your cloud provider workspace:
   ```bash
   # For AWS
   terraform workspace new aws
   terraform workspace select aws

   # For GCP
   terraform workspace new gcp
   terraform workspace select gcp

   # For Azure
   terraform workspace new azure
   terraform workspace select azure
