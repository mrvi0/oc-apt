# Usage Examples for OC-APT

This document provides detailed examples of how to use the OC-APT package manager in various scenarios.

## 🚀 Getting Started

### First Time Setup

```bash
# 1. Download and install OC-APT
wget https://raw.githubusercontent.com/mrvi0/oc-apt/main/install.lua
lua install.lua

# 2. Update package lists
apt update

# 3. See what's available
apt list
```

### Basic Workflow

```bash
# Search for a specific tool
apt search editor

# Get information about a package
apt show editor

# Install the package
apt install editor

# Verify installation
apt list --installed

# Use the installed program
edit myfile.txt
```

## 📦 Package Management Examples

### Installing Development Tools

```bash
# Install a complete development environment
apt install editor
apt install file-manager
apt install wget
apt install json-lib

# Verify all installations
apt list --installed
```

### Setting Up a Web Server

```bash
# Install web server with dependencies
apt install web-server  # Automatically installs json-lib dependency

# Check what was installed
apt show web-server

# Start the web server
httpd
```

### Network Utilities Setup

```bash
# Install network diagnostic tools
apt install network-tools

# Use the tools
ping google.com
traceroute 8.8.8.8
netstat
```

### Database Development

```bash
# Install database system
apt install database

# This automatically installs json-lib as dependency
# Start using the database
db create mydata
db insert mydata name="John" age=30
db select mydata
```

## 🔧 Advanced Usage

### Managing Multiple Repositories

```bash
# Add a custom repository
apt add-repo https://example.com/custom-packages.json

# List all configured repositories
apt list-repos

# Update from all repositories
apt update

# Remove a repository if needed
apt remove-repo https://example.com/custom-packages.json
```

### Batch Operations

```bash
# Install multiple packages at once
apt install wget editor file-manager network-tools

# Update all packages
apt upgrade

# Remove multiple packages
apt remove package1 package2 package3
```

### Searching and Discovery

```bash
# Search for packages by name
apt search wget

# Search for packages by description
apt search "text editor"

# Search for network-related packages
apt search network

# Find all available packages
apt list
```

## 🛠️ Developer Examples

### Creating Your First Package

```bash
# Download the package creator
wget https://raw.githubusercontent.com/mrvi0/oc-apt/main/create-package.lua

# Start the interactive package creator
lua create-package.lua create
```

Follow the prompts:
```
Package name: my-calculator
Version: 1.0.0
Description: Simple calculator for OpenComputers
Author: Your Name
License: MIT
Dependencies: 
File mapping: /usr/bin/calc.lua=./calculator.lua
Make /usr/bin/calc.lua executable? [Y/n]: y
Keywords: calculator, math, utility
```

### Validating Packages

```bash
# Download the validator
wget https://raw.githubusercontent.com/mrvi0/oc-apt/main/validate-package.lua

# Validate your package
lua validate-package.lua package.json
```

### Testing Package Installation

```bash
# Test your package locally before publishing
# 1. Create a local repository file
cat > local-repo.json << EOF
{
  "my-calculator": {
    "name": "my-calculator",
    "version": "1.0.0",
    "description": "Simple calculator",
    "files": {
      "/usr/bin/calc.lua": "http://localhost:8080/calculator.lua"
    }
  }
}
EOF

# 2. Serve your files (use a local HTTP server)
# 3. Add the local repository
apt add-repo http://localhost:8080/local-repo.json

# 4. Test installation
apt update
apt install my-calculator
```

## 📋 Troubleshooting Examples

### Common Installation Issues

```bash
# Issue: "Internet card required"
# Solution: Check for internet card
components

# Issue: "Package not found"
# Solution: Update package lists
apt update
apt search package-name

# Issue: "Failed to download"
# Solution: Check network connectivity
ping google.com
```

### Dependency Problems

```bash
# If dependencies are broken, try:
apt update
apt upgrade

# Force reinstall a package
apt remove package-name
apt install package-name
```

### Storage Issues

