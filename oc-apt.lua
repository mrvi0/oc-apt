#!/usr/bin/env lua

--[[
OpenComputers APT Manager
A package manager for OpenComputers mod (Minecraft 1.7.10)

Author: Vi
License: MIT
]]

local computer = require("computer")
local component = require("component")
local filesystem = require("filesystem")
local internet = require("internet")
local json = require("json")
local shell = require("shell")
local term = require("term")

-- Configuration
local APT_CONFIG = {
    version = "1.0.0",
    config_dir = "/etc/oc-apt/",
    cache_dir = "/var/cache/oc-apt/",
    db_file = "/var/lib/oc-apt/installed.json",
    repos_file = "/etc/oc-apt/sources.list",
    default_repos = {
        "https://raw.githubusercontent.com/mrvi0/oc-apt/main/packages.json"
    }
}

-- Color codes for terminal output
local COLORS = {
    RED = "\27[31m",
    GREEN = "\27[32m",
    YELLOW = "\27[33m",
    BLUE = "\27[34m",
    MAGENTA = "\27[35m",
    CYAN = "\27[36m",
    WHITE = "\27[37m",
    RESET = "\27[0m"
}

-- Utility functions
local function print_colored(color, text)
    io.write(color .. text .. COLORS.RESET .. "\n")
end

local function print_error(text)
    print_colored(COLORS.RED, "ERROR: " .. text)
end

local function print_success(text)
    print_colored(COLORS.GREEN, "SUCCESS: " .. text)
end

local function print_warning(text)
    print_colored(COLORS.YELLOW, "WARNING: " .. text)
end

local function print_info(text)
    print_colored(COLORS.CYAN, "INFO: " .. text)
end

-- Ensure directory exists
local function ensure_dir(path)
    if not filesystem.exists(path) then
        filesystem.makeDirectory(path)
    end
end

-- Initialize APT directories and files
local function init_apt()
    ensure_dir(APT_CONFIG.config_dir)
    ensure_dir(APT_CONFIG.cache_dir)
    ensure_dir(filesystem.path(APT_CONFIG.db_file))
    
    -- Initialize repos file if it doesn't exist
    if not filesystem.exists(APT_CONFIG.repos_file) then
        local file = io.open(APT_CONFIG.repos_file, "w")
        for _, repo in ipairs(APT_CONFIG.default_repos) do
            file:write(repo .. "\n")
        end
        file:close()
    end
    
    -- Initialize installed packages database
    if not filesystem.exists(APT_CONFIG.db_file) then
        local file = io.open(APT_CONFIG.db_file, "w")
        file:write("{}")
        file:close()
    end
end

-- HTTP request function
local function http_request(url)
    local handle = internet.request(url)
    if not handle then
        return nil, "Failed to create HTTP request"
    end
    
    local result = ""
    local timeout = computer.uptime() + 30 -- 30 second timeout
    
    -- Use the iterator approach as documented
    for chunk in handle do
        result = result .. chunk
        
        -- Check timeout
        if computer.uptime() > timeout then
            return nil, "Request timeout"
        end
    end
    
    return result
end

-- Download file from URL
local function download_file(url, path)
    local content, err = http_request(url)
    if not content then
        return false, err
    end
    
    ensure_dir(filesystem.path(path))
    local file = io.open(path, "w")
    if not file then
        return false, "Cannot create file: " .. path
    end
    
    file:write(content)
    file:close()
    return true
end

-- Load JSON file
local function load_json(path)
    if not filesystem.exists(path) then
        return {}
    end
    
    local file = io.open(path, "r")
    if not file then
        return {}
    end
    
    local content = file:read("*a")
    file:close()
    
    local success, data = pcall(json.decode, content)
    if success then
        return data
    else
        return {}
    end
end

-- Save JSON file
local function save_json(path, data)
    ensure_dir(filesystem.path(path))
    local file = io.open(path, "w")
    if not file then
        return false
    end
    
    file:write(json.encode(data))
    file:close()
    return true
