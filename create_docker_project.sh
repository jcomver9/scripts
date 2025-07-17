import os
import argparse
from datetime import datetime

def create_file(path, content):
    """Create a file with the given content"""
    with open(path, 'w') as f:
        f.write(content)

def create_docker_project(project_name):
    """Create a Docker project structure with template files"""
    
    # Create project directory
    os.makedirs(project_name, exist_ok=True)
    print(f"Created project directory: {project_name}")
    
    # Define files and their template content
    files = {
        'Dockerfile': f"""# {project_name} Dockerfile
# Generated on {datetime.now().strftime('%Y-%m-%d')}

# Use an official base image
FROM python:3.9-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set work directory
WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project
COPY . .

# Command to run when the container starts
CMD ["python", "app.py"]
""",
        
        'docker-compose.yml': f"""# {project_name} Docker Compose configuration
version: '3.8'

services:
  app:
    build: .
    ports:
      - "8000:8000"
    volumes:
      - .:/app
    environment:
      - ENV=development
    depends_on:
      - redis

  redis:
    image: "redis:alpine"
    ports:
      - "6379:6379"
""",
        
        'requirements.txt': f"""# {project_name} requirements
flask==2.0.1
redis==3.5.3
""",
        
        '.dockerignore': """# Files to ignore in Docker builds
__pycache__
*.pyc
*.pyo
*.pyd
.Python
env
venv
.venv
.env
.git
.gitignore
Dockerfile
docker-compose.yml
README.md
""",
        
        'README.md': f"""# {project_name} Docker Project

## Project Overview
Brief description of your project and its purpose.

## Getting Started

### Prerequisites
- Docker
- Docker Compose

### Installation
1. Clone this repository
2. Run `docker-compose build` to build the images
3. Run `docker-compose up` to start the services

## Configuration
Environment variables and other configuration options.

## Usage
How to use the application once it's running.

## Development
Instructions for developers working on the project.
""",
        
        'app.py': f"""# {project_name} Main Application
from flask import Flask
import redis
import os

app = Flask(__name__)
redis_client = redis.Redis(host='redis', port=6379, db=0)

@app.route('/')
def hello():
    count = redis_client.incr('hits')
    return f'Hello from {project_name}! This page has been viewed {{count}} times.\\n'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000, debug=os.getenv('ENV') == 'development')
"""
    }
    
    # Create each file in the project directory
    for filename, content in files.items():
        filepath = os.path.join(project_name, filename)
        create_file(filepath, content)
        print(f"Created file: {filepath}")
    
    print(f"\nDocker project '{project_name}' created successfully!")
    print(f"Navigate to the project directory and run 'docker-compose up' to start the services.")

def main():
    parser = argparse.ArgumentParser(description='Create a Docker project structure with template files.')
    parser.add_argument('project_name', help='Name of the Docker project to create')
    args = parser.parse_args()
    
    create_docker_project(args.project_name)

if __name__ == '__main__':
    main()