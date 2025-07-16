#!/bin/bash

# Go Project Structure Creator
# Usage: ./create-go-project.sh <project-name>

set -e

if [ -z "$1" ]; then
  echo "Error: Project name not provided"
  echo "Usage: $0 <project-name>"
  exit 1
fi

PROJECT_NAME=$1

echo "Creating Go project structure for '$PROJECT_NAME'..."

# Create root directory
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Initialize Go module
go mod init "$PROJECT_NAME"

# Create main directories
mkdir -p cmd/"$PROJECT_NAME"
mkdir -p internal/app/{service,repository,handler,models}
mkdir -p internal/pkg
mkdir -p pkg/{utils,logging,config}
mkdir -p api/openapi
mkdir -p configs
mkdir -p migrations
mkdir -p scripts
mkdir -p test/{integration,unit}

# Create main.go file
cat > cmd/"$PROJECT_NAME"/main.go << 'EOF'
package main

import "fmt"

func main() {
    fmt.Println("Hello, World!")
}
EOF

# Create basic config file
cat > configs/app.yaml << 'EOF'
app:
  name: "$PROJECT_NAME"
  version: "0.1.0"
  port: 8080

database:
  host: "localhost"
  port: 5432
  user: "user"
  password: "password"
  name: "$PROJECT_NAME"
EOF

# Create Makefile
cat > Makefile << 'EOF'
.PHONY: build run test clean

build:
	go build -o bin/${PROJECT_NAME} ./cmd/${PROJECT_NAME}

run:
	go run ./cmd/${PROJECT_NAME}

test:
	go test ./...

clean:
	rm -rf bin/
EOF

# Create README.md
cat > README.md << EOF
# $PROJECT_NAME

A Go project.

## Getting Started

### Prerequisites
- Go 1.20+ (or latest stable version)

### Installation
\`\`\`sh
go mod download
\`\`\`

### Running
\`\`\`sh
go run ./cmd/$PROJECT_NAME
\`\`\`

## Project Structure

\`\`\`
$(tree -d -L 2)
\`\`\`
EOF

# Create .gitignore
cat > .gitignore << 'EOF'
# Binaries
bin/
*.exe
*.out

# Dependency directories
vendor/

# IDE specific files
.idea/
.vscode/
*.swp
*.swo

# Environment files
.env
.env.local

# Debug files
debug

# Test output
coverage.txt
profile.out
EOF

echo "Project '$PROJECT_NAME' created successfully!"
echo "Next steps:"
echo "1. cd $PROJECT_NAME"
echo "2. Initialize git: git init"
echo "3. Start coding!"