end

-- Load repositories
local function load_repos()
    local repos = {}
    local file = io.open(APT_CONFIG.repos_file, "r")
    if file then
        for line in file:lines() do
            line = line:trim()
            if line ~= "" and not line:match("^#") then
                table.insert(repos, line)
            end
        end
        file:close()
    end
    return repos
end

-- Load installed packages
local function load_installed()
    return load_json(APT_CONFIG.db_file)
end

-- Save installed packages
local function save_installed(packages)
    return save_json(APT_CONFIG.db_file, packages)
end

-- Load package cache
local function load_cache()
    return load_json(APT_CONFIG.cache_dir .. "packages.json")
end

-- Save package cache
local function save_cache(packages)
    return save_json(APT_CONFIG.cache_dir .. "packages.json", packages)
end

-- Update package lists
local function update_packages()
    print_info("Updating package lists...")
    
    local repos = load_repos()
    local all_packages = {}
    
    for _, repo_url in ipairs(repos) do
        print_info("Fetching from: " .. repo_url)
        
        local content, err = http_request(repo_url)
        if content then
            local success, repo_packages = pcall(json.decode, content)
            if success and repo_packages then
                for name, package in pairs(repo_packages) do
                    all_packages[name] = package
                    package.repository = repo_url
                end
                print_success("Repository updated successfully")
            else
                print_error("Invalid JSON in repository: " .. repo_url)
            end
        else
            print_error("Failed to fetch repository: " .. repo_url .. " (" .. (err or "unknown error") .. ")")
        end
    end
    
    save_cache(all_packages)
    print_success("Package lists updated. " .. table.size(all_packages) .. " packages available.")
end

