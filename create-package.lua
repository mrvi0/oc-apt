#!/usr/bin/env lua

--[[
Package Creation Tool for OC-APT
Helps developers create and validate packages
]]

local filesystem = require("filesystem")
local json = require("json")
local shell = require("shell")

-- Configuration
local PACKAGE_TEMPLATE = {
    name = "",
    version = "1.0.0",
    description = "",
    author = "",
    license = "MIT",
    dependencies = {},
    files = {},
    executable = {},
    keywords = {},
    homepage = "",
    repository = {
        type = "git",
        url = ""
    },
    bugs = {
        url = ""
    },
    requirements = {
        components = {},
        minimum_memory = 192,
        minimum_storage = 64
    }
}

-- Color codes
local COLORS = {
    RED = "\27[31m",
    GREEN = "\27[32m",
    YELLOW = "\27[33m",
    BLUE = "\27[34m",
    CYAN = "\27[36m",
    RESET = "\27[0m"
}

local function print_colored(color, text)
    io.write(color .. text .. COLORS.RESET .. "\n")
end

local function print_error(text)
    print_colored(COLORS.RED, "ERROR: " .. text)
end

local function print_success(text)
    print_colored(COLORS.GREEN, "SUCCESS: " .. text)
end

local function print_info(text)
    print_colored(COLORS.CYAN, "INFO: " .. text)
end

local function print_warning(text)
    print_colored(COLORS.YELLOW, "WARNING: " .. text)
end

-- Read user input
local function read_input(prompt, default)
    if default then
        io.write(prompt .. " [" .. default .. "]: ")
    else
        io.write(prompt .. ": ")
    end
    local input = io.read():trim()
    return input ~= "" and input or default
end

-- Read yes/no input
local function read_yes_no(prompt, default)
    local default_str = default and "Y/n" or "y/N"
    io.write(prompt .. " [" .. default_str .. "]: ")
    local input = io.read():trim():lower()
    
    if input == "" then
        return default
    end
    
    return input == "y" or input == "yes"
end

-- Split string by delimiter
local function split(str, delimiter)
    local result = {}
    local pattern = "([^" .. delimiter .. "]+)"
    for match in str:gmatch(pattern) do
        table.insert(result, match:trim())
    end
    return result
end

-- String trim function
function string:trim()
    return self:match("^%s*(.-)%s*$")
end

-- Validate package name
local function validate_package_name(name)
    if not name or name == "" then
        return false, "Package name cannot be empty"
    end
    
    if not name:match("^[a-z][a-z0-9%-]*$") then
        return false, "Package name must start with a letter and contain only lowercase letters, numbers, and hyphens"
    end
    
    if #name > 50 then
        return false, "Package name too long (max 50 characters)"
    end
    
    return true
end

-- Validate version
local function validate_version(version)
    if not version or version == "" then
        return false, "Version cannot be empty"
    end
    
    if not version:match("^%d+%.%d+%.%d+") then
        return false, "Version must follow semver format (x.y.z)"
    end
    
    return true
end

-- Create package interactively
local function create_package_interactive()
    print_colored(COLORS.BLUE, "=== OC-APT Package Creator ===")
    print()
    print_info("This tool will help you create a new package for OC-APT")
    print()
    
    local package = {}
    
    -- Package name
    repeat
        package.name = read_input("Package name")
        local valid, err = validate_package_name(package.name)
        if not valid then
            print_error(err)
        end
    until valid
    
    -- Version
    repeat
        package.version = read_input("Version", PACKAGE_TEMPLATE.version)
        local valid, err = validate_version(package.version)
        if not valid then
            print_error(err)
        end
    until valid
    
    -- Description
    package.description = read_input("Description")
    
    -- Author
    package.author = read_input("Author")
    
    -- License
    package.license = read_input("License", PACKAGE_TEMPLATE.license)
    
    -- Dependencies
    local deps_input = read_input("Dependencies (comma-separated, leave empty for none)")
    if deps_input and deps_input ~= "" then
        package.dependencies = split(deps_input, ",")
    else
        package.dependencies = {}
    end
    
    -- Files
    print()
    print_info("Now let's add files to your package.")
    print_info("Enter file mappings in format: destination=source")
    print_info("Example: /usr/bin/myapp.lua=./src/myapp.lua")
    print_info("Enter empty line when done")
    
    package.files = {}
    repeat
        local file_mapping = read_input("File mapping")
        if file_mapping and file_mapping ~= "" then
            local dest, src = file_mapping:match("^(.+)=(.+)$")
            if dest and src then
                package.files[dest:trim()] = src:trim()
            else
                print_error("Invalid format. Use: destination=source")
            end
        end
    until not file_mapping or file_mapping == ""
    
    -- Executable files
    if next(package.files) then
        print()
        print_info("Mark executable files:")
        package.executable = {}
        for dest, _ in pairs(package.files) do
            if read_yes_no("Make " .. dest .. " executable?", dest:match("%.lua$") ~= nil) then
                table.insert(package.executable, dest)
            end
        end
    else
        package.executable = {}
    end
    
    -- Keywords
    local keywords_input = read_input("Keywords (comma-separated, leave empty for none)")
    if keywords_input and keywords_input ~= "" then
        package.keywords = split(keywords_input, ",")
    else
        package.keywords = {}
    end
    
    -- Repository info
    package.homepage = read_input("Homepage URL (optional)")
    local repo_url = read_input("Repository URL (optional)")
    if repo_url and repo_url ~= "" then
        package.repository = {
            type = "git",
            url = repo_url
        }
        package.bugs = {
            url = repo_url .. "/issues"
        }
    end
    
    -- Requirements
    print()
    print_info("System requirements:")
    local components_input = read_input("Required components (comma-separated, e.g.: internet,gpu)")
    if components_input and components_input ~= "" then
        package.requirements = {
            components = split(components_input, ","),
            minimum_memory = tonumber(read_input("Minimum memory (KB)", "192")) or 192,
            minimum_storage = tonumber(read_input("Minimum storage (KB)", "64")) or 64
        }
    else
        package.requirements = PACKAGE_TEMPLATE.requirements
    end
    
    return package
