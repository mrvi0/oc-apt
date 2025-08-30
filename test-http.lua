#!/usr/bin/env lua

--[[
Simple HTTP Test Script for OC-APT
Tests the HTTP download functionality
]]

local component = require("component")
local computer = require("computer")
local internet = require("internet")

-- Check if internet component is available
if not component.isAvailable("internet") then
    print("ERROR: Internet card not found!")
    print("Please install an Internet Card and try again.")
    os.exit(1)
end

print("Testing HTTP functionality...")
print()

-- Test HTTP request function (same as in oc-apt.lua)
local function http_request(url)
    print("Requesting: " .. url)
    
    -- Use the internet API (higher level)
    local inet = require("internet")
    local handle = inet.request(url)
    if not handle then
        return nil, "Failed to create HTTP request"
    end
    
    local result = ""
    local timeout = computer.uptime() + 30 -- 30 second timeout
    local bytes_received = 0
    
    -- Safe iteration with error handling
    local success, err = pcall(function()
        for chunk in handle do
            if chunk then
                result = result .. chunk
                bytes_received = bytes_received + #chunk
                if bytes_received % 4096 == 0 then
                    print("  Downloaded: " .. bytes_received .. " bytes")
                end
            end
            
            -- Check timeout
            if computer.uptime() > timeout then
                error("Request timeout")
            end
        end
    end)
    
    if not success then
        return nil, err or "Download failed"
    end
    
    print("  Total downloaded: " .. bytes_received .. " bytes")
    return result
end

-- Test 1: Download a simple text file
print("Test 1: Downloading a test URL...")
local test_url = "https://httpbin.org/robots.txt"
local content, err = http_request(test_url)

if content then
    print("✅ SUCCESS: HTTP request completed")
    print("Content preview:")
    print(string.sub(content, 1, 200) .. (string.len(content) > 200 and "..." or ""))
else
    print("❌ FAILED: " .. (err or "Unknown error"))
end

print()

-- Test 2: Download package information (if available)
print("Test 2: Testing package repository access...")
local repo_url = "https://raw.githubusercontent.com/mrvi0/oc-apt/main/example-packages.json"
local repo_content, repo_err = http_request(repo_url)

if repo_content then
    print("✅ SUCCESS: Repository access works")
    print("Repository size: " .. string.len(repo_content) .. " bytes")
    
    -- Try to parse JSON (basic check)
    if string.find(repo_content, "{") and string.find(repo_content, "}") then
        print("✅ Repository appears to be valid JSON")
    else
        print("⚠️  Warning: Repository content may not be valid JSON")
    end
else
    print("❌ FAILED: " .. (repo_err or "Unknown error"))
    print("Note: This might be expected if the repository doesn't exist yet")
end

print()
print("=== HTTP Test Complete ===")
print()
print("If both tests passed, OC-APT should work correctly!")
print("If tests failed, check your internet connection and try again.") 