```bash
# Check available storage
df

# Clean up cache if needed
# (Note: OC-APT doesn't have built-in cache cleaning yet)
# Remove unnecessary packages
apt remove unused-package
```

## 🎯 Use Case Scenarios

### Scenario 1: Setting Up a Monitoring Server

```bash
# Install system monitoring tools
apt install system-monitor

# Install web server for dashboard
apt install web-server

# Install backup tool for data safety
apt install backup-tool

# Configure and start services
htop &
httpd &
```

### Scenario 2: Development Environment

```bash
# Essential development tools
apt install editor
apt install file-manager
apt install wget
apt install json-lib

# Optional: package manager GUI
apt install package-manager
```

### Scenario 3: Network Administration

```bash
# Network diagnostic and management tools
apt install network-tools
apt install web-server

# Test network connectivity
ping 8.8.8.8
traceroute google.com
netstat -a
```

### Scenario 4: Data Management

```bash
# Database and backup tools
apt install database
apt install backup-tool
apt install json-lib

# Set up automated backups
backup --schedule daily --target /mnt/backup
```

## 📊 Package Information Examples

### Getting Detailed Package Info

```bash
# Show comprehensive package information
apt show web-server
```

Output example:
```
Package: web-server
Version: 1.0.0
Description: Simple HTTP web server
Author: oc-apt
Dependencies: json-lib
Files:
  /usr/bin/httpd.lua
  /etc/httpd.conf
  /var/www/index.html
Status: Not installed
```

### Checking Installation Status

```bash
# List all installed packages with versions
apt list --installed

# Check if specific package is installed
apt list --installed | grep wget
```

## 🔄 Update and Maintenance Examples

### Regular Maintenance Routine

```bash
# Weekly maintenance script
#!/usr/bin/env lua

print("Starting weekly maintenance...")

# Update package lists
os.execute("apt update")

# Upgrade all packages
os.execute("apt upgrade")

# List installed packages for review
os.execute("apt list --installed")

print("Maintenance complete!")
```

### Selective Updates

```bash
# Update only specific packages
apt show package-name  # Check current version
apt remove package-name
apt install package-name  # Install latest version
```

## 🎨 Integration Examples

### Using OC-APT in Scripts

```lua
-- Example: Auto-installer script
local os = require("os")

local required_packages = {
    "wget",
    "editor", 
    "file-manager",
    "json-lib"
}

print("Installing required packages...")

-- Update package lists
os.execute("apt update")

-- Install each package
for _, package in ipairs(required_packages) do
    print("Installing " .. package .. "...")
    local result = os.execute("apt install " .. package)
    if result == 0 then
        print("✓ " .. package .. " installed successfully")
    else
        print("✗ Failed to install " .. package)
    end
end

print("Installation complete!")
```

### Custom Package Manager GUI

```lua
-- Example: Simple GUI wrapper for APT
local term = require("term")
local gpu = require("component").gpu

local function show_menu()
    term.clear()
    print("=== OC-APT Package Manager ===")
    print("1. Update package lists")
    print("2. Search packages")
    print("3. List installed")
    print("4. Install package")
    print("5. Remove package")
    print("0. Exit")
    print()
    io.write("Choice: ")
end

local function main()
    while true do
        show_menu()
        local choice = io.read()
        
        if choice == "1" then
            os.execute("apt update")
        elseif choice == "2" then
            io.write("Search query: ")
            local query = io.read()
            os.execute("apt search " .. query)
        elseif choice == "3" then
            os.execute("apt list --installed")
        elseif choice == "4" then
            io.write("Package name: ")
            local package = io.read()
            os.execute("apt install " .. package)
        elseif choice == "5" then
            io.write("Package name: ")
            local package = io.read()
            os.execute("apt remove " .. package)
        elseif choice == "0" then
            break
        end
        
        print("\nPress Enter to continue...")
        io.read()
    end
end

main()
```

These examples should help you get the most out of OC-APT package manager! 