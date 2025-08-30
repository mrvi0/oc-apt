#!/bin/lua

--[[
OC-APT Installation Script
Downloads and installs the APT package manager for OpenComputers
]]

local component = require("component")
local computer = require("computer")
local filesystem = require("filesystem")

-- Try to load internet component safely
local internet
local success_inet = pcall(function()
    internet = require("internet")
end)

-- Configuration
local INSTALL_CONFIG = {
    apt_url = "https://raw.githubusercontent.com/mrvi0/oc-apt/main/oc-apt.lua",
    install_path = "/usr/bin/oc-apt.lua",
    symlink_path = "/usr/bin/apt"
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

-- Ensure directory exists
local function ensure_dir(path)
    local dir = filesystem.path(path)
    if not filesystem.exists(dir) then
        filesystem.makeDirectory(dir)
    end
end

-- Download file from URL
local function download_file(url, path)
    print_info("Downloading from: " .. url)
    
    -- Use the internet API (higher level)
    local inet = require("internet")
    local handle = inet.request(url)
    if not handle then
        return false, "Failed to create HTTP request"
    end
    
    local result = ""
    local timeout = computer.uptime() + 30 -- 30 second timeout
    
    -- Safe iteration with error handling
    local success, err = pcall(function()
        for chunk in handle do
            if chunk then
                result = result .. chunk
            end
            
            -- Check timeout
            if computer.uptime() > timeout then
                error("Request timeout")
            end
        end
    end)
    
    if not success then
        return false, err or "Download failed"
    end
    
    if result == "" then
        return false, "Empty response"
    end
    
    ensure_dir(path)
    local file = io.open(path, "w")
    if not file then
        return false, "Cannot create file: " .. path
    end
    
    file:write(result)
    file:close()
    return true
end

-- Main installation function
local function install_apt()
    print_colored(COLORS.BLUE, "=== OC-APT Installation ===")
    print()
    
    -- Check if internet card is available
    if not component.isAvailable("internet") then
        print_error("Internet card required for installation")
        print("Please install an Internet Card and try again")
        return false
    end
    
    -- Download the main APT script
    print_info("Downloading OC-APT...")
    local success, err = download_file(INSTALL_CONFIG.apt_url, INSTALL_CONFIG.install_path)
    if not success then
        print_error("Failed to download OC-APT: " .. (err or "unknown error"))
        return false
    end
    
    -- Make executable
    print_info("Setting up permissions...")
    -- Note: chmod may not be available in all OpenOS versions
    
    -- Create symlink
    print_info("Creating symlink...")
    if filesystem.exists(INSTALL_CONFIG.symlink_path) then
        filesystem.remove(INSTALL_CONFIG.symlink_path)
    end
    
    local ok, err = filesystem.link(INSTALL_CONFIG.install_path, INSTALL_CONFIG.symlink_path)
    if not ok then
        print_warning("Failed to create symlink: " .. tostring(err or "unknown error"))
        print_info("Creating wrapper script instead...")
        
        -- Create a Lua wrapper script
        local wrapper_file = io.open(INSTALL_CONFIG.symlink_path, "w")
        if wrapper_file then
            wrapper_file:write("#!/bin/lua\n")
            wrapper_file:write("-- OC-APT wrapper script\n")
            wrapper_file:write("local args = {...}\n")
            wrapper_file:write("dofile(\"" .. INSTALL_CONFIG.install_path .. "\")\n")
            wrapper_file:close()
            print_success("Wrapper script created successfully")
        else
            print_error("Failed to create wrapper script")
            print("You can manually use: lua " .. INSTALL_CONFIG.install_path .. " <command>")
        end
    else
        print_success("Symlink created successfully")
    end
    
    print()
    print_success("OC-APT installed successfully!")
    print()
    print_info("You can now use the following commands:")
    print("  apt update           - Update package lists")
    print("  apt search <query>   - Search for packages")
    print("  apt install <name>   - Install a package")
    print("  apt list             - List available packages")
    print()
    print_info("Run 'apt update' to download the latest package lists")
    
    return true
end

-- Check for help argument
local args = {...}
if #args > 0 and (args[1] == "-h" or args[1] == "--help" or args[1] == "help") then
    print("OC-APT Installation Script")
    print()
    print("This script downloads and installs the APT package manager")
    print("for OpenComputers mod (Minecraft 1.7.10)")
    print()
    print("Usage: lua install.lua")
    print()
    print("Requirements:")
    print("  - Internet Card in the computer")
    print("  - Write access to /usr/bin/")
    return
end

-- Run installation
if not install_apt() then
    print()
    print_error("Installation failed!")
    print("Please check the error messages above and try again")
    os.exit(1)
end 