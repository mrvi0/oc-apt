#!/bin/lua

--[[
Simple OC-APT Installation Script (Fallback Version)
Uses component API directly if internet API fails
]]

local component = require("component")
local computer = require("computer")
local filesystem = require("filesystem")

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

-- Ensure directory exists
local function ensure_dir(path)
    local dir = filesystem.path(path)
    if not filesystem.exists(dir) then
        filesystem.makeDirectory(dir)
    end
end

-- Download file using component API directly
local function download_file_simple(url, path)
    print_info("Downloading from: " .. url)
    
    if not component.isAvailable("internet") then
        return false, "Internet component not available"
    end
    
    local internet = component.internet
    local handle = internet.request(url)
    if not handle then
        return false, "Failed to create HTTP request"
    end
    
    local result = ""
    local timeout = computer.uptime() + 30
    
    -- Wait for response and read data
    while true do
        local data = handle.read()
        if data then
            result = result .. data
        elseif handle.finishConnect() then
            break -- Connection finished
        end
        
        if computer.uptime() > timeout then
            handle.close()
            return false, "Request timeout"
        end
        
        computer.pullSignal(0.1) -- Small delay
    end
    
    handle.close()
    
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
    print_colored(COLORS.BLUE, "=== Simple OC-APT Installation ===")
    print()
    
    -- Check if internet card is available
    if not component.isAvailable("internet") then
        print_error("Internet card required for installation")
        print("Please install an Internet Card and try again")
        return false
    end
    
    -- Download the main APT script
    print_info("Downloading OC-APT (simple method)...")
    local success, err = download_file_simple(INSTALL_CONFIG.apt_url, INSTALL_CONFIG.install_path)
    if not success then
        print_error("Failed to download OC-APT: " .. (err or "unknown error"))
        return false
    end
    
    -- Make executable
    print_info("Setting up permissions...")
    -- Note: chmod might not work in all OpenOS versions
    
    -- Create symlink
    print_info("Creating symlink...")
    if filesystem.exists(INSTALL_CONFIG.symlink_path) then
        filesystem.remove(INSTALL_CONFIG.symlink_path)
    end
    
    local ok, err = filesystem.link(INSTALL_CONFIG.install_path, INSTALL_CONFIG.symlink_path)
    if not ok then
        print_error("Failed to create symlink: " .. tostring(err or "unknown error"))
        print_info("Creating shell script wrapper instead...")
        
        -- Create simple shell script as symlink alternative
        local link_file = io.open(INSTALL_CONFIG.symlink_path, "w")
        if link_file then
            link_file:write("#!/usr/bin/env lua\n")
            link_file:write("-- APT wrapper script\n")
            link_file:write("local args = {...}\n")
            link_file:write("dofile(\"" .. INSTALL_CONFIG.install_path .. "\")\n")
            link_file:close()
            print_success("Wrapper script created")
        else
            print_error("Failed to create wrapper script")
        end
    else
        print_success("Symlink created successfully")
    end
    
    print()
    print_success("OC-APT installed successfully!")
    print()
    print_info("You can now use the following commands:")
    print("  lua " .. INSTALL_CONFIG.install_path .. " update")
    print("  " .. INSTALL_CONFIG.symlink_path .. " update")
    print()
    print_info("Run 'apt update' to download the latest package lists")
    
    return true
end

-- Run installation
if not install_apt() then
    print()
    print_error("Installation failed!")
    print("Please check the error messages above and try again")
    print("Try using the regular install.lua if this doesn't work")
end 