#!/bin/lua

--[[
OC-APT Uninstaller
Completely removes OC-APT package manager from the system
]]

local filesystem = require("filesystem")

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

local function print_warning(text)
    print_colored(COLORS.YELLOW, "WARNING: " .. text)
end

local function print_info(text)
    print_colored(COLORS.CYAN, "INFO: " .. text)
end

-- Files and directories to remove
local UNINSTALL_ITEMS = {
    files = {
        "/usr/bin/oc-apt.lua",
        "/usr/bin/apt", 
        "/usr/bin/oc-apt.lua.backup"
    },
    directories = {
        "/etc/oc-apt/",
        "/var/cache/oc-apt/",
        "/var/lib/oc-apt/"
    }
}

local function confirm_uninstall()
    print_colored(COLORS.BLUE, "=== OC-APT Uninstaller ===")
    print()
    print_warning("This will completely remove OC-APT and all its data!")
    print()
    print("The following will be removed:")
    print()
    print("Files:")
    for _, file in ipairs(UNINSTALL_ITEMS.files) do
        if filesystem.exists(file) then
            print_colored(COLORS.RED, "  - " .. file)
        else
            print_colored(COLORS.YELLOW, "  - " .. file .. " (not found)")
        end
    end
    
    print()
    print("Directories:")
    for _, dir in ipairs(UNINSTALL_ITEMS.directories) do
        if filesystem.exists(dir) then
            print_colored(COLORS.RED, "  - " .. dir)
        else
            print_colored(COLORS.YELLOW, "  - " .. dir .. " (not found)")
        end
    end
    
    print()
    print_warning("This will also remove:")
    print("  - All installed package information")
    print("  - Package cache")
    print("  - Repository configurations")
    print("  - Any custom settings")
    print()
    
    io.write("Do you want to continue? (yes/no): ")
    local response = io.read()
    
    return response and (response:lower() == "yes" or response:lower() == "y")
end

local function remove_file(path)
    if filesystem.exists(path) then
        local success, err = pcall(filesystem.remove, path)
        if success then
            print_success("Removed: " .. path)
            return true
        else
            print_error("Failed to remove " .. path .. ": " .. tostring(err))
            return false
        end
    else
        print_info("Not found: " .. path)
        return true
    end
end

local function remove_directory(path)
    if filesystem.exists(path) then
        local success, err = pcall(filesystem.remove, path)
        if success then
            print_success("Removed directory: " .. path)
            return true
        else
            print_error("Failed to remove directory " .. path .. ": " .. tostring(err))
            return false
        end
    else
        print_info("Directory not found: " .. path)
        return true
    end
end

local function uninstall_oc_apt()
    if not confirm_uninstall() then
        print()
        print_info("Uninstallation cancelled.")
        return
    end
    
    print()
    print_info("Starting uninstallation...")
    print()
    
    local success_count = 0
    local total_count = 0
    
    -- Remove files
    print_info("Removing files...")
    for _, file in ipairs(UNINSTALL_ITEMS.files) do
        total_count = total_count + 1
        if remove_file(file) then
            success_count = success_count + 1
        end
    end
    
    -- Remove directories (in reverse order to handle nested directories)
    print()
    print_info("Removing directories...")
    for i = #UNINSTALL_ITEMS.directories, 1, -1 do
        local dir = UNINSTALL_ITEMS.directories[i]
        total_count = total_count + 1
        if remove_directory(dir) then
            success_count = success_count + 1
        end
    end
    
    print()
    print_colored(COLORS.BLUE, "=== Uninstallation Summary ===")
    print()
    
    if success_count == total_count then
        print_success("OC-APT has been completely removed!")
        print_info("Removed " .. success_count .. "/" .. total_count .. " items successfully")
    else
        print_warning("Uninstallation completed with some errors")
        print_info("Removed " .. success_count .. "/" .. total_count .. " items")
        print()
        print_info("You may need to manually remove any remaining files")
    end
    
    print()
    print_info("To reinstall OC-APT, run:")
    print("  wget https://raw.githubusercontent.com/mrvi0/oc-apt/main/install.lua")
    print("  lua install.lua")
end

-- Main execution
local args = {...}

if #args > 0 and (args[1] == "--help" or args[1] == "-h") then
    print("OC-APT Uninstaller")
    print()
    print("Usage: lua uninstall.lua")
    print()
    print("This script will completely remove OC-APT from your system,")
    print("including all installed package information and settings.")
    print()
    print("Options:")
    print("  --help, -h    Show this help message")
elseif #args > 0 and args[1] == "--force" then
    print_warning("Force uninstall not implemented for safety reasons")
    print_info("Please run without --force and confirm manually")
else
    uninstall_oc_apt()
end 