#!/bin/bash

# terraform-init.sh - Creates a standard Terraform project structure

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
  modules/example-module \
  environments/{prod,staging,dev} \
  scripts \
  tests \
  docs

# Create standard files
touch \
  main.tf \
  variables.tf \
  outputs.tf \
  terraform.tfvars.example \
  versions.tf \
  providers.tf \
  README.md \
  .gitignore \
  .terraform-version

# Create environment-specific files
for env in environments/*; do
  touch "${env}/main.tf" "${env}/variables.tf" "${env}/outputs.tf" "${env}/terraform.tfvars"
done

# Create module structure
touch modules/example-module/{main.tf,variables.tf,outputs.tf,README.md}

# Populate .gitignore with common Terraform patterns
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

# Create basic README
cat > README.md << 'EOL'
# ${PROJECT_NAME} Terraform Project

## Overview
This project contains Terraform configurations for [describe purpose].

## Structure
- `environments/`: Contains environment-specific configurations (dev, staging, prod)
- `modules/`: Contains reusable Terraform modules
- `scripts/`: Contains helper scripts for Terraform operations
- `tests/`: Contains test configurations
- `docs/`: Contains project documentation

## Usage
1. Initialize Terraform:
   ```bash
   terraform init