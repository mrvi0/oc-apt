# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive usage examples documentation
- International documentation in English

### Changed
- Improved README structure and formatting

## [1.0.0] - 2025-01-XX

### Added
- Complete APT package manager implementation
- Package installation and removal functionality
- Automatic dependency resolution system
- Repository management capabilities
- Package search and information display
- Colorized terminal output for better UX
- Installation script for easy setup
- Package creation tools for developers
- Package validation utilities
- Example packages (wget implementation)
- Comprehensive documentation
- Build automation with Makefile
- Support for install/remove scripts
- Local database for installed packages
- Multiple repository support

### Features
- **Core Package Management:**
  - Install packages with `apt install <package>`
  - Remove packages with `apt remove <package>`
  - Update package lists with `apt update`
  - Upgrade all packages with `apt upgrade`
  - Search packages with `apt search <query>`
  - Show package info with `apt show <package>`
  - List packages with `apt list [--installed]`

- **Repository Management:**
  - Add repositories with `apt add-repo <url>`
  - Remove repositories with `apt remove-repo <url>`
  - List repositories with `apt list-repos`

- **Developer Tools:**
  - Interactive package creator (`create-package.lua`)
  - Package validator (`validate-package.lua`)
  - Example package structure

- **System Features:**
  - Automatic dependency resolution
  - Install/remove script execution
  - File conflict detection
  - Version checking and updates
  - Persistent package database
  - Multi-repository support

### Technical Details
- **Language:** Lua 5.3 compatible
- **Platform:** OpenComputers for Minecraft 1.7.10
- **Dependencies:** Internet Card component required
- **Storage:** Minimum 64KB storage space
- **Memory:** Minimum 192KB RAM

### Project Structure
```
oc-apt/
├── oc-apt.lua              # Main APT manager (18KB)
├── install.lua             # Installation script (4KB)
├── create-package.lua      # Package creation tool (11KB)
├── validate-package.lua    # Package validation (3KB)
├── example-packages.json   # Sample repository (4KB)
├── examples/               # Example packages
│   └── simple-wget/        # wget implementation
├── Makefile               # Build automation
├── README.md              # Main documentation
├── USAGE_EXAMPLES.md      # Detailed usage examples
├── CHANGELOG.md           # This file
└── LICENSE                # MIT License
```

### Repository Format
- JSON-based package definitions
- HTTP/HTTPS repository support
- Semantic versioning for packages
- Dependency specification support
- File mapping with URL sources
- Install/remove script support

### Security
- Package validation and verification
- Safe file operations with error handling
- No automatic script execution without user consent
- Repository URL validation

## [0.0.1] - 2025-01-XX

### Added
- Initial project setup
- Basic project structure
- MIT License
- Git repository initialization

---

## Contributing

When contributing to this project, please:

1. Follow [Conventional Commits](https://www.conventionalcommits.org/) for commit messages
2. Update this CHANGELOG.md for notable changes
3. Bump version numbers according to [Semantic Versioning](https://semver.org/)
4. Add entries under the "Unreleased" section
5. Move entries to a new version section when releasing

### Commit Types
- `feat:` New features
- `fix:` Bug fixes
- `docs:` Documentation changes
- `style:` Code style changes
- `refactor:` Code refactoring
- `test:` Test additions or changes
- `chore:` Build/tool changes 