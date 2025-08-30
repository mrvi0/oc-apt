# oc-apt
APT-like Package Manager for OpenComputers (Minecraft 1.7.10)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Lua](https://img.shields.io/badge/Lua-5.3-blue.svg)](https://www.lua.org/)
[![OpenComputers](https://img.shields.io/badge/OpenComputers-1.7.10-green.svg)](https://github.com/MightyPirates/OpenComputers)

A comprehensive package management system for OpenComputers mod, inspired by Debian's APT. Easily install, update, and manage programs on your in-game computers.

## 🌟 Features

- 📦 **One-command package installation and removal**
- 🔄 **Automatic dependency resolution**
- 📋 **Repository management**
- 🔍 **Package search and discovery**
- 📊 **Detailed package information display**
- 💾 **Local database of installed packages**
- 🛠️ **Developer tools for package creation**
- 🎨 **Colorized terminal output**
- ⚡ **Fast and lightweight**

## 📋 Requirements

- OpenComputers mod for Minecraft 1.7.10
- Internet Card (for downloading packages)
- At least 192KB of memory
- 64KB of storage space

## 🚀 Quick Installation

### Method 1: One-line Installation
```bash
wget https://raw.githubusercontent.com/mrvi0/oc-apt/main/install.lua && lua install.lua
```

### Method 2: Manual Installation
1. Download the installer:
   ```bash
   wget https://raw.githubusercontent.com/mrvi0/oc-apt/main/install.lua
   ```

2. Run the installer:
   ```bash
   lua install.lua
   ```

3. The installer will:
   - Download the main `oc-apt.lua` script
   - Install it to `/usr/bin/`
   - Create a symbolic link as `apt`
   - Set up necessary directories

## 📖 Usage Guide

### Basic Package Management

#### Update Package Lists
Before installing packages, update the repository information:
```bash
apt update
```

#### Search for Packages
Find packages by name or description:
```bash
apt search <query>

# Examples:
apt search editor
apt search network
apt search wget
```

#### Install Packages
Install a package and its dependencies:
```bash
apt install <package_name>

# Examples:
apt install wget
apt install file-manager
apt install network-tools
```

#### Remove Packages
Uninstall a package:
```bash
apt remove <package_name>

# Example:
apt remove wget
```

#### Show Package Information
Display detailed information about a package:
```bash
apt show <package_name>

# Example:
apt show file-manager
```

#### List Packages
```bash
# List all available packages
apt list

# List only installed packages
apt list --installed
```

#### Upgrade All Packages
Update all installed packages to their latest versions:
```bash
apt upgrade
```

### Repository Management

#### Add a Repository
```bash
apt add-repo <repository_url>

# Example:
apt add-repo https://example.com/packages.json
```

#### Remove a Repository
```bash
apt remove-repo <repository_url>
```

#### List Repositories
```bash
apt list-repos
```

### Help and Version Information
```bash
# Show help
apt

# Show version (check the script)
apt --version
```

## 📚 Available Packages

The default repository includes useful packages such as:

- **wget** - Download files from the internet
- **editor** - Simple text editor
- **file-manager** - Advanced file manager with GUI
- **network-tools** - Network utilities (ping, traceroute, netstat)
- **json-lib** - JSON encoding/decoding library
- **package-manager** - GUI package manager
- **system-monitor** - System resource monitor
- **oc-htop** - Advanced system monitor inspired by htop
- **backup-tool** - Backup and restore utility
- **web-server** - Simple HTTP server
- **database** - Simple database system

## 🛠️ For Package Developers

### Creating a Package

1. **Use the Package Creator Tool:**
   ```bash
   wget https://raw.githubusercontent.com/mrvi0/oc-apt/main/create-package.lua
   lua create-package.lua create
   ```

2. **Follow the interactive prompts** to define your package

3. **Validate your package:**
   ```bash
   wget https://raw.githubusercontent.com/mrvi0/oc-apt/main/validate-package.lua
   lua validate-package.lua package.json
   ```

### Package Structure

Packages are defined in JSON format:

```json
{
  "name": "my-package",
  "version": "1.0.0",
  "description": "Description of my package",
  "author": "Your Name",
  "license": "MIT",
  "dependencies": ["dependency1", "dependency2"],
  "files": {
    "/usr/bin/myapp.lua": "https://example.com/files/myapp.lua",
    "/etc/myapp.conf": "https://example.com/files/myapp.conf"
  },
  "executable": ["/usr/bin/myapp.lua"],
  "keywords": ["utility", "tool"],
  "install_script": "https://example.com/install.lua",
  "remove_script": "https://example.com/remove.lua",
  "requirements": {
    "components": ["internet", "gpu"],
    "minimum_memory": 192,
    "minimum_storage": 64
  }
}
```

### Package Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | ✅ | Package name (lowercase, alphanumeric, hyphens) |
| `version` | ✅ | Semantic version (x.y.z) |
| `description` | ✅ | Short description of the package |
| `author` | ✅ | Package author |
| `license` | ❌ | License (default: MIT) |
| `dependencies` | ❌ | Array of required packages |
| `files` | ❌ | Object mapping destination paths to source URLs |
| `executable` | ❌ | Array of files to make executable |
| `keywords` | ❌ | Array of search keywords |
| `install_script` | ❌ | URL to installation script |
| `remove_script` | ❌ | URL to removal script |
| `requirements` | ❌ | System requirements |

### Repository Format

A repository is a JSON file containing multiple packages:

```json
{
  "package1": { /* package definition */ },
  "package2": { /* package definition */ },
  "package3": { /* package definition */ }
}
```

## 🏗️ Development

### Building and Testing

If you want to contribute or modify the project:

```bash
# Clone the repository
git clone https://github.com/mrvi0/oc-apt.git
cd oc-apt

# Validate syntax
make validate

# Test package validation
make examples

# Clean temporary files
make clean
```

### Project Structure

```
oc-apt/
├── oc-apt.lua              # Main APT manager script
├── install.lua             # Installation script
├── create-package.lua      # Package creation tool
├── validate-package.lua    # Package validation tool
├── example-packages.json   # Example repository
├── examples/
│   └── simple-wget/        # Example package
│       ├── wget.lua
│       └── package.json
├── packages/               # Official packages
│   └── oc-htop/           # System monitor package
│       ├── oc-htop.lua
│       ├── package.json
│       └── README.md
├── Makefile               # Build automation
├── README.md              # This file
├── USAGE_EXAMPLES.md      # Detailed usage examples
├── CHANGELOG.md           # Version history
└── LICENSE                # MIT License
```

## 🔧 Configuration

### Default Directories

- **Configuration:** `/etc/oc-apt/`
- **Cache:** `/var/cache/oc-apt/`
- **Database:** `/var/lib/oc-apt/installed.json`
- **Repositories:** `/etc/oc-apt/sources.list`

### Default Repository

The system comes pre-configured with a default repository. You can add additional repositories using the `apt add-repo` command.

## 🐛 Troubleshooting

### Common Issues

**"Internet card required"**
- Install an Internet Card in your computer
- Make sure the card is properly configured

**"Package not found"**
- Run `apt update` to refresh package lists
- Check if the package name is correct with `apt search`

**"Failed to download"**
- Check your internet connection
- Verify the repository URLs are accessible

**"Permission denied"**
- Ensure you have write access to system directories
- Some packages may require specific permissions

### Getting Help

1. Check this README for usage instructions
2. Use `apt` without arguments to see available commands
3. Open an issue on GitHub for bugs or feature requests

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Areas for Contribution

- Additional utility packages
- GUI improvements
- Performance optimizations
- Documentation updates
- Bug fixes

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **OpenComputers Team** for the amazing mod
- **Debian APT Team** for inspiration
- **OpenComputers Community** for feedback and support

## 📞 Support

- **GitHub Issues:** [Report bugs or request features](https://github.com/mrvi0/oc-apt/issues)
- **OpenComputers Forum:** [Community discussions](https://oc.cil.li/)
- **Discord:** OpenComputers community server

---

**Made with ❤️ for the OpenComputers community**