-- Search packages
local function search_packages(query)
    local packages = load_cache()
    local results = {}
    
    query = query:lower()
    
    for name, package in pairs(packages) do
        if name:lower():find(query) or 
           (package.description and package.description:lower():find(query)) then
            table.insert(results, {name = name, package = package})
        end
    end
    
    if #results == 0 then
        print_info("No packages found matching: " .. query)
        return
    end
    
    print_info("Found " .. #results .. " packages:")
    for _, result in ipairs(results) do
        local pkg = result.package
        print(string.format("%s%s%s/%s%s%s - %s", 
            COLORS.GREEN, result.name, COLORS.RESET,
            COLORS.BLUE, pkg.version or "unknown", COLORS.RESET,
            pkg.description or "No description"))
    end
end

-- Show package info
local function show_package(name)
    local packages = load_cache()
    local package = packages[name]
    
    if not package then
        print_error("Package not found: " .. name)
        return
    end
    
    print_colored(COLORS.GREEN, "Package: " .. name)
    print("Version: " .. (package.version or "unknown"))
    print("Description: " .. (package.description or "No description"))
    print("Author: " .. (package.author or "unknown"))
    
    if package.dependencies and #package.dependencies > 0 then
        print("Dependencies: " .. table.concat(package.dependencies, ", "))
    end
    
    if package.files then
        print("Files:")
        for file_path, _ in pairs(package.files) do
            print("  " .. file_path)
        end
    end
    
    local installed = load_installed()
    if installed[name] then
        print_colored(COLORS.GREEN, "Status: Installed (version " .. installed[name].version .. ")")
    else
        print_colored(COLORS.YELLOW, "Status: Not installed")
    end
end

-- Check and install dependencies
local function install_dependencies(package_name, visited)
    visited = visited or {}
    
    if visited[package_name] then
        return true -- Already processed
    end
    visited[package_name] = true
    
    local packages = load_cache()
    local package = packages[package_name]
    
    if not package or not package.dependencies then
        return true
    end
    
    local installed = load_installed()
    
    for _, dep in ipairs(package.dependencies) do
        if not installed[dep] then
            print_info("Installing dependency: " .. dep)
            if not install_dependencies(dep, visited) then
                return false
            end
            if not install_package(dep, true) then
                return false
            end
        end
    end
    
    return true
end

-- Install package
local function install_package(name, is_dependency)
    is_dependency = is_dependency or false
    
    local packages = load_cache()
    local package = packages[name]
    
    if not package then
        print_error("Package not found: " .. name)
        return false
    end
    
    local installed = load_installed()
    if installed[name] then
        if not is_dependency then
            print_warning("Package already installed: " .. name)
        end
        return true
    end
    
    -- Install dependencies first
    if not install_dependencies(name) then
        print_error("Failed to install dependencies for: " .. name)
        return false
    end
    
    print_info("Installing package: " .. name)
    
    -- Download and install files
    if package.files then
        for file_path, file_url in pairs(package.files) do
            print_info("Downloading: " .. file_path)
            local success, err = download_file(file_url, file_path)
            if not success then
                print_error("Failed to download " .. file_path .. ": " .. (err or "unknown error"))
                return false
            end
        end
    end
    
    -- Run install script if present
    if package.install_script then
        print_info("Running install script...")
        local success, err = download_file(package.install_script, "/tmp/install_script.lua")
        if success then
            local ok, result = pcall(dofile, "/tmp/install_script.lua")
            if not ok then
                print_warning("Install script failed: " .. tostring(result))
            end
            filesystem.remove("/tmp/install_script.lua")
        end
    end
    
    -- Mark as installed
    installed[name] = {
        version = package.version,
        installed_at = os.time(),
        files = package.files and table.keys(package.files) or {}
    }
    save_installed(installed)
    
    print_success("Package installed: " .. name)
    return true
end

-- Remove package
local function remove_package(name)
    local installed = load_installed()
    
    if not installed[name] then
        print_error("Package not installed: " .. name)
        return false
    end
    
    print_info("Removing package: " .. name)
    
    local package_info = installed[name]
    
    -- Remove files
    if package_info.files then
        for _, file_path in ipairs(package_info.files) do
            if filesystem.exists(file_path) then
                print_info("Removing file: " .. file_path)
                filesystem.remove(file_path)
            end
        end
    end
    
    -- Run remove script if present
    local packages = load_cache()
    local package = packages[name]
    if package and package.remove_script then
        print_info("Running remove script...")
        local success, err = download_file(package.remove_script, "/tmp/remove_script.lua")
        if success then
            local ok, result = pcall(dofile, "/tmp/remove_script.lua")
            if not ok then
                print_warning("Remove script failed: " .. tostring(result))
            end
            filesystem.remove("/tmp/remove_script.lua")
        end
    end
    
    -- Remove from installed list
    installed[name] = nil
    save_installed(installed)
    
    print_success("Package removed: " .. name)
    return true
end

-- List installed packages
local function list_installed()
    local installed = load_installed()
    
    if table.size(installed) == 0 then
        print_info("No packages installed")
        return
    end
    
    print_info("Installed packages:")
    for name, info in pairs(installed) do
        print(string.format("%s%s%s/%s%s%s", 
            COLORS.GREEN, name, COLORS.RESET,
            COLORS.BLUE, info.version or "unknown", COLORS.RESET))
    end
end

-- List all available packages
local function list_available()
    local packages = load_cache()
    
    if table.size(packages) == 0 then
        print_info("No packages available. Run 'apt update' first.")
        return
    end
    
    print_info("Available packages:")
    for name, package in pairs(packages) do
        print(string.format("%s%s%s/%s%s%s - %s", 
            COLORS.GREEN, name, COLORS.RESET,
            COLORS.BLUE, package.version or "unknown", COLORS.RESET,
            package.description or "No description"))
    end
end

-- Upgrade all packages
local function upgrade_packages()
    local installed = load_installed()
    local packages = load_cache()
    local upgraded = 0
    
    print_info("Checking for upgrades...")
    
    for name, installed_info in pairs(installed) do
        local available = packages[name]
        if available and available.version and installed_info.version then
            if available.version ~= installed_info.version then
                print_info("Upgrading " .. name .. " from " .. installed_info.version .. " to " .. available.version)
                if remove_package(name) and install_package(name) then
                    upgraded = upgraded + 1
                end
            end
        end
    end
    
    if upgraded > 0 then
        print_success(upgraded .. " packages upgraded")
    else
        print_info("All packages are up to date")
    end
end

-- Add repository
local function add_repo(url)
    local repos = load_repos()
    
    for _, repo in ipairs(repos) do
        if repo == url then
            print_warning("Repository already exists: " .. url)
            return
        end
    end
    
    local file = io.open(APT_CONFIG.repos_file, "a")
    if file then
        file:write(url .. "\n")
        file:close()
        print_success("Repository added: " .. url)
    else
        print_error("Failed to add repository")
    end
end

-- Remove repository
local function remove_repo(url)
    local repos = load_repos()
    local new_repos = {}
    local found = false
    
    for _, repo in ipairs(repos) do
        if repo ~= url then
            table.insert(new_repos, repo)
        else
            found = true
        end
    end
    
    if not found then
        print_error("Repository not found: " .. url)
        return
    end
    
    local file = io.open(APT_CONFIG.repos_file, "w")
    if file then
        for _, repo in ipairs(new_repos) do
            file:write(repo .. "\n")
        end
        file:close()
        print_success("Repository removed: " .. url)
    else
        print_error("Failed to remove repository")
    end
end

-- List repositories
local function list_repos()
    local repos = load_repos()
    
    if #repos == 0 then
        print_info("No repositories configured")
        return
    end
    
    print_info("Configured repositories:")
    for i, repo in ipairs(repos) do
        print(i .. ": " .. repo)
    end
end

-- Utility function for table size
function table.size(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

-- Utility function for table keys
function table.keys(t)
    local keys = {}
    for k in pairs(t) do
        table.insert(keys, k)
    end
    return keys
end

-- String trim function
function string:trim()
    return self:match("^%s*(.-)%s*$")
end

-- Main command handler
local function main(args)
    init_apt()
    
    if #args == 0 then
        print("OpenComputers APT Manager v" .. APT_CONFIG.version)
        print("Usage: apt <command> [options]")
        print("")
        print("Commands:")
        print("  update              Update package lists")
        print("  install <package>   Install a package")
        print("  remove <package>    Remove a package")
        print("  search <query>      Search for packages")
        print("  show <package>      Show package information")
        print("  list [--installed]  List packages")
        print("  upgrade             Upgrade all packages")
        print("  add-repo <url>      Add repository")
        print("  remove-repo <url>   Remove repository")
        print("  list-repos          List repositories")
        return
    end
    
    local command = args[1]
    
    if command == "update" then
        update_packages()
    elseif command == "install" then
        if not args[2] then
            print_error("Package name required")
            return
        end
        install_package(args[2])
    elseif command == "remove" then
        if not args[2] then
            print_error("Package name required")
            return
        end
        remove_package(args[2])
    elseif command == "search" then
        if not args[2] then
            print_error("Search query required")
            return
        end
        search_packages(args[2])
    elseif command == "show" then
        if not args[2] then
            print_error("Package name required")
            return
        end
        show_package(args[2])
    elseif command == "list" then
        if args[2] == "--installed" then
            list_installed()
        else
            list_available()
        end
    elseif command == "upgrade" then
        upgrade_packages()
    elseif command == "add-repo" then
        if not args[2] then
            print_error("Repository URL required")
            return
        end
        add_repo(args[2])
    elseif command == "remove-repo" then
        if not args[2] then
            print_error("Repository URL required")
            return
        end
        remove_repo(args[2])
    elseif command == "list-repos" then
        list_repos()
    else
        print_error("Unknown command: " .. command)
    end
end

-- Run the program
main({...}) 