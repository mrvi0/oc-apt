# OC-APT Repository Architecture

This document describes the recommended architecture for OC-APT package repositories to maximize community adoption and contribution.

## 🎯 Goals

- **Easy contribution**: Anyone can create and maintain their own packages
- **Decentralized**: No single point of failure
- **Discoverable**: Users can easily find packages
- **Quality control**: Curated official packages with community additions
- **Scalable**: Architecture grows with the community

## 🏗️ Recommended Architecture

### Core Repositories

1. **`oc-apt/oc-apt`** - Main package manager
   - Contains the APT manager core
   - Installation scripts
   - Documentation
   - Official package registry (packages.json)

2. **`oc-apt/registry`** - Community package index
   - Curated list of all known package repositories
   - Package discovery and search
   - Quality ratings and reviews
   - Automated package validation

### Package Repository Types

#### 1. Official Packages (`oc-apt/packages-*`)
```
oc-apt/packages-core      - Essential system utilities
oc-apt/packages-network   - Network tools
oc-apt/packages-system    - System monitoring and management
oc-apt/packages-dev       - Development tools
oc-apt/packages-games     - Games and entertainment
```

#### 2. Community Packages (`username/oc-package-name`)
```
mrvi0/oc-package-htop     - Individual package repositories
alice/oc-package-editor   - Each package has its own repo
bob/oc-package-web-server - Easy to maintain and contribute
```

#### 3. Collection Repositories (`username/oc-packages-*`)
```
company/oc-packages-enterprise  - Enterprise tools collection
team/oc-packages-minecraft      - Minecraft integration tools
user/oc-packages-personal       - Personal utility collection
```

## 📋 Package Repository Structure

### Individual Package Repository
```
oc-package-htop/
├── package.json          # Package metadata
├── src/                  # Source files
│   └── htop.lua
├── README.md             # Documentation
├── CHANGELOG.md          # Version history
├── LICENSE               # License file
├── .github/
│   └── workflows/
│       └── validate.yml  # CI validation
└── examples/             # Usage examples
```

### Collection Repository
```
oc-packages-system/
├── registry.json         # Package index
├── packages/
│   ├── htop/
│   │   ├── package.json
│   │   └── src/
│   ├── top/
│   │   ├── package.json
│   │   └── src/
│   └── sysinfo/
│       ├── package.json
│       └── src/
└── README.md
```

## 🔍 Package Discovery Workflow

### 1. Central Registry
The main registry (`oc-apt/registry`) maintains:

```json
{
  "repositories": [
    {
      "name": "Official Core Packages",
      "url": "https://raw.githubusercontent.com/oc-apt/packages-core/main/registry.json",
      "type": "official",
      "category": "core"
    },
    {
      "name": "Community System Tools", 
      "url": "https://raw.githubusercontent.com/mrvi0/oc-packages-system/main/registry.json",
      "type": "community",
      "category": "system"
    }
  ]
}
```

### 2. Auto-Discovery
```bash
# Add official repositories
apt add-repo https://raw.githubusercontent.com/oc-apt/packages-core/main/registry.json

# Add community repositories  
apt add-repo https://raw.githubusercontent.com/mrvi0/oc-packages-system/main/registry.json

# Search across all repositories
apt search htop
```

### 3. Package Installation
```bash
# Install from any registered repository
apt install htop

# Install from specific repository
apt install --repo mrvi0/oc-packages-system htop

# Install directly from GitHub
apt install-from-github mrvi0/oc-package-htop
```

## 🎯 Benefits for Community Growth

### For Package Developers
- **Own their packages**: Complete control over their repository
- **Easy maintenance**: Standard GitHub workflow
- **Automatic CI/CD**: GitHub Actions for validation
- **Discoverability**: Listed in central registry
- **Recognition**: Author attribution in package manager

### For Users
- **Rich ecosystem**: Many packages to choose from
- **Quality assurance**: Official + community validation
- **Easy installation**: Single command installs from any repo
- **Updates**: Automatic updates from source repositories
- **Trust**: Can inspect source before installing

### For Project Maintainers
- **Reduced workload**: Community maintains their own packages
- **Quality control**: Can curate official packages
- **Scalability**: Architecture scales with adoption
- **Flexibility**: Multiple distribution models

## 🚀 Implementation Plan

### Phase 1: Core Infrastructure
1. Create `oc-apt/registry` repository
2. Set up official package repositories
3. Implement multi-repo support in APT manager
4. Create package submission guidelines

### Phase 2: Community Tools
1. GitHub Actions for package validation
2. Web interface for package discovery
3. Quality rating system
4. Automated security scanning

### Phase 3: Ecosystem Growth
1. Documentation and tutorials
2. Package creation templates
3. Developer incentives (badges, showcases)
4. Integration with OpenComputers community sites

## 📝 Package Submission Process

### For Official Packages
1. Create package in personal repository
2. Test thoroughly with multiple OpenComputers setups
3. Submit pull request to appropriate official repository
4. Code review and quality check
5. Merge and inclusion in official registry

### For Community Packages
1. Create package repository using template
2. Validate with GitHub Actions
3. Submit to community registry
4. Automated inclusion after validation
5. Optional: Apply for official status later

## 🔧 Technical Implementation

### APT Manager Changes
```lua
-- Support for multiple repository types
local function add_repository(url, type)
    if type == "registry" then
        -- Load registry and add all listed repositories
        load_registry(url)
    elseif type == "collection" then
        -- Load collection repository
        load_collection(url)
    else
        -- Load single package repository
        load_package_repo(url)
    end
end
```

### Repository Validation
- JSON schema validation
- Package file accessibility checks
- Security scanning for malicious code
- Dependency resolution verification
- OpenComputers compatibility testing

This architecture promotes:
- **Community ownership** of packages
- **Decentralized development** 
- **Easy discovery** and installation
- **Quality maintenance** through automation
- **Rapid ecosystem growth** 