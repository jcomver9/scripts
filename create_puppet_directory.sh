#!/bin/bash

# Script to create a basic Puppet directory structure

# Set the base directory (can be customized)
BASE_DIR="puppet"

# Create main Puppet directories
mkdir -p "$BASE_DIR/manifests"
mkdir -p "$BASE_DIR/modules"
mkdir -p "$BASE_DIR/environments/production/manifests"
mkdir -p "$BASE_DIR/environments/production/modules"

# Optionally, create a site manifest
touch "$BASE_DIR/manifests/site.pp"

# Optionally, create a README
cat <<EOF > "$BASE_DIR/README.md"
# Puppet Directory Structure

- manifests/: Top-level manifests (e.g., site.pp)
- modules/: Custom or external modules
- environments/production/: Production environment (manifests and modules)

EOF

echo "Puppet directory structure created under '$BASE_DIR/'"