end

-- Validate package structure
local function validate_package(package)
    local errors = {}
    
    -- Check required fields
    if not package.name or package.name == "" then
        table.insert(errors, "Package name is required")
    end
    
    if not package.version or package.version == "" then
        table.insert(errors, "Package version is required")
    end
    
    if not package.description or package.description == "" then
        table.insert(errors, "Package description is required")
    end
    
    -- Validate files exist
    if package.files then
        for dest, src in pairs(package.files) do
            if not filesystem.exists(src) then
                table.insert(errors, "Source file not found: " .. src)
            end
        end
    end
    
    return #errors == 0, errors
end

-- Save package to file
local function save_package(package, filename)
    filename = filename or "package.json"
    
    local file = io.open(filename, "w")
    if not file then
        return false, "Cannot create file: " .. filename
    end
    
    local json_str = json.encode(package)
    -- Pretty print JSON
    json_str = json_str:gsub(',', ',\n  ')
    json_str = json_str:gsub('{', '{\n  ')
    json_str = json_str:gsub('}', '\n}')
    
    file:write(json_str)
    file:close()
    
    return true
end

-- Main function
local function main(args)
    local command = args[1]
    
    if command == "create" or command == "new" then
        local package = create_package_interactive()
        
        print()
        print_info("Package configuration complete!")
        print()
        
        -- Validate package
        local valid, errors = validate_package(package)
        if not valid then
            print_error("Package validation failed:")
            for _, err in ipairs(errors) do
                print("  - " .. err)
            end
            print()
            if read_yes_no("Save anyway?", false) then
                local success, err = save_package(package)
                if success then
                    print_success("Package saved to package.json")
                else
                    print_error("Failed to save package: " .. err)
                end
            end
            return
        end
        
        -- Save package
        local success, err = save_package(package)
        if success then
            print_success("Package saved to package.json")
            print()
            print_info("Next steps:")
            print("1. Test your package locally")
            print("2. Upload files to a web server")
            print("3. Update file URLs in package.json")
            print("4. Submit to a package repository")
        else
            print_error("Failed to save package: " .. err)
        end
        
    elseif command == "validate" then
        local filename = args[2] or "package.json"
        
        if not filesystem.exists(filename) then
            print_error("Package file not found: " .. filename)
            return
        end
        
        local file = io.open(filename, "r")
        local content = file:read("*a")
        file:close()
        
        local success, package = pcall(json.decode, content)
        if not success then
            print_error("Invalid JSON in package file")
            return
        end
        
        local valid, errors = validate_package(package)
        if valid then
            print_success("Package validation passed!")
        else
            print_error("Package validation failed:")
            for _, err in ipairs(errors) do
                print("  - " .. err)
            end
        end
        
    else
        print("OC-APT Package Creator")
        print()
        print("Usage:")
        print("  lua create-package.lua create    - Create a new package interactively")
        print("  lua create-package.lua validate [file] - Validate package.json")
        print()
        print("Examples:")
        print("  lua create-package.lua create")
        print("  lua create-package.lua validate my-package.json")
    end
end

-- Parse arguments and run
local args = {...}
main(args) 