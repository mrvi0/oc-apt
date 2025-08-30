#!/usr/bin/env lua

--[[
Standalone Package Validation Tool
Validates OC-APT packages without OpenComputers dependencies
]]

local json = require("json") or require("dkjson") or require("cjson")

-- Simple JSON implementation if none available
if not json then
    json = {
        decode = function(str)
            -- Very basic JSON decode for validation purposes
            local f = load("return " .. str)
            return f and f()
        end
    }
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
    
    -- Validate package name
    if package.name and not package.name:match("^[a-z][a-z0-9%-]*$") then
        table.insert(errors, "Package name must start with a letter and contain only lowercase letters, numbers, and hyphens")
    end
    
    -- Validate version format
    if package.version and not package.version:match("^%d+%.%d+%.%d+") then
        table.insert(errors, "Version must follow semver format (x.y.z)")
    end
    
    return #errors == 0, errors
end

-- Main function
local function main(args)
    local filename = args[1] or "package.json"
    
    if not filename or filename == "--help" or filename == "-h" then
        print("Package Validation Tool")
        print("Usage: lua validate-package.lua <package.json>")
        return
    end
    
    -- Read package file
    local file = io.open(filename, "r")
    if not file then
        print("ERROR: Package file not found: " .. filename)
        os.exit(1)
    end
    
    local content = file:read("*a")
    file:close()
    
    -- Parse JSON
    local success, package = pcall(json.decode, content)
    if not success then
        print("ERROR: Invalid JSON in package file")
        os.exit(1)
    end
    
    -- Validate package
    local valid, errors = validate_package(package)
    if valid then
        print("SUCCESS: Package validation passed!")
    else
        print("ERROR: Package validation failed:")
        for _, err in ipairs(errors) do
            print("  - " .. err)
        end
        os.exit(1)
    end
end

-- Parse arguments and run
local args = {...}
main(args) 