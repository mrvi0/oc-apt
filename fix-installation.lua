#!/bin/lua

--[[
Quick Fix Script for OC-APT Installation Issues
Run this if you're getting "envlua: file not found" errors
]]

local filesystem = require("filesystem")

print("=== OC-APT Quick Fix ===")
print()

-- Fix the main script shebang
local apt_path = "/usr/bin/oc-apt.lua"
if filesystem.exists(apt_path) then
    print("Fixing main script shebang...")
    
    local file = io.open(apt_path, "r")
    if file then
        local content = file:read("*a")
        file:close()
        
        -- Replace the shebang
        content = content:gsub("#!/usr/bin/env lua", "#!/bin/lua")
        
        file = io.open(apt_path, "w")
        if file then
            file:write(content)
            file:close()
            print("✓ Fixed main script")
        else
            print("✗ Failed to write main script")
        end
    else
        print("✗ Failed to read main script")
    end
else
    print("✗ Main script not found at " .. apt_path)
end

-- Create working wrapper script
local symlink_path = "/usr/bin/apt"
print("Creating wrapper script...")

local wrapper_file = io.open(symlink_path, "w")
if wrapper_file then
    wrapper_file:write("#!/bin/lua\n")
    wrapper_file:write("-- OC-APT wrapper script\n")
    wrapper_file:write("local args = {...}\n")
    wrapper_file:write("dofile(\"/usr/bin/oc-apt.lua\")\n")
    wrapper_file:close()
    print("✓ Created wrapper script")
else
    print("✗ Failed to create wrapper script")
end

print()
print("=== Fix Complete ===")
print()
print("Now try:")
print("  apt update")
print("  apt install oc-htop")
print()
print("If that doesn't work, you can always use:")
print("  lua /usr/bin/oc-apt.lua update")
print("  lua /usr/bin/oc-apt.lua install oc-htop") 