#!/usr/bin/env lua

--[[
Simple wget implementation for OpenComputers
Downloads files from the internet
]]

local component = require("component")
local internet = require("internet")
local filesystem = require("filesystem")
local shell = require("shell")

-- Check if internet card is available
if not component.isAvailable("internet") then
    io.stderr:write("Error: Internet card required\n")
    os.exit(1)
end

-- Parse command line arguments
local args, options = shell.parse(...)

if #args == 0 or options.h or options.help then
    print("wget - download files from the internet")
    print()
    print("Usage: wget [options] <url> [output_file]")
    print()
    print("Options:")
    print("  -h, --help     Show this help message")
    print("  -o <file>      Output file (default: filename from URL)")
    print("  -q, --quiet    Quiet mode")
    print("  -v, --verbose  Verbose mode")
    print()
    print("Examples:")
    print("  wget http://example.com/file.txt")
    print("  wget http://example.com/file.txt myfile.txt")
    print("  wget -o output.txt http://example.com/data")
    os.exit(0)
end

local url = args[1]
local output_file = args[2] or options.o

-- Extract filename from URL if not specified
if not output_file then
    output_file = url:match("([^/]+)$") or "downloaded_file"
    if output_file == "" then
        output_file = "index.html"
    end
end

-- Verbose logging function
local function log(message)
    if not options.q and not options.quiet then
        print(message)
    end
end

-- Verbose logging function
local function verbose_log(message)
    if options.v or options.verbose then
        print(message)
    end
end

-- Download function
local function download(url, filepath)
    log("Downloading: " .. url)
    verbose_log("Output file: " .. filepath)
    
    local handle = internet.request(url)
    if not handle then
        io.stderr:write("Error: Failed to create HTTP request\n")
        return false
    end
    
    -- Ensure output directory exists
    local dir = filesystem.path(filepath)
    if dir and dir ~= "" and not filesystem.exists(dir) then
        filesystem.makeDirectory(dir)
    end
    
    local file = io.open(filepath, "w")
    if not file then
        io.stderr:write("Error: Cannot create file: " .. filepath .. "\n")
        handle:close()
        return false
    end
    
    local total_size = 0
    local chunk_count = 0
    
    verbose_log("Starting download...")
    
    repeat
        local chunk = handle:read(8192)
        if chunk then
            file:write(chunk)
            total_size = total_size + #chunk
            chunk_count = chunk_count + 1
            
            if chunk_count % 10 == 0 then
                verbose_log("Downloaded " .. total_size .. " bytes...")
            end
        end
    until not chunk
    
    file:close()
    handle:close()
    
    log("Download complete: " .. total_size .. " bytes saved to " .. filepath)
    return true
end

-- Main execution
local success = download(url, output_file)
if not success then
    os.exit(1)
end 