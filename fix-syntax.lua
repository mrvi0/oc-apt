#!/bin/lua

--[[
Syntax Fix Script for OC-APT
Fixes compatibility issues with OpenComputers Lua
]]

local filesystem = require("filesystem")
local internet = require("internet")
local computer = require("computer")

print("=== OC-APT Syntax Fix ===")
print()

-- Download the fixed version
local apt_path = "/usr/bin/oc-apt.lua"
local backup_path = "/usr/bin/oc-apt.lua.backup"

-- Create backup
if filesystem.exists(apt_path) then
    print("Creating backup...")
    filesystem.copy(apt_path, backup_path)
    print("✓ Backup created at " .. backup_path)
end

-- Download fixed version
print("Downloading fixed version...")
local handle = internet.request("https://raw.githubusercontent.com/mrvi0/oc-apt/main/oc-apt.lua")
if not handle then
    print("✗ Failed to download fixed version")
    return
end

local result = ""
for chunk in handle do
    if chunk then
        result = result .. chunk
    end
end

if result == "" then
    print("✗ Empty response from server")
    return
end

-- Write the fixed version
local file = io.open(apt_path, "w")
if file then
    file:write(result)
    file:close()
    print("✓ Fixed version installed")
else
    print("✗ Failed to write fixed version")
    return
end

print()
print("=== Fix Complete ===")
print()
print("Now try:")
print("  apt update")
print("  apt install oc-htop")
print()
print("If there are still issues, you can restore the backup:")
print("  mv " .. backup_path .. " " .. apt_path) 