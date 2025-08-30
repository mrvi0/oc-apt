# OC-APT Makefile
# Makefile for OpenComputers APT package manager

.PHONY: help install test clean validate examples deploy

# Default target
help:
	@echo "OC-APT Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  help      - Show this help message"
	@echo "  validate  - Validate Lua syntax of all scripts"
	@echo "  examples  - Validate all example packages"
	@echo "  clean     - Clean temporary files"
	@echo "  deploy    - Deploy to GitHub releases"
	@echo ""
	@echo "Usage in OpenComputers:"
	@echo "  wget https://raw.githubusercontent.com/oc-apt/oc-apt/main/install.lua"
	@echo "  lua install.lua"

# Validate Lua syntax
validate:
	@echo "Validating Lua syntax..."
	@luac -p oc-apt.lua
	@luac -p install.lua  
	@luac -p create-package.lua
	@luac -p examples/simple-wget/wget.lua
	@echo "All files validated successfully!"

# Validate example packages
examples:
	@echo "Validating example packages..."
	@lua validate-package.lua examples/simple-wget/package.json
	@echo "Example packages validated successfully!"

# Clean temporary files
clean:
	@echo "Cleaning temporary files..."
	@find . -name "*.tmp" -delete
	@find . -name "*~" -delete
	@echo "Clean complete!"

# Deploy release (requires GitHub CLI)
deploy:
	@echo "Creating GitHub release..."
	@if ! command -v gh &> /dev/null; then \
		echo "Error: GitHub CLI (gh) is required for deployment"; \
		exit 1; \
	fi
	@gh release create v$(shell grep -o '"version": "[^"]*"' oc-apt.lua | cut -d'"' -f4) \
		--title "OC-APT v$(shell grep -o '"version": "[^"]*"' oc-apt.lua | cut -d'"' -f4)" \
		--notes "Release of OC-APT package manager" \
		oc-apt.lua install.lua create-package.lua README.md
	@echo "Release deployed successfully!"

# Install locally (for development)
install-local:
	@echo "Installing OC-APT locally..."
	@mkdir -p ~/.local/bin
	@cp oc-apt.lua ~/.local/bin/
	@cp install.lua ~/.local/bin/
	@cp create-package.lua ~/.local/bin/
	@chmod +x ~/.local/bin/oc-apt.lua
	@chmod +x ~/.local/bin/install.lua
	@chmod +x ~/.local/bin/create-package.lua
	@echo "Local installation complete!"

# Run tests (if we add them later)
test:
	@echo "Running tests..."
	@echo "No tests implemented yet!"

# Check for common issues
lint:
	@echo "Checking for common issues..."
	@grep -n "TODO\|FIXME\|XXX" *.lua || echo "No TODO items found"
	@echo "Lint check complete!"

# Create distribution package
dist: clean validate
	@echo "Creating distribution package..."
	@mkdir -p dist
	@cp oc-apt.lua dist/
	@cp install.lua dist/
	@cp create-package.lua dist/
	@cp README.md dist/
	@cp LICENSE dist/
	@cp example-packages.json dist/
	@tar -czf dist/oc-apt.tar.gz -C dist .
	@echo "Distribution package created: dist/oc-apt.tar.gz"

# Development setup
dev-setup:
	@echo "Setting up development environment..."
	@echo "Installing development dependencies..."
	@if command -v luacheck &> /dev/null; then \
		echo "luacheck already installed"; \
	else \
		echo "Please install luacheck for better linting"; \
	fi
	@echo "Development setup complete!"

# Quick development test
dev-test: validate examples
	@echo "Running development tests..."
	@echo "All development tests passed!